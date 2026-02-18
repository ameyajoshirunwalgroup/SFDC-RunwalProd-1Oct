@isTest
public class LockatedApp_LoyaltyEngineTest {
    
    
    @isTest
    public static void birthdayNotificationTest(){
        
        Segment__c seg = new Segment__c();
        seg.Name = 'Test Segment';
        seg.Segment_Type__c = 'Premium';
        insert seg;
        
        Project__c proj = new Project__c();
        proj.Name = 'Test Project';
        proj.Segment_Lookup__c = seg.Id;
        insert proj;
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'Test Opp 1';
        opp1.AccountId = acc.Id;
        opp1.News_Letter_Date__c = Date.today();
        opp1.CloseDate = Date.today() + 10;
        opp1.StageName = 'Unit Booked';
        oppList.add(opp1);
        
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'Test Opp 2';
        opp2.AccountId = acc.Id;
        opp2.News_Letter_Date__c = Date.today();
        opp2.CloseDate = Date.today() + 10;
        opp2.StageName = 'Unit Booked';
        opp2.Customer_Reference__c = acc.Id;
        oppList.add(opp2);
        
        Opportunity opp3 = new Opportunity();
        opp3.Name = 'Test Opp 3';
        opp3.AccountId = acc.Id;
        opp3.News_Letter_Date__c = Date.today();
        opp3.CloseDate = Date.today() + 10;
        opp3.StageName = 'Site Visit';
        opp3.Customer_Reference__c = acc.Id;
        opp3.LeadSource = 'Referral';
        oppList.add(opp3);
        insert oppList;
        
        Booking__c bkg =  new Booking__c();
        bkg.Opportunity__c = opp1.Id;
        bkg.Customer__c = opp1.Id;
        bkg.Project__c = proj.Id;
        insert bkg;
        
        Applicant_Details__c app = new Applicant_Details__c();
        app.Opportunity__c = opp1.Id;
        app.Booking__c = bkg.Id;
        app.DOB__c = Date.today();
        app.Applicant_Number__c = 'Primary Applicant';
        insert app;
        
        Lead ld = new Lead();
        ld.LastName = 'Test Lead';
        ld.LeadSource = 'Referral';
        ld.Customer_Reference__c = acc.Id;
        ld.RW_Mobile_No__c = '1234567890';
        insert ld;
        
        LockatedApp_LoyaltyEngine.birthdayPoints();
        
    }
    
   

}