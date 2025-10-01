/*
---------------------------------------------------------------------------------------
Name: Chayan Batabyal
Date: 27/1/17
Email Id: chayan.batabyal@saasfocus.com
Tracker For: RefferalController
---------------------------------------------------------------------------------------
*/

@isTest(seeAllData = false)
public class RefferalControllerTracker
{
    public static Account objAcc;
    public static Opportunity objOpp;
    public static Project__c objProject;
    public static Project_Unit__c objUnit;
    public static Lead objLead;
    public static User objUser;
    
    public static testMethod void myTest1()
    {
        LoadData();
        
        System.runAs(objUser)
        {
            RefferalController.getLeadFromSFDC();
            RefferalController.getOpp();
            RefferalController.updateOpportunity(objOpp.Id);
            RefferalController.getProjName();
            RefferalController.insertLeadToServer('', 'FirstName', '1221122100', 'Email@mail.com', objProject.Name);
            RefferalController.insertLeadToServer('LastName', '', '1221122100', 'Email@mail.com', objProject.Name);
            RefferalController.insertLeadToServer('LastName', 'FirstName', '', 'Email@mail.com', objProject.Name);
            RefferalController.insertLeadToServer('LastName', 'FirstName', '1221122100', '', objProject.Name);
            RefferalController.insertLeadToServer('LastName', 'FirstName', '1221122100', 'Email@mail.com', '');
            RefferalController.insertLeadToServer('LastName', 'FirstName', '1221122100', 'Email@mail.com', objProject.Name);
            RefferalController.insertLeadToServer('LastName', 'FirstName', '1221122199', 'Email@mail.com', objProject.Name);
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
        objUnit.Name = 'testName';
        objUnit.RW_Project__c = objProject.Id;
        objUnit.RW_Param1__c = 'P1';
        objUnit.RW_Param2__c = 'P2';
        objUnit.RW_Param3__c = 'P3';
        objUnit.RW_Param4__c = 'P4';
        objUnit.RW_Param5__c = 'P5';
        objUnit.RW_Delimeter__c = '/';
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
        objOpp.Customer_Reference__c = objAcc.Id;
        insert objOpp;
        
        objLead = new Lead();
        objLead.LastName = 'testLast';
        objLead.Email = 'test@test.com';
        objLead.RW_Mobile_No__c = '1221122100';
        objLead.Remark__c = 'testRemark';
        objLead.RW_Project__c = objProject.Id;
        objLead.RW_Rating__c = 'Hot';
        objLead.Lead_Source__c = 'Reference';
        //objLead.RW_Reference_Source__c = 'Existing Customer Reference';
        objLead.RW_Lead_Sub_Source__c = 'Existing client reference';
        objLead.Status = 'Not Sure';
        objLead.Customer_Reference__c = objAcc.Id;
        objLead.Country__c = 'India';
        objLead.State__c = 'Odisha';
        objLead.City__c = 'Bhubaneshwar';
        objLead.RW_Budget__c = '< 1Cr';
        objLead.RW_Configuration__c = '1.5 BHK';
        objLead.RW_Location__c = 'MANGLAUR';
        objLead.RW_Time_line__c = 'Ready Possession';
        insert objLead;
    }
}