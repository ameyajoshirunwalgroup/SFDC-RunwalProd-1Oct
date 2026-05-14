import { LightningElement, api, track, wire } from 'lwc';
import getOppRecords from '@salesforce/apex/Customer360.getOppRecords';
import dndFromAcc from '@salesforce/apex/Customer360.dndFromAccount';
import { NavigationMixin } from 'lightning/navigation';
import { subscribe, MessageContext } from 'lightning/messageService';
import OPPORTUNITY_MESSAGE_CHANNEL from '@salesforce/messageChannel/OpportunityMessageChannel__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCustLedgerPdf from '@salesforce/apex/PDFController.getCustLedgerPdf';
import getCustomerLedgerPdf from '@salesforce/apex/PDFController.getCustomerLedgerPdf';
import click2Call from '@salesforce/apex/Customer360.click2Call';
import ResetPassword from '@salesforce/apex/Customer360.ResetPassword';
import getTasks from '@salesforce/apex/EmailTemplateController.getTasksForOpportunity'
import UpdateDND from '@salesforce/apex/Customer360.updateDND';
import UpdateStopCaseEmails from '@salesforce/apex/Customer360.updateStopCaseEmails';
import stopCaseEmailsFromAcc from '@salesforce/apex/Customer360.stopCaseEmailsFromAccount';
import USER_ID from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import ProfilesRorStopCaseEmailsLabel from '@salesforce/label/c.Profiles_for_Stop_Case_Emails';

const FIELDS = ['User.ProfileId'];
const ACCOUNT_FIELDS = ['Account.DND__c','Account.Stop_Case_Emails__c'];

export default class CenterSectionComponent extends NavigationMixin(LightningElement) {
    @track height = '900px';
    @track referrerPolicy = 'no-referrer';
    @track sandbox = '';
    @track pdfUrl;
    @track url = '';
    @track width = '100%';
    @api opportunityId;
    @api recordId;
    oppid;
    @track isModalOpen = false;
    @track taskData = [];
    @track bookingData = [];
    @track error;
    hasLoadedBookingData;
    @track isPersonalDetails = true;
    @track isBookingDetails = false;
    @wire(MessageContext)
    messageContext; 
    @track isDND = false;
    @track isStopCaseEmails = false;
    showStopCaseEmailsCheckbox = false;

    label = {ProfilesRorStopCaseEmailsLabel};

    @wire(getRecord, { recordId: USER_ID, fields: FIELDS })
    userRecord({ data, error }) {
        if (data) {
            const profileId = data.fields.ProfileId.value;
            const hiddenProfileIds = this.label.ProfilesRorStopCaseEmailsLabel.split(','); 
            this.showStopCaseEmailsCheckbox = hiddenProfileIds.includes(profileId);
        } else if (error) {
            console.error(error);
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: ACCOUNT_FIELDS })
    accountRecord({ data, error }) {
        if (data) {
            console.log('data: ', data);
            console.log('data: ', data.fields);
            console.log('data: ', data.fields.DND__c);
            this.isDND = data.fields.DND__c.value;
            this.isStopCaseEmails = data.fields.Stop_Case_Emails__c.value;
        } else if (error) {
            console.error(error);
        }
    }

    connectedCallback() {
        this.subscribeToMessageChannel();
        const params = new URLSearchParams(window.location.search);
        if (params.has('c__var2')) {
            this.recordId = params.get('c__var2');
            console.log('recordId set from URL:', this.recordId);
        }
        if (params.has('c__var1')) {
            this.oppid = params.get('c__var1');
            console.log('oppid set from URL:', this.oppid);
        }
        //this.dndFromAccount();
        //this.stopCaseEmailsFromAccount();
    }

    dndFromAccount() {
        dndFromAcc({ accountId: this.recordId })
            .then((result) => {
                console.log('--DND: ' , result);
                this.isDND = result;
            })
            .catch((error) => {
                console.error('error: ', error);
            });
    }

    stopCaseEmailsFromAccount() {
        stopCaseEmailsFromAcc({ accountId: this.recordId })
            .then((result) => {
                console.log('--stopCaseEmailsFromAcc: ' , result);
                this.isStopCaseEmails = result;
            })
            .catch((error) => {
                console.error('error: ', error);
            });
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                OPPORTUNITY_MESSAGE_CHANNEL,
                (message) => this.handleMessage(message)
            );
        }
    }

    handleMessage(message) {
        this.opportunityId = message.opportunityId;
        this.loadBookingData();
    }
    @api
    loadBookingData() {
        if (this.opportunityId) {
            getOppRecords({ oppId: this.opportunityId, accountId: this.recordId })
                .then(result => {
                    // Parse and clone the result
                    let bookingData = JSON.parse(JSON.stringify(result));

                    // Sort the VideoWrapper data within each booking record by CreatedDate
                    bookingData.forEach(bk => {
                        if (bk.VideoWrapper) {
                            bk.VideoWrapper.sort((a, b) => new Date(a.CreatedDate) - new Date(b.CreatedDate));
                        }
                    });

                    // Assign the sorted data to this.bookingData
                    this.bookingData = bookingData;
                    this.error = undefined;
                })
                .catch(error => {
                    this.error = error;
                    this.bookingData = undefined;
                });
        } else {
            this.clearBookingData();
        }
    }
    clearBookingData() {
        this.bookingData = [];
        this.error = undefined;
    }
    click2Call(event) {
        const phoneNumber = event.currentTarget.dataset.phonenumber;
        const countrycode = event.currentTarget.dataset.countrycode;
        console.log('phoneNumber', phoneNumber);
        console.log('countrycode', countrycode);
        click2Call({ countryCode: countrycode, customerPh: phoneNumber })
            .then((result) => {
                console.log('Call initiated successfully:', result);
                alert('Call initiated successfully.');
            })
            .catch((error) => {
                console.error('Error initiating call:', error);
                alert('Error initiating call: ' + error.body.message);
            });
    }

    showPersonalDetails() {
        this.isPersonalDetails = true;
        this.isBookingDetails = false;
    }

    showBookingDetails() {
        this.isPersonalDetails = false;
        this.isBookingDetails = true;
    }

    get personalButtonStyle() {
        return this.isPersonalDetails ? 'background-color: #b98e33; color: white;' : '';
    }

    get bookingButtonStyle() {
        return this.isBookingDetails ? 'background-color: #b98e33; color: white;' : '';
    }
    navigateToRecord(event) {
        event.preventDefault();
        const recordId = event.currentTarget.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view'
            }
        });
    }
    navigateToAuraComponent() {
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: 'c__CustomerLedgerViewer',
            },
            state: {
                c__recordId: this.bookingId
            }
        });
    }
    handleLedgerClick(event) {
        const recordId = event.target.dataset.id;

        getCustLedgerPdf({ recordId: recordId })
            .then(result => {
                const binary = atob(result); // Decode base64 string
                const len = binary.length;
                const buffer = new ArrayBuffer(len);
                const view = new Uint8Array(buffer);
                for (let i = 0; i < len; i++) {
                    view[i] = binary.charCodeAt(i);
                }

                const blob = new Blob([view], { type: 'application/pdf' });
                this.pdfUrl = URL.createObjectURL(blob);
                const link = document.createElement('a');
                link.href = this.pdfUrl;
                link.target = '_blank';
                link.click();
                console.log('this.pdfUrl', this.pdfUrl);
            })
            .catch(error => {
                let message = 'Unknown error';
                if (error && error.body && error.body.message) {
                    message = error.body.message;
                } else if (error && error.message) {
                    message = error.message;
                }

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading PDF',
                        message: message,
                        variant: 'error',
                    })
                );
            });
    }
    handleResetPassword() {
        console.log('accountId: ', this.recordId);
        ResetPassword({ accountId: this.recordId })
            .then(() => {
                this.showToast('Success', 'Password reset successfully.', 'success');
            })
            .catch((error) => {
                this.showToast('Error', 'Failed to reset password.', 'error');
                console.error('Error resetting password:', error);
            });
    }

    handleDND(event) {
        console.log('-event.target.checked ', event.target.checked);
        this.isDND = event.target.checked;
        UpdateDND({ accountId: this.recordId, dnd : event.target.checked })
            .then(() => {
                //this.isDND = event.target.checked;
                this.showToast('Success', 'DND updated successfully.', 'success');
            })
            .catch((error) => {
                this.showToast('Error', 'Failed to update DND.', 'error');
                console.error('Error resetting password:', error);
            });
    }

    handleStopCaseEmails(event) {
        console.log('-event.target.checked ', event.target.checked);
        this.isStopCaseEmails = event.target.checked;
        UpdateStopCaseEmails({ accountId: this.recordId, stopEmails : event.target.checked })
            .then(() => {
                //this.isStopCaseEmails = event.target.checked;
                this.showToast('Success', 'Stop Case Emails updated successfully.', 'success');
            })
            .catch((error) => {
                this.showToast('Error', 'Failed to update Stop Case Emails.', 'error');
                console.error('Error resetting password:', error);
            });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant, // 'success', 'error', 'info', 'warning'
        });
        this.dispatchEvent(event); // Dispatch the event to show the toast
    }

    handleAllInteractionClick() {
        console.log('inside method');
        this.loadTasks();
    }

    closeModal() {
        this.isModalOpen = false;
    }


    loadTasks() {
        console.log('inside loadtask');
        getTasks({ opportunityId: this.opportunityId })
            .then((result) => {
                this.taskData = result;
                this.isModalOpen = true;
            })
            .catch((error) => {
                console.error('Error fetching tasks:', error);
            });
    }
    handleInterestLedgerClick(event) {
        const CustCode = event.target.dataset.id;
        const CmpCode = event.target.dataset.companycode;
        getCustomerLedgerPdf({ customerNumber: CustCode, companycode: CmpCode })
            .then(result => {
                const binary = atob(result); // Decode base64 string
                const len = binary.length;
                const buffer = new ArrayBuffer(len);
                const view = new Uint8Array(buffer);
                for (let i = 0; i < len; i++) {
                    view[i] = binary.charCodeAt(i);
                }

                const blob = new Blob([view], { type: 'application/pdf' });
                this.pdfUrl = URL.createObjectURL(blob);
                const link = document.createElement('a');
                link.href = this.pdfUrl;
                link.target = '_blank';
                link.click();
                console.log('this.pdfUrl', this.pdfUrl);
            })
            .catch(error => {
                let message = 'Unknown error';
                if (error && error.body && error.body.message) {
                    message = error.body.message;
                } else if (error && error.message) {
                    message = error.message;
                }

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading PDF',
                        message: message,
                        variant: 'error',
                    })
                );
            });
    }
    renderedCallback() {
        const elements = this.template.querySelectorAll('.booking-field-value');
        elements.forEach(element => {
            if (element.textContent.trim() === 'TBD') {
                element.classList.add('red-text');
            }
        });
    }

    openCustomerDetailsForm() {
        window.open('/apex/CustomerDetailsForm?id='+this.opportunityId, '_blank');
    }
}