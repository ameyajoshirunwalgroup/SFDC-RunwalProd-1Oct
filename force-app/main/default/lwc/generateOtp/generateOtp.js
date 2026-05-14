import { LightningElement, api, wire, track } from 'lwc';
import generateOtp from '@salesforce/apex/GenerateOtpControllerforLeadLWC.generateOtp';
import getActiveOtpForLead from '@salesforce/apex/GenerateOtpControllerforLeadLWC.getActiveOtpForLead';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class GenerateOtp extends LightningElement {
    @api recordId;
    @track existingOtp;
    wiredOtpResult;

    @wire(getActiveOtpForLead, { leadId: '$recordId' })
    wiredOtp(result) {
        this.wiredOtpResult = result;
        const { data, error } = result;
        if (data) {
            this.existingOtp = data.Generated_OTP__c
        } else {
            this.existingOtp = null;
            if (error) console.error('Error fetching OTP:', error);
        }
    }

    handleClick() {
        generateOtp({ leadId: this.recordId })
            .then(result => {
                if (result.startsWith('SUCCESS:')) {
                    const otp = result.replace('SUCCESS:', '');
                    this.existingOtp = otp;
                    this.showToast('Success', `OTP Generated: ${otp}`, 'success');
                } else if (result.startsWith('EXISTS:')) {
                    const otp = result.replace('EXISTS:', '');
                    this.existingOtp = otp;
                    this.showToast('Info', `OTP Already Exists: ${otp}`, 'info');
                } else if (result.startsWith('ERROR:')) {
                    const errorMsg = result.replace('ERROR:', '');
                    this.showToast('Error', errorMsg, 'error');
                }
                refreshApex(this.wiredOtpResult);
            })
            .catch(error => {
                this.showToast('Error', 'Unexpected error occurred', 'error');
                console.error(error);
            });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    get showButton() {
        return !this.existingOtp;
    }

    get showOtp() {
        return !!this.existingOtp;
    }
}