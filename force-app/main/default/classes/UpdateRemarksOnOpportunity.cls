global class UpdateRemarksOnOpportunity implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id, CRM_Remarks__c, Sales_Remarks__c FROM Opportunity WHERE StageName = 'Unit Booked']);
    }
    
    global void execute(Database.BatchableContext bc, List<Opportunity> oppList){
        Set<Id> oppIds = new Set<Id>();
        Id serviceRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Service Task').getRecordTypeId();
        Id salesRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Sales Task').getRecordTypeId();
        List<Opportunity> oppListToUpdate = new List<Opportunity>();
        for(Opportunity opp : oppList){
            if(opp.CRM_Remarks__c == null && opp.Sales_Remarks__c == null){
                oppIds.add(opp.Id);
            	oppListToUpdate.add(opp);
            }
        }
        if(oppIds.size() > 0){
            List<Task> taskList = [SELECT Id, Remarks__c, WhatId, RecordTypeId FROM Task WHERE WhatId =: oppIds AND Remarks__c != null AND (RecordTypeId =: serviceRecTypeId OR RecordTypeId =: salesRecTypeId) ORDER By CreatedDate desc];
            Map<Id, String> oppIdVsCrmRemarks = new Map<Id, String>();
            Map<Id, String> oppIdVsSalesRemarks = new Map<Id, String>();
            for(Task tsk : taskList){
                if(tsk.RecordTypeId == serviceRecTypeId){
                    if(!oppIdVsCrmRemarks.containsKey(tsk.WhatId)){
                        oppIdVsCrmRemarks.put(tsk.WhatId, tsk.Remarks__c);
                    }else{
                        oppIdVsCrmRemarks.put(tsk.WhatId, oppIdVsCrmRemarks.get(tsk.WhatId) + '; * ' + tsk.Remarks__c);
                    }
                }else if(tsk.RecordTypeId == salesRecTypeId){
                    if(!oppIdVsSalesRemarks.containsKey(tsk.WhatId)){
                        oppIdVsSalesRemarks.put(tsk.WhatId, tsk.Remarks__c);
                    }else{
                        oppIdVsSalesRemarks.put(tsk.WhatId, oppIdVsSalesRemarks.get(tsk.WhatId) + + '; * ' + tsk.Remarks__c);
                    }
                }
            }
            for(Opportunity opp : oppListToUpdate){
                if(oppIdVsCrmRemarks.containsKey(opp.id)){
                    String str = oppIdVsCrmRemarks.get(opp.Id);
                    opp.CRM_Remarks__c = (str.length() > 131072) ? str.substring(0, 131072) : str;
                    //opp.CRM_Remarks__c = oppIdVsCrmRemarks.get(opp.Id);
                }else if(oppIdVsSalesRemarks.containsKey(opp.id)){
                    String str = oppIdVsSalesRemarks.get(opp.Id);
                    opp.Sales_Remarks__c = (str.length() > 131072) ? str.substring(0, 131072) : str;
                    //opp.Sales_Remarks__c = oppIdVsSalesRemarks.get(opp.Id);
                }
                System.debug('opp.CRM_Remarks__c: ' + opp.CRM_Remarks__c);
                System.debug('opp.Sales_Remarks__c: ' + opp.Sales_Remarks__c);
            }
            //update oppListToUpdate;
        }
    }
    
    global void finish(Database.BatchableContext bc){}
}