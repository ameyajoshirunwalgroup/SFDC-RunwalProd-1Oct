@isTest
public class PostPossessionDashboardForFmCtrlTest {

    @isTest
    public static void ppdForFMTest(){
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
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
        Project__c proj1 = new Project__c();
        proj1.Name = 'Runwal MyCity';
        insert proj1;
        
        Project__c proj2 = new Project__c();
        proj2.Name = 'Runwal Gardens';
        insert proj2;
        
        Project__c proj3 = new Project__c();
        proj3.Name = 'Runwal Bliss';
        insert proj3;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.AccountId = acc.Id;
        opp.RW_Mobile_No__c = '9874563210';
        opp.RW_Email__c = 'test@mail.com';
        opp.StageName = 'Unit Booked';
        opp.SAP_Customer_Number__c = '0020012345';
        opp.RW_Project__c = proj2.Id;
        opp.CloseDate = Date.today() + 10;
        insert opp;
        
        WhatsApp_Feedback__c fb = new WhatsApp_Feedback__c();
        fb.Feedback_Type__c = 'Post Possession Handover';
        fb.Answer_21__c = 'Excellent';
        fb.Answer_22__c = 'Very Good';
        fb.Answer_23__c = 'Good';
        fb.Answer_24__c = 'Bad';
        fb.Answer_25__c = 'Excellent';
        fb.Answer_26__c = 'Very Good';
        fb.Answer_27__c = 'Good';
        fb.Answer_29__c = '08';
        fb.Post_Possession_Frequency__c = 60;
        fb.Opportunity__c = opp.Id;
        insert fb;
        
         
        PostPossessionDashboardForFmCtrl.getTeam();
        PostPossessionDashboardForFmCtrl.getDefaultRecords(null,'','');
        PostPossessionDashboardForFmCtrl.getRecords('','','');
        PostPossessionDashboardForFmCtrl.npsSummaryForYear();
        PostPossessionDashboardForFmCtrl.eventWiseData('Admin','','','','Post Possession Handover 60 days');
        PostPossessionDashboardForFmCtrl.npsWiseData('Post Possession Handover 60 days','Admin','','','','All Projects','08');
        PostPossessionDashboardForFmCtrl.npsWiseDataPPD('Post Possession Handover 60 days','Admin','','','','All Projects','08');
        PostPossessionDashboardForFmCtrl.overAllDataExp('Admin','','','');
        PostPossessionDashboardForFmCtrl.npsSummaryYearMonthValues();
    }
}