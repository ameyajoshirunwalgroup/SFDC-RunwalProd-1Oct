import { LightningElement, wire, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createTempCP from '@salesforce/apex/CPRegisterationController.createTempCP';
import isDuplicateCPExist from '@salesforce/apex/CPRegisterationController.isDuplicateCPExist';
// import isDuplicateTempCPExist from '@salesforce/apex/CPBookingController.isDuplicateTempCPExist';
import { NavigationMixin } from 'lightning/navigation';

export default class CpCreationForm extends NavigationMixin(LightningElement) {

    @track cp = {};
    @track isOpen = false;
    @track cpFields = {
        firstName: null,
        middleName: null,
        lastName: null,
        email: null,
        mobileno: null,
        panno: null,
        company: null
    };
    @track validatefields = false;
    @api isLoaded = false;
    showLoadingSpinner = false;
    disablesubmitbtn = false;


    connectedCallback() {
        console.log('In Start')
        console.log('Modal open parameter:', this.isOpen);
        this.isOpen = true;
    }

    handleSubmit() {
        this.saveRecord(false);
    }

    handleSaveAndNew() {
        this.saveRecord(true);
    }

    handleClose() {
        window.history.back();
    }

    saveRecord(isSaveAndNew) {
        this.validate();
        if (this.validatefields) {
            this.showLoadingSpinner = true;
            // if (this.disablesubmitbtn) return;
            // this.disablesubmitbtn = true;
            this.cpFields = JSON.parse(JSON.stringify(this.cpFields))
            this.cp.NAME_FIRST__c = this.cpFields.firstName;
            console.log('this.cpFields.middleName' + this.cpFields.middleName)
            this.cp.NAME_MIDDLE__c = this.cpFields.middleName;
            this.cp.NAME_LAST__c = this.cpFields.lastName;
            if (this.cp.NAME_MIDDLE__c != null) {
                this.cp.Name = this.cpFields.firstName + ' ' + this.cpFields.middleName + ' ' + this.cpFields.lastName;
            } else {
                this.cp.Name = this.cpFields.firstName + ' ' + this.cpFields.lastName;
            }
            // this.cp.TITLE__c = this.salutation;
            this.cp.RW_Email__c = this.cpFields.email;
            this.cp.Broker_Pan_No__c = this.cpFields.panno;
            this.cp.Company_Name__c = this.cpFields.company;
            this.cp.RW_Mobile_No__c = this.cpFields.mobileno;
            console.log('this.cp', JSON.stringify(this.cp))
            this.cp = JSON.parse(JSON.stringify(this.cp));

            isDuplicateCPExist({ bk: this.cp })
                .then((result) => {
                    if (result != null && result != undefined && result != '') {
                        this.showLoadingSpinner = false;
                        const duplicateexist = new ShowToastEvent({
                            title: 'Error!!',
                            message: result,
                            variant: 'error',
                        })
                        this.dispatchEvent(duplicateexist)

                    } else {
                        createTempCP({ bk: this.cp })
                            .then(result => {
                                this.showToast('Success', 'Temp CP created ', 'success')
                                if (isSaveAndNew) {
                                    this.cpFields = {};
                                } else {
                                    console.log('Record Id returned from APEX -> ' + result);
                                    this[NavigationMixin.Navigate]({
                                        type: 'standard__recordPage',
                                        attributes: {
                                            recordId: result,
                                            objectApiName: 'Broker__c',
                                            actionName: 'view'
                                        }
                                    });
                                    this.isOpen = false;
                                    this.showLoadingSpinner = false;
                                }
                                // this.cp = { this.cpFields.firstName: '', middleName : '', lastName: '', email: '', mobileno: '', panno: '' };
                                // console.log('CP Id -> ', result)
                                this.disablesubmitbtn = false;

                            })
                            .catch(error => {
                                this.showToast('Error creating record', error.body.message, 'error')
                                this.disablesubmitbtn = false;
                                this.showLoadingSpinner = false;
                            });
                    }
                })
                .catch((error) => {
                    this.error = error;

                    if (error && error.body && error.body.message) {

                        console.log('error msg-', error.body.message);
                    }


                });


        }
    }




    handleChange(event) {
        console.log('event.target', event.target)
        const { name, value } = event.target;
        console.log('event.target.name', event.target.name)
        console.log('event.target.value', event.target.value)
        console.log('event.detail.value', event.detail.value)
        this.cpFields[name] = value;
        console.log('cpFields - ', JSON.stringify(this.cpFields))
    }

    validate() {
        const allInputs = this.template.querySelectorAll('lightning-input');
        this.validatefields = true;

        allInputs.forEach(input => {
            if (!input.checkValidity()) {
                input.reportValidity();
                this.validatefields = false;
            }
        });

        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        const mobileRegex = /^[0-9]{10}$/;
        const panRegex = /^[A-Z]{5}[0-9]{4}[A-Z]$/;

        if (!mobileRegex.test(this.cpFields.mobileno) && this.cpFields.mobileno != null) {
            this.showToast('Validation Error', 'Mobile number must be exactly 10 digits.', 'error');
            this.validatefields = false;
        }

        if (!emailRegex.test(this.cpFields.email) && this.cpFields.email != null) {
            this.showToast('Validation Error', 'Please enter a valid email address.', 'error');
            this.validatefields = false;
        }

        if (!panRegex.test(this.cpFields.panno) && this.cpFields.panno != null) {
            this.showToast('Validation Error', 'Please enter a valid PAN in format: ABCFA1234D', 'error');
            this.validatefields = false;
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }

}