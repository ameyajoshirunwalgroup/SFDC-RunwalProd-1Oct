import { LightningElement, wire, api, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';
import getBrokerageSummary from '@salesforce/apex/CPBookingController.getBrokerageSummary';
const columns = [{
    label: 'Booking',
    fieldName: 'Booking_Name__c',
    type: 'text',
    initialWidth: 130,
    sortable: true
},
{
    label: 'Project',
    fieldName: 'Project__c',
    initialWidth: 130,
    sortable: true
},
{
    label: 'Tower - Unit',
    fieldName: 'Tower_Unit__c',
    initialWidth: 130,
    sortable: true
},
{
    label: 'Customer Name',
    fieldName: 'Customer_Name__c',
    initialWidth: 130,
    sortable: true
},
{
    label: 'Brokerage Scheme',
    fieldName: 'Brokerage_Scheme_Name__c',
    initialWidth: 150,
    sortable: true
},
{
    label: 'Base Brokerage',
    fieldName: 'Base_Brokerage__c',
    initialWidth: 150,
    type: 'percentfixed',
    cellAttributes: { alignment: 'right' },
    sortable: true
},
{
    label: 'Additional Brokerage',
    fieldName: 'Additional_Brokerage__c',
    initialWidth: 150,
    type: 'percentfixed',
    sortable: true
},
{
    label: 'Total Brokerage %',
    fieldName: 'Brokerage__c',
    initialWidth: 150,
    type: 'percentfixed',
    sortable: true
},
{
    label: 'Total Brokerage(In Rs)',
    fieldName: 'Total_Brokerage__c',
    initialWidth: 150,
    type:'currency',
    sortable: true
},
{
    label: 'Total Agreement Value',
    fieldName: 'Total_Agreement_Value__c',
    initialWidth: 150,
    type:'currency',
    sortable: true
},
{
    label: 'Status',
    fieldName: 'Status__c',
    initialWidth: 130,
    sortable: true
},
{
    type: "button",initialWidth: 130,label: 'Action',
     typeAttributes: {
        label: 'View',
        name: 'View',
        title: 'View',
        disabled: false,
        value: 'view',
        iconPosition: 'left'
    }
}

];
export default class CpBrokerageSummaryListView extends NavigationMixin(LightningElement) {
    @track value;
    @track error;
    @track data;
    @api sortedDirection = 'asc';
    @api sortedBy = 'Name';
    @api BssearchKey = '';
    @api searchKeyBooking = '';
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
    pdfString;
    url;
    isPageChanged = false;
    initialLoad = true;
    mapoppNameVsOpp = new Map();
    @track brokeragesummaryData = {}

    columnHeader = ['Booking Name', 'Brokerage Scheme Name', 'Base Brokerage', 'Additional Brokerage',
                    'Brokerage', 'Total Brokerage', 'Total Agreement Value', 'Status' ]


    get options() {
        return [
            { label: '--None--', value: '' },
            { label: 'Due', value: 'Due' },
            { label: 'Not Due', value: 'Not Due' }
         ];
    }
    @wire(getBrokerageSummary, { BssearchKey: '$BssearchKey', searchKeyBooking:'$searchKeyBooking' })
    wiredAccounts({ error, data }) {
        if (data) {
            this.processRecords(data);
            this.brokeragesummaryData = data
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
        this.BssearchKey = event.target.value;
        var data = [];
        for (var i = 0; i < this.items.length; i++) {
            if (this.items[i] != undefined && this.items[i].Name.includes(this.BssearchKey)) {
                data.push(this.items[i]);
            }
        }
        this.processRecords(data);
    }
    handleKeyBookingChange(event) {
        this.searchKeyBooking = event.target.value;
        var data = [];
        for (var i = 0; i < this.items.length; i++) {
            if (this.items[i] != undefined && this.items[i].Name.includes(this.searchKeyBooking)) {
                data.push(this.items[i]);
            }
        }
        this.processRecords(data);
    }
    callRowAction(event) {
        console.log('Inside callRowAction');
        const recId = event.detail.row.Id;
        const actionName = event.detail.action.name;
        console.log('recId::' + recId + ':::Action:::' + actionName);
        if (actionName === 'View') {

            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: recId,
                    objectApiName: 'Brokerage_Summary__c',
                    actionName: 'view'
                }
            })

        }

    }
    exportData(){
        // Prepare a html table
        let doc = '<table>';
        // Add styles for the table
        doc += '<style>';
        doc += 'table, th, td {';
        doc += '    border: 1px solid black;';
        doc += '    border-collapse: collapse;';
        doc += '}';          
        doc += '</style>';
        // Add all the Table Headers
        doc += '<tr>';
        this.columnHeader.forEach(element => {            
            doc += '<th>'+ element +'</th>'           
        });
        doc += '</tr>';
        // Add the data rows
        this.brokeragesummaryData.forEach(record => {
            doc += '<tr>';
            doc += '<th>'+record.Booking_Name__c+'</th>'; 
            doc += '<th>'+record.Brokerage_Scheme_Name__c+'</th>'; 
            doc += '<th>'+record.Base_Brokerage__c+'</th>';
            doc += '<th>'+record.Additional_Brokerage__c+'</th>';
            doc += '<th>'+record.Brokerage__c+'</th>';
            doc += '<th>'+record.Total_Brokerage__c+'</th>';
            doc += '<th>'+record.Total_Agreement_Value__c+'</th>';
            doc += '<th>'+record.Status__c+'</th>'; 
            doc += '</tr>';
        });
        doc += '</table>';
        var element = 'data:application/vnd.ms-excel,' + encodeURIComponent(doc);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        // use .csv as extension on below line if you want to export data as csv
        downloadElement.download = 'Brokerage Summary.xls';
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }
           
}