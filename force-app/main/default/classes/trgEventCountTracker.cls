@isTest
public class trgEventCountTracker 
{ 
    static testMethod void myUnitTest() 
    {
        Project__c objProj = new Project__c();
        objProj.name = 'test';
        insert objProj;
       
        
        Account objAcc = new Account();
        objAcc.name = 'test';
        insert objAcc;
    
        Opportunity objopp = new Opportunity();
        objopp.name = 'test';
        objopp.AccountId = objAcc.id;
        objopp.CloseDate = system.today();
        objopp.StageName = 'Qualification';
        objopp.RW_Project__c = objProj.id;
        objopp.RW_Mobile_No__c = '1233211231';
        objopp.RW_Email__c = 'test1@test2.com';
        //objopp.RW_Project_Unit__c = objPU.id;
        insert objopp;
        
        event objEvent = new Event();
        objEvent.Subject = 'Site Visit';
        objEvent.StartDateTime = System.now();
        objEvent.EndDateTime = System.now();
        objEvent.WhatId= objopp.Id;
        objEvent.OwnerId = UserInfo.getUserId();
        insert objEvent;
    }
}