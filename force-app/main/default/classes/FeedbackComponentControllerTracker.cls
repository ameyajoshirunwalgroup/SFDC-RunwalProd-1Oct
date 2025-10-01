/*
---------------------------------------------------------------------------------------
Name: Chayan Batabyal
Date: 27/1/17
Email Id: chayan.batabyal@saasfocus.com
Tracker For: FeedbackComponentController
---------------------------------------------------------------------------------------
*/

@istest(seeAllData = false)
public class FeedbackComponentControllerTracker
{
    public static Account objAcc;
    public static Opportunity objOpp;
    public static Project__c objProject;
    public static Project_Unit__c objUnit;
    public static User objUser;
    public static RW_Feedback__c objFeed;
    public static List<RW_Feedback__c> lstFeed;
    
    public static testMethod void myTest1()
    {
        LoadData();
        insert objFeed;
        lstFeed.add(objFeed);
        
        System.runAs(objUser)
        {
            FeedbackComponentController.getFeedBackData();
            FeedbackComponentController.SaveFeedBackData(lstFeed);
        }
    }
    
    public static testMethod void myTest2()
    {
        LoadData();
        
        objFeed.RW_Tell_us_about_our_service__c = 'test';
        insert objFeed;
        
        lstFeed.add(objFeed);
        
        System.runAs(objUser)
        {
            FeedbackComponentController.getFeedBackData();
            FeedbackComponentController.SaveFeedBackData(lstFeed);
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
        objUnit.RW_Param5__c = 'P5';
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
        objOpp.RW_Possession_Done__c = true;
        insert objOpp;
        
        lstFeed = new List<RW_Feedback__c>();
        objFeed = new RW_Feedback__c();
        objFeed.RW_Opportunity__c = objOpp.Id;
        objFeed.RW_Hospitality_by_the_executive__c = 'test';
        objFeed.RW_Rate_Our_Service__c = '5';
    }
}