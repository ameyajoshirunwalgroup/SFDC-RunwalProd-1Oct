import { LightningElement, wire, api } from 'lwc';
import getUserIdToManagerNameMap from '@salesforce/apex/WhatsAppFeedbackBotReportsController.getUserIdToManagerNameMap';
import getProjectFeedback from '@salesforce/apex/WhatsAppFeedbackBotReportsController.getProjectFeedback';
import getFilteredCases from '@salesforce/apex/WhatsAppFeedbackBotReportsController.getFilteredCases';
import getFeedbackData from '@salesforce/apex/WhatsAppFeedbackBotReportsController.getFeedbackData';
export default class Test extends LightningElement {
    @api period;
    @api year;
    @api month;
    feedbackList;
    filteredCases;
    feedbackData;
    YearlyCase;
    TotalExportList;
    showFilteredCases = false;
    showFeedbackTable = false;
    userIdToManagerNameMap;
    ExcelcolumnHeader = ["Case Number", "Subject", "Status", "TL Name", "RM Name", "Closed Date", "Aging", "Feedback Rating", "Feedback Remark", "Project", "Date open","Case Type","Tower","Unit Name"];
    ExcelAllcolumnHeader = ["Case Number", "Subject", "Status", "RM Name", "Closed Date", "Aging", "Feedback Rating", "Feedback Remark", "Project", "Date open","Case Type","Tower","Unit Name"];

    @wire(getFeedbackData)
    wiredFeedbackData({ error, data }) {
        if (data) {
            this.feedbackData = data;
        } else if (error) {
            console.error('Error retrieving feedback data:', error);
        }
    }

    @wire(getUserIdToManagerNameMap)
    wiredUserMap({ error, data }) {
        if (data) {
            this.userIdToManagerNameMap = data;
            console.log('User Id to Manager Name Map:', this.userIdToManagerNameMap);
        } else if (error) {
            console.error('Error fetching user map:', error);
        }
    }
    @wire(getProjectFeedback, {
        period: '$period', Year: '$year', Month: '$month'
    })
    wiredFeedback({ error, data }) {
        console.log('inside :: getProjectFeedback');
        console.log('period :: ', this.period);
        console.log('year :: ', this.year);
        console.log('month :: ', this.month);
        if (data) {
            data = JSON.parse(JSON.stringify(data));
            for (let i = 0; i < data.length; i++) {
                let rowSpancount = 1;
                let j = i + 1;
                for (; j < data.length ; j++) {

                    if (data[i].project == data[j].project) {
                        rowSpancount++;
                    } else {
                        break;
                    }
                }
                data[i].rowSpan = rowSpancount
                data[i].isProjectvisible = true;
                i = j - 1;
            }

            this.feedbackList = data;
            this.showFeedbackTable = true;
            //this.TotalExportList=this.feedbackList.ExportCase;
            console.log('TotalfeedbackList :: ', this.feedbackList);
            //console.log('TotalExportList :: ', this.TotalExportList);


        } else if (error) {
            console.error('Error fetching project feedback:', error);
        }
    }
    @api resetTable() {


        console.log('inside reset');
        this.filteredCases = [];
        this.showFilteredCases = false;
    }
    handleCellClick(event) {
        this.showFeedbackTable = false;
        let data = {};

        console.log('event.target.dataset.name'+event.target.dataset.name);
        console.log('event.target.dataset.value'+event.target.dataset.value);

        data[event.target.dataset.name] = event.target.dataset.value;
        if (event.target.dataset.name == 'RM Name') {
            data['Project Name'] = event.target.dataset.projectname;
        } else if (event.target.dataset.name == 'Status') {
            data['Project Name'] = event.target.dataset.projectname;
            data['RM Name'] = event.target.dataset.rmname;
        }
        else if (event.target.dataset.name == 'Total case') {
            data['Project Name'] = event.target.dataset.projectname;
            data['RM Name'] = event.target.dataset.rmname;
        }
        console.log('data'+JSON.stringify(data));
        console.table(data);
        getFilteredCases({
            data: JSON.stringify(data), period: this.period, Year: this.year, Month: this.month
        })
            .then(result => {
                console.log('result:::', result)
                this.filteredCases = result.map(item => {

                    let formattedDate = null;
                    let formattedCreatedDate = null;
                     let recordTypeValue=null;
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
                   if(item.RecordTypeId)
                   {
                   
                    if (item.RecordTypeId === '0121e00000141soAAA') {
                          recordTypeValue = 'inbound call';
                                } else {
                         recordTypeValue = 'normal case';
                            }
                   }

                   console.log(item.RecordTypeId)
                    console.log(item.ClosedDate)
                    console.log(item.formattedCreatedDate)
                    console.log(item.OwnerId)


                    return {
                        ...item,
                        closedDateFormatted: formattedDate,
                        createdDateFormatted: formattedCreatedDate, ManagerName: this.userIdToManagerNameMap[item.OwnerId]
                    };
                });
                this.showFilteredCases = true;
                console.log()
            })
            .catch(error => {
                console.error('Error fetching filtered cases:', error);
            });
    }
    goBack(event) {
        this.showFeedbackTable = true;
        this.showFilteredCases = false;
        event.preventDefault();
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

            doc += '<tr>';
            doc += '<td>' + record.CaseNumber + '</td>';
            doc += '<td>' + record.Subject + '</td>';
            doc += '<td>' + record.Status + '</td>';
            doc += '<td>' + record.ManagerName + '</td>';
            doc += '<td>' + record.RW_RM_Name__c + '</td>';
            doc += '<td>' + formattedDate + '</td>';
            doc += '<td>' + record.Ageing__c + '</td>';
            doc += '<td>' + record.CSAT_Feedback_Rating__c + '</td>';
            doc += '<td>' + record.CSAT_Feedback_Remark__c + '</td>';
            doc += '<td>' + record.RW_Project__r.Name + '</td>';
            doc += '<td>' + formattedCreatedDate + '</td>';
            doc += '<td>' + record.RecordType.Name + '</td>';
            doc += '<td>' + record.Tower__c + '</td>';
            doc += '<td>' + record.Unit_Name__c + '</td>';
            doc += '</tr>';

        });
        doc += '</table>';
        var element = 'data:application/vnd.ms-excel,' + encodeURIComponent(doc);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        // use .csv as extension on below line if you want to export data as csv
        downloadElement.download = 'RMFeedbackSummary.xls';
        document.body.appendChild(downloadElement);
        downloadElement.click();
        event.preventDefault();
        //this.showToast('RMFeedbackSummary', 'RM Feedback Summary  has been exported successfully', 'success', 'dismissable');
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
        this.feedbackList.forEach((Ex, ind) => {
            if (ind == 0) {
                Ex.ExportCase.forEach(record => {

                    let formattedDate = null;
                    let formattedCreatedDate = null;

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

                doc += '<tr>';
doc += '<td>' + (record.CaseNumber || '') + '</td>';
doc += '<td>' + (record.Subject || '') + '</td>';
doc += '<td>' + (record.Status || '') + '</td>';
doc += '<td>' + (record.RW_RM_Name__c || '') + '</td>';
doc += '<td>' + (formattedDate || '') + '</td>';
doc += '<td>' + (record.Ageing__c || '') + '</td>';
doc += '<td>' + (record.CSAT_Feedback_Rating__c || '') + '</td>';
doc += '<td>' + (record.CSAT_Feedback_Remark__c || '') + '</td>';
doc += '<td>' + (record.RW_Project__r?.Name || '') + '</td>';
doc += '<td>' + (formattedCreatedDate || '') + '</td>';
doc += '<td>' + (record.RecordType?.Name || '') + '</td>';
doc += '<td>' + (record.Tower__c || '') + '</td>';
doc += '<td>' + (record.Unit_Name__c || '') + '</td>';
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
        const caseId = event.target.dataset.caseId;
        const url = 'https://runwal.lightning.force.com/lightning/r/case/' + caseId + '/view';
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