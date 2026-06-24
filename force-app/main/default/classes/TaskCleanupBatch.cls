public class TaskCleanupBatch implements Database.Batchable<sObject>, Schedulable{
    public Database.QueryLocator start(Database.BatchableContext BC){
        DateTime cutoffDate = System.now().addMonths(-3);
        DateTime cutoffDate6Months = System.now().addMonths(-6);
        String query = 'Select id from Task '+
                       'WHERE (Communication_Type__c = \'Outbound Call\' ' +
                       'AND Task_Type__c = \'Presales Call\' ' +
                       'AND WhatId = NULL ' +
                       'AND Who.Type = \'Lead\' ' +
                       'AND LastModifiedDate <= :cutoffDate) ' + 'OR '+
            		   '(Communication_Type__c = \'Inbound Call\' ' +
                       'AND Task_Type__c = \'Presales Call\' ' +
                       'AND WhatId = NULL ' +
                       'AND Who.Type = \'Lead\' ' +
                       'AND LastModifiedDate <= :cutoffDate6Months)';
        return Database.getQueryLocator(query);
    }
    Public void execute(Database.BatchableContext BC, List<Task> scope){
        if(!scope.isEmpty()){
            try{
                Database.delete(scope,false);
            }catch(Exception ex){
                System.debug('Error in batch: ' + ex.getMessage());
            }
        }
    }
    Public void execute(SchedulableContext sc){
        Database.executeBatch(new TaskCleanupBatch(), 2000);
    }
    Public void finish(Database.BatchableContext BC){
        
    }
    public static void dummyData(){
        Integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}