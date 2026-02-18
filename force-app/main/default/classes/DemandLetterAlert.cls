global class DemandLetterAlert implements Database.Batchable <sObject>, Database.AllowsCallouts, Schedulable{
    
	global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id, Booking__c, Booking__r.Opportunity__r.RW_Mobile_No__c, Booking__r.RW_Country_Phone_Code__c, Booking__r.Primary_Applicant_Name__c FROM RW_Demand__c WHERE CreatedDate = TODAY AND RW_Demand_Status__c != 'Revoke']);  // Added RW_Demand_Status__c != 'Revoke' by Vinay 03-10-2025
    }
    
    global void execute(Database.BatchableContext bc, list <RW_Demand__c> demands){
        if(demands.size() > 0){
            for(RW_Demand__c dem : demands){
                if(!Test.isRunningTest()){
                    String demLink ='id='+dem.Id+'&doc=dem';
                    SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(null,dem.Booking__r.Primary_Applicant_Name__c,null,null,null,null,null,null,demLink,dem.Booking__r.RW_Country_Phone_Code__c,dem.Booking__r.Opportunity__r.RW_Mobile_No__c,'Demand Letter');
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext bc){
        
    }
    
    global void execute(SchedulableContext dc) {
        DemandLetterAlert b = new DemandLetterAlert();
        Database.executeBatch(b, 20);
    }

}