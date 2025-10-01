@isTest
public class sendEmailOnEsclatationHandlerTracker
{
    static testMethod void myUnitTest() 
    {
        Account objAcc = new Account();
        objAcc.name = 'test';
        insert objAcc;
        
        Opportunity objopp = new Opportunity();
        objopp.name = 'test';
        objopp.AccountId = objAcc.id;
        objopp.CloseDate = system.today();
        objopp.StageName = 'Qualification';
        objopp.RW_Mobile_No__c = '1233211231';
        objopp.RW_Email__c = 'test1@test2.com';
        //objopp.RW_Project__c = objProj.id;
        //objopp.RW_Project_Unit__c = objPU.id;
        insert objopp;
        
        Task objTask = new Task();
        objTask.Subject = 'Call Customer';
        objTask.Priority = 'Normal';
        objTask.OwnerId = UserInfo.getUserId();
        objTask.WhatId = objopp.id;
        objTask.Status ='Completed';
        objTask.RW_Call_Completion__c = true;
        insert objTask;
        
        objTask.Priority = 'Normal';
        objTask.Call_Status__c = 'Visit Confirmed';
        objTask.RW_Call_Timing__c = system.now();
        update objTask;


        //objTask.RW_Call_Completion__c = true;
        //update objTask;
        
    }

}