import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';

import sendRegistrationLinktoCP from '@salesforce/apex/CPRegisterationController.sendRegistrationLinktoCP';

import cpName from '@salesforce/schema/Broker__c.Name';
import cpEmail from '@salesforce/schema/Broker__c.RW_Email__c';
import cpMobile from '@salesforce/schema/Broker__c.RW_Mobile_No__c';
import cpRecordType from '@salesforce/schema/Broker__c.RecordType.Name';
import rlink from '@salesforce/schema/Broker__c.Portal_Registration_Link__c';

export default class SendRegistrationLinktoCP extends LightningElement {
    @api recordId;
    @track isLoading = false;
    @track
    brokerName;
    brokerEmail;
    brokerMobile;
    recordType;
    registrationLink;

    @wire(getRecord, { recordId: '$recordId', fields: [cpName, cpEmail, cpMobile, cpRecordType,rlink] })
    wiredBroker({ error, data }) {
        if (data) {
            this.brokerName = getFieldValue(data, cpName);
            this.brokerEmail = getFieldValue(data, cpEmail);
            this.brokerMobile = getFieldValue(data, cpMobile);
            this.recordType = getFieldValue(data, cpRecordType);
            this.registrationLink = getFieldValue(data, rlink);
        } else if (error) {
            console.error('Error fetching broker details', error);
        }
    }

    get isTempPartner() {
        return this.recordType === 'Temp Channel Partner';
    }

    handleSendEmail() {
        if (!this.recordId) return;

        this.isLoading = true;

        sendRegistrationLinktoCP({ brId: this.recordId })
            .then((result) => {
                this.showToast('Success!!', result || 'The registration link has been sent successfully', 'success');
                this.dispatchEvent(new CloseActionScreenEvent());
            })
            .catch((error) => {
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

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}