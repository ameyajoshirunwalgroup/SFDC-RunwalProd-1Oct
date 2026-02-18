import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import { RefreshEvent } from 'lightning/refresh';

import getDemandRecords from '@salesforce/apex/interestWaiverConsolidation.getDemandRecords';
import getIWRecords from '@salesforce/apex/interestWaiverConsolidation.getIWRecords';
import submitSelectedWaivers from '@salesforce/apex/interestWaiverConsolidation.submitSelectedWaivers';
import createInterestWaiver from '@salesforce/apex/interestWaiverConsolidation.createInterestWaiver';
import interestWaiverAmtLimit from '@salesforce/apex/interestWaiverConsolidation.interestWaiverAmtLimit';
import fetchFiles from '@salesforce/apex/interestWaiverConsolidation.fetchFiles';

import {
    getPicklistValues,
    getObjectInfo
} from 'lightning/uiObjectInfoApi';
import WAIVER_OBJECT from '@salesforce/schema/Interest_Waiver__c';
import WaiverReason_Picklist from '@salesforce/schema/Interest_Waiver__c.Waiver_Reason__c';
import WaiverSubReason_Picklist from '@salesforce/schema/Interest_Waiver__c.Sub_Reason__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

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

export default class InterestWaiverConsolidation extends NavigationMixin(LightningElement) {
    // @api recordId;
    @track showModal = true;
    @track demands = [];
    @track interestWaivers = [];
    @track allIwList = [];
    @track isModalOpen = false;
    // @track selectedWaivers = new Set();
    @track selectedInterestWaivers = new Set();
    @track showIWSubmissionPage = false;
    @track showIWCreationPage = true;
    @track waiverAmount = 0;
    @track openGenerateIWPanel = false;
    @track isUpdateMode = false;
    @track selectedDemandIdforIW;
    @track iswaiverSubReasonDisabled = true;
    @track selectedwaiverReason = '';
    @track selectedwaiverSubReason = '';
    @track descriptionValue;
    @track showSpinner = false;
    @track columns = columns;
    @track interestWaiverAmtPaid = 0;
    @track filteredWaiverReasons = [];
    allSubReasons = [];
    @track waiverSubReason = [];
    @track waiverSubReasonMaster = [];
    @track waiverReason = [];
    @track totalWaiverLevied = 0;
    @track totalWaiverRequested = 0;
    @track totalIWRequested = 0;
    @track balanceWaiverLevied = 0;
    @track totalNetAmount = 0;
     @track totalSAPWaivedAmount = 0;
    @track projectWaiverLimit = 0;
    // @track closePage = false;
    selectedDemandforIW = [];
    interestWaiver = {
        'sobjectType': 'Interest_Waiver__c'
    };
    @track bookinglist = [];
    @track iomUploaded = false;
    @track lstAllFiles;
    showIomMessage = false;
    showIomFileUpload = false;
    iomMessage = '';
    iomMessageClass = '';
    acceptedFormats = ['.pdf', '.png', '.jpg'];

    @track showSubmit = false;
    @track totalWaiverAmount;
    @track totalSapApprovedAmount;
    @track totalApprovedButNotSapWaivedAmount;
    @track totalRequestedAmount;
    _recordId;



    @api set recordId(value) {
        this._recordId = value;
        console.log('recordId - this._recordId', this._recordId);
        console.log('recordId - this.recordId', this.recordId);
        // this.getDemands();
        // do your thing right here with this.recordId / value
    }

    get recordId() {
        console.log('this._recordId -> ', this._recordId);
        return this._recordId;
    }


    connectedCallback() {
        // console.log('connectedCallback - this._recordId -> ', this._recordId);
        // console.log('connectedCallback - this.recordId -> ', this.recordId);
        // this.getDemands();
        // refreshApex(this.wiredDemandResult);
        // window.location.reload();

    }
    @wire(getObjectInfo, { objectApiName: WAIVER_OBJECT })
    objectInfo;

    getDemands() {
        // this.recordId = 'a0s0I000006zf6eQAA';
        console.log('Booking ID from URL → ' + this.recordId);
        // console.log('Booking ID from Action → ' + this.recordId);
        // this.recordId = 'a0s0I000006zf6eQAA';
        console.log('recordId -> ' + this.recordId)
        getDemandRecords({ bookingId: this.recordId })
            .then(result => {
                this.demands = result.map(demand => ({
                    ...demand,
                    isSelected: false,
                    hasInterestWaiver: demand.Interest_Waivers__r && demand.Interest_Waivers__r.length > 0
                }));
                console.log('this.demands -> ', this.demands);
                console.log('this.demands -> ', JSON.stringify(this.demands));
                console.log('this.demands interest waivers -> ', JSON.stringify(this.demands.Interest_Waivers__r));

                this.demands.forEach(demand => {
                    console.log('Demand Id:', demand.Id);
                    console.log('Total_Interest_Amount__c → ', demand.Total_Interest_Amount__c);
                    console.log('Interest_Waiver_Requested__c → ', demand.Interest_Waiver_Requested__c);
                    totalWaiverLevied += demand.Total_Interest_Amount__c;
                    totalWaiverRequested += demand.Interest_Waiver_Requested__c;
                    totalIWRequested += demand.Total_Interest_Waiver_Amount__c
                    totalNetAmount += demand.Net_Interest_Amount__c;
                    totalSAPWaivedAmount += demand.Previously_Waived_Amount_SAP__c;
                })
                console.log('totalWaiverLevied → ', totalWaiverLevied);
                console.log('totalWaiverRequested → ', totalWaiverRequested);
            })
            // .catch(error => {
            //     this.error = error;

            //     this.demands = [];
            // });
            .catch(error => {
                this.demands = [];
                this.showToast('Error', error.body.message, 'error');
            });

        // console.log('Demands ::::', this.demands)

        // console.log('Demands ::::', JSON.stringify(this.demands))
    }

    @wire(getDemandRecords, { bookingId: '$recordId' })
    wiredDemands(result) {
        this.wiredDemandResult = result;
        // if (result.data) {
        //     this.demands = result.data.map(demand => ({
        //         ...demand,
        //         isSelected: false,
        //         generateIW: demand.Interest_Waivers__r && demand.Interest_Waivers__r.length > 0
        //     }));
        //     console.log('All Demands → ', JSON.stringify(this.demands));

        //     this.demands.forEach(demand => {
        //         console.log('Demand Id:', demand.Id);
        //         console.log('Interest Waivers → ', JSON.stringify(demand.Interest_Waivers__r));
        //         let interestWaiverDemands = demand.Interest_Waivers__r;
        //         interestWaiverDemands.forEach(iw => {
        //             console.log('Iw Id:', iw.Id);
        //             console.log('Iw Id:', iw.Sent_for_Approval__c);
        //             console.log('Iw Id:', iw.Approval_Status__c);
        //         });
        //     });
        // }
        console.log('Inside Refresh Demands')
        if (result.data) {

            // this.allIwList = [];
            // this.demands = result.data.map(demand => {

            //     let iwList = demand.Interest_Waivers__r || [];
            //     let generateIW = true;
            //     if (demand.Previously_Waived_Amount_SAP__c != 0 && demand.Previously_Waived_Amount_SAP__c != null) {
            //         generateIW = false;
            //     }

            //     let openUpdateIW = false;
            //     let hasApprovedPendingIW = false;
            //     let waiverRecordId = null;

            //     if (iwList.length > 0) {
            //         generateIW = false; // Because waivers exist

            //         iwList.forEach(iw => {
            //             this.allIwList.push(iw);
            //             let status = iw.Approval_Status__c;

            //             // waiverRecordId = iw.Id;

            //             if (status === 'Rejected') {
            //                 generateIW = true;
            //                 waiverRecordId = iw.Id;
            //             }

            //             if (status === 'Draft') {
            //                 openUpdateIW = true;
            //                 waiverRecordId = iw.Id;
            //                 generateIW = false;
            //             }

            //             if (status === 'Approved' || status === 'Submitted for Approval') {
            //                 hasApprovedPendingIW = true;
            //                 generateIW = false;
            //             }
            //         });
            //     }

            //     return {
            //         ...demand,
            //         isSelected: false,
            //         generateIW,
            //         openUpdateIW,
            //         hasApprovedPendingIW,
            //         waiverRecordId
            //     };
            // });
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
            console.log('this.projectWaiverLimit -> ' + this.projectWaiverLimit);
            console.log('Final Demand Flags →', JSON.stringify(this.demands));
            this.totalWaiverLevied = 0;
            this.totalWaiverRequested = 0;
            this.balanceWaiverLevied = 0;
            this.demands.forEach(demand => {
                console.log('Demand Id:', demand.Id);
                console.log('Total_Interest_Amount__c → ', demand.Total_Interest_Amount__c);
                console.log('Interest_Waiver_Requested__c → ', demand.Interest_Waiver_Requested__c);
                this.totalWaiverLevied += demand.Total_Interest_Amount__c;
                this.totalWaiverRequested += demand.Interest_Waiver_Requested__c;
                this.totalNetAmount += demand.Net_Interest_Amount__c;
                this.totalSAPWaivedAmount += demand.Previously_Waived_Amount_SAP__c;
            })
            console.log('totalWaiverLevied → ', this.totalWaiverLevied);
            console.log('totalWaiverRequested → ', this.totalWaiverRequested);
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

    // handleCheckboxChange(event) {
    //     const waiverId = event.target.dataset.id;
    //     console.log('waiverId -> ' + waiverId);
    //     console.log('waiverId::', this.waiverId)
    //     if (event.target.checked) {
    //         console.log('Checked');
    //         this.selectedWaivers.add(waiverId);
    //     } else {
    //         console.log('Deleted');
    //         this.selectedWaivers.delete(waiverId);
    //     }
    //     console.log('selectedWaivers::', this.selectedWaivers)
    // }

    handleIWAmountChange(event) {
        this.IWAmout = event.target.value;
        console.log('Current amount:', this.IWAmout)
    }


    handleIWCheckboxChange(event) {
        const waiverId = event.target.dataset.id;
        const isChecked = event.target.checked;
        this.interestWaivers = this.interestWaivers.map(iw => {
            if (iw.Id === waiverId) {
                return { ...iw, isSelected: isChecked };
            }
            return iw;
        });

        if (isChecked) {
            if (!this.selectedInterestWaivers.includes(waiverId)) {
                this.selectedInterestWaivers = [...this.selectedInterestWaivers, waiverId];
            }
        } else {
            this.selectedInterestWaivers = this.selectedInterestWaivers.filter(id => id !== waiverId);
        }
        console.log('selectedInterestWaivers :::', JSON.stringify(this.selectedInterestWaivers));
        console.log('interestWaivers :::', JSON.stringify(this.interestWaivers));
        this.totalWaiverAmount = this.interestWaivers
            .filter(iw => iw.isSelected)
            .reduce((sum, iw) => sum + (iw.Waiver_Amount__c || 0), 0);

        console.log('totalWaiverAmount ::::', this.totalWaiverAmount);
    }

    generateIWPanelOld(event) {
        this.selectedDemandIdforIW = event.target.dataset.id;
        this.openGenerateIWPanel = true;
        console.log('selectedDemandIdforIW -> ', this.selectedDemandIdforIW)

        this.selectedDemandforIW = this.demands.find(d => d.Id === this.selectedDemandIdforIW);//Assign selected demand
        console.log('this.allIwList-> ', this.allIwList);
        console.log('this.selectedDemandIdforIW.waiverRecordId-> ', this.selectedDemandIdforIW.waiverRecordId);
        console.log('this.allIwList-> ', JSON.stringify(this.allIwList));
        console.log('waiver amount -> ', this.allIwList.find(i => i.Id === this.selectedDemandIdforIW.waiverRecordId));
        console.log('waiver reason -> ', this.allIwList.find(i => i.Id === this.selectedDemandIdforIW.waiverRecordId));
        console.log('waiver sub reason -> ', this.allIwList.find(i => i.Id === this.selectedDemandIdforIW.waiverRecordId));
    }

    generateIWPanel(event) {
        console.log('🔵 Inside generateIWPanel');

        let demandId = event.target.dataset.id;
        console.log('👉 demandId from button:', demandId);

        this.selectedDemandforIW = this.demands.find(d => d.Id === demandId);
        console.log('👉 selectedDemandforIW:', JSON.stringify(this.selectedDemandforIW));

        this.openGenerateIWPanel = true;
        console.log('📌 Modal Opened');

        if (!this.selectedDemandforIW) {
            console.log('❌ selectedDemandforIW is NULL. Something is wrong with dataset.id');
            return;
        }

        console.log('🔍 Checking if update mode is required...');
        console.log('openUpdateIW:', this.selectedDemandforIW.openUpdateIW);
        console.log('waiverRecordId:', this.selectedDemandforIW.waiverRecordId);

        if (this.selectedDemandforIW.openUpdateIW && this.selectedDemandforIW.waiverRecordId) {
            console.log('🟠 UPDATE MODE activated');
            this.isUpdateMode = true;

            let selectedIW = this.allIwList.find(i => i.Id === this.selectedDemandforIW.waiverRecordId);
            console.log('👉 selectedIW record in allIwList:', JSON.stringify(selectedIW));

            if (!selectedIW) {
                console.log('❌ selectedIW not found in allIwList. allIwList:', JSON.stringify(this.allIwList));
            }

            // Prefill fields
            this.waiverdesc = selectedIW?.Remarks__c;
            this.waiverAmount = selectedIW?.Waiver_Amount__c;
            this.selectedwaiverReason = selectedIW?.Waiver_Reason__c;
            this.selectedwaiverSubReason = selectedIW?.Sub_Reason__c;

            console.log('📝 Prefilled fields:', {
                waiverdesc: this.waiverdesc,
                waiverAmount: this.waiverAmount,
                selectedwaiverReason: this.selectedwaiverReason,
                selectedwaiverSubReason: this.selectedwaiverSubReason
            });

        } else {
            console.log('🟢 NEW MODE activated');
            this.isUpdateMode = false;

            this.waiverdesc = null;
            // this.waiverAmount = null;
            console.log('this.selectedDemandforIW.Total_Interest_Amount__c -> ', this.selectedDemandforIW.Total_Interest_Amount__c)
            this.waiverAmount = this.selectedDemandforIW.Total_Interest_Amount__c;
            console.log('this.waiverAmount -> ', this.waiverAmount)
            this.selectedwaiverReason = null;
            this.selectedwaiverSubReason = null;

            console.log('🧹 Cleared form fields for new IW');
        }

        console.log('🔵 END generateIWPanel()');
    }




    handleIWAmtFieldChange(event) {
        this.waiverAmount = event.target.value;
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

            // 4️⃣ Prepare record
            this.interestWaiver.Id = this.isUpdateMode
                ? this.selectedDemandforIW.waiverRecordId
                : null;

            this.interestWaiver.Remarks__c = this.waiverdesc;
            this.interestWaiver.Approval_Status__c = 'Draft';
            this.interestWaiver.Waiver_Amount__c = this.waiverAmount;
            this.interestWaiver.Waiver_Reason__c = this.selectedwaiverReason;
            this.interestWaiver.Sub_Reason__c = this.selectedwaiverSubReason;

            this.interestWaiver.Booking__c = this.selectedDemandforIW.Booking__r.Id;
            this.interestWaiver.Demand__c = this.selectedDemandforIW.Id;
            this.interestWaiver.Interest_Days__c = this.selectedDemandforIW.Interest_Days__c;
            this.interestWaiver.Net_Interest_Amount_Demand__c = this.selectedDemandforIW.Net_Interest_Amount__c;
            this.interestWaiver.Previously_Waived_Amount_SAP__c = this.selectedDemandforIW.Previously_Waived_Amount_SAP__c;
            this.interestWaiver.Project_Code__c = this.selectedDemandforIW.Project_Code__c;
            this.interestWaiver.SAP_Customer_Number__c = this.selectedDemandforIW.SAP_Customer_Number__c;
            this.interestWaiver.Slab_Code__c = this.selectedDemandforIW.SAP_Slab_Code__c;
            this.interestWaiver.Slab_Description__c = this.selectedDemandforIW.SAP_Slab_Description__c;
            this.interestWaiver.Total_Interest_Amount_Demand__c = this.selectedDemandforIW.Total_Interest_Amount__c;

            // 5️⃣ Save
            this.showSpinner = true;

            const result = await createInterestWaiver({
                interestWaiverRecord: this.interestWaiver
            });

            console.log('Saved IW -> ', result);

            this.waiverdesc = null;
            this.waiverAmount = null;
            this.selectedwaiverReason = null;
            this.selectedwaiverSubReason = null;
            this.openGenerateIWPanel = false;

            refreshApex(this.wiredDemandResult);

            this.showToast(
                'Success',
                this.isUpdateMode
                    ? 'Interest Waiver updated successfully!'
                    : 'Interest Waiver created successfully!',
                'success'
            );

        } catch (error) {
            console.error('Error in saveIW:', error);
            this.showToast('Error', error.body?.message || 'Error creating interest waiver', 'error');
        } finally {
            this.showSpinner = false;
        }
    }


    // saveIWV2() {
    //     console.log('Inside Save Event');

    //     if (!this.waiverAmount || this.waiverAmount.trim() === '') {
    //         this.showToast('Error', 'Please fill the waiver amount', 'error');
    //         return;
    //     }

    //     if (!this.selectedwaiverReason) {
    //         this.showToast('Error', 'Please fill the waiver reason', 'error');
    //         return;
    //     }

    //     if (!this.selectedwaiverSubReason) {
    //         this.showToast('Error', 'Please fill the waiver sub reason', 'error');
    //         return;
    //     }

    //     this.showSpinner = true;

    //     interestWaiverAmtLimit({ demandId: this.selectedDemandforIW.Id })
    //         .then((result) => {
    //             this.interestWaiverAmtPaid = result;

    //             if (this.waiverAmount > (this.selectedDemandforIW.Total_Interest_Amount__c - this.interestWaiverAmtPaid)) {
    //                 this.showSpinner = false;
    //                 this.showToast('Error', 'Waiver amount cannot exceed total interest on demand.', 'error');
    //                 return;
    //             }

    //             this.interestWaiver.Remarks__c = this.waiverdesc;
    //             this.interestWaiver.Waiver_Amount__c = this.waiverAmount;
    //             this.interestWaiver.Waiver_Reason__c = this.selectedwaiverReason;
    //             this.interestWaiver.Sub_Reason__c = this.selectedwaiverSubReason;
    //             this.interestWaiver.Demand__c = this.selectedDemandforIW.Id;
    //             this.interestWaiver.Booking__c = this.selectedDemandforIW.Booking__r.Id;
    //             this.interestWaiver.Approval_Status__c = 'Submitted for Approval';

    //             return createInterestWaiver({ interestWaiverRecord: this.interestWaiver });
    //         })
    //         .then(() => {
    //             this.showSpinner = false;
    //             this.openGenerateIWPanel = false;

    //             this.waiverdesc = null;
    //             this.waiverAmount = null;
    //             this.selectedwaiverReason = null;
    //             this.selectedwaiverSubReason = null;

    //             // this.getDemands();
    //             refreshApex(this.wiredDemandResult);

    //             this.showToast('Success', 'Interest Waiver created successfully!', 'success');
    //         })
    //         .catch(error => {
    //             this.showSpinner = false;
    //             console.error(error);
    //             this.showToast('Error', error.body?.message || 'Something went wrong', 'error');
    //         });
    // }


    // @wire(getIWRecords, { bookingId: '$recordId' })
    // wiredIWResult(result) {
    //     this.wiredIWResult = result;
    //     if (result.data) {
    //         this.interestWaivers = result.data.map(iw => ({
    //             ...iw,
    //             isSelected: true
    //         }));
    //     }
    // }

    @wire(getIWRecords, { bookingId: '$recordId' })
    wiredIWResult({ data, error }) {
        if (data) {
           this.interestWaivers = result.data.map(iw => ({
                ...iw,
                isSelected: true
            }));
        } else if (error) {
            this.error = error;
        }
    }


    // switchtoNextPage() {
    //     this.showIWSubmissionPage = true;
    //     this.showIWCreationPage = false;
    //     this.showIomMessage = false;

    //     getIWRecords({ bookingId: this.recordId })
    //         .then(result => {
    //             this.interestWaivers = result.map(iw => ({
    //                 ...iw,
    //                 isSelected: true
    //             }));
    //             console.log('interestWaivers ::::', JSON.stringify(this.interestWaivers))
    //             this.selectedInterestWaivers = this.interestWaivers.map(waiver => waiver.Id);
    //             console.log('selectedInterestWaivers ::::', JSON.stringify(this.selectedInterestWaivers))
    //             this.totalWaiverAmount = this.interestWaivers
    //                 .filter(iw => iw.isSelected)
    //                 .reduce((sum, iw) => sum + (iw.Waiver_Amount__c || 0), 0);

    //             console.log('totalWaiverAmount ::::', this.totalWaiverAmount);
    //             if (this.interestWaivers.length > 0) {
    //                 this.showSubmit = true;
    //             }
    //         })
    //         // .catch(error => {
    //         //     this.error = error;
    //         //     this.interestWaivers = [];
    //         // });
    //         .catch(error => {
    //             this.interestWaivers = [];
    //             this.showToast('Error', error.body.message, 'error');
    //         });

    // }

    async switchtoNextPage() {

    try {

        // 🔹 Fetch IW records first
        const result = await getIWRecords({ bookingId: this.recordId });

        // ❌ If no IW created → stop here
        if (!result || result.length === 0) {
            this.showToast(
                'Action Required',
                'Please generate at least one Interest Waiver to proceed.',
                'error'
            );
            return;
        }

        // ✅ If IW exists → move to next page
        this.showIWSubmissionPage = true;
        this.showIWCreationPage = false;
        this.showIomMessage = false;

        // Prepare data for page 2
        this.interestWaivers = result.map(iw => ({
            ...iw,
            isSelected: true
        }));

        this.selectedInterestWaivers = this.interestWaivers.map(iw => iw.Id);

        this.totalWaiverAmount = this.interestWaivers
            .reduce((sum, iw) => sum + (iw.Waiver_Amount__c || 0), 0);

        if (this.interestWaivers.length > 0) {
            this.showSubmit = true;
        }

    } catch (error) {
        this.showToast('Error', error.body.message, 'error');
    }
}



    submitSelectedWaivers() {

        const selectedIds = Array.from(this.selectedInterestWaivers); // Convert Set to Array
        console.log('selectedIds inside submit ::', selectedIds);

        if (selectedIds.length === 0 || selectedIds == []) {
            this.showToast('No Waivers Selected', 'Please select at least one waiver to send for approval.', 'warning');
            return;
        }
        console.log('this.totalWaiverAmount  - ', this.totalWaiverAmount);
        console.log('this.projectWaiverLimit  - ', this.projectWaiverLimit);
        this.totalRequestedAmount = this.totalWaiverAmount + this.totalApprovedButNotSapWaivedAmount + this.totalSapApprovedAmount;
        console.log('this.totalWaiverAmount----->',this.totalWaiverAmount);
        console.log('this.totalApprovedButNotSapWaivedAmount----->',this.totalApprovedButNotSapWaivedAmount);
        console.log('this.totalSapApprovedAmount----->',this.totalSapApprovedAmount);
        console.log('this.totalRequestedAmount----->',this.totalRequestedAmount);
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


        // sendReceiptEmail({ receiptIds: selectedIds }) // Use the Array here
        //     .then(() => {
        //         this.dispatchEvent(
        //             new ShowToastEvent({
        //                 title: 'Success',
        //                 message: 'Selected receipts have been sent successfully.',
        //                 variant: 'success'
        //             })
        //         );
        //         this.closeReceiptModal();
        //     })
        //     .catch(error => {
        //         this.dispatchEvent(
        //             new ShowToastEvent({
        //                 title: 'Error sending receipts',
        //                 message: error.body.message,
        //                 variant: 'error'
        //             })
        //         );
        //     });
    }

    submitSelectedWaiverswithIOM() {
        this.showSpinner = true;
        const selectedIds = Array.from(this.selectedInterestWaivers);
        this.submitBookingforApproval(selectedIds, this.iomUploaded);
    }



    async getFilesData(bookingId) {
        const result = await fetchFiles({ recordId: bookingId });
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

    submitBookingforApproval(selectedIds, iomUploaded) {
        submitSelectedWaivers({ bookingId: this.recordId, waivers: selectedIds, iomUploaded: iomUploaded,totalWaiverRequested: this.totalIWRequested })
            .then(result => {
                console.log('result: ', result);
                if (result == true) {
                    this.showToast('Success', 'Interest Waiver submitted for Approval!', 'success');
                    this.navigateRecord(this.recordId);
                    this.showIomMessage = false;
                    this.dispatchEvent(new RefreshEvent());
                    // this.closePage = true;
                }
                // else if (result == 'Upload IOM') {
                //     this.showIomMessage = true;
                //     this.showIWSubmissionPage = false;
                //     this.showIomFileUpload = true;
                //     this.iomMessage = 'Total Waiver Amount requested exceeded the limit. Please upload IOM File';
                //     //this.showIWSubmissionPage = false;
                //     this.iomMessageClass = 'slds-text-color_success';
                // }
                /*if (result == true) {
                    this.showToast('Success', 'Interest Waiver submitted for Approval!', 'success');
                    this.navigateRecord(this.recordId);
                    this.dispatchEvent(new RefreshEvent());
                    // this.closePage = true;
                }*/
                // this.demands = result.map(demand => ({
                //     ...demand,
                //     isSelected: false
                // }));
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


    handleUploadFinished(event) {
        const files = event.detail.files;
        console.log('Uploaded files:', files);

        if (files != null) {
            this.iomUploaded = true;
        }
        this.getFilesData(this.recordId);

        // this[NavigationMixin.Navigate]({
        //     type: 'standard__recordPage',
        //     attributes: {
        //         recordId: this.recordId,
        //         actionName: 'view'
        //     }
        // });
    }

    // submitapproval(){
    //     sendapproval({comment:this.cmnt,recId : this.bId}).then(result=>{
    //         console.log('Result::'+JSON.parse(JSON.stringify(result)));
    //         if(result)
    //             {
    //                 const saveMessage = new ShowToastEvent({
    //                     title :'Success !',
    //                     message :'Approval Sent !',
    //                     variant : 'success',
    //                     mode : 'dismissable'
    //                 })
    //                 this.dispatchEvent(saveMessage);
    // 							 this.isSpinner = true;
    //              location.replace("https://runwal.lightning.force.com/lightning/r/Brokerage_Invoice__c/" + this.bId + "/view")

    // 							}
    //             else
    //             {
    //                 const saveMessage = new ShowToastEvent({
    //                     title :'Error !',
    //                     message :'Something went wrong',
    //                     variant : 'error',
    //                     mode : 'dismissable'
    //                 })
    //                 this.dispatchEvent(saveMessage);
    //             }
    //     }).catch((error) => {
    //         this.error = error;
    //         const errMessage = new ShowToastEvent({
    //             title :'Error !',
    //             message :error.body.message,
    //             variant : 'error',
    //             mode : 'sticky'
    //         })
    //         this.dispatchEvent(errMessage);
    //         console.log('error-', JSON.stringify(this.error));
    //     });


    // }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            })
        );
    }

}