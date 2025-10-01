import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class NavigateToRecord extends  NavigationMixin(LightningElement) {

    @api recId;

    connectedCallback(){
        console.log('recId: ' + this.recId);
        this.navigateToRecord(this.recId);

        
    }

    navigateToRecord(recId) {
        // Navigate to the Task record page after creation
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recId,
                actionName: 'view'
            }
        });
    }
}