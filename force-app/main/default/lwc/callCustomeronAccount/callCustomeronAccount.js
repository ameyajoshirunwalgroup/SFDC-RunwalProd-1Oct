import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import makeCalls from '@salesforce/apex/CallCustomerController.callAPI';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


const FIELDS = [
    'Account.Mobile_No__c',
    'Account.RW_Secondary_Mobile_No__pc',
    'Account.RW_Country__c',
    'Account.Country_Code__c',
    'Account.Country_Code_2__c',
    'Account.Dialing_Country_2__c',
    'Account.Alternate_Mobile_No__c'
];

export default class CallCustomeronAccount extends LightningElement {
    @api recordId;
    @track mobile1error = false;
    @track mobile2error = false;
    @track AccData;
    
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    AccData;
    
    /* Display Mobile 1 on UI */
    get mobile1() { 
        //alert('mobile NUmber');
        if (this.AccData.data.fields.Mobile_No__c.value != null)
            return this.AccData.data.fields.Country_Code__c.value + ' ' + this.AccData.data.fields.Mobile_No__c.value.replace(this.AccData.data.fields.Mobile_No__c.value.substring(0, 5), 'XXXXX');
        else
        alert('mobile1:'+this.AccData.data.fields.Mobile_No__c.value);
            return null;
    }

    /* Display Mobile 2 on UI */
    get mobile2() {
        // var actualmobile2 = this.AccData.data.fields.Phone.value;
        if (this.AccData.data.fields.RW_Secondary_Mobile_No__pc.value != null){
            return this.AccData.data.fields.Country_Code_2__c.value + ' ' + this.AccData.data.fields.RW_Secondary_Mobile_No__pc.value.replace(this.AccData.data.fields.RW_Secondary_Mobile_No__pc.value.substring(0, 5), 'XXXXX');
        }else if(this.AccData.data.fields.Alternate_Mobile_No__c.value != null){
            return this.AccData.data.fields.Country_Code_2__c.value + ' ' + this.AccData.data.fields.Alternate_Mobile_No__c.value.replace(this.AccData.data.fields.Alternate_Mobile_No__c.value.substring(0, 5), 'XXXXX');
        }else
            return null;
    }

    /* Make call on Mobile 1 */
    callmobile1() {
        //  alert('mobile 1 method called');
        this.mobile1error = false;
        //  alert('dialing country 1: ' + this.AccData.data.fields.Dialing_Country_1__c.value);
        /* Validations */
        /*if (this.AccData.data.fields.Is_DND__c.value == true) {
            this.mobile1error = true;
            const event = new ShowToastEvent({
                title: 'Error',
                variant: 'Error',
                mode: 'sticky',
                message: 'Customer opted for DND',
            });
            this.dispatchEvent(event);
        }*/
        if (this.AccData.data.fields.RW_Country__c.value == null) {
            this.mobile1error = true;
            const event = new ShowToastEvent({
                title: 'Error',
                variant: 'Error',
                mode: 'sticky',
                message: 'Dialing Country 1 is blank',
            });
            this.dispatchEvent(event);
        }
        if (this.AccData.data.fields.Country_Code__c.value == null) {
            this.mobile1error = true;
            const event = new ShowToastEvent({
                title: 'Error',
                variant: 'Error',
                mode: 'sticky',
                message: 'Country Code 1 is blank',
            });
            this.dispatchEvent(event);
        }
        if (this.AccData.data.fields.Mobile_No__c.value == null) {
            this.mobile1error = true;
            const event = new ShowToastEvent({
                title: 'Error',
                variant: 'Error',
                mode: 'sticky',
                message: 'Mobile 1 is blank',
            });
            this.dispatchEvent(event);
        }

        if (this.AccData.data.fields.RW_Country__c.value != null && this.AccData.data.fields.RW_Country__c.value == 'India') {
            if (this.AccData.data.fields.Country_Code__c.value != null && this.AccData.data.fields.Country_Code__c.value != '+91') {
                this.mobile1error = true;
                const event = new ShowToastEvent({
                    title: 'Error',
                    variant: 'Error',
                    mode: 'sticky',
                    message: 'For India, Country Code 1 should be +91',
                });
                this.dispatchEvent(event);
            }
            if (this.AccData.data.fields.Mobile_No__c.value != null && this.AccData.data.fields.Mobile_No__c.value.length != 10 && this.AccData.data.fields.RW_Country__c.value == 'India') {
                this.mobile1error = true;
                const event = new ShowToastEvent({
                    title: 'Error',
                    variant: 'Error',
                    mode: 'sticky',
                    message: 'For India, Mobile 1 should be of 10 digit',
                });
                this.dispatchEvent(event);
            }
        }
       // alert('Before calling API: ' + this.mobile1error);
        if (this.mobile1error == false) {
          alert('Calling API');
						console.log('recId:', this.recordId);
            makeCalls({
                customerPh: this.AccData.data.fields.Mobile_No__c.value,
                countryCode: this.AccData.data.fields.Country_Code__c.value,
				recId: this.recordId
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
      //  alert('method 2 called');
        if (this.AccData.data.fields.RW_Secondary_Mobile_No__pc.value != null) {
            if (this.AccData.data.fields.Dialing_Country_2__c.value == null) {
                this.mobile2error = true;
                const event = new ShowToastEvent({
                    title: 'Error',
                    variant: 'Error',
                    mode: 'sticky',
                    message: 'Dialing Country 2 is blank',
                });
                this.dispatchEvent(event);
            }
            if (this.AccData.data.fields.Country_Code_2__c.value == null) {
                this.mobile2error = true;
                const event = new ShowToastEvent({
                    title: 'Error',
                    variant: 'Error',
                    mode: 'sticky',
                    message: 'Country Code 2 is blank',
                });
                this.dispatchEvent(event);
            }

            if (this.AccData.data.fields.Dialing_Country_2__c.value != null && this.AccData.data.fields.Dialing_Country_2__c.value == 'India') {
                if (this.AccData.data.fields.Country_Code_2__c.value != null && this.AccData.data.fields.Country_Code_2__c.value != '+91') {
                    this.mobile2error = true;
                    const event = new ShowToastEvent({
                        title: 'Error',
                        variant: 'Error',
                        mode: 'sticky',
                        message: 'For India, Country Code 2 should be +91',
                    });
                    this.dispatchEvent(event);
                }
                if (this.AccData.data.fields.RW_Secondary_Mobile_No__pc.value != null && this.AccData.data.fields.RW_Secondary_Mobile_No__pc.value.length != 10 && this.AccData.data.fields.Dialing_Country_2__c.value == 'India') {
                    this.mobile2error = true;
                    const event = new ShowToastEvent({
                        title: 'Error',
                        variant: 'Error',
                        mode: 'sticky',
                        message: 'For India, Mobile 2 should be of 10 digit',
                    });
                    this.dispatchEvent(event);
                }
            }
        }
     //   alert('calling API for mobile 2');
        if (this.mobile2error == false) {
          //  alert('calling API');
            makeCalls({
                customerPh: this.AccData.data.fields.RW_Secondary_Mobile_No__pc.value,
                countryCode: this.AccData.data.fields.Country_Code_2__c.value,
				recId: this.recordId
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
                        message: 'Error occurred while calling: ' + error,
                    });
                    this.dispatchEvent(event);
                })
        }
    }
}