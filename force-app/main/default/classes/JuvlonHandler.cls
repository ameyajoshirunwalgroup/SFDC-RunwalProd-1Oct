public class JuvlonHandler {
    
    @future (callout=true)
    Public static void updateJuvlonObjField(set<Id> reportIdToSendJuvlonHandler)
    {
        system.debug('in future method');
        if(reportIdToSendJuvlonHandler != null && reportIdToSendJuvlonHandler.size() > 0) 
        {
            RW_Juvlon_Campaign__c juvlonObj =  [select Id,Name,RW_Report_Id__c,RW_Juvlon_Object__c from RW_Juvlon_Campaign__c where id in :reportIdToSendJuvlonHandler limit 1];
            system.debug('juvlonObj:::'+juvlonObj);
            if(juvlonObj.RW_Report_Id__c != null && juvlonObj.RW_Report_Id__c !=''){
                Reports.ReportDescribeResult describe = Reports.ReportManager.describeReport(juvlonObj.RW_Report_Id__c);
                Reports.ReportMetadata reportMd = describe.getReportMetadata();
                system.debug('---col ReportType from Trigger---'+reportMd.getReportType().getLabel());
               
                If(reportMd.getReportType().getLabel() != null && reportMd.getReportType().getLabel() == 'Leads'){
                  juvlonObj.RW_Juvlon_Object__c = 'Lead';
                  system.debug('---line 18 leads---'+juvlonObj.RW_Juvlon_Object__c);
                   
                }
                If(reportMd.getReportType().getLabel() != null && reportMd.getReportType().getLabel() == 'Opportunities'){
                    juvlonObj.RW_Juvlon_Object__c = 'Opportunity';
                        
                }
            }
            system.debug('---line 26 juvlonObj---'+juvlonObj);
            update juvlonObj;
            
        }
        
    }
}