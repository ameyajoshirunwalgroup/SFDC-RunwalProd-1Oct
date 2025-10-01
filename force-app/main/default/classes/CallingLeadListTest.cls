@isTest
public class CallingLeadListTest {
    
    @isTest
    public static void test1(){
        
        Lead ld = new Lead();
        ld.LastName = 'Test Lead';
        ld.Email = 'test@mail.com';
        ld.RW_Mobile_No__c = '1111111111';
        ld.Calling_Campaign__c = 'Campaign 1';
        insert ld;
        
        Test.startTest();
        CallingLeadList.leadList(ld.Calling_Campaign__c, 'All');
        CallingLeadList.getStatusValues();
        CallingLeadList.getCampaignValues();
        Test.stopTest();
    }

}