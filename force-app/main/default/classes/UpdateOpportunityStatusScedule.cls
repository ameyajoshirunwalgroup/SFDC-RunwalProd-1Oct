global class UpdateOpportunityStatusScedule implements Database.Batchable<sObject>,  Schedulable{

    global Database.QueryLocator start(Database.BatchableContext BC){
        
        return Database.getQueryLocator([SELECT Id, Opportunity_Status__c, RW_Opportunity_Status__c FROM Opportunity WHERE Opportunity_Status_Matched__c = false]);
    }
    
    global void execute(Database.BatchableContext BC,list<Opportunity> oppList){
        if(oppList.size() > 0){
            for(Opportunity opp : oppList){
                opp.Opportunity_Status__c = opp.RW_Opportunity_Status__c;
            }
            Database.update(oppList, false);
            //update oppList;
        }
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
    
    global void execute(SchedulableContext dc) {

        UpdateOpportunityStatusScedule b = new UpdateOpportunityStatusScedule();
        Database.executeBatch(b, 100);
    }
}