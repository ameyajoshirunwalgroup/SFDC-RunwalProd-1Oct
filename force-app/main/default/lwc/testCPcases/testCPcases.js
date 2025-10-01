import { LightningElement, wire, api,track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
// import getUserIdToManagerNameMap from '@salesforce/apex/WhatsAppFeedbackBotReportsController.getUserIdToManagerNameMap';
// import getProjectFeedback from '@salesforce/apex/WhatsAppFeedbackBotReportsController.getProjectFeedback';
// import getFeedbackData from '@salesforce/apex/WhatsAppFeedbackBotReportsController.getFeedbackData';
import getUnprocessedCases from '@salesforce/apex/CPDashboardController.getUnprocessedCases';
import getRegisteredCaseCountByProject from '@salesforce/apex/CPDashboardController.getRegisteredCaseCountByProject';
import getUnRegisteredCaseCountByProject from '@salesforce/apex/CPDashboardController.getUnRegisteredCaseCountByProject';
// import getTotalRegisteredCaseCountByProject from '@salesforce/apex/WhatsAppFeedbackBotReportsController.getTotalRegisteredCaseCountByProject';
// import getTotalUnRegisteredCaseCountByProject from '@salesforce/apex/WhatsAppFeedbackBotReportsController.getTotalUnRegisteredCaseCountByProject';
import getCaseData from '@salesforce/apex/CPDashboardController.getCaseData';
import getTotalCaseCount from '@salesforce/apex/CPDashboardController.getTotalCaseCount';
// import getProjectCase from '@salesforce/apex/WhatsAppFeedbackBotReportsController.getProjectCase';
import getFilteredCasesNew from '@salesforce/apex/CPDashboardController.getFilteredCasesNew';
// import user_field from '@salesforce/schema/Case.Opportunity__c';
// import getCaseCgetUnRegisteredCaseCountByProjectountByUser from '@salesforce/apex/WhatsAppFeedbackBotReportsController.getCaseCountByUser';
import Case_Redirect from '@salesforce/label/c.Case_Redirect';
import getCaseDataBasedonCustomLabel from '@salesforce/apex/CPDashboardController.getCaseDataBasedonCustomLabel';

export default class Test extends LightningElement {    
    @api period;
    @api year;
    @api month;
    @api new_user;

    @track label = Case_Redirect;
      
    // @api newuser;
    feedbackList;
    filteredCases;
    feedbackData;
    caseData;
    caseListData;
    unProcessedCaseCount = 0;
    registeredcaseList;
    totalregisteredcaseList;
    unregisteredcaseList;
    totalunregisteredcaseList
    totalcaseList;
    combinedCaseList // New property for combined list
    // @track caseCounts;
    @track error;
    @track registeredprojectCount;
    @track unregisteredprojectCount;
    wiredUnProcessedCasesResult;
    wiredRegisteredcaseResult;
    wiredUnregisteredcaseListResult;
    wiredTotalcaseListResult;
    wired12MonthsSummary;
    YearlyCase;
    TotalExportList;
    showFilteredCases = false;
    showFeedbackTable = false;
    show12MonthsSummaryValue = false;
    valuenew;
    userIdToManagerNameMap;
    ExcelcolumnHeader = ["Case Number", "Project", "Status", "CP Name", "Created Date", "Closed Date", "Closed By", "Registered/Unregistered","Current Stage"];
    ExcelAllcolumnHeader = ["Case Number", "Project", "Status", "CP Name", "Created Date", "Closed Date", "Closed By", "Registered/Unregistered","Current Stage"];


    @wire(getUnprocessedCases, {
        period: '$period', Year: '$year', Month: '$month', new_user: '$new_user'})
    wiredUnProcessedCaseCounts(result) {
        this.wiredUnProcessedCasesResult = result;
        const { error, data } = result;
        console.log('inside :: getUnprocessedCases');
        console.log('period :: ', this.period);
        console.log('year :: ', this.year);
        console.log('month :: ', this.month);
        console.log('new_user :: ', this.new_user);
        if (data) {
            console.log('getUnprocessedCases data'+  data);
            if(data>0){
                this.unProcessedCaseCount = data;
                console.log('unProcessedCaseCount '+  this.unProcessedCaseCount);
            }else{
                this.unProcessedCaseCount = 0;
                console.log('unProcessedCaseCount '+  this.unProcessedCaseCount);       
            }
            
        } else if (error) {
            this.error = error;
            // this.caseCounts = undefined;
            console.error('error data:-'+error);
        }
    }

   


    @wire(getRegisteredCaseCountByProject, {
        period: '$period', Year: '$year', Month: '$month', new_user: '$new_user'})
    wiredRCaseCounts(result) {
        this.wiredRegisteredcaseResult = result;
        const { error, data } = result;
        console.log('inside :: getRegisteredCaseCountByProject');
        console.log('period :: ', this.period);
        console.log('year :: ', this.year);
        console.log('month :: ', this.month);
        console.log('new_user :: ', this.new_user);
        if (data) {
            this.showFeedbackTable = true;
            // this.caseCounts = data;
            // this.error = undefined;
            // console.log('data:-'+data);
            console.log('Registered Case data:-'+JSON.stringify(data));
            // data = JSON.parse(JSON.stringify(data));
            this.registeredcaseList = JSON.parse(JSON.stringify(data));

            this.registeredcaseList.forEach((rcase, index) => {
                if (index === 0) {
                    rcase.isProjectvisible = true;
                    rcase.rowSpan = this.registeredcaseList.length;
                } else {
                    rcase.isProjectvisible = false;
                }
            });

            // this.updateCombinedList();

        } else if (error) {
            this.error = error;
            // this.caseCounts = undefined;
            console.error('error data:-'+error);
        }
    }


    
    // @wire(getTotalRegisteredCaseCountByProject, {
    //     period: '$period', Year: '$year', Month: '$month'
    // })
    // wiredTRCaseCounts({ error, data }) {
    //     console.log('inside :: getTotalRegisteredCaseCountByProject');
    //     console.log('period :: ', this.period);
    //     console.log('year :: ', this.year);
    //     console.log('month :: ', this.month);
    //     if (data) {
    //         // this.caseCounts = data;
    //         this.error = undefined;
    //         // console.log('data:-'+data);
    //         console.log('Total Registered Case data:-'+JSON.stringify(data));
    //         this.totalregisteredcaseList = data;
    //         this.updateCombinedList();
    //         console.log('Registered Case data:-'+this.totalregisteredcaseList);
    //     } else if (error) {
    //         this.error = error;
    //         // this.caseCounts = undefined;
    //         console.error('error data:-'+error);
    //     }
    // }


    @wire(getUnRegisteredCaseCountByProject, {
        period: '$period', Year: '$year', Month: '$month', new_user: '$new_user'})
    wiredUrCaseCounts(result) {
        this.wiredUnregisteredcaseListResult = result;
        const { error, data } = result;
        console.log('inside :: getUnRegisteredCaseCountByProject');
        console.log('period :: ', this.period);
        console.log('year :: ', this.year);
        console.log('month :: ', this.month);
        console.log('new_user :: ', this.new_user);
        if (data) {
            // this.caseCounts = data;
            this.showFeedbackTable = true;
            // this.error = undefined;
            // console.log('data:-'+data);
            console.log('UnRegistered Case data:-'+JSON.stringify(data));
            this.unregisteredcaseList = JSON.parse(JSON.stringify(data));

            this.unregisteredcaseList.forEach((unrcase, index) => {
                if (index === 0) {
                    unrcase.isProjectvisible = true;
                    unrcase.rowSpan = this.unregisteredcaseList.length;
                } else {
                    unrcase.isProjectvisible = false;
                }
            });

            // this.updateCombinedList();

        } else if (error) {
            this.error = error;
            // this.caseCounts = undefined;
            console.error('error data:-'+error);
        }
    }
    

    // @wire(getTotalUnRegisteredCaseCountByProject, {
    //     period: '$period', Year: '$year', Month: '$month'
    // })
    // wiredTURCaseCounts({ error, data }) {
    //     if (data) {
    //         // this.caseCounts = data;
    //         this.error = undefined;
    //         // console.log('data:-'+data);
    //         console.log('Total UnRegistered Case data:-'+JSON.stringify(data));
    //         this.totalunregisteredcaseList = data;
    //         this.updateCombinedList();
    //         console.log('UnRegistered Case data:-'+this.totalunregisteredcaseList);
    //     } else if (error) {
    //         this.error = error;
    //         // this.caseCounts = undefined;
    //         console.error('error data:-'+error);
    //     }
    // }



    @wire(getTotalCaseCount, {
        period: '$period', Year: '$year', Month: '$month', new_user: '$new_user'})
    wiredTotalCaseCounts(result) {
        this.wiredTotalcaseListResult = result;
        const { error, data } = result;
        console.log('inside :: getTotalCaseCount');
        console.log('period :: ', this.period);
        console.log('year :: ', this.year);
        console.log('month :: ', this.month);
        console.log('new_user :: ', this.new_user);
        if (data) {
            this.showFeedbackTable = true;
            // this.caseCounts = data;
            // this.error = undefined;
            // console.log('data:-'+data);
            console.log('totalcaseList Case data:-'+JSON.stringify(data));
            this.totalcaseList = JSON.parse(JSON.stringify(data));

            // this.unregisteredcaseList.forEach((feedback, index) => {
            //     if (index === 0) {
            //         feedback.isProjectvisible = true;
            //         feedback.rowSpan = this.unregisteredcaseList.length;
            //     } else {
            //         feedback.isProjectvisible = false;
            //     }
            // });

            // this.updateCombinedList();

        } else if (error) {
            this.error = error;
            // this.caseCounts = undefined;
            console.error('error data:-'+error);
        }
    }
    
    


    @wire(getCaseDataBasedonCustomLabel, {
        period: '$period', Year: '$year', Month: '$month', new_user: '$new_user'})
        showCaseDataBasedonCustomLabel(result) {
            this.wired12MonthsSummary = result;
            const { error, data } = result;
            if (data) {
                console.log('data'+data);
                this.show12MonthsSummaryValue = data;
                console.log('show12MonthsSummary'+this.show12MonthsSummary);
                this.show12MonthsSummaryData();
            } else if (error) {
                console.error('Error retrieving data:', error);
            }
        }
    



    show12MonthsSummaryData() {
        console.log('show12MonthsSummary data: ' + this.show12MonthsSummaryValue);
        // console.log('checkFieldValues this.questions: ' + JSON.stringify(this.questions));
        
        getCaseData()
            .then(result => {
                console.log('Result from Apex: ', result);
                console.log('getCaseData Data'+JSON.stringify(result));
                this.caseData = result;
                console.log('case data::', this.caseData);
            })
            .catch(error => {
                console.error('Error fetching data: ', error);
            });
    }


    // @wire(getCaseData)
    // wiredCaseData({ error, data }) {
    //     if (data) {
    //         this.caseData = data;
    //         console.log('case data::', this.caseData);
    //     } else if (error) {
    //         console.error('Error retrieving case data:', error);
    //     }
    // }

    // @wire(getUserIdToManagerNameMap)
    // wiredUserMap({ error, data }) {
    //     if (data) {
    //         this.userIdToManagerNameMap = data;
    //         console.log('User Id to Manager Name Map:', this.userIdToManagerNameMap);
    //     } else if (error) {
    //         console.error('Error fetching user map:', error);
    //     }
    // }
    // @wire(getProjectFeedback, {
    //     period: '$period', Year: '$year', Month: '$month'
    // })
    // wiredFeedback({ error, data }) {
    //     console.log('inside :: getProjectFeedback');
    //     console.log('period :: ', this.period);
    //     console.log('year :: ', this.year);
    //     console.log('month :: ', this.month);
    //     if (data) {
    //         data = JSON.parse(JSON.stringify(data));
    //         for (let i = 0; i < data.length; i++) {
    //             let rowSpancount = 1;
    //             let j = i + 1;
    //             for (; j < data.length ; j++) {

    //                 if (data[i].project == data[j].project) {
    //                     rowSpancount++;
    //                 } else {
    //                     break;
    //                 }
    //             }
    //             data[i].rowSpan = rowSpancount
    //             data[i].isProjectvisible = true;
    //             i = j - 1;
    //         }

    //         this.feedbackList = data;
    //         this.showFeedbackTable = true;
    //         //this.TotalExportList=this.feedbackList.ExportCase;
    //         console.log('TotalfeedbackList :: ', this.feedbackList);
    //         //console.log('TotalExportList :: ', this.TotalExportList);


    //     } else if (error) {
    //         console.error('Error fetching project feedback:', error);
    //     }
    // }

    // @wire(getProjectCase, {
    //     period: '$period', Year: '$year', Month: '$month'
    // })
    // wiredCase({ error, data }) {
    //     console.log('inside :: getProjectCase');
    //     console.log('period :: ', this.period);
    //     console.log('year :: ', this.year);
    //     console.log('month :: ', this.month);
    //         this.showFeedbackTable = true;
    //     if (data) {
    //         data = JSON.parse(JSON.stringify(data));
    //         // for (let i = 0; i < data.length; i++) {
    //         //     let rowSpancount = 1;
    //         //     let j = i + 1;
    //         //     for (; j < data.length ; j++) {

    //         //         if (data[i].project == data[j].project) {
    //         //             rowSpancount++;
    //         //         } else {
    //         //             break;
    //         //         }
    //         //     }
    //         //     data[i].rowSpan = rowSpancount
    //         //     data[i].isProjectvisible = true;
    //         //     i = j - 1;
    //         // }

    //         this.caseListData = data;
    //         //this.TotalExportList=this.feedbackList.ExportCase;
    //         console.log('caseListData :: ', this.caseListData);
    //         //console.log('TotalExportList :: ', this.TotalExportList);


    //     } else if (error) {
    //         console.error('Error fetching project case:', error);
    //     }
    // }


    @api resetTable() {


        console.log('inside reset');
        this.filteredCases = [];
        this.showFilteredCases = false;
    }
    handleCellClick(event) {
        this.showFeedbackTable = false;
        this.show12MonthsSummaryValue = false;
        let data = {};

        console.log('name:'+event.target.dataset.name);
        console.log('value:'+event.target.dataset.value);

        data[event.target.dataset.name] = event.target.dataset.value;
        if (event.target.dataset.name == 'projectName') {
            data['projectName'] = event.target.dataset.value;
        }
        
        else if (event.target.dataset.name == 'registeredCases') {
            console.log('event.target.dataset.projectname'+event.target.dataset.projectname);
            data['projectName'] = event.target.dataset.projectname;        
        }
        else if (event.target.dataset.name == 'openregisteredCases') {
            console.log('event.target.dataset.projectname'+event.target.dataset.projectname);
            data['projectName'] = event.target.dataset.projectname;        
        }
        else if (event.target.dataset.name == 'closedregisteredCases') {
            console.log('event.target.dataset.projectname'+event.target.dataset.projectname);
            data['projectName'] = event.target.dataset.projectname;        
        }
        else if (event.target.dataset.name == 'unregisteredCases') {
            console.log('event.target.dataset.projectname'+event.target.dataset.projectname);
            data['projectName'] = event.target.dataset.projectname;        
        }
        else if (event.target.dataset.name == 'openunregisteredCases') {
            console.log('event.target.dataset.projectname'+event.target.dataset.projectname);
            data['projectName'] = event.target.dataset.projectname;        
        }
        else if (event.target.dataset.name == 'closedunregisteredCases') {
            console.log('event.target.dataset.projectname'+event.target.dataset.projectname);
            data['projectName'] = event.target.dataset.projectname;        
        }
        else if(event.target.dataset.name == 'unProcessedCases' && (event.target.dataset.value == '' || event.target.dataset.value == undefined)){
            console.log('Inside Unprocessed');
            data[event.target.dataset.name] = 0;
           
        }
        else if (event.target.dataset.name == 'stage1' ||
                event.target.dataset.name == 'stage2' ||
                event.target.dataset.name == 'stage3' ||
                event.target.dataset.name == 'stage4' ||
                event.target.dataset.name == 'stage5' ||
                event.target.dataset.name == 'stage6' ||
                event.target.dataset.name == 'stage7' ||
                event.target.dataset.name == 'stage8' ||
                event.target.dataset.name == 'openstage1' ||
                event.target.dataset.name == 'openstage2' ||
                event.target.dataset.name == 'openstage3' ||
                event.target.dataset.name == 'openstage4' ||
                event.target.dataset.name == 'openstage5' ||
                event.target.dataset.name == 'openstage6' ||
                event.target.dataset.name == 'openstage7' ||
                event.target.dataset.name == 'openstage8' ||
                event.target.dataset.name == 'unstage1' ||
                event.target.dataset.name == 'unstage2' ||
                event.target.dataset.name == 'unstage3' ||
                event.target.dataset.name == 'unstage4' ||
                event.target.dataset.name == 'unstage5' ||
                event.target.dataset.name == 'unstage6' ||
                event.target.dataset.name == 'unstage7' ||
                event.target.dataset.name == 'unstage8' ||
                event.target.dataset.name == 'openunstage1' ||
                event.target.dataset.name == 'openunstage2' ||
                event.target.dataset.name == 'openunstage3' ||
                event.target.dataset.name == 'openunstage4' ||
                event.target.dataset.name == 'openunstage5' ||
                event.target.dataset.name == 'openunstage6' ||
                event.target.dataset.name == 'openunstage7' ||
                event.target.dataset.name == 'openunstage8'
                ) {
            console.log('event.target.dataset.projectname'+event.target.dataset.projectname);
            data['projectName'] = event.target.dataset.projectname;        
        }

        console.table('handleCellClick data og',data);

        console.log('data name'+data.name);
        console.log('data value'+data.value);
        
        console.table('handleCellClick data stringify',JSON.stringify(data));
        getFilteredCasesNew({
            data: JSON.stringify(data), period: this.period, Year: this.year, Month: this.month,new_user: this.new_user
        })
        .then(result => {
            console.log('result:::', result);
            this.filteredCases = result.map(item => {
                let formattedDate = null;
                let formattedCreatedDate = null;
                let closedBy = '';
                let CPStatus = '';
                let contactName = '';
                let projectName = '';
                let currentStage = '';

                if (item.RW_Project__r && item.RW_Project__r.Name) {
                    projectName = item.RW_Project__r.Name;
                } else {
                    projectName = '';
                }

                 if (item.Current_Stage__c != null) {
                     if(item.Current_Stage__c == 'CP-L1'){
                          currentStage = 'Stage 1 - Level 1';
                     }else if(item.Current_Stage__c == 'CP-L2'){
                          currentStage = 'Stage 2 - Level 1';
                     }else if(item.Current_Stage__c == 'CP-L3'){
                          currentStage = 'Stage 3 - Level 1';
                     }else if(item.Current_Stage__c == 'CP-L4'){
                          currentStage = 'Stage 3 - Level 2';
                     }else if(item.Current_Stage__c == 'CP-L5'){
                          currentStage = 'Stage 4 - Level 1';
                     } else if(item.Current_Stage__c == 'CP-L6'){
                          currentStage = 'Stage 4 - Level 2';
                     } else if(item.Current_Stage__c == 'CP-L7'){
                          currentStage = 'Stage 5 - Level 1';
                     } else if(item.Current_Stage__c == 'CP-L8'){
                          currentStage = 'Stage 5 - Level 2';
                     }
                } else {
                    currentStage = '';
                }

                if (item.Contact && item.Contact.Name) {
                    console.log('Registered/Unregistered' + item.Contact.Name);
                    contactName = item.Contact.Name;
                } else {
                    console.log('Registered/Unregistered' + item.Contact);
                    contactName = '';
                }

                if (item.OwnerId && item.Owner.Name) {
                    console.log('last modified by user' + item.Owner.Name);
                    closedBy = item.Owner.Name;
                }

                if (item.ClosedDate) {
                    const originalDate = new Date(item.ClosedDate);
                    const day = String(originalDate.getDate()).padStart(2, '0');
                    const month = String(originalDate.getMonth() + 1).padStart(2, '0');
                    const year = originalDate.getFullYear();
                    formattedDate = `${day}-${month}-${year}`;
                }

                if (item.CreatedDate) {
                    const originalCreatedDate = new Date(item.CreatedDate);
                    const createdDay = String(originalCreatedDate.getDate()).padStart(2, '0');
                    const createdMonth = String(originalCreatedDate.getMonth() + 1).padStart(2, '0');
                    const createdYear = originalCreatedDate.getFullYear();
                    formattedCreatedDate = `${createdDay}-${createdMonth}-${createdYear}`;
                }

                if (item.ContactId) {
                    CPStatus = 'Registered';
                } else {
                    CPStatus = 'Unregistered';
                }


                return {
                    ...item,
                    contactName: contactName,
                    projectName: projectName,
                    closedDateFormatted: formattedDate,
                    createdDateFormatted: formattedCreatedDate,
                    closedBy: closedBy,
                    CPStatus: CPStatus,
                    currentStage: currentStage
                };
            });
            this.showFilteredCases = true;
            console.log('this.filteredCases' + JSON.stringify(this.filteredCases));
            console.log('this.filteredCases' + this.filteredCases.length);
        })
        .catch(error => {
            console.error('Error fetching filtered cases:', error);
        });

    }


    goBack() {
        this.showFeedbackTable = true;
        // this.show12MonthsSummaryValue = false;
        this.showFilteredCases = false;

         Promise.all([
            refreshApex(this.wiredUnProcessedCasesResult),
            refreshApex(this.wiredRegisteredcaseResult),
            refreshApex(this.wiredUnregisteredcaseListResult),
            refreshApex(this.wiredTotalcaseListResult),
            refreshApex(this.wired12MonthsSummary)
        ]).catch(error => {
            console.error('Error refreshing Apex:', error);
        });

        // event.preventDefault();
    }

    exportData(event) {
        let doc = '<table>';
        doc += '<style>';
        doc += 'table, th, td {';
        doc += '    border: 1px solid black;';
        doc += '    border-collapse: collapse;';
        doc += '}';
        doc += '</style>';
        doc += '<tr>';
        this.ExcelcolumnHeader.forEach(element => {
            doc += '<th>' + element + '</th>'
        });
        doc += '</tr>';
        this.filteredCases.forEach(record => {
            let formattedDate = null;
            let formattedCreatedDate = null;
            let closedBy = '';
            let currentStage = '';
            let CPStatus = '';
            if (record.ClosedDate) {
                const originalDate = new Date(record.ClosedDate);
                const day = String(originalDate.getDate()).padStart(2, '0');
                const month = String(originalDate.getMonth() + 1).padStart(2, '0');
                const year = originalDate.getFullYear();
                formattedDate = `${day}-${month}-${year}`;
            }

            if (record.Current_Stage__c != null) {
                     if(record.Current_Stage__c == 'CP-L1'){
                          currentStage = 'Stage 1 - Level 1';
                     }else if(record.Current_Stage__c == 'CP-L2'){
                          currentStage = 'Stage 2 - Level 1';
                     }else if(record.Current_Stage__c == 'CP-L3'){
                          currentStage = 'Stage 3 - Level 1';
                     }else if(record.Current_Stage__c == 'CP-L4'){
                          currentStage = 'Stage 3 - Level 2';
                     }else if(record.Current_Stage__c == 'CP-L5'){
                          currentStage = 'Stage 4 - Level 1';
                     } else if(record.Current_Stage__c == 'CP-L6'){
                          currentStage = 'Stage 4 - Level 2';
                     } else if(record.Current_Stage__c == 'CP-L7'){
                          currentStage = 'Stage 5 - Level 1';
                     }
                } else {
                    currentStage = '';
                }


            if (record.CreatedDate) {
                const originalCreatedDate = new Date(record.CreatedDate);
                const createdDay = String(originalCreatedDate.getDate()).padStart(2, '0');
                const createdMonth = String(originalCreatedDate.getMonth() + 1).padStart(2, '0');
                const createdYear = originalCreatedDate.getFullYear();
                formattedCreatedDate = `${createdDay}-${createdMonth}-${createdYear}`;
            }
            console.log(formattedDate)
            console.log(formattedCreatedDate)

             if(record.Owner.Name){
                closedBy = record.Owner.Name;
            }

            if(record.ContactId){
                CPStatus = 'Registered';
            }else {
                CPStatus = 'Unregistered';
            }

            doc += '<tr>';
            doc += '<td>' + (record.CaseNumber ? record.CaseNumber : '') + '</td>';
            doc += '<td>' + (record.RW_Project__c && record.RW_Project__r.Name ? record.RW_Project__r.Name : '') + '</td>';
            doc += '<td>' + (record.Status ? record.Status : '') + '</td>';
            doc += '<td>' + (record.ContactId && record.Contact.Name ? record.Contact.Name : '') + '</td>';
            doc += '<td>' + (formattedCreatedDate ? formattedCreatedDate : '') + '</td>';
            doc += '<td>' + (formattedDate ? formattedDate : '') + '</td>';
            doc += '<td>' + (closedBy ? closedBy : '') + '</td>';
            doc += '<td>' + (CPStatus ? CPStatus : '') + '</td>';            
            doc += '<td>' + (currentStage ? currentStage : '') + '</td>';
            doc += '</tr>';



        });
        doc += '</table>';
        var element = 'data:application/vnd.ms-excel,' + encodeURIComponent(doc);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        // use .csv as extension on below line if you want to export data as csv
        downloadElement.download = 'CaseSummary.xls';
        document.body.appendChild(downloadElement);
        downloadElement.click();
        event.preventDefault();
        //this.showToast('RMFeedbackSummary', 'RM Feedback Summary  has been exported successfully', 'success', 'dismissable');
    }

    getAllData(event) {
        let data = {};

        console.log('name:'+event.target.dataset.name);
        console.log('value:'+event.target.dataset.value);

        data[event.target.dataset.name] = event.target.dataset.value;

        getFilteredCasesNew({
            data: JSON.stringify(data), period: this.period, Year: this.year, Month: this.month
        })
        .then(result => {
            console.log('result:::', result);
            this.filteredCases = result.map(item => {
                let formattedDate = null;
                let formattedCreatedDate = null;
                let closedBy = '';
                let CPStatus = '';
                let contactName = '';
                let projectName = '';
                let currentStage = '';

                if (item.RW_Project__r && item.RW_Project__r.Name) {
                    projectName = item.RW_Project__r.Name;
                } else {
                    projectName = '';
                }

                if (item.Contact && item.Contact.Name) {
                    console.log('Registered/Unregistered' + item.Contact.Name);
                    contactName = item.Contact.Name;
                } else {
                    console.log('Registered/Unregistered' + item.Contact);
                    contactName = '';
                }

                if (item.Current_Stage__c != null) {
                     if(item.Current_Stage__c == 'CP-L1'){
                          currentStage = 'Stage 1 - Level 1';
                     }else if(item.Current_Stage__c == 'CP-L2'){
                          currentStage = 'Stage 2 - Level 1';
                     }else if(item.Current_Stage__c == 'CP-L3'){
                          currentStage = 'Stage 3 - Level 1';
                     }else if(item.Current_Stage__c == 'CP-L4'){
                          currentStage = 'Stage 3 - Level 2';
                     }else if(item.Current_Stage__c == 'CP-L5'){
                          currentStage = 'Stage 4 - Level 1';
                     } else if(item.Current_Stage__c == 'CP-L6'){
                          currentStage = 'Stage 4 - Level 2';
                     } else if(item.Current_Stage__c == 'CP-L7'){
                          currentStage = 'Stage 5 - Level 1';
                     }
                } else {
                    currentStage = '';
                }


                if (item.OwnerId && item.Owner.Name) {
                    console.log('last modified by user' + item.Owner.Name);
                    closedBy = item.Owner.Name;
                }

                if (item.ClosedDate) {
                    const originalDate = new Date(item.ClosedDate);
                    const day = String(originalDate.getDate()).padStart(2, '0');
                    const month = String(originalDate.getMonth() + 1).padStart(2, '0');
                    const year = originalDate.getFullYear();
                    formattedDate = `${day}-${month}-${year}`;
                }

                if (item.CreatedDate) {
                    const originalCreatedDate = new Date(item.CreatedDate);
                    const createdDay = String(originalCreatedDate.getDate()).padStart(2, '0');
                    const createdMonth = String(originalCreatedDate.getMonth() + 1).padStart(2, '0');
                    const createdYear = originalCreatedDate.getFullYear();
                    formattedCreatedDate = `${createdDay}-${createdMonth}-${createdYear}`;
                }

                if (item.ContactId) {
                    CPStatus = 'Registered';
                } else {
                    CPStatus = 'Unregistered';
                }

                return {
                    ...item,
                    contactName: contactName,
                    projectName: projectName,
                    closedDateFormatted: formattedDate,
                    createdDateFormatted: formattedCreatedDate,
                    closedBy: closedBy,
                    CPStatus: CPStatus,
                    currentStage: currentStage
                };
            });
            // this.showFilteredCases = true;
            console.log('this.filteredCases' + JSON.stringify(this.filteredCases));
            console.log('this.filteredCases' + this.filteredCases.length);
            this.exportData();
        }) 
        .catch(error => {
            console.error('Error fetching filtered cases:', error);
        });

        
    }

    exportTotalData(event){
        let doc = '<table>';
        doc += '<style>';
        doc += 'table, th, td {';
        doc += '    border: 1px solid black;';
        doc += '    border-collapse: collapse;';
        doc += '}';
        doc += '</style>';
        doc += '<tr>';
        this.ExcelcolumnHeader.forEach(element => {
            doc += '<th>' + element + '</th>'
        });
        doc += '</tr>';
        this.filteredCases.forEach(record => {
            let formattedDate = null;
            let formattedCreatedDate = null;
            let closedBy = '';
            let currentStage = '';
            let CPStatus = '';
            if (record.ClosedDate) {
                const originalDate = new Date(record.ClosedDate);
                const day = String(originalDate.getDate()).padStart(2, '0');
                const month = String(originalDate.getMonth() + 1).padStart(2, '0');
                const year = originalDate.getFullYear();
                formattedDate = `${day}-${month}-${year}`;
            }
            

            
            if (record.Current_Stage__c != null) {
                     if(record.Current_Stage__c == 'CP-L1'){
                          currentStage = 'Stage 1 - Level 1';
                     }else if(record.Current_Stage__c == 'CP-L2'){
                          currentStage = 'Stage 2 - Level 1';
                     }else if(record.Current_Stage__c == 'CP-L3'){
                          currentStage = 'Stage 3 - Level 1';
                     }else if(record.Current_Stage__c == 'CP-L4'){
                          currentStage = 'Stage 3 - Level 2';
                     }else if(record.Current_Stage__c == 'CP-L5'){
                          currentStage = 'Stage 4 - Level 1';
                     } else if(record.Current_Stage__c == 'CP-L6'){
                          currentStage = 'Stage 4 - Level 2';
                     } else if(record.Current_Stage__c == 'CP-L7'){
                          currentStage = 'Stage 5 - Level 1';
                     }
                } else {
                    currentStage = '';
                }

            if (record.CreatedDate) {
                const originalCreatedDate = new Date(record.CreatedDate);
                const createdDay = String(originalCreatedDate.getDate()).padStart(2, '0');
                const createdMonth = String(originalCreatedDate.getMonth() + 1).padStart(2, '0');
                const createdYear = originalCreatedDate.getFullYear();
                formattedCreatedDate = `${createdDay}-${createdMonth}-${createdYear}`;
            }
            console.log(formattedDate)
            console.log(formattedCreatedDate)

             if(record.Owner.Name){
                closedBy = record.Owner.Name;
            }

            if(record.ContactId){
                CPStatus = 'Registered';
            }else {
                CPStatus = 'Unregistered';
            }

            doc += '<tr>';
            doc += '<td>' + (record.CaseNumber ? record.CaseNumber : '') + '</td>';
            doc += '<td>' + (record.RW_Project__c && record.RW_Project__r.Name ? record.RW_Project__r.Name : '') + '</td>';
            doc += '<td>' + (record.Status ? record.Status : '') + '</td>';
            doc += '<td>' + (record.ContactId && record.Contact.Name ? record.Contact.Name : '') + '</td>';
            doc += '<td>' + (formattedCreatedDate ? formattedCreatedDate : '') + '</td>';
            doc += '<td>' + (formattedDate ? formattedDate : '') + '</td>';
            doc += '<td>' + (closedBy ? closedBy : '') + '</td>';
            doc += '<td>' + (CPStatus ? CPStatus : '') + '</td>';            
            doc += '<td>' + (currentStage ? currentStage : '') + '</td>';
            doc += '</tr>';



        });
        doc += '</table>';
        var element = 'data:application/vnd.ms-excel,' + encodeURIComponent(doc);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        // use .csv as extension on below line if you want to export data as csv
        downloadElement.download = 'CaseSummary.xls';
        document.body.appendChild(downloadElement);
        downloadElement.click();
        event.preventDefault();
    }



    exportAllData(event) {
        let doc = '<table>';
        doc += '<style>';
        doc += 'table, th, td {';
        doc += '    border: 1px solid black;';
        doc += '    border-collapse: collapse;';
        doc += '}';
        doc += '</style>';
        doc += '<tr>';
        this.ExcelAllcolumnHeader.forEach(element => {
            doc += '<th>' + element + '</th>'
        });
        doc += '</tr>';
        this.caseListData.forEach((Ex, ind) => {
            if (ind == 0) {
                Ex.ExportCase.forEach(record => {

                    let formattedDate = null;
                    let formattedCreatedDate = null;
                    let closedBy = '';
                    let currentStage = '';
                    let CPStatus = '';

                    if (record.ClosedDate) {
                        const originalDate = new Date(record.ClosedDate);
                        const day = String(originalDate.getDate()).padStart(2, '0');
                        const month = String(originalDate.getMonth() + 1).padStart(2, '0');
                        const year = originalDate.getFullYear();
                        formattedDate = `${day}-${month}-${year}`;
                    }

                    if (record.CreatedDate) {
                        const originalCreatedDate = new Date(record.CreatedDate);
                        const createdDay = String(originalCreatedDate.getDate()).padStart(2, '0');
                        const createdMonth = String(originalCreatedDate.getMonth() + 1).padStart(2, '0');
                        const createdYear = originalCreatedDate.getFullYear();
                        formattedCreatedDate = `${createdDay}-${createdMonth}-${createdYear}`;
                    }
                    console.log(formattedDate)
                    console.log(formattedCreatedDate)

                    if(record.Owner.Name){
                        closedBy = record.Owner.Name;
                    }

                    
            if (record.Current_Stage__c != null) {
                     if(record.Current_Stage__c == 'CP-L1'){
                          currentStage = 'Stage 1 - Level 1';
                     }else if(record.Current_Stage__c == 'CP-L2'){
                          currentStage = 'Stage 2 - Level 1';
                     }else if(record.Current_Stage__c =='CP-L3'){
                          currentStage = 'Stage 3 - Level 1';
                     }else if(record.Current_Stage__c == 'CP-L4'){
                          currentStage = 'Stage 3 - Level 2';
                     }else if(record.Current_Stage__c == 'CP-L5'){
                          currentStage = 'Stage 4 - Level 1';
                     } else if(record.Current_Stage__c == 'CP-L6'){
                          currentStage = 'Stage 4 - Level 2';
                     } else if(record.Current_Stage__c == 'CP-L7'){
                          currentStage = 'Stage 5 - Level 1';
                     }
                } else {
                    currentStage = '';
                }

                    if(record.ContactId){
                        CPStatus = 'Registered';
                    }else {
                        CPStatus = 'Unregistered';
                    }


                    doc += '<tr>';
                    doc += '<td>' + (record.CaseNumber ? record.CaseNumber : '') + '</td>';
                    doc += '<td>' + (record.RW_Project__c && record.RW_Project__r.Name ? record.RW_Project__r.Name : '') + '</td>';
                    doc += '<td>' + (record.Status ? record.Status : '') + '</td>';
                    doc += '<td>' + (record.ContactId && record.Contact.Name ? record.Contact.Name : '') + '</td>';
                    doc += '<td>' + (formattedCreatedDate ? formattedCreatedDate : '') + '</td>';
                    doc += '<td>' + (formattedDate ? formattedDate : '') + '</td>';
                    doc += '<td>' + (closedBy ? closedBy : '') + '</td>';
                    doc += '<td>' + (CPStatus ? CPStatus : '') + '</td>';            
                    doc += '<td>' + (currentStage ? currentStage : '') + '</td>';
                    doc += '</tr>';

                });
            }

        });
        doc += '</table>';
        doc = doc.replace(/<table[^>]*>/g, '<table style="font-weight: normal;">');
        var element = 'data:application/vnd.ms-excel,' + encodeURIComponent(doc);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        // use .csv as extension on below line if you want to export data as csv
        downloadElement.download = 'AllDataSummary.xls';
        document.body.appendChild(downloadElement);
        downloadElement.click();
        event.preventDefault();
        //this.showToast('RMFeedbackSummary', 'RM Feedback Summary  has been exported successfully', 'success', 'dismissable');
    }
    handleCaseRecordClick(event) {
        console.log('Case_Redirect'+Case_Redirect);
        const caseId = event.target.dataset.caseId;
        const url = 'https://runwal'+ Case_Redirect+ 'lightning.force.com/lightning/r/case/' + caseId + '/view';
        window.open(url, '_blank');
    }


    renderedCallback() {
        // console.log('hi');
        // let allProjectname = this.template.querySelectorAll('.projectName');
        // // alert(allProjectname);
        // console.log('1  :: ', allProjectname);
        // for (let i = 0; i < allProjectname.length - 1; i++) {
        //     console.log('2  :: ', allProjectname[i]);
        //     if (allProjectname[i].innerText == allProjectname[i + 1].innerText) {
        //         console.log('3  :: ', allProjectname[i]);
        //         allProjectname[i].rowSpan = allProjectname[i].rowSpan + 1;
        //         allProjectname[i + 1].remove();
        //     }
        // }


    }
}