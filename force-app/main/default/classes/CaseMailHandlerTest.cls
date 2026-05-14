@isTest
public class CaseMailHandlerTest {
    
    
    
    @isTest
    static void testCaseCategorizationMail() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        User testUser = new User(
            Alias = 'testuser', 
            Email = 'newcase@gmail.com', 
            EmailEncodingKey = 'UTF-8', 
            LastName = 'User', 
            LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', 
            ProfileId = p.Id, FirstName='test',
            TimeZoneSidKey = 'America/Los_Angeles', 
            UserName = 'newcase@gmail.com'
        );
        insert testUser;
        
        RecordType feedbackRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND Name = 'Customer Feedback' LIMIT 1];
        RecordType visitFeedbackRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND Name = 'Visit Feedback' LIMIT 1];
        
        Case testCase1 = new Case(
            SuppliedEmail = 'test2@example.com',
            RW_Reporting_2_Email__c = 'test3@example.com',
            Description = 'Test Case 1',
            Subject = 'Test Subject 1',
            Status = 'Open',            RW_Case_Type__c='Complaint',
           /// RW_Complaint_Type__c='Legal Related',RW_Complaint_SubType__c='approvals related',
            AccountId = testAccount.Id,
            OwnerId = testUser.Id,
            RecordTypeId = feedbackRecordType.Id
        );
        
        Case testCase2 = new Case(
            SuppliedEmail = 'test5@example.com',
            RW_Reporting_2_Email__c = 'test6@example.com',
            Description = 'Test Case 2',
            Subject = 'Test Subject 2',
            Status = 'Open',            RW_Case_Type__c='Complaint',
            //RW_Complaint_Type__c='Legal Related',RW_Complaint_SubType__c='approvals related',
            AccountId = testAccount.Id,
            OwnerId = testUser.Id,
            RecordTypeId = visitFeedbackRecordType.Id
        );
        
        insert testCase1;
        insert testCase2;
        Set<Id> caseIds = new Set<Id>();
        caseIds.add([SELECT Id FROM Case WHERE   SuppliedEmail = 'test2@example.com' LIMIT 1].Id);
        
        Test.startTest();
        CaseMailHandler.CaseCategorizationMail(caseIds);
        Test.stopTest();
        
        
    }
    
    @isTest
    static void testCaseClosureEmailCustomer() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        User testUser = new User(
            Alias = 'testuser', 
            Email = 'newcase@gmail.com', 
            EmailEncodingKey = 'UTF-8', 
            LastName = 'User', 
            LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', 
            ProfileId = p.Id, FirstName='test',
            TimeZoneSidKey = 'America/Los_Angeles', 
            UserName = 'newcase@gmail.com'
        );
        insert testUser;        
        RecordType feedbackRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND Name = 'Customer Feedback' LIMIT 1];
        RecordType visitFeedbackRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND Name = 'Visit Feedback' LIMIT 1];
        
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account a = new Account();
        a.RecordTypeID=recordTypeId ;
        a.FirstName ='TestAccount1';
        a.LastName ='TestAccount2';
        a.PersonEmail = 'wc@email.com';
        a.City__c='TestCity';
        a.RW_Zip_Code__c = '999999';
        a.State__c ='Karnataka';
        a.Country__c ='India';
        a.Mobile_No__c = '1236547896';
        a.Alternate_Email__c = 'wc1@email.com';
        a.Gender__c='Male';
        a.Salutation = 'Mr.';
        a.Birth_Date__c = System.today().addYears(-20);   
        insert a;
        
        Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.SAPMaterial_Code__c = '1211';
        objpr.RW_Project_Location_Videos_Link__c='test';
        objpr.RW_Project_Brochure_PublicUrl__c='test1';
        objpr.RW_SAP_Company_Code__c='5245';
        objpr.WhatsApp_Bot_Project_Image_File_Id__c = System.label.Possession_Guidelines_Doc_Id;
        insert objpr;
        
        Tower__c t = UniversalTestClassSetup.setuptower(objpr.Id,'A','Residential');
        
        Project_Unit__c objPU1 = new Project_Unit__c();    
        objPU1.Name = 'TestFive';     
        objPU1.Unit_SAP_Code__c ='1R000333';
        objPU1.RW_Project__c = objpr.Id;
        objPU1.RW_Param1__c = '5';
        objPU1.UnitNo__c ='TestFive';
        objPU1.RW_Unit_status__c='Available';
        objPU1.RW_Booking_Date__c = system.Today();
        objPU1.Actual_Area_value__c = 2218;
        objPU1.New_Floor__c = '8';
        objPU1.RW_Param4__c ='A-4546';
        objPU1.TowerName__c = t.Id;
        objPU1.Carpet_Area__c = 10;
        objPU1.Saleable_Area__c=2218;
        objPU1.Single_car_park_Earmarked__c = 0;
        objPU1.Single_Open_Earmarked__c = 0;
        objPU1.Tandem_Open_Earmarked__c = 0;
        objPU1.Tandem_car_park_Earmarked__c = 0;
        objPU1.Tandem_Open_Earmarked__c = 0;
        objPU1.MLCP_Earmarked__c = 0;
        objPU1.Stack__c = 0;
        insert objPU1;
        
        Opportunity oppRec= new Opportunity();
        oppRec.RW_Project__c=objpr.id;
        oppRec.Name='Test 1';
        oppRec.RW_Email__c=a.PersonEmail;
        oppRec.StageName='Unit Booked';
        oppRec.CloseDate=system.today();
        oppRec.Status__c ='Active';
        oppRec.AccountId = a.Id;
        oppRec.Sales_Manager__c = 'SM2@g.com';
        oppRec.Sourcing_Manager__c='Aniket Sapre';
        oppRec.RW_Sourcing_Head__c='Adrian Dsouza';
        oppRec.RW_Sales_Associate__c='Karthik Chettiar';
        oppRec.Sales_Manager_User__c= UserInfo.getUserId(); //Added by Vinay 09-12-2025
        oppRec.RW_Closing_Head__c='Karthik Chettiar';
        oppRec.Walkin_Source__c='Direct';
        oppRec.SAP_Customer_Number__c='0020006618';
        oppRec.SalesOrder_Number__c='3010005457';
        oppRec.RW_Mobile_No__c = '1234567890';
        oppRec.Sales_Manager_User__c = UserInfo.getUserId();
        insert oppRec;
        
        Booking__c objBking = new Booking__c();
        objBking.Customer__c = oppRec.Id;
        objBking.Project__c = objpr.Id;
        objBking.Opportunity__c = oppRec.Id;
        objBking.Unit_No__c = objPU1.id;
        objBking.Booking_Date__c = Date.today();
        objBking.Status__c ='Booking Confirmed';
        objBking.RW_Total_Receipt_Amount_Received__c = 1000;
        objBking.RW_Total_Receipt_Discount_Recieved__c = 0;
        objBking.Primary_Applicant_Email__c = 'test@mail.com';
        objBking.RW_Signed_Agreement_Document_Id__c = System.label.Possession_Guidelines_Doc_Id;
        insert objBking;
        
        oppRec.Booking__c = objBking.Id;
        update oppRec;
        
        
        Case testCase1 = new Case(
            SuppliedEmail = 'test2@example.com',
            RW_Reporting_2_Email__c = 'test3@example.com',
            Description = 'Test Case 1',
            Subject = 'Test Subject 1',
            Status = 'Open',            RW_Case_Type__c='Complaint',
            //RW_Complaint_Type__c='Legal Related',RW_Complaint_SubType__c='approvals related',
            AccountId = testAccount.Id,
            OwnerId = testUser.Id,
            RecordTypeId = feedbackRecordType.Id
        );
        
        Case testCase2 = new Case(
            SuppliedEmail = 'test5@example.com',
            RW_Reporting_2_Email__c = 'test6@example.com',
            Description = 'Test Case 2',
            Subject = 'Test Subject 2',
            Status = 'Open',            RW_Case_Type__c='Complaint',
           // RW_Complaint_Type__c='Legal Related',RW_Complaint_SubType__c='approvals related',
            AccountId = testAccount.Id,
            OwnerId = testUser.Id,
            RecordTypeId = visitFeedbackRecordType.Id
        );
        
        Case testCase3 = new Case(
            SuppliedEmail = 'test6@example.com',
            RW_Reporting_2_Email__c = 'test6@example.com',
            Description = 'Test Case 2',
            Subject = 'Test Subject 2',
            Status = 'Open',            RW_Case_Type__c='Complaint',
           // RW_Complaint_Type__c='Legal Related',RW_Complaint_SubType__c='approvals related',
            AccountId = a.Id,
            OwnerId = testUser.Id,
            RecordTypeId = visitFeedbackRecordType.Id,
            Opportunity__c = oppRec.Id
        );
        List<Case> caseList = new List<Case>();
        //insert testCase3;
        //insert testCase1;
        //insert testCase2;
        caseList.add(testCase1);
        caseList.add(testCase2);
        caseList.add(testCase3);
        insert caseList;
        Set<Id> caseIds = new Set<Id>();
        caseIds.add([SELECT Id FROM Case WHERE  SuppliedEmail = 'test2@example.com' LIMIT 1].Id);
        caseIds.add([SELECT Id FROM Case WHERE   SuppliedEmail = 'test5@example.com' LIMIT 1].Id);
        caseIds.add([SELECT Id FROM Case WHERE   SuppliedEmail = 'test6@example.com' LIMIT 1].Id);
        System.debug('caseIds: ' + caseIds);
        
        Test.startTest();
        CaseMailHandler.CaseClosureEmailCustomer(caseIds);
        Test.stopTest();
        
        
    }
    
    @isTest
    static void testCaseIsReopened() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
         
        User testUser1 = new User(
            Alias = 'newuser', 
            Email = 'newcase12344@gmail.com', 
            EmailEncodingKey = 'UTF-8', 
            LastName = 'User1111', 
            LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', 
            ProfileId = p.Id, FirstName='test',
            TimeZoneSidKey = 'America/Los_Angeles', 
            UserName = 'newcase12344@gmail.com'
        );
        insert testUser1;
        User testUser = new User(
            Alias = 'testuser', 
            Email = 'newcase@gmail.com', 
            EmailEncodingKey = 'UTF-8', 
            LastName = 'User', 
            LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', 
            ProfileId = p.Id, FirstName='test',
            TimeZoneSidKey = 'America/Los_Angeles', 
            UserName = 'newcase@gmail.com',
            Manager=testUser1
        );
        insert testUser; 
        RecordType feedbackRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND Name = 'Customer Feedback' LIMIT 1];
        RecordType visitFeedbackRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND Name = 'Visit Feedback' LIMIT 1];
        
        Case testCase1 = new Case(
            SuppliedEmail = 'test2@example.com',
            RW_Reporting_2_Email__c = 'test3@example.com',
            Description = 'Test Case 1',
            Subject = 'Test Subject 1',
            Status = 'Open',            RW_Case_Type__c='Complaint',
            //RW_Complaint_Type__c='Legal Related',RW_Complaint_SubType__c='approvals related',
            AccountId = testAccount.Id,
            OwnerId = testUser.Id,
            RecordTypeId = feedbackRecordType.Id
        );
        
        Case testCase2 = new Case(
            SuppliedEmail = 'test5@example.com',
            RW_Reporting_2_Email__c = 'test6@example.com',
            Description = 'Test Case 2',
            Subject = 'Test Subject 2',
            Status = 'Open',             RW_Case_Type__c='Complaint',
           // RW_Complaint_Type__c='Legal Related',RW_Complaint_SubType__c='approvals related',
            AccountId = testAccount.Id,
            OwnerId = testUser.Id,
            RecordTypeId = visitFeedbackRecordType.Id
        );
        
        insert testCase1;
        insert testCase2;
        Set<Id> caseIds = new Set<Id>();
        caseIds.add([SELECT Id FROM Case WHERE SuppliedEmail = 'test2@example.com' LIMIT 1].Id);
        
        Test.startTest();
        CaseMailHandler.CaseIsReopened(caseIds);
        Test.stopTest();
        
        
    }
    
    @isTest
    static void testUpdateL3() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        User testUser = new User(
            Alias = 'testuser', 
            Email = 'newcase@gmail.com', 
            EmailEncodingKey = 'UTF-8', 
            LastName = 'User', 
            LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', 
            ProfileId = p.Id, FirstName='test',
            TimeZoneSidKey = 'America/Los_Angeles', 
            UserName = 'newcase@gmail.com'
        );
        insert testUser;        
        RecordType feedbackRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND Name = 'Customer Feedback' LIMIT 1];
        RecordType visitFeedbackRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND Name = 'Visit Feedback' LIMIT 1];
        
        Case testCase1 = new Case(
            SuppliedEmail = 'test2@example.com',
            RW_Reporting_2_Email__c = 'test3@example.com',
            Description = 'Test Case 1',
            Subject = 'Test Subject 1',
            Status = 'Open',            RW_Case_Type__c='Complaint',
            //RW_Complaint_Type__c='Legal Related',RW_Complaint_SubType__c='approvals related',
            AccountId = testAccount.Id,
            OwnerId = testUser.Id,
            RecordTypeId = feedbackRecordType.Id
        );
        
        Case testCase2 = new Case(
            SuppliedEmail = 'test5@example.com',
            RW_Reporting_2_Email__c = 'test6@example.com',
            Description = 'Test Case 2',
            Subject = 'Test Subject 2',
            Status = 'Open',            RW_Case_Type__c='Complaint',
            //RW_Complaint_Type__c='Legal Related',RW_Complaint_SubType__c='approvals related',
            AccountId = testAccount.Id,
            OwnerId = testUser.Id,
            RecordTypeId = visitFeedbackRecordType.Id
        );
        
        insert testCase1;
        insert testCase2;
        Set<Id> caseIds = new Set<Id>();
        caseIds.add([SELECT Id FROM Case WHERE   SuppliedEmail = 'test5@example.com' LIMIT 1].Id);
        
        Test.startTest();
        CaseMailHandler.UpdateL3(caseIds);
        Test.stopTest();
        
        Case updatedCase = [SELECT Current_Stage__c FROM Case WHERE SuppliedEmail = 'test2@example.com' LIMIT 1];
        
    }
}