@isTest
public class LockatedApp_LoyaltyEngineTest {
    
    
    @isTest
    public static void loyaltyEngineTest1(){
        
        Segment__c seg = new Segment__c();
        seg.Name = 'Test Segment';
        seg.Segment_Type__c = 'Premium';
        insert seg;
        
        Project__c proj = new Project__c();
        proj.Name = 'Runwal Bliss';
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
        opp1.SAP_Customer_Number__c = '0020025458';
        opp1.RW_Project__c = proj.Id;
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
        
        RW_Payment_Details__c rec = new RW_Payment_Details__c();
        rec.RW_Booking__c = bkg.Id;
        insert rec;
        
        
        Applicant_Details__c app = new Applicant_Details__c();
        app.First_Name__c = 'Test';
        app.Last_Name__c = 'Applicant';
        app.Booking__c = bkg.Id;
        app.Opportunity__c = opp1.Id;
        app.Email_Address__c = 'test@mail.com';
        app.Mobile_Number__c = '2314578965';
        app.Applicant_Number__c = 'Primary Applicant';
        app.PancardNo__c = 'DERGR5445G';
        app.Permanent_Address_Line_1__c = 'Test1';
        app.DOB__c = Date.today();
        app.Country__c = 'India';
        insert app;

        RW_Demand__c dem = new RW_Demand__c(RW_Demand_Status__c = 'Due',Due_Date__c = Date.today() + 10, Booking__c = bkg.Id);
        insert dem;

        RW_Demand_Item__c demItem =  new RW_Demand_Item__c(RW_Demand__c = dem.Id,RW_Demand_Item_Amount__c=1000);
        insert demItem;
        
        bkg.Status__c = 'Booking Confirmed';
        bkg.RW_Registration_Date__c = Date.today();
        bkg.RW_Booking_Confirmed_Date__c = Date.today();
        update bkg;
        
        
        
        dem.RW_Demand_Status__c = 'Paid';
        update dem;
        
        Lead ld = new Lead();
        ld.LastName = 'Test Lead';
        ld.LeadSource = 'Referral';
        ld.Customer_Reference__c = acc.Id;
        ld.RW_Mobile_No__c = '1234567890';
        insert ld;
        
        
        
        Test.setMock(HttpCalloutMock.class, new CalloutMockClass());
        LockatedApp_LoyaltyEngine.birthdayPoints();
        LockatedApp_LoyaltyEngine.earlyPayment(new List<RW_Demand__c>{dem});
        
        LockatedApp_LoyaltyMemberCreation.createLoyaltyMember(new List<Id>{bkg.Id});
        LockatedApp_LoyaltyEngine.appEnrollment(new List<Id>{bkg.Id});
        LockatedApp_LoyaltyEngine.referralFreshLeads(new List<Id>{ld.Id});
        LockatedApp_LoyaltyEngine.referralSiteVisits(new List<Opportunity>{opp3});
        //List<Referral_Points__c> refPoint = [SELECT Id FROM Referral_Points__c];
        //LockatedApp_LoyaltyMemberCreation.creditWallet(new List<Id>{refPoint[0].Id});
    }
    
    @isTest
    public static void loyaltyEngineTest2(){
        
        Segment__c seg = new Segment__c();
        seg.Name = 'Test Segment';
        seg.Segment_Type__c = 'Premium';
        insert seg;
        
        Project__c proj = new Project__c();
        proj.Name = 'Runwal Bliss';
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
        opp1.SAP_Customer_Number__c = '0020025458';
        opp1.RW_Project__c = proj.Id;
        oppList.add(opp1);
        
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'Test Opp 2';
        opp2.AccountId = acc.Id;
        opp2.News_Letter_Date__c = Date.today();
        opp2.CloseDate = Date.today() + 10;
        opp2.StageName = 'Unit Booked';
        //opp2.Customer_Reference__c = acc.Id;
        oppList.add(opp2);
        
        Opportunity opp3 = new Opportunity();
        opp3.Name = 'Test Opp 3';
        opp3.AccountId = acc.Id;
        opp3.News_Letter_Date__c = Date.today();
        opp3.CloseDate = Date.today() + 10;
        opp3.StageName = 'Site Visit';
        //opp3.Customer_Reference__c = acc.Id;
        opp3.LeadSource = 'Referral';
        oppList.add(opp3);
        insert oppList;
        
        
        
        Lead ld = new Lead();
        ld.LastName = 'Test Lead';
        ld.LeadSource = 'Referral';
        ld.Customer_Reference__c = acc.Id;
        ld.RW_Mobile_No__c = '1234567890';
        insert ld;
        
                
        Test.setMock(HttpCalloutMock.class, new CalloutMockClass());
        LockatedApp_LoyaltyEngine.referralFreshLeads(new List<Id>{ld.Id});
        List<Referral_Points__c> refPoint = [SELECT Id FROM Referral_Points__c];
        LockatedApp_LoyaltyMemberCreation.creditWallet(new List<Id>{refPoint[0].Id});
    }

    @isTest
    public static void loyaltyEngineTest3(){
        
        Segment__c seg = new Segment__c();
        seg.Name = 'Test Segment';
        seg.Segment_Type__c = 'Premium';
        insert seg;
        
        Project__c proj = new Project__c();
        proj.Name = 'Runwal Bliss';
        proj.Segment_Lookup__c = seg.Id;
        insert proj;

        List<Account> accList = new List<Account>();
        Account acc1 = new Account();
        acc1.Name = 'Test Account';
        accList.add(acc1);

        Account acc2 = new Account();
        acc2.Name = 'Test Account';
        accList.add(acc2);
        insert accList;
        
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'Test Opp 1';
        opp1.AccountId = acc1.Id;
        opp1.News_Letter_Date__c = Date.today();
        opp1.CloseDate = Date.today() + 10;
        opp1.StageName = 'Unit Booked';
        opp1.SAP_Customer_Number__c = '0020025458';
        opp1.RW_Project__c = proj.Id;
        oppList.add(opp1);
        
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'Test Opp 2';
        opp2.AccountId = acc1.Id;
        opp2.News_Letter_Date__c = Date.today();
        opp2.CloseDate = Date.today() + 10;
        opp2.StageName = 'Unit Booked';
        opp2.Customer_Reference__c = acc1.Id;
        oppList.add(opp2);
        
        Opportunity opp3 = new Opportunity();
        opp3.Name = 'Test Opp 3';
        opp3.AccountId = acc1.Id;
        opp3.News_Letter_Date__c = Date.today();
        opp3.CloseDate = Date.today() + 10;
        opp3.StageName = 'Site Visit';
        //opp3.Customer_Reference__c = acc.Id;
        opp3.LeadSource = 'Referral';
        oppList.add(opp3);
        insert oppList;
        
        
        Lead ld = new Lead();
        ld.LastName = 'Test Lead';
        ld.LeadSource = 'Referral';
        ld.Customer_Reference__c = acc1.Id;
        ld.RW_Mobile_No__c = '1234567890';
        insert ld;
        
        
        
        Test.setMock(HttpCalloutMock.class, new CalloutMockClass());
        LockatedApp_LoyaltyEngine.referralFreshLeads(new List<Id>{ld.Id});     
    }   

}