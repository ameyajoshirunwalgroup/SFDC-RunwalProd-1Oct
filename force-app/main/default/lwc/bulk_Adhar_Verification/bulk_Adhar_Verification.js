import { LightningElement, api, track, wire } from 'lwc';
import getSigningURL from '@salesforce/apex/bulk_Aadhar_Verification_Integration.getBulkAadharVerification';
import verifyApplicantDetails from '@salesforce/apex/bulk_Aadhar_Verification_Integration.verifyApplicantDetails';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class Aadhar_Verification_TrueSigned_LWC extends LightningElement {
    @api recordId;

    @track showProceedButton = false;
    @track pageDisabled = false;
    @track showError = false;
    @track errorMessage = '';
    @track applicantData = [];

    @wire(verifyApplicantDetails, {sRecordIds: '$recordId' })
    wiredApplicants({ error, data }) {
        if (data) {
            this.applicantData = data;
            this.showError = data && data.length > 0;
            if (this.showError) {
                this.errorMessage = 'Some applicant details are missing. Please review the table below.';
            }
        } else if (error) {
            this.showError = true;
            this.errorMessage = 'Error checking applicant details.';
            console.error(error);
        }
    }

    handleTermsCheck(event) {
        this.showProceedButton = event.target.checked;
    }

    handleTermsSign() {
        getSigningURL({ sRrecordId: this.recordId })
            .then(() => {
                setTimeout(() => {
                    this.dispatchEvent(new CloseActionScreenEvent());
                }, 2000);
            })
            .catch((error) => {
                console.error('Error during signing:', error);
                this.pageDisabled = false;
            });
    }
}