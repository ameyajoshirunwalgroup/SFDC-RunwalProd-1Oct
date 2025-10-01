import { LightningElement, wire, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import updategst from '@salesforce/apex/CPBookingController.UpdateGSTNo';
import createcdl from '@salesforce/apex/CPBookingController.createContentLink';
import getFiles from '@salesforce/apex/CPBookingController.returnFiles';
import getAllFiles from '@salesforce/apex/CPBookingController.returnAllFiles';
import GSTNoExist from '@salesforce/apex/CPBookingController.GSTPresent';
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

export default class CpUpdateGSTNo extends NavigationMixin(LightningElement) {
    @track gstno = null;
    @track broId = null;
    @track data;
    @track showsubmit = false;
    @track showSpinner = false;
    @track isPresent = false;
    @track columns = columns;
    contentdocIds = [];
    contentdocIdsprocessedArray = [];
    get acceptedFormats() {
        return ['.pdf', '.png', '.jpg', '.jpeg'];
    }
    handlegstChange(event) {
        this.gstno = event.detail.value;
    }
    // get URL Parameter
    currentPageReference = null;
    urlStateParameters = null;
    /* Params from Url */
    @track bId = null;
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            this.setParametersBasedOnUrl();
        }
    }
    setParametersBasedOnUrl() {
        this.bId = this.urlStateParameters.c__cpId || null;
        console.log('Bid::' + this.bId);
    }
    connectedCallback() {
        this.broId = this.bId;
        GSTNoExist({ CPId: this.broId})
            .then((result) => {
                this.isPresent = result;
            })
            .catch((error) => {
                this.error = error;
                window.alert("error :" + JSON.stringify(this.error));
            });
    }
    handlesave() {
        console.log('Handle Save broId::' + this.broId);
        this.showSpinner = true;
        updategst({ CPId: this.broId, gstno: this.gstno })
            .then((result) => {
                this.showSpinner = false;
                this[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: {
                        url: 'https://cpdesk.runwalgroup.in/s/accountdetails'
                    }
                });
            })
            .catch((error) => {
                this.error = error;
                window.alert("error :" + JSON.stringify(this.error));
            });
    }
    openfileUpload2(event) {
        const uploadedFiles = event.detail.files;
        console.log('second files::' + uploadedFiles.documentId);
        console.log('third files::' + JSON.stringify(uploadedFiles));
        createcdl({ uploadedfile: uploadedFiles, recId: this.broId })
            .then(data => {
                const showSuccess = new ShowToastEvent({
                    title: 'Success!!',
                    message: 'File uploaded successfully.',
                    variant: 'Success',
                });
                this.showsubmit = true;
                this.dispatchEvent(showSuccess);
                this.contentdocIds = data;

                console.log('this.contentdocIds' + JSON.stringify(this.contentdocIds));
                this.contentdocIdsprocessedArray.push({
                    cverId: data
                });
                console.log('contentdocIdsprocessedArray::' + JSON.stringify(this.contentdocIdsprocessedArray))
                this.getAllFilesData(this.contentdocIdsprocessedArray);
            })
            .catch(error => {
                console.error('error:-createcdl:' + JSON.stringify(error))
                const showError = new ShowToastEvent({
                    title: 'Error!!',
                    message: 'An Error occur while uploading the file.',
                    variant: 'error',
                });
                this.dispatchEvent(showError);
            });
    }
    getFilesData(lstIds) {
        getFiles({ lstFileIds: lstIds })
            .then(data => {
                data.forEach((record) => {
                    record.FileName = 'https://cpdesk.runwalgroup.in/sfc/servlet.shepherd/document/download/' + record.ContentDocumentId;
                });

                this.data = data;

                window.console.log('data ====> ' + JSON.stringify(data));
            })
            .catch(error => {
                window.console.log('error ====> ' + JSON.stringify(error));
            })
    }

    getAllFilesData(lstIds) {
        getAllFiles({ allfiles: lstIds })
            .then(data => {
                data.forEach((record) => {
                    record.FileName = 'https://cpdesk.runwalgroup.in/sfc/servlet.shepherd/document/download/' + record.ContentDocumentId;
                });

                this.data = data;

                window.console.log('data ====> ' + JSON.stringify(data));
            })
            .catch(error => {
                window.console.log('error ====> ' + JSON.stringify(error));
            })
    }
}