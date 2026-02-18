import { LightningElement, wire, track, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCpBrokerages from '@salesforce/apex/CPBrokerageInvoiceController.getCpBrokerages';
import CheckGst from '@salesforce/apex/CPBrokerageInvoiceController.CheckForGSTNo'; // Missing import

const columns = [
    //For every type
    {label: 'Customer Name',fieldName: 'Customer_Name__c', type: 'text',sortable: true},
    {label: 'Brokerage Scheme',fieldName: 'Brokerage_Scheme_Name__c',sortable: true},
    /*{label: 'Name',fieldName: 'Name',sortable: true},*/
    {label: 'Project',fieldName: 'Project__c', sortable: true},
    {label: 'Tower - Unit',fieldName: 'Tower_Unit__c',sortable: true},
    {label: 'Invoice Number',fieldName: 'Invoice_Number__c',sortable: true},
    {label: 'Invoice Status',fieldName: 'Invoice_Status_CP_Portal__c',sortable: true},
    {label: 'Payment Status',fieldName: 'Status__c',sortable: true},    
    // {label: 'Eligible Slab', fieldName: 'RW_Eligible_Slab__c', sortable: true },

    // { label: 'Invoice Number', fieldName: 'Invoice_Number__c', sortable: true },
    // { label: 'Approval Status', fieldName: 'Approval_Status__c', sortable: true },
    // { label: 'Approval Status (Clearing)', fieldName: 'Approval_Status_clearing__c', sortable: true },
    { label: 'Eligible Slab', fieldName: 'Brokerage_Type__c', sortable: true },
    { label: 'Total Brokerage', fieldName: 'Total_Brokerage__c', type: 'currency', sortable: true },
    { label: 'Company Name', fieldName: 'Company_Name__c', sortable: true },
    //For every type

    {
        type: "button", 
        label: 'Preview Invoice', 
        initialWidth: 150,
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
        type: "button", 
        label: 'Generate Invoice', 
        initialWidth: 150,
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
        type: 'button',
        label: 'View',
        initialWidth: 100, 
        typeAttributes: {
            label: 'View',
            name: 'View',
            title: 'View',
            disabled: false,
            iconPosition: 'left'
        }
    }
];

/*const othercolumns = [

    //For Other Invoices
    { label: 'Invoice Number', fieldName: 'Invoice_Number__c', sortable: true },
    { label: 'Approval Status', fieldName: 'Approval_Status__c', sortable: true },
    { label: 'Approval Status (Clearing)', fieldName: 'Approval_Status_clearing__c', sortable: true },
    { label: 'Brokerage Type', fieldName: 'Brokerage_Type__c', sortable: true },
    { label: 'Company Name', fieldName: 'Company_Name__c', sortable: true },
    { label: 'Invoice Status', fieldName: 'Invoice_Status__c', sortable: true },
    { label: 'Payment Status', fieldName: 'Status__c', sortable: true },
    { label: 'Total Brokerage', fieldName: 'Total_Brokerage__c', type: 'currency', sortable: true },
    // { label: 'Created Date', fieldName: 'CreatedDate', type: 'date', sortable: true },
    // { label: 'Last Modified Date', fieldName: 'LastModifiedDate', type: 'date', sortable: true },
    //For Other Invoices ENDS
    {
        type: "button", 
        label: 'Preview Invoice', 
        initialWidth: 150,
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
        type: "button", 
        label: 'Generate Invoice', 
        initialWidth: 150,
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
        type: 'button',
        label: 'View',
        initialWidth: 100, 
        typeAttributes: {
            label: 'View',
            name: 'View',
            title: 'View',
            disabled: false,
            iconPosition: 'left'
        }
    }
];*/

export default class CpBrokerageListView extends NavigationMixin(LightningElement) {
    @track data = [];
    @track columns = columns;
    @track error;
    @track showEditfrom = false;
    @track showiframe = false;
    @track showspinner = false;
    @track isPresent = false;

    @api sortedDirection = 'asc';
    @api sortedBy = 'Invoice_Number__c';

    @api searchKey = '';
    @api searchKeystatus = '';

    // Pagination
    @track page = 1;
    @track items = [];
    @track startingRecord = 1;
    @track endingRecord = 0;
    @track pageSize = 10;
    @track totalRecountCount = 0;
    @track totalPage = 0;

    // Row selection
    @track allSelectedRows = [];
    isPageChanged = false;
    initialLoad = true;

    // Instance variables
    CPBIId; // Should be tracked or reactive
    wiredResult;

    @wire(getCpBrokerages, {
        searchKey: '$searchKey',
        sortBy: '$sortedBy',
        sortDirection: '$sortedDirection',
        searchKeystatus: '$searchKeystatus'
    })
    wiredBrokerages(result) {
        this.wiredResult = result;
        const { data, error } = result || {};
        if (data) {
            console.log(' Data received:', JSON.parse(JSON.stringify(data)));
            console.log(' Data received:', JSON.stringify(data));
            // if(data.length > 0 && data[0].Brokerage_Type__c != null){
            //     this.columns = data[0].Brokerage_Type__c === 'Base Brokerage'? basecolumns : othercolumns;
            // }    
            const flattened = data.map(row => {
                return {
                    ...row,
                    Legal_Entity_Name: row.Legal_Entity__r ? row.Legal_Entity__r.Name : ''
                };
            });

            this.processRecords(flattened);
            this.error = undefined;
        } else if (error) {
            console.error('Error in wiredBrokerages:', error);
            this.error = error;
            this.data = [];
            this.items = [];
            this.totalRecountCount = 0;
            this.totalPage = 0;
        }
    }

    processRecords(records) {
        this.items = records || [];
        this.totalRecountCount = this.items.length;
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);

        this.page = 1;
        this.displayRecordPerPage(this.page);
    }

    previousHandler() {
        this.isPageChanged = true;
        if (this.page > 1) {
            this.page -= 1;
            this.displayRecordPerPage(this.page);
        }
        this._restoreSelections();
    }

    nextHandler() {
        this.isPageChanged = true;
        if (this.page < this.totalPage) {
            this.page += 1;
            this.displayRecordPerPage(this.page);
        }
        this._restoreSelections();
    }

    displayRecordPerPage(page) {
        const startIndex = (page - 1) * this.pageSize;
        const endIndex = Math.min(startIndex + this.pageSize, this.totalRecountCount);
        
        this.data = this.items.slice(startIndex, endIndex);
        this.startingRecord = startIndex + 1;
        this.endingRecord = endIndex;
    }

    sortColumns(event) {
        this.sortedBy = event.detail.fieldName;
        this.sortedDirection = event.detail.sortDirection;
        if (this.wiredResult) refreshApex(this.wiredResult);
    }

    onRowSelection(event) {
        if (!this.isPageChanged || this.initialLoad) {
            if (this.initialLoad) this.initialLoad = false;
            this.allSelectedRows = event.detail.selectedRows;
        } else {
            this.isPageChanged = false;
            this.initialLoad = true;
        }
    }

    _restoreSelections() {
        const selectedIds = this.allSelectedRows.map(r => r.Id);
        const table = this.template.querySelector('lightning-datatable');
        if (table) table.selectedRows = selectedIds;
    }

    handleKeyChange(event) {
        this.searchKey = (event.target.value || '').trim();
     
        setTimeout(() => {
            if (this.wiredResult) refreshApex(this.wiredResult);
        }, 300);
    }

    handleKeystatusChange(event) {
        this.searchKeystatus = (event.target.value || '').trim();
        setTimeout(() => {
            if (this.wiredResult) refreshApex(this.wiredResult);
        }, 300);
    }

    callRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        const actionName = action.name;
        const recId = row.Id;
        
        this.CPBIId = recId; 

        console.log('recId::' + recId + ':::Action:::' + actionName);

        if (actionName === 'Generate') {
            this.showEditfrom = true;
        } else if (actionName === 'View') {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: recId,
                    objectApiName: 'CP_Brokerage__c',
                    actionName: 'view'
                }
            });
        } else if (actionName === 'Preview') {
             this[NavigationMixin.Navigate]({
    type: "standard__webPage",
    attributes: {
        url: window.location.origin + '/apex/ShowCP_InvoicePreview?id=' + this.CPBIId
    }
});
        }
    }

    closeTermsAndConditions() {
        this.showEditfrom = false;
    }

    closeTermsAndConditions2() {
        this.showiframe = false;
    }

    handleSubmit(event) {
        this.showspinner = true;
        console.log('onsubmit event recordEditForm' + JSON.stringify(event.detail.fields));
    }

    handlegstchange(event) {
        console.log('Handle Change GST Applicable' + event.detail.value);
        if (event.detail.value === 'Yes') {
            CheckGst({ InvId: this.CPBIId })
                .then((result) => {
                    this.isPresent = result;
                    if (!this.isPresent) {
                        this.dispatchEvent(new ShowToastEvent({
                            title: "Warning!",
                            message: 'Please update your GST Number through your profile update',
                            variant: 'warning',
                            mode: 'dismissable'
                        }));
                    }
                })
                .catch((error) => {
                    this.error = error;
                    this.dispatchEvent(new ShowToastEvent({
                        title: "Error",
                        message: 'An error occurred while checking GST status',
                        variant: 'error'
                    }));
                });
        }
    }

    handleSuccess(event) {
        this.showEditfrom = false;
        this.showspinner = false;
        
        // Refresh the data
        if (this.wiredResult) refreshApex(this.wiredResult);
        
        this.dispatchEvent(new ShowToastEvent({
            title: "Success",
            message: "Operation completed successfully",
            variant: "success"
        }));

        this[NavigationMixin.Navigate]({
            type: "standard__webPage",
            attributes: {
               url: window.location.origin + '/apex/ShowCP_InvoicePreview?id=' + this.CPBIId
            }
        });
    }
}