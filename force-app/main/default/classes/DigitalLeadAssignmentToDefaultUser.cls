global class DigitalLeadAssignmentToDefaultUser implements Database.Batchable <sObject>, Database.AllowsCallouts, Schedulable{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        if(!Test.isRunningTest()){
            return Database.getQueryLocator([SELECT Id, Name FROM Lead WHERE (CreatedDate = TODAY OR CreatedDate = YESTERDAY) AND (Owner.Name = 'System Admin' OR Owner.Name = 'Integration Admin')]);
        }else{
            return Database.getQueryLocator([SELECT Id, Name FROM Lead]);
        }
    }
    
    global void execute(Database.BatchableContext bc, list <Lead> leads){
        if(leads.size() > 0){
            for(Lead ld : leads){
                ld.OwnerId = System.label.Presales_Default_User;
            }
            update leads;
        }
    }
    
    global void finish(Database.BatchableContext bc){
        
    }
    
    global void execute(SchedulableContext dc) {
        DigitalLeadAssignmentToDefaultUser b = new DigitalLeadAssignmentToDefaultUser();
        Database.executeBatch(b, 20);
    }

}