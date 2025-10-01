import { LightningElement,track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import uploadFile from '@salesforce/apex/FileUploaderClass.uploadFile'
import saveFiles from '@salesforce/apex/CPBookingController.saveFiles';
import getFiles from '@salesforce/apex/CPBookingController.returnFiles';
const columns = [{
    label: 'Title',
    fieldName: 'FileName',
    type: 'url',
    typeAttributes: {
        label: {
            fieldName: 'Title'
        },
        target: '_blank'
    }
}];
export default class CpDocumentTest1 extends LightningElement {
    @api getSelfReg;
    showLoadingSpinner = false;
    @track fileNames = '';
    @track filesUploaded = [];
    fileData
    @track data;
    @track columns = columns;
    lastnextbutton;
    openfileUpload(event) {
        let files = event.target.files;

        if (files.length > 0) {
            let filesName = '';

            for (let i = 0; i < files.length; i++) {
                let file = files[i];

                filesName = filesName + file.name + ',';

                let freader = new FileReader();
                freader.onload = f => {
                    let base64 = 'base64,';
                    let content = freader.result.indexOf(base64) + base64.length;
                    let fileContents = freader.result.substring(content);
                    this.filesUploaded.push({
                        Title: file.name,
                        VersionData: fileContents
                    });
                };
                freader.readAsDataURL(file);
            }

            this.fileNames = filesName.slice(0, -1);
        }
    }
    handleClick() {
        this.showLoadingSpinner = true;
        saveFiles({filesToInsert: this.filesUploaded})
        .then(data => {
            this.showLoadingSpinner = false;
            const showSuccess = new ShowToastEvent({
                title: 'Success!!',
                message: this.fileNames + ' files uploaded successfully.',
                variant: 'Success',
            });
            this.dispatchEvent(showSuccess);
            this.getFilesData(data);
            if(this.getFilesData(data)){
                lastnextbutton = true;
            }
            this.fileNames = undefined;
        })
        .catch(error => {
            console.error('error:'+JSON.stringify(error))
            const showError = new ShowToastEvent({
                title: 'Error!!',
                message: 'An Error occur while uploading the file.',
                variant: 'error',
            });
            this.dispatchEvent(showError);
        });
    }

    toast(title){
        const toastEvent = new ShowToastEvent({
            title, 
            variant:"success"
        })
        this.dispatchEvent(toastEvent)
    }

    getFilesData(lstIds) {
        getFiles({lstFileIds: lstIds})
        .then(data => {
            data.forEach((record) => {
                record.FileName = '/' + record.Id;
            });

            this.data = data;
        })
        .catch(error => {
            window.console.log('error ====> ' + error);
        })
    }
}