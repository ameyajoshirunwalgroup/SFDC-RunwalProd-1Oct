import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import SITE_URL from '@salesforce/label/c.Site_Url_New';
import USER_ID from '@salesforce/user/Id';

export default class CpRegistrationLink extends LightningElement {
    
    generateLink() {
        const url = `${SITE_URL}/s/customregisterpage?smId=${USER_ID}`;

        if (navigator.clipboard && navigator.clipboard.writeText) {
            navigator.clipboard.writeText(url).then(() => {
                this.showToast('Success', 'Copied to clipboard!Link can be shared via Whatsapp or Email', 'success');
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
            this.showToast('Success', 'Copied to clipboard!! Link can be shared via Whatsapp or Email', 'success');
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