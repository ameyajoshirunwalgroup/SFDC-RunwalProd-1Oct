import { LightningElement, api, wire, track } from 'lwc';
import makeCalls from '@salesforce/apex/CallCustomerController.callAPI';
import caseData from '@salesforce/apex/CallCustomerController.caseData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CallCustomerOnCase extends LightningElement {
    @api recordId;
    @track caseRec;
    @track mobile1error = false;
    @track mobile2error = false;
    @track countryCode2;
    secondaryMobileNum;

    @wire(caseData, { recId: '$recordId' })
    wiredCaseData({ error, data }) {
        if (data) {
            this.caseRec = data;
            const account = data?.Account;
            this.secondaryMobileNum = account?.RW_Secondary_Mobile_No__pc || account?.Alternate_Mobile_No__c || null;
        } else if (error) {
            console.error('Error fetching case data:', error);
        }
    }

    get mobile1() {
        const account = this.caseRec?.Account;
        if (account?.Mobile_No__c && account?.Country_Code__c) {
            return `${account.Country_Code__c} ${account.Mobile_No__c.replace(account.Mobile_No__c.substring(0, 5), 'XXXXX')}`;
        }
        return null;
    }

    get mobile2() {
        const account = this.caseRec?.Account;
        const code = account?.Country_Code_2__c || account?.Country_Code__c;
        if (this.secondaryMobileNum && code) {
            this.countryCode2 = code;
            return `${code} ${this.secondaryMobileNum.replace(this.secondaryMobileNum.substring(0, 5), 'XXXXX')}`;
        }
        return null;
    }

    showToast(title, message, variant = 'error', mode = 'sticky') {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant, mode }));
    }

    callmobile1() {
        this.mobile1error = false;
        const account = this.caseRec?.Account;

        if (!account?.RW_Country__c) {
            this.mobile1error = true;
            this.showToast('Error', 'Dialing Country 1 is blank on Account');
        }

        if (!account?.Country_Code__c) {
            this.mobile1error = true;
            this.showToast('Error', 'Country Code 1 is blank on Account');
        }

        if (!account?.Mobile_No__c) {
            this.mobile1error = true;
            this.showToast('Error', 'Mobile 1 is blank on Account');
        }

        if (account?.RW_Country__c === 'India') {
            if (account?.Country_Code__c !== '+91') {
                this.mobile1error = true;
                this.showToast('Error', 'For India, Country Code 1 should be +91 on Account');
            }
            if (account?.Mobile_No__c?.length !== 10) {
                this.mobile1error = true;
                this.showToast('Error', 'For India, Mobile 1 should be of 10 digits on Account');
            }
        }

        if (!this.mobile1error) {
            makeCalls({
                customerPh: account.Mobile_No__c,
                countryCode: account.Country_Code__c,
                recId: this.recordId
            })
                .then(result => {
                    this.showToast('Information', result, 'info', 'dismissable');
                })
                .catch(error => {
                    this.showToast('Error', 'Error occurred while calling: ' + error);
                });
        }
    }

    callmobile2() {
        this.mobile2error = false;
        const account = this.caseRec?.Account;

        if (!this.secondaryMobileNum) return;

        if (!account?.Dialing_Country_2__c) {
            this.mobile2error = true;
            this.showToast('Error', 'Dialing Country 2 is blank on Account');
        }

        const countryCode = this.countryCode2;

        if (!countryCode) {
            this.mobile2error = true;
            this.showToast('Error', 'Country Code 2 is blank on Account');
        }

        if (account?.Dialing_Country_2__c === 'India') {
            if (countryCode !== '+91') {
                this.mobile2error = true;
                this.showToast('Error', 'For India, Country Code 2 should be +91 on Account');
            }
            if (this.secondaryMobileNum?.length !== 10) {
                this.mobile2error = true;
                this.showToast('Error', 'For India, Mobile 2 should be of 10 digits on Account');
            }
        }

        if (!this.mobile2error) {
            makeCalls({
                customerPh: this.secondaryMobileNum,
                countryCode: countryCode,
                recId: this.recordId
            })
                .then(result => {
                    this.showToast('Information', result, 'info', 'dismissable');
                })
                .catch(error => {
                    this.showToast('Error', 'Error occurred while calling: ' + error);
                });
        }
    }
}