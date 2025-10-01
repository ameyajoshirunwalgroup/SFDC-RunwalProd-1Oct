import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import accMobile1 from '@salesforce/schema/Opportunity.Account.Mobile_No__c';
//import accMobile2 from '@salesforce/schema/Opportunity.Account.RW_Secondary_Mobile_No__c';
import accCountry from '@salesforce/schema/Opportunity.Account.RW_Country__c';
import accCountryCode1 from '@salesforce/schema/Opportunity.Account.Country_Code__c';
import accCountry2 from '@salesforce/schema/Opportunity.Account.Dialing_Country_2__c';
import accCountryCode2 from '@salesforce/schema/Opportunity.Account.Country_Code_2__c';
import makeCalls from '@salesforce/apex/CallCustomerOfflineController.callAPI';
import oppData from '@salesforce/apex/CallCustomerOfflineController.oppData';
import accMobile2New from '@salesforce/schema/Opportunity.Account.Alternate_Mobile_No__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CallCustomerOmOpptyOffline extends LightningElement {
    @api recordId;
    @track mobile1error = false;
    @track mobile2error = false;

    optyData;
    optyDataError;
    secondaryMobileNum;

    @wire(oppData,  {recId: '$recordId'})
    opttyData({error, data}){
        if(data){
            console.log('data: ', data);
            this.optyData = data;
            if(this.optyData.Account.RW_Secondary_Mobile_No__pc != null){
                this.secondaryMobileNum = this.optyData.Account.RW_Secondary_Mobile_No__pc;
            }else{
                this.secondaryMobileNum = this.optyData.Account.Alternate_Mobile_No__c;
            }
        }else if(error){
            console.log('error: ', error);
            this.optyDataError = error;
        }
    }

    /* Display Mobile 1 on UI */
    get mobile1() {
       // alert('recordId:: ' + this.recordId);
     //   alert('123 closedate:: ' + getFieldValue(this.optyData.data, accMobile1));
        console.log('mobile'+this.optyData);
        //console.log('mobile1'+accMobile1);
        if (this.optyData.Account.Mobile_No__c != null)
            return this.optyData.Account.Country_Code__c +' ' + this.optyData.Account.Mobile_No__c.replace(this.optyData.Account.Mobile_No__c.substring(0, 5), 'XXXXX');
        else
            return null;
    }

    /* Display Mobile 2 on UI */
    get mobile2() {
        if (this.secondaryMobileNum != null)
            return this.optyData.Account.Country_Code_2__c +' ' + this.secondaryMobileNum.replace(this.secondaryMobileNum.substring(0, 5), 'XXXXX');
        else
            return null;
    }

    /* Make call on Mobile 1 */
    callmobile1() {
        //  alert('mobile 1 method called');
        this.mobile1error = false;
        //  alert('dialing country 1: ' + this.leadData.data.fields.Dialing_Country_1__c.value);
        /* Validations */
        if (this.optyData.Account.RW_Country__c == null) {
            this.mobile1error = true;
            const event = new ShowToastEvent({
                title: 'Error',
                variant: 'Error',
                mode: 'sticky',
                message: 'Dialing Country 1 is blank on Account',
            });
            this.dispatchEvent(event);
        }
        if (this.optyData.Account.Country_Code__c == null) {
            this.mobile1error = true;
            const event = new ShowToastEvent({
                title: 'Error',
                variant: 'Error',
                mode: 'sticky',
                message: 'Country Code 1 is blank on Account',
            });
            this.dispatchEvent(event);
        }
        if (this.optyData.Account.Mobile_No__c == null) {
            this.mobile1error = true;
            const event = new ShowToastEvent({
                title: 'Error',
                variant: 'Error',
                mode: 'sticky',
                message: 'Mobile 1 is blank on Account',
            });
            this.dispatchEvent(event);
        }

        if (this.optyData.Account.RW_Country__c != null && this.optyData.Account.RW_Country__c == 'India') {
            if (this.optyData.Account.Country_Code__c != null && this.optyData.Account.Country_Code__c != '+91') {
                this.mobile1error = true;
                const event = new ShowToastEvent({
                    title: 'Error',
                    variant: 'Error',
                    mode: 'sticky',
                    message: 'For India, Country Code 1 should be +91 on Account',
                });
                this.dispatchEvent(event);
            }
            if (this.optyData.Account.Mobile_No__c != null && this.optyData.Account.Mobile_No__c.length != 10 && this.optyData.Account.RW_Country__c == 'India') {
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
        //  alert('Before calling API: ' + this.mobile1error);
        if (this.mobile1error == false) {
            makeCalls({
                customerPh: this.optyData.Account.Mobile_No__c,
                countryCode: this.optyData.Account.Country_Code__c,
                RecordId: this.recordId
            })
                .then(result => {
                    //  this.status = result;
                    const event = new ShowToastEvent({
                        title: 'Information',
                        variant: 'info',
                        mode: 'dismissable', // Remains visible until the user clicks the close button or 3 seconds has elapsed, whichever comes first.
                        message: result,
                    });
                    this.dispatchEvent(event);
                })
                .catch(error => {
                    //    this.errorMsg = error;
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
            if (this.optyData.Account.Dialing_Country_2__c == null) {
                this.mobile2error = true;
                const event = new ShowToastEvent({
                    title: 'Error',
                    variant: 'Error',
                    mode: 'sticky',
                    message: 'Dialing Country 2 is blank on Account',
                });
                this.dispatchEvent(event);
            }
            if (this.optyData.Account.Country_Code_2__c == null) {
                this.mobile2error = true;
                const event = new ShowToastEvent({
                    title: 'Error',
                    variant: 'Error',
                    mode: 'sticky',
                    message: 'Country Code 2 is blank on Account',
                });
                this.dispatchEvent(event);
            }

            if (this.optyData.Account.Dialing_Country_2__c != null && this.optyData.Account.Dialing_Country_2__c == 'India') {
                if (this.optyData.Account.Country_Code_2__c != null && this.optyData.Account.Country_Code_2__c != '+91') {
                    this.mobile2error = true;
                    const event = new ShowToastEvent({
                        title: 'Error',
                        variant: 'Error',
                        mode: 'sticky',
                        message: 'For India, Country Code 2 should be +91 on Account',
                    });
                    this.dispatchEvent(event);
                }
                if (this.secondaryMobileNum != null && this.secondaryMobileNum.length != 10 && this.optyData.Account.Dialing_Country_2__c == 'India') {
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
        //   alert('calling API for mobile 2');
        if (this.mobile2error == false) {
            makeCalls({
                customerPh: this.secondaryMobileNum,
                countryCode: this.optyData.Account.Country_Code_2__c
            })
                .then(result => {
                    //  this.status = result;
                    const event = new ShowToastEvent({
                        title: 'Information',
                        variant: 'info',
                        mode: 'dismissable', // Remains visible until the user clicks the close button or 3 seconds has elapsed, whichever comes first.
                        message: result,
                    });
                    this.dispatchEvent(event);
                })
                .catch(error => {
                    //    this.errorMsg = error;
                    //  alert('Inside mobile 2 error');
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