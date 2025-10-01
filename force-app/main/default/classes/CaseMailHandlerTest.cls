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
        
        insert testCase1;
        insert testCase2;
        Set<Id> caseIds = new Set<Id>();
        caseIds.add([SELECT Id FROM Case WHERE  SuppliedEmail = 'test2@example.com' LIMIT 1].Id);
        caseIds.add([SELECT Id FROM Case WHERE   SuppliedEmail = 'test5@example.com' LIMIT 1].Id);
        
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