import { LightningElement, wire, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import getBrokerDetails from '@salesforce/apex/CPRegisterationController.getBrokerDetails';
import updatevaluesinCP from '@salesforce/apex/CPRegisterationController.updateDocDetailsnSubmitforAppr';
// import createcdl from '@salesforce/apex/CPRegisterationController.createContentLink2';
// import getFiles from '@salesforce/apex/CPRegisterationController.returnFiles';
import uploadFile from '@salesforce/apex/CPRegisterationController.uploadFile';
import fetchFiles from '@salesforce/apex/CPRegisterationController.fetchFiles';
// import getAllFiles from '@salesforce/apex/CPRegisterationController.returnAllFiles';
import userId from '@salesforce/user/Id';
//import RERANoExist from '@salesforce/apex/CPRegisterationController.RERAPresent';
const columns = [
    {
        label: 'File Name',
        fieldName: 'fileUrl',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'Title' },
            target: '_blank'
        }
    },
    { label: 'Type', fieldName: 'FileType', type: 'text' },
    // { label: 'Size (KB)', fieldName: 'ContentSizeKB', type: 'number' },
    { label: 'Created Date', fieldName: 'CreatedDate', type: 'date' },
    { label: 'Last Modified Date', fieldName: 'LastModifiedDate', type: 'date' }
];
export default class UploadRERAnCC extends LightningElement {
    @track recordId;
    isrera = false;
    iscc = false;
    @track brokerData = {};
    @track isreravalid = false;
    @track isccvalid = false;
    @track rerano = null;
    @track broId = null;
    @track data;
    @track showsubmit = false;
    @track showSpinner = false;
    @track isPresent = false;
    reraexpDate;
    ccexpDate;
    @track docType;
    @track lstAllFiles;
    today = new Date().toISOString().split('T')[0];
    @track columns = columns;
    contentdocIds = [];
    contentdocIdsprocessedArray = [];
    get acceptedFormats() {
        return ['.pdf', '.png', '.jpg', '.jpeg'];
    }
    // get URL Parameter
    currentPageReference = null;
    urlStateParameters = null;
    files;
    /* Params from Url */
    // @track bId = null;
    // @wire(CurrentPageReference)
    // getStateParameters(currentPageReference) {
    //     if (currentPageReference) {
    //         this.urlStateParameters = currentPageReference.state;
    //         this.setParametersBasedOnUrl();
    //     }
    // }
    connectedCallback() {
        console.log('User Id:', userId);
        this.fullUrl = window.location.href;
        this.pathUrl = window.location.pathname;

        console.log('Full URL:', this.fullUrl);
        console.log('Path:', this.pathUrl);
        const splitedPathUrl = this.pathUrl.split('/')
        const splitedPathUrlLastIndex = splitedPathUrl[splitedPathUrl.length - 1]
        console.log('split url -> ', splitedPathUrl)
        console.log('split url last index -> ', splitedPathUrl[splitedPathUrl.length - 1])
        if (splitedPathUrlLastIndex == 'upload-latest-rera') {
            this.isrera = true;
            this.docType = 'RERA Certificate';
        } else if (splitedPathUrlLastIndex == 'upload-latest-cc') {
            this.iscc = true;
            this.docType = 'Competency Certificate';
        }
        console.log('isrera -', this.isrera)
        console.log('iscc -', this.iscc)

        getBrokerDetails({ CPUserId: userId })
            .then((result) => {
                if (result && result.length > 0) {
                    this.brokerData = result;
                    console.log('Broker Id ->', this.brokerData.Id);
                    console.log('result -> ', result)
                    this.brokerData = result[0];
                    console.log('brokerData ->', this.brokerData);
                    console.log('Broker data -> ', JSON.stringify(this.brokerData));
                    // console.log('Broker RERA -> ', this.brokerData.Valid_RERA_certificate__c);
                    console.log('Broker Id -> ', this.brokerData.Id);
                    console.log('Broker Id -> ', this.recordId);

                    this.recordId = this.brokerData.Id;
                    window.history.pushState({}, '', window.location.pathname + '?brId=' + this.recordId);
                    console.log('Broker Id -> ', this.brokerData.Id);
                    console.log('Broker Id -> ', this.recordId);
                    this.getFilesData2(this.recordId);
                    // console.log('Broker RERA -> ',this.brokerData[Valid_RERA_certificate__c]);
                    // console.log('Broker CC -> ',this.brokerData.Valid_competency_certificate__c);
                } else {
                    console.error('No broker record found for user:', userId);
                }
            })
            .catch((error) => {
                this.error = error;
                // console.log('error-', JSON.stringify(this.error));

                console.error('Raw error object:', error);
                console.error('Stringified error:', JSON.stringify(error));

                // Check for Apex errors
                if (error?.body?.message) {
                    console.error('Apex error message:', error.body.message);
                }
                // JS errors
                else if (error?.message) {
                    console.error('JS error message:', error.message);
                }
                // Network/server errors
                else if (error?.statusText) {
                    console.error('Status text:', error.statusText);
                }
                else {
                    console.error('Unexpected error format:', error);
                }
            })
            .finally(() => {
                this.showSpinner = false; // hide spinner once done
            });



        // this.userId = this.bId;
        // RERANoExist({ CPId: this.userId })
        //     .then((result) => {
        //         this.isPresent = result;
        //     })
        //     .catch((error) => {
        //         this.error = error;
        //         window.alert("error :" + JSON.stringify(this.error));
        //     });
    }

    get isRERAUnderApproval() {
        console.log('this.brokerData RERA -> ', JSON.stringify(this.brokerData))
        console.log('this.brokerData.Latest_RERA_Upload_Status__c -> ', this.brokerData.Latest_RERA_Upload_Status__c)
        if (this.brokerData.Latest_RERA_Upload_Status__c === 'Approval Pending') {
            return true;
        } else {
            return false;
        }
    }
    get isCCUnderApproval() {
        console.log('this.brokerData CC -> ', JSON.stringify(this.brokerData))
        console.log('this.brokerData.Latest_CC_Upload_Status__c -> ', this.brokerData.Latest_CC_Upload_Status__c)
        if (this.brokerData.Latest_CC_Upload_Status__c === 'Approval Pending') {
            return true;
        } else {
            return false;
        }
    }

    get showRERA() {
        if (this.isrera && !this.isRERAUnderApproval && !this.isCCUnderApproval) {
            return true;
        } else {
            return false;
        }
    }

    get showCC() {
        if (this.iscc && !this.isRERAUnderApproval && !this.isCCUnderApproval) {
            return true;
        } else {
            return false;
        }
    }

    get showSubmit() {
        if (this.lstAllFiles && (this.showRERA || this.showCC)) {
            return true;
        } else {
            return false;
        }
    }


    handlesave() {
        console.log('Handle Save userId::' + this.userId)
        console.log('RERA Exp date:: ' + this.reraexpDate)
        console.log('CC Exp date:: ' + this.ccexpDate)

        if (!this.reraexpDate && this.isrera == true) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Missing RERA Expiry Date',
                    message: 'Please select the RERA expiry date before submitting.',
                    variant: 'error',
                    mode: 'dismissable'
                })
            );
            return;
        }
        if (!this.ccexpDate && this.iscc == true) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Missing CC Expiry Date',
                    message: 'Please select the CC expiry date before submitting.',
                    variant: 'error',
                    mode: 'dismissable'
                })
            );
            return;
        }
        if (!this.files || this.files.length === 0) {
            this.showToast(
                'Error!!',
                'Please upload at least one document.',
                'error'
            );
            return;
        }
        this.showSpinner = true;
        updatevaluesinCP({ isrera: this.isrera, iscc: this.iscc, brId: this.recordId, reraExpDate: this.reraexpDate, ccExpDate: this.ccexpDate })
            .then((result) => {
                this.showSpinner = false;
                if (this.isrera == true) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'RERA details submitted successfully.',
                            variant: 'success'
                        })
                    );
                }
                if (this.iscc == true) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'CC details submitted successfully.',
                            variant: 'success'
                        })
                    );
                }
                this[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: {
                        url: 'https://cpdesk.runwalgroup.in/s/'
                    }
                });
            })
            .catch((error) => {
                this.showSpinner = false;
                if (this.isrera == true) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Error while submitting RERA details: ' + error.body.message,
                            variant: 'error'
                        })
                    );
                }
                if (this.iscc == true) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Error while submitting CC details: ' + error.body.message,
                            variant: 'error'
                        })
                    );
                }
            });
    }

    // openfileUpload2(event) {
    //     const uploadedFiles = event.detail.files;
    //     console.log('second files::' + uploadedFiles.documentId);
    //     console.log('third files::' + JSON.stringify(uploadedFiles));
    //     console.log('User Id:', userId);
    //     createcdl({ uploadedfile: uploadedFiles, recId: userId })
    //         .then(data => {
    //             const showSuccess = new ShowToastEvent({
    //                 title: 'Success!!',
    //                 message: 'File uploaded successfully.',
    //                 variant: 'Success',
    //             });
    //             this.showsubmit = true;
    //             this.dispatchEvent(showSuccess);
    //             this.contentdocIds = data;

    //             console.log('this.contentdocIds' + JSON.stringify(this.contentdocIds));
    //             this.contentdocIdsprocessedArray.push({
    //                 cverId: data
    //             });
    //             console.log('contentdocIdsprocessedArray::' + JSON.stringify(this.contentdocIdsprocessedArray))
    //             this.getAllFilesData(this.contentdocIdsprocessedArray);
    //         })
    //         .catch(error => {
    //             console.error('error:-createcdl:' + JSON.stringify(error))
    //             const showError = new ShowToastEvent({
    //                 title: 'Error!!',
    //                 message: 'An Error occur while uploading the file.',
    //                 variant: 'error',
    //             });
    //             this.dispatchEvent(showError);
    //         });
    // }
    // getFilesData(lstIds) {
    //     getFiles({ lstFileIds: lstIds })
    //         .then(data => {
    //             data.forEach((record) => {
    //                 record.FileName = 'https://cpdesk.runwalgroup.in/sfc/servlet.shepherd/document/download/' + record.ContentDocumentId;
    //             });

    //             this.data = data;

    //             window.console.log('data ====> ' + JSON.stringify(data));
    //         })
    //         .catch(error => {
    //             window.console.log('error ====> ' + JSON.stringify(error));
    //         })
    // }

    // getAllFilesData(lstIds) {
    //     getAllFiles({ allfiles: lstIds })
    //         .then(data => {
    //             data.forEach((record) => {
    //                 record.FileName = 'https://cpdesk.runwalgroup.in/sfc/servlet.shepherd/document/download/' + record.ContentDocumentId;
    //             });

    //             this.data = data;

    //             window.console.log('data ====> ' + JSON.stringify(data));
    //         })
    //         .catch(error => {
    //             window.console.log('error ====> ' + JSON.stringify(error));
    //         })
    // }

    async openfileUpload2(event) {

        try {
            this.files = event.target.files;
            // const recordId = this.isUpdate ? this.brId : this.selfregisterId;           

            for (const file of this.files) {
                const base64 = await this.readFileAsBase64(file);
                // this.docType = this.local ? this.typeofdoclocal : this.typeofdocNRI;
                console.log('doc type -> ', this.docType)
                console.log('Record Id -> ', this.recordId)
                // console.log('doc local -> ', this.local)
                // console.log('doc type local-> ', this.typeofdoclocal)
                // console.log('doc type NRI-> ', this.typeofdocNRI)
                await uploadFile({
                    base64: base64,
                    filename: file.name,
                    recordId: this.recordId,
                    docType: this.docType
                });
            }

            await this.getFilesData2(this.recordId);

            this.showToast('Success!!', `${this.docType} uploaded successfully.`, 'success');
        } catch (error) {
            console.error('Error in uploadFile -> ', error);
            this.showToast(
                'Error!!',
                error?.body?.message || 'An error occurred while uploading the file.',
                'error'
            );
        }
    }

    async getFilesData2(brokerId) {
        const result = await fetchFiles({ recordId: brokerId });
        this.lstAllFiles = result.map(row => ({
            Id: row.ContentDocumentId,
            Title: row.ContentDocument.Title,
            FileType: row.ContentDocument.FileType,
            CreatedDate: row.ContentDocument.CreatedDate,
            LastModifiedDate: row.ContentDocument.LastModifiedDate,
            fileUrl: `/sfc/servlet.shepherd/document/download/${row.ContentDocumentId}`
        }));
        console.log('lstAllFiles -> ', JSON.stringify(this.lstAllFiles));
    }

    readFileAsBase64(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = async () => resolve(reader.result.split(',')[1]);
            reader.onerror = reject;
            reader.readAsDataURL(file);
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


    handleReraExpDateChange(event) {
        this.reraexpDate = event.target.value;
        console.log('reraexpDate -> ', this.reraexpDate)
    }
    handleCCExpDateChange(event) {
        this.ccexpDate = event.target.value;
        console.log('ccexpDate -> ', this.ccexpDate)
    }
}