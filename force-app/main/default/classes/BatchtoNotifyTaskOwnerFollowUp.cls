public class BatchtoNotifyTaskOwnerFollowUp implements Database.Batchable<sObject> {
    
    @InvocableMethod(Label='Batch to Notify Presales-Sales Task Owner for Follow-Up')
    Public static void callBatchtoNotifyTaskOwnerFollowUp(){
        BatchtoNotifyTaskOwnerFollowUp  bb = new BatchtoNotifyTaskOwnerFollowUp();
        Database.executeBatch(bb,50);
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        system.debug('Inside start method----');
        Id PreSalesTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Presales Task').getRecordTypeId();
        Id SalesTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Sales Task').getRecordTypeId();
        return Database.getQueryLocator([Select id,OwnerId,Next_Action_Date__c from Task where Next_Action_Date__c = TODAY and 
                                         (RecordTypeId =: PreSalesTaskRecordTypeId or RecordTypeId =: SalesTaskRecordTypeId)
                                         /*and Status != 'Completed'*/]); 
    }
    
    public void execute(Database.BatchableContext bc, List<Task> tlist){
        if(!tlist.isEmpty()){
            CustomNotificationType notificationType = [SELECT Id,DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'PushNotificationtoSM' limit 1];   
            system.debug('notificationType'+notificationType);              
            for(Task t : tlist){
                String formattedDate = t.Next_Action_Date__c.format('yyyy-MM-dd h:mm a');
                String Body = 'Reminder: Your follow-up with the customer is scheduled for today (' + formattedDate + ').';
                //String Body = 'Please Call ' + t.OwnerId + ' who visited on ' + t.Next_Action_Date__c;
                if (notificationType != null) {          
                    Messaging.CustomNotification customNotificationObj = new Messaging.CustomNotification();      
                    //if(Test.isRunningTest()){
                        customNotificationObj.setBody(Body);   
                    //}
                    customNotificationObj.setTitle('Reminder for Follow-Up');  
                    customNotificationObj.setNotificationTypeId(notificationType.id);                     
                    customNotificationObj.setTargetId(t.Id);
                    customNotificationObj.send(new Set<String> {t.OwnerId});
                }
            }
        }
        
        /*if(!tlist.isEmpty()){
            Database.SaveResult[] wiList = Database.update(tlist, false);
		
            for(Database.SaveResult sr : wiList){
                if(!sr.isSuccess()){
                    for(Database.Error err : sr.getErrors()){
                        System.debug(err.getStatusCode() + ':' + err.getMessage());
                    }
                }
            }
        }*/
    }	
    
    public void finish(Database.BatchableContext bc) {}
}