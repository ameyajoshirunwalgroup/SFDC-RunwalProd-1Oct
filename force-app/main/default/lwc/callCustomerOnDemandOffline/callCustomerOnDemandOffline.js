import { LightningElement, api, track, wire  } from 'lwc';
import makeCalls from '@salesforce/apex/CallCustomerOfflineController.callAPI';
import demandData from '@salesforce/apex/CallCustomerOfflineController.demandData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CallCustomerOnDemandOffline extends LightningElement {
  @api recordId;
    @track mobile1error = false;
    @track mobile2error = false;
    @track demandRec;
    @track countryCode2;

    secondaryMobileNum;

    @wire(demandData, { recId: '$recordId' })
    wiredDemandData({ error, data }) {
        if (data) {
            console.log('data: ', data);
            this.demandRec = data;

            const account = data?.Booking__r?.Customer__r?.Account;
            if (account?.RW_Secondary_Mobile_No__pc != null) {
                this.secondaryMobileNum = account.RW_Secondary_Mobile_No__pc;
            } else {
                this.secondaryMobileNum = account?.Alternate_Mobile_No__c;
            }
        } else if (error) {
            console.error('Error fetching case data:', error);
        }
    }

    /* Display Mobile 1 on UI */
    get mobile1() {
        const account = this.demandRec?.Booking__r?.Customer__r?.Account;
        if (account?.Mobile_No__c != null) {
            return `${account.Country_Code__c} ${account.Mobile_No__c.replace(account.Mobile_No__c.substring(0, 5), 'XXXXX')}`;
        }
        return null;
    }

    /* Display Mobile 2 on UI */
    get mobile2() {
        const account = this.demandRec?.Booking__r?.Customer__r?.Account;
        const code = account?.Country_Code_2__c || account?.Country_Code__c;
        if (this.secondaryMobileNum && code) {
            return `${code} ${this.secondaryMobileNum.replace(this.secondaryMobileNum.substring(0, 5), 'XXXXX')}`;
        }
        return null;
    }

    /* Make call on Mobile 1 */
    callmobile1() {
        this.mobile1error = false;

        const account = this.demandRec?.Booking__r?.Customer__r?.Account;

        if (!account?.RW_Country__c) {
            this.mobile1error = true;
            this.showToast('Error', 'Dialing Country 1 is blank on Account', 'error');
        }

        if (!account?.Country_Code__c) {
            this.mobile1error = true;
            this.showToast('Error', 'Country Code 1 is blank on Account', 'error');
        }

        if (!account?.Mobile_No__c) {
            this.mobile1error = true;
            this.showToast('Error', 'Mobile 1 is blank on Account', 'error');
        }

        if (account?.RW_Country__c === 'India') {
            if (account?.Country_Code__c && account.Country_Code__c !== '+91') {
                this.mobile1error = true;
                this.showToast('Error', 'For India, Country Code 1 should be +91 on Account', 'error');
            }

            if (account?.Mobile_No__c && account.Mobile_No__c.length !== 10) {
                this.mobile1error = true;
                this.showToast('Error', 'For India, Mobile 1 should be of 10 digit on Account', 'error');
            }
        }

        if (!this.mobile1error) {
            makeCalls({
                customerPh: account.Mobile_No__c,
                countryCode: account.Country_Code__c,
                RecordId: this.recordId
            })
                .then(result => {
                    this.showToast('Information', result, 'info');
                })
                .catch(error => {
                    this.showToast('Error', `Error occurred while calling:: ${error}`, 'error');
                });
        }
    }

    /* Make call on Mobile 2 */
    callmobile2() {
        this.mobile2error = false;

        const account = this.demandRec?.Booking__r?.Customer__r?.Account;

        if (this.secondaryMobileNum != null) {
            if (!account?.Dialing_Country_2__c) {
                this.mobile2error = true;
                this.showToast('Error', 'Dialing Country 2 is blank on Account', 'error');
            }

            if (!account?.Country_Code_2__c) {
                this.mobile2error = true;
                this.showToast('Error', 'Country Code 2 is blank on Account', 'error');
            }

            if (account?.Dialing_Country_2__c === 'India') {
                if (account?.Country_Code_2__c && account.Country_Code_2__c !== '+91') {
                    this.mobile2error = true;
                    this.showToast('Error', 'For India, Country Code 2 should be +91 on Account', 'error');
                }

                if (this.secondaryMobileNum.length !== 10) {
                    this.mobile2error = true;
                    this.showToast('Error', 'For India, Mobile 2 should be of 10 digit on Account', 'error');
                }
            }
        }

        if (!this.mobile2error) {
            makeCalls({
                customerPh: this.secondaryMobileNum,
                countryCode: account?.Country_Code_2__c
            })
                .then(result => {
                    this.showToast('Information', result, 'info');
                })
                .catch(error => {
                    this.showToast('Error', `Error occurred while calling:: ${error}`, 'error');
                });
        }
    }

    /* Utility Method for Toasts */
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'sticky'
        });
        this.dispatchEvent(event);
    }

}