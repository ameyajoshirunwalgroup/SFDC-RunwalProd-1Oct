import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getTableData from '@salesforce/apex/MarketingDashboardController.getTableData';
import generateCSV from '@salesforce/apex/MarketingDashboardController.generateCSV';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import LEAD_OBJECT from '@salesforce/schema/Lead';
import LEAD_SOURCE_FIELD from '@salesforce/schema/Lead.LeadSource';
import COMPANY_TARGET_OBJECT from '@salesforce/schema/Company_Target__c';
import VERTICALS_FIELD from '@salesforce/schema/Company_Target__c.Verticals__c';
import getProjects from '@salesforce/apex/MarketingDashboardController.getProjects';

export default class MarketingDashboard extends NavigationMixin(LightningElement) {
    // State management
    @track selectedTable = 'table1'; // Default Table [cite: 16]
    @track selectedYear = new Date().getFullYear().toString(); // Default Current Year [cite: 16]
    //@track selectedMonth = (new Date().getMonth() + 1).toString(); // Default Current Month [cite: 16]
    selectedMonthLabels = [];
    selectedMonthValues = [];
    selectedLeadSourceLabels = [];
    selectedLeadSourceValues = [];
    @track data = [];
    @track columns = [];
    @track isLoading = false; // Spinner control [cite: 5]
    @track monthLabels = [];
    @track drillDownColumns = [];
    @track totals = { leads: 0, walkins: 0, bookings: 0 };
    @track grandTotalRev = 0;
    @track totalSpnd = 0;
    @track spndPct = 0;
    @track leadSourceOptions = [];
    verticalOptions = [];
    projectOptions = [];
    @track selectedSource;
    @track selectedProject = 'All';
    @track selectedDateRange;
    @track showMonthsDropdown = false;
    @track showLeadSourceDropdown = false;

    // Options for Table Selection Dropdown [cite: 3]
    get tableOptions() {
        return [
            { label: 'Lead, Walk-in & Booking', value: 'table1' },
            { label: 'Lead Status', value: 'table2' },
            { label: 'Junk %', value: 'table3' },
            { label: 'Walking to booking %', value: 'table4' },
            { label: 'Digital Budget', value: 'table5' },
            { label: 'Media Summary', value: 'table6' },
            { label: 'Spends Summary', value: 'table7' }
        ];
    }

    // Year Dropdown: 5 years backwards from current 
    get yearOptions() {
        const currentYear = new Date().getFullYear();
        let years = [];
        years.push({ label: '--Select Year--', value: '' });
        for (let i = 0; i < 5; i++) {
            const y = (currentYear - i).toString();
            years.push({ label: y, value: y });
        }
        return years;
    }

    // Month Dropdown 
   /* get monthOptions() {
        return [
            //{ label: '--None (Yearly)--', value: '' },
            { label: 'January', value: '1', checked: false }, { label: 'February', value: '2', checked: false },
            { label: 'March', value: '3', checked: false }, { label: 'April', value: '4', checked: false },
            { label: 'May', value: '5', checked: false }, { label: 'June', value: '6', checked: false },
            { label: 'July', value: '7', checked: false }, { label: 'August', value: '8', checked: false },
            { label: 'September', value: '9', checked: false }, { label: 'October', value: '10', checked: false },
            { label: 'November', value: '11', checked: false}, { label: 'December', value: '12', checked: false }
        ];
    }*/

    get dateRangeOptions() {
        return [
            //{ label: '--Select--', value: '' },
            { label: 'Last 7 Days', value: 'LAST_N_DAYS:7' }, { label: 'Last 15 Days', value: 'LAST_N_DAYS:15' },
            { label: 'Last 30 Days', value: 'LAST_N_DAYS:30' }, { label: 'Last Month', value: 'LAST_MONTH' },
            { label: 'Last 3 Months', value: 'LAST_N_MONTHS:3' },
            { label: 'Last 6 Months', value: 'LAST_N_MONTHS:6' }, { label: 'Current Month', value: 'THIS_MONTH' },
            { label: 'Current FY', value: 'THIS_FISCAL_YEAR' }, { label: 'Previous FY', value: 'LAST_FISCAL_YEAR' },
            { label: 'Custom', value: 'Custom' }
        ];
    }

    @track monthOptions = [
        { label: 'January', value: '1', checked: false },
        { label: 'February', value: '2', checked: false },
        { label: 'March', value: '3', checked: false },
        { label: 'April', value: '4', checked: false },
        { label: 'May', value: '5', checked: false },
        { label: 'June', value: '6', checked: false },
        { label: 'July', value: '7', checked: false },
        { label: 'August', value: '8', checked: false },
        { label: 'September', value: '9', checked: false },
        { label: 'October', value: '10', checked: false },
        { label: 'November', value: '11', checked: false },
        { label: 'December', value: '12', checked: false }
    ];

    @wire(getObjectInfo, { objectApiName: LEAD_OBJECT })
    leadObjectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$leadObjectInfo.data.defaultRecordTypeId',
        fieldApiName: LEAD_SOURCE_FIELD
    })
    leadSourceValues({ data, error }) {
        if (data) {
            this.leadSourceOptions = [
                //{ label: '--None--', value: '', checked: false },
    
                ...data.values.map(item => ({
                    label: item.label,
                    value: item.value,
                    checked: false
                }))
            ];
        } else if (error) {
            console.error(error);
        }
        console.log('this.leadSourceOptions: ', this.leadSourceOptions);
    }

    @wire(getObjectInfo, { objectApiName: COMPANY_TARGET_OBJECT })
    companyTargetObjectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$companyTargetObjectInfo.data.defaultRecordTypeId',
        fieldApiName: VERTICALS_FIELD
    })
    verticalValues({ data, error }) {
        if (data) {
            this.verticalOptions = [
                { label: '--None--', value: '' },
    
                ...data.values.map(item => ({
                    label: item.label,
                    value: item.value
                }))
            ];
        } else if (error) {
            console.error(error);
        }
    }

    @wire(getProjects, { table: '$selectedTable' })
    wiredProjects({ error, data }) {
        if (data) {
            this.projectOptions = data;
        } else if (error) {
            console.error(error);
        }
    }

   

    // Check if we should show the custom HTML Table 1 [cite: 9]
    get isTable1() {
        return this.selectedTable === 'table1';
    }
    get isTable2() {
        return this.selectedTable === 'table2';
    }
    get isTable3() {
        return (this.selectedTable === 'table3' && this.selectedYear == '');
    }
    get isTable3_1() {
        return (this.selectedTable === 'table3' && this.selectedYear != '');
    }
    get isTable4() {
        return (this.selectedTable === 'table4' && this.selectedDateRange == '');
    }
    get isTable4_1() {
        return (this.selectedTable === 'table4' && this.selectedDateRange != '');
    }
    get isTable5() {
        return this.selectedTable === 'table5';
    }
    get isTable6() {
        return this.selectedTable === 'table6';
    }
    get isTable7() {
        return this.selectedTable === 'table7';
    }

    get showFilters() {
        return this.selectedTable === 'table1' || this.selectedTable === 'table2'  || this.selectedTable === 'table3' || this.selectedTable === 'table4' || this.selectedTable === 'table5' || this.selectedTable === 'table6' || this.selectedTable === 'table7';
    }

    get showDateRange() {
        return this.selectedTable != 'table1' && this.selectedTable != 'table3' && this.selectedTable != 'table5';
    }

    get showLeadSource() {
        return this.selectedTable != 'table1' && this.selectedTable != 'table5';
    }

    get showYearMonth() {
        return this.selectedTable === 'table1' || this.selectedTable == 'table3' || this.selectedTable === 'table5' || this.selectedDateRange === 'Custom';
    }

    get selectedMonthsLabel() {
        return this.selectedMonthLabels.length
            ? this.selectedMonthLabels.join(', ')
            : '--Select Months--';
    }
    get selectedLeadSourceLabel() {
        return this.selectedLeadSourceLabels.length
            ? this.selectedLeadSourceLabels.join(', ')
            : '--Select Sources--';
    }

    generateMonthLabels() {
        const labels = [];
        const monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
        let d = new Date();
        d.setMonth(d.getMonth() - 11);
    
        for (let i = 0; i < 12; i++) {
            labels.push(`${monthNames[d.getMonth()]}-${d.getFullYear().toString().substr(-2)}`);
            d.setMonth(d.getMonth() + 1);
        }
        this.monthLabels = labels;
    }

    // Check if data exists to show "No Data" message [cite: 17]
    get hasData() {
        return this.data.length > 0;
    }

    // Lifecycle hook to load initial data
    connectedCallback() {
        if(this.selectedTable != 'table3'){
            const currentMonth = (new Date().getMonth() + 1).toString();
            this.monthOptions = this.monthOptions.map(item => {
                if(item.value === currentMonth) {
                    item.checked = true;
                    this.selectedMonthLabels.push(item.label);
                    this.selectedMonthValues.push(item.value);
                }
                return item;
            });
        }
        

        if(this.selectedTable != 'table6'){
            this.selectedSource = 'Digital';
        }
        if(this.selectedTable === 'table4'){
            this.selectedDateRange = '';
        }else{
            this.selectedDateRange = 'THIS_MONTH';
        }
        if(this.selectedTable === 'table3'){
            this.selectedYear = '';
            this.selectedMonthValues = [];
        }
        this.loadDashboardData();
    }

    handleTableChange(event) {
        this.selectedTable = event.detail.value;
        if(['table3', 'table4'].includes(this.selectedTable)) {
            this.generateMonthLabels();
        }
        if(this.selectedTable != 'table6'){
            this.selectedSource = 'Digital';
        }else{
            this.selectedSource = '';
        }
        if(this.selectedTable === 'table4'){
            this.selectedDateRange = '';
        }else{
            this.selectedDateRange = 'THIS_MONTH';
        }
        if(this.selectedTable === 'table3'){
            this.selectedYear = '';
            this.selectedMonthValues = [];
        }
        this.triggerLoad();
    }

   

    toggleMonthsDropdown() {
        this.showMonthsDropdown = !this.showMonthsDropdown;
    }
    toggleLeadSourceDropdown() {
        this.showLeadSourceDropdown = !this.showLeadSourceDropdown;
    }

    handleMonthSelect(event) {
        const value = event.target.value;
        this.monthOptions = this.monthOptions.map(item => {
            if(item.value === value) {
                item.checked = event.target.checked;
            }
            return item;
        });
        this.selectedMonthLabels = this.monthOptions
            .filter(item => item.checked)
            .map(item => item.label);

        this.selectedMonthValues = this.monthOptions
            .filter(item => item.checked)
            .map(item => item.value);

            this.triggerLoad();
    }

    handleLeadSourceSelect(event) {
        const value = event.target.value;
        this.leadSourceOptions = this.leadSourceOptions.map(item => {
            if(item.value === value) {
                item.checked = event.target.checked;
            }
            return item;
        });
        this.selectedLeadSourceLabels = this.leadSourceOptions
            .filter(item => item.checked)
            .map(item => item.label);

        this.selectedLeadSourceValues = this.leadSourceOptions
            .filter(item => item.checked)
            .map(item => item.value);

            this.triggerLoad();
    }

    // Handle Dropdown Changes [cite: 4]
    handleFilterChange(event) {
        const field = event.target.label;
        if (field === 'Select Table') this.selectedTable = event.detail.value;
        if (field === 'Year') this.selectedYear = event.detail.value;
        //if (field === 'Month') this.selectedMonths = event.detail.value;
        if (field === 'Lead Source') this.selectedSource = event.detail.value;
        if (field === 'Vertical') this.selectedSource = event.detail.value;
        if (field === 'Date Range') this.selectedDateRange = event.detail.value;
        if (field === 'Project') this.selectedProject = event.detail.value;
        this.triggerLoad();
    }

    // Debounced trigger to avoid rapid consecutive Apex calls
    loadDebounce;
    triggerLoad() {
        if (this.loadDebounce) {
            clearTimeout(this.loadDebounce);
        }
        this.loadDebounce = setTimeout(() => this.loadDashboardData(), 200);
    }

    // Fetch Data from Apex
    async loadDashboardData() {
        this.isLoading = true; // Show spinner [cite: 5]
        this.data = []; // Clear previous data

        // request-id guard to avoid race condition overriding newer state
        this._reqId = (this._reqId || 0) + 1;
        const myReq = this._reqId;

        try {
            // Setup columns for lightning-datatable (Tables 2-7)
            this.setupColumns();

            // Call Apex [cite: 4]
            const result = await getTableData({
                tableType: this.selectedTable,
                year: this.selectedYear,
                months: this.selectedMonthValues,
                sources: this.selectedLeadSourceValues,
                dateRange: this.selectedDateRange,
                project: this.selectedProject
            });

            // Ignore stale responses
            if (myReq !== this._reqId) {
                return;
            }

            // Defensive mapping + unified total row detection
            const isTotalRow = (r) => {
                const p = typeof r?.project === 'string' ? r.project.toLowerCase() : '';
                const m = typeof r?.media === 'string' ? r.media.toLowerCase() : '';
                return p === 'total' || m === 'total';
            };

            const safeResult = Array.isArray(result) ? result : [];
            this.data = safeResult.map(row => ({
                ...row,
                totalClass: isTotalRow(row) ? 'grand-total-row' : ''
            }));
            if(this.selectedTable === 'table6'){
                this.grandTotalRev = result[0].globalRev;
                this.totalSpnd = result[0].globalSpnd;
                this.spndPct = result[0].spndPct;

                let lSum = 0, wSum = 0, bSum = 0;

                this.data = result.map((row, index) => {
                    lSum += row.leads; wSum += row.walkins; bSum += row.bookings;
                    return {
                        ...row,
                        isFirst: index === 0,
                        rowSpan: result.length // Dynamic value for HTML
                    };
                });

                this.totals = { leads: lSum, walkins: wSum, bookings: bSum };
            }
        } catch (error) {
            // Keep one concise error log
            // eslint-disable-next-line no-console
            console.error('Error loading data:', error);
            this.data = [];
        } finally {
            this.isLoading = false; // Hide spinner [cite: 5]
        }
    }

    setupColumns() {
        // Table 2: Lead Statuses (Dynamic Columns) [cite: 19, 21]
        if (this.selectedTable === 'table2') {
            this.columns = [
                { label: 'Project', fieldName: 'project', type: 'text' },
                { label: 'New', fieldName: 'New', type: 'number' },
                { label: 'Contacted', fieldName: 'Contacted', type: 'number' },
                { label: 'Interested', fieldName: 'Interested', type: 'number' },
                { label: 'VCVP', fieldName: 'VCVP', type: 'number' },
                { label: 'Visit Done', fieldName: 'VisitDone', type: 'number' },
                { label: 'Lost', fieldName: 'Lost', type: 'number' },
                { label: 'Junk', fieldName: 'Junk', type: 'number' },
                { label: 'Total', fieldName: 'Total', type: 'number', 
                  cellAttributes: { class: 'slds-theme_shade slds-font-weight_bold' } }
            ];
        } 
        // Tables 3, 4, 5: 12-Month Trend [cite: 24, 29, 34]
        else if (['table3', 'table4', 'table5'].includes(this.selectedTable)) {
            this.columns = [
                { label: 'Project', fieldName: 'project', type: 'text' }
                // Remaining 12 month columns would be pushed here dynamically by Apex keys
            ];
        }
        // Table 6: Digital Budget [cite: 39]
        /*else if (this.selectedTable === 'table6') {
            this.columns = [
                { label: 'Project', fieldName: 'project', type: 'text' },
                { label: 'Spends Planned', fieldName: 'planned', type: 'currency' },
                { label: 'Spends Approved', fieldName: 'approved', type: 'currency' },
                { label: 'Actual Spends', fieldName: 'actual', type: 'currency' },
                { label: 'Balance Amount', fieldName: 'balance', type: 'currency' },
                { label: 'Balance Days', fieldName: 'days', type: 'number' }
            ];
        }
        // Table 7: Media Summary [cite: 43]
        else if (this.selectedTable === 'table7') {
            this.columns = [
                { label: 'Media', fieldName: 'media', type: 'text' },
                { label: 'Leads', fieldName: 'leads', type: 'number' },
                { label: 'Walk-ins', fieldName: 'walkins', type: 'number' },
                { label: 'Bookings', fieldName: 'bookings', type: 'number' },
                { label: 'Total Revenue (Cr.)', fieldName: 'revenue', type: 'number' },
                { label: 'Spends (Cr.)', fieldName: 'spends', type: 'text' }
            ];
        }*/
    }
    

    closeModal() {
        this.isModalOpen = false;
    }

    // Export to CSV Logic [cite: 6]
    downloadCSV() {
        const rows = this.data || [];
        console.log('--rows: ', rows);
        if (!rows.length) return;
        console.log('--downloadCSV');
        // Prefer the datatable column order when available; exclude UI-only fields like totalClass
        const fieldOrder = (this.columns?.map(c => c.fieldName) || Object.keys(rows[0] || {}))
            .filter(f => f && f !== 'totalClass');
        console.log('--fieldOrder: ', fieldOrder);
        const escapeCsv = (v) => {
            const s = v == null ? '' : String(v);
            return /[",\r\n]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s;
        };

        const header = fieldOrder.map(escapeCsv).join(',');
        const body = rows.map(r => fieldOrder.map(f => escapeCsv(r[f])).join(',')).join('\r\n');
        const csv = `${header}\r\n${body}`;

        // Use Blob + ObjectURL for better encoding handling
        const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
        const link = document.createElement('a');
        link.href = URL.createObjectURL(blob);
        link.download = `${this.selectedTable}_Export.csv`;
        link.click();
        URL.revokeObjectURL(link.href);
    }

    handleExport() {
        const tableType = this.selectedTable;
        console.log('tableType: ', tableType);
        generateCSV({ tableType: tableType, year: this.selectedYear, months: this.selectedMonthValues, sources: this.selectedLeadSourceValues, dateRange: this.selectedDateRange, project: this.selectedProject })
            .then(result => {
                Object.keys(result).forEach(fileName => {
                    const base64Data = result[fileName];
                    const csvContent = decodeURIComponent(
                        escape(window.atob(base64Data))
                    );
                    const csvData = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csvContent);
                    const link = document.createElement('a');
                    link.href = csvData;
                    link.download = fileName;
                    document.body.appendChild(link);
                    link.click();
                    document.body.removeChild(link);
                });
            })
            .catch(error => {
                console.error('CSV Download Failed:', error);
            });
    }
}