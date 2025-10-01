@isTest
public class ProspectEngagementViaWhatsappTest {
    
    @isTest
    public static void test(){
        
        Project__c proj = new Project__c();
        proj.Name = 'Test Project';
        proj.VDNB_Customer_Whatsapp_Journey__c = true;
        proj.Day_3_Whatsapp_Content__c = 'Day 3 Content';
        proj.Day_1_Whatsapp_Content__c = 'Day 1 Content';
        proj.Key_Features_Amenities_Video_Link__c = 'video link';
        proj.Testimonial_Video_Link__c = 'video link';
        proj.Prospect_Engagement_Team__c = 'Test Project Team';
        proj.Photo_Album__c = 'Photo Album';
        insert proj;
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.StageName= 'Qualification';
        opp.CloseDate = Date.today() + 10;
        opp.Name = 'Test Opportunity';
        opp.AccountId = acc.Id;
        opp.RW_Email__c = 'test@mail.com';
        opp.RW_Mobile_No__c = '2536547895';
        opp.RW_Project__c = proj.Id;
        opp.Date_Of_Visit__c = Date.today() - 5;
        insert opp;
        
        CIF__c cif = new CIF__c();
        cif.Opportunity__c = opp.Id;
        insert cif;
        
        ProspectEngagementViaWhatsapp b = new ProspectEngagementViaWhatsapp();
        b.execute(null);
        
    }

}