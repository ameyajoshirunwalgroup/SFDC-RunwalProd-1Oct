@isTest
public class ReferralLeadCreationTest {
    
    @isTest
    public static void noLeadTest(){
        
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        RW_Referral__c ref = new RW_Referral__c();
        ref.RW_First_Name__c ='Test';
        ref.RW_Last_Name__c='Lead';
        ref.RW_Email_Address__c='Test@test.com';
        ref.RW_Project__c= 'Runwal Bliss';
        ref.RW_Contact_Phone__c = '1221122100';
        ref.RW_Status__c = 'In Process';
        ref.RW_LeadCreated__c = false;
        ref.RW_Duplicate_Lead__c = false;
        ref.Account__c = acc.Id;
        insert ref;
        
        
        Project__c prj = new Project__c();
        prj.Name = 'Runwal Bliss';
        prj.Loyalty_Head__c = UserInfo.getUserId();
        insert prj;
        
        
        Test.startTest();
        ReferralLeadCreation rlc = new ReferralLeadCreation(new List<String>{ref.Id});
        Database.executeBatch(rlc);
        Test.stopTest();
    }
    
     @isTest
    public static void leadWithSameProj(){
        
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        RW_Referral__c ref = new RW_Referral__c();
        ref.RW_First_Name__c ='Test';
        ref.RW_Last_Name__c='Lead';
        ref.RW_Email_Address__c='Test@test.com';
        ref.RW_Project__c= 'Runwal Bliss';
        ref.RW_Contact_Phone__c = '1221122100';
        ref.RW_Status__c = 'In Process';
        ref.RW_LeadCreated__c = false;
        ref.RW_Duplicate_Lead__c = false;
        ref.Account__c = acc.Id;
        insert ref;
        
        Project__c prj = new Project__c();
        prj.Name = 'Runwal Bliss';
        prj.Loyalty_Head__c = UserInfo.getUserId();
        insert prj;

		Lead ld = new Lead();
		ld.LastName = 'Test';
		ld.RW_Mobile_No__c = '1221122100';
        ld.RW_Project__c = prj.Id;
        insert ld;
        
        Test.startTest();
        ReferralLeadCreation rlc = new ReferralLeadCreation(new List<String>{ref.Id});
        Database.executeBatch(rlc);
        Test.stopTest();
    }
    
    @isTest
    public static void leadWithDiffProjProsWithSameProj(){
        
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        RW_Referral__c ref = new RW_Referral__c();
        ref.RW_First_Name__c ='Test';
        ref.RW_Last_Name__c='Lead';
        ref.RW_Email_Address__c='Test@test.com';
        ref.RW_Project__c= 'Runwal Gardens';
        ref.RW_Contact_Phone__c = '1221122100';
        ref.RW_Status__c = 'In Process';
        ref.RW_LeadCreated__c = false;
        ref.RW_Duplicate_Lead__c = false;
        ref.Account__c = acc.Id;
        insert ref;
        
        Project__c prj = new Project__c();
        prj.Name = 'Runwal Bliss';
        prj.Loyalty_Head__c = UserInfo.getUserId();
        insert prj;
        
        Project__c prj2 = new Project__c();
        prj2.Name = 'Runwal Gardens';
        prj2.Loyalty_Head__c = UserInfo.getUserId();
        insert prj2;

		Lead ld = new Lead();
		ld.LastName = 'Test';
		ld.RW_Mobile_No__c = '1221122100';
        ld.RW_Project__c = prj.Id;
        insert ld;
        
        Prospect__c pros = new Prospect__c();
        pros.Lead__c = ld.Id;
        pros.Project__c = prj2.Id;
        insert pros;
        
        Test.startTest();
        ReferralLeadCreation rlc = new ReferralLeadCreation(new List<String>{ref.Id});
        Database.executeBatch(rlc);
        Test.stopTest();
    }
    
    @isTest
    public static void leadWithDiffProjProsWithDiffProj(){
        
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        RW_Referral__c ref = new RW_Referral__c();
        ref.RW_First_Name__c ='Test';
        ref.RW_Last_Name__c='Lead';
        ref.RW_Email_Address__c='Test@test.com';
        ref.RW_Project__c= 'Runwal Gardens';
        ref.RW_Contact_Phone__c = '1221122100';
        ref.RW_Status__c = 'In Process';
        ref.RW_LeadCreated__c = false;
        ref.RW_Duplicate_Lead__c = false;
        ref.Account__c = acc.Id;
        insert ref;
        
        Project__c prj = new Project__c();
        prj.Name = 'Runwal Bliss';
        prj.Loyalty_Head__c = UserInfo.getUserId();
        insert prj;
        
        Project__c prj2 = new Project__c();
        prj2.Name = 'Runwal Gardens';
        prj2.Loyalty_Head__c = UserInfo.getUserId();
        insert prj2;

		Lead ld = new Lead();
		ld.LastName = 'Test';
		ld.RW_Mobile_No__c = '1221122100';
        ld.RW_Project__c = prj.Id;
        insert ld;
        
        Prospect__c pros = new Prospect__c();
        pros.Project__c = prj.Id;
        pros.Lead__c = ld.Id;
        insert pros;
        
        Test.startTest();
        ReferralLeadCreation rlc = new ReferralLeadCreation(new List<String>{ref.Id});
        Database.executeBatch(rlc);
        Test.stopTest();
    }
    
    @isTest
    public static void leadWithDiffProjWithNoProsp(){
        
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        RW_Referral__c ref = new RW_Referral__c();
        ref.RW_First_Name__c ='Test';
        ref.RW_Last_Name__c='Lead';
        ref.RW_Email_Address__c='Test@test.com';
        ref.RW_Project__c= 'Runwal Gardens';
        ref.RW_Contact_Phone__c = '1221122100';
        ref.RW_Status__c = 'In Process';
        ref.RW_LeadCreated__c = false;
        ref.RW_Duplicate_Lead__c = false;
        ref.Account__c = acc.Id;
        insert ref;
        
        Project__c prj = new Project__c();
        prj.Name = 'Runwal Bliss';
        prj.Loyalty_Head__c = UserInfo.getUserId();
        insert prj;
        
        Project__c prj2 = new Project__c();
        prj2.Name = 'Runwal Gardens';
        prj2.Loyalty_Head__c = UserInfo.getUserId();
        insert prj2;

		Lead ld = new Lead();
		ld.LastName = 'Test';
		ld.RW_Mobile_No__c = '1221122100';
        ld.RW_Project__c = prj.Id;
        insert ld;
        
        
        Test.startTest();
        ReferralLeadCreation rlc = new ReferralLeadCreation(new List<String>{ref.Id});
        Database.executeBatch(rlc);
        Test.stopTest();
    }
    
    @isTest
    public static void withOppTest(){
        
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        RW_Referral__c ref = new RW_Referral__c();
        ref.RW_First_Name__c ='Test';
        ref.RW_Last_Name__c='Lead';
        ref.RW_Email_Address__c='Test@test.com';
        ref.RW_Project__c= 'Runwal Bliss';
        ref.RW_Contact_Phone__c = '1221122100';
        ref.RW_Status__c = 'In Process';
        ref.RW_LeadCreated__c = false;
        ref.RW_Duplicate_Lead__c = false;
        ref.Account__c = acc.Id;
        insert ref;
        
        
        Project__c prj = new Project__c();
        prj.Name = 'Runwal Bliss';
        prj.Loyalty_Head__c = UserInfo.getUserId();
        insert prj;
        
        Opportunity opp = new Opportunity();
        opp.StageName = 'Qualification';
        opp.CloseDate = Date.today() + 10;
        opp.Name = 'Test';
        opp.RW_Project__c = prj.Id;
        opp.RW_Mobile_No__c = '1221122100';
        opp.RW_Email__c = 'test@mail.com';
        insert opp;
        
        
        Test.startTest();
        ReferralLeadCreation rlc = new ReferralLeadCreation(new List<String>{ref.Id});
        Database.executeBatch(rlc);
        Test.stopTest();
    }
    
    @isTest
    public static void withBookedOppTest(){
        
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        RW_Referral__c ref = new RW_Referral__c();
        ref.RW_First_Name__c ='Test';
        ref.RW_Last_Name__c='Lead';
        ref.RW_Email_Address__c='Test@test.com';
        ref.RW_Project__c= 'Runwal Bliss';
        ref.RW_Contact_Phone__c = '1221122100';
        ref.RW_Status__c = 'In Process';
        ref.RW_LeadCreated__c = false;
        ref.RW_Duplicate_Lead__c = false;
        ref.Account__c = acc.Id;
        insert ref;
        
        
        Project__c prj = new Project__c();
        prj.Name = 'Runwal Bliss';
        prj.Loyalty_Head__c = UserInfo.getUserId();
        insert prj;
        
        Opportunity opp = new Opportunity();
        opp.StageName = 'Unit Booked';
        opp.CloseDate = Date.today() + 10;
        opp.Name = 'Test';
        opp.RW_Project__c = prj.Id;
        opp.RW_Mobile_No__c = '1221122100';
        opp.RW_Email__c = 'test@mail.com';
        insert opp;
        
        
        Test.startTest();
        ReferralLeadCreation rlc = new ReferralLeadCreation(new List<String>{ref.Id});
        Database.executeBatch(rlc);
        Test.stopTest();
    }
    
    @isTest
    public static void oppeithDifProjProsWithSameProjTest(){
        
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        RW_Referral__c ref = new RW_Referral__c();
        ref.RW_First_Name__c ='Test';
        ref.RW_Last_Name__c='Lead';
        ref.RW_Email_Address__c='Test@test.com';
        ref.RW_Project__c= 'Runwal Bliss';
        ref.RW_Contact_Phone__c = '1221122100';
        ref.RW_Status__c = 'In Process';
        ref.RW_LeadCreated__c = false;
        ref.RW_Duplicate_Lead__c = false;
        ref.Account__c = acc.Id;
        insert ref;
        
        
        Project__c prj = new Project__c();
        prj.Name = 'Runwal Bliss';
        prj.Loyalty_Head__c = UserInfo.getUserId();
        insert prj;
        
        Project__c prj2 = new Project__c();
        prj2.Name = 'Runwal Gardens';
        prj2.Loyalty_Head__c = UserInfo.getUserId();
        insert prj2;
        
        Opportunity opp = new Opportunity();
        opp.StageName = 'Unit Booked';
        opp.CloseDate = Date.today() + 10;
        opp.Name = 'Test';
        opp.RW_Project__c = prj2.Id;
        opp.RW_Mobile_No__c = '1221122100';
        opp.RW_Email__c = 'test@mail.com';
        insert opp;
        
        Prospect__c pros = new Prospect__c();
        pros.Project__c = prj.Id;
        insert pros;
        
        
        Test.startTest();
        ReferralLeadCreation rlc = new ReferralLeadCreation(new List<String>{ref.Id});
        Database.executeBatch(rlc);
        Test.stopTest();
    }
    
    @isTest
    public static void oppeithDifProjProsWithDiffProjTest(){
        
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        RW_Referral__c ref = new RW_Referral__c();
        ref.RW_First_Name__c ='Test';
        ref.RW_Last_Name__c='Lead';
        ref.RW_Email_Address__c='Test@test.com';
        ref.RW_Project__c= 'Runwal Bliss';
        ref.RW_Contact_Phone__c = '1221122100';
        ref.RW_Status__c = 'In Process';
        ref.RW_LeadCreated__c = false;
        ref.RW_Duplicate_Lead__c = false;
        ref.Account__c = acc.Id;
        insert ref;
        
        
        Project__c prj = new Project__c();
        prj.Name = 'Runwal Bliss';
        prj.Loyalty_Head__c = UserInfo.getUserId();
        insert prj;
        
        Project__c prj2 = new Project__c();
        prj2.Name = 'Runwal Gardens';
        prj2.Loyalty_Head__c = UserInfo.getUserId();
        insert prj2;
        
        Opportunity opp = new Opportunity();
        opp.StageName = 'Unit Booked';
        opp.CloseDate = Date.today() + 10;
        opp.Name = 'Test';
        opp.RW_Project__c = prj2.Id;
        opp.RW_Mobile_No__c = '1221122100';
        opp.RW_Email__c = 'test@mail.com';
        insert opp;
        
        Prospect__c pros = new Prospect__c();
        pros.Project__c = prj2.Id;
        insert pros;
        
        
        Test.startTest();
        ReferralLeadCreation rlc = new ReferralLeadCreation(new List<String>{ref.Id});
        Database.executeBatch(rlc);
        Test.stopTest();
    }
    
    @isTest
    public static void testschedule() {
        
        Test.StartTest();
    	ScheduleReferedLeadCreation testsche = new ScheduleReferedLeadCreation();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, testsche );
        Test.stopTest();
    }



}