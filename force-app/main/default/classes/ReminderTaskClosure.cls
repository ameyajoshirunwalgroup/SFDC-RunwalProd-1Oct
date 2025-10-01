/*global class BatchforReminderTaskClosure implements Database.Batchable<sObject> {
    global static void BatchforReminderTaskClosure(){
        System.debug('Inside BatchforReminderTaskClosure method');
        BatchforReminderTaskClosure bb = new BatchforReminderTaskClosure();
        Database.executeBatch(bb, 50);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        System.debug('Inside start method');
        Id ReminderLetterRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Reminder letter').getRecordTypeId();
        System.debug('Retrieved ReminderLetterRecTypeId: ' + ReminderLetterRecTypeId);
        return Database.getQueryLocator([SELECT Id, Subject, WhatId FROM Task WHERE RecordTypeId =: ReminderLetterRecTypeId AND Status != 'Completed']);
    }
    
    global void execute(Database.BatchableContext bc, List<Task> tasklist){
        System.debug('Inside execute method');
        System.debug('Task list size: ' + tasklist.size());
        System.debug('Task list content: ' + tasklist);
        
        Map<Id, List<Task>> customertoTaskMap = new Map<Id, List<Task>>();
        List<Task> tasksToUpdate = new List<Task>();
        
        if (!tasklist.isEmpty()) {
            for (Task t : tasklist) {
                System.debug('Processing Task: ' + t);
                if (!customertoTaskMap.containsKey(t.WhatId)) {
                    customertoTaskMap.put(t.WhatId, new List<Task>());
                }
                customertoTaskMap.get(t.WhatId).add(t);
            }
            
            System.debug('Customer to Task Map: ' + JSON.serialize(customertoTaskMap));
            
            for (Id customerId : customertoTaskMap.keySet()) {
                System.debug('Processing Customer ID: ' + customerId);
                Map<String, Task> taskMap = new Map<String, Task>();
                
                for (Task t : customertoTaskMap.get(customerId)) {
                    System.debug('Adding to taskMap: ' + t.Subject);
                    taskMap.put(t.Subject, t);
                }
                
                System.debug('Task Map for customer ' + customerId + ': ' + JSON.serialize(taskMap));
                
                if (taskMap.containsKey('REMINDER2') && taskMap.containsKey('REMINDER1')) {
                    System.debug('Closing Reminder 1');
                    Task reminderToClose = taskMap.get('REMINDER1');
                    reminderToClose.Status = 'Completed';
                    tasksToUpdate.add(reminderToClose);
                }
                if (taskMap.containsKey('REMINDER3') && taskMap.containsKey('REMINDER2')) {
                    System.debug('Closing Reminder 2');
                    Task reminderToClose = taskMap.get('REMINDER2');
                    reminderToClose.Status = 'Completed';
                    tasksToUpdate.add(reminderToClose);
                }
                if (taskMap.containsKey('REMINDER4') && taskMap.containsKey('REMINDER3')) {
                    System.debug('Closing Reminder 3');
                    Task reminderToClose = taskMap.get('REMINDER3');
                    reminderToClose.Status = 'Completed';
                    tasksToUpdate.add(reminderToClose);
                }
                if (taskMap.containsKey('REMINDER5') && taskMap.containsKey('REMINDER4')) {
                    System.debug('Closing Reminder 4');
                    Task reminderToClose = taskMap.get('REMINDER4');
                    reminderToClose.Status = 'Completed';
                    tasksToUpdate.add(reminderToClose);
                }
                if (taskMap.containsKey('REMINDER6') && taskMap.containsKey('REMINDER5')) {
                    System.debug('Closing Reminder 5');
                    Task reminderToClose = taskMap.get('REMINDER5');
                    reminderToClose.Status = 'Completed';
                    tasksToUpdate.add(reminderToClose);
                }
                if (taskMap.containsKey('Default Notice') && taskMap.containsKey('REMINDER6')) {
                    System.debug('Closing Reminder 6');
                    Task reminderToClose = taskMap.get('REMINDER6');
                    reminderToClose.Status = 'Completed';
                    tasksToUpdate.add(reminderToClose);
                }
                if (taskMap.containsKey('Termination') && taskMap.containsKey('Default Notice')) {
                    System.debug('Closing Default Notice');
                    Task reminderToClose = taskMap.get('Default Notice');
                    reminderToClose.Status = 'Completed';
                    tasksToUpdate.add(reminderToClose);
                }
            }
        } else {
            System.debug('No Records Found');
        }
        
        if (!tasksToUpdate.isEmpty()) {
            System.debug('Updating Tasks: ' + JSON.serialize(tasksToUpdate));
            Database.SaveResult[] updateResults = Database.update(tasksToUpdate, false);
            
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
        System.debug('Inside finish method');
    }
}

*/


//Added by Prashant to Close Reminder tasks on due. 31-3-25.
public class ReminderTaskClosure {
    public static void ReminderTaskClosure(){
        Id ReminderLetterRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Reminder letter').getRecordTypeId();
        Date yesterdayDate = System.today().addDays(-1);
        list<Task> tasklist = [SELECT Id, Subject, WhatId FROM Task WHERE RecordTypeId =: ReminderLetterRecTypeId AND Status = 'In-progress' and DAY_ONLY(CreatedDate) =: yesterdayDate ];
        System.debug('Task list size: ' + tasklist.size());
        System.debug('Task list content: ' + tasklist);
        
        Map<Id, List<Task>> customertoTaskMap = new Map<Id, List<Task>>();
        List<Task> tasksToUpdate = new List<Task>();
        
        if (!tasklist.isEmpty()) {
            for (Task t : tasklist) {
                System.debug('Processing Task: ' + t);
                if (!customertoTaskMap.containsKey(t.WhatId)) {
                    customertoTaskMap.put(t.WhatId, new List<Task>());
                }
                customertoTaskMap.get(t.WhatId).add(t);
            }
            
            System.debug('Customer to Task Map: ' + JSON.serialize(customertoTaskMap));
            
            for (Id customerId : customertoTaskMap.keySet()) {
                System.debug('Processing Customer ID: ' + customerId);
                Map<String, Task> taskMap = new Map<String, Task>();
                
                for (Task t : customertoTaskMap.get(customerId)) {
                    System.debug('Adding to taskMap: ' + t.Subject);
                    taskMap.put(t.Subject, t);
                }
                
                //System.debug('Task Map for customer ' + customerId + ': ' + JSON.serialize(taskMap));
                
                if (taskMap.containsKey('REMINDER2') && taskMap.containsKey('REMINDER1')) {
                    System.debug('Closing Reminder 1');
                    Task reminderToClose = taskMap.get('REMINDER1');
                    reminderToClose.Status = 'Completed';
                    tasksToUpdate.add(reminderToClose);
                }
                if (taskMap.containsKey('REMINDER3') && taskMap.containsKey('REMINDER2')) {
                    System.debug('Closing Reminder 2');
                    Task reminderToClose = taskMap.get('REMINDER2');
                    reminderToClose.Status = 'Completed';
                    tasksToUpdate.add(reminderToClose);
                }
                if (taskMap.containsKey('REMINDER4') && taskMap.containsKey('REMINDER3')) {
                    System.debug('Closing Reminder 3');
                    Task reminderToClose = taskMap.get('REMINDER3');
                    reminderToClose.Status = 'Completed';
                    tasksToUpdate.add(reminderToClose);
                }
                if (taskMap.containsKey('REMINDER5') && taskMap.containsKey('REMINDER4')) {
                    System.debug('Closing Reminder 4');
                    Task reminderToClose = taskMap.get('REMINDER4');
                    reminderToClose.Status = 'Completed';
                    tasksToUpdate.add(reminderToClose);
                }
                if (taskMap.containsKey('REMINDER6') && taskMap.containsKey('REMINDER5')) {
                    System.debug('Closing Reminder 5');
                    Task reminderToClose = taskMap.get('REMINDER5');
                    reminderToClose.Status = 'Completed';
                    tasksToUpdate.add(reminderToClose);
                }
                if (taskMap.containsKey('Default Notice') && taskMap.containsKey('REMINDER6')) {
                    System.debug('Closing Reminder 6');
                    Task reminderToClose = taskMap.get('REMINDER6');
                    reminderToClose.Status = 'Completed';
                    tasksToUpdate.add(reminderToClose);
                }
                if (taskMap.containsKey('Termination') && taskMap.containsKey('Default Notice')) {
                    System.debug('Closing Default Notice');
                    Task reminderToClose = taskMap.get('Default Notice');
                    reminderToClose.Status = 'Completed';
                    tasksToUpdate.add(reminderToClose);
                }
            }
        } else {
            System.debug('No Records Found');
        }
        
        if (!tasksToUpdate.isEmpty()) {
            System.debug('Updating Tasks: ' + JSON.serialize(tasksToUpdate));
            Database.SaveResult[] updateResults = Database.update(tasksToUpdate, false);
            
            for (Database.SaveResult sr : updateResults) {
                if (!sr.isSuccess()) {
                    for (Database.Error err : sr.getErrors()) {
                        System.debug('Update Error: ' + err.getStatusCode() + ' - ' + err.getMessage());
                    }
                }
            }
        }
    }
        
    
}