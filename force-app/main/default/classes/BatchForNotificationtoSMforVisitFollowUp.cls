global class BatchForNotificationtoSMforVisitFollowUp implements Database.Batchable<sObject> {
   @InvocableMethod(Label='Batch for Notification to SM for Visit Follow-Up')
    Public static void callCustomNotificationBatch(){
        BatchForNotificationtoSMforVisitFollowUp  bb = new BatchForNotificationtoSMforVisitFollowUp();
        Database.executeBatch(bb,1);
    }
    global Database.QueryLocator start(Database.BatchableContext bc){
        system.debug('Inside start method----');
        Date oneDaysBefore = Date.today().addDays(-1);
        return Database.getQueryLocator([Select Id, Name, Date_Of_Visit__c, RW_Sales_Associate__c, RW_Project__c, OwnerId, StageName
                                         from Opportunity
                                         where Date_Of_Visit__c != null 
                                         and RW_Sales_Associate__c != null 
                                         and StageName != 'Unit Blocked' 
                                         and StageName != 'Unit Booked' 
                                         and RW_CIF_form_number__c != null 
                                         and Date_Of_Visit__c = :oneDaysBefore]);
    }
    
    global void execute(Database.BatchableContext bc, List<Opportunity> opplist){
        system.debug('Inside execute method----');
        
        Set<Id> oppIds = new Set<Id>();
        
        system.debug('opplist'+opplist);
        system.debug('opplist size'+opplist.size());
        
        if(!opplist.isEmpty()){
           SendNotificationtoSMforVisitFollowUp.sendCustomNotification(opplist);
        } else{
            System.debug('No Records Found');
        }
       
    }
    
    global void finish(Database.BatchableContext bc) {
        System.debug('I ma in Finish Method----');
        
        Date fiveDaysBefore = Date.Today().addDays(-5);   
        list<Task> tasklist = [Select Id,ActivityDate from Task where Subject = 'Visit Follow Up - Auto' and Status != 'Completed'];
        system.debug('tasklist'+tasklist.size());
        list<Task> tasktoUpdate = new list<Task>();
        for(Task t : tasklist){
            system.debug('task created date'+t.ActivityDate);
            if(t.ActivityDate == fiveDaysBefore){
                t.Status = 'Completed';
                tasktoUpdate.add(t);
            }
        }
        if(!tasktoUpdate.isEmpty()){
            try{
                update tasktoUpdate;
            }catch(Exception e){
                system.debug('Error while updating Task records------>>>>>'+e.getMessage());
            }
        }
    }
}