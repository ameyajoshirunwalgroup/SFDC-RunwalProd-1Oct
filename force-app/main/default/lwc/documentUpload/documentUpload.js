import { LightningElement,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class FileUpload extends LightningElement {
    @api recordId;
    @api acceptedFileFormats;
    @api fileUploaded;
    @api showsignup;
    @api showUpload;
    @api showuploadmodal;
    handleUploadFinished() {
        this.dispatchEvent(new CustomEvent('uploadfinished', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                data: { recordId: this.recordId }
            }
        }));
        this.dispatchEvent(new ShowToastEvent({
            title: 'Completed',
            message: 'File has been uploaded',
        }));
    }
}