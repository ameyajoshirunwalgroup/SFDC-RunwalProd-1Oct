trigger JuvlonTrigger on RW_Juvlon_Campaign__c (before insert, before Update, after insert, after Update) {
    Set<ID> reportIdToSendJuvlonHandler = new Set<ID>();
    Set<String> juvlonReportIdSet = new Set<String>();
    
    If((Trigger.isInsert || Trigger.isUpdate ) ) {
        if( Trigger.isBefore){
            Set<String> reportIdSet = new Set<String>();
            
            
            for(RW_Juvlon_Campaign__c juvLon: Trigger.new){
                if(juvLon.RW_Report_Id__c != null && juvLon.RW_Report_Id__c !=''){
                    juvlonReportIdSet.add(juvLon.RW_Report_Id__c);
                }
            }
            for(Report rep: [SELECT Id, Name FROM Report where id =: juvlonReportIdSet]){
                reportIdSet.add(rep.Id);
            }
            
            for(RW_Juvlon_Campaign__c juvLon: Trigger.new){
                if (Trigger.isBefore || Trigger.isUpdate) {
                    if(juvLon.RW_Report_Id__c != null && juvLon.RW_Report_Id__c !=''){
                        system.debug('juvLon.RW_Report_Id__c::: line 18'+juvLon.RW_Report_Id__c);
                        //move this validation part to the before insert /update section keep
                        if(!test.isRunningTest()){
                            if(!reportIdSet.contains(juvLon.RW_Report_Id__c)){
                                juvLon.RW_Report_Id__c.addError('Incorrect ReportId');  
                            }
                        }
                    }
                }
                
            } 
        }
        if(Trigger.isAfter ){
             for(RW_Juvlon_Campaign__c juvLon: Trigger.new){
            if(Trigger.isUpdate){
               
                    system.debug('juvLon.RW_Report_Id__c::: line 26'+juvLon.RW_Report_Id__c);
                    system.debug('Trigger.oldMap.get(juvLon.Id).RW_Report_Id__c::: line 27'+Trigger.oldMap.get(juvLon.Id).RW_Report_Id__c);
                    if(juvLon.RW_Report_Id__c != Trigger.oldMap.get(juvLon.Id).RW_Report_Id__c ||String.isBlank(juvLon.RW_Juvlon_Object__c)){
                        reportIdToSendJuvlonHandler.add(juvLon.id);
                    } 
                    
                    if(juvLon.RW_Report_Id__c != Trigger.oldMap.get(juvLon.Id).RW_Report_Id__c){
                        system.debug('line 29'+juvLon.RW_Report_Id__c);
                    }
                } 
                                 
             else{
                        reportIdToSendJuvlonHandler.add(juvLon.id);
                        
             }
                 
        }
                if(reportIdToSendJuvlonHandler.size() > 0){
                    JuvlonHandler.updateJuvlonObjField(reportIdToSendJuvlonHandler);
                }
            
            
        }
    }  
    
    
    if(Trigger.isUpdate && Trigger.isAfter){
        List<ID> jIds = new List<id>();
        for(RW_Juvlon_Campaign__c juvLon: Trigger.new){
            if(juvLon.RW_Campaign_Status__c == 'Approved' && Trigger.oldMap.get(juvLon.Id).RW_Campaign_Status__c == 'Sent for Approval'){
                jIds.add(juvLon.id);
            }
            
        }
        if(jIds.size()>0){
            JuvlonIntegration.reportMethod(jIds);
        }
    }
}