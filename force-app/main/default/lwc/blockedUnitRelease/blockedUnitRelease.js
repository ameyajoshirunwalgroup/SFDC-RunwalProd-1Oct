import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent} from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import releaseUnit from '@salesforce/apex/BlockedUnitRelease.releaseUnit';
import sendApproval from '@salesforce/apex/BlockedUnitRelease.sendApproval';

export default class BlockedUnitRelease extends LightningElement {

    @api recordId;
    message;
    errorMessage;

    @wire(releaseUnit, {oppId: '$recordId'}) 
    releaseStatus({data,error}){
        if(data){
            console.log('data: ', data);
            //this.message = data;
            let recId = data;
            sendApproval({blkInfoId: recId})
            .then( result => {
                console.log('result: ', result);
                this.message = result;
                const showSuccess = new ShowToastEvent({
                    title: 'Success!!',
                    message: 'Approval Request submitted successfully.',
                    variant: 'Success',
                });
                this.dispatchEvent(showSuccess);
            })
            .catch( e => {
                console.log('e: ', e);
                this.message = e;
                const showError = new ShowToastEvent({
                    title: 'Error!!',
                    message: e.body.message,
                    variant: 'error',
                });
                this.dispatchEvent(showError);
            });
            window.setTimeout(() => {
                this.dispatchEvent(new CloseActionScreenEvent());
             }, 3000);
        }else if(error){
            console.log('error: ', error);
            this.errorMessage = error;
            const showError = new ShowToastEvent({
                title: 'Error!!',
                message: error.body.message,
                variant: 'error',
            });
            this.dispatchEvent(showError);
            window.setTimeout(() => {
                this.dispatchEvent(new CloseActionScreenEvent());
             }, 3000);
        }
        //this.dispatchEvent(new CloseActionScreenEvent());
    }

    
}