@IsTest(SeeAllData=true)
public class JuvlonIntegrationTest {
    //@testSetup  
    static testMethod void scheduleMsTeamsTest1() {
        RW_Juvlon_Campaign__c julcom = new RW_Juvlon_Campaign__c();
        //julcom.RW_Approved_By__c
        julcom.RW_Campaign_Status__c = 'Sent for approval';
        julcom.RW_ListId__c = 'Newyeartest2';
        julcom.RW_Report_Id__c = '00O0I00000Avgg6UAB';
        julcom.RW_from_date__c = system.today();
        julcom.RW_to_date__c = system.today().addDays(1);
        //julcom.RW_Juvlon_Object__c = 'Lead';
        
        insert julcom;
        
        Test.startTest();     
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        JuvlonIntegration.reportMethod(new List<Id>{julcom.Id});
        Test.stopTest();
        
        JuvlonJson jul = new JuvlonJson();
        jul.apiKey = 'sas';
    }
}