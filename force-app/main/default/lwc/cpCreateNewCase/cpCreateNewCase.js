import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import NAME_FIELD from '@salesforce/schema/Case.CaseNumber';
import OPPORTUNITY_FIELD from '@salesforce/schema/Case.Opportunity__c';
import CATEGORY_FIELD from '@salesforce/schema/Case.Case_Category__c';
import SUBCATEGORY_FIELD from '@salesforce/schema/Case.Case_Sub_Category__c';
import SUBJECT_FIELD from '@salesforce/schema/Case.Subject';
import DESCRIPTION_FIELD from '@salesforce/schema/Case.Description';
export default class CpCreateNewCase extends NavigationMixin(LightningElement) {
    @api objectApiName = 'Case';
    fields = [OPPORTUNITY_FIELD, CATEGORY_FIELD, SUBCATEGORY_FIELD,SUBJECT_FIELD,DESCRIPTION_FIELD];
    


    handleSuccess(event){
        console.log('RecordID::'+event.detail.id);
        
        console.log('2');
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.detail.id,
                objectApiName: 'Case',
                actionName: 'view'
            }
        });
        console.log('3');
    }



    handleOnchange(event) {
        console.log('Case detail: ', event.detail.fields);
    }


    handleSubmit(event) {

        event.preventDefault(); // Stop the form from submitting
        const fields = event.detail.fields;


        // Custom validation
        if (!fields.Case_Category__c || fields.Case_Category__c.trim() === '') {
            this.showToast('Validation Error', 'Category is required.', 'error');
            return;
        } else if (fields.Case_Category__c === 'Payment Related' || fields.Case_Category__c === 'Invoice Related') {
            if (!fields.Opportunity__c || fields.Opportunity__c.trim() === '') {
                this.showToast('Validation Error', 'Opportunity is required.', 'error');
                return;
            }
        }

        if (!fields.Case_Sub_Category__c || fields.Case_Sub_Category__c.trim() === '') {
            this.showToast('Validation Error', 'Sub Category is required.', 'error');
            return;
        }

        if (!fields.Subject || fields.Subject.trim() === '') {
            this.showToast('Validation Error', 'Subject is required.', 'error');
            return;
        }

        if (!fields.Description || fields.Description.trim() === '') {
            this.showToast('Validation Error', 'Description is required.', 'error');
            return;
        }

        // If valid, submit the form
        this.template.querySelector('lightning-record-form').submit(fields);


    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }




    handleCancel(event){
        console.log('RecordID::'+event.detail.id);
        
        console.log('2');
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                recordId: event.detail.id,
                objectApiName: 'Case',
                actionName: 'list'
            },
            state: {
                
                filterName: '00B5j00000CvPTYEA3' 
            }
        });
        console.log('3');
    }
}