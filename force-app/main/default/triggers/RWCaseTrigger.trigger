trigger RWCaseTrigger on Case (before insert, after insert,before update, after update) 
{         
    
    //Added by Vinay 01-12-2025 Start
    /*List<Id> caseIdsToDelete = new List<Id>(); 
    List<Case> casesToProcess = new List<Case>();
    Map<Id, Case> oldMap = new Map<Id, Case>();
    RWCaseTriggerHandler handler = new RWCaseTriggerHandler();
    for(Case c: trigger.new){ 
        if(c.Subject.contains('Undeliverable') || c.Subject.contains('undeliverable')){
            caseIdsToDelete.add(c.Id);
        }else{
            casesToProcess.add(c);
            oldMap.put(c.Id, trigger.OldMap.get(c.Id));
        }
    }
    
    if(Trigger.isBefore && Trigger.isInsert){
        handler.onBeforeInsert(casesToProcess, oldMap);
    }
    if (Trigger.isBefore && Trigger.isUpdate){
        handler.onBeforeUpdate(casesToProcess, oldMap);
    }
    if (Trigger.isAfter && Trigger.isInsert) {
        handler.onAfterInsert(casesToProcess, oldMap);
    }
    if (Trigger.isAfter && Trigger.isUpdate){
        handler.onAfterUpdate(casesToProcess, oldMap);
    }
    if(caseIdsToDelete.size() > 0){ 
        List<Case> cases = [SELECT Id FROM Case WHERE Id =: caseIdsToDelete];
        delete cases;
    }*/
    //Added by Vinay 01-12-2025 End
    
    
   RWCaseTriggerHandler obj = new RWCaseTriggerHandler();
    obj.runTrigger();
    if(Trigger.isUpdate && Trigger.isAfter){
        Set<Id> CaseClosureSetNew = new Set<Id>();
        Set<Id> CaseReopenedSet = new Set<Id>();
         Set<Id> LastClosedDateSet = new Set<Id>();
        Set<Id> L3Update = new Set<Id>();
        String RecordTypeId = '0121e000000eZaqAAE';
        Set<Id> CaseOwners = new Set<Id>();
        List<Case> statusChangedCases = new List<Case>(); //Added by Vinay 20-01-2026
        List<Case> closedCases = new List<Case>(); //Added by Vinay 20-01-2026
        for(Case c: trigger.new){   
            System.debug('inside case update');
            
            //if(Trigger.oldMap.get(c.id).Status != Trigger.newMap.get(c.id).Status && c.Status=='Case Closed' && String.isBlank(Trigger.oldMap.get(c.id).CSAT_Feedback_Rating__c)){  //Commented by Vinay 14-01-2025
            if(Trigger.oldMap.get(c.id).Status != Trigger.newMap.get(c.id).Status && c.Status=='Case Closed' && String.isBlank(Trigger.oldMap.get(c.id).CSAT_Feedback_Rating__c) && String.isBlank(c.locobuzz__Locobuzz_ID__c) && c.Stop_Emails__c == false){  //Added by Vinay 10-02-2025
                System.debug('inside case closed');
                System.debug('oldMap::'+Trigger.oldMap.get(c.id).Status);
                System.debug('newMap::'+Trigger.newMap.get(c.id).Status);
                CaseClosureSetNew.add(c.Id);
                System.debug('inside case closed');
            }
            
            if(Trigger.oldMap.get(c.id).ClosedDate != Trigger.newMap.get(c.id).ClosedDate && Trigger.newMap.get(c.id).ClosedDate!=null){  
               
                System.debug('inside case owners'); 
                LastClosedDateSet.add(c.Id);
            }
           
            if(Trigger.oldMap.get(c.id).Status != Trigger.newMap.get(c.id).Status && c.Status=='Reopened'&& Trigger.oldMap.get(c.id).Status=='Case Closed'){   
                CaseReopenedSet.add(c.Id);
            }
            
            if(Trigger.oldMap.get(c.id).RW_Case_Escalation__c != Trigger.newMap.get(c.id).RW_Case_Escalation__c && c.RW_Case_Escalation__c=='First Escalation' && Trigger.oldMap.get(c.id).isEscalated !=Trigger.newMap.get(c.id).isEscalated && c.Current_Stage__c == 'CP-L2'){
                system.debug('Inside Updte L3');
                //L3Update.add(c.Id);
            }
            
            if(Trigger.oldMap.get(c.id).Status != Trigger.newMap.get(c.id).Status){ //Added by Vinay 20-01-2026
                statusChangedCases.add(c);
                if(c.Status == 'Case Closed'){
                    closedCases.add(c);
                }
            }
        }
        
        if(!LastClosedDateSet.isEmpty()){
            CaseMailHandler.UpdateLastCloseDate(LastClosedDateSet);
        }
         if(checkRecursion.isFirstRunA()){
        if(!CaseReopenedSet.isEmpty()){
           CaseMailHandler.CaseIsReopened(CaseReopenedSet);
        }
         }
        if(!CaseClosureSetNew.isEmpty()){
            System.debug('CaseClosureSetNew'+CaseClosureSetNew);
            CaseMailHandler.CaseClosureEmailCustomer(CaseClosureSetNew);//Customer
            System.debug('CaseClosureSetNew END'+CaseClosureSetNew);
        }
        
        if(statusChangedCases.size() > 0){ //Added by Vinay 20-01-2026
            LockatedApp_Notifications.caseStatusChangedNotification(statusChangedCases);
        }
        if(closedCases.size() > 0){ //Added by Vinay 20-01-2026
            LockatedApp_Notifications.caseClosedNotification(closedCases);
        }
        /*if (!CaseOwners.isEmpty()) {
            List<Case> casesToUpdate = [SELECT Id, Owner.Name, owners__c,RW_Owner_Name__c FROM Case WHERE Id IN :CaseOwners];
            for (Case c : casesToUpdate) {
                system.debug('owner - '+c.Owners__c);
                system.debug('owner name - '+c.RW_Owner_Name__c);
                if(c.Owners__c != null ){
                   c.owners__c = c.owners__c + ', ' + c.RW_Owner_Name__c; 
                }else{
                   c.owners__c = c.RW_Owner_Name__c;
                }
                
            }
            update casesToUpdate;
        }
        */
             
    }
    
    if(Trigger.isInsert && Trigger.isAfter){ //Added by Vinay 20-01-2026
        LockatedApp_Notifications.caseCreatedNotification(trigger.New);
    }
    
    
    
    
}