@isTest
public class Batch_SendEscallationMailTracker
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
        
        list<task> lstTask = new list<task>();
        
        Task objTask = new Task();
        objTask.Subject = 'Call Customer';
        objTask.Priority = 'Normal';
        objTask.OwnerId = UserInfo.getUserId();
        objTask.WhatId = objopp.id;
        objTask.ActivityDate = system.today();
        lstTask.add(objTask);
        
        Task objTask1 = new Task();
        objTask1.Subject = 'Call Customer';
        objTask1.Priority = 'Normal';
        objTask1.OwnerId = UserInfo.getUserId();
        objTask1.WhatId = objopp.id;
        objTask1.ActivityDate = system.today().addDays(-1);
        lstTask.add(objTask1);
        
        Task objTask2 = new Task();
        objTask2.Subject = 'Call Customer';
        objTask2.Priority = 'Normal';
        objTask2.OwnerId = UserInfo.getUserId();
        objTask2.WhatId = objopp.id;
        objTask2.ActivityDate = system.today().addDays(-2);
        lstTask.add(objTask2);
        
        insert lstTask;
        Database.BatchableContext BC;
        Batch_SendEscallationMail objClass = new Batch_SendEscallationMail();
        objClass.start(BC);
        objClass.execute(BC,lstTask);
        objClass.finish(BC);
    }

}