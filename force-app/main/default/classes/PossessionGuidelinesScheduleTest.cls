@isTest
public class PossessionGuidelinesScheduleTest {
    
    @isTest
    public static void possesstionGuidelinesTest(){
        
        Project__c prj = new Project__c();
        prj.Name = 'Test Proj';
        insert prj;
        
        Opp_Close_Date__c cls = new Opp_Close_Date__c();
        cls.Project_Name__c = 'Test Proj';
        cls.Name = prj.Id;
        cls.No_of_Days__c = 45;
        insert cls;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.StageName = 'Qualification';
        opp.CloseDate = Date.today() + 10;
        opp.RW_Email__c = 'test@mail.com';
        opp.RW_Mobile_No__c = '1122445577';
        opp.RW_project__c = prj.Id;
        insert opp;
        
        Booking__c bkg = new Booking__c();
        bkg.Opportunity__c = opp.Id;
        bkg.RW_Country_Phone_Code__c = '+91';
        insert bkg;
        
        Test.startTest();
        PossessionGuidelinesSchedule b = new PossessionGuidelinesSchedule();
        b.execute(null);
        Test.stopTest();
    }

}