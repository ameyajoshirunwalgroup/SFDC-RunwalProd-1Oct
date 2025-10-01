import { LightningElement, wire, api, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';
import getopportunites from '@salesforce/apex/CPProfileUpdate.getopps';
const columns = [{
    label: 'Customer Name',
    fieldName: 'Name',
    type: 'text',
    initialWidth: 130,
},
{
    label: 'Project',
    fieldName: 'Project_Name_formula__c',
    initialWidth: 130,
},
{
    label: 'Type Of Client',
    fieldName: 'RW_Type_of_Client__c',
    initialWidth: 130,
},
{
    label: 'CIF Form Number',
    fieldName: 'RW_CIF_form_number__c',
    initialWidth: 150,
},
{
    label: 'Stage',
    fieldName: 'StageName',
    initialWidth: 150,
},
{
    label: 'Sourcing Manager',
    fieldName: 'RW_Sourcing_Manager__c',
    initialWidth: 150,
},
{
    label: 'Number of Total Visits',
    fieldName: 'Number_of_Total_Visits__c',
    initialWidth: 150,
},
{
    label: 'Booking',
    fieldName: 'Booking1__c',
    initialWidth: 150,
},
{
    label: 'Unit',
    fieldName: 'Unit1__c',
    initialWidth: 150,
},
{
    label: 'Booking Date',
    fieldName: 'RW_Booking_Date_Opp__c',
    initialWidth: 150,
},
{
    label: 'Budget',
    fieldName: 'RW_Budget__c',
    initialWidth: 130,
},
{
    label: 'Close Date',
    fieldName: 'CloseDate',
    initialWidth: 130,
    sortable: "true"

    
},
{
    label: 'Sales Manager',
    fieldName: 'RW_Sales_Associate__c',
    initialWidth: 130,
},
{
    label: 'SM Comments',
    fieldName: 'RW_Sales_Manager_Comment__c',
    initialWidth: 130,
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
export default class CpOpportunityListView extends NavigationMixin(LightningElement)  {
    @track value;
    @track error;
    @track data;
    @track sortedDirection = 'desc';
    @track sortedBy = 'CloseDate';
    @api BssearchKey = '';
    @api searchKeyproject = '';
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
    @track opportunityData = {}

    columnHeader = ['Customer Name', 'Project', 'Type Of Client','CIF Form Number','Stage','Sourcing Manager',
                    'No. of Visits', 'Booking', 'Unit', 'Booking Date','Budget','Close Date','Sales Manager','SM Comments']


    
    @wire(getopportunites, { custname: '$BssearchKey', projectname:'$searchKeyproject',orderBy: "$sortedBy", direction: "$sortedDirection" })
    wiredOpp({ error, data }) {
        if (data) {
            this.processRecords(data);
            this.opportunityData = data
            this.error = undefined;
        } else if (error) {
            this.error = error;
            window.alert('Error::'+JSON.stringify(this.error));
            this.data = undefined;
        }
    }
    onSort(event) {
        this.sortedBy = event.detail.fieldName;
        this.sortedDirection = event.detail.sortDirection;
      }

    processRecords(data) {
        console.log('Inside Process Records');
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
    handleKeyprojectChange(event) {
        this.searchKeyproject = event.target.value;
        var data = [];
        for (var i = 0; i < this.items.length; i++) {
            if (this.items[i] != undefined && this.items[i].Name.includes(this.searchKeyproject)) {
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
                    objectApiName: 'Opportunity',
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
        this.opportunityData.forEach(record => {
            doc += '<tr>';
            doc += '<th>'+record.Name+'</th>'; 
            doc += '<th>'+record.Project_Name_formula__c+'</th>'; 
            doc += '<th>'+record.RW_Type_of_Client__c+'</th>';
            doc += '<th>'+record.RW_CIF_form_number__c+'</th>';
            doc += '<th>'+record.StageName+'</th>';
            doc += '<th>'+record.RW_Sourcing_Manager__c+'</th>';
            doc += '<th>'+record.RW_Number_of_Visits__c+'</th>';
            doc += '<th>'+record.Booking__c+'</th>';
            doc += '<th>'+record.RW_Project_Unit__c+'</th>';
            doc += '<th>'+record.RW_Booking_Date_Opp__c+'</th>';
            doc += '<th>'+record.RW_Budget__c+'</th>';
            doc += '<th>'+record.CloseDate+'</th>';
            doc += '<th>'+record.RW_Sales_Associate__c+'</th>'; 
            doc += '<th>'+record.RW_Sales_Manager_Comment__c+'</th>';  
            doc += '</tr>';
        });
        doc += '</table>';
        var element = 'data:application/vnd.ms-excel,' + encodeURIComponent(doc);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        // use .csv as extension on below line if you want to export data as csv
        downloadElement.download = 'Opportunities.xls';
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }
}