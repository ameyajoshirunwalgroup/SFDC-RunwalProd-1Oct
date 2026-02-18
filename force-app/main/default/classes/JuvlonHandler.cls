public class JuvlonHandler {
    
    @future (callout=true)
    Public static void updateJuvlonObjField(set<Id> reportIdToSendJuvlonHandler){
        if(reportIdToSendJuvlonHandler != null && reportIdToSendJuvlonHandler.size() > 0){
            RW_Juvlon_Campaign__c juvlonObj =  [select Id,Name,RW_Report_Id__c,RW_Juvlon_Object__c from RW_Juvlon_Campaign__c where id in :reportIdToSendJuvlonHandler limit 1];
            if(juvlonObj.RW_Report_Id__c != null && juvlonObj.RW_Report_Id__c !=''){
                Reports.ReportDescribeResult describe = Reports.ReportManager.describeReport(juvlonObj.RW_Report_Id__c);
                Reports.ReportMetadata reportMd = describe.getReportMetadata();
               
                If(reportMd.getReportType().getLabel() != null && reportMd.getReportType().getLabel() == 'Leads'){
                  juvlonObj.RW_Juvlon_Object__c = 'Lead';
                   
                }
                If(reportMd.getReportType().getLabel() != null && reportMd.getReportType().getLabel() == 'Opportunities'){
                    juvlonObj.RW_Juvlon_Object__c = 'Opportunity';
                        
                }
            }
            update juvlonObj;
            
        }
        
    }
}