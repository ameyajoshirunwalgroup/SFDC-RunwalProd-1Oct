import { LightningElement, wire, api, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import getallkickerbookings from '@salesforce/apex/CPBookingController.CPKickerBookings';
import getvalueandcount from '@salesforce/apex/CPBookingController.getBrokerageSummaryCountValue';
const columns = [{
    label: 'Booking Name',
    fieldName: 'Name',
    type: 'text',

    sortable: true
},
{
    label: 'Tower - Unit',
    fieldName: 'Unit_Number__c',

    sortable: true
},
{
    label: 'Project',
    fieldName: 'RW_Project_Name__c',

    sortable: true
},
{
    label: 'Agreement Value',
    fieldName: 'Agreement_Value_for_brokers__c',
    type:'currency',
    sortable: true,
    cellAttributes: { alignment: 'left' }
}

];
export default class CpAllBookingKickerIncentive extends NavigationMixin(LightningElement) {
    @track value;
    @track error;
    @track data;
    @track Count;
    @track Agvalue;
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
    @track allcountvalue = {}

    // get URL Parameter
    currentPageReference = null;
    urlStateParameters = null;
    /* Params from Url */
    @track bId = null;
    @track bsId = null;
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            this.setParametersBasedOnUrl();
        }
    }
    setParametersBasedOnUrl() {
        this.bId = this.urlStateParameters.c__kId || null;
        this.bsId = this.urlStateParameters.c__bsId || null;
        console.log('Bid::'+this.bId);
        console.log('bsId::'+this.bsId);
    }
    connectedCallback(){
        console.log('Rendered::'+this.bId);
        getallkickerbookings({kickerId : this.bId}).then(result=>{
            this.processRecords(result);
            this.brokeragesummaryData = result
            this.error = undefined;
        }).catch(error =>{
            window.alert("error :"+JSON.stringify(error));
        })
        getvalueandcount({SummaryId : this.bsId}).then(result=>{
            this.allcountvalue = result;
            this.Count = this.allcountvalue[0].Count_of_Bookings__c;
            this.Agvalue = this.allcountvalue[0].Aggregate_Agreement_Value__c;
        }).catch(error =>{
            window.alert("error :"+JSON.stringify(error));
        })
        
    
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

    
    
    
}