import { LightningElement, wire, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import isEmailExist from '@salesforce/apex/CommunityAuthController.isEmailExist';
import isDuplicateCPExist from '@salesforce/apex/CPRegisterationController.isDuplicateCPExist';
import selfregister from '@salesforce/apex/CPRegisterationController.selfregister';
// import createcdl from '@salesforce/apex/CPRegisterationController.createContentLink';
// import saveFiles from '@salesforce/apex/CPRegisterationController.saveFiles';
// import getFiles from '@salesforce/apex/CPRegisterationController.returnFiles';
import getTempCPData from '@salesforce/apex/CPRegisterationController.getTempCPData';
import getExistingCPData from '@salesforce/apex/CPRegisterationController.getExistingCPData';
import uploadFile from '@salesforce/apex/CPRegisterationController.uploadFile';
import fetchFiles from '@salesforce/apex/CPRegisterationController.fetchFiles';
import pickListValueDynamically from '@salesforce/apex/CPRegisterationController.pickListValueDynamically';
import getProject from '@salesforce/apex/CPRegisterationController.getProjectList';
import regiscomplete from '@salesforce/apex/CPRegisterationController.registrationcomplete';
import getapproverId from '@salesforce/apex/CPRegisterationController.getApprovers';
import elevateimg from '@salesforce/resourceUrl/Runwal_Elevate_Image';
// import DevelopersWorkedFor from "@salesforce/schema/Broker__c.Developers_Worked_For__c";
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { CurrentPageReference } from "lightning/navigation";
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
export default class CustomSelfRegister extends LightningElement {
    @track firstName = null;
    @track lastName = null;
    @track email = null;
    @track userName = null;
    @track password = null;
    @track confirmPassword = null;
    @track mobileno = null;
    @track companyname = null;
    // @track isreraapplicable = null;
    @track isccapplicable = null;
    @track istempcppresent = null;
    @track istempcpvalid = null;
    @track isgstapplicable = null;
    @track experience = null;
    @track aqb = null;
    @track isigstapplicable = null;
    @track salutation = null;
    @track middlename = null;
    @track countrycode = null;
    @track expertise = null;
    @track isnri = null;
    @track pos = null;
    @track showrerano = false;
    @track showccyes = false;
    @track showccno = false;
    @track showtempsec = null;
    @track teamsize = null;
    @track developerworked = null;
    @track houseno = null;
    @track street = null;
    @track street2 = null;
    @track street3 = null;
    @track country = null;
    @track state = null;
    @track city = null;
    @track pincode = null;
    @track showgst = false;
    @track errorCheck;
    @track optionsbankname;
    @track errorMessage;
    @track competencycertificate = false;
    @track isDeclarationFormReq = false;
    @track declarationform = false;
    @track chequescannedcopy = false;
    @track gstcertificate = false;
    @track docofcompany = false;
    @track trc = false;
    @track isaccepted = false;
    @track cancelledchequebankdetails = false;
    showUserName;
    @track showTermsAndConditions;
    @track showTermsAndConditionsLoading = false;
    @track infoTooltipDisplayData = {};
    @track requiredTooltipDisplayData = {};
    @track errorTooltipDisplayData = {};
    @track emailError;
    @track passwordError;
    contentdocIds = [];
    contentdocIdsprocessedArray = [];
    @api showsignup = false;
    @track firstform = true;
    @track secondform = false;
    @track firstformbutton = true;
    @api showUpload = false;
    @api showuploadmodal = false;
    @api shownextbutton;
    @api hideform;
    @track optionsteamsize;
    @track optionsproject;
    @track getDevelopersWorkedFor;
    @track showfirstnextbutton;
    local = false;
    NRI = false;
    selfregisterId;
    nextform = false;
    secondnextbuttonhide = false;
    value = '--Select Type--';
    docvalue = '';
    accno;
    branchcode;
    bankname;
    gstno;
    favname;
    panno;
    rerano;
    reraexpDate;
    ccexpDate;
    ccschexmDate;
    today = new Date().toISOString().split('T')[0];
    tempcpno;
    ifsccode;
    projectvalue;
    @api getSelfReg;
    showLoadingSpinner = false;
    @track fileNames = '';
    @track filesUploaded = [];
    documentIds = [];
    fileData
    @track optionspos;
    @track data;
    @track cvid;
    @track optionsexperience;
    @track columns = columns;
    lastnextbutton = false;
    aadharuploaded = false;
    rerauploaded = false;
    visauploaded = false;
    panuploaded = false;
    selfreg = {}
    lastmessage = false;
    error;
    valuenationality;
    uploadedFiles = [];
    ApproverIds = [];
    @track picklistVal;
    @track l_All_Types;
    @track TypeOptions;
    imagecon = elevateimg;
    levelValues;
    @track secondaryLevelValues;
    @track selectedLevelValue = '';
    @track picklistValuesObj;
    @track selectedSecondaryLevelValue = '';
    @track isindividual = false;
    @track brId;
    @track smId;
    @track docType;
    cpData = {

    };
    @track isUpdate = false;
    @track lstAllFiles;

    @wire(CurrentPageReference)
    getPageReference(pageRef) {
        if (pageRef) {
            const urlParams = pageRef.state;
            console.log('urlParams -> ', urlParams)
            console.log('Temp CP Id -> ', urlParams['tempcpid'])
            const brokerUniqueId = urlParams['tempcpid'];
            this.brId = urlParams['brId'];
            this.smId = urlParams['smId'];
            console.log('Sourcing Manager Id Present -> '+this.smId)
            if (this.smId != null) {
                this.cpData.Sourcing_Manager__c = this.smId;
            }
            console.log('brokerUniqueId -> ',brokerUniqueId);
            console.log('Existing Broker Id -> ', this.brId)
            if (brokerUniqueId != null) {
                this.fetchTempCPData(brokerUniqueId);
            }
            if (this.brId != null) {
                console.log('Inside Page Reference BrId')
                this.fetchExistingCPData(this.brId);
            }

        }
    }



    connectedCallback() {
        console.log('Is Update Case??-> ', this.isUpdate)
        // this.local = true;
        // this.firstform = false;
        // this.firstformbutton = false;
        // this.showuploadmodal = true;
        // this.secondnextbuttonhide = false;
        // this.nextform = false;
        // this.isccapplicable = 'Yes';
        // this.isgstapplicable = 'No';
        // this.isDeclarationFormReq = false;

        //this.showUpload = true;
        console.log('first form - > ', this.firstform)
        this.showUserName = false;
        this.hideform = true;
        this.shownextbutton = true;
        this.showfirstnextbutton = false;
        this.infoTooltipDisplayData.username = "tooltiptext usernameTooltiptext";
        this.infoTooltipDisplayData.password = "tooltiptext";

        this.requiredTooltipDisplayData.firstName = 'tooltiptext tooltipHide';
        this.requiredTooltipDisplayData.lastName = 'tooltiptext tooltipHide';
        this.requiredTooltipDisplayData.email = 'tooltiptext tooltipHide';
        this.requiredTooltipDisplayData.username = 'tooltiptext tooltipHide';
        this.requiredTooltipDisplayData.password = 'tooltiptext tooltipHide';
        this.requiredTooltipDisplayData.confirmPassword = 'tooltiptext tooltipHide';

        this.errorTooltipDisplayData.email = 'tooltiptext tooltipHide';
        this.errorTooltipDisplayData.password = 'tooltiptext tooltipHide';

        // console.log('Broker Id??-> ', this.brId)
        // if (this.brId != null) {
        //     this.getFilesData2(this.brId);
        // }

    }

    fetchTempCPData(brokerUniqueId) {
        getTempCPData({ brokerUniqueId: brokerUniqueId })
            .then((result) => {
                console.log('temp result -> ', result)
                if (result && result.length > 0) {
                    this.cpData = result[0];
                    this.istempcpvalid = true;
                    this.istempcppresent = 'Yes';
                    this.showtempsec = true;
                    console.log('Temp CP Data -> ', JSON.stringify(this.cpData));
                } else {
                    this.istempcpvalid = false;
                    this.istempcppresent = 'No';
                    this.showtempsec = false;
                    console.log('No Temp CP Data found.');
                    // this.showToast('Error', 'Please select a valid Temp CP record before submitting.','error');
                }
            })
            .catch((error) => {
                this.error = error;
                this.istempcpvalid = false;
                // window.alert("error in temp cp data:" + JSON.stringify(this.error));
                this.error = error;
                console.error('Raw error object:', error);

                // Apex errors (from server)
                if (error?.body?.message) {
                    console.error('Apex error message:', error.body.message);
                } else if (Array.isArray(error?.body)) {
                    error.body.forEach(err => console.error('Apex array error:', err.message));
                }
                // JS errors
                else if (error?.message) {
                    console.error('JS error message:', error.message);
                }
                // Network / HTTP errors
                else if (error?.statusText) {
                    console.error('HTTP error:', error.statusText);
                }
                else {
                    console.error('Unexpected error format:', JSON.stringify(error));
                }

                // Optional: show user friendly alert
                window.alert("Error in temp CP data: " + (error?.body?.message || error?.message || 'Unknown error'));
            });
    }

    fetchExistingCPData(brId) {
        getExistingCPData({ brId: brId })
            .then((result) => {
                console.log('brId -> ', brId)
                console.log('cp result -> ', result)
                if (result && result.length > 0) {
                    // this.cpData = result[0];
                    this.cpData = JSON.parse(JSON.stringify(result[0]));
                    this.isUpdate = true;
                    console.log('Is Update Case??-> ', this.isUpdate)
                    console.log('Broker Data -> ', JSON.stringify(this.cpData));
                    console.log('Developers worked for -> ', this.cpData.Developers_Worked_For__c)
                    console.log('Expertise -> ', this.cpData.Expertise__c)
                    console.log('this.cpData.RW_Broker_Number__c -> ', this.cpData.RW_Broker_Number__c)
                    console.log('this.cpData.RW_Is_GST_Applicable__c -> ', this.cpData.RW_Is_GST_Applicable__c)
                    if (this.expertise) {
                        this.expertise = this.cpData.Expertise__c.split(';');
                    }
                    if (this.developerworked) {
                        this.developerworked = this.cpData.Developers_Worked_For__c.split(';');
                    }
                    this.selectedLevelValue = this.cpData.Country__c;
                    this.selectedSecondaryLevelValue = this.cpData.State__c
                    if (this.cpData.RW_Broker_Number__c) {
                        this.istempcppresent = 'Yes';
                        this.showtempsec = true;
                    } else {
                        this.istempcppresent = 'No';
                        this.showtempsec = false;
                    }

                    this.isgstapplicable = this.cpData.RW_Is_GST_Applicable__c ? 'Yes' : 'No';
                    this.showgst = this.cpData.RW_Is_GST_Applicable__c;

                    if (this.cpData.RW_Is_CC_Applicable__c) {
                        this.isccapplicable = 'Yes';
                        this.showccyes = true;
                        this.showccno = false;
                        this.isDeclarationFormReq = false;
                    } else {
                        this.isccapplicable = 'No';
                        this.showccyes = false;
                        this.showccno = true;
                        this.isDeclarationFormReq = true;
                    }


                    if (this.cpData.Is_NRI_CP__c) {
                        this.NRI = true;
                        this.local = false;
                    } else {
                        this.local = true;
                        this.NRI = false;
                    }

                } else {
                    console.log('No Broker Data found.');
                }
            })
            .catch((error) => {
                this.error = error;
                console.error('Raw error object:', error);

                // Apex errors (from server)
                if (error?.body?.message) {
                    console.error('Apex error message:', error.body.message);
                } else if (Array.isArray(error?.body)) {
                    error.body.forEach(err => console.error('Apex array error:', err.message));
                }
                // JS errors
                else if (error?.message) {
                    console.error('JS error message:', error.message);
                }
                // Network / HTTP errors
                else if (error?.statusText) {
                    console.error('HTTP error:', error.statusText);
                }
                else {
                    console.error('Unexpected error format:', JSON.stringify(error));
                }

                // Optional: show user friendly alert
                window.alert("Error in existing CP data: " + (error?.body?.message || error?.message || 'Unknown error'));
            });

    }

    reloadDataFromUrl() {
        const urlParams = new URLSearchParams(window.location.search);
        // const recordId;
        // if(this.isUpdate){
        const recordId = urlParams.get('brId');
        // }else{
        // recordId = urlParams.get('ibrId');
        // }
        if (recordId) {
            this.fetchExistingCPData(recordId);
        }
    }


    get options() {
        return [
            { label: '--Select Type--', value: '--Select Type--' },
            { label: 'Individual', value: 'Individual' },
            { label: 'Company', value: 'Company' },
            { label: 'Partnership', value: 'Partnership' },
        ];
    }
    get optionsExpertise() {
        return [
            { label: 'Retail', value: 'Retail' },
            { label: 'Residential', value: 'Residential' },
            { label: 'Commercial', value: 'Commercial' },
            { label: 'Rentals', value: 'Rentals' },
        ];
    }
    /*get optionsdeveloperworked() {
        return [
            { label: 'Lodha Group', value: 'Lodha Group' },
            { label: 'K Raheja Corp', value: 'KP Raheja Corp' },//
            { label: 'Hiranandani Developers', value: 'Hiranandani Developers' },//
            { label: 'Adani Realty', value: 'Adani Realty' },//
            { label: 'L&T Realty', value: 'L&T Realty' },//
            { label: 'Godrej Properties', value: 'Godrej Properties' },
            { label: 'Dosti Group', value: 'Dosti Group' },
            { label: 'Wadhwa Group', value: 'Wadhwa Group' },
            { label: 'Puranik Builders', value: 'Puranik Builders' },//
            { label: 'Rustomjee', value: 'Rustomjee' },
            { label: 'Runwal Group', value: 'Runwal Group' },
            { label: 'Mahindra Lifespaces', value: 'Mahindra Lifespaces' },//
            { label: 'Piramal Realty', value: 'Piramal Realty' },
            { label: 'Kalpataru', value: 'Kalpataru' },
            { label: 'Sunteck Realty', value: 'Sunteck Realty' },//
            { label: 'Shapoorji Pallonji Real Estate', value: 'Shapoorji Pallonji Real Estate' },
            { label: 'Other', value: 'Other' }
        ];
    }*/

    get docoptionslocal() {
        if (this.isgstapplicable == 'Yes' && this.isccapplicable == 'Yes') {
            return [
                { label: '--Select Type--', value: '--Select Type--' },
                { label: 'PAN Card', value: 'PAN Card' },
                { label: 'RERA Certificate', value: 'RERA Certificate' },
                { label: 'Competency Certificate', value: 'Competency Certificate' },
                { label: 'Cheque Scanned Copy', value: 'Cheque Scanned Copy' },
                { label: 'GST Certificate', value: 'GST Certificate' }
            ];
        } else if (this.isgstapplicable == 'No' && this.isccapplicable == 'No') {
            return [
                { label: '--Select Type--', value: '--Select Type--' },
                { label: 'PAN Card', value: 'PAN Card' },
                { label: 'RERA Certificate', value: 'RERA Certificate' },
                { label: 'Cheque Scanned Copy', value: 'Cheque Scanned Copy' },
                { label: 'Declaration Form', value: 'Declaration Form' }
            ];
        } else if (this.isgstapplicable == 'Yes' && this.isccapplicable == 'No') {
            return [
                { label: '--Select Type--', value: '--Select Type--' },
                { label: 'PAN Card', value: 'PAN Card' },
                { label: 'RERA Certificate', value: 'RERA Certificate' },
                { label: 'Cheque Scanned Copy', value: 'Cheque Scanned Copy' },
                { label: 'GST Certificate', value: 'GST Certificate' },
                { label: 'Declaration Form', value: 'Declaration Form' }
            ];
        } else if (this.isgstapplicable == 'No' && this.isccapplicable == 'Yes') {
            return [
                { label: '--Select Type--', value: '--Select Type--' },
                { label: 'PAN Card', value: 'PAN Card' },
                { label: 'RERA Certificate', value: 'RERA Certificate' },
                { label: 'Competency Certificate', value: 'Competency Certificate' },
                { label: 'Cheque Scanned Copy', value: 'Cheque Scanned Copy' }
            ];
        }
        // if (this.isgstapplicable == 'Yes' && this.isreraapplicable == 'Yes' && this.isccapplicable == 'Yes') {
        //     return [
        //         { label: '--Select Type--', value: '--Select Type--' },
        //         { label: 'PAN Card', value: 'PAN Card' },
        //         { label: 'RERA Certificate', value: 'RERA Certificate' },
        //         { label: 'Compenteny Certificate', value: 'Compenteny Certificate' },
        //         { label: 'Cheque Scanned Copy', value: 'Cheque Scanned Copy' },
        //         { label: 'GST Certificate', value: 'GST Certificate' }
        //     ];
        // } else if (this.isgstapplicable == 'Yes' && this.isreraapplicable == 'Yes' && this.isccapplicable == 'No') {
        //     return [
        //         { label: '--Select Type--', value: '--Select Type--' },
        //         { label: 'PAN Card', value: 'PAN Card' },
        //         { label: 'RERA Certificate', value: 'RERA Certificate' },
        //         { label: 'Declaration Form', value: 'Declaration Form' },
        //         { label: 'Cheque Scanned Copy', value: 'Cheque Scanned Copy' },
        //         { label: 'GST Certificate', value: 'GST Certificate' }
        //     ];
        // }
        // else if (this.isgstapplicable == 'No' && this.isreraapplicable == 'No' && this.isccapplicable == 'Yes') {
        //     return [
        //         { label: '--Select Type--', value: '--Select Type--' },
        //         { label: 'PAN Card', value: 'PAN Card' },
        //         { label: 'Cheque Scanned Copy', value: 'Cheque Scanned Copy' },
        //         { label: 'Compenteny Certificate', value: 'Compenteny Certificate' }
        //     ];
        // }
        // else if (this.isgstapplicable == 'No' && this.isreraapplicable == 'No' && this.isccapplicable == 'No') {
        //     return [
        //         { label: '--Select Type--', value: '--Select Type--' },
        //         { label: 'PAN Card', value: 'PAN Card' },
        //         { label: 'Cheque Scanned Copy', value: 'Cheque Scanned Copy' },
        //         { label: 'Declaration Form', value: 'Declaration Form' }
        //     ];
        // }
        // else if (this.isgstapplicable == 'Yes' && this.isreraapplicable == 'No' && this.isccapplicable == 'Yes') {
        //     return [
        //         { label: '--Select Type--', value: '--Select Type--' },
        //         { label: 'PAN Card', value: 'PAN Card' },
        //         { label: 'Cheque Scanned Copy', value: 'Cheque Scanned Copy' },
        //         { label: 'GST Certificate', value: 'GST Certificate' },
        //         { label: 'Compenteny Certificate', value: 'Compenteny Certificate' }
        //     ];
        // }
        // else if (this.isgstapplicable == 'Yes' && this.isreraapplicable == 'No' && this.isccapplicable == 'No') {
        //     return [
        //         { label: '--Select Type--', value: '--Select Type--' },
        //         { label: 'PAN Card', value: 'PAN Card' },
        //         { label: 'Cheque Scanned Copy', value: 'Cheque Scanned Copy' },
        //         { label: 'GST Certificate', value: 'GST Certificate' },
        //         { label: 'Declaration Form', value: 'Declaration Form' }
        //     ];
        // }
        // else if (this.isgstapplicable == 'No' && this.isreraapplicable == 'Yes' && this.isccapplicable == 'Yes') {
        //     return [
        //         { label: '--Select Type--', value: '--Select Type--' },
        //         { label: 'PAN Card', value: 'PAN Card' },
        //         { label: 'Cheque Scanned Copy', value: 'Cheque Scanned Copy' },
        //         { label: 'RERA Certificate', value: 'RERA Certificate' },
        //         { label: 'Compenteny Certificate', value: 'Compenteny Certificate' }
        //     ];
        // }
        // else if (this.isgstapplicable == 'No' && this.isreraapplicable == 'Yes' && this.isccapplicable == 'No') {
        //     return [
        //         { label: '--Select Type--', value: '--Select Type--' },
        //         { label: 'PAN Card', value: 'PAN Card' },
        //         { label: 'Cheque Scanned Copy', value: 'Cheque Scanned Copy' },
        //         { label: 'RERA Certificate', value: 'RERA Certificate' },
        //         { label: 'Declaration Form', value: 'Declaration Form' }
        //     ];
        // }

    }
    get docoptionsNRI() {
        return [
            { label: '--Select Type--', value: '--Select Type--' },
            { label: 'Documents of the company', value: 'Documents of the company' },
            { label: 'TRC ( Tax Residency Certificate )', value: 'TRC ( Tax Residency Certificate )' },
            { label: 'Cancelled cheque or Bank Details', value: 'Cancelled cheque or Bank Details' }
        ];
    }
    get optionsnationality() {
        return [
            { label: 'Local', value: 'Local' },
            { label: 'NRI', value: 'NRI' },
        ];
    }

    get optionisnri() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }
    get optionisgst() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }
    get optionisigst() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }
    get optionisrera() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }
    get optionssalutation() {
        return [
            { label: 'Mr.', value: 'Mr.' },
            { label: 'Ms.', value: 'Ms.' },
            { label: 'Mrs.', value: 'Mrs.' },
            { label: 'Dr.', value: 'Dr.' },
            { label: 'Prof.', value: 'Prof.' },
        ];
    }

    //////////////////////

    // method to get master and dependent Picklist values based on record type
    @wire(getPicklistValuesByRecordType, { objectApiName: 'Broker__c', recordTypeId: '0125j0000006brmAAA' })
    newPicklistValues({ error, data }) {
        if (data) {
            this.error = null;
            this.picklistValuesObj = data.picklistFieldValues;
            //console.log('data returned' + JSON.stringify(data.picklistFieldValues));
            let levelValueslist = data.picklistFieldValues.Country_2__c.values;
            let levelValues = [];
            for (let i = 0; i < levelValueslist.length; i++) {
                levelValues.push({
                    label: levelValueslist[i].label,
                    value: levelValueslist[i].value
                });
            }
            this.levelValues = levelValues;
            console.log('Level values' + JSON.stringify(this.levelValues));
        } else if (error) {
            this.error = JSON.stringify(error);
            console.log('Error Country Picklist::' + JSON.stringify(error));
        }
    }
    handleLevelChange(event) {
        this.selectedLevelValue = event.detail.value;
        this.cpData = { ...this.cpData, Country__c: event.detail.value };
        if (this.selectedLevelValue) {
            let data = this.picklistValuesObj;
            let totalSecondaryLevelValues = data.State_2__c;
            let controllerValueIndex = totalSecondaryLevelValues.controllerValues[this.selectedLevelValue];
            let secondaryLevelPicklistValues = data.State_2__c.values;
            let secondaryLevelPicklists = [];
            secondaryLevelPicklistValues.forEach(key => {
                for (let i = 0; i < key.validFor.length; i++) {
                    if (controllerValueIndex == key.validFor[i]) {
                        secondaryLevelPicklists.push({
                            label: key.label,
                            value: key.value
                        });
                    }
                }
            })
            console.log('SecondaryLevelPicklists ' + JSON.stringify(secondaryLevelPicklists));
            console.log('SecondaryLevelPicklists length' + JSON.stringify(secondaryLevelPicklists.length));
            if (secondaryLevelPicklists && secondaryLevelPicklists.length > 0) {
                this.secondaryLevelValues = secondaryLevelPicklists;
            } else {
                this.secondaryLevelValues = [];
            }
            console.log('secondaryLevelValues' + JSON.stringify(this.secondaryLevelValues));
        }
    }

    handleSecondaryLevelChange(event) {
        this.selectedSecondaryLevelValue = event.detail.value;
        this.cpData = { ...this.cpData, State__c: event.target.value };
    }
    ///////////////
    handleChangepicklistnationality(event) {
        this.valuenationality = event.detail.value;
        this.cpData = { ...this.cpData, Broker_Type__c: event.detail.value };
        if (this.valuenationality == 'Local') {
            this.local = true;
        } else if (this.valuenationality == 'NRI') {
            this.NRI = true;
        }
    }
    handleChangepicklist(event) {
        this.value = event.detail.value;
        this.cpData = { ...this.cpData, Broker_Type__c: event.detail.value };
        if (this.cpData.Broker_Type__c == 'Individual') {
            this.isindividual = true;
        } else {
            this.isindividual = false;
        }
        this.cpData = { ...this.cpData, Individual_CP__c: this.isindividual };
    }
    handleChangeisnri(event) {
        this.isnri = event.detail.value;
        this.cpData = { ...this.cpData, Are_you_NRI__c: event.detail.value };
        if (this.isnri == 'Yes') {
            this.NRI = true;
            this.local = false;
            this.cpData = { ...this.cpData, Is_NRI_CP__c: true };
        } else if (this.isnri == 'No') {
            this.local = true;
            this.NRI = false;
            this.cpData = { ...this.cpData, Is_NRI_CP__c: false };
        }
    }
    handleChangeisgst(event) {
        this.isgstapplicable = event.detail.value;
        if (this.isgstapplicable == 'Yes') {
            this.showgst = true;
            this.cpData = { ...this.cpData, RW_Is_GST_Applicable__c: true };
        } else {
            this.showgst = false;
            this.cpData = { ...this.cpData, RW_Is_GST_Applicable__c: false };
        }
    }
    handleChangeisigst(event) {
        this.isigstapplicable = event.detail.value;
    }
    // handleChangeisrera(event) {
    //     this.isreraapplicable = event.detail.value;
    //     if (this.isreraapplicable == 'Yes') {
    //         this.showrerano = true;
    //     } else {
    //         this.showrerano = false;
    //     }
    // }

    handleChangeisCC(event) {
        this.isccapplicable = event.detail.value;
        if (this.isccapplicable == 'Yes') {
            this.showccyes = true;
            this.showccno = false;
            this.isDeclarationFormReq = false;
            this.cpData = { ...this.cpData, RW_Is_CC_Applicable__c: true };
        } else if (this.isccapplicable == 'No') {
            this.showccno = true;
            this.showccyes = false;
            this.isDeclarationFormReq = true;
            this.cpData = { ...this.cpData, RW_Is_CC_Applicable__c: false };
        }

    }

    handleChangeisTemp(event) {
        this.istempcppresent = event.detail.value;
        if (this.istempcppresent == 'Yes') {
            this.showtempsec = true;
            // this.fetchTempCPData(brokerUniqueId);
        } else {
            this.tempcpno = '';
            this.showtempsec = false;
            // this.cpData = { ...this.cpData, RW_Broker_Number__c: null };
            // this.istempcpvalid = true;
        }
    }

    handleTempNoChange(event) {
        // this.cpData = { ...this.cpData, RW_Broker_Number__c: event.detail.value };
        this.tempcpno = event.detail.value;
    }

    // get istempcpvalid(){
    //     if(this.istempcppresent == 'Yes' && this.cpData.RW_Broker_Number__c != null){
    //         return
    //     }
    // }


    handleChangepos(event) {
        this.cpData = { ...this.cpData, Place_of_Supply__c: event.detail.value };
        this.pos = event.detail.value;
    }
    handleChangepicklistdocLocal(event) {
        this.typeofdoclocal = event.detail.value;
    }
    handlestreet2(event) {
        this.cpData = { ...this.cpData, STR_SUPPL2__c: event.detail.value };
        this.street2 = event.detail.value;
    }
    handlestreet3(event) {
        this.cpData = { ...this.cpData, STR_SUPPL3__c: event.detail.value };
        this.street3 = event.detail.value;
    }
    handleChangepicklistdocNRI(event) {
        this.cpData = { ...this.cpData, NAME_FIRST__c: event.detail.value };
        this.typeofdocNRI = event.detail.value;
    }
    handleChangeexpertise(event) {
        this.cpData = { ...this.cpData, NAME_FIRST__c: event.detail.value };
        this.expertise = event.detail.value;
        console.log('expertise -> ', this.expertise)
    }
    handleChangeexperience(event) {
        this.cpData = { ...this.cpData, Experience__c: event.detail.value };
        this.experience = event.detail.value;
    }
    handleChangedeveloperworked(event) {
        this.cpData = { ...this.cpData, Developers_Worked_For__c: event.detail.value };
        this.developerworked = event.detail.value;
    }
    handleChangeesalutation(event) {
        this.cpData = { ...this.cpData, NAME_FIRST__c: event.detail.value };
        this.salutation = event.detail.value;
    }
    handleChangeecountrycode(event) {
        this.cpData = { ...this.cpData, Dialing_Country_Code1__c: event.detail.value };
        this.countrycode = event.detail.value;
    }
    handlehouseno(event) {
        this.cpData = { ...this.cpData, House_Flat_Company__c: event.detail.value };
        this.houseno = event.detail.value;
    }
    handlestate(event) {
        this.cpData = { ...this.cpData, NAME_FIRST__c: event.detail.value };
        this.state = event.detail.value;
    }
    handlestreet(event) {
        this.cpData = { ...this.cpData, STREET__c: event.detail.value };
        this.street = event.detail.value;
    }
    handlecity(event) {
        this.cpData = { ...this.cpData, City__c: event.detail.value };
        this.city = event.detail.value;
    }
    handlecountry(event) {
        this.cpData = { ...this.cpData, NAME_FIRST__c: event.detail.value };
        this.country = event.detail.value;
    }
    handlepincode(event) {
        this.cpData = { ...this.cpData, Pin_Code__c: event.detail.value };
        this.pincode = event.detail.value;
    }
    handlemiddlename(event) {
        this.cpData = { ...this.cpData, NAME_MIDDLE__c: event.detail.value };
        this.middlename = event.detail.value;
    }
    handleaqb(event) {
        this.aqb = event.detail.value;//Not Mapped with any field in CP
    }
    handlecompanyname(event) {
        this.cpData = { ...this.cpData, Company_Name_As_per_RERA__c: event.detail.value };
        this.companyname = event.detail.value;
    }
    handlemobilenoChange(event) {
        this.cpData = { ...this.cpData, RW_Mobile_No__c: event.detail.value };
        this.mobileno = event.detail.value;
    }
    handleChangeteamsize(event) {
        this.cpData = { ...this.cpData, Team_Size__c: event.detail.value };
        this.teamsize = event.detail.value;
    }
    handlebranchnameChange(event) {
        this.cpData = { ...this.cpData, Bank_Branch__c: event.detail.value };
        this.branchname = event.detail.value;
    }
    handleprojectChange(event) {
        this.cpData = { ...this.cpData, Project__c: event.detail.value };
        this.projectvalue = event.detail.value;
    }
    onEmailInvalid(event) {

        if (!event.target.validity.valid) {
            event.target.setCustomValidity('Enter a valid email address')
        }

    }

    onEmailInput(event) {

        event.target.setCustomValidity('')
    }

    onEmailClick(event) {

        let parent = event.target.parentElement.parentElement.parentElement;
        console.log('parent-', parent);
        parent.classList.remove('tooltipEmail');
    }

    onEmailBlur(event) {

        let parent = event.target.parentElement.parentElement.parentElement;
        console.log('parent-', parent);
        parent.classList.add('tooltipEmail');
    }



    @wire(pickListValueDynamically, { customObjInfo: { 'sobjectType': 'Broker__c' }, selectPicklistApi: 'Developers_Worked_For__c' })
    selectdevelopersworkedforValues({ error, data }) {
        if (data) {
            try {
                // this.l_All_Types = data;
                let options = [];

                for (var key in data) {
                    options.push({ label: data[key].custFldlabel, value: data[key].custFldvalue });
                }
                this.getDevelopersWorkedFor = options;

            } catch (error) {
                console.error('check error here', error);
            }
        } else if (error) {
            console.error('check error here', error);
        }

    }



    @wire(pickListValueDynamically, { customObjInfo: { 'sobjectType': 'Broker__c' }, selectPicklistApi: 'Dialing_Country_Code1__c' })
    selectcountrycodeValues({ error, data }) {

        if (data) {
            try {
                this.l_All_Types = data;
                let options = [];

                for (var key in data) {
                    // Here key will have index of list of records starting from 0,1,2,....
                    options.push({ label: data[key].custFldlabel, value: data[key].custFldvalue });

                    // Here Name and Id are fields from sObject list.
                }
                this.optionscountrycode = options;

            } catch (error) {
                console.error('check error here', error);
            }
        } else if (error) {
            console.error('check error here', error);
        }

    }

    @wire(pickListValueDynamically, { customObjInfo: { 'sobjectType': 'Broker__c' }, selectPicklistApi: 'Team_Size__c' })
    selectteamsizeValues({ error, data }) {

        if (data) {
            try {
                this.l_All_Types = data;
                let options = [];

                for (var key in data) {
                    // Here key will have index of list of records starting from 0,1,2,....
                    options.push({ label: data[key].custFldlabel, value: data[key].custFldvalue });

                    // Here Name and Id are fields from sObject list.
                }
                this.optionsteamsize = options;

            } catch (error) {
                console.error('check error here', error);
            }
        } else if (error) {
            console.error('check error here', error);
        }

    }

    @wire(pickListValueDynamically, { customObjInfo: { 'sobjectType': 'Broker__c' }, selectPicklistApi: 'Place_of_Supply__c' })
    selectposValues({ error, data }) {

        if (data) {
            try {
                this.l_All_Types = data;
                let options = [];

                for (var key in data) {
                    // Here key will have index of list of records starting from 0,1,2,....
                    options.push({ label: data[key].custFldlabel, value: data[key].custFldvalue });

                    // Here Name and Id are fields from sObject list.
                }
                this.optionspos = options;

            } catch (error) {
                console.error('check error here', error);
            }
        } else if (error) {
            console.error('check error here', error);
        }

    }

    @wire(pickListValueDynamically, { customObjInfo: { 'sobjectType': 'Broker__c' }, selectPicklistApi: 'Experience__c' })
    selectexperienceValues({ error, data }) {

        if (data) {
            try {
                this.l_All_Types = data;
                let options = [];

                for (var key in data) {
                    // Here key will have index of list of records starting from 0,1,2,....
                    options.push({ label: data[key].custFldlabel, value: data[key].custFldvalue });

                    // Here Name and Id are fields from sObject list.
                }
                this.optionsexperience = options;

            } catch (error) {
                console.error('check error here', error);
            }
        } else if (error) {
            console.error('check error here', error);
        }

    }

    @wire(pickListValueDynamically, { customObjInfo: { 'sobjectType': 'Broker__c' }, selectPicklistApi: 'Bank_Name__c' })
    selectbanknameValues({ error, data }) {

        if (data) {
            try {
                this.l_All_Types = data;
                let options = [];

                for (var key in data) {
                    // Here key will have index of list of records starting from 0,1,2,....
                    options.push({ label: data[key].custFldlabel, value: data[key].custFldvalue });

                    // Here Name and Id are fields from sObject list.
                }
                this.optionsbankname = options;

            } catch (error) {
                console.error('check error here', error);
            }
        } else if (error) {
            console.error('check error here', error);
        }

    }

    @wire(getProject)
    selectProjectValues({ error, data }) {

        if (data) {
            try {
                this.l_All_Types = data;
                let options = [];

                for (var key in data) {
                    // Here key will have index of list of records starting from 0,1,2,....
                    options.push({ label: data[key].custFldlabel, value: data[key].custFldvalue });

                    // Here Name and Id are fields from sObject list.
                }
                this.optionsproject = options;

            } catch (error) {
                console.error('check error here', error);
            }
        } else if (error) {
            console.error('check error here', error);
        }

    }

    handleRegister() {
        //alert('1')
        console.log('Is Temp cp present - > ' + this.istempcppresent)
        console.log('Temp cp number - > ' + this.tempcpno)
        console.log('Pan -> ', this.cpData.Broker_Pan_No__c)
        console.log('CP Data -> ', this.cpData)
        console.log('CP Data to Submit - > ', JSON.stringify(this.cpData));
        console.log('Br Id -> ', this.brId)
        if (!this.istempcpvalid && this.istempcppresent == 'Yes' && this.cpData.RW_Broker_Number__c != null) {
            this.showToast('Error!!', 'Please select a valid Temp CP record before submitting.', 'error');
            return;
        }
        if (this.checkfromvalid()) {
            this.showTermsAndConditionsLoading = true;

            isDuplicateCPExist({ bk: this.cpData })
                .then((result) => {

                    console.log('login result---' + result, typeof result);

                    if (result != null && result != undefined && result != '') {
                        this.showTermsAndConditionsLoading = false;
                        const duplicateexist = new ShowToastEvent({
                            title: 'Error!!',
                            message: result,
                            variant: 'error',
                        })
                        this.dispatchEvent(duplicateexist)

                    } else {
                        getapproverId({
                            pname: this.cpData.Project__c
                        }).then((result) => {
                            this.ApproverIds = JSON.parse(JSON.stringify(result));
                            console.log('Approvers--', JSON.stringify(this.ApproverIds));
                            console.log('Approvers-0-', JSON.stringify(this.ApproverIds[0]));
                            console.log('Approvers-1-', JSON.stringify(this.ApproverIds[1]));
                            console.log('this.cpData -> ', this.cpData)
                            let cpDataCopy = JSON.parse(JSON.stringify(this.cpData));
                            console.log('CP Data to Submit - > ', this.cpData);
                            console.log('CP Data to Submit - > ', JSON.stringify(this.cpData));
                            //this.selfreg.Experience__c= this.experience;
                            //this.selfreg.Dialing_Country_Code1__c = this.gstno;
                            //alert('2'+this.email+'::PAN::'+this.panno)  
                            selfregister({
                                sf: this.cpData,
                                isnri: this.NRI,
                                istempcppresent: this.istempcppresent,
                                isccapplicable: this.isccapplicable
                            })
                                .then((result) => {

                                    if (result) {
                                        //alert('3')     
                                        console.log('Result - >', result)
                                        this.selfregisterId = result;
                                        this.firstform = false;
                                        this.firstformbutton = false;
                                        this.showuploadmodal = true;
                                        this.secondnextbuttonhide = false;
                                        this.nextform = false;

                                        if (this.cpData.RW_Broker_Number__c) {
                                            this.istempcppresent = 'Yes';
                                            this.showtempsec = true;
                                        } else {
                                            this.istempcppresent = 'No';
                                            this.showtempsec = false;
                                        }

                                        this.isgstapplicable = this.cpData.RW_Is_GST_Applicable__c ? 'Yes' : 'No';
                                        this.showgst = this.cpData.RW_Is_GST_Applicable__c;

                                        if (this.cpData.RW_Is_CC_Applicable__c) {
                                            this.isccapplicable = 'Yes';
                                            this.showccyes = true;
                                            this.showccno = false;
                                            this.isDeclarationFormReq = false;
                                        } else {
                                            this.isccapplicable = 'No';
                                            this.showccyes = false;
                                            this.showccno = true;
                                            this.isDeclarationFormReq = true;
                                        }

                                        if (this.cpData.Is_NRI_CP__c) {
                                            this.NRI = true;
                                            this.local = false;
                                        } else {
                                            this.local = true;
                                            this.NRI = false;
                                        }

                                        this.getFilesData2(this.selfregisterId);

                                        // Assign record id in the URL.
                                        window.history.pushState({}, '', window.location.pathname + '?brId=' + this.selfregisterId);

                                        //createcdl({contentVersionId: this.cvid, recordId:this.selfregisterId})

                                        console.log('Temp cp number - >>>> ' + this.tempcpno)

                                    }

                                    this.showTermsAndConditionsLoading = false;
                                }).catch((error) => {
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

                                    this.showTermsAndConditionsLoading = false;


                                    if (error && error.body && error.body.message) {

                                        this.showTermsAndConditions = false;
                                        this.errorCheck = true;
                                        this.errorMessage = error.body.message;
                                        console.error('Full Error Message:', error.body.message);
                                        const evt = new ShowToastEvent({
                                            title: "Error!",
                                            message: error.body.message,
                                            variant: "error",
                                        });
                                        this.dispatchEvent(evt);
                                    }

                                });
                        }).catch((error) => {
                            this.error = error;
                            this.showTermsAndConditionsLoading = false;
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
                        });

                    }
                })
                .catch((error) => {
                    this.error = error;

                    if (error && error.body && error.body.message) {

                        console.log('error msg-', error.body.message);
                    }

                    this.showTermsAndConditionsLoading = false;

                });

        } else {
            const showSuccess = new ShowToastEvent({
                title: 'Error!',
                message: 'Required Fields are missing',
                variant: 'error',
            });
            this.dispatchEvent(showSuccess);
        }



    }

    handleTermsAndConditions(event) {

        this.showTermsAndConditions = true;
    }

    handleFirstNameChange(event) {
        this.cpData = { ...this.cpData, NAME_FIRST__c: event.target.value };
        this.firstName = event.target.value;
    }
    handlePanNoChange(event) {
        this.cpData = { ...this.cpData, Broker_Pan_No__c: event.target.value };
        this.panno = event.target.value;
    }
    handleLastNameChange(event) {
        this.cpData = { ...this.cpData, NAME_LAST__c: event.target.value };
        this.lastName = event.target.value;
    }
    handlefavnameChange(event) {
        this.cpData = { ...this.cpData, Cheque_DD_Favouring_Name__c: event.target.value };
        this.favname = event.target.value;
    }
    handlegstChange(event) {
        this.cpData = { ...this.cpData, RW_GST_Number__c: event.target.value };
        this.gstno = event.target.value;
    }
    handlebanknameChange(event) {
        this.cpData = { ...this.cpData, Bank_Name__c: event.target.value };
        this.bankname = event.target.value;
    }
    handlebankcodeChange(event) {
        this.cpData = { ...this.cpData, Branch_Code__c: event.target.value };
        this.branchcode = event.target.value;
    }
    handlebankaccnoChange(event) {
        this.cpData = { ...this.cpData, Account_Number__c: event.target.value };
        this.accno = event.target.value;
    }
    handlebankifscChange(event) {
        this.cpData = { ...this.cpData, IFSC_Code__c: event.target.value };
        this.ifsccode = event.target.value;
    }
    handleEmailChange(event) {
        if (event.target.value) {
            this.email = event.target.value;
            this.userName = this.email;
            this.cpData = { ...this.cpData, RW_Email__c: event.target.value };
        }
    }

    handlePasswordChange(event) {
        // this.cpData = { ...this.cpData, RW_GST_Number__c: event.target.value };
        this.password = event.target.value;
    }
    handleReraChange(event) {
        this.cpData = { ...this.cpData, RW_RERA_Registration_Number__c: event.target.value };
        this.rerano = event.target.value;
    }
    handleReraExpDateChange(event) {
        this.cpData = { ...this.cpData, RERA_Valid_till__c: event.target.value };
        this.reraexpDate = event.target.value;
        console.log('reraexpDate -> ', this.reraexpDate)
    }
    handleCCExpDateChange(event) {
        this.cpData = { ...this.cpData, CC_Valid_till__c: event.target.value };
        this.ccexpDate = event.target.value;
    }
    handleCCSchExmDateChange(event) {
        this.cpData = { ...this.cpData, CC_Scheduled_Exam_Date__c: event.target.value };
        this.ccschexmDate = event.target.value;
    }
    handleConfirmPasswordChange(event) {
        this.cpData = { ...this.cpData, RW_GST_Number__c: event.target.value };
        this.confirmPassword = event.target.value;
    }

    closeTermsAndConditions(event) {
        this.showTermsAndConditions = false;
    }
    closeUploadModal(event) {
        console.log('Inside close');
        this.showuploadmodal = false;
    }

    handleEmailHover(event) {
    }

    uploadbuttonclick(event) {

        this.showuploadmodal = true;
        this.showsignup = false;
    }

    hideModalBox(event) {
        this.showTermsAndConditions = false;
        this.showfirstnextbutton = true;
        this.isaccepted = true;
    }
    hanldeProgressValueChange(event) {
        this.showsignup = event.detail.sign;
        this.showUpload = event.detail.upload;
        console.log('showsignup => ' + this.showsignup);
        console.log('showUpload => ' + this.showUpload);
    }
    next(event) {
        console.log('Inside Next');
        this.errorCheck = false;
        this.errorMessage = null;

        this.errorTooltipDisplayData.email = 'tooltiptext tooltipHide';
        this.errorTooltipDisplayData.password = 'tooltiptext tooltipHide';

        if (!this.firstName) {
            console.log('Inside firstName');
            this.requiredTooltipDisplayData.firstName = 'tooltiptext tooltipShow';

        } else {

            this.requiredTooltipDisplayData.firstName = 'tooltiptext tooltipHide';
        }

        if (!this.lastName) {

            this.requiredTooltipDisplayData.lastName = 'tooltiptext tooltipShow';

        } else {

            this.requiredTooltipDisplayData.lastName = 'tooltiptext tooltipHide';
        }

        if (!this.email) {

            this.requiredTooltipDisplayData.email = 'tooltiptext tooltipShow';

        } else {

            this.requiredTooltipDisplayData.email = 'tooltiptext tooltipHide';
        }


        if (!this.userName) {

            this.requiredTooltipDisplayData.username = 'tooltiptext tooltipShow';
            this.infoTooltipDisplayData.username = "tooltiptext usernameTooltiptext tooltipHide";

        } else {

            this.requiredTooltipDisplayData.username = 'tooltiptext tooltipHide';
        }



        if (!this.password) {

            this.requiredTooltipDisplayData.password = 'tooltiptext tooltipShow';
            this.infoTooltipDisplayData.password = "tooltiptext tooltipHide";

        } else {

            this.requiredTooltipDisplayData.password = 'tooltiptext tooltipHide';
        }

        if (!this.confirmPassword) {

            this.requiredTooltipDisplayData.confirmPassword = 'tooltiptext tooltipShow';

        } else {

            this.requiredTooltipDisplayData.confirmPassword = 'tooltiptext tooltipHide';
        }



        if (this.firstName && this.lastName && this.email && this.userName && this.password && this.confirmPassword) {

            //this.showTermsAndConditionsLoading = true;

            if (this.password != this.confirmPassword) {
                console.log('Inside passwordcheck');
                this.infoTooltipDisplayData.password = "tooltiptext tooltipHide";
                this.passwordError = 'Password did not match. Please Make sure both the passwords match.';
                this.errorTooltipDisplayData.password = 'tooltiptext tooltipShow tooltipError';

                event.preventDefault();

                this.showTermsAndConditionsLoading = false;

                return;
            }

            let emailCheck = /^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(this.email);

            console.log('emailCheck--', emailCheck);

            if (emailCheck == null || emailCheck == undefined || emailCheck == false) {

                this.showTermsAndConditionsLoading = false;
                console.log('inside email check');

                this.emailError = 'Please enter a valid email address';
                this.errorTooltipDisplayData.email = 'tooltiptext tooltipShow tooltipError';

                return;
            }

            let passwordCheck = /^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$/.test(this.password);

            if (passwordCheck == null || passwordCheck == undefined || passwordCheck == false) {

                this.showTermsAndConditionsLoading = false;

                this.infoTooltipDisplayData.password = "tooltiptext tooltipHide";
                this.passwordError = 'Password must be Minimum eight characters, at least one letter, one number and one special character.';
                this.errorTooltipDisplayData.password = 'tooltiptext tooltipShow tooltipError';

                return;
            }

            event.preventDefault();

            isEmailExist({ username: this.userName })
                .then((result) => {

                    console.log('login result---' + result, typeof result);

                    if (result != null && result != undefined && result == true) {

                        this.emailError = 'Your username already exists somewhere on the  Salesforce Ecosystem.';
                        this.errorTooltipDisplayData.email = 'tooltiptext tooltipShow tooltipError';

                        this.showTermsAndConditionsLoading = false;

                    } else {
                        /*selfregister().then(res => { 
                            this.selfregisterId = res; 
                            console.log('selfregisterId => '+this.selfregisterId)
                        }
                        ).catch(err => console.error('err:'+JSON.stringify(err)));*/
                        this.shownextbutton = false;
                        this.hideform = false;
                        this.nextform = true;
                        this.secondnextbuttonhide = true
                    }
                })
                .catch((error) => {
                    this.error = error;

                    if (error && error.body && error.body.message) {

                        console.log('error msg-', error.body.message);
                    }

                    this.showTermsAndConditionsLoading = false;

                });

        }


    }
    // secondformnext() {
    //     //if(this.checkfromvalid()){
    //     this.handleRegister();
    //     this.showuploadmodal = true;
    //     this.secondnextbuttonhide = false;
    //     this.nextform = false;
    //     //}

    // }
    backbutton() {
        this.firstform = true;
        this.firstformbutton = true;
        this.showuploadmodal = false;
        this.secondnextbuttonhide = true;
        this.nextform = true;
        this.reloadDataFromUrl();
        console.log('Br Id -> ', this.brId)
    }
    completeregister() {
        this.showTermsAndConditionsLoading = true;
        regiscomplete({ CPId: this.selfregisterId })
            .then((result) => {
                this.showTermsAndConditionsLoading = false;
            })
            .catch((error) => {
                this.error = error;

                console.log('error-', JSON.stringify(this.error));
                this.showTermsAndConditionsLoading = false;


                if (error && error.body && error.body.message) {

                    this.showTermsAndConditions = false;
                    this.errorCheck = true;
                    this.errorMessage = error.body.message;
                    const evt = new ShowToastEvent({
                        title: "Error!",
                        message: error.body.message,
                        variant: "error",
                        mode: 'sticky'
                    });
                    this.dispatchEvent(evt);
                }

            });
    }
    lastnextbuttonfuc() {
        // if (!this.isUpdate) {
            if (this.local) {
                if (this.isgstapplicable == 'Yes' && this.isccapplicable == 'Yes') {
                    if (this.chequescannedcopy == false) {
                        this.errortoast('Cheque Scanned Copy')
                    } else if (this.panuploaded == false) {
                        this.errortoast('PAN Card')
                    } else if (this.rerauploaded == false) {
                        this.errortoast('RERA Certificate')
                    } else if (this.gstcertificate == false) {
                        this.errortoast('GST Certificate')
                    } else if (this.competencycertificate == false) {
                        this.errortoast('Competency Certificate')
                    }
                } else if (this.isgstapplicable == 'Yes' && this.isccapplicable == 'No') {
                    if (this.chequescannedcopy == false) {
                        this.errortoast('Cheque Scanned Copy')
                    } else if (this.panuploaded == false) {
                        this.errortoast('PAN Card')
                    } else if (this.rerauploaded == false) {
                        this.errortoast('RERA Certificate')
                    } else if (this.gstcertificate == false) {
                        this.errortoast('GST Certificate')
                    } else if (this.declarationform == false) {
                        this.errortoast('Declaration Form')
                    }
                }
                else if (this.isgstapplicable == 'No' && this.isccapplicable == 'Yes') {
                    if (this.chequescannedcopy == false) {
                        this.errortoast('Cheque Scanned Copy')
                    } else if (this.panuploaded == false) {
                        this.errortoast('PAN Card')
                    } else if (this.rerauploaded == false) {
                        this.errortoast('RERA Certificate')
                    } else if (this.competencycertificate == false) {
                        this.errortoast('Competency Certificate')
                    }
                } else if (this.isgstapplicable == 'No' && this.isccapplicable == 'No') {
                    if (this.chequescannedcopy == false) {
                        this.errortoast('Cheque Scanned Copy')
                    } else if (this.panuploaded == false) {
                        this.errortoast('PAN Card')
                    } else if (this.rerauploaded == false) {
                        this.errortoast('RERA Certificate')
                    } else if (this.declarationform == false) {
                        this.errortoast('Declaration Form')
                    }
                }

                // if (this.isgstapplicable == 'Yes' && this.isreraapplicable == 'Yes' && this.isccapplicable == 'Yes') {
                //     if (this.chequescannedcopy == false) {
                //         this.errortoast('Cheque Scanned Copy')
                //     } else if (this.panuploaded == false) {
                //         this.errortoast('PAN Card')
                //     } else if (this.rerauploaded == false) {
                //         this.errortoast('RERA Certificate')
                //     } else if (this.gstcertificate == false) {
                //         this.errortoast('GST Certificate')
                //     } else if (this.competencycertificate == false) {
                //         this.errortoast('Competency Certificate')
                //     }
                // } else if (this.isgstapplicable == 'Yes' && this.isreraapplicable == 'Yes' && this.isccapplicable == 'No') {
                //     if (this.chequescannedcopy == false) {
                //         this.errortoast('Cheque Scanned Copy')
                //     } else if (this.panuploaded == false) {
                //         this.errortoast('PAN Card')
                //     } else if (this.rerauploaded == false) {
                //         this.errortoast('RERA Certificate')
                //     } else if (this.gstcertificate == false) {
                //         this.errortoast('GST Certificate')
                //     } else if (this.declarationform == false) {
                //         this.errortoast('Declaration Form')
                //     }
                // }
                // else if (this.isgstapplicable == 'No' && this.isreraapplicable == 'No' && this.isccapplicable == 'Yes') {
                //     if (this.chequescannedcopy == false) {
                //         this.errortoast('Cheque Scanned Copy')
                //     } else if (this.panuploaded == false) {
                //         this.errortoast('PAN Card')
                //     } else if (this.competencycertificate == false) {
                //         this.errortoast('Competency Certificate')
                //     }
                // } else if (this.isgstapplicable == 'No' && this.isreraapplicable == 'No' && this.isccapplicable == 'No') {
                //     if (this.chequescannedcopy == false) {
                //         this.errortoast('Cheque Scanned Copy')
                //     } else if (this.panuploaded == false) {
                //         this.errortoast('PAN Card')
                //     } else if (this.declarationform == false) {
                //         this.errortoast('Declaration Form')
                //     }
                // }
                // else if (this.isgstapplicable == 'Yes' && this.isreraapplicable == 'No' && this.isccapplicable == 'Yes') {
                //     if (this.chequescannedcopy == false) {
                //         this.errortoast('Cheque Scanned Copy')
                //     } else if (this.panuploaded == false) {
                //         this.errortoast('PAN Card')
                //     } else if (this.gstcertificate == false) {
                //         this.errortoast('GST Certificate')
                //     } else if (this.competencycertificate == false) {
                //         this.errortoast('Competency Certificate')
                //     }
                // } else if (this.isgstapplicable == 'Yes' && this.isreraapplicable == 'No' && this.isccapplicable == 'No') {
                //     if (this.chequescannedcopy == false) {
                //         this.errortoast('Cheque Scanned Copy')
                //     } else if (this.panuploaded == false) {
                //         this.errortoast('PAN Card')
                //     } else if (this.gstcertificate == false) {
                //         this.errortoast('GST Certificate')
                //     } else if (this.declarationform == false) {
                //         this.errortoast('Declaration Form')
                //     }
                // }
                // else if (this.isgstapplicable == 'No' && this.isreraapplicable == 'Yes' && this.isccapplicable == 'Yes') {
                //     if (this.chequescannedcopy == false) {
                //         this.errortoast('Cheque Scanned Copy')
                //     } else if (this.panuploaded == false) {
                //         this.errortoast('PAN Card')
                //     } else if (this.rerauploaded == false) {
                //         this.errortoast('RERA Certificate')
                //     } else if (this.competencycertificate == false) {
                //         this.errortoast('Competency Certificate')
                //     }
                // } else if (this.isgstapplicable == 'No' && this.isreraapplicable == 'Yes' && this.isccapplicable == 'No') {
                //     if (this.chequescannedcopy == false) {
                //         this.errortoast('Cheque Scanned Copy')
                //     } else if (this.panuploaded == false) {
                //         this.errortoast('PAN Card')
                //     } else if (this.rerauploaded == false) {
                //         this.errortoast('RERA Certificate')
                //     } else if (this.declarationform == false) {
                //         this.errortoast('Declaration Form')
                //     }
                // }
                console.log('this.chequescannedcopy::' + this.chequescannedcopy)
                console.log('this.panuploaded::' + this.panuploaded)
                console.log('this.rerauploaded::' + this.rerauploaded)
                console.log('this.gstcertificate::' + this.gstcertificate)
                console.log('this.competencycertificate::' + this.competencycertificate)
                console.log('this.declarationform::' + this.declarationform)
                if (this.chequescannedcopy && this.panuploaded && this.rerauploaded && this.gstcertificate && this.competencycertificate && this.isgstapplicable == 'Yes' /*&& this.isreraapplicable == 'Yes'*/ && this.isccapplicable == 'Yes') {
                    this.lastmessage = true;
                    this.showuploadmodal = false;
                    console.log('1')
                    this.completeregister();
                } else if (this.chequescannedcopy && this.panuploaded && this.competencycertificate && this.isgstapplicable == 'No' /*&& this.isreraapplicable == 'No' */ && this.isccapplicable == 'Yes') {
                    this.lastmessage = true;
                    this.showuploadmodal = false;
                    console.log('2')
                    this.completeregister();
                } else if (this.chequescannedcopy && this.panuploaded && this.competencycertificate && this.rerauploaded && this.isgstapplicable == 'No' /*&& this.isreraapplicable == 'Yes'*/ && this.isccapplicable == 'Yes') {
                    this.lastmessage = true;
                    this.showuploadmodal = false;
                    console.log('3')
                    this.completeregister();
                } else if (this.chequescannedcopy && this.panuploaded && this.competencycertificate && this.gstcertificate && this.isgstapplicable == 'Yes' /*&& this.isreraapplicable == 'No'*/ && this.isccapplicable == 'Yes') {
                    this.lastmessage = true;
                    this.showuploadmodal = false;
                    console.log('4')
                    this.completeregister();
                } else if (this.chequescannedcopy && this.panuploaded && this.declarationform && this.rerauploaded && this.gstcertificate && this.isgstapplicable == 'Yes' /*&& this.isreraapplicable == 'Yes'*/ && this.isccapplicable == 'No') {
                    this.lastmessage = true;
                    this.showuploadmodal = false;
                    console.log('5')
                    this.completeregister();
                } else if (this.chequescannedcopy && this.panuploaded && this.declarationform && this.isgstapplicable == 'No' /*&& this.isreraapplicable == 'No' */ && this.isccapplicable == 'No') {
                    this.lastmessage = true;
                    this.showuploadmodal = false;
                    console.log('6')
                    this.completeregister();
                } else if (this.chequescannedcopy && this.panuploaded && this.declarationform && this.rerauploaded && this.isgstapplicable == 'No' /*&& this.isreraapplicable == 'Yes'*/ && this.isccapplicable == 'No') {
                    this.lastmessage = true;
                    this.showuploadmodal = false;
                    console.log('7')
                    this.completeregister();
                } else if (this.chequescannedcopy && this.panuploaded && this.declarationform && this.gstcertificate && this.isgstapplicable == 'Yes' /*&& this.isreraapplicable == 'No' */ && this.isccapplicable == 'No') {
                    this.lastmessage = true;
                    this.showuploadmodal = false;
                    console.log('8')
                    this.completeregister();
                }
            } else {
                console.log('this.trc::' + this.trc);
                console.log('this.docofcompany::' + this.docofcompany);
                console.log('cancelledchequebankdetails::' + this.cancelledchequebankdetails);
                if (this.trc == false) {
                    this.errortoast('Tax Residency Certificate')
                } else if (this.docofcompany == false) {
                    this.errortoast('Documents of the company')
                } else if (this.cancelledchequebankdetails == false) {
                    this.errortoast('Cancelled cheque or Bank Details')
                }
                if (this.trc && this.docofcompany && this.cancelledchequebankdetails) {
                    this.lastmessage = true;
                    this.showuploadmodal = false;
                    this.completeregister();
                }
            }
        // } else {
        //     this.lastmessage = true;
        //     this.showuploadmodal = false;
        //     console.log('1')
        //     this.completeregister();
        // }


    }
    get acceptedFormats() {
        return ['.pdf', '.png', '.jpg', '.jpeg'];
    }
    checkfromvalid() {
        let isvalid = true;
        this.template.querySelectorAll('lightning-input').forEach(element => {
            console.log('checkValidity' + element.checkValidity());
            console.log('reportValidity' + element.reportValidity());
            if (!element.checkValidity()) {
                element.reportValidity();
                isvalid = false;
            }
        });
        this.template.querySelectorAll('lightning-combobox').forEach(element => {
            console.log('checkValidity' + element.checkValidity());
            console.log('reportValidity' + element.reportValidity());
            if (!element.checkValidity()) {
                element.reportValidity();
                isvalid = false;
            }
        });
        this.template.querySelectorAll('lightning-radio-group').forEach(element => {
            console.log('checkValidity' + element.checkValidity());
            console.log('reportValidity' + element.reportValidity());
            if (!element.checkValidity()) {
                element.reportValidity();
                isvalid = false;
            }
        });
        return isvalid;
    }

    /*openfileUpload2(event) {
        console.log('this.typeofdoclocal' + this.typeofdoclocal);
        console.log('First files::' + this.selfregisterId);
        const uploadedFiles = event.detail.files;
        console.log('second files::' + uploadedFiles.documentId);
        console.log('third files::' + JSON.stringify(uploadedFiles));
        console.log('Local Doc type -> ', this.typeofdoclocal);
        console.log('Nri Doc type -> ', this.typeofdocNRI);
        const docType = (this.local === true) ? this.typeofdoclocal : this.typeofdocNRI;
        console.log('docType -> ', docType);





        createcdl({ uploadedfile: uploadedFiles, recId: 'a019I00000N4O3L', docType: docType })
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


                if (this.local) {
                    if (this.typeofdoclocal == 'Cheque Scanned Copy') {
                        this.chequescannedcopy = true;
                        this.typeofdoclocal = '--Select Type--';
                        //this.successtoast(this.typeofdoclocal);
                    } else if (this.typeofdoclocal == 'PAN Card') {
                        this.panuploaded = true;
                        this.typeofdoclocal = '--Select Type--';
                        //this.successtoast(this.typeofdoclocal);
                    } else if (this.typeofdoclocal == 'RERA Certificate') {
                        this.rerauploaded = true;
                        this.typeofdoclocal = '--Select Type--';
                        //this.successtoast(this.typeofdoclocal);
                    }
                    else if (this.typeofdoclocal == 'GST Certificate') {
                        this.gstcertificate = true;
                        this.typeofdoclocal = '--Select Type--';
                        //this.successtoast(this.typeofdoclocal);
                    }
                    else if (this.typeofdoclocal == 'Competency Certificate') {
                        this.competencycertificate = true;
                        this.typeofdoclocal = '--Select Type--';
                    }
                    else if (this.typeofdoclocal == 'Declaration Form') {
                        this.declarationform = true;
                        this.typeofdoclocal = '--Select Type--';
                    }
                } else {
                    if (this.typeofdocNRI == 'TRC ( Tax Residency Certificate )') {
                        this.trc = true;
                        this.typeofdocNRI = '--Select Type--';
                        //this.successtoast(this.typeofdoclocal);
                    } else if (this.typeofdocNRI == 'Documents of the company') {
                        this.docofcompany = true;
                        this.typeofdocNRI = '--Select Type--';
                        //this.successtoast(this.typeofdoclocal);
                    } else if (this.typeofdocNRI == 'Cancelled cheque or Bank Details') {
                        this.cancelledchequebankdetails = true;
                        this.typeofdocNRI = '--Select Type--';
                        //this.successtoast(this.typeofdoclocal);
                    }
                    console.log('this.trc::' + this.trc);
                    console.log('this.docofcompany::' + this.docofcompany);
                    console.log('cancelledchequebankdetails::' + this.cancelledchequebankdetails);
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


    }*/


    async openfileUpload2(event) {
        this.showLoadingSpinner = true;
        try {
            const files = event.target.files;
            const recordId = this.isUpdate ? this.brId : this.selfregisterId;

            for (const file of files) {
                const base64 = await this.readFileAsBase64(file);
                this.docType = this.local ? this.typeofdoclocal : this.typeofdocNRI;
                console.log('doc type -> ', this.docType)
                console.log('doc local -> ', this.local)
                console.log('doc type local-> ', this.typeofdoclocal)
                console.log('doc type NRI-> ', this.typeofdocNRI)
                await uploadFile({
                    base64: base64,
                    filename: file.name,
                    recordId: recordId,
                    docType: this.docType
                });

                if (this.local) {
                    switch (this.typeofdoclocal) {
                        case 'Cheque Scanned Copy':
                            this.chequescannedcopy = true;
                            break;
                        case 'PAN Card':
                            this.panuploaded = true;
                            break;
                        case 'RERA Certificate':
                            this.rerauploaded = true;
                            break;
                        case 'GST Certificate':
                            this.gstcertificate = true;
                            break;
                        case 'Competency Certificate':
                            this.competencycertificate = true;
                            break;
                        case 'Declaration Form':
                            this.declarationform = true;
                            break;
                    }
                    this.typeofdoclocal = '--Select Type--';
                } else {
                    switch (this.typeofdocNRI) {
                        case 'TRC ( Tax Residency Certificate )':
                            this.trc = true;
                            break;
                        case 'Documents of the company':
                            this.docofcompany = true;
                            break;
                        case 'Cancelled cheque or Bank Details':
                            this.cancelledchequebankdetails = true;
                            break;
                    }
                    this.typeofdocNRI = '--Select Type--';
                }
            }

            await this.getFilesData2(recordId);

            this.showToast('Success!!', `${this.docType} uploaded successfully.`, 'success');
        } catch (error) {
            console.error('Error in uploadFile -> ', error);
            this.showToast(
                'Error!!',
                error?.body?.message || 'An error occurred while uploading the file.',
                'error'
            );
        }finally {
            this.showLoadingSpinner = false; 
        }
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


    getFileBase64(contentDocumentId, fileName) {
        return new Promise((resolve, reject) => {
            const actionUrl = `/sfc/servlet.shepherd/document/download/${contentDocumentId}`;
            fetch(actionUrl)
                .then(response => response.blob())
                .then(blob => {
                    const reader = new FileReader();
                    reader.onloadend = () => {
                        let base64 = reader.result.split(',')[1];
                        resolve(base64);
                    };
                    reader.onerror = reject;
                    reader.readAsDataURL(blob);
                })
                .catch(error => reject(error));
        });
    }

    async getFilesData2(brokerUniqueId) {
        const result = await fetchFiles({ recordId: brokerUniqueId });
        this.lstAllFiles = result.map(row => ({
            Id: row.ContentDocumentId,
            Title: row.ContentDocument.Title,
            FileType: row.ContentDocument.FileType,
            CreatedDate: row.ContentDocument.CreatedDate,
            LastModifiedDate: row.ContentDocument.LastModifiedDate,
            fileUrl: `/sfc/servlet.shepherd/document/download/${row.ContentDocumentId}`
        }));
        console.log('lstAllFiles -> ', JSON.stringify(this.lstAllFiles));
        console.log('docoptionsNRI -> ', JSON.stringify(this.docoptionsNRI))
        console.log('docoptionslocal -> ', JSON.stringify(this.docoptionslocal))

        this.lstAllFiles.forEach(file => {
            if (file.Title) {
                console.log('Checking file -> ', file.Title);

                if (file.Title.includes('Cheque Scanned Copy')) {
                    this.chequescannedcopy = true;
                    console.log('✅ Cheque Scanned Copy uploaded');
                } else if (file.Title.includes('PAN Card')) {
                    this.panuploaded = true;
                    console.log('✅ PAN Card uploaded');
                } else if (file.Title.includes('RERA Certificate')) {
                    this.rerauploaded = true;
                    console.log('✅ RERA Certificate uploaded');
                } else if (file.Title.includes('GST Certificate')) {
                    this.gstcertificate = true;
                    console.log('✅ GST Certificate uploaded');
                } else if (file.Title.includes('Competency Certificate')) {
                    this.competencycertificate = true;
                    console.log('✅ Competency Certificate uploaded');
                } else if (file.Title.includes('Declaration Form')) {
                    this.declarationform = true;
                    console.log('✅ Declaration Form uploaded');
                } else if (file.Title.includes('TRC ( Tax Residency Certificate )')) {
                    this.trc = true;
                    console.log('✅ TRC uploaded');
                } else if (file.Title.includes('Documents of the company')) {
                    this.docofcompany = true;
                    console.log('✅ Documents of the company uploaded');
                } else if (file.Title.includes('Cancelled cheque or Bank Details')) {
                    this.cancelledchequebankdetails = true;
                    console.log('✅ Cancelled cheque or Bank Details uploaded');
                } else {
                    console.log('⚠️ No match found for file:', file.Title);
                }
            }
        });

    }





    openfileUpload(event) {
        let files = event.target.files;
        //uploadedFiles.forEach(element => documentIds.push(element.documentId));
        if (files.length > 0) {
            let filesName = '';

            for (let i = 0; i < files.length; i++) {
                let file = files[i];
                console.log('files::' + JSON.stringify(event.target.files[i]));
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
    /*handleClick() {
        this.showLoadingSpinner = true;
        saveFiles({ filesToInsert: this.filesUploaded, recId: this.selfregisterId })
            .then(data => {
                this.showLoadingSpinner = false;
                const showSuccess = new ShowToastEvent({
                    title: 'Success!!',
                    message: this.fileNames + ' files uploaded successfully.',
                    variant: 'Success',
                });
                this.dispatchEvent(showSuccess);
                this.cvid = data
                this.getFilesData(data);
                this.fileNames = undefined;
            })
            .catch(error => {
                console.error('error:' + JSON.stringify(error))
                const showError = new ShowToastEvent({
                    title: 'Error!!',
                    message: 'An Error occur while uploading the file.',
                    variant: 'error',
                });
                this.dispatchEvent(showError);
            });
    }*/

    toast(title) {
        const toastEvent = new ShowToastEvent({
            title,
            variant: "success"
        })
        this.dispatchEvent(toastEvent)
    }

    successtoast(msg) {
        const toastEvent = new ShowToastEvent({
            title: 'Success file!!',
            message: msg + 'uploaded successfully.',
            variant: 'success',
        })
        this.dispatchEvent(toastEvent)
    }
    errortoast(msg) {
        const toastEvent = new ShowToastEvent({
            title: 'Error!!',
            message: 'Please Upload ' + msg,
            variant: 'error',
        })
        this.dispatchEvent(toastEvent)
    }

    /*getFilesData(lstIds) {
        console.log('Broker Id -> ', this.brId)
        getFiles({ lstFileIds: lstIds, recId: this.brId })
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
    }*/
    //////////////////////////////////////////

    handleSave() {
    }

    closePopup() {
        this.showModal = false;
        this.dispatchEvent(new CustomEvent('close'));
    }

}