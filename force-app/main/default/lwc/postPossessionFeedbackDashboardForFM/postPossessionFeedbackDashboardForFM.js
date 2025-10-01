import { LightningElement, api, track, wire } from 'lwc';
import feedbacDefaultRecords from '@salesforce/apex/PostPossessionDashboardForFmCtrl.getDefaultRecords';
import feedbackRecords from '@salesforce/apex/PostPossessionDashboardForFmCtrl.getRecords';
import npsSummaryForYear from '@salesforce/apex/PostPossessionDashboardForFmCtrl.npsSummaryForYear';
import npsSummaryYearMonthValues from '@salesforce/apex/PostPossessionDashboardForFmCtrl.npsSummaryYearMonthValues';
import getTeam from '@salesforce/apex/PostPossessionDashboardForFmCtrl.getTeam';
import eventWiseData from '@salesforce/apex/PostPossessionDashboardForFmCtrl.eventWiseData';
import npsWiseData from '@salesforce/apex/PostPossessionDashboardForFmCtrl.npsWiseData';
import npsWiseDataPPD from '@salesforce/apex/PostPossessionDashboardForFmCtrl.npsWiseDataPPD';
import overAllDataExp from '@salesforce/apex/PostPossessionDashboardForFmCtrl.overAllDataExp';
import { NavigationMixin } from 'lightning/navigation';

export default class PostPossessionFeedbackDashboardForFM extends LightningElement {

    @track selectedPeriod = 'LAST_N_DAYS:30';
    @track selectedYear = "-Select-";
    @track selectedMonth;
    fbList;
    npsSummary;
    hideYearMonth = true;
    team;
    teamStr;
    eventWiseDetails;
    eventWiseFbType = null;
    showEventWiseData = false;
    showMainTable = true;
    showSummary = false;
    npsWiseDetails;
    showNPSDataTable = false;
    allTeam = false;
    exportDetails;
    overAllData;
    disableAllExpBtn = false;
    yearMonthValues;

    noDataFound;
    
    reportOptions = [
        {label: 'Post Possession Handover', value: 'Post Possession Handover'}
    ];

    /*@api LWCFunction(){
       console.log('-team-', team); 
       console.log('-dateRange-', dateRange);
       console.log('-year-', year);
       console.log('-month-', month);
    }*/

    

    @wire(getTeam)
    getUserTeam({data, error}){
        if(data){
            let teamdata = data.split(':');
            this.teamStr = teamdata;
            this.team = teamdata[0];
            if(teamdata[1] == 'All'){
                this.allTeam = true;
            }
        }else if(error){
            console.log('Error: ', error);
        }
    }

    @wire(feedbacDefaultRecords)
    defautlFeedbacks({data, error}){
        if(data){
            this.fbList = data;
            console.log('--data: ', data);
            if(this.fbList != null){
                this.showSummary = true;
                this.noDataFound = false;
            }
            
        }else if(error){
            console.log('Error: ', error);
        }
    }

    @wire(npsSummaryYearMonthValues)
    npsSummaryYearMonthData({data, error}){
        if(data){
            this.yearMonthValues = data;
            console.log('--npsSummary: ', data);
        }else if(error){
            console.log('Error: ', error);
        }
    }

    @wire(npsSummaryForYear)
    npsSummaryForYearData({data, error}){
        if(data){
            this.npsSummary = data;
            console.log('--npsSummary: ', data);
        }else if(error){
            console.log('Error: ', error);
        }
    }

    periodOptions =[
        { label: '-Select-', value: '' },
        { label: 'Last 7 Days', value: 'LAST_N_DAYS:7' },
        { label: 'Last 15 Days', value: 'LAST_N_DAYS:15' },
        { label: 'Last 30 Days', value: 'LAST_N_DAYS:30' },
        { label: 'Last 90 Days', value: 'LAST_N_MONTHS:3' },
        { label: 'Last 180 Days', value: 'LAST_N_MONTHS:6' },
        { label: 'Current Month', value: 'THIS_MONTH' },
        { label: 'Current FY', value: 'THIS_FISCAL_YEAR' },
        { label: 'Previous FY', value: 'LAST_FISCAL_YEAR' },
        { label: 'Custom', value: 'Custom' },
    ];
    @track today = new Date();
    yearOptions;

    monthOptions = [
        {label : 'January', value : '1'},
        {label : 'February', value : '2'},
        {label : 'March', value : '3'},
        {label : 'April', value : '4'},
        {label : 'May', value : '5'},
        {label : 'June', value : '6'},
        {label : 'July', value : '7'},
        {label : 'August', value : '8'},
        {label : 'September', value : '9'},
        {label : 'October', value : '10'},
        {label : 'November', value : '11'},
        {label : 'December', value : '12'}
    ]

    handlePeriodChange(event){
        this.tskList = null;
        this.selectedPeriod = event.detail.value;
        console.log('selected Period: ', this.selectedPeriod);
        if(this.selectedPeriod == 'Custom'){
            this.hideYearMonth = false;

            var year = this.today.getFullYear();
            var year1 = year -1;
            var year2 = year -2;
            var year3 = year -3;
            var year4 = year - 4;
            this.yearOptions = [
                {label : year, value : year},
                {label : year1, value : year1},
                {label : year2, value : year2},
                {label : year3, value : year3},
                {label : year4, value : year4}
            ];
        }else{
						this.selectedYear = '-Select-';
						this.selectedMonth = null;
            this.hideYearMonth = true;
        }
        feedbackRecords({dateRange : this.selectedPeriod, year : this.selectedYear, month : this.selectedMonth})
        .then(result => {
            this.fbList = result;
            console.log('this.fbList: ' + this.fbList);
            if(this.fbList != null){
                this.showSummary = true;
                this.noDataFound = false;
            }else{
                this.showSummary = false;
                this.noDataFound = true;
            }
        })
        .catch(error => {
            this.fbList = undefined;
        })
        
    }

    handleYearChange(event){
        this.selectedYear = event.detail.value;
        console.log('selected Period: ', this.selectedYear);
        feedbackRecords({dateRange : this.selectedPeriod, year : this.selectedYear, month : this.selectedMonth})
        .then(result => {
            this.fbList = result;
            if(this.fbList != null){
                this.showSummary = true;
                this.noDataFound = false;
            }else{
                this.showSummary = false;
                this.noDataFound = true;
            }
        })
        .catch(error => {
            this.fbList = undefined;
        })
    }

    handleMonthChange(event){
        this.selectedMonth = event.detail.value;
        console.log('selected Period: ', this.selectedMonth);
        feedbackRecords({dateRange : this.selectedPeriod, year : this.selectedYear, month : this.selectedMonth})
        .then(result => {
            this.fbList = result;
            if(this.fbList != null){
                this.showSummary = true;
                this.noDataFound = false;
            }else{
                this.showSummary = false;
                this.noDataFound = true;
            }
        })
        .catch(error => {
            this.fbList = undefined;
        })
    }

    exportOverAllData(event){

        console.log('--exportOverAllData--: ');
        overAllDataExp({userTeam : this.team, dateRange : this.selectedPeriod, year : this.selectedYear, month : this.selectedMonth})
        .then(result => {
            this.overAllData = result;
            this.exportDataToCSV(this.overAllData);
        })
        .catch(error => {
            this.overAllData = undefined;
        })
    }

    detaildReport(event){
        var fbType = event.currentTarget.id;
        fbType = fbType.replace(/-0/g,'');
        this.eventWiseFbType = fbType;
        this.showEventWiseData = true;
        this.showMainTable = false;
        this.showSummary = false;
        this.showNPSDataTable = false;
        this.disableAllExpBtn = true;
        eventWiseData({team : this.team , dateRange : this.selectedPeriod, year : this.selectedYear, month : this.selectedMonth, eventType : fbType})
        .then(result => {
            this.eventWiseDetails = result;
        })
        .catch(error => {
            this.eventWiseDetails = undefined;
        })
    }

    goBack(event){
        var fbType = event.currentTarget.id;
        fbType = fbType.replace(/-0/g,'');
        this.eventWiseFbType = fbType;
        this.showEventWiseData = false;
        this.showMainTable = true;
        this.showSummary = true;
        this.showNPSDataTable = false;
        this.disableAllExpBtn = false;
    }

    npsWiseReport(event){
        var fbType = event.currentTarget.id;
        var proj = event.currentTarget.name;
        var npsVal = event.currentTarget.dataset.nps;
        fbType = fbType.replace(/-0/g,'');
        console.log('fbType: ', fbType);
        console.log('project: ', proj);
        console.log('nps: ', npsVal);
        this.showNPSDataTable = true;
        this.eventWiseFbType = fbType;
        this.showEventWiseData = false;
        this.showMainTable = false;
        this.showSummary = false;
        this.disableAllExpBtn = true;
        npsWiseData({fbType : fbType, team : this.team , dateRange : this.selectedPeriod, year : this.selectedYear, month : this.selectedMonth, project : proj, nps : npsVal})
        .then(result => {
            this.npsWiseDetails = result;
        })
        .catch(error => {
            this.npsWiseDetails = undefined;
        })
    }

    npsWiseReportPPD(event){
        var fbType = event.currentTarget.id;
        var proj = event.currentTarget.name;
        var npsVal = event.currentTarget.dataset.nps;
        fbType = fbType.replace(/-0/g,'');
        console.log('fbType: ', fbType);
        console.log('project: ', proj);
        console.log('nps: ', npsVal);
        this.showNPSDataTable = true;
        this.eventWiseFbType = fbType;
        this.showEventWiseData = false;
        this.showMainTable = false;
        this.showSummary = false;
        this.disableAllExpBtn = true;
        npsWiseDataPPD({fbType : fbType, team : this.team , dateRange : this.selectedPeriod, year : this.selectedYear, month : this.selectedMonth, project : proj, nps : npsVal})
        .then(result => {
            this.npsWiseDetails = result;
        })
        .catch(error => {
            this.npsWiseDetails = undefined;
        })
    }

    openRec(event){
        var recId = event.currentTarget.id;
        console.log('recId: ', recId);
        var recName = event.currentTarget.name;
        console.log('recName: ', recName);
        var url = 'https://runwal.lightning.force.com/lightning/r/WhatsApp_Feedback__c/'+recName+'/view';
        window.open(url);

        /*this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recName,
                actionName: 'view',
                objectApiName: 'WhatsApp_Feedback__c'
            }
        });*/
    }

    exportData(event){
        console.log('exportData:-- ');
        console.log('event.currentTarget.name:-- ', event.currentTarget.name);
        if(event.currentTarget.name == 'eventWiseDetailsExp'){
            console.log('event.currentTarget.name:-- ', event.currentTarget.name);
            this.exportDataToCSV(this.eventWiseDetails);
        }else if(event.currentTarget.name == 'npsWiseDetailsExp'){

            this.exportDataToCSV(this.npsWiseDetails);
        }
    }

    exportDataToCSV(expDetails){
        console.log('exportData:-- ');
        console.log('expDetails:-- ', expDetails);
        let csvContent = 'Id,Name,Project,CRN,Opportunity Id,Opportunity Name,Feedback Type,Frequency,NPS\n';
        expDetails.forEach(record => {
            console.log('record: ',record);
            let recId = record.Id;
            let name = record.Name;
            let project = record.Project__c;
            let crn = record.CRN__c;
            let opportunity = record.Opportunity__c;
            let oppName = record.Opportunity_Name__c;
            let fbType = record.Feedback_Type__c;
            let freq = (record.Post_Possession_Frequency_Days__c != undefined) ? record.Post_Possession_Frequency_Days__c : 60;
            let nps = record.NPS__c;

            csvContent += `"${recId}","${name}","${project}","${crn}","${opportunity}","${oppName}","${fbType}","${freq}","${nps}"\n`;
        });

        console.log('csvContent::', csvContent);

        // Create Blob and download CSV file

        // Creating anchor element to download
        let downloadElement = document.createElement('a');

        // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvContent);
        downloadElement.target = '_self';
        // CSV File Name
        downloadElement.download = 'Details.csv';
        // below statement is required if you are using firefox browser
        document.body.appendChild(downloadElement);
        // click() Javascript function to download CSV file
        downloadElement.click();

    }
    goBackToAllFbsPage(event){
        window.open('https://runwal.lightning.force.com/apex/WhatsAppFeedbackReportsPage','_self');
    }
}