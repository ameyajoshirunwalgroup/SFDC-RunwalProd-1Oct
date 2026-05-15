import { LightningElement, api, track, wire } from 'lwc';
    import { getPicklistValuesByRecordType, getObjectInfo } from 'lightning/uiObjectInfoApi';
    import { ShowToastEvent } from 'lightning/platformShowToastEvent';
    import { NavigationMixin } from 'lightning/navigation';
    import { RefreshEvent } from 'lightning/refresh';

    import BOOKING_OBJECT from '@salesforce/schema/Booking__c';
    import getBookingDetails from '@salesforce/apex/CancellationRequestController.getBookingDetails';
    import saveBookingDetails from '@salesforce/apex/CancellationRequestController.saveBookingDetails';

    export default class BookingDetails extends NavigationMixin(LightningElement) {
        @api recordId;
        
        @track bookingInfo;
        @track isLoading = true;

        // Picklist Tracks
        @track reasonOptions = [];
        @track subReasonOptions = [];
        @track modeOfCancellationOptions = [];
        @track meetingStatusOptions = [];
        @track cancellationSubtypeOptions = [];
        @track sourceOfCancellationOptions = [];

        allPicklistValues;
        get acceptedFormats() { return ['.jpg', '.jpeg', '.png', '.pdf']; }

        // --- Wire Data ---

        @wire(getObjectInfo, { objectApiName: BOOKING_OBJECT })
        objectInfo;

        @wire(getPicklistValuesByRecordType, { 
            objectApiName: BOOKING_OBJECT, 
            recordTypeId: '$objectInfo.data.defaultRecordTypeId' 
        })
        wiredPicklistValues({ error, data }) {
            if (data) {
                this.allPicklistValues = data.picklistFieldValues;
                this.modeOfCancellationOptions = this.allPicklistValues.Mode_of_Cancellation__c.values;
                this.meetingStatusOptions = this.allPicklistValues.Meeting_Status__c.values;
                this.reasonOptions = this.allPicklistValues.Cancellation_Reason__c.values;
                this.sourceOfCancellationOptions = this.allPicklistValues.Source_of_Cancellation__c.values;
                
                // Sync picklists if data already exists
                if (this.bookingInfo) this.syncPicklists();
            }
        }

        

        // Standard wire to fetch record data instead of manual imperative call in connectedCallback
        @wire(getBookingDetails, { recordId: '$recordId' })
        wiredBooking({ error, data }) {
            this.isLoading = true;
            if (data) {
                this.bookingInfo = JSON.parse(JSON.stringify(data));
                if (this.allPicklistValues) this.syncPicklists();
                this.isLoading = false;
            } else if (error) {
                this.showToast('Error', 'Failed to load booking', 'error');
                this.isLoading = false;
            }
        }

        // --- Getters for UI display (Null Safety) ---

        get projectName() { return this.bookingInfo?.Project__r?.Name || ''; }
        get unitNo() { return this.bookingInfo?.Unit_No__r?.RW_Param4__c || ''; }
        get towerName() { return this.bookingInfo?.Unit_No__r?.TowerName__r?.Name || ''; }
        get crnNo() { return this.bookingInfo?.Opportunity__r?.SAP_Customer_Number__c || ''; }
        get primaryApplicantName() { return this.bookingInfo?.Primary_Applicant_Name__c || ''; }
        get otherApplicantName() { return this.bookingInfo?.Opportunity__r?.Other_Applicants_Name__c || ''; }
        get bookingStatus() { return this.bookingInfo?.Status__c || ''; }
        get sourceOfBooking() { return this.bookingInfo?.Source_of_Booking__c || ''; }
        get bookingDate() { return this.bookingInfo?.Booking_Date__c || ''; }
        get registrationStatus() { return this.bookingInfo?.RW_Registration_Status__c || ''; }

        get isMeetingMode() { return this.bookingInfo?.Mode_of_Cancellation__c === 'Meeting'; }
        get isMeetingDone() { return this.bookingInfo?.Meeting_Status__c === 'Meeting done'; }
        get isWrittenMode() { return this.bookingInfo?.Mode_of_Cancellation__c === 'Written'; }
        get isOtherMode() { return this.bookingInfo?.Mode_of_Cancellation__c === 'Others'; }

        // --- Logic ---

        syncPicklists() {
            if (this.bookingInfo.Cancellation_Reason__c) {
                this.filterSubReasons(this.bookingInfo.Cancellation_Reason__c);
            }
            if (this.bookingInfo.Cancellation_Sub_reason__c) {
                this.filterSubtypes(this.bookingInfo.Cancellation_Sub_reason__c);
            }
        }

        filterSubReasons(reasonValue) {
            const fieldData = this.allPicklistValues.Cancellation_Sub_reason__c;
            const controllerValueIndex = fieldData.controllerValues[reasonValue];
            this.subReasonOptions = fieldData.values.filter(opt => opt.validFor.includes(controllerValueIndex));
        }

        filterSubtypes(subReasonValue) {
            const fieldData = this.allPicklistValues.Cancellation_Subtype__c;
            const controllerValueIndex = fieldData.controllerValues[subReasonValue];
            this.cancellationSubtypeOptions = fieldData.values.filter(opt => opt.validFor.includes(controllerValueIndex));
            
            // Auto-populate subtype if there's only one option
            if (this.cancellationSubtypeOptions.length > 0) {
                this.bookingInfo.Cancellation_Subtype__c = this.cancellationSubtypeOptions[0].value;
            }
        }

        // --- Event Handlers ---

        handleInputChange(event) {
            this.bookingInfo[event.target.name] = event.detail.value;
        }

        handleReasonChange(event) {
            const val = event.detail.value;
            this.bookingInfo.Cancellation_Reason__c = val;
            this.bookingInfo.Cancellation_Sub_reason__c = ''; 
            this.bookingInfo.Cancellation_Subtype__c = '';
            this.filterSubReasons(val);
        }

        handleSubReasonChange(event) {
            const val = event.detail.value;
            this.bookingInfo.Cancellation_Sub_reason__c = val;
            this.filterSubtypes(val);
        }

        handleUploadFinished(event){
            const uploadedFiles = event.detail.files;
    
        }

        handleSave() {
            const isInputsValid = [...this.template.querySelectorAll('lightning-input, lightning-combobox, lightning-textarea')]
                .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
                }, true);

            if (!isInputsValid) return;
            let status = 'Cancellation Requested';
            let requestedStatus = 'Cancellation Sought';
            const reason = this.bookingInfo.Cancellation_Reason__c;

            // 2. Determine statuses based on reason
            if (reason === 'Transfer') {
                requestedStatus = 'Cancellation Confirmed';
                status = 'Transfer In Progress';
            } else if (reason === 'Upgrade/Downgrade') {
                requestedStatus = 'Cancellation Confirmed';
                status = 'Upgrade In Progress';
            }
            const fieldsToSave = {
                ...this.bookingInfo,
                Id: this.recordId,
                Cancellation_Requested_Status__c: requestedStatus,
                Status__c: status,
                Cancellation_Request_Date__c: new Date().toISOString().split('T')[0] // Formats as YYYY-MM-DD
            };
            this.isLoading = true;
            
            saveBookingDetails({ bookingData: fieldsToSave })
                .then(() => {
                    this.showToast('Success', 'Updated Successfully', 'success');
                    this.dispatchEvent(new RefreshEvent());
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: { recordId: this.recordId, actionName: 'view' }
                    });
                })
                .catch(error => {
                    this.showToast('Error', error.body?.message || 'Update failed', 'error');
                })
                .finally(() => this.isLoading = false);
        }

        handleCancel() {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: { recordId: this.recordId, actionName: 'view' }
            });
        }

        showToast(title, message, variant) {
            this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
        }
    }