global class ProjectUnitUpdateOnCaseBatch implements Database.Batchable<sObject> , Database.Stateful{
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id, AccountId, RW_Project__c FROM Case WHERE Triggered_for_CRN_update__c = false AND SAP_Customer_Number__c = null AND AccountId != null AND RW_Project_Unit__c = null AND Opportunity__c = null LIMIT 20000]);
    }
    
    global void execute(Database.BatchableContext bc, List<Case> lstCase){
        Set<String> accIds = new Set<String>();
        for(Case c : lstCase){
            accIds.add(c.AccountId);
        }
        if(accIds.size() > 0){
            Map<String, List<Opportunity>> accVsOppMap = new Map<String, List<Opportunity>>();
            List<Opportunity> bookedOppList = new List<Opportunity>();
            if(!Test.isRunningTest()){
                bookedOppList = [SELECT Id, AccountId, RW_Project_Unit__c, RW_Project__c, RW_RM_Name__c FROM Opportunity WHERE AccountId =: accIds AND StageName = 'Unit Booked' AND RW_Project_Unit__c != null ORDER BY Booking__r.Booking_Date__c DESC];
            }else{
                bookedOppList = [SELECT Id, AccountId, RW_Project_Unit__c, RW_Project__c, RW_RM_Name__c FROM Opportunity WHERE AccountId =: accIds AND StageName = 'Unit Booked'];
            }
            for(Opportunity opp : bookedOppList){
                if(accVsOppMap.get(opp.AccountId) != null){
                    accVsOppMap.get(opp.AccountId).add(opp);
                }else{
                    accVsOppMap.put(opp.AccountId, new List<Opportunity>{opp});
                }
            }
            
            List<Case> caseList = new List<Case>();
            List<Case> caseListToUpdate = new List<Case>();
            for(Case c : lstCase){
                if(accVsOppMap.get(c.AccountId) != null && accVsOppMap.get(c.AccountId).size() > 0){
                    if(c.RW_Project__c != null){
                        for(Opportunity opp : accVsOppMap.get(c.AccountId)){
                            if(c.RW_Project__c == opp.RW_Project__c){
                                c.RW_Project_Unit__c = opp.RW_Project_Unit__c;
                                c.Opportunity__c = opp.Id;
                                if(!caseList.contains(c)){
                                    caseList.add(c);
                                }
                                caseListToUpdate.add(c);
                            }
                        }
                    }else{
                        c.RW_Project_Unit__c = accVsOppMap.get(c.AccountId)[0].RW_Project_Unit__c;
                        c.RW_Project__c = accVsOppMap.get(c.AccountId)[0].RW_Project__c;
                        c.Opportunity__c = accVsOppMap.get(c.AccountId)[0].Id;
                        if(!caseList.contains(c)){
                            caseList.add(c);
                        }
                        caseListToUpdate.add(c);
                    }
                }
                c.Triggered_for_CRN_update__c = true;
                if(!caseList.contains(c)){
                    caseList.add(c);
                }
                
            }
            if(caseList.size() > 0){
                System.debug('caseList: ' + caseList);
                try{
                    //update caseList;
                    Database.update(caseList,false);
                }catch(exception ex){
                    System.debug('Error: '+ex);
                }
                
            }
        }
        
    }
    
    global void finish(Database.BatchableContext bc) {
    }
}