global class UpdateMobileOnOppFromAccBatch implements Database.Batchable <sObject>, Schedulable {
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id, Name, RW_Mobile_No__c, Account.Mobile_No__c FROM Opportunity WHERE RW_Mobile_No__c = null AND Account.Mobile_No__c != null]);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> opps){
        List<Opportunity> oppToUpdate = new List<Opportunity>();
        for(Opportunity opp : opps){
            if(opp.RW_Mobile_No__c == null && opp.Account.Mobile_No__c != null){
                opp.RW_Mobile_No__c = opp.Account.Mobile_No__c;
                oppToUpdate.add(opp);
            }
        }
        update oppToUpdate;
    }
    
    global void finish(Database.BatchableContext BC){

    }
    
    global void execute(SchedulableContext dc) {

        UpdateMobileOnOppFromAccBatch b = new UpdateMobileOnOppFromAccBatch();
        Database.executeBatch(b, 1);
    }
    
}