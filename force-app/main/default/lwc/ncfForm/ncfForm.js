import { LightningElement, api, track, wire } from 'lwc';
import getNCF from '@salesforce/apex/CustomerPortalNCFController.getNCF';
import approveNCF from '@salesforce/apex/CustomerPortalNCFController.approveNCF';
import createCaseWithBookingOwner from '@salesforce/apex/CustomerPortalNCFController.createCaseWithBookingOwner';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class NcfForm extends LightningElement {

    @api recordId; // Optional fallback
    @track showCaseForm = false;
    @track showSpinner = false;

    // --- CASE MODAL VARIABLES ---
    @track showCaseModal = false;
    selectedBookingId;       // Holds the Booking Id for the Case
    selectedNCFId;
    selectedBookingOwnerId;  // Holds the Owner Id for the Case
    selectedUnitNumber;

    // This holds the list of Bookings+NCF data for the Tabs
    @track tabsData = [];

    defaultCaseType = 'Complaint'; 
    defaultLifecycle = 'Registration';
    defaultComplaintType = 'Registration / Agreement for Sale'; // Leave empty if you want user to pick
    defaultComplaintSubType = 'NCF Related';

    // Current Context for Case Creation
    selectedBookingId;
    
    connectedCallback() {
        this.initializeData();
    }

    /* -----------------------------------------
       1. INITIALIZE DATA FROM SESSION STORAGE
    ----------------------------------------- */
    async initializeData() {
        const storedInfo = sessionStorage.getItem('pageTransfer');

        let bookingList = [];

        // 1. Get List from Session Storage
        if (storedInfo) {
            const parsedInfo = JSON.parse(storedInfo);
            console.log('Check Parse Data',parsedInfo.bookingdetails);
            if(parsedInfo.bookingdetails){
                bookingList = parsedInfo.bookingdetails.map(record => {
                    return {
                        Id: record.BookingId,       // Mapping JSON 'BookingId' to 'Id'
                        Name: record.unitNumber     // Mapping JSON 'unitNumber' to 'Name' (for Tab Label)
                    };
                });
                console.log('Check All Boooking',bookingList);
            }
        } 
        // Fallback: If no session data, but recordId exists (Component dropped on record page)
        else if (this.recordId) {
            bookingList = [{ Id: this.recordId, Name: 'Current Booking' }]; 
        }

        if (bookingList.length === 0) {
            this.showSpinner = false;
            return;
        }

        // 2. Fetch NCF for EACH Booking ID
        // Note: Ideally, update Apex to accept a List<Id>. 
        // Here we use Promise.all to call existing getNCF multiple times efficiently.
        try {
            const promises = bookingList.map(booking => {
                return getNCF({ bookingId: booking.Id })
                    .then(ncfResult => {
                        return {
                            bookingId: booking.Id,
                            bookingOwnerId: ncfResult?.Booking__r?.OwnerId,
                            // If booking has a generic name, try to use Unit Name from NCF or fallback
                            tabLabel: ncfResult?.Booking__r?.Unit_Number__c || booking.Name || 'Booking', 
                            unitNumber: ncfResult?.Booking__r?.Unit_Number__c || '',
                            ncf: ncfResult,
                            ncfId: ncfResult?.Id,
                            // Logic for disable button
                            disableApprove: !ncfResult || ncfResult.Status__c === 'Approved' || ncfResult.Status__c === 'Raised a Case',
                            disableRaiseACase: !ncfResult || ncfResult.Status__c === 'Approved' || ncfResult.Status__c === 'Raised a Case'
                        };
                    })
                    .catch(error => {
                        console.error('Error fetching NCF for ' + booking.Id, error);
                        return {
                            bookingId: booking.Id,
                            tabLabel: booking.Name || 'Booking (Error)',
                            ncf: null,
                            disableApprove: true,
                            disableRaiseACase: true
                        };
                    });
            });
            console.log('Check Promises------>',promises);
            this.tabsData = await Promise.all(promises);
            console.log('Tabs Data Loaded:', JSON.parse(JSON.stringify(this.tabsData)));

        } catch (error) {
            this.showToast('Error', 'Failed to load booking details.', 'error');
            console.error(error);
        } finally {
            this.showSpinner = false;
        }
    }






    /* -----------------------------------------
       2. HANDLE APPROVE (CONTEXT AWARE)
    ----------------------------------------- */
    async handleApprove(event) {
        // Retrieve ID from the button clicked
        const ncfIdToApprove = event.target.dataset.ncfid;
        const bookingId = event.target.dataset.bookingid;

        if(!ncfIdToApprove) return;

        this.showSpinner = true;
        try {
            await approveNCF({ ncfId: ncfIdToApprove, bookingId:  bookingId});
            this.showToast("Success", "NCF has been approved.", "success");

            // Update local state to disable button immediately without refresh
            this.tabsData = this.tabsData.map(tab => {
                if (tab.bookingId === bookingId && tab.ncf) {
                    // Clone ncf object to update status
                    let updatedNcf = { ...tab.ncf, Status__c: "Approved" };
                    return { ...tab, ncf: updatedNcf, disableApprove: true, disableRaiseACase: true };
                }
                return tab;
            });

        } catch (error) {
            console.error(error);
            this.showToast("Error", "Failed to approve NCF.", "error");
        }
        this.showSpinner = false;
    }

    // Open Modal
    handleRaiseCase(event) {
        
        this.selectedBookingId = event.target.dataset.bookingid;
        this.selectedNCFId = event.target.dataset.ncfid;
        
        // Find the specific tab data to get the specific Booking Owner
        const selectedTab = this.tabsData.find(t => t.bookingId === this.selectedBookingId);
        
        if(selectedTab) {
            this.selectedBookingOwnerId = selectedTab.bookingOwnerId;
            this.selectedUnitNumber = selectedTab.unitNumber;
            this.showCaseModal = true;
        } else {
            this.showToast('Error', 'Could not determine booking details.', 'error');
        }
    }

    // Close Modal
    closeCaseModal() {
        this.showCaseModal = false;
        this.selectedBookingId = null;
        this.selectedNCFId = null;
        this.selectedBookingOwnerId = null;
    }

    // Trigger the form submit (Because button is outside the form)
    triggerCaseSubmit() {
        const btn = this.template.querySelector('.hidden-submit-btn');
        if(btn) btn.click();
    }

    


    /* -----------------------------------------
       3. CASE MANAGEMENT (MANUAL SAVE)
    ----------------------------------------- */
    
    // Triggered by the "Save Case" footer button
    handleSaveCase() {
        // 1. Select all input fields inside the form
        const inputFields = this.template.querySelectorAll('lightning-input-field');
        let isValid = true;
        let fields = {};

        // 2. Loop through fields to Check Validity and Collect Values
        inputFields.forEach(field => {
            // Check if field is valid (required fields are filled)
            if(!field.reportValidity()) {
                isValid = false;
            }
            // Add field name and value to our object
            fields[field.fieldName] = field.value;
        });

        // 3. Stop if validation failed
        if (!isValid) {
            this.showToast('Error', 'Please fill in all required fields.', 'error');
            return;
        }

        // 4. Validation Passed - Prepare Data for Apex
        this.showSpinner = true;

        const caseRecord = { 
            sobjectType: 'Case',
            RW_Case_Type__c: fields.RW_Case_Type__c,
            Customer_Lifecycle_Touchpoint__c: fields.Customer_Lifecycle_Touchpoint__c,
            RW_Complaint_Type__c: fields.RW_Complaint_Type__c,
            RW_Complaint_SubType__c: fields.RW_Complaint_SubType__c,
            Description: fields.Description,
            Subject: 'New Case raised via NCF Portal',
            Origin: 'Portal' // Manually setting Origin
        };

        console.log('Sending to Apex:', JSON.stringify(caseRecord));

        // 5. Call Apex
        createCaseWithBookingOwner({ 
            caseRecord: caseRecord, 
            bookingId: this.selectedBookingId ,
            ncfId: this.selectedNCFId
        })
        .then(result => {
            console.log('Apex Success:', result);
            this.showToast('Success', 'Case Created Successfully', 'success');
            this.closeCaseModal();
        })
        .catch(error => {
            console.error('Apex Error:', error);
            const message = error.body ? error.body.message : error.message;
            this.showToast('Error', 'Failed to create case: ' + message, 'error');
        })
        .finally(() => {
            this.showSpinner = false;
        });
    }

    // You can DELETE the handleCaseSubmit method entirely now.

    handleCaseSuccess(event) {
        this.showSpinner = false;
        this.showToast('Success', 'Case Created Successfully. Case ID: ' + event.detail.id, 'success');
        this.closeCaseModal();
    }

    handleCaseError(event) {
        this.showSpinner = false;
        // Error is usually handled by lightning-messages, but you can log it
        console.error('Case Create Error', event.detail);
        this.showToast('Error', 'Failed to create case. Please check required fields.', 'error');
    }



    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({ title, message, variant })
        );
    }
}