@isTest
public with sharing class RWTaskTriggerHandlerTracker 
{
    
    
    /*public static testmethod void unitTest1()
    {
        
        
        
        
        Account objAccount = new Account();
        objAccount.Name = 'AccountName';
        
        insert objAccount;
        
        Project__c objProject = new Project__c();
        objProject.Name = 'Project1';
        objProject.RW_Status__c = 'Active';
        
        insert objProject;
        
        Case objCase = new Case();
        objCase.Status = 'Open';
        objCase.RW_RM_Name__c = 'Rishi';
        objCase.Accountid = objAccount.id;
        objCase.Description = 'Description';
        objCase.RW_Project__c = objProject.id;
        objCase.Origin = 'Email';
        objCase.RW_Is_Owner_changed__c = false;
        
        insert objCase;
        objCase.RW_Is_Owner_changed__c = true;
        update objCase;
        
        
        Task objTask = new Task();
        objTask.subject ='Call Customer';
        objTask.whatid = objCase.id;
        objTask.Status = 'Completed';
        objTask.Project__c = objCase.RW_Project__c;
        objTask.Priority='Normal';
        //objTask.ownerid = objCase.ownerid;
        
        insert objTask;
        
        objTask.Status = 'Completed';
        
        update objTask;
        
               
    }*/
    
    @isTest
    public static void test1(){
        
        Project__c objProject = new Project__c();
        objProject.Name = 'Project1';
        objProject.RW_Status__c = 'Active';
        objProject.Contact_No__c = '1111111111';
        insert objProject;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Unit Booked';
        opp.CloseDate = Date.today() + 5;
        opp.RW_Email__c = 'test@mail.com';
        opp.RW_Project__c = objProject.Id;
        insert opp;
        
        Account objAccount = new Account();
        objAccount.Name = 'AccountName';
        insert objAccount;
        
        Case cs = new Case();
        cs.AccountId = objAccount.Id;
        cs.Subject = 'Test';
        cs.OwnerId = UserInfo.getUserId();
        insert cs;
        
        Not_Contactable_Email_Alerts__c nc = new Not_Contactable_Email_Alerts__c();
        nc.Name = 'Sales Task';
        nc.Email_Template__c = 'Not_Contactable_Call_Email_CRM';
        nc.Number_Field__c = 'Contact_No__c';
        insert nc;
        
        Id tskRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Sales Task').getRecordTypeId();
        Id custIntrRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Customer Interaction').getRecordTypeId();
        List<Task> tskList = new List<Task>();
        
        Task objTask = new Task();
        objTask.subject ='Test';
        objTask.WhatId = opp.Id;
        objTask.Status = 'Not Started';
        objTask.Priority='Normal';
        objTask.RecordTypeId = tskRecTypeId;
        objTask.Communication_Type__c = 'Outbound Call';
        //insert objTask;
        tskList.add(objTask);
        
        
        
        Task objTask1 = new Task();
        objTask1.subject ='Test';
        objTask1.WhatId = cs.Id;
        objTask1.Status = 'Not Started';
        objTask1.Priority='Normal';
        objTask1.RecordTypeId = custIntrRecTypeId;
        objTask1.Description = 'Testing';
        //insert objTask1;
        tskList.add(objTask1);
        insert tskList;
        
        objTask.Status = 'Completed';
        objTask.Call_Status__c = 'Not Contactable';
        update objTask;
    }
}