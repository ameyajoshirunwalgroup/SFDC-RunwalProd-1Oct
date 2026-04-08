import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getGreetingInitialData from '@salesforce/apex/GreetingCallController.getGreetingInitialData';
import processGreetingCall from '@salesforce/apex/GreetingCallController.processGreetingCall';
import { getPicklistValuesByRecordType, getObjectInfo } from 'lightning/uiObjectInfoApi';
import GREETING_OBJECT from '@salesforce/schema/Greeting_Call__c';


export default class GreetingCallChecklist extends LightningElement {
    // @api recordId;
    @track checklistData = [];
    @track isLoading = false;
    @track reasonValue = '';
    @track currentStatus = '';

    verifyOptions = [{ label: 'Yes', value: 'Yes' }, { label: 'No', value: 'No' }];
    

    get isReasonRequired() {
        return this.currentStatus === 'Hold' || this.currentStatus === 'Rejected';
    }

    _recordId;

    @api set recordId(value) {
        this._recordId = value;
        if (value) {
            console.log('recordId received:', value);
            this.loadData(); // Call loadData here instead of connectedCallback
        }
    }

    get recordId() {
        return this._recordId;
    }


    async loadData() {
        this.isLoading = true;
        console.log('Check recordId Inside Load Data--->', this.recordId);
        try {
            const result = await getGreetingInitialData({ oppId: this.recordId });
            console.log('resultData----->'+result);
            const apexFundingOptions = result.fundingOptions;
            this.mapFields(result.opportunityData, result.previousRemarksBlob, apexFundingOptions, result.loanRecordData, result.bankPreferenceOptions);
        } catch (error) {
            this.showToast('Error', error.body.message, 'error');
        } finally {
            this.isLoading = false;
        }
    }

    intresentInHomeLoan = [
        { label: 'Yes', value: 'Yes' },
        { label: 'No', value: 'No' }
    ];

    mapFields(bkg, blob, apexFundingOptions,loanRecordData,bankPreferenceOptions) {
        debugger;
        console.log('Print bkg',bkg[0]);
        console.log('Print bkg Name',bkg[0].Name);
        console.log('Print Blob', blob);
        // console.log('Print loanRecord', loanRecordData[0]);
        const firstLoan = loanRecordData && loanRecordData.length > 0 ? loanRecordData[0] : {};
        const fieldMapping = [
            { section: 'Customer Information', label: 'Customer Name', api: 'ApplicantName1', val: bkg[0].Name , type: 'text', remark: ''},
            { section: 'Customer Information', label: 'Email', api: 'EmailAddresses1', val: bkg[0].RW_Email__c? bkg[0].RW_Email__c: 'N/A' , type: 'input', remark: ''},
            { section: 'Customer Information', label: 'Mobile No.', api: 'MobileNo1', val: bkg[0].RW_Mobile_No__c , type: 'input', remark: ''},
            { section: 'Project Details', label: 'Project', api: 'ProjectName', val: bkg[0].Project_Name__c , type: 'text', remark: ''},
            { section: 'Project Details', label: 'Unit No', api: 'FlatNo', val: bkg[0].RW_Project_Unit__r.Name , type: 'text', remark: ''},
            { section: 'Financials', label: 'Agreement Value', api: 'AgreementValue', val: bkg[0].RW_Agreement_Value__c , type: 'text', remark: ''},
            { section: 'Financials', label: 'Blocking Amount', api: 'BolckingAmount', val: bkg[0].Blocking_Amount_Received__c , type: 'text', remark: ''},
            { section: 'Financials', label: 'Blocked Date', api: 'BlockDate', val: bkg[0].Blocked_Date__c , type: 'text', remark: ''},
            { section: 'Financials', label: 'Sales Manager', api: 'SalesManager', val: bkg[0].Sales_Manager_User__r? bkg[0].Sales_Manager_User__r.Name : 'N/A' , type: 'text', remark: ''},
            //{ label: 'Booking Amount', api: 'BookingAmount', val: 'N/A' , type: 'text', remark: ''},
            { section: 'Funding & Banking', label: 'Funding Type', api: 'FundingType', val: firstLoan?.Mode_of_funding__c ?? '' , type: 'picklist', options: apexFundingOptions, remark: ''},
            { section: 'Funding & Banking', label: 'Bank Preference 1', api: 'BankPreference1', val: firstLoan?.RW_Bank_Preference_1__c ?? '' , type: 'picklist', options: bankPreferenceOptions, remark: '', isBankPreference: true},
            { section: 'Funding & Banking', label: 'Bank Preference 2', api: 'BankPreference2', val: firstLoan?.RW_Bank_Preference_2__c ?? '' , type: 'picklist', options: bankPreferenceOptions, remark: '', isBankPreference: true},
            { section: 'Funding & Banking', label: 'Bank Preference 3', api: 'BankPreference3', val: firstLoan?.RW_Bank_Preference_3__c ?? '' , type: 'picklist', options: bankPreferenceOptions, remark: '', isBankPreference: true}
            //{ label: 'Intrested In Home Loan', api: 'HomeLoan', val: 'N/A' , type: 'picklist', options: this.intresentInHomeLoan, remark: ''}
            // Add all other fields here...
        ];

        // Parse Blob Logic (Pre-population)
        let parsedMap = {};
        if (blob) {
            blob.split('%  ,').forEach(item => {
                let [keyPart, valPart, label] = item.split(': ');
                if (keyPart && valPart) {
                    let cleanKey = keyPart.trim();
                    let [status, sysVal, remark] = valPart.split('~');
                    parsedMap[cleanKey] = { 
                        status: status ? status.trim() : 'No', 
                        val: sysVal ? sysVal.trim() : '',
                        remark: remark ? remark.replace('%', '').trim() : '' 
                    };
                }
            });
        }

        const currentFunding = parsedMap['FundingType']? parsedMap['FundingType']?.val : loanRecordData ? loanRecordData[0].Mode_of_funding__c : null;
        const isBankLoan = currentFunding === 'Bank Loan';

        this.checklistData = fieldMapping.map(f => ({
            // label: f.label,
            // fieldName: f.api,
            // status: parsedMap[f.api] ? parsedMap[f.api].status : 'Yes',
            // remark: parsedMap[f.api] ? parsedMap[f.api].remark : f.api
            ...f,
            val: f.val,
            fieldName: f.api,
            label: f.label,
            // Helper booleans for the HTML template
            isText: f.type === 'text',
            isPicklist: f.type === 'picklist',
            isInput: f.type === 'input',
            // ... existing status/remark logic ...
            isVisible: f.isBankPreference ? isBankLoan : true,
            status: parsedMap[f.api]?.status || 'No',
            remark: parsedMap[f.api]?.remark || f.remark
        }));
        console.log('Checklist---->',this.checklistData);

        
    }

    get sections() {
        const sectionMap = {};
        this.checklistData.forEach(field => {
            if (!sectionMap[field.section]) {
                sectionMap[field.section] = { label: field.section, fields: [] };
            }
            sectionMap[field.section].fields.push(field);
        });
        return Object.values(sectionMap);
    }

    handleStatusChange(e) { this.updateRow(e.target.name, 'status', e.detail.value); }
    handleRemarkChange(e) { this.updateRow(e.target.name, 'remark', e.detail.value); }
    handleReasonChange(e) { this.reasonValue = e.detail.value; }
    handleValueChange(e) {
        const fieldName = e.target.name;
        const newValue = e.detail.value;
        this.updateRow(fieldName, 'val', newValue); // Note: we update 'val' for system values

        if (fieldName === 'FundingType') {
            const isBankLoan = newValue === 'Bank Loan'; // Ensure this matches your picklist API value
            this.checklistData = this.checklistData.map(row => {
                if (row.isBankPreference) {
                    return { ...row, isVisible: isBankLoan };
                }
                return row;
            });
        }
    }

    updateRow(name, prop, val) {
        console.log('Check Name',name);
        console.log('Check Status',val);
        this.checklistData = this.checklistData.map(r => r.fieldName === name ? { ...r, [prop]: val } : r);
        console.log('Check Checklist Data---->',JSON.stringify(this.checklistData));
    }

    @api objectApiName = 'Greeting_Call__c'; // Ensure this matches your object

    @track allReasons = []; // To store all reason values + dependency info
    @track reasonOptions = []; // The filtered options shown in UI
    
    @wire(getObjectInfo, { objectApiName: GREETING_OBJECT })
    objectInfo;
    
    // Wire to get ALL picklist values for the Opportunity record type
    @wire(getPicklistValuesByRecordType, { 
        objectApiName: GREETING_OBJECT,
        recordTypeId: '$objectInfo.data.defaultRecordTypeId'
    })
    wiredPicklists({ error, data }) {
        if (data) {
            // 1. Find the Reason__c field data
            const reasonData = data.picklistFieldValues.Reason__c;
            this.allReasons = reasonData.values;
            
            // 2. Find the index/map of the Status__c (Controlling Field) values
            this.statusControllerValues = reasonData.controllerValues; 
            console.log('reasonData---->',reasonData);
        } else if (error) {
            console.error('Error fetching picklists', error);
        }
    }

    handleAccept() { 
        this.submit('Accepted'); 
        }
    handleHold() {
        this.currentStatus = 'Hold';
        this.isButtonsDisabled = true;
        this.filterReasons('Hold'); 
    }
    handleReject() { 
        this.currentStatus = 'Rejected';
        this.isButtonsDisabled = true;
        this.filterReasons('Rejected');
    }
    handleCancel() {
        this.currentStatus = '';       // Removes the reason section (isReasonRequired becomes false)
        this.isButtonsDisabled = false; // Re-enables the footer buttons
        this.reasonValue = '';         // Clear the selected reason
    }

    handleFinalSubmit() {
        if (this.isReasonRequired && !this.reasonValue) {
            this.showToast('Required', 'Please select a reason for ' + this.currentStatus, 'error');
            return;
        }
        this.submit(this.currentStatus);
    }

    filterReasons(selectedStatus) {
        // Find the numeric 'validFor' index for the selected status
        const controllerIndex = this.statusControllerValues[selectedStatus];

        // Filter the Reason values where 'validFor' array includes this index
        this.reasonOptions = this.allReasons
            .filter(opt => opt.validFor.includes(controllerIndex))
            .map(opt => ({ label: opt.label, value: opt.value }));
            
        this.reasonValue = ''; // Reset selection
    }

    validateAndSubmit(status) {
        if (!this.reasonValue) {
            this.showToast('Required', 'Please select a reason for ' + status, 'error');
            return;
        }
        this.submit(status);
    }

    submit(status) {
        const missingRemarks = this.checklistData.filter(row => row.isVisible &&
            row.status === 'No' && (!row.remark || row.remark.trim() === '')
        );

        if(status == 'Accepted'){
            const markedNo = this.checklistData.filter(row => row.isVisible &&
                row.status === 'No'
            );
            if(markedNo.length > 0){
                const fieldLabelYes = markedNo.map(r => r.label).join(', ');
                this.showToast('Error', `Greeting Call can not accepted when status is marked 'No': ${fieldLabelYes}`, 'error');
                return; // Stop execution
            }
        }

        if (missingRemarks.length > 0) {
            const fieldLabels = missingRemarks.map(r => r.label).join(', ');
            this.showToast('Error', `Please provide remarks for fields marked as 'No': ${fieldLabels}`, 'error');
            return; // Stop execution
        }

        this.isLoading = true;
        let blob = this.checklistData.map(r => `${r.fieldName}: ${r.status}~${r.val}~${r.remark}: ${r.label} % `).join(' , \n');

        let fieldValuesMap = {};
        this.checklistData.forEach(row => {
            // We only care about fields that exist on the Greeting_Call__c object
            // You can filter by type or api name here
            // if (row.type === 'picklist' || row.type === 'input') {
                fieldValuesMap[row.fieldName] = row.val;
            // }
        });

        processGreetingCall({
            oppId: this.recordId,
            status: status,
            reason: this.reasonValue,
            remarksBlob: blob,
            fieldValues: fieldValuesMap
        })
        .then(() => {
            this.showToast('Success', 'Greeting Call ' + status + 'ed successfully', 'success');
        })
        .catch(err => this.showToast('Error', err.body.message, 'error'))
        .finally(() => this.isLoading = false);
    }

    showToast(t, m, v) { this.dispatchEvent(new ShowToastEvent({ title: t, message: m, variant: v })); }
}