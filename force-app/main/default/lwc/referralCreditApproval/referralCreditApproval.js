import { api, LightningElement, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import showUploadSection from '@salesforce/apex/SubmitForApprovalReferral.CheckUploadAttachmenttobeShown';
import checkAttachment from '@salesforce/apex/SubmitForApprovalReferral.CheckAttachmentinReferralCredit';
import sendapproval from '@salesforce/apex/SubmitForApprovalReferral.SendForReferralApproval';
import createcdl from '@salesforce/apex/SubmitForApprovalReferral.createContentLink';
import getFiles from '@salesforce/apex/SubmitForApprovalReferral.returnFiles';
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
export default class referralCreditApproval extends LightningElement {
    @api recordId;
    @track cmnt;
    @track isShowUploadSection = false;
    @track isAttachmentExist = false;
    // get URL Parameter
    currentPageReference = null;
    urlStateParameters = null;
    /* Params from Url */
    rcId = null;
    doc1 = false;
    doc2 = false;
    doc3 = false;
    doc4 = false;
    doc5 = false;
    doc6 = false;
    isSpinner = false;
    // isNri = false;
    // isKicker = false;
    // isoutstation = false;
    uploadedFiles = [];
    contentdocIds = [];
    contentdocIdsprocessedArray = [];
    showapprovalbutton = false;
    @track columns = columns;
    @track data;
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            this.setParametersBasedOnUrl();
        }
    }
    setParametersBasedOnUrl() {
        this.rcId = this.urlStateParameters.c__rcId || null;
    }

    // get showTable() {
    //      console.log('data'+this.data);
    //       console.log('isAttachmentExist'+this.isAttachmentExist);
    //     return this.data && this.isAttachmentExist;
    // }



    connectedCallback() {
        console.log('Data' + this.data);
        console.log('Rendered::' + this.rcId);
        
        // this.showTable();
        showUploadSection({ rcId: this.rcId })
            .then(result => {
                console.log('Result::' + JSON.parse(JSON.stringify(result)));
                this.isShowUploadSection = JSON.parse(JSON.stringify(result));
                console.log('isShowUploadSection::' + this.isShowUploadSection);
                if (this.isShowUploadSection == false) {
                    // this.notification()
                }
                // checkclient({ InvId: this.rcId }).then(result => {
                //     if (result) {
                //         this.isNri = true;
                //     } else if (result == false) {
                //         this.isNri = false;
                //     }
                // }).catch(error => {
                //     window.alert("error checkclient:" + JSON.stringify(error));
                // })

                // Kicker({ InvId: this.rcId }).then(result => {
                //     if (result) {
                //         this.isKicker = true;
                //         this.showapprovalbutton = true;
                //     } else {
                //         this.isKicker = false;
                //     }
                // }).catch(error => {
                //     window.alert("error Kicker:" + JSON.stringify(error));
                // })

                // outstationcp({ InvId: this.rcId }).then(result => {
                //     if (result) {
                //         this.isoutstation = true;
                //     } else {
                //         this.isoutstation = false;
                //     }
                // }).catch(error => {
                //     window.alert("error outstationcp:" + JSON.stringify(error));
                // })
            }).catch(error => {
                window.alert("error showUploadSection:" + JSON.stringify(error));
            })

        checkAttachment({ rcId: this.rcId }).then(result => {
            console.log('Result::' + JSON.parse(JSON.stringify(result)));
            this.isAttachmentExist = JSON.parse(JSON.stringify(result));
            console.log('isAttachmentExist::' + this.isAttachmentExist);

        }).catch(error => {
            window.alert("error checkAttachment:" + JSON.stringify(error));
        })


        // console.log('this.isNri::' + this.isNri);
        // console.log('this.isoutstation::' + this.isoutstation);
        // console.log('this.isKicker::' + this.isKicker);
    }
    get acceptedFormats() {
        return ['.pdf', '.png', '.jpg', '.jpeg'];
    }
    handleChangepicklistdoc(event) {
        this.typeofdoc = event.detail.value;
    }
    get docoptions() {
        return [
            { label: '--Select Type--', value: '--Select Type--' },
            { label: '* IOM', value: 'IOM' },
            { label: 'Index II copy of Referrer', value: 'Index II copy of Referrer' },
            { label: 'Index II copy of Referee', value: 'Index II copy of Referee' },
            { label: 'SCS copy of Referrer', value: 'SCS copy of Referrer' },
            { label: '* SCS copy of Referee', value: 'SCS copy of Referee' },
            { label: '* Booking form of Referee', value: 'Booking form of Referee' },
        ];
    }


    handleupload(event) {
        const uploadedFiles = event.detail.files;
        console.log('uploadedFiles files::' + uploadedFiles.documentId);
        console.log('uploadedFiles files 2::' + JSON.stringify(uploadedFiles));
        createcdl({ uploadedfile: uploadedFiles, rcId: this.rcId })
            .then(data => {
                const showSuccess = new ShowToastEvent({
                    title: 'Success!!',
                    message: 'File uploaded successfully.',
                    variant: 'Success',
                });
                console.log('Data_------------' + data);
                this.dispatchEvent(showSuccess);
                this.contentdocIds = data;
                console.log('this.contentdocIds' + JSON.stringify(this.contentdocIds));
                this.contentdocIdsprocessedArray.push({
                    cver: data
                });
                console.log('contentdocIdsprocessedArray::' + JSON.stringify(this.contentdocIdsprocessedArray))

                if (this.typeofdoc == 'IOM') {
                    this.doc1 = true;
                    this.typeofdoc = '';
                } else if (this.typeofdoc == 'Index II copy of Referrer') {
                    this.doc2 = true;
                    this.typeofdoc = '';
                } else if (this.typeofdoc == 'Index II copy of Referee') {
                    this.doc3 = true;
                    this.typeofdoc = '';
                } else if (this.typeofdoc == 'SCS copy of Referrer') {
                    this.doc4 = true;
                    this.typeofdoc = '';
                }
                else if (this.typeofdoc == 'SCS copy of Referee') {
                    this.doc5 = true;
                    this.typeofdoc = '';
                }
                else if (this.typeofdoc == 'Booking form of Referee') {
                    this.doc6 = true;
                    this.typeofdoc = '';
                }
                console.log('doc1::' + this.doc1);
                console.log('doc2::' + this.doc2);
                console.log('doc3::' + this.doc3);
                console.log('doc4::' + this.doc4);
                console.log('doc5::' + this.doc5);
                console.log('doc6::' + this.doc6);
                if (this.doc1 && this.doc5 && this.doc6) {
                    this.showapprovalbutton = true;
                }
                console.log('contentdocIdsprocessedArray'+this.contentdocIdsprocessedArray);
                this.getFilesData(this.contentdocIdsprocessedArray);
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
        console.log('second files::' + uploadedFiles);
    }
    getFilesData(lstIds) {
        getFiles({ lstFileIds: lstIds })
            .then(data => {
                data.forEach((record) => {
                    const baseUrl = window.location.origin;
                    // console.log('file download link',URL.getOrgDomainUrl().toExternalForm() + '/sfc/servlet.shepherd/document/download/' + record.ContentDocumentId);
                    // record.FileName = URL.getOrgDomainUrl().toExternalForm() + '/sfc/servlet.shepherd/document/download/' + record.ContentDocumentId;
                    record.FileName = baseUrl + '/sfc/servlet.shepherd/document/download/' + record.ContentDocumentId;
                    // record.FileName = 'https://runwal.force.com/servlet.shepherd/document/download/' + record.ContentDocumentId;
                });
                this.data = data;

                window.console.log('data ====> ' + JSON.stringify(data));
            })
            .catch(error => {
                window.console.log('error ====> ' + JSON.stringify(error));
            })
    }
    submitapproval() {
        this.isSpinner = true;
        sendapproval({ comment: this.cmnt, rcId: this.rcId })
            .then(result => {
                console.log('Result::' + JSON.parse(JSON.stringify(result)));
                this.isSpinner = false;
                const saveMessage = new ShowToastEvent({
                    title: 'Success !',
                    message: 'Approval Sent !',
                    variant: 'success',
                    mode: 'dismissable'
                })
                this.dispatchEvent(saveMessage);
                this.isSpinner = true;
                const baseUrl = window.location.origin;
                const recordUrl = `${baseUrl}/lightning/r/Referral_Credits__c/${this.rcId}/view`;
                location.replace(recordUrl);

            }).catch((error) => {
                this.isSpinner = false;
                if (error && error.body && error.body.message) {
                    const evt = new ShowToastEvent({
                        title: "Error!",
                        message: error.body.message,
                        variant: "error",
                    });
                    this.dispatchEvent(evt);
                }
            });


    }
    notification() {
        const evt = new ShowToastEvent({
            title: "Message",
            message: 'Please upload Invoice related document before sending it for approval',
            variant: "error",
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    handlecomment(event) {
        this.cmnt = event.target.value;
    }

    back() {
        const baseUrl = window.location.origin;
        const recordUrl = `${baseUrl}/lightning/r/Referral_Credits__c/${this.rcId}/view`;
        location.replace(recordUrl);
    }

}