@isTest
private class LeadsFromMagicBricksCalloutTest {

    static testMethod void testMultipleLeads() {
        Test.StartTest();
 
        Test.setMock(HttpCalloutMock.class, new MagicBricksSuccessCalloutMockImpl());
        List <Lead> leads = LeadsFromMagicBricksCallout.getLeads(Datetime.now(), Datetime.now());
        Test.StopTest();
        
        System.assertEquals(leads.size(), 2);
        System.assertEquals(leads[0].Email, 'mayursolidMagicBricks@gmail.com');
        System.assertEquals(leads[0].LastName, 'mayurMagicBricks');
        //System.assertEquals(leads[0].RW_Mobile_No__c, '919845533577');
        System.assertEquals(leads[0].Received_On__c, Date.newInstance(2016, 6, 7));
    System.assertEquals(leads[0].City__c, 'Bangalore');
        
        System.assertEquals(leads[1].Email, 'mayurliquidMagicBricks@gmail.com');
        System.assertEquals(leads[1].LastName, 'mayurLQMagicBricks');
        //System.assertEquals(leads[1].RW_Mobile_No__c, '449845533578');
        System.assertEquals(leads[1].Received_On__c, Date.newInstance(2016, 6, 8));
    System.assertEquals(leads[1].City__c, 'Pune');
    }
    
    static testMethod void testErrorResponse() {
        Test.StartTest();
 
        Test.setMock(HttpCalloutMock.class, new MagicBricksErrorCalloutMockImpl());
        List <Lead> leads = LeadsFromMagicBricksCallout.getLeads(Datetime.now(), Datetime.now());
        Test.StopTest();
        
        System.assertEquals(leads.size(), 0);
        
    }
    
    static testMethod void testZeroLeads() {
    Test.StartTest();
 
        Test.setMock(HttpCalloutMock.class, new MagicBricksNoLeadsCalloutMockImpl());
        List <Lead> leads = LeadsFromMagicBricksCallout.getLeads(Datetime.now(), Datetime.now());
        Test.StopTest();
        
        System.assertEquals(leads.size(), 0);
        
    }  
}