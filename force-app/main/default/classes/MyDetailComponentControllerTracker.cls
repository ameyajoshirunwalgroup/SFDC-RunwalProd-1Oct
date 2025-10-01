/*
---------------------------------------------------------------------------------------
Name: Chayan Batabyal
Date: 27/1/17
Email Id: chayan.batabyal@saasfocus.com
Tracker For: MyDetailComponentController
---------------------------------------------------------------------------------------
*/

@isTest(seeAllData = false)
public class MyDetailComponentControllerTracker
{
    public static Account objAcc;
    public static Opportunity objOpp;
    public static Project__c objProject;
    public static Project_Unit__c objUnit;
    public static RW_Construction_Stage__c objConstructionStage;
    public static Attachment objAttach;
    public static User objUser;
    
    public static testMethod void myTest1()
    {
        LoadData();
        System.runAs(objUser)
        {
            MyDetailComponentController.getOpportunityData();
            MyDetailComponentController.getstageData(objProject.Id);
        }
    }
    
    public static void LoadData()
    {
        List<User> a1 = [Select Id, Name from User where Profile.Name = 'System Administrator' and UserRoleId != null and IsActive= true];
        objAcc = new Account();
        objAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        objAcc.LastName = 'testAcc LastName';
        objAcc.PersonEmail = 'test1@test2.com';
        objAcc.PersonMobilePhone = '1233211231';
        objAcc.ownerId = a1[0].Id;
        insert objAcc;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Community Login User Custm' and UserLicense.Name = 'Customer Community Login'];
        List<account> lstAccount = [Select Id, IsPersonAccount, PersonContactId from account where id =: objAcc.id];
        
        objUser = new User(Alias = 'standt', Email='standardTest@testing.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@testorg.com',
            ContactId = lstAccount[0].PersonContactId);
        insert objUser;
        
        objProject = new Project__c();
        objProject.Name = 'testProject';
        objProject.RW_Status__c = 'Active';
        objProject.RW_Project_Code__c = '007';
        insert objProject;
        
        objUnit = new Project_Unit__c();
        objUnit.RW_Project__c = objProject.Id;
        objUnit.RW_Param1__c = 'P1';
        objUnit.RW_Param2__c = 'P2';
        objUnit.RW_Param3__c = 'P3';
        objUnit.RW_Param4__c = 'P4';
        objUnit.RW_Unit_Status__c = 'Available';
        insert objUnit;
        
        objOpp = new Opportunity();
        objOpp.AccountId = objAcc.Id;
        objOpp.Amount = 500;
        objOpp.Name = 'testOppName';
        objOpp.StageName = 'Qualification';
        objOpp.LeadSource = 'Outdoor';
        objOpp.CloseDate = Date.today();
        objOpp.RW_Project__c = objProject.Id;
        objOpp.RW_Project_Unit__c = objUnit.Id;
        insert objOpp;
        
        objConstructionStage = new RW_Construction_Stage__c();
        objConstructionStage.Name = 'testName';
        objConstructionStage.RW_Project__c = objProject.Id;
        objConstructionStage.RW_Sequence_No__c = 5.5;
        insert objConstructionStage;
        
        objAttach = new Attachment();
        objAttach.Body = Blob.valueOf('o');
        objAttach.Name = 'testName';
        objAttach.Description = 'testDescription';
        objAttach.ParentId = objConstructionStage.Id;
        insert objAttach;
    }
}