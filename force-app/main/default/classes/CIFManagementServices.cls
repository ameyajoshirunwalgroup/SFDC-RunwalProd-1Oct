public class CIFManagementServices {
    public static void updateFeedbackOnCif(List<Task> taskList) {
        List<CIF__c> cifList = new List<CIF__c>();
        List<CIF__c> cifListToUpdate = new List<CIF__c>();
        Map<Id,Task> cifMap = new Map<Id,Task>();
        for(Task t : taskList) {
            if(t.CI_Form__c != null)
                cifMap.put(t.CI_Form__c,t);
        }
        if(!cifMap.isEmpty()) {
            cifList = [Select Id, Name ,Is_SV_comments_Updated__c from CIF__c where Id IN : cifMap.keySet()];
        }
        if(!cifList.isEmpty()) {
            for(CIF__c c : cifList) {
                if(cifMap.containsKey(c.Id) && String.isNotBlank(cifMap.get(c.Id).description)) {
                    c.Is_SV_comments_Updated__c = true;
                    cifListToUpdate.add(c);
                }
            }
            if(!cifListToUpdate.isEmpty())
                update cifListToUpdate;
        }
    }
    
    public static void createcase(List<Task> taskList) {
        system.debug('Inside createcase');
        Map < Id, Task > opptyTaskMap = new Map < Id, Task > ();  
        Id feedbackId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Feedback').getRecordTypeId();
        for (Task t: TaskList) {
            if (t.WhatId != null && t.WhatId.getSObjectType().getDescribe().getName() == 'Opportunity') {
                if (opptyTaskMap.containsKey(t.whatId)) {
                    // if a task already exist for the oppty, 
                    // replace it with the new task only if the new task is the latest
                    if (opptyTaskMap.get(t.whatId).createdDate < t.createdDate) {
                        opptyTaskMap.put(t.whatId, t);
                    }
                } else {
                    opptyTaskMap.put(t.whatId, t);
                }
            }
            
        }
        
            List<Case_Platform_Event__e> eventsToPublish = new List<Case_Platform_Event__e>();
        List<Opportunity> oppList = [SELECT Id,RW_Email__c,RW_RM_Name__c, AccountId,Account.PersonEmail, RW_Project__c,RW_Project_Unit__r.Name,RW_Project_Unit__r.RW_Param2__c FROM Opportunity WHERE Id in : opptyTaskMap.keySet()];            
        Set<Id> accountIds = new Set<Id>();
        for (Opportunity opp : oppList) {
            accountIds.add(opp.AccountId);            
        }
        system.debug('accountIds'+accountIds);
        Datetime thirtySecondsAgo = Datetime.now().addMinutes(-1);
        system.debug('thirtySecondsAgo'+thirtySecondsAgo);
        
        Map<Id, Case> recentCaseMap = new Map<Id, Case>();
        List<Case> recentCases = [
            SELECT Id, AccountId, RecordTypeId, CreatedDate
            FROM Case
            WHERE AccountId IN :accountIds
            AND RecordTypeId = :feedbackId
            AND CreatedDate >= :thirtySecondsAgo
        ];
system.debug('recentCases'+recentCases);
        
        String AdminId = System.label.System_Administrator_User_Id;
        System.debug('custom label is '+AdminId);
        list<task> duplicatetasktoUpdate = new list<task>();
        
    for (Case c : recentCases) {
        recentCaseMap.put(c.AccountId, c);
        system.debug('Inside for recentCases');
        system.debug('Inside for recentCases'+c.CreatedDate);
      
        For(opportunity opp:oppList){
        Task duplicatetask = new Task();
        duplicatetask.id = opptyTaskMap.get(opp.id).id;
        duplicatetask.Status = 'Completed';
        duplicatetask.Subject = 'Duplicate CRM Call';
        duplicatetask.Disposition_Type__c = 'NotAnswered';    
        duplicatetask.OwnerId = AdminId;
            
            duplicatetasktoUpdate.add(duplicatetask);
        }
        
    }
        if(!duplicatetasktoUpdate.isEmpty()){
            try{
                update duplicatetasktoUpdate;
            }catch(exception e){
                system.debug('Error while updating Duplicate Tasks'+e.getMessage());
            }
        }
        system.debug('recentCaseMap'+recentCaseMap);
        For(opportunity opp:oppList)
        {  if (!recentCaseMap.containsKey(opp.AccountId)) {
            system.debug('Inside if recentCaseMap');
            Case c = new Case();
            c.OwnerId = opptyTaskMap.get(opp.id).OwnerId;
            c.Status = 'Open';
            c.RecordTypeId = feedbackId;
            c.AccountId = opp.AccountId;
            c.RW_Project__c = opp.RW_Project__c;
            if(!String.isBlank(opp.RW_Email__c))
            {
                c.SuppliedEmail= opp.RW_Email__c; 
            }
           if(String.isBlank(opp.RW_Email__c))
           {
              c.SuppliedEmail =opp.Account.PersonEmail;
           }
            c.RW_Case_Type__c='Complaint';
            c.Origin='Inbound Call';
            c.RW_Communication_Type__c='Inbound Call';
            c.call_url__c=opptyTaskMap.get(opp.id).Voice_Log_URL__c;
            c.Subject='Customer Call Feedback';
            Task taskForOpportunity = opptyTaskMap.get(opp.id);
            c.Task_Link__c='/' + taskForOpportunity.Id; 
            c.RW_Approval_Status__c='Approved';
            //c.RW_RM_Name__c=opp.RW_RM_Name__c; // Commnented by Vinay 21-04-2025 to fix the issue of Case assignment to System Admin.
            c.Remarks_by_RM__c='Closed Satisfactory';
            c.Unit_Name__c=opp.RW_Project_Unit__r.Name;
            c.Tower__c=opp.RW_Project_Unit__r.RW_Param2__c;
            
            
              insert c;  
                
            
           /* c.Status='Case Closed';
            c.RW_Approval_Status__c='Approved';
            c.Remarks_by_RM__c='Closed Satisfactory';*/
            Opportunity updateopty=new Opportunity();
            updateopty.id=opp.id;
            updateopty.Latest_Inbound_call_Case__c=c.id;
            update updateopty;
            set <Id> caseId=new set<Id>();
            caseId.add(c.id);
            CaseMailHandler.CaseCategorizationMail(caseId);
            Task taskForOpportunity1 = new Task();
            taskForOpportunity1.id=opptyTaskMap.get(opp.id).id;
            taskForOpportunity1.Status = 'Completed'; 
            
                update taskForOpportunity1; 
            
           
                Case_Platform_Event__e event = new Case_Platform_Event__e(
            CaseId__c = c.Id
        );
        eventsToPublish.add(event);
    }
        }

    if (!eventsToPublish.isEmpty()) {
        EventBus.publish(eventsToPublish);
            
        }
    } 
}