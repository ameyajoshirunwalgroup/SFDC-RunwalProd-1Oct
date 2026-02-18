public class ScheduleOzonetelCalls {
    
    public static void callSchedule(List<Task> taskList){
        List<Scheduled_Call__c> schedulesToCreate = new List<Scheduled_Call__c>();
        Set<Id> relatedIds = new Set<id>();
        Set<Id> ownerIds = new Set<Id>();
        for(Task tsk : taskList){
            if(tsk.Next_Action_Date__c > Datetime.now()){
                if(tsk.WhatId != null)
                	relatedIds.add(tsk.WhatId);
                else if(tsk.WhoId != null)
                	relatedIds.add(tsk.WhoId);
                ownerIds.add(tsk.OwnerId);
            }
        }
        Map<Id, User> userMap;
        if(ownerIds.size() > 0){
            userMap = new Map<Id, User>([SELECT Id, CTI_Agent_ID__c FROM User WHERE Id =: ownerIds]);
        }
        Map<String, Scheduled_Call__c> relatedIdVsSchedule = new Map<String, Scheduled_Call__c>();
        Map<String, String> recVsProjMap = new Map<String, String>();
        if(relatedIds.size() > 0){
            recVsProjMap = projectIds(relatedIds);
            System.debug('relatedIds: ' + relatedIds);
            List<Scheduled_Call__c> existingSchedules = [SELECT Id, Schedule_Date__c, Related_Record_Id__c FROM Scheduled_Call__c WHERE Related_Record_Id__c =: relatedIds];
            //List<Scheduled_Call__c> existingSchedules = [SELECT Id, Schedule_Date__c, Related_Record_Id__c FROM Scheduled_Call__c];
            System.debug('existingSchedules: ' + existingSchedules);
            for(Scheduled_Call__c sc : existingSchedules){
                relatedIdVsSchedule.put(sc.Related_Record_Id__c, sc);
            }
        }
        System.debug('relatedIdVsSchedule: ' + relatedIdVsSchedule);
        List<Scheduled_Call__c> schedulesToUpdate = new List<Scheduled_Call__c>();
        for(Task tsk : taskList){
            if(Test.isRunningTest() || (tsk.WhatId != null || tsk.WhoId != null)){
                if(relatedIdVsSchedule.containskey(tsk.WhatId)){
                    relatedIdVsSchedule.get(tsk.WhatId).Schedule_Date__c = tsk.Next_Action_Date__c;
                    relatedIdVsSchedule.get(tsk.WhatId).Task_Id__c = tsk.Id;
                    schedulesToUpdate.add(relatedIdVsSchedule.get(tsk.WhatId));
                }else if(relatedIdVsSchedule.containskey(tsk.WhoId)){
                    relatedIdVsSchedule.get(tsk.WhoId).Schedule_Date__c = tsk.Next_Action_Date__c;
                    relatedIdVsSchedule.get(tsk.WhoId).Task_Id__c = tsk.Id;
                    schedulesToUpdate.add(relatedIdVsSchedule.get(tsk.WhoId));
                }else{
                    Scheduled_Call__c sc = new Scheduled_Call__c();
                    sc.Related_Record_Id__c = tsk.WhatId;
                    sc.Schedule_Date__c = tsk.Next_Action_Date__c;
                    if(userMap != null && userMap.get(tsk.OwnerId) != null){
                        sc.Agent_Id__c = userMap.get(tsk.OwnerId).CTI_Agent_ID__c;
                    }
                    sc.Task_Id__c = tsk.Id;
                    if(tsk.WhatId != null && tsk.WhatId.getSObjectType().getDescribe().getName() == 'Opportunity'){
                        sc.Opportunity__c = tsk.WhatId;
                        sc.Related_To__c = 'Opportunity';
                    }else if(tsk.WhatId != null && tsk.WhatId.getSObjectType().getDescribe().getName() == 'Account'){
                        sc.Account__c = tsk.WhatId;
                        sc.Related_To__c = 'Account';
                    }else if(tsk.WhoId != null && tsk.WhoId.getSObjectType().getDescribe().getName() == 'Lead'){
                        sc.Lead__c = tsk.WhoId;
                        sc.Related_To__c = 'Lead';
                    }
                    schedulesToCreate.add(sc);
                }
            }
        }
        System.debug('schedulesToCreate: ' + schedulesToCreate);
        System.debug('schedulesToUpdate: ' + schedulesToUpdate);
        if(schedulesToCreate.size() > 0)
        	insert schedulesToCreate;
        if(schedulesToUpdate.size() > 0)
        	update schedulesToUpdate;
    }
    
    public static Map<String, String> projectIds(Set<Id> relatedIds){
        List<Id> oppIds = new List<Id>();
        List<Id> accIds = new List<Id>();
        List<Id> leadIds = new List<Id>();
        Map<String, String> recIdVsProjId = new Map<String, String>();
        for(Id relId : relatedIds){
            if(relId.getSObjectType().getDescribe().getName() == 'Opportunity'){
                oppIds.add(relId);
            }else if(relId.getSObjectType().getDescribe().getName() == 'Account'){
                accIds.add(relId);
            }else if(relId.getSObjectType().getDescribe().getName() == 'Lead'){
                leadIds.add(relId);
            }
        }
        if(oppIds.size() > 0){
            List<Opportunity> oppList = [SELECT Id,RW_Project__c FROM Opportunity WHERE Id =: oppIds];
            for(Opportunity opp : oppList){
                recIdVsProjId.put(opp.Id, opp.RW_Project__c);
            }
        }
        if(accIds.size() > 0){
            List<Account> accList = [SELECT Id,Project_Name__c FROM Account WHERE Id =: accIds];
            for(Account acc : accList){
                recIdVsProjId.put(acc.Id, acc.Project_Name__c);
            }
        }
        if(leadIds.size() > 0){
            List<Lead> leadList = [SELECT Id,RW_Project__c FROM Lead WHERE Id =: leadIds];
            for(Lead ld : leadList){
                recIdVsProjId.put(ld.Id, ld.RW_Project__c);
            }
        }
        return recIdVsProjId;
    }
    
}