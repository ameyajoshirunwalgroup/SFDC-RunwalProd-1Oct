import { LightningElement, wire, api, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';
import getBrokerageSummary from '@salesforce/apex/CPBookingController.getOTPs';
const columns = [{
    label: 'Project',
    fieldName: 'Project_Name__c',
    type: 'text',
    
    sortable: true
},
{
    label: 'Customer Name',
    fieldName: 'Customer_Name__c',
    
    sortable: true
},
{
    label: 'Customer Visited On Site',
    fieldName: 'Customer_Site_Visit_On__c',
    
    sortable: true
},
{
    label: 'OTP',
    fieldName: 'Generated_OTP__c',
    
    sortable: true
},
{
    label: 'OTP Generated On',
    fieldName: 'OTP_Generated_on__c',
    
    sortable: true
},
{
    type: "button",label: 'Action',
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
export default class CpOTPListView extends NavigationMixin(LightningElement) {
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
    @track pageSize = 25;
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

    columnHeader = ['Name', 'Customer Name', 'Customer Site Visit On', 'Generated OTP',
                    'Sourcing Manager', 'Project Name']


    
    @wire(getBrokerageSummary, { custname: '$searchKeyBooking', projectname:'$BssearchKey' })
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
                    objectApiName: 'OTP__c',
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
            doc += '<th>'+record.Name+'</th>'; 
            doc += '<th>'+record.Customer_Name__c+'</th>'; 
            doc += '<th>'+record.Customer_Site_Visit_On__c+'</th>'; 
            doc += '<th>'+record.Generated_OTP__c+'</th>';
            doc += '<th>'+record.Sourcing_Manager__c+'</th>';
            doc += '<th>'+record.Project_Name__c+'</th>';
            doc += '</tr>';
        });
        doc += '</table>';
        var element = 'data:application/vnd.ms-excel,' + encodeURIComponent(doc);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        // use .csv as extension on below line if you want to export data as csv
        downloadElement.download = 'OTP.xls';
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }
}