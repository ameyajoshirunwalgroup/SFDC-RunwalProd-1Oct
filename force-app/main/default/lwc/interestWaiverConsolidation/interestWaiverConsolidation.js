import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { RefreshEvent } from 'lightning/refresh';
import getDemandRecords from '@salesforce/apex/interestWaiverConsolidation.getDemandRecords';
import createAndSubmitWaivers from '@salesforce/apex/interestWaiverConsolidation.createAndSubmitWaivers';
import interestWaiverAmtLimit from '@salesforce/apex/interestWaiverConsolidation.interestWaiverAmtLimit';
import { CloseActionScreenEvent } from 'lightning/actions';
import uploadMultipleIOMFiles from '@salesforce/apex/interestWaiverConsolidation.uploadMultipleIOMFiles';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import WAIVER_OBJECT from '@salesforce/schema/Interest_Waiver__c';
import WaiverReason_Picklist from '@salesforce/schema/Interest_Waiver__c.Waiver_Reason__c';
import WaiverSubReason_Picklist from '@salesforce/schema/Interest_Waiver__c.Sub_Reason__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [
    {
        label: 'File Name',
        fieldName: 'Title',
        type: 'text'
    },
    { label: 'Type', fieldName: 'FileType', type: 'text' },
    // { label: 'Size (KB)', fieldName: 'ContentSizeKB', type: 'number' },
    { label: 'Created Date', fieldName: 'CreatedDate', type: 'date' },
    { label: 'Last Modified Date', fieldName: 'LastModifiedDate', type: 'date' },
    {
        type: 'button-icon',
        fixedWidth: 60,
        typeAttributes: {
            iconName: 'utility:delete',
            name: 'delete',
            variant: 'bare',
            alternativeText: 'Delete',
            title: 'Delete'
        }
    }
];

export default class InterestWaiverConsolidation extends NavigationMixin(LightningElement) {
    // @api recordId;
    showModal = true;
    demands = [];
    interestWaivers = [];
    allIwList = [];
    isModalOpen = false;
    // @track selectedWaivers = new Set();
    selectedInterestWaivers = [];
    showIWSubmissionPage = false;
    showIWCreationPage = true;
    waiverAmount = 0;
    openGenerateIWPanel = false;
    isUpdateMode = false;
    selectedDemandIdforIW;
    iswaiverSubReasonDisabled = true;
    selectedwaiverReason = '';
    selectedwaiverSubReason = '';
    descriptionValue;
    showSpinner = false;
    columns = columns;
    interestWaiverAmtPaid = 0;
    filteredWaiverReasons = [];
    allSubReasons = [];
    waiverSubReason = [];
    waiverSubReasonMaster = [];
    waiverReason = [];
    totalWaiverLevied = 0;
    totalWaiverRequested = 0;
    totalIWRequested = 0;
    balanceWaiverLevied = 0;
    totalNetAmount = 0;
    totalSAPWaivedAmount = 0;
    projectWaiverLimit = 0;
    totalCollectedAmount = 0;
    // @track closePage = false;
    selectedDemandforIW = [];
    interestWaiver = {
        'sobjectType': 'Interest_Waiver__c'
    };
    bookinglist = [];
    iomUploaded = false;
    lstAllFiles;
    showIomMessage = false;
    showIomFileUpload = false;
    iomMessage = '';
    iomMessageClass = '';
    acceptedFormats = ['.pdf'];

    showSubmit = false;
    totalWaiverAmount;
    totalSapApprovedAmount;
    totalApprovedButNotSapWaivedAmount;
    totalRequestedAmount;
    _recordId;
    uploadedFiles = [];
    draftIWList = [];


    @api set recordId(value) {
        this._recordId = value;
        console.log('recordId - this._recordId', this._recordId);
        console.log('recordId - this.recordId', this.recordId);
    }

    get recordId() {
        console.log('this._recordId -> ', this._recordId);
        return this._recordId;
    }

    @wire(getObjectInfo, { objectApiName: WAIVER_OBJECT })
    objectInfo;

    @wire(getDemandRecords, { bookingId: '$recordId' })
    wiredDemands(result) {
        this.wiredDemandResult = result;

        console.log('Inside Refresh Demands')
        if (result.data) {


            let rawDemands = result.data;

            // Get booking level value
            this.totalApprovedButNotSapWaivedAmount =
                rawDemands[0].Booking__r.Interest_Waiver_Approved_but_not_Waived__c;

            // 🚨 BLOCK COMPONENT IF APPROVED BUT NOT WAIVED EXISTS
            if (this.totalApprovedButNotSapWaivedAmount > 0) {

                this.showIWCreationPage = false;
                this.showIWSubmissionPage = false;
                this.showModal = false;

                this.showToast(
                    'Error',
                    'Interest Waiver is already approved but not yet waived in SAP. Please wait until SAP processes the waiver.',
                    'error'
                );
                // ✅ Close Quick Action modal
                this.dispatchEvent(new CloseActionScreenEvent());
                return;
            }
            this.allIwList = [];

            // Step 1: map data to temp array
            let tempDemands = result.data.map(demand => {

                let iwList = demand.Interest_Waivers__r || [];
                let generateIW = true;

                if (demand.Previously_Waived_Amount_SAP__c != 0 && demand.Previously_Waived_Amount_SAP__c != null) {
                    generateIW = false;
                }

                let openUpdateIW = false;
                let hasApprovedPendingIW = false;
                let waiverRecordId = null;

                if (iwList.length > 0) {
                    generateIW = false;

                    iwList.forEach(iw => {
                        this.allIwList.push(iw);
                        let status = iw.Approval_Status__c;

                        if (status === 'Rejected') {
                            generateIW = true;
                            waiverRecordId = iw.Id;
                        }

                        if (status === 'Draft') {
                            openUpdateIW = true;
                            waiverRecordId = iw.Id;
                            generateIW = false;
                        }

                        if (status === 'Approved' || status === 'Submitted for Approval') {
                            hasApprovedPendingIW = true;
                            generateIW = false;
                        }
                    });
                }

                return {
                    ...demand,
                    isSelected: false,
                    generateIW,
                    openUpdateIW,
                    hasApprovedPendingIW,
                    waiverRecordId
                };
            });

            // ⭐ Step 2: SORT BY DEMAND DATE ASCENDING
            tempDemands.sort((a, b) => {
                return new Date(a.Demand_Date__c) - new Date(b.Demand_Date__c);
            });

            // Step 3: assign sorted list
            this.demands = tempDemands;

            this.projectWaiverLimit = this.demands[0].Booking__r.Project_Waived_Limit__c;
            this.totalSapApprovedAmount = this.demands[0].Booking__r.Total_Approved_Interest_Amount_Waived__c;
            this.totalApprovedButNotSapWaivedAmount = this.demands[0].Booking__r.Interest_Waiver_Approved_but_not_Waived__c;
            this.totalCollectedAmount = Number(this.demands[0]?.Booking__r?.RW_Total_Amount_Collected__c || 0);
            console.log('this.projectWaiverLimit -> ' + this.projectWaiverLimit);
            console.log('Final Demand Flags →', JSON.stringify(this.demands));
            this.totalWaiverLevied = 0;
            this.totalWaiverRequested = 0;
            this.balanceWaiverLevied = 0;
            this.totalNetAmount = 0;
            this.totalSAPWaivedAmount = 0;
            this.demands.forEach(demand => {
                console.log('Demand Id:', demand.Id);
                console.log('Total_Interest_Amount__c → ', demand.Total_Interest_Amount__c);
                console.log('Interest_Waiver_Requested__c → ', demand.Interest_Waiver_Requested__c);
                console.log('Previously_Waived_Amount_SAP__c → ', demand.Previously_Waived_Amount_SAP__c);
                console.log('Type2 → ', typeof demand.Previously_Waived_Amount_SAP__c);
                this.totalWaiverLevied += Number(demand.Total_Interest_Amount__c || 0);
                this.totalWaiverRequested += Number(demand.Interest_Waiver_Requested__c || 0);
                this.totalNetAmount += Number(demand.Net_Interest_Amount__c || 0);
                this.totalSAPWaivedAmount += Number(demand.Previously_Waived_Amount_SAP__c || 0);

            })
            console.log('totalCollectedAmount → ', this.totalCollectedAmount);
            console.log('totalWaiverLevied → ', this.totalWaiverLevied);
            console.log('totalWaiverRequested → ', this.totalWaiverRequested);
            if(this.totalCollectedAmount>0) this.totalNetAmount = this.totalNetAmount - this.totalCollectedAmount;
            this.balanceWaiverLevied = this.totalWaiverLevied - this.totalWaiverRequested;
        }

    }

    closeModal() {
        this.showModal = false;
        this.isModalOpen = false;
        this.selectedInterestWaivers.clear();
        this.navigateRecord(this.recordId);
        this.dispatchEvent(new RefreshEvent());
    }

    switchtoPage1() {
        this.showIWSubmissionPage = false;
        this.showIWCreationPage = true;
        this.showIomMessage = false;
    }

    switchtoPage2() {
        this.showIWSubmissionPage = true;
        this.showIWCreationPage = false;
        this.showIomMessage = false;
    }

    handleRecordNavigation(event) {
        const recId = event.target.dataset.id;
        console.log('Navigate to -> ' + recId);
        this.navigateRecord(recId);
        this.dispatchEvent(new RefreshEvent());
    }

    navigateRecord(recId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recId,
                actionName: 'view'
            }
        });
    }


    handleIWAmountChange(event) {
        this.IWAmout = event.target.value;
        console.log('Current amount:', this.IWAmout)
    }


    handleIWCheckboxChange(event) {
        const waiverId = event.target.dataset.id;
        const isChecked = event.target.checked;
        this.interestWaivers = this.interestWaivers.map(iw => {
            if (String(iw.tempId) === String(waiverId)) {
                return { ...iw, isSelected: isChecked };
            }
            return iw;
        });

        if (isChecked) {
            if (!this.selectedInterestWaivers.includes(waiverId)) {
                this.selectedInterestWaivers = [...this.selectedInterestWaivers, waiverId];
            }
        } else {
            this.selectedInterestWaivers =
                this.selectedInterestWaivers.filter(
                    id => String(id) !== String(waiverId)
                );
        }
        console.log('selectedInterestWaivers :::', JSON.stringify(this.selectedInterestWaivers));
        console.log('waiverId => ', waiverId);
        console.log('isChecked => ', isChecked);
        console.log(
            'selectedInterestWaivers :::',
            JSON.stringify(this.selectedInterestWaivers)
        );
        console.log('interestWaivers :::', JSON.stringify(this.interestWaivers));
        this.totalWaiverAmount = this.interestWaivers
            .filter(iw => iw.isSelected)
            .reduce((sum, iw) => sum + Number(iw.Waiver_Amount__c || 0), 0);

        console.log('totalWaiverAmount ::::', this.totalWaiverAmount);
    }

    generateIWPanel(event) {

        let demandId = event.target.dataset.id;

        this.selectedDemandforIW =
            this.demands.find(d => d.Id === demandId);

        this.openGenerateIWPanel = true;

        // First check local draft list
        let selectedIW = this.draftIWList.find(
            iw => iw.Demand__c === demandId
        );

        if (selectedIW) {

            // UPDATE MODE
            this.isUpdateMode = true;

            this.waiverdesc = selectedIW.Remarks__c;
            this.waiverAmount = selectedIW.Waiver_Amount__c;
            this.selectedwaiverReason = selectedIW.Waiver_Reason__c;
            this.selectedwaiverSubReason = selectedIW.Sub_Reason__c;

            // enable sub reason dropdown
            this.iswaiverSubReasonDisabled = false;

        } else {

            // NEW MODE
            this.isUpdateMode = false;

            this.waiverdesc = null;
            this.waiverAmount =
                this.selectedDemandforIW.Total_Interest_Amount__c;

            this.selectedwaiverReason = null;
            this.selectedwaiverSubReason = null;

            this.iswaiverSubReasonDisabled = true;
        }
    }




    handleIWAmtFieldChange(event) {
        this.waiverAmount = Number(event.target.value);
        console.log('Waiver Amount -> ', this.waiverAmount);
    }

    closeIWPanel() {
        this.openGenerateIWPanel = false;
        // this.navigateRecord(this.recordId);
    }

    @wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: WaiverReason_Picklist
    })
    wireWaiverReasonPickList({
        error,
        data
    }) {
        if (data) {
            this.waiverReason = data.values;
            console.log('waiverReason -> ', this.waiverReason)
        } else if (error) {
            console.log(error);
        }
    }


    @wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: WaiverSubReason_Picklist
    })
    wireSubReasonPickList({ error, data }) {
        if (data) {
            this.waiverSubReasonMaster = data.controllerValues;
            this.allSubReasons = data.values;
            this.waiverSubReason = [...this.allSubReasons];
            console.log('Loaded Sub Reason Picklist:', data);
        } else if (error) {
            console.error(error);
        }
    }


    handlewaiverReasonChange(event) {
        this.selectedwaiverReason = event.detail.value;

        this.waiverSubReason = [...this.allSubReasons];

        const controllerKey = this.waiverSubReasonMaster[this.selectedwaiverReason];
        this.waiverSubReason = this.waiverSubReason.filter(
            option => option.validFor.includes(controllerKey)
        );
        this.iswaiverSubReasonDisabled = false;
    }


    handlewaiverSubReasonChange(event) {
        this.selectedwaiverSubReason = event.detail.value;
    }

    handleDescriptionChange(event) {
        this.waiverdesc = event.detail.value;
    }

    async saveIW() {
        console.log('Inside Save Event');
        console.log('Waiver Amount -> ', this.waiverAmount);

        // 1️⃣ Basic validation
        if (this.waiverAmount === null || this.waiverAmount === undefined || this.waiverAmount <= 0) {
            this.showToast('Error', 'Please fill the waiver amount', 'error');
            return;
        }

        if (!this.selectedwaiverReason) {
            this.showToast('Error', 'Please fill the waiver reason', 'error');
            return;
        }

        if (!this.selectedwaiverSubReason) {
            this.showToast('Error', 'Please fill the waiver sub reason', 'error');
            return;
        }

        try {
            // 2️⃣ WAIT for Apex result
            this.interestWaiverAmtPaid = await interestWaiverAmtLimit({
                demandId: this.selectedDemandforIW.Id
            });

            console.log('Previously waived amount -> ', this.interestWaiverAmtPaid);

            const remainingInterest =
                this.selectedDemandforIW.Total_Interest_Amount__c - this.interestWaiverAmtPaid;

            console.log('Remaining Interest -> ', remainingInterest);

            // 3️⃣ Amount validation (NOW reliable)
            if (this.waiverAmount > remainingInterest) {
                this.showToast(
                    'Error',
                    'Please enter a waiver amount that is less than the total interest levied on the demand.',
                    'error'
                );
                return;
            }

            let iwData = {
                tempId: Date.now(),

                Demand__c: this.selectedDemandforIW.Id,
                Booking__c: this.selectedDemandforIW.Booking__r.Id,

                Waiver_Amount__c: Number(this.waiverAmount),
                Waiver_Reason__c: this.selectedwaiverReason,
                Sub_Reason__c: this.selectedwaiverSubReason,
                Remarks__c: this.waiverdesc,

                Interest_Days__c: this.selectedDemandforIW.Interest_Days__c,
                Net_Interest_Amount_Demand__c: this.selectedDemandforIW.Net_Interest_Amount__c,
                Previously_Waived_Amount_SAP__c: this.selectedDemandforIW.Previously_Waived_Amount_SAP__c,
                Project_Code__c: this.selectedDemandforIW.Project_Code__c,
                SAP_Customer_Number__c: this.selectedDemandforIW.SAP_Customer_Number__c,
                Slab_Code__c: this.selectedDemandforIW.SAP_Slab_Code__c,
                Slab_Description__c: this.selectedDemandforIW.SAP_Slab_Description__c,
                Total_Interest_Amount_Demand__c: this.selectedDemandforIW.Total_Interest_Amount__c,

                Demand__r: {
                    Name: this.selectedDemandforIW.Name
                },

                isSelected: true
            };


            let existingIndex = this.draftIWList.findIndex(
                x => x.Demand__c === this.selectedDemandforIW.Id
            );

            if (existingIndex >= 0) {
                this.draftIWList[existingIndex] = iwData;
            } else {
                this.draftIWList.push(iwData);
            }

            // ALWAYS update demand UI
            let demandIndex = this.demands.findIndex(
                d => d.Id === this.selectedDemandforIW.Id
            );

            if (demandIndex >= 0) {

                this.demands[demandIndex] = {
                    ...this.demands[demandIndex],
                    generateIW: false,
                    openUpdateIW: true
                };

                this.demands = [...this.demands];
            }
            this.waiverdesc = null;
            this.waiverAmount = null;
            this.selectedwaiverReason = null;
            this.selectedwaiverSubReason = null;

            this.openGenerateIWPanel = false;

            this.showToast(
                'Success',
                'Interest Waiver prepared successfully!',
                'success'
            );

            // 5️⃣ Save
            this.showSpinner = true;


        } catch (error) {
            console.error('Error in saveIW:', error);
            this.showToast('Error', error.body?.message || 'Error creating interest waiver', 'error');
        } finally {
            this.showSpinner = false;
        }
    }

    async switchtoNextPage() {

        if (this.draftIWList.length === 0) {
            this.showToast(
                'Action Required',
                'Please generate at least one Interest Waiver.',
                'error'
            );
            return;
        }
        
        this.showIWSubmissionPage = true;
        this.showIWCreationPage = false;
        this.showIomMessage = false;

        this.interestWaivers = [...this.draftIWList];

        this.selectedInterestWaivers =
            this.interestWaivers.map(iw => String(iw.tempId));

        this.totalWaiverAmount =
            this.interestWaivers.reduce(
                (sum, iw) => sum + Number(iw.Waiver_Amount__c || 0),
                0
            );

        this.showSubmit = true;
    }



    submitSelectedWaivers() {
        if (this.totalWaiverAmount > this.totalNetAmount) {
            this.showToast(
                'Error',
                'Requested waiver amount exceeds Balance Interest.',
                'error'
            );
            return;
        }


        const selectedIds = Array.from(this.selectedInterestWaivers); // Convert Set to Array
        console.log('selectedIds inside submit ::', selectedIds);

        if (selectedIds.length === 0 || selectedIds == []) {
            this.showToast('No Waivers Selected', 'Please select at least one waiver to send for approval.', 'Error');
            return;
        }
        console.log('this.totalWaiverAmount  - ', this.totalWaiverAmount);
        console.log('this.projectWaiverLimit  - ', this.projectWaiverLimit);
        this.totalRequestedAmount = this.totalWaiverAmount + this.totalApprovedButNotSapWaivedAmount + this.totalSapApprovedAmount;
        console.log('this.totalWaiverAmount----->', this.totalWaiverAmount);
        console.log('this.totalApprovedButNotSapWaivedAmount----->', this.totalApprovedButNotSapWaivedAmount);
        console.log('this.totalSapApprovedAmount----->', this.totalSapApprovedAmount);
        console.log('this.totalRequestedAmount----->', this.totalRequestedAmount);
        if (this.totalRequestedAmount > this.projectWaiverLimit) {

            this.showSpinner = true;
            this.showIomMessage = true;
            this.showIWSubmissionPage = false;
            this.showIomFileUpload = true;
            this.iomMessage = 'Total Waiver Amount requested exceeded the limit. Please upload IOM File';
            this.showIWSubmissionPage = false;
            this.iomMessageClass = 'slds-text-color_success';
            this.showSpinner = false;
            return;
        }

        this.showSpinner = true;
        console.log('Waivers to ids ::', selectedIds);
        console.log('this.iomUploaded - ', this.iomUploaded);
        this.submitBookingforApproval(selectedIds, this.iomUploaded);



    }

    submitSelectedWaiverswithIOM() {

        this.showSpinner = true;

        const selectedIds = Array.from(this.selectedInterestWaivers);

        uploadMultipleIOMFiles({
            files: this.uploadedFiles,
            bookingId: this.recordId
        })
            .then(() => {

                this.submitBookingforApproval(selectedIds, true);

            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
                this.showSpinner = false;
            });

    }



    submitBookingforApproval(selectedIds, iomUploaded) {
        console.log(
            'selectedInterestWaivers FINAL => ',
            JSON.stringify(this.selectedInterestWaivers)
        );

        console.log(
            'interestWaivers FINAL => ',
            JSON.stringify(this.interestWaivers)
        );

        const selectedRecords =
            this.interestWaivers.filter(
                iw => this.selectedInterestWaivers.includes(String(iw.tempId))
            );

        console.log(
            'selectedRecords FINAL => ',
            JSON.stringify(selectedRecords)
        );
        const waiverRecords = selectedRecords.map(iw => ({
            Booking__c: iw.Booking__c,
            Demand__c: iw.Demand__c,
            Waiver_Amount__c: iw.Waiver_Amount__c,
            Waiver_Reason__c: iw.Waiver_Reason__c,
            Sub_Reason__c: iw.Sub_Reason__c,
            Remarks__c: iw.Remarks__c,

            Interest_Days__c: iw.Interest_Days__c,
            Net_Interest_Amount_Demand__c: iw.Net_Interest_Amount_Demand__c,
            Previously_Waived_Amount_SAP__c: iw.Previously_Waived_Amount_SAP__c,
            Project_Code__c: iw.Project_Code__c,
            SAP_Customer_Number__c: iw.SAP_Customer_Number__c,
            Slab_Code__c: iw.Slab_Code__c,
            Slab_Description__c: iw.Slab_Description__c,
            Total_Interest_Amount_Demand__c: iw.Total_Interest_Amount_Demand__c
        }));
        createAndSubmitWaivers({
            bookingId: this.recordId,
            waivers: waiverRecords,
            iomUploaded: iomUploaded
        })
            .then(result => {
                console.log('result: ', result);
                if (result == true) {
                    this.showToast('Success', 'Interest Waiver submitted for Approval!', 'success');
                    this.navigateRecord(this.recordId);
                    this.showIomMessage = false;
                    this.dispatchEvent(new RefreshEvent());
                    // this.closePage = true;
                }

            })
            // .catch(error => {
            //     this.error = error;
            // })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            })
            .finally(() => {
                this.showSpinner = false;
                // this.closePage = true;
            });
    }


    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            })
        );
    }

    handleRowAction(event) {

        const row = event.detail.row;

        this.uploadedFiles.splice(row.Id, 1);

        this.lstAllFiles = this.uploadedFiles.map((f, index) => ({
            Id: index,
            Title: f.fileName,
            FileType: f.fileType,
            CreatedDate: new Date(),
            LastModifiedDate: new Date()
        }));

        if (this.uploadedFiles.length === 0) {
            this.iomUploaded = false;
        }
    }

    handleFileChange(event) {

        const files = event.target.files;

        for (const file of files) {

            // ✅ File Size Validation
            if (file.size > 4500000) {
                this.showToast('Error', 'File size must be below 4.5MB', 'error');
                return;
            }

            // ✅ File Type Validation
            const fileExtension = file.name.split('.').pop().toLowerCase();

            if (!this.acceptedFormats.includes('.' + fileExtension)) {
                this.showToast('Error', 'Only .pdf files are allowed', 'error');
                return;
            }

            //VALIDATION: Must contain "IWR" and "IOM" (flexible format)
            const fileNameLower = file.name.toLowerCase();

            // normalize name → remove special chars for flexible matching
            const normalizedName = fileNameLower.replace(/[^a-z]/g, '');

            // check both words exist
            //if (!(normalizedName.includes('iwr') && normalizedName.includes('iom'))) {
            if (!(normalizedName.includes('iwr'))) {
                this.showToast(
                    'Invalid File Name',
                    'File name must contain "IWR"',
                    'error'
                );
                return;
            }

            const reader = new FileReader();

            reader.onload = () => {

                const base64 = reader.result.split(',')[1];
                const fileNameWithoutExtension = file.name.substring(0, file.name.lastIndexOf('.'));
                console.log('fileNameWithoutExtensionenteringgg--->');

                console.log('fileNameWithoutExtension--->', fileNameWithoutExtension);

                // ✅ Important: Use spread operator instead of push
                this.uploadedFiles = [
                    ...this.uploadedFiles,
                    {
                        fileName: fileNameWithoutExtension,
                        base64: base64,
                        fileType: fileExtension.toUpperCase()
                    }
                ];

                // Update table
                this.lstAllFiles = this.uploadedFiles.map((f, index) => ({
                    Id: index,
                    Title: f.fileName,
                    FileType: f.fileType,
                    CreatedDate: new Date(),
                    LastModifiedDate: new Date()
                }));

                this.iomUploaded = true;

            };

            reader.readAsDataURL(file);
        }
    }
}