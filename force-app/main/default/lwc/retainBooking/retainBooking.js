import { LightningElement, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NotifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import updateRetainBooking from '@salesforce/apex/RW_UnitTransferAndCancellation.updateRetainBooking';

export default class RetainBooking extends LightningElement {
    @api recordId;
    isLoading = false;

    handleRetain() {
        this.isLoading = true;
        
        updateRetainBooking({ recordId: this.recordId })
            .then(async () => {
                this.showToast('Success!', 'Booking successfully retained', 'success');
                
                // Tell LDS that the record has changed
                await NotifyRecordUpdateAvailable([{ recordId: this.recordId }]);
                
                // Close the modal
                this.closeAction();
                
            })
            .catch(error => {
                // Better error handling for Apex exceptions
                let message = 'Unknown error';
                if (Array.isArray(error.body)) {
                    message = error.body.map(e => e.message).join(', ');
                } else if (typeof error.body.message === 'string') {
                    message = error.body.message;
                }
                this.showToast('Error', message, 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        }));
    }
}