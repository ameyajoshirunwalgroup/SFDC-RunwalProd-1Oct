global class BatchforReminderTaskClosure implements Database.Batchable<sObject> {
    global static void BatchforReminderTaskClosure(){
        BatchforReminderTaskClosure  bb = new BatchforReminderTaskClosure();
        Database.executeBatch(bb,50);
    }
    global Database.QueryLocator start(Database.BatchableContext bc){
        system.debug('Inside start method----');
        Id ReminderLetterRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Reminder letter').getRecordTypeId();
        return Database.getQueryLocator([Select Id,Subject,WhatId from Task where RecordTypeId =: ReminderLetterRecTypeId and Status != 'Completed']);
    }
    
    global void execute(Database.BatchableContext bc, List<Task> tasklist){
        system.debug('Inside execute method----');
        
        system.debug('tasklist'+tasklist);
         system.debug('tasklist'+tasklist.size());
        Map<Id,list<Task>> customertoTaskMap = new Map<Id,list<Task>>();
        list<Task> tasksToUpdate = new list<Task>();
        if(!tasklist.isEmpty()){
            for(Task t : tasklist){
                if (!customertoTaskMap.containsKey(t.WhatId)) {
                    customertoTaskMap.put(t.WhatId, new List<Task>());
                }
                customertoTaskMap.get(t.WhatId).add(t);
            }
          
            system.debug('customertoTaskMap'+customertoTaskMap);
            for(Id customerId : customertoTaskMap.keySet()){
                Map<String, Task> taskMap = new Map<String, Task>();
                for(Task t : customertoTaskMap.get(customerId)){
                    taskMap.put(t.Subject, t);
                }
                if (taskMap.containsKey('REMINDER2') && taskMap.containsKey('REMINDER1')) {
                    system.debug('Inside Reminder 1 Closure');
                    Task reminderToClose = taskMap.get('REMINDER1');
                    reminderToClose.Status = 'Completed';
                    tasksToUpdate.add(reminderToClose);
                }
                if (taskMap.containsKey('REMINDER3') && taskMap.containsKey('REMINDER2')) {
                    system.debug('Inside Reminder 2 Closure');
                    Task reminderToClose = taskMap.get('REMINDER2');
                    reminderToClose.Status = 'Completed';
                    tasksToUpdate.add(reminderToClose);
                }
                if (taskMap.containsKey('REMINDER4') && taskMap.containsKey('REMINDER3')) {
                    system.debug('Inside Reminder 3 Closure');
                    Task reminderToClose = taskMap.get('REMINDER3');
                    reminderToClose.Status = 'Completed';
                    tasksToUpdate.add(reminderToClose);
                }
                if (taskMap.containsKey('REMINDER5') && taskMap.containsKey('REMINDER4')) {
                    system.debug('Inside Reminder 4 CLosure');
                    Task reminderToClose = taskMap.get('REMINDER4');
                    reminderToClose.Status = 'Completed';
                    tasksToUpdate.add(reminderToClose);
                }
                if (taskMap.containsKey('REMINDER6') && taskMap.containsKey('REMINDER5')) {
                    system.debug('Inside Reminder 5 Closure');
                    Task reminderToClose = taskMap.get('REMINDER5');
                    reminderToClose.Status = 'Completed';
                    tasksToUpdate.add(reminderToClose);
                }
                if (taskMap.containsKey('Default Notice') && taskMap.containsKey('REMINDER6')) {
                    system.debug('Inside Reminder 6 Closure');
                    Task reminderToClose = taskMap.get('REMINDER6');
                    reminderToClose.Status = 'Completed';
                    tasksToUpdate.add(reminderToClose);
                }
                if (taskMap.containsKey('Termination') && taskMap.containsKey('Default Notice')) {
                    system.debug('Inside Default Notice Closure');
                    Task reminderToClose = taskMap.get('Default Notice');
                    reminderToClose.Status = 'Completed';
                    tasksToUpdate.add(reminderToClose);
                }
            }
        } else{
            System.debug('No Records Found');
        }
       if(!tasksToUpdate.isEmpty()){
                Database.SaveResult[] wiList = Database.update(tasksToUpdate, false);                
                for(Database.SaveResult sr : wiList){
                    if(!sr.isSuccess()){
                        for(Database.Error err : sr.getErrors()){
                            System.debug(err.getStatusCode() + ':' + err.getMessage());
                        }
                    }
                }
            }
    }
    
    global void finish(Database.BatchableContext bc) {
        System.debug('I ma in Finish Method----');
    }
}