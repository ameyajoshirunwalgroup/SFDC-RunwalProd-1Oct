import { LightningElement, api, track, wire } from 'lwc';
// import { publish, MessageContext } from 'lightning/messageService';
// import getLastLoginTime from '@salesforce/apex/customerPortalPopup.getLastLoginTime';
// import getLastLoginTimebyAccountId from '@salesforce/apex/customerPortalPopup.getLastLoginTimebyAccountId';
import getQuestions from '@salesforce/apex/customerPortalPopup.getQuestions';
import fetchDataForObjectFields from '@salesforce/apex/customerPortalPopup.fetchDataForObjectFields';
import updateFieldData from '@salesforce/apex/customerPortalPopup.updateFieldData';
import getPicklistValues from '@salesforce/apex/customerPortalPopup.getPicklistValues';
// import fetchOpportunityList from '@salesforce/apex/customerPortalPopup.fetchOpportunityList';
import showPopupBasedonProfile from '@salesforce/apex/customerPortalPopup.showPopupBasedonProfile';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// import SEND_DATA_FROM_POPUP_TO_360 from '@salesforce/messageChannel/SendDatafromCustomer360toPopup__c';



// Mapping of field names to input types
// const fieldInputTypes = {
//     'Name': 'text',
//     'Email': 'email',
//     'Phone': 'tel',
//     'Date': 'date',
//     'Picklist' : 'picklist'
// };


export default class CustomerPortalPopup extends LightningElement {
    @track showModal = false;
    @api userId;
    @api type;
    @api shownewmodal;
    @api accountId;

    
    
    // @api ;
    // @track accountId;
    @track currentUser = [];
    @track questions = [];
    @track currentQuestionIndex = 0;
    @track showPopup = false;
    @track popup = false;
    @track currentQuestion = {};
    @track fieldValue = '';
    @track fieldUpdates = [];
    @track inputType = 'text';
    @track picklistValues = [] ;
    @track Object_Name = '';
    @track field_Name = '';
    @track field_Type = '';
    @track typeIsPicklist = false;
    @track typeIsText = false;
    @track typeIsDate = false;
    @track typeIsBoolean = false;
    @track typeIsEmail = false;
    @track OppList = [];

    // @api customerAccountId = '0011e000006x1Z3AAI';


    connectedCallback(){
        // console.log('connectedCallback type'+this.type);
        // console.log('connectedCallback userId'+this.userId);   
        console.log('connectedCallback account id- '+this.ogaccountId);  
        console.log('{showModal}'+this.shownewmodal);   
    }



    @wire(showPopupBasedonProfile, { accountId: '$accountId' })
    wiredShowPopup({ error, data }) {
        console.log('showPopupBasedonProfile accountId :: ', this.accountId);
        if (data !== undefined) {
            console.log('showPopupBasedonProfile data: ' + data);
            this.showModal = data;
            console.log('popup: ' + this.showModal);
        } else if (error) {
            console.error('Error retrieving showPopupBasedonProfile data:', error);
        }
    }


    @wire(getQuestions, {
        accountId: '$accountId'
    })
    wiredQuestions({ error, data }) {
        console.log('getQuestions accountId :: ', this.accountId);
        if (data) {
            console.log('wiredQuestions data--->>>>' + JSON.stringify(data));
            this.questions = JSON.parse(JSON.stringify(data));
            this.checkFieldValues();
        } else if (error) {
            console.error('Error fetching questions: ', error);
        }
    }


    checkFieldValues() {
        console.log('checkFieldValues accountId: ' + this.accountId);
        console.log('checkFieldValues this.questions: ' + JSON.stringify(this.questions));

        fetchDataForObjectFields({ accountId: this.accountId, metadata: this.questions })
            .then(result => {
                console.log('Result from Apex: ',JSON.stringify(result));

                console.log('Length of Questions : ' + this.questions.length);

                for (let question of this.questions) {
                    const fieldKey = question.Object_Name__c + '.' + question.Field_Name__c;
                    console.log('fieldKey: ' + fieldKey);
                    console.log('question: ' + JSON.stringify(question));
                    console.log('result[fieldKey]: ' + JSON.stringify(result[fieldKey]));
                    console.log('result[fieldKey].value: ' + result[fieldKey].value);
                    
                    if ((result[fieldKey].value == null || result[fieldKey].value == undefined) && result[fieldKey].type != null) {
                        console.log('Inside If');
                        this.currentQuestion = question;
                        console.log('currentQuestion: ' + JSON.stringify(this.currentQuestion));
                        this.object_Name = question.Object_Name__c;
                        this.field_Name = question.Field_Name__c;

                        // Example handling for different field types
                        if (result[fieldKey].type === 'PICKLIST') {
                            this.typeIsPicklist = true;
                            this.fetchPicklistOptions();
                        } else if (result[fieldKey].type === 'STRING') {
                            this.typeIsText = true;
                        } else if (result[fieldKey].type === 'DATE') {
                            this.typeIsDate = true;
                        } else if (result[fieldKey].type === 'PHONE') {
                            this.typeIsPhone = true;
                        } else if (result[fieldKey].type === 'BOOLEAN') {
                            this.typeIsBoolean = true;
                        } else if (result[fieldKey].type === 'EMAIL') {
                            this.typeIsEmail = true;
                        }

                        // Access field value and type
                        const fieldValue = result[fieldKey].value;
                        const fieldType = result[fieldKey].type;

                        this.field_Type = result[fieldKey].type;
                        console.log('this Field Type: ', this.field_Type);

                        console.log('Field Value: ', fieldValue);
                        console.log('Field Type: ', fieldType);

                        // this.showModal = true;
                        console.log('showmodal'+this.showModal);
                        return;
                    }
                }
                // console.log('Total questions : ' + this.questions.length); 
                
            })
            .catch(error => {
                console.error('Error fetching data: ', error);
            });
    }


    fetchPicklistOptions() {
        console.log('object_Name: ' + this.object_Name);
        console.log('field_Name: ' + this.field_Name);
        
        getPicklistValues({ objectName: this.object_Name, fieldName: this.field_Name })
            .then(result => {
                console.log('Result from Apex: ', result);
                if (result && result.length > 0) {
                    this.picklistValues = result;
                    console.log('Picklist Values: ', this.picklistValues);
                } else {
                    console.log('No picklist values returned.');
                }
            })
            .catch(error => {
                console.error('Error fetching data: ', error);
            });
    }




    handlecheckBoxFieldChange(event) {
        const isChecked = event.target.checked;        
        console.log('Checkbox value:', isChecked);
        if(isChecked == true){
            this.fieldValue = 'true';
        } else{
            this.fieldValue = null;
        }
        
        console.log(' this.fieldValue'+ this.fieldValue);
    }



    handleFieldChange(event) {
        console.log('value'+event.target.value);
        this.fieldValue = event.target.value;
        console.log('value'+this.fieldValue);
    }

    handleSave() {
        console.log('field value'+this.fieldValue);
        const { Object_Name__c, Field_Name__c } = this.currentQuestion;

        if (!this.fieldValue || this.fieldValue.trim() === '') {
            this.showToast('Error', 'Please fill the value', 'error');
            return; 
        } 

        if (this.typeIsEmail && !this.validateEmail(this.fieldValue)) {
            this.showToast('Error', 'Invalid email format', 'error');
            return;
        }

        if (this.typeIsPhone && !this.validatePhone(this.fieldValue)) {
            this.showToast('Error', 'Invalid phone number', 'error');
            return;
        }

        if (this.typeIsDate && !this.validateDate(this.fieldValue)) {
            this.showToast('Error', 'Invalid date', 'error');
            return;
        }
               
        updateFieldData({ accountId: this.accountId, objectName: Object_Name__c, fieldName: Field_Name__c, value: this.fieldValue })
        .then(() => {
            this.showModal = false;
            // this.checkFieldValues();
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Field updated successfully!',
                    variant: 'success'
                })
            );
        })
        .catch(error => {
            console.error('Error updating field: ', error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Error updating field',
                    variant: 'error'
                })
            );
        });
        // this.dispatchEvent(new CustomEvent('close'));
    }
        

    validateEmail(email) {
        const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return re.test(String(email).toLowerCase());
    }


    validatePhone(phone) {
        const re = /^\d{10}$/; 
        return re.test(String(phone));
    }

    validateDate(date) {
        return !isNaN(Date.parse(date));
    }  

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            })
        );
    }


    // handleSave() {
    //     // const { Object_Name__c, Field_Name__c } = this.currentQuestion;
    //     console.log('field value'+this.fieldValue);
    //     console.log('this.currentQuestion'+this.currentQuestion);
    //     this.fieldUpdates.push({
    //         objectName: this.currentQuestion.Object_Name__c,
    //         fieldName: this.currentQuestion.Field_Name__c,
    //         value: this.fieldValue
    //     });

    //     console.log('this.fieldUpdates'+this.fieldUpdates);
    //     console.log('this.fieldUpdates'+JSON.stringify(this.fieldUpdates));  
    //     // this.fieldUpdates = JSON.parse(this.fieldUpdates);

    //     updateFieldData({ accountId: this.accountId, fieldUpdates: this.fieldUpdates })
    //         .then(() => {
    //             this.showPopup = false;
    //             this.fieldUpdates = [];
    //             this.checkFieldValues();
    //             this.dispatchEvent(
    //                 new ShowToastEvent({
    //                     title: 'Success',
    //                     message: 'Field updated successfully!',
    //                     variant: 'success'
    //                 })
    //             );
    //         })
    //         .catch(error => {
    //             console.error('Error updating field: ', error);
    //             this.dispatchEvent(
    //                 new ShowToastEvent({
    //                     title: 'Error',
    //                     message: 'Error updating field',
    //                     variant: 'error'
    //                 })
    //             );
    //         });
    // }





    // @wire(getLastLoginTime, {
    //     userId: '$userId'
    // })
    // wiredLastLogin({ error, data }) {
    //     console.log('Inside getLastLoginTime');
    //     console.log('userId :: ', this.userId);
    //     if (data) {
    //         console.log('data :: ', JSON.stringify(data));            
    //         const lastLoginDate = new Date(data);
    //         const today = new Date();
    //         today.setHours(0, 0, 0, 0);

    //         console.log('lastLoginDate :: ', lastLoginDate);
    //          console.log('today :: ', today);
    //         if (lastLoginDate < today) {
    //             this.showPopup = true;
    //         } else {
    //             this.showPopup = false;
    //         }
    //     } else if (data === null) {
    //         this.showPopup = true;
    //     }
    //     else if (error) {
    //         console.error('Error fetching questions: ', error);
    //     }
    // }


    closePopup() {
        this.showModal = false;
        this.dispatchEvent(new CustomEvent('close'));
    }

}