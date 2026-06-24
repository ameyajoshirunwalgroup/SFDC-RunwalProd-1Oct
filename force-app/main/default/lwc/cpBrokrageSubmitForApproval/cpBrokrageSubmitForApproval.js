import { api, LightningElement, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation'; // Added NavigationMixin
import getApprval from '@salesforce/apex/CpBrokerageSubmitForApprovalLwc.CheckAttachmentInvoice';
import sendapproval from '@salesforce/apex/CpBrokerageSubmitForApprovalLwc.SendForApprovalInvoice';
import createcdl from '@salesforce/apex/CpBrokerageSubmitForApprovalLwc.createContentLink';
import checkclient from '@salesforce/apex/CpBrokerageSubmitForApprovalLwc.CheckClient';
import Kicker from '@salesforce/apex/CpBrokerageSubmitForApprovalLwc.IsKicker';
import outstationcp from '@salesforce/apex/CpBrokerageSubmitForApprovalLwc.CheckClientOuts';
import getFiles from '@salesforce/apex/CpBrokerageSubmitForApprovalLwc.returnFiles';

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

export default class InvoiceSchemeApproval extends NavigationMixin(LightningElement) { // Added NavigationMixin
    @api recordId;
    @track cmnt;
    @track isAttachmentExist = false;
    
    // get URL Parameter
    currentPageReference = null;
    urlStateParameters = null;
    
    /* Params from Url */
    bId = null;
    doc1 = false;
    doc2 = false;
    doc3 = false;
    doc4 = false;
    doc5 = false;
    doc6 = false;
    isSpinner = false;
    isNri = false;
    isKicker = false;
    isoutstation = false;
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
        this.bId = this.urlStateParameters.c__bId || null;
    }

    connectedCallback() {
        console.log('Rendered::' + this.bId);
        
        getApprval({ InvId: this.bId }).then(result => {
            console.log('Result::' + JSON.parse(JSON.stringify(result)));
            this.isAttachmentExist = JSON.parse(JSON.stringify(result));
            console.log('isAttachmentExist::' + this.isAttachmentExist);
            
            if (this.isAttachmentExist == false) {
                this.notification()
            }

            checkclient({ InvId: this.bId }).then(result => {
                if (result) {
                    this.isNri = true;
                } else if (result == false) {
                    this.isNri = false;
                }
            }).catch(error => {
                window.alert("error checkclient:" + JSON.stringify(error));
            })

            Kicker({ InvId: this.bId }).then(result => {
                if (result) {
                    this.isKicker = true;
                    this.showapprovalbutton = true;
                } else {
                    this.isKicker = false;
                }
            }).catch(error => {
                window.alert("error Kicker:" + JSON.stringify(error));
            })

            outstationcp({ InvId: this.bId }).then(result => {
                if (result) {
                    this.isoutstation = true;
                } else {
                    this.isoutstation = false;
                }
            }).catch(error => {
                window.alert("error outstationcp:" + JSON.stringify(error));
            })
        }).catch(error => {
            window.alert("error getApprval:" + JSON.stringify(error));
        })

        console.log('this.isNri::' + this.isNri);
        console.log('this.isoutstation::' + this.isoutstation);
        console.log('this.isKicker::' + this.isKicker);
    }

    get acceptedFormats() {
        return ['.pdf', '.png', '.jpg', '.jpeg'];
    }

    handleChangepicklistdoc(event) {
        this.typeofdoc = event.detail.value;
    }

    get docoptions() {
        if (this.isNri) {
            return [
                { label: '--Select Type--', value: '--Select Type--' },
                { label: 'Invoice Hard Copy', value: 'Invoice Hard Copy' },
                { label: '* SCS Copy ( Sales Conformation Sheet )', value: 'SCS Copy ( Sales Conformation Sheet )' },
                { label: 'Sales IOM', value: 'Sales IOM' },
                { label: '* Booking Form', value: 'Booking Form' },
                { label: 'Index 2', value: 'Index 2' },
                { label: 'SFDC Copy', value: 'SFDC Copy' },
                { label: '* Pass Port ( IF NRI ) / ( If Outstation )  Aadhar Card or Electricity Bill', value: 'Pass Port ( IF NRI ) / ( If Outstation )  Aadhar Card or Electricity Bill' },
                { label: '* Visa Copy', value: 'Visa Copy' },
                { label: 'Current Residential Proof', value: 'Current Residential Proof' },
                { label: 'Any Additional IOM if required', value: 'Any Additional IOM if required' }
            ];
        } else if (this.isNri == false) {
            if (this.isoutstation) {
                return [
                    { label: '--Select Type--', value: '--Select Type--' },
                    { label: 'Invoice Hard Copy', value: 'Invoice Hard Copy' },
                    { label: '* SCS Copy ( Sales Conformation Sheet )', value: 'SCS Copy ( Sales Conformation Sheet )' },
                    { label: 'Sales IOM', value: 'Sales IOM' },
                    { label: '* Booking Form', value: 'Booking Form' },
                    { label: 'Index 2', value: 'Index 2' },
                    { label: 'SFDC Copy', value: 'SFDC Copy' },
                    { label: '* Pass Port ( IF NRI ) / ( If Outstation )  Aadhar Card or Electricity Bill', value: 'Pass Port ( IF NRI ) / ( If Outstation )  Aadhar Card or Electricity Bill' },
                    { label: 'Any Additional IOM if required', value: 'Any Additional IOM if required' }
                ];
            } else if (this.isoutstation == false) {
                return [
                    { label: '--Select Type--', value: '--Select Type--' },
                    { label: 'Invoice Hard Copy', value: 'Invoice Hard Copy' },
                    { label: '* SCS Copy ( Sales Conformation Sheet )', value: 'SCS Copy ( Sales Conformation Sheet )' },
                    { label: 'Sales IOM', value: 'Sales IOM' },
                    { label: '* Booking Form', value: 'Booking Form' },
                    { label: 'Index 2', value: 'Index 2' },
                    { label: 'SFDC Copy', value: 'SFDC Copy' },
                    { label: 'Any Additional IOM if required', value: 'Any Additional IOM if required' }
                ];
            }
        }
    }

    handleupload(event) {
        const uploadedFiles = event.detail.files;
        console.log('uploadedFiles files::' + uploadedFiles.documentId);
        console.log('uploadedFiles files 2::' + JSON.stringify(uploadedFiles));
        
        createcdl({ uploadedfile: uploadedFiles, recId: this.bId })
            .then(data => {
                const showSuccess = new ShowToastEvent({
                    title: 'Success!!',
                    message: 'File uploaded successfully.',
                    variant: 'Success',
                });
                this.dispatchEvent(showSuccess);
                
                this.contentdocIds = data;
                console.log('this.contentdocIds' + JSON.stringify(this.contentdocIds));
                
                this.contentdocIdsprocessedArray.push({
                    cver: data
                });
                
                console.log('contentdocIdsprocessedArray::' + JSON.stringify(this.contentdocIdsprocessedArray))
                
                if (this.isNri) {
                    if (this.isKicker == false) {
                        if (this.typeofdoc == 'Invoice Hard Copy') {
                            this.doc1 = true;
                            this.typeofdoc = '--Select Type--';
                        } else if (this.typeofdoc == 'SCS Copy ( Sales Conformation Sheet )') {
                            this.doc2 = true;
                            this.typeofdoc = '--Select Type--';
                        } else if (this.typeofdoc == 'Sales IOM') {
                            this.doc3 = true;
                            this.typeofdoc = '--Select Type--';
                        } else if (this.typeofdoc == 'Booking Form') {
                            this.doc4 = true;
                            this.typeofdoc = '--Select Type--';
                        } else if (this.typeofdoc == 'Index 2') {
                            this.doc5 = true;
                            this.typeofdoc = '--Select Type--';
                        } else if (this.typeofdoc == 'SFDC Copy') {
                            this.doc6 = true;
                            this.typeofdoc = '--Select Type--';
                        } else if (this.typeofdoc == 'Pass Port ( IF NRI ) / ( If Outstation )  Aadhar Card or Electricity Bill') {
                            this.doc7 = true;
                            this.typeofdoc = '--Select Type--';
                        } else if (this.typeofdoc == 'Visa Copy') {
                            this.doc8 = true;
                            this.typeofdoc = '--Select Type--';
                        } else if (this.typeofdoc == 'Current Residential Proof') {
                            this.doc9 = true;
                            this.typeofdoc = '--Select Type--';
                        }
                        
                        console.log('isNri doc2::' + this.doc2);
                        console.log('isNri doc3::' + this.doc3);
                        console.log('isNri doc4::' + this.doc4);
                        console.log('isNri doc5::' + this.doc5);
                        console.log('isNri doc6::' + this.doc6);
                        console.log('isNri doc7::' + this.doc7);
                        console.log('isNri doc8::' + this.doc8);
                        console.log('isNri doc9::' + this.doc9);
                        
                        if (this.doc2 && this.doc4 && this.doc7 && this.doc8) {
                            this.showapprovalbutton = true;
                        }
                    } else if (this.isKicker == true) {
                        this.showapprovalbutton = true;
                    }
                } else if (this.isNri == false) {
                    if (this.isoutstation) {
                        if (this.isKicker) {
                            this.showapprovalbutton = true;
                        } else if (this.isKicker == false) {
                            if (this.typeofdoc == 'Invoice Hard Copy') {
                                this.doc1 = true;
                                this.typeofdoc = '--Select Type--';
                            } else if (this.typeofdoc == 'SCS Copy ( Sales Conformation Sheet )') {
                                this.doc2 = true;
                                this.typeofdoc = '--Select Type--';
                            } else if (this.typeofdoc == 'Sales IOM') {
                                this.doc3 = true;
                                this.typeofdoc = '--Select Type--';
                            } else if (this.typeofdoc == 'Booking Form') {
                                this.doc4 = true;
                                this.typeofdoc = '--Select Type--';
                            } else if (this.typeofdoc == 'Index 2') {
                                this.doc5 = true;
                                this.typeofdoc = '--Select Type--';
                            } else if (this.typeofdoc == 'SFDC Copy') {
                                this.doc6 = true;
                                this.typeofdoc = '--Select Type--';
                            } else if (this.typeofdoc == 'Pass Port ( IF NRI ) / ( If Outstation )  Aadhar Card or Electricity Bill') {
                                this.doc7 = true;
                                this.typeofdoc = '--Select Type--';
                            } else if (this.typeofdoc == 'Visa Copy') {
                                this.doc8 = true;
                                this.typeofdoc = '--Select Type--';
                            } else if (this.typeofdoc == 'Current Residential Proof') {
                                this.doc9 = true;
                                this.typeofdoc = '--Select Type--';
                            }
                            
                            console.log('isoutstationdoc2::' + this.doc2);
                            console.log('isoutstationdoc3::' + this.doc3);
                            console.log('isoutstationdoc4::' + this.doc4);
                            console.log('isoutstationdoc5::' + this.doc5);
                            console.log('isoutstationdoc6::' + this.doc6);
                            console.log('isoutstationdoc7::' + this.doc7);
                            console.log('isoutstationdoc8::' + this.doc8);
                            console.log('isoutstationdoc9::' + this.doc9);
                            
                            if (this.doc2 && this.doc4 && this.doc7) {
                                this.showapprovalbutton = true;
                            }
                        }
                    } else if (this.isoutstation == false) {
                        if (this.isKicker == false) {
                            if (this.typeofdoc == 'Invoice Hard Copy') {
                                this.doc1 = true;
                                this.typeofdoc = '--Select Type--';
                            } else if (this.typeofdoc == 'SCS Copy ( Sales Conformation Sheet )') {
                                this.doc2 = true;
                                this.typeofdoc = '--Select Type--';
                            } else if (this.typeofdoc == 'Sales IOM') {
                                this.doc3 = true;
                                this.typeofdoc = '--Select Type--';
                            } else if (this.typeofdoc == 'Booking Form') {
                                this.doc4 = true;
                                this.typeofdoc = '--Select Type--';
                            } else if (this.typeofdoc == 'Index 2') {
                                this.doc5 = true;
                                this.typeofdoc = '--Select Type--';
                            } else if (this.typeofdoc == 'SFDC Copy') {
                                this.doc6 = true;
                                this.typeofdoc = '--Select Type--';
                            }
                            
                            console.log('isoutstationfalsedoc2::' + this.doc2);
                            console.log('isoutstationfalsedoc3::' + this.doc3);
                            console.log('isoutstationfalsedoc4::' + this.doc4);
                            console.log('isoutstationfalsedoc5::' + this.doc5);
                            console.log('isoutstationfalsedoc6::' + this.doc6);
                            
                            if (this.doc2 && this.doc4) {
                                this.showapprovalbutton = true;
                            }
                        } else if (this.isKicker) {
                            this.showapprovalbutton = true;
                        }
                    }
                } 

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
                    // Use relative URL for file download - works in any environment
                    record.FileName = '/servlet.shepherd/document/download/' + record.ContentDocumentId;
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
        sendapproval({ comment: this.cmnt, recId: this.bId }).then(result => {
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
            // Use navigation service instead of hardcoded URL
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.bId,
                    objectApiName: 'CP_Brokerage__c',
                    actionName: 'view'
                }
            });

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
        // Use navigation service for back button
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.bId,
                objectApiName: 'CP_Brokerage__c',
                actionName: 'view'
            }
        });
    }
}