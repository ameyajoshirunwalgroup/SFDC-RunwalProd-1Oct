global class FBGetLeadsBatch implements Database.Batchable <sObject>,Database.AllowsCallouts, Schedulable {
    Public String Query;
    
    public FBGetLeadsBatch() {
        Query = 'Select Id, Name,Lead_ID__c, Form_ID__c, Form_Data__c from Social_media_lead__c where processed__c = false and isDeleted= false';
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext info, List<Social_Media_Lead__c> scope){
           SocialMediaLeadServices.getFBleads(scope);
    }
    
    global void finish(Database.BatchableContext info){     
    }   
    
    global void execute(SchedulableContext sc) {
      FBGetLeadsBatch b = new FBGetLeadsBatch(); 
      database.executebatch(b,1);
     }    
}