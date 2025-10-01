global class BatchforReminderTaskCloseonCstPayment implements Database.Batchable<sObject>,Database.Stateful {//, Schedulable   
    public list<Booking__c> bookingListToUpdate = new list<Booking__c>();
    Public static void callBatchforReminderTaskCloseonCstPayment(){
        BatchforReminderTaskCloseonCstPayment  bb = new BatchforReminderTaskCloseonCstPayment();
        Database.executeBatch(bb,50);
    }
    global Database.QueryLocator start(Database.BatchableContext bc){
        system.debug('Inside start method----');
        Id ReminderLetterRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Reminder letter').getRecordTypeId();  
        Date todayDate = System.today();
        return Database.getQueryLocator([SELECT Id, Subject, WhatId FROM Task WHERE RecordTypeId =: ReminderLetterRecTypeId AND Status = 'In-progress' and ActivityDate =:todayDate]); 
    }
    
    global void execute(Database.BatchableContext bc, List<Task> tasklist){
        system.debug('Inside execute method----');
        System.debug('Task list size: ' + tasklist.size());
        System.debug('Task list content: ' + tasklist);
        list<Task> tsktoUpdate = new list<Task>();
        For(Task t : tasklist){
            t.Status = 'Customer Paid';
            tsktoUpdate.add(t);
        }
        if (!tsktoUpdate.isEmpty()) {
            Database.SaveResult[] updateResults = Database.update(tsktoUpdate, false);
            
            for (Database.SaveResult sr : updateResults) {
                if (!sr.isSuccess()) {
                    for (Database.Error err : sr.getErrors()) {
                        System.debug('Update Error: ' + err.getStatusCode() + ' - ' + err.getMessage());
                    }
                }
            }
        }
    }
  
    global void finish(Database.BatchableContext bc) {
    System.debug('Inside Finish Method');

   
}
}