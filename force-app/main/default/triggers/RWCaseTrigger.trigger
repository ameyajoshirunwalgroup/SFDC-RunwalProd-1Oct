trigger RWCaseTrigger on Case (before insert, after insert,before update, after update) 
{         
    RWCaseTriggerHandler obj = new RWCaseTriggerHandler();
    obj.runTrigger();
    if(Trigger.isUpdate && Trigger.isAfter){
        Set<Id> CaseClosureSetNew = new Set<Id>();
        Set<Id> CaseReopenedSet = new Set<Id>();
         Set<Id> LastClosedDateSet = new Set<Id>();
        Set<Id> L3Update = new Set<Id>();
        String RecordTypeId = '0121e000000eZaqAAE';
        Set<Id> CaseOwners = new Set<Id>();
        
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
   
    
    
    
    
}