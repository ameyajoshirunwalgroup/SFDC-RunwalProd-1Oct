@isTest
public class GenerateOtpControllerforLeadLWCTest {
    
    @isTest
    static void testGenerateOtpWithValidLead() {
        
        Project__c projectRec = new Project__c(Name = 'Test Project');
insert projectRec;
        // Create Lead with required fields
        Lead testLead = new Lead(
            LastName = 'Test Lead',
            Company = 'Test Company',
            RW_Mobile_No__c='848484848',
            Status = 'VCVP',
            RW_Project__c = projectRec.Id,
            LeadSource = 'Web',
            RW_Sourcing_Manager__c = UserInfo.getUserId()
        );
        insert testLead;
        
        Test.startTest();
        String otpResult = GenerateOtpControllerforLeadLWC.generateOtp(testLead.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testGenerateOtpWithExistingOtp() {
        
        Project__c projectRec = new Project__c(Name = 'Test Project');
insert projectRec;
        // Create Lead
        Lead testLead = new Lead(
            LastName = 'Existing OTP Lead',
            RW_Mobile_No__c='848484848',
            Company = 'Test Company',
            Status = 'VCVP',
            RW_Project__c =projectRec.Id,
            LeadSource = 'Web'
        );
        insert testLead;

        // Create Existing OTP
        OTP__c existingOtp = new OTP__c(
            Lead__c = testLead.Id,
            Generated_OTP__c = '12345',
            //OTP_Expired__c = false,
            Project__c = testLead.RW_Project__c
        );
        insert existingOtp;
        
        Test.startTest();
        String otpResult = GenerateOtpControllerforLeadLWC.generateOtp(testLead.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testGenerateOtpWithReferral() {
         Project__c projectRec = new Project__c(Name = 'Test Project');
insert projectRec;
        // Create Referral Account
        Account referralAccount = new Account(
            LastName = 'Referral Account'
        );
        insert referralAccount;
        
        // Create Booked Opportunity
        Opportunity bookedOpp = new Opportunity(
            Name = 'Booked Unit',
            StageName = 'Unit Booked',
            CloseDate = System.today(),
            AccountId = referralAccount.Id,
            SAP_Customer_Number__c = 'SAP123'
        );
        insert bookedOpp;
         Project__c projectRec1 = new Project__c(Name = 'Test Project');
        insert projectRec1;
        // Create Lead
        Lead referralLead = new Lead(
            LastName = 'Referral Lead',
            Company = 'Test Company',
            RW_Mobile_No__c= '848484848',
            Status = 'VCVP',
            RW_Project__c =projectRec1.Id,
            LeadSource = 'Referral',
            Lead_Sub_Source__c = 'Friend',
            RW_Lead_Sub_Source__c = 'Existing client reference',
            Customer_Reference__c = referralAccount.Id
        );
        insert referralLead;
        
        Test.startTest();
        String otpResult = GenerateOtpControllerforLeadLWC.generateOtp(referralLead.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testGenerateOtpForInactiveLead() {
         Project__c projectRec = new Project__c(Name = 'Test Project');
insert projectRec;
        // Lead with wrong status
        Lead inactiveLead = new Lead(
            LastName = 'Inactive Lead',
            Company = 'Test Company',
            Status = 'Open',
            RW_Project__c =projectRec.Id
        );
        insert inactiveLead;
        
        Test.startTest();
        String otpResult = GenerateOtpControllerforLeadLWC.generateOtp(inactiveLead.Id);
        Test.stopTest();
    }

    @isTest
    static void testGenerateOtpWithoutProject() {
        // Lead without Project
        Lead leadWithoutProject = new Lead(
            LastName = 'Lead No Project',
            Company = 'Test Company',
            Status = 'VCVP'
        );
        insert leadWithoutProject;
        
        Test.startTest();
        String otpResult = GenerateOtpControllerforLeadLWC.generateOtp(leadWithoutProject.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testGetActiveOtpForLead() {
         Project__c projectRec = new Project__c(Name = 'Test Project');
insert projectRec;
        Lead testLead = new Lead(
            LastName = 'Active OTP Lead',
            Company = 'Test Company',
            Status = 'VCVP',
            RW_Project__c = projectRec.Id
        );
        insert testLead;
        
        OTP__c otp = new OTP__c(
            Lead__c = testLead.Id,
            Generated_OTP__c = '67890'
           // OTP_Expired__c = false
        );
        insert otp;
        
        Test.startTest();
        Otp__c tiveOtp = GenerateOtpControllerforLeadLWC.getActiveOtpForLead(testLead.Id);
        Test.stopTest();
    }
}