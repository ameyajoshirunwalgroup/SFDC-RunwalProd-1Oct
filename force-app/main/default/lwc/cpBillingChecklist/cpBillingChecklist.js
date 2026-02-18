import { LightningElement, api, wire, track } from 'lwc';
import getChecklistRecords from '@salesforce/apex/CPBillingChecklistController.getChecklistRecords';
import updateChecklist from '@salesforce/apex/CPBillingChecklistController.updateChecklist';
import getUserPreviousRemarks from '@salesforce/apex/CPBillingChecklistController.getUserPreviousRemarks';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CpBillingChecklist extends LightningElement {
    @api recordId;
    @track checklist = [];
    wiredResult;


    @wire(getChecklistRecords, { bookingId: '$recordId' })
    wiredChecklist(result) {
        this.wiredResult = result;
        if (result.data) {
            let tempData = result.data.map(item => {
                let fieldDisplayValue = '';
                console.log('Checklist item name:', JSON.stringify(item.Checklist_Item__c));
                switch (item.Checklist_Item__c) {
                    case 'Agreement Value':
                        let agreementValue = item.Booking__r?.Original_Agreement_Value__c;
                        fieldDisplayValue = agreementValue != null
                            ? new Intl.NumberFormat('en-IN', { style: 'currency', currency: 'INR' }).format(agreementValue)
                            : '—';
                        break;
                    case 'Booking Date':
                        if (item.Booking__r?.Booking_Date__c) {
                            const dateVal = new Date(item.Booking__r.Booking_Date__c);
                            fieldDisplayValue = dateVal.toLocaleDateString();

                        } else {
                            fieldDisplayValue = '—';
                        }
                        break;

                    case 'Channel Partner Tagging':
                        fieldDisplayValue = item.Booking__r?.BrokerIId__r?.Name || '—';
                        break;
                    case 'Brokerage Scheme':
                        fieldDisplayValue = item.Booking__r?.Brokerage_Scheme__r?.Name || '—';
                        break;
                    case 'Competency Certificate Validity':
                        fieldDisplayValue = item.Booking__r?.BrokerIId__r?.Valid_competency_certificate__c ? 'Valid' : 'Not Valid';
                        break;
                    case 'Rera Certificate Validity':
                        fieldDisplayValue = item.Booking__r?.BrokerIId__r?.Valid_RERA_certificate__c ? 'Valid' : 'Not Valid';
                        break;

                    case 'CP Passback':
                        let passbackVal = item.Booking__r?.Quotation__r?.Discount_9_L__c;
                        fieldDisplayValue = passbackVal != null
                            ? new Intl.NumberFormat('en-IN', { style: 'currency', currency: 'INR' }).format(passbackVal)
                            : '—';
                        break;

                    case 'SDR Paid By Runwal':
                        let sdrVal = item.Booking__r?.Stamp_duty_payable_by_Runwal__c;
                        fieldDisplayValue = sdrVal != null
                            ? new Intl.NumberFormat('en-IN', { style: 'currency', currency: 'INR' }).format(sdrVal)
                            : '—';
                        break;

                    case 'Development Charges':
                        let devChargeVal = item.Booking__r?.Development_Charge__c;
                        fieldDisplayValue = devChargeVal != null
                            ? new Intl.NumberFormat('en-IN', { style: 'currency', currency: 'INR' }).format(devChargeVal)
                            : '—';
                        break;
                }

                return {
                    ...item,
                    fieldDisplayValue,
                    remarkValue: item.Remark__c || '',
                    previousRemarks: [],
                    isDisabled: item.Status__c === 'Approved' || item.Status__c === 'Rejected',
                    showButtons: item.Status__c !== 'Approved' && item.Status__c !== 'Rejected',
                    isDraft: item.Status__c === 'Draft'
                };
            });


            this.checklist = tempData.sort((a, b) => {
                const order = { 'Draft': 1, 'Approved': 2, 'Rejected': 3 };
                return (order[a.Status__c] || 4) - (order[b.Status__c] || 4);
            });



            const recordIds = this.checklist.map(c => c.Id);
            if (recordIds.length > 0) {
                getUserPreviousRemarks({ recordIds })
                    .then(data => {
                        this.checklist = this.checklist.map(item => ({
                            ...item,
                            previousRemarks: (data[item.Id] || []).join('\n'),
                            showPreviousRemark: item.Status__c === 'Draft' && (data[item.Id] && data[item.Id].length > 0)

                        }));
                    })
                    .catch(error => {
                        this.showToast('Error', error.body.message, 'error');
                    });
            }
        } else if (result.error) {
            this.showToast('Error', 'Error fetching checklist', 'error');
        }
    }


    handleRemarkChange(event) {
        const recId = event.target.dataset.id;
        const value = event.target.value;
        this.checklist = this.checklist.map(item =>
            item.Id === recId ? { ...item, remarkValue: value } : item
        );
    }

    handleAction(event) {
        const recordId = event.target.dataset.id;
        const action = event.target.dataset.action;
        const record = this.checklist.find(item => item.Id === recordId);

        if (!record.remarkValue || record.remarkValue.trim() === '') {
            this.showToast('Validation Error', 'Remark is mandatory before Approve or Reject.', 'error');
            return;
        }
        if (record.remarkValue.trim() === (record.Remark__c || '').trim()) {
            this.showToast('Validation Error', 'Remark must be different from the previous remark.', 'error');
            return;
        }

        updateChecklist({ recordId: recordId, status: action, remark: record.remarkValue })
            .then(() => {
                this.showToast('Success', `Record ${action}`, 'success');
                return refreshApex(this.wiredResult);
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            });
    }

    showButtons(status) {

        return status !== 'Approved' && status !== 'Rejected';
    }


    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}