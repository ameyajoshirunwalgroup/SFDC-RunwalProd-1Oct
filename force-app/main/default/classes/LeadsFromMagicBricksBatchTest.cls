@isTest
private class LeadsFromMagicBricksBatchTest {
  
    static testmethod void testSuccessCallout() {   
                
        Test.startTest();
    Test.setMock(HttpCalloutMock.class, new MagicBricksSuccessCalloutMockImpl());
        Database.executeBatch(new LeadsFromMagicBricksBatch(Datetime.newInstance(2016,06,07,0,0,0), Datetime.newInstance(2016,06,07,23,59,59)));
        Test.stopTest();
        
        List<Lead> leads = [SELECT Id FROM Lead WHERE Email = 'mayurliquidMagicBricks@gmail.com' or Email = 'mayursolidMagicBricks@gmail.com'];
        System.debug('leads = ' + leads);
        /*System.assertEquals(leads.size(), 2);
        System.assertEquals(leads[0].Email, 'mayursolidMagicBricks@gmail.com');
        System.assertEquals(leads[0].LastName, 'mayurMagicBricks');
        System.assertEquals(leads[0].RW_Mobile_No__c, '919845533577');
        System.assertEquals(leads[0].Received_On__c, Date.newInstance(2016, 6, 7));
    System.assertEquals(leads[0].City_R__c, 'Bangalore');
        
        System.assertEquals(leads[1].Email, 'mayurliquidMagicBricks@gmail.com');
        System.assertEquals(leads[1].LastName, 'mayurLQMagicBricks');
        System.assertEquals(leads[1].RW_Mobile_No__c, '449845533578');
        System.assertEquals(leads[1].Received_On__c, Date.newInstance(2016, 6, 8));
    System.assertEquals(leads[1].City_R__c, 'Pune');*/
    }
    
     @isTest
    private static void test2() { //Added by Vinay 29-08-2025
        
        MB_Campaign_Code__c gp = new MB_Campaign_Code__c();
        gp.Name = 'Runwal Bliss';
        gp.Project_Name__c = 'Runwal Bliss';
        insert gp;
        
        Project__c proj = new Project__c();
        proj.Name = 'Runwal Bliss';
        insert proj;
        
        Test.startTest();
    	Test.setMock(HttpCalloutMock.class, new MagicBricksSuccessCalloutMockImpl());
        Database.executeBatch(new LeadsFromMagicBricksBatch(Datetime.newInstance(2016,06,07,0,0,0), Datetime.newInstance(2016,06,07,23,59,59)));
        Test.stopTest();
    }
}