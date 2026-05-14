import { LightningElement, track } from 'lwc';
import processPayment from '@salesforce/apex/BillDeskPayButtomTestCompController.processPayment';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class BilldeskPayButtonTestComponent extends LightningElement {
    paymentType = '';
    amount;
    @track responseData;
    isLoading = false;

    get paymentOptions() {
        return [
            { label: 'PRINCIPAL_GST', value: 'PRINCIPAL_GST' },
            { label: 'GST_ONLY', value: 'GST_ONLY' },
            { label: 'CUSTOM_AMOUNT', value: 'CUSTOM_AMOUNT' }
        ];
    }

    handlePaymentTypeChange(event) {
        this.paymentType = event.detail.value;
    }

    handleAmountChange(event) {
        this.amount = event.target.value;
    }

    handleSubmit() {

        if (!this.paymentType || !this.amount) {
            this.showToast('Error', 'Please fill all fields', 'error');
            return;
        }

        this.isLoading = true;

        processPayment({
            paymentType: this.paymentType,
            amount: this.amount
        })
        .then(result => {
            this.responseData = result;
            this.showToast('Success', result, 'success');
        })
        .catch(error => {
            this.showToast('Error', error.body.message, 'error');
        })
        .finally(() => {
            this.isLoading = false;
        });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }
}