/*
---------------------------------------------------------------------------------------
Name: Chayan Batabyal
Date: 27/1/17
Email Id: chayan.batabyal@saasfocus.com
Tracker For: DocumentComponentController
---------------------------------------------------------------------------------------
*/

@istest(seeAllData = false)
public class DocumentComponentControllerTracker
{
    public static Account objAcc;
    public static Opportunity objOpp;
    public static Project__c objProject;
    public static Project_Unit__c objUnit;
    public static User objUser;
    public static RW_Construction_Stage__c objConstructionStage;
    public static Attachment objAttach;
    public static Attachment objAttach1;
    
    public static testMethod void myTest1()
    {
        LoadData();
        System.runAs(objUser)
        {
            DocumentComponentController.fetchDocuments();
            DocumentComponentController.fetchLedgerDate('P1/P2/P3/P4/P5');
            DocumentComponentController.GoToDocuments();
            DocumentComponentController.FetchAllPortalDocuments();
            DocumentComponentController.UploadAttachments('fileName', 'base64Data', 'PDF', 'P1/P2/P3/P4/P5', 'DocumentName');
            DocumentComponentController.ViewDemandLetterDocs('P1/P2/P3/P4/P5');
            DocumentComponentController.ViewGenMoneyReceipt('P1/P2/P3/P4/P5');
            DocumentComponentController.ViewAllotmentLetterDocs('P1/P2/P3/P4/P5');
            DocumentComponentController.ViewReminderLetterDocs('P1/P2/P3/P4/P5');
            DocumentComponentController.ApplicantLedgerGenerate('P1/P2/P3/P4/P5');
            
            objOpp.RW_Ledger_Valid_To__c = System.now().addDays(1);
            update objOpp;
            
            DocumentComponentController.ApplicantLedgerGenerate('P1/P2/P3/P4/P5');
            DocumentComponentController.fetchTokenNumber();
            DocumentComponentController.viewLatestConstructionStage('');
            DocumentComponentController.viewLatestConstructionStage('P1/P2/P3/P4');
            DocumentComponentController.viewLatestConstructionStage('P1/P2/P3/P4/P5');
        }
        
        delete objAttach1;
        DocumentComponentController.viewLatestConstructionStage('P1/P2/P3/P4/P5');
        
        delete objConstructionStage;
        DocumentComponentController.viewLatestConstructionStage('P1/P2/P3/P4/P5');
    }
    
    public static testMethod void myTest2()
    {
        WrapPortalData objCls = new WrapPortalData();
        objCls.ErrorCode = 1;
        objCls.StatusMessage = 'str';
        //objCls = WrapPortalData.parse('str');
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
        
        
        Profile p = [SELECT Id, UserLicense.Name FROM Profile WHERE Name = 'Community Login User Custm' and UserLicense.Name = 'Customer Community Login']; //
        List<account> lstAccount = [Select Id, IsPersonAccount, PersonContactId from account where id =: objAcc.id];
        
        
        objUser = new User(Alias = 'standt', Email='standardTest@testing.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@testorg.com'
            ,ContactId = lstAccount[0].PersonContactId
            ); 
        insert objUser;
        
        System.debug('objUser::'+objUser.UserRole);
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
        objUnit.RW_Delimeter__c = '/';
        objUnit.RW_Unit_Status__c = 'Available';
        insert objUnit;
        
        objOpp = new Opportunity();
        objOpp.AccountId = objAcc.Id;
        objOpp.Amount = 500;
        objOpp.Name = 'testOppName';
        objOpp.StageName = 'Qualification';
        objOpp.LeadSource = 'Outdoor';
        //objOpp.CloseDate = Date.today();
        objOpp.RW_Project__c = objProject.Id;
        objOpp.RW_Project_Unit__c = objUnit.Id;
        objOpp.RW_Applicant_Ledger_Generated__c = true;
        objOpp.RW_Ledger_Valid_To__c = System.now();
        insert objOpp;
        
        objAttach = new Attachment();
        objAttach.Body = Blob.valueOf('o');
        objAttach.Name = 'test.pdf';
        objAttach.Description = 'Portal Upload : asasa';
        objAttach.ParentId = objAcc.Id;
        insert objAttach;
        
        Farvision_API_Settings__c objFar = new Farvision_API_Settings__c();
        objFar.Name = 'test';
        objFar.FV_SecurityKey__c = 'str';
        objFar.FV_UserID__c = objUser.Username;
        objFar.FV_Password__c = 'strPass';
        objFar.FV_Authenticate_User__c = 'www.google.com';
        objFar.Timeout__c = 5.5;
        insert objFar;
        
        objConstructionStage = new RW_Construction_Stage__c();
        objConstructionStage.Name = 'testName';
        objConstructionStage.RW_Project__c = objProject.Id;
        objConstructionStage.RW_Sequence_No__c = 5.5;
        insert objConstructionStage;
        
        objAttach1 = new Attachment();
        objAttach1.Body = Blob.valueOf('o');
        objAttach1.Name = 'testName';
        objAttach1.Description = 'testDescription';
        objAttach1.ParentId = objConstructionStage.Id;
        insert objAttach1;
        
        RW_Portal_Endpoint_URL__c objPortalUrl1 = new RW_Portal_Endpoint_URL__c();
        objPortalUrl1.Name = 'DemandLetter';
        objPortalUrl1.RW_URL__c = 'www.google.com';
        insert objPortalUrl1;
        
        RW_Portal_Endpoint_URL__c objPortalUrl2 = new RW_Portal_Endpoint_URL__c();
        objPortalUrl2.Name = 'MoneyReceipt';
        objPortalUrl2.RW_URL__c = 'www.google.com';
        insert objPortalUrl2;
        
        RW_Portal_Endpoint_URL__c objPortalUrl3 = new RW_Portal_Endpoint_URL__c();
        objPortalUrl3.Name = 'AllotmentLetter';
        objPortalUrl3.RW_URL__c = 'www.google.com';
        insert objPortalUrl3;
        
        RW_Portal_Endpoint_URL__c objPortalUrl4 = new RW_Portal_Endpoint_URL__c();
        objPortalUrl4.Name = 'ReminderLetter';
        objPortalUrl4.RW_URL__c = 'www.google.com';
        insert objPortalUrl4;
        
        RW_Portal_Endpoint_URL__c objPortalUrl5 = new RW_Portal_Endpoint_URL__c();
        objPortalUrl5.Name = 'ApplicantLedger';
        objPortalUrl5.RW_URL__c = 'www.google.com';
        insert objPortalUrl5;
    }
     
}