import { LightningElement, api, track, wire } from 'lwc';
import makeCalls from '@salesforce/apex/CallCustomerOfflineController.callAPI';
import accData from '@salesforce/apex/CallCustomerOfflineController.accData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CallCustomerAccountOffline extends LightningElement {

    @api recordId;
    @track mobile1error = false;
    @track mobile2error = false;

    accountData;
    accountDataError;
    secondaryMobileNum;

    @wire(accData,  {recId: '$recordId'})
    accountData({error, data}){
        if(data){
            console.log('data: ', data);
            this.accountData = data;
            if(this.accountData.RW_Secondary_Mobile_No__pc != null){
                this.secondaryMobileNum = this.accountData.RW_Secondary_Mobile_No__pc;
            }else{
                this.secondaryMobileNum = this.accountData.Alternate_Mobile_No__c;
            }
        }else if(error){
            console.log('error: ', error);
            this.accountDataError = error;
        }
    }

    /* Display Mobile 1 on UI */
    get mobile1() {
         console.log('mobile'+this.accountData);
         if (this.accountData.Mobile_No__c != null)
             return this.accountData.Country_Code__c +' ' + this.accountData.Mobile_No__c.replace(this.accountData.Mobile_No__c.substring(0, 5), 'XXXXX');
         else
             return null;
     }
 
     /* Display Mobile 2 on UI */
     get mobile2() {
         if (this.secondaryMobileNum != null)
             return this.accountData.Country_Code_2__c +' ' + this.secondaryMobileNum.replace(this.secondaryMobileNum.substring(0, 5), 'XXXXX');
         else
             return null;
     }

     /* Make call on Mobile 1 */
     callmobile1() {
        this.mobile1error = false;
        if (this.accountData.RW_Country__c == null) {
            this.mobile1error = true;
            const event = new ShowToastEvent({
                title: 'Error',
                variant: 'Error',
                mode: 'sticky',
                message: 'Dialing Country 1 is blank on Account',
            });
            this.dispatchEvent(event);
        }
        if (this.accountData.Country_Code__c == null) {
            this.mobile1error = true;
            const event = new ShowToastEvent({
                title: 'Error',
                variant: 'Error',
                mode: 'sticky',
                message: 'Country Code 1 is blank on Account',
            });
            this.dispatchEvent(event);
        }
        if (this.accountData.Mobile_No__c == null) {
            this.mobile1error = true;
            const event = new ShowToastEvent({
                title: 'Error',
                variant: 'Error',
                mode: 'sticky',
                message: 'Mobile 1 is blank on Account',
            });
            this.dispatchEvent(event);
        }

        if (this.accountData.RW_Country__c != null && this.accountData.RW_Country__c == 'India') {
            if (this.accountData.Country_Code__c != null && this.accountData.Country_Code__c != '+91') {
                this.mobile1error = true;
                const event = new ShowToastEvent({
                    title: 'Error',
                    variant: 'Error',
                    mode: 'sticky',
                    message: 'For India, Country Code 1 should be +91 on Account',
                });
                this.dispatchEvent(event);
            }
            if (this.accountData.Mobile_No__c != null && this.accountData.Mobile_No__c.length != 10 && this.accountData.RW_Country__c == 'India') {
                this.mobile1error = true;
                const event = new ShowToastEvent({
                    title: 'Error',
                    variant: 'Error',
                    mode: 'sticky',
                    message: 'For India, Mobile 1 should be of 10 digit on Account',
                });
                this.dispatchEvent(event);
            }
        }
        if (this.mobile1error == false) {
            makeCalls({
                customerPh: this.accountData.Mobile_No__c,
                countryCode: this.accountData.Country_Code__c,
                RecordId: this.recordId
            })
                .then(result => {
                    const event = new ShowToastEvent({
                        title: 'Information',
                        variant: 'info',
                        mode: 'dismissable', // Remains visible until the user clicks the close button or 3 seconds has elapsed, whichever comes first.
                        message: result,
                    });
                    this.dispatchEvent(event);
                })
                .catch(error => {
                    const event = new ShowToastEvent({
                        title: 'Error',
                        variant: 'error',
                        mode: 'dismissable', // Remains visible until the user clicks the close button or 3 seconds has elapsed, whichever comes first.
                        message: 'Error occurred while calling:: ' + error,
                    });
                    this.dispatchEvent(event);
                })
        }
    }

    /* Make call on Mobile 2 */
    callmobile2() {
        this.mobile2error = false;
        if (this.secondaryMobileNum != null) {
            if (this.accountData.Dialing_Country_2__c == null) {
                this.mobile2error = true;
                const event = new ShowToastEvent({
                    title: 'Error',
                    variant: 'Error',
                    mode: 'sticky',
                    message: 'Dialing Country 2 is blank on Account',
                });
                this.dispatchEvent(event);
            }
            if (this.accountData.Country_Code_2__c == null) {
                this.mobile2error = true;
                const event = new ShowToastEvent({
                    title: 'Error',
                    variant: 'Error',
                    mode: 'sticky',
                    message: 'Country Code 2 is blank on Account',
                });
                this.dispatchEvent(event);
            }

            if (this.accountData.Dialing_Country_2__c != null && this.accountData.Dialing_Country_2__c == 'India') {
                if (this.accountData.Country_Code_2__c != null && this.accountData.Country_Code_2__c != '+91') {
                    this.mobile2error = true;
                    const event = new ShowToastEvent({
                        title: 'Error',
                        variant: 'Error',
                        mode: 'sticky',
                        message: 'For India, Country Code 2 should be +91 on Account',
                    });
                    this.dispatchEvent(event);
                }
                if (this.secondaryMobileNum != null && this.secondaryMobileNum.length != 10 && this.accountData.Dialing_Country_2__c == 'India') {
                    this.mobile2error = true;
                    const event = new ShowToastEvent({
                        title: 'Error',
                        variant: 'Error',
                        mode: 'sticky',
                        message: 'For India, Mobile 2 should be of 10 digit on Account',
                    });
                    this.dispatchEvent(event);
                }
            }
        }
        if (this.mobile2error == false) {
            makeCalls({
                customerPh: this.secondaryMobileNum,
                countryCode: this.accountData.Country_Code_2__c
            })
                .then(result => {
                    const event = new ShowToastEvent({
                        title: 'Information',
                        variant: 'info',
                        mode: 'dismissable', // Remains visible until the user clicks the close button or 3 seconds has elapsed, whichever comes first.
                        message: result,
                    });
                    this.dispatchEvent(event);
                })
                .catch(error => {
                    const event = new ShowToastEvent({
                        title: 'Error',
                        variant: 'error',
                        mode: 'dismissable', // Remains visible until the user clicks the close button or 3 seconds has elapsed, whichever comes first.
                        message: 'Error occurred while calling:: ' + error,
                    });
                    this.dispatchEvent(event);
                })
        }
    }
}