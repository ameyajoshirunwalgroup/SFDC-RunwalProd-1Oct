import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import SITE_URL from '@salesforce/label/c.Site_Url_New';
import { getRecord } from 'lightning/uiRecordApi';

const RECORDTYPE_FIELD = 'Channel_Partner__c.RecordType.DeveloperName';

export default class CpUpdateLink extends LightningElement {
    @api recordId;

    recordTypeName;

    @wire(getRecord, { recordId: '$recordId', fields: [RECORDTYPE_FIELD] })
    wiredRecord({ data, error }) {
        if (data) {
            this.recordTypeName = data.fields.RecordType.value.fields.DeveloperName.value;
        }
    }

    generateLink() {
        // Decide parameter name based on record type
        let paramName = '';

        if (this.recordTypeName === 'Channel_Partner') {
            paramName = 'brId';
        } else if (this.recordTypeName === 'Temp_Channel_Partner') {
            paramName = 'tempcpid';
        } else {
            paramName = 'brId'; // fallback if needed
        }

        const url = `${SITE_URL}/s/customregisterpage?${paramName}=${this.recordId}`;

        if (navigator.clipboard && navigator.clipboard.writeText) {
            navigator.clipboard.writeText(url).then(() => {
                this.showToast(
                    'Success',
                    'Copied to clipboard! Link can be shared via WhatsApp or Email',
                    'success'
                );
            }).catch(() => {
                this.fallbackCopy(url);
            });
        } else {
            this.fallbackCopy(url);
        }
    }

    fallbackCopy(text) {
        const textarea = document.createElement('textarea');
        textarea.value = text;
        textarea.style.position = 'fixed';
        document.body.appendChild(textarea);
        textarea.focus();
        textarea.select();

        try {
            document.execCommand('copy');
            this.showToast('Success', 'Copied to clipboard!', 'success');
        } catch (err) {
            this.showToast('Error', 'Failed to copy link', 'error');
        }

        document.body.removeChild(textarea);
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