import { LightningElement, track, wire } from 'lwc';
import getOpenComplaints from '@salesforce/apex/OpenComplaintsDashboardController.getOpenComplaints';
import { refreshApex } from '@salesforce/apex';

export default class LiveOpenComplaintsDashboard extends LightningElement {
    @track data = [];
    fullData = [];
    wiredResult;

    selectedRM = '';
    selectedTL = '';
    selectedProject = '';
    selectedSegment = '';

    selectedYear = null;
    selectedMonth = null;
    startDate = null;
    endDate = null;

    rmOptions = [];
    tlOptions = [];
    projectOptions = [];
    segmentOptions = [];

    sortedBy = '';
    sortDirection = 'asc';

    totalCount = 0;
    overdueCount = 0;
    withinSlaCount = 0;

    get yearOptions() {
        const currentYear = new Date().getFullYear();
        let years = [];
    
        for(let i = 0; i < 5; i++){
            years.push({
                label: (currentYear - i).toString(),
                value: (currentYear - i).toString()
            });
        }
        return years;
    }

    get monthOptions() {
        return [
            { label: 'January', value: '1' },
            { label: 'February', value: '2' },
            { label: 'March', value: '3' },
            { label: 'April', value: '4' },
            { label: 'May', value: '5' },
            { label: 'June', value: '6' },
            { label: 'July', value: '7' },
            { label: 'August', value: '8' },
            { label: 'September', value: '9' },
            { label: 'October', value: '10' },
            { label: 'November', value: '11' },
            { label: 'December', value: '12' }
        ];
    }

    // ================================
    // WIRE APEX
    // ================================
    @wire(getOpenComplaints,{selectedYear: '$selectedYear', selectedMonth: '$selectedMonth', startDate: '$startDate', endDate: '$endDate'})
    wiredOpenComplaints(result) {
        console.log('result: ', result);
        this.wiredResult = result;
        if (result.data) {
            this.prepareData(result.data);
        }
    }

    // ================================
    // REFRESH BUTTON
    // ================================
    handleRefresh() {
        refreshApex(this.wiredResult);
    }

    // ================================
    // PREPARE DATA + SUMMARY
    // ================================
    prepareData(result) {
        console.log('result: ', result);
        this.fullData = result.map(row => {

            //const isOverdue = row.isOverdue === true;
            let isOverdue = false;
            let overdueTextCaseOpen = '';
            let overdueTextCaseReopen = '';
            if(row.caseType === 'Open'){
                isOverdue = row.isOverdueCaseOpen === true;
                overdueTextCaseOpen = isOverdue ? 'YES' : '';
            }else if(row.caseType === 'Reopened'){
                isOverdue = row.isOverdueCaseReopen === true;
                overdueTextCaseReopen = isOverdue ? 'YES' : '';
            }
            console.log('row: ', row);
            return {
                ...row,
                overdueTextCaseOpen: overdueTextCaseOpen,
                overdueTextCaseReopen: overdueTextCaseReopen,
                overdueClass: isOverdue ? 'overdue-text' : '',
                rowClass: isOverdue ? 'overdue-row' : ''
            };
        });

        //this.data = [...this.fullData];

        //this.calculateSummary();
        this.generateFilterOptions();
        this.applyFilters();
    }

    // ================================
    // GENERATE DROPDOWN VALUES
    // ================================
    generateFilterOptions() {

        const rmSet = new Set();
        const tlSet = new Set();
        const projectSet = new Set();
        const segmentSet = new Set();

        this.fullData.forEach(row => {
            if (row.rmName) rmSet.add(row.rmName);
            if (row.tlName) tlSet.add(row.tlName);
            if (row.project) projectSet.add(row.project);
            if (row.segment) segmentSet.add(row.segment);
        });

        this.rmOptions = [{ label: 'All', value: '' },
        ...[...rmSet].map(val => ({ label: val, value: val }))
        ];

        this.tlOptions = [{ label: 'All', value: '' },
        ...[...tlSet].map(val => ({ label: val, value: val }))
        ];

        this.projectOptions = [{ label: 'All', value: '' },
        ...[...projectSet].map(val => ({ label: val, value: val }))
        ];

        this.segmentOptions = [{ label: 'All', value: '' },
            ...[...segmentSet].map(val => ({ label: val, value: val }))
        ];
    }

    // ================================
    // FILTER HANDLERS
    // ================================
    handleRMChange(event) {
        this.selectedRM = event.detail.value;
        this.applyFilters();
    }

    handleTLChange(event) {
        this.selectedTL = event.detail.value;
        this.applyFilters();
    }

    handleProjectChange(event) {
        /*this.filters = {
            ...this.filters,
            selectedProject: event.detail.value
        };*/
        this.selectedProject = event.detail.value;
        this.applyFilters();
    }

    handleSegmentChange(event) {
        /*this.filters = {
            ...this.filters,
            selectedSegment: event.detail.value
        };*/
        this.selectedSegment = event.detail.value;
        this.applyFilters();
    }

    handleYearChange(event){
        //this.selectedYear = parseInt(event.detail.value);
        this.selectedYear = event.detail.value;
        //this.handleRefresh();
    }
    
    handleMonthChange(event){
        //this.selectedMonth = parseInt(event.detail.value);
        this.selectedMonth = event.detail.value;
        //this.handleRefresh();
    }
    
    handleStartDateChange(event){
        this.startDate = event.detail.value;
    }
    
    handleEndDateChange(event){
        this.endDate = event.detail.value;
    }

    handleReset() {
        this.selectedRM = '';
        this.selectedTL = '';
        this.selectedProject = '';
        this.selectedSegment = '';
        this.selectedYear = null;
        this.selectedMonth = null;
        this.startDate = null;
        this.endDate = null;
        this.applyFilters();
    }

    // ================================
    // APPLY FILTERS
    // ================================
    applyFilters() {

        this.data = this.fullData.filter(row => {

            return (
                (this.selectedRM === '' || row.rmName === this.selectedRM) &&
                (this.selectedTL === '' || row.tlName === this.selectedTL) &&
                (this.selectedProject === '' || row.project === this.selectedProject) &&
                (this.selectedSegment === '' || row.segment === this.selectedSegment)
            );
        });

        this.calculateSummary();
    }


    // ================================
    // SUMMARY CALCULATION
    // ================================
    calculateSummary() {
        this.totalCount = this.data.length;
        this.overdueCount = this.data.filter(r => r.isOverdue).length;
        this.withinSlaCount = this.totalCount - this.overdueCount;
    }

    // ================================
    // COLUMN SORTING
    // ================================
    handleSort(event) {

        const field = event.currentTarget.dataset.field;

        if (this.sortedBy === field) {
            this.sortDirection = this.sortDirection === 'asc' ? 'desc' : 'asc';
        } else {
            this.sortDirection = 'asc';
        }

        this.sortedBy = field;

        this.data.sort((a, b) => {

            let val1 = a[field] || '';
            let val2 = b[field] || '';

            if (typeof val1 === 'number') {
                return this.sortDirection === 'asc' ? val1 - val2 : val2 - val1;
            } else {
                return this.sortDirection === 'asc'
                    ? val1.localeCompare(val2)
                    : val2.localeCompare(val1);
            }
        });
    }

    // ================================
    // SORT ICONS
    // ================================
    get getSortIcon() {

        return {
            caseNumber: this.getIcon('caseNumber'),
            customerName: this.getIcon('customerName'),
            customerNumber: this.getIcon('customerNumber'),
            segment: this.getIcon('segment'),
            project: this.getIcon('project'),
            unit: this.getIcon('unit'),
            tower: this.getIcon('tower'),
            phase: this.getIcon('phase'),
            rmName: this.getIcon('rmName'),
            tlName: this.getIcon('tlName'),
            caseType: this.getIcon('caseType'),
            caseOpenDate: this.getIcon('caseOpenDate'),
            caseReopenDate: this.getIcon('caseReopenDate'),
            caseOpenTime: this.getIcon('caseOpenTime'),
            ageMinutesCaseOpen: this.getIcon('ageMinutesCaseOpen'),
            ageHoursCaseOpen: this.getIcon('ageHoursCaseOpen'),
            ageDaysCaseOpen: this.getIcon('ageDaysCaseOpen'),
            ageMinutesCaseReopen: this.getIcon('ageMinutesCaseReopen'),
            ageHoursCaseReopen: this.getIcon('ageHoursCaseReopen'),
            ageDaysCaseReopen: this.getIcon('ageDaysCaseReopen'),
        };
    }

    getIcon(field) {
        if (this.sortedBy !== field) return '';
        return this.sortDirection === 'asc' ? '↑' : '↓';
    }

    // ================================
    // EXPORT
    // ================================
    handleExport() {

        let csv = '';
        const headers = ['Case Number', 'Customer', 'SAP Customer Number', 'Segment', 'Project', 'Unit', 'Tower', 'Phase', 'RM', 'TL', 'Type of Case', 'Date of Case Open', 'Time of Case Open', 'Ageing Minutes Case Open', 'Ageing Hours Case Open', 'Ageing Days Case Open', 'Case Open Overdue > 1 Day', 'Date of Case Reopen', 'Time of Case Reopen', 'Ageing Minutes Case Reopen', 'Ageing Hours Case Reopen', 'Ageing Days Case Reopen', 'Case Reopen Overdue > 1 Day'];
        csv += headers.join(',') + '\n';

        this.data.forEach(row => {
            csv += [
                row.caseNumber,
                row.customerName,
                row.customerNumber,
                row.segment,
                row.project,
                row.unit,
                row.tower,
                row.phase,
                row.rmName,
                row.tlName,
                row.caseType,
                row.caseOpenDate,
                row.caseOpenTime,
                row.ageMinutesCaseOpen,
                row.ageHoursCaseOpen,
                row.ageDaysCaseOpen,
                row.overdueTextCaseOpen,
                row.caseReopenDate,
                row.caseReopenTime,
                row.ageMinutesCaseReopen,
                row.ageHoursCaseReopen,
                row.ageDaysCaseReopen,
                row.overdueTextCaseReopen
            ].join(',') + '\n';
        });

        const element = document.createElement('a');
        element.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        element.download = 'Open Complaints Report.csv';
        element.click();
    }
}