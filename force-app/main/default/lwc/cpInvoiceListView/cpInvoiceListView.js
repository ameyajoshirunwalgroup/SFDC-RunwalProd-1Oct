import { LightningElement, wire, api, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOpps from '@salesforce/apex/CPBookingController.getInvoice';
import { loadScript } from 'lightning/platformResourceLoader';
import CheckGst from '@salesforce/apex/CPBookingController.CheckForGSTNo';
const columns = [{
    label: 'Customer Name',
    fieldName: 'Customer_Name__c',
    type: 'text',
    sortable: true
},
{
    label: 'Brokerage Scheme',
    fieldName: 'Brokerage_Scheme_Name__c',
    sortable: true
},
/*{
    label: 'Name',
    fieldName: 'Name',
    sortable: true
},*/
{
    label: 'Project',
    fieldName: 'Project__c',
    sortable: true
},
{
    label: 'Tower - Unit',
    fieldName: 'Tower_Unit__c',
    sortable: true
},
{
    label: 'Invoice Number',
    fieldName: 'Invoice_Number__c',
    sortable: true
},
{
    label: 'Invoice Status',
    fieldName: 'Invoice_Status_Brokerage_invoice__c',
    sortable: true
},
{
    label: 'Payment Status',
    fieldName: 'Status__c',
    sortable: true
},
{
    label: 'Eligible Slab',
    fieldName: 'RW_Eligible_Slab__c',
    sortable: true
},
{
    type: "button", label: 'Preview Invoice', initialWidth: 150,
    typeAttributes: {
        label: 'Preview',
        name: 'Preview',
        title: 'Preview',
        disabled: false,
        value: 'edit',
        iconPosition: 'left'
    }
},
{
    type: "button", label: 'Generate Invoice', initialWidth: 150,
    typeAttributes: {
        label: 'Generate',
        name: 'Generate',
        title: 'Generate',
        disabled: false,
        value: 'edit',
        iconPosition: 'left'
    }
},
{
    type: "button", label: 'View', typeAttributes: {
        label: 'View',
        name: 'View',
        title: 'View',
        disabled: false,
        value: 'view',
        iconPosition: 'left'
    }
}

];

export default class CpInvoiceListView extends NavigationMixin(LightningElement) {
    @track value;
    @track error;
    @track data;
    @api sortedDirection = 'asc';
    @api sortedBy = 'Name';
    @api searchKey = '';
    @api searchKeystatus = '';
    result;
    @track allSelectedRows = [];
    @track page = 1;
    @track items = [];
    @track data = [];
    @track columns;
    @track startingRecord = 1;
    @track endingRecord = 0;
    @track pageSize = 10;
    @track totalRecountCount = 0;
    @track totalPage = 0;
    @track BIId;
    @track showEditfrom = false;
    @track showspinner = false;
    @track showiframe = false;
    @track isPresent = false;
    pdfString;
    url;
    isPageChanged = false;
    initialLoad = true;
    mapoppNameVsOpp = new Map();;

    @wire(getOpps, { searchKey: '$searchKey', sortBy: '$sortedBy', sortDirection: '$sortedDirection', searchKeystatus: '$searchKeystatus' })
    wiredAccounts({ error, data }) {
        if (data) {
            this.processRecords(data);
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.data = undefined;
        }
    }

    processRecords(data) {
        this.items = data;
        this.totalRecountCount = data.length;
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);

        this.data = this.items.slice(0, this.pageSize);
        this.endingRecord = this.pageSize;
        this.columns = columns;
    }
    //clicking on previous button this method will be called
    previousHandler() {
        this.isPageChanged = true;
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            this.displayRecordPerPage(this.page);
        }
        var selectedIds = [];
        for (var i = 0; i < this.allSelectedRows.length; i++) {
            selectedIds.push(this.allSelectedRows[i].Id);
        }
        this.template.querySelector(
            '[data-id="table"]'
        ).selectedRows = selectedIds;
    }

    //clicking on next button this method will be called
    nextHandler() {
        this.isPageChanged = true;
        if ((this.page < this.totalPage) && this.page !== this.totalPage) {
            this.page = this.page + 1; //increase page by 1
            this.displayRecordPerPage(this.page);
        }
        var selectedIds = [];
        for (var i = 0; i < this.allSelectedRows.length; i++) {
            selectedIds.push(this.allSelectedRows[i].Id);
        }
        this.template.querySelector(
            '[data-id="table"]'
        ).selectedRows = selectedIds;
    }

    //this method displays records page by page
    displayRecordPerPage(page) {

        this.startingRecord = ((page - 1) * this.pageSize);
        this.endingRecord = (this.pageSize * page);

        this.endingRecord = (this.endingRecord > this.totalRecountCount)
            ? this.totalRecountCount : this.endingRecord;

        this.data = this.items.slice(this.startingRecord, this.endingRecord);
        this.startingRecord = this.startingRecord + 1;
    }

    sortColumns(event) {
        this.sortedBy = event.detail.fieldName;
        this.sortedDirection = event.detail.sortDirection;
        return refreshApex(this.result);

    }

    onRowSelection(event) {
        if (!this.isPageChanged || this.initialLoad) {
            if (this.initialLoad) this.initialLoad = false;
            this.processSelectedRows(event.detail.selectedRows);
        } else {
            this.isPageChanged = false;
            this.initialLoad = true;
        }

    }
    processSelectedRows(selectedOpps) {
        var newMap = new Map();
        for (var i = 0; i < selectedOpps.length; i++) {
            if (!this.allSelectedRows.includes(selectedOpps[i])) {
                this.allSelectedRows.push(selectedOpps[i]);
            }
            this.mapoppNameVsOpp.set(selectedOpps[i].Name, selectedOpps[i]);
            newMap.set(selectedOpps[i].Name, selectedOpps[i]);
        }
        for (let [key, value] of this.mapoppNameVsOpp.entries()) {
            if (newMap.size <= 0 || (!newMap.has(key) && this.initialLoad)) {
                const index = this.allSelectedRows.indexOf(value);
                if (index > -1) {
                    this.allSelectedRows.splice(index, 1);
                }
            }
        }
    }

    handleKeyChange(event) {
        this.searchKey = event.target.value;
        var data = [];
        for (var i = 0; i < this.items.length; i++) {
            if (this.items[i] != undefined && this.items[i].Name.includes(this.searchKey)) {
                data.push(this.items[i]);
            }
        }
        this.processRecords(data);
    }
    handleKeystatusChange(event) {
        this.searchKeystatus = event.target.value;
        var data = [];
        for (var i = 0; i < this.items.length; i++) {
            if (this.items[i] != undefined && this.items[i].Name.includes(this.searchKeystatus)) {
                data.push(this.items[i]);
            }
        }
        this.processRecords(data);
    }
    callRowAction(event) {
        console.log('Inside callRowAction');
        const recId = event.detail.row.Id;
        const actionName = event.detail.action.name;
        console.log('recId::' + this.recId);
        this.BIId = event.detail.row.Id;
        console.log('BIId::' + this.BIId);
        console.log('recId::' + recId + ':::Action:::' + actionName);
        if (actionName === 'Generate') {

            this.showEditfrom = true;
            
        } else if (actionName === 'View') {

            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: recId,
                    objectApiName: 'Brokerage_Invoice__c',
                    actionName: 'view'
                }
            })

        } else if (actionName === 'Preview') {

            this[NavigationMixin.Navigate]({
                "type": "standard__webPage",
                "attributes": {
                    "url": window.location.origin + '/apex/ShowInvoicePreview?id=' + this.BIId
                }
            });

        }

    }
    closeTermsAndConditions(event) {
        this.showEditfrom = false;
    }
    closeTermsAndConditions2(event) {
        this.showiframe = false;
    }
    handleSubmit(event) {
        this.showspinner = true;
        console.log('onsubmit event recordEditForm' + event.detail.fields);
    }
    handlegstchange(event) {
        console.log('Handle Chnage GST Applicable' + event.detail.value);
        if (event.detail.value == 'Yes') {
            CheckGst({ InvId: this.BIId })
                .then((result) => {
                    this.isPresent = result;
                    if (!this.isPresent) {
                        const evt = new ShowToastEvent({
                            title: "Warning!",
                            message: 'Please update your GST Number through your profile update',
                            variant: 'warning',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(evt);
                    }
                })
                .catch((error) => {
                    this.error = error;
                    window.alert("error :" + JSON.stringify(this.error));
                });
        }

    }
    handleSuccess(event) {
        this.showEditfrom = false;
        this.showspinner = false;
        getOpps({ searchKey: '', sortBy: '', sortDirection: '' })
            .then(data => {
                this.processRecords(data);
            }).catch(error => {
                window.console.log('error ====> ' + JSON.stringify(error));
            })
        //this.generatePdf();
        //this.url = 'https://runwal--uat.sandbox.my.site.com/channelpartner/apex/ShowInvoicePreview?id=' + this.BIId
        //this.showiframe = true
        this[NavigationMixin.Navigate]({
    type: "standard__webPage",
    attributes: {
        url: window.location.origin + '/apex/ShowCP_InvoicePreview?id=' + this.BIId
    }
});

        console.log('onsuccess event recordEditForm', event.detail.id);
    }




}