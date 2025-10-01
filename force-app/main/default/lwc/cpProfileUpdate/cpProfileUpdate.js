import { LightningElement, wire, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import isEmailExist from '@salesforce/apex/CommunityAuthController.isEmailExist';
import selfregister from '@salesforce/apex/CPBookingController.selfregister';
import createcdl from '@salesforce/apex/CPBookingController.createContentLink';
import saveFiles from '@salesforce/apex/CPBookingController.saveFiles';
import getFiles from '@salesforce/apex/CPBookingController.returnFiles';
import pickListValueDynamically from '@salesforce/apex/CPBookingController.pickListValueDynamically';
import getProject from '@salesforce/apex/CPBookingController.getProjectList';
import getapproverId from '@salesforce/apex/CPBookingController.getApprovers';
import elevateimg from '@salesforce/resourceUrl/Runwal_Elevate_Image';
import getCPDetails from '@salesforce/apex/CPBookingController.getCPDetails';
import updatecp from '@salesforce/apex/CPProfileUpdate.updateChannelPartner';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
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
export default class CustomSelfRegister extends NavigationMixin(LightningElement) {
    @track firstName = null;
    @track lastName = null;
    @track email = null;
    @track userName = null;
    @track password = null;
    @track confirmPassword = null;
    @track mobileno = null;
    @track companyname = null;
    @track isreraapplicable = 'Yes';
    @track isgstapplicable = 'Yes';
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
    @track firstformbutton = true;
    @api showUpload = false;
    @api showuploadmodal = false;
    @api shownextbutton;
    @api hideform;
    @track optionsteamsize;
    @track optionsproject;
    @track showfirstnextbutton;
    local = false;
    NRI = false;
    selfregisterId;
    nextform = false;
    secondnextbuttonhide = false;
    value = 'Individual';
    docvalue = '';
    accno;
    brachcode;
    bankname;
    gstno;
    favname;
    panno;
    rerano;
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
    @track existingrera = false;
    @track existinggst = false;
    @track nodocupload = false;
    @track userId = null;
    @track nochange = null;
    @track existingrerano = false;
    @track existinggstno = false;
    @track existingfirstname = false;
    @track existinglastname = false;
    @track namechange = false;
    connectedCallback() {
        //this.showUpload = true;
        this.showUserName = false;
        this.hideform = true;
        this.shownextbutton = true;
        this.showfirstnextbutton = false;
        //this.nochange = false;
        this.existingrerano = false;
        this.existinggstno = false;
        this.existingfirstname = false;
        this.existinglastname = false;
        this.namechange = false;
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
        getCPDetails().then((result) => {
            console.log('GetCPDetails--', JSON.stringify(result));
            //this.selfreg.Name = this.firstName + ' ' + this.lastName;
            this.firstName = result[0].NAME_FIRST__c;
            this.existingfirstname = result[0].NAME_FIRST__c;
            this.middlename = result[0].NAME_MIDDLE__c;
            this.lastName = result[0].NAME_LAST__c;
            this.existinglastname = result[0].NAME_LAST__c;
            this.salutation = result[0].TITLE__c;
            this.email = result[0].RW_Email__c;
            //this.selfreg.Broker_Type__c= this.value;
            this.panno = result[0].Broker_Pan_No__c;
            this.rerano = result[0].RW_RERA_Registration_Number__c;
            this.accno = result[0].Account_Number__c;
            this.favname = result[0].Cheque_DD_Favouring_Name__c;
            this.ifsccode = result[0].IFSC_Code__c;
            this.brachcode = result[0].Branch_Code__c;
            this.bankname = result[0].Bank_Name__c;
            this.branchname = result[0].Bank_Branch__c;
            this.mobileno = result[0].RW_Mobile_No__c;
            this.gstno = result[0].RW_GST_Number__c;
            this.houseno = result[0].House_Flat_Company__c;
            this.companyname = result[0].Company_Name_As_per_RERA__c;
            this.street = result[0].STREET__c;
            this.street = result[0].STR_SUPPL1__c;
            this.street2 = result[0].STR_SUPPL2__c;
            this.street3 = result[0].STR_SUPPL3__c;
            this.city = result[0].City__c;
            this.selectedSecondaryLevelValue = result[0].State__c;
            this.selectedLevelValue = result[0].Country__c;
            this.pincode = result[0].Pin_Code__c;
            this.value = result[0].Broker_Type__c;
            this.experience = result[0].Experience__c;
            this.countrycode = result[0].Dialing_Country_Code1__c;
            //this.expertise = result[0].Expertise__c;
            this.pos = result[0].Place_of_Supply__c;
            this.teamsize = result[0].Team_Size__c;
            //this.developerworked = result[0].Developers_Worked_For__c;
            this.projectvalue = result[0].Project__c;
            this.rerano = result[0].RW_RERA_Registration_Number__c;
            this.gstno = result[0].RW_GST_Number__c;
            this.existingrerano = result[0].RW_RERA_Registration_Number__c;
            this.existinggstno = result[0].RW_GST_Number__c;
            this.value = result[0].Broker_Type__c;
            this.salutation = result[0].TITLE__c;
            this.selectedLevelValue = result[0].Country__c;
            this.city = result[0].City__c;
            this.selectedSecondaryLevelValue = result[0].State__c;
            this.selfregisterId = result[0].Id;
            if (result[0].Is_NRI_CP__c) {
                this.isnri = 'Yes';
                this.NRI = true;
                this.local = false;
            } else {
                this.isnri = 'No';
                this.NRI = false;
                this.local = true;
            }
            if (result[0].RW_Is_GST_Applicable__c) {
                this.isgstapplicable = 'Yes';
                this.showgst = true;
                this.existinggst = true;
                console.log('isgstapplicable--' + this.isgstapplicable);
            } else {
                this.isgstapplicable = 'No';
                this.showgst = false;
                this.existinggst = false;
            }
            if (result[0].Unregistered_Channel_Partner__c) {
                this.isreraapplicable = 'No';
                this.showrerano = false;
                this.existingrera = false
            } else {
                this.isreraapplicable = 'Yes';
                this.showrerano = true;
                this.existingrera = true;
            }
            if (result[0].IS_IGST_Applicable__c) {
                this.isigstapplicable = 'Yes';
            } else {
                this.isigstapplicable = 'No';
            }
            console.log('gstno::' + this.gstno);
            console.log('rerano::' + this.rerano);
            console.log('this.existingrerano:::' + this.existingrerano);
            console.log('this.existinggstno::' + this.existinggstno);
            if (this.existinggst && this.existingrera) {
                this.nodocupload = true;
                console.log('nodocupload::' + this.nodocupload);
            }

            /*if(this.rerano == this.existingrerano && this.gstno == this.existinggstno){
                this.nochange = true;
                console.log('nochange::'+this.nochange);
            }*/

        }).catch((error) => {
            this.error = error;
            this.showTermsAndConditionsLoading = false;
            console.log('error-', JSON.stringify(this.error));
        });
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
    get optionsdeveloperworked() {
        return [
            { label: 'Hiranandani', value: 'Hiranandani' },
            { label: 'Godrej Properties', value: 'Godrej Properties' },
            { label: 'Lodha Group', value: 'Lodha Group' },
            { label: 'Piramal Realty', value: 'Piramal Realty' },
            { label: 'Kanakia', value: 'Kanakia' },
            { label: 'Mahindra Lifespaces developers', value: 'Mahindra Lifespaces developers' },
            { label: 'Kalpataru', value: 'Kalpataru' },
            { label: 'Runwal Group', value: 'Runwal Group' },
            { label: 'Dosti Group', value: 'Dosti Group' },
            { label: 'Wadhwa Group', value: 'Wadhwa Group' },
            { label: 'Rustomjee', value: 'Rustomjee' },
            { label: 'Puraniks builders', value: 'Puraniks builders' },
            { label: 'Adhiraj construction', value: 'Adhiraj construction' },
            { label: 'L & T Realty', value: 'L & T Realty' },
            { label: 'Paradise group', value: 'Paradise group' },
            { label: 'Chandak', value: 'Chandak' },
            { label: 'Other', value: 'Other' }
        ];
    }
    get docoptionslocal() {
        if (this.existinggst == false && this.existingrera == false) {
            return [
                { label: '--Select Type--', value: '--Select Type--' },
                { label: 'RERA Certificate', value: 'RERA Certificate' },
                { label: 'GST Certificate', value: 'GST Certificate' }
            ];
        } else if (this.existinggst == false && this.existingrera) {
            return [
                { label: '--Select Type--', value: '--Select Type--' },
                { label: 'GST Certificate', value: 'GST Certificate' }
            ];
        } else if (this.existinggst && this.existingrera == false) {
            return [
                { label: '--Select Type--', value: '--Select Type--' },
                { label: 'RERA Certificate', value: 'RERA Certificate' }
            ];
        }

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
    }
    ///////////////
    handleChangepicklistnationality(event) {
        this.valuenationality = event.detail.value;
        if (this.valuenationality == 'Local') {
            this.local = true;
        } else if (this.valuenationality == 'NRI') {
            this.NRI = true;
        }
    }
    handleChangepicklist(event) {
        this.value = event.detail.value;
    }
    handleChangeisnri(event) {
        this.isnri = event.detail.value;
        if (this.isnri == 'Yes') {
            this.NRI = true;
            this.local = false;
        } else if (this.isnri == 'No') {
            this.local = true;
            this.NRI = false;
        }
    }
    handleChangeisgst(event) {
        if (this.existinggst == false) {
            this.isgstapplicable = event.detail.value;
            if (this.isgstapplicable == 'Yes') {
                this.showgst = true;
            } else {
                this.showgst = false;
            }
        }
    }
    handleChangeisigst(event) {
        this.isigstapplicable = event.detail.value;
    }
    handleChangeisrera(event) {
        if (this.existingrera == false) {
            this.isreraapplicable = event.detail.value;
            if (this.isreraapplicable == 'Yes') {
                this.showrerano = true;
            } else {
                this.showrerano = false;
            }
        }
    }
    handleChangepos(event) {
        this.pos = event.detail.value;
    }
    handleChangepicklistdocLocal(event) {
        this.typeofdoclocal = event.detail.value;
    }
    handlestreet2(event) {
        this.street2 = event.detail.value;
    }
    handlestreet3(event) {
        this.street3 = event.detail.value;
    }
    handleChangepicklistdocNRI(event) {
        this.typeofdocNRI = event.detail.value;
    }
    handleChangeexpertise(event) {
        this.expertise = event.detail.value;
    }
    handleChangeexperience(event) {
        this.experience = event.detail.value;
    }
    handleChangedeveloperworked(event) {
        this.developerworked = event.detail.value;
    }
    handleChangeecountrycode(event) {
        this.countrycode = event.detail.value;
    }
    handleChangeesalutation(event) {
        this.salutation = event.detail.value;
    }
    handleChangeecountrycode(event) {
        this.countrycode = event.detail.value;
    }
    handleChangeesalutation(event) {
        this.salutation = event.detail.value;
    }
    handlehouseno(event) {
        this.houseno = event.detail.value;
    }
    handlestate(event) {
        this.state = event.detail.value;
    }
    handlestreet(event) {
        this.street = event.detail.value;
    }
    handlecity(event) {
        this.city = event.detail.value;
    }
    handlecountry(event) {
        this.country = event.detail.value;
    }
    handlepincode(event) {
        this.pincode = event.detail.value;
    }
    handlemiddlename(event) {
        this.middlename = event.detail.value;
    }
    handleaqb(event) {
        this.aqb = event.detail.value;
    }
    handlecompanyname(event) {
        this.companyname = event.detail.value;
    }
    handlemobilenoChange(event) {
        this.mobileno = event.detail.value;
    }
    handleChangeteamsize(event) {
        this.teamsize = event.detail.value;
    }
    handlebranchnameChange(event) {
        this.branchname = event.detail.value;
    }
    handleprojectChange(event) {
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

        if (this.checkfromvalid()) {
            if (this.nodocupload || this.nochange || this.NRI || this.namechange) {
                this.updatechannelpartner();
            } else {
                this.firstform = false;
                this.firstformbutton = false;
                this.showuploadmodal = true;
                this.secondnextbuttonhide = false;
                this.nextform = false;
            }







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

        this.firstName = event.target.value;
        if (this.nodocupload && this.nochange == false) {
            if (this.firstName != this.existingfirstname) {
                this.namechange = true;
                console.log('namechange::' + this.namechange);
            }
        } else if (this.nochange == undefined && this.nodocupload == false) {
            if (this.firstName != this.existingfirstname) {
                this.namechange = true;
                console.log('namechange::' + this.namechange);
            }
        } else if (this.nodocupload == false && this.nochange == false) {
            if (this.firstName != this.existingfirstname) {
                this.namechange = false;
                console.log('namechange::' + this.namechange);
            }
        }

    }
    handlePanNoChange(event) {

        this.panno = event.target.value;
    }
    handleLastNameChange(event) {

        this.lastName = event.target.value;
        console.log('this.nodocupload::' + this.nodocupload);
        console.log('this.nochange::' + this.nochange);
        if (this.nodocupload && this.nochange == false) {
            if (this.lastName != this.existinglastname) {
                this.namechange = true;
                console.log('namechange::' + this.namechange);
            }else{
                this.namechange = true;
            }
        } else if (this.nochange == undefined && this.nodocupload == false) {
            if (this.lastName != this.existinglastname) {
                this.namechange = true;
                console.log('namechange::' + this.namechange);
            }else{
                this.namechange = true;
            }
        } else if (this.nodocupload == false && this.nochange == false) {
            if (this.lastName != this.existinglastname) {
                this.namechange = false;
                console.log('namechange::' + this.namechange);
            }else{
                this.namechange = false;
            }
        }
    }
    handlefavnameChange(event) {

        this.favname = event.target.value;
    }
    handlegstChange(event) {
        this.nochange = false;
        this.gstno = event.target.value;
        if (this.rerano == this.existingrerano && this.gstno == this.existinggstno) {
            this.nochange = true;
            console.log('nochange::' + this.nochange);
        }
    }
    handlebanknameChange(event) {

        this.bankname = event.target.value;
    }
    handlebankcodeChange(event) {

        this.brachcode = event.target.value;
    }
    handlebankaccnoChange(event) {

        this.accno = event.target.value;
    }
    handlebankifscChange(event) {

        this.ifsccode = event.target.value;
    }
    handleEmailChange(event) {

        if (event.target.value) {

            this.email = event.target.value;
            this.userName = this.email;

        } else {

            this.email = event.target.value;
            this.userName = this.email;
        }
    }

    handlePasswordChange(event) {

        this.password = event.target.value;
    }
    handleReraChange(event) {
        this.nochange = false;
        this.rerano = event.target.value;
        if (this.rerano == this.existingrerano && this.gstno == this.existinggstno) {
            this.nochange = true;
            console.log('nochange::' + this.nochange);
        }

    }
    handleConfirmPasswordChange(event) {

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
    secondformnext() {
        //if(this.checkfromvalid()){
        this.handleRegister();
        this.showuploadmodal = true;
        this.secondnextbuttonhide = false;
        this.nextform = false;
        //}

    }

    lastnextbuttonfuc() {
        if (this.local) {

            if (this.existinggst == false && this.existingrera == false) {
                if (this.rerauploaded == false) {
                    this.errortoast('RERA Certificate')
                } else if (this.gstcertificate == false) {
                    this.errortoast('GST Certificate')
                }
            } else if (this.existinggst == false && this.existingrera) {
                if (this.gstcertificate == false) {
                    this.errortoast('GST Certificate')
                }
            } else if (this.existinggst && this.existingrera == false) {
                if (this.rerauploaded == false) {
                    this.errortoast('RERA Certificate')
                }
            }

            console.log('this.rerauploaded::' + this.rerauploaded)
            console.log('this.gstcertificate::' + this.gstcertificate)
            if (this.rerauploaded && this.gstcertificate && this.existinggst == false && this.existingrera == false) {
                //this.lastmessage = true;
                //this.showuploadmodal = false;
                console.log('1')
                this.updatechannelpartner();
            } else if (this.existinggst && this.existingrera) {
                console.log('2')
                this.updatechannelpartner();
            } else if (this.rerauploaded && this.existinggst && this.existingrera == false) {
                console.log('3')
                this.updatechannelpartner();
            } else if (this.gstcertificate && this.existinggst == false && this.existingrera) {
                console.log('4')
                this.updatechannelpartner();
            }
        } else {
            if (this.trc == false) {
                this.errortoast('Tax Residency Certificate')
            } else if (this.docofcompany == false) {
                this.errortoast('Documents of the company')
            } else if (this.cancelledchequebankdetails == false) {
                this.errortoast('Cancelled cheque or Bank Details')
            }
            if (this.trc && this.docofcompany && this.cancelledchequebankdetails) {
                //this.lastmessage = true;
                //this.showuploadmodal = false;
                this.updatechannelpartner();
            }
        }


    }
    updatechannelpartner() {
        this.showTermsAndConditionsLoading = true;
        this.selfreg.Name = this.firstName + ' ' + this.lastName;
        this.selfreg.NAME_FIRST__c = this.firstName;
        this.selfreg.NAME_MIDDLE__c = this.middlename;
        this.selfreg.NAME_LAST__c = this.lastName;
        this.selfreg.TITLE__c = this.salutation;
        //this.selfreg.Broker_Type__c= this.value;
        this.selfreg.RW_RERA_Registration_Number__c = this.rerano;
        this.selfreg.Account_Number__c = this.accno;
        this.selfreg.Cheque_DD_Favouring_Name__c = this.favname;
        this.selfreg.IFSC_Code__c = this.ifsccode;
        this.selfreg.Branch_Code__c = this.brachcode;
        this.selfreg.Bank_Name__c = this.bankname;
        this.selfreg.Bank_Branch__c = this.branchname;
        this.selfreg.RW_Mobile_No__c = this.mobileno;
        this.selfreg.RW_GST_Number__c = this.gstno;
        this.selfreg.House_Flat_Company__c = this.houseno;
        this.selfreg.Company_Name_As_per_RERA__c = this.companyname;
        this.selfreg.STREET__c = this.street;
        this.selfreg.STR_SUPPL1__c = this.street;
        this.selfreg.STR_SUPPL2__c = this.street2;
        this.selfreg.STR_SUPPL3__c = this.street3;
        this.selfreg.City__c = this.city;
        this.selfreg.State__c = this.selectedSecondaryLevelValue;
        this.selfreg.Country__c = this.selectedLevelValue;
        this.selfreg.Pin_Code__c = this.pincode;
        this.selfreg.Broker_Type__c = this.value;
        this.selfreg.Experience__c = this.experience;
        this.selfreg.Dialing_Country_Code1__c = this.countrycode;
        this.selfreg.Expertise__c = this.expertise;
        this.selfreg.Place_of_Supply__c = this.pos;
        this.selfreg.Team_Size__c = this.teamsize;
        this.selfreg.Developers_Worked_For__c = this.developerworked;
        if (this.isnri == 'Yes') {
            this.selfreg.Is_NRI_CP__c = true;
        } else {
            this.selfreg.Is_NRI_CP__c = false;
        }
        if (this.existinggst == false) {
            if (this.isgstapplicable == 'Yes') {
                this.selfreg.RW_Is_GST_Applicable__c = true;
            } else {
                this.selfreg.RW_Is_GST_Applicable__c = false;
            }
        }
        if (this.existingrera == false) {
            if (this.isreraapplicable == 'Yes') {
                this.selfreg.Unregistered_Channel_Partner__c = false;
            } else {
                this.selfreg.Unregistered_Channel_Partner__c = true;
            }
        }

        if (this.isigstapplicable == 'Yes') {
            this.selfreg.IS_IGST_Applicable__c = 'Yes';
        } else {
            this.selfreg.IS_IGST_Applicable__c = 'No';
        }
        if (this.value == 'Individual') {
            this.selfreg.Individual_CP__c = true;
        } else {
            this.selfreg.Individual_CP__c = false;
        }

        //this.selfreg.Experience__c= this.experience;
        //this.selfreg.Dialing_Country_Code1__c = this.gstno;
        //alert('2'+this.email+'::PAN::'+this.panno)  
        updatecp({
            sf: this.selfreg
        })
            .then((result) => {

                if (result) {
                    //alert('3')          
                    this.selfregisterId = result;
                    this[NavigationMixin.Navigate]({
                        type: 'standard__webPage',
                        attributes: {
                            url: 'https://cpdesk.runwalgroup.in/s/accountdetails'
                        }
                    });
                    //createcdl({contentVersionId: this.cvid, recordId:this.selfregisterId})
                    const showSuccess = new ShowToastEvent({
                        title: 'Success!',
                        message: 'Profile has been updated successfully',
                        variant: 'Success',
                    });
                    this.dispatchEvent(showSuccess);

                }

                this.showTermsAndConditionsLoading = false;
            }).catch((error) => {
                this.error = error;

                console.log('error-', JSON.stringify(this.error));
                console.log('error2' + this.error);
                this.showTermsAndConditionsLoading = false;


                if (error && error.body && error.body.message) {

                    this.showTermsAndConditions = false;
                    this.errorCheck = true;
                    this.errorMessage = error.body.message;
                    const evt = new ShowToastEvent({
                        title: "Error!",
                        message: error.body.message,
                        variant: "error",
                    });
                    this.dispatchEvent(evt);
                }

            });
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
                const showErrorvalid = new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Required Fields are missing',
                    variant: 'error',
                });
                this.dispatchEvent(showErrorvalid);
            }
        });
        return isvalid;
    }
    openfileUpload2(event) {
        console.log('this.typeofdoclocal' + this.typeofdoclocal);
        console.log('First files::' + this.selfregisterId);
        const uploadedFiles = event.detail.files;
        console.log('second files::' + uploadedFiles.documentId);
        console.log('third files::' + JSON.stringify(uploadedFiles));
        createcdl({ uploadedfile: uploadedFiles, recId: this.selfregisterId })
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
                    if (this.typeofdoclocal == 'RERA Certificate') {
                        this.rerauploaded = true;
                        this.typeofdoclocal = '--Select Type--';
                        //this.successtoast(this.typeofdoclocal);
                    } else if (this.typeofdoclocal == 'GST Certificate') {
                        this.gstcertificate = true;
                        this.typeofdoclocal = '--Select Type--';
                        //this.successtoast(this.typeofdoclocal);
                    }
                } else {
                    if (this.typeofdoclocal == 'TRC ( Tax Residency Certificate )') {
                        this.trc = true;
                        this.typeofdocNRI = '--Select Type--';
                        //this.successtoast(this.typeofdoclocal);
                    } else if (this.typeofdoclocal == 'Documents of the company') {
                        this.docofcompany = true;
                        this.typeofdocNRI = '--Select Type--';
                        //this.successtoast(this.typeofdoclocal);
                    } else if (this.typeofdoclocal == 'Cancelled cheque or Bank Details') {
                        this.cancelledchequebankdetails = true;
                        this.typeofdocNRI = '--Select Type--';
                        //this.successtoast(this.typeofdoclocal);
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
    handleClick() {
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
    }

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
    //////////////////////////////////////////



}