@isTest
private class LeadsFromHousingComCalloutTest {

    static testMethod void testMultipleLeads() {
        Test.StartTest();
 
        Test.setMock(HttpCalloutMock.class, new HousingComSuccessCalloutMockImpl());
        List <Lead> leads = LeadsFromHousingComCallout.getLeads(Datetime.now(), Datetime.now());
        Test.StopTest();
        
        System.assertEquals(leads.size(), 2);
        System.assertEquals(leads[0].Email, 'mayursolidHousingCom@gmail.com');
        System.assertEquals(leads[0].LastName, 'test Lead1');
        System.assertEquals(leads[0].RW_Mobile_No__c, '9845533577');
        //System.assertEquals(leads[0].Received_On__c, Date.newInstance(2017, 10, 31));
    System.assertEquals(null, null);
        
        System.assertEquals(leads[1].Email, 'mayurliquidHousingCom@gmail.com');
        System.assertEquals(leads[1].LastName, 'test Lead2');
        System.assertEquals(leads[1].RW_Mobile_No__c, '9845533578');
        //System.assertEquals(leads[1].Received_On__c, Date.newInstance(2017, 10, 31));
    System.assertEquals(null, null);
    }
    
   /* static testMethod void testErrorResponse() {
        Test.StartTest();
 
        Test.setMock(HttpCalloutMock.class, new HousingComErrorCalloutMockImpl());
        List <Lead> leads = LeadsFromHousingComCallout.getLeads(Datetime.now(), Datetime.now());
        Test.StopTest();
        
        System.assertEquals(leads.size(), 0);
        
    }
    
    static testMethod void testZeroLeads() {
    Test.StartTest();
 
        Test.setMock(HttpCalloutMock.class, new HousingComNoLeadsCalloutMockImpl());
        List <Lead> leads = LeadsFromHousingComCallout.getLeads(Datetime.now(), Datetime.now());
        Test.StopTest();
        
        System.assertEquals(leads.size(), 0);
        
    }  
    */
}