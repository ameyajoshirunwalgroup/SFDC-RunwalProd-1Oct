@isTest
public class PortalUserPasswordResetTest {
    
    @isTest
    public static void resetPasswordTest(){
        
        Profile p = [Select Id, Name from Profile where Name = 'Relationship Manager'];
        
        User usr = new User();
        usr.firstName = 'TestUser1';
        usr.lastName = 'TestUser2';
        usr.email='ttestt@gmail.com';
        usr.Username= 'tusername1@gmail.com';
        usr.ProfileId = p.Id;
        usr.alias= 'alias';
        usr.EmailEncodingKey='UTF-8';
        usr.LocaleSidKey='en_US';
        usr.TimeZoneSidKey='America/Los_Angeles';
        usr.LanguageLocaleKey='en_US';
    	insert usr;
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.RW_Email__c = 'test@mail.com';
        acc.Portal_User__c = usr.Id;
        insert acc;
        
        Project__c prj = new Project__c();
        prj.Name = 'Test Proj';
        insert prj;
        
        Opp_Close_Date__c cls = new Opp_Close_Date__c();
        cls.Project_Name__c = 'Test Proj';
        cls.Name = prj.Id;
        cls.No_of_Days__c = 45;
        insert cls;
        
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Test Opportunity';
        opp.StageName = 'Qualification';
        opp.CloseDate = Date.today() + 10;
        opp.RW_project__c = prj.Id;
        insert opp;
        
        Test.startTest();
        PortalUserPasswordReset.resetPassword(opp.Id);
        Test.stopTest();
    }

}