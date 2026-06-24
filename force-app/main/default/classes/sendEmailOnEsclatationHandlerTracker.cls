@isTest
public class sendEmailOnEsclatationHandlerTracker {
    
    @isTest
    static void myUnitTest() {
        // Create test Account
        Account objAcc = new Account(Name = 'Test Account');
        insert objAcc;
        
        // Create test Opportunity
        Opportunity objOpp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = objAcc.Id,
            CloseDate = System.today(),
            StageName = 'Qualification',
            RW_Mobile_No__c = '1233211231',
            RW_Email__c = 'test1@test2.com'
        );
        insert objOpp;

        // Create test Task (this should trigger 'after insert' logic)
        Task objTask = new Task(
            Subject = 'Call Customer',
            Priority = 'Normal',
            OwnerId = UserInfo.getUserId(),
            WhatId = objOpp.Id,
            Status = 'Completed',
            RW_Call_Completion__c = true
        );
        insert objTask;

        // Update Task (this should trigger 'after update' logic)
        objTask.Call_Status__c = 'Visit Confirmed';
        objTask.RW_Call_Timing__c = System.now();
        update objTask;
    }
}