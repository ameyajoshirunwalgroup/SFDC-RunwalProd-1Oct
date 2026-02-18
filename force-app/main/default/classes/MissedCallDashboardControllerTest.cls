@isTest
public class MissedCallDashboardControllerTest {

    @isTest
    static void testGetMissedCalls() {

        // Create Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        

        // Create Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Customer',
            StageName = 'Unit Booked',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id,
            Last_CRM_Call_Subject__c = 'Missed Call'
        );
        insert opp;
        
        // Create Missed Call Task
        Task t = new Task(
            WhatId = opp.Id,
            Subject = 'Missed Call',
            Task_Type__c = 'CRM Call',
            Communication_Type__c = 'Inbound Call',
            Status = 'Not Started',
            Priority = 'Normal'
        );
        insert t;

        // Make the task older (for ageing calculation)
        Test.setCreatedDate(t.Id, System.now().addHours(-8));
        
        Test.startTest();
        List<MissedCallDashboardController.MissedCallWrapper> result =
            MissedCallDashboardController.getMissedCalls();
        Test.stopTest();

    }
}