import { LightningElement, track, wire } from 'lwc';
import getMissedCalls from '@salesforce/apex/MissedCallDashboardController.getMissedCalls';
import { refreshApex } from '@salesforce/apex';

export default class LiveMissedCallDashboard extends LightningElement {

    @track data = [];
    fullData = [];
    wiredResult;

    selectedRM = '';
    selectedTL = '';
    selectedProject = '';

    rmOptions = [];
    tlOptions = [];
    projectOptions = [];

    sortedBy = '';
    sortDirection = 'asc';

    totalCount = 0;
    overdueCount = 0;
    withinSlaCount = 0;

    // ================================
    // WIRE APEX
    // ================================
    @wire(getMissedCalls)
    wiredMissedCalls(result) {
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

        this.fullData = result.map(row => {

            const isOverdue = row.isOverdue === true;

            return {
                ...row,
                overdueText: isOverdue ? 'YES' : 'NO',
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

        this.fullData.forEach(row => {
            if (row.rmName) rmSet.add(row.rmName);
            if (row.tlName) tlSet.add(row.tlName);
            if (row.project) projectSet.add(row.project);
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
        this.selectedProject = event.detail.value;
        this.applyFilters();
    }

    handleReset() {
        this.selectedRM = '';
        this.selectedTL = '';
        this.selectedProject = '';
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
                (this.selectedProject === '' || row.project === this.selectedProject)
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
            customerName: this.getIcon('customerName'),
            customerNumber: this.getIcon('customerNumber'),
            project: this.getIcon('project'),
            unit: this.getIcon('unit'),
            tower: this.getIcon('tower'),
            phase: this.getIcon('phase'),
            rmName: this.getIcon('rmName'),
            tlName: this.getIcon('tlName'),
            communicationType: this.getIcon('communicationType'),
            inboundDeskAgent: this.getIcon('inboundDeskAgent'),
            callDate: this.getIcon('callDate'),
            callTime: this.getIcon('callTime'),
            ageMinutes: this.getIcon('ageMinutes'),
            ageHours: this.getIcon('ageHours'),
            ageDays: this.getIcon('ageDays'),
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
        const headers = ['Customer', 'SAP Customer Number', 'Project', 'Unit', 'Tower', 'Phase', 'RM', 'TL', 'Communication Type', 'Inbound Desk Agent', 'Date of Call', 'Time of Call', 'Ageing Minutes', 'Ageing Hours', 'Ageing Days', 'Call Overdue > 6 Hours'];
        csv += headers.join(',') + '\n';

        this.data.forEach(row => {
            csv += [
                row.customerName,
                row.customerNumber,
                row.project,
                row.unit,
                row.tower,
                row.phase,
                row.rmName,
                row.tlName,
                row.communicationType,
                row.inboundDeskAgent,
                row.callDate,
                row.callTime,
                row.ageMinutes,
                row.ageHours,
                row.ageDays,
                row.overdueText
            ].join(',') + '\n';
        });

        const element = document.createElement('a');
        element.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        element.download = 'MissedCallsReport.csv';
        element.click();
    }
}