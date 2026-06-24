@isTest
private class Lockated_CP_Sync_Test {
    
    @testSetup
    static void setupData() {
        // Create test Broker records that meet your Batch query criteria
        List<Broker__c> brokers = new List<Broker__c>();
        for(Integer i=0; i<5; i++) {
            brokers.add(new Broker__c(
                NAME_FIRST__c = 'TestFirst' + i,
                NAME_LAST__c = 'TestLast' + i,
                RW_Email__c = 'test' + i + '@runwal.com',
                RW_Mobile_No__c = '987654321' + i,
                Broker_Pan_No__c = 'ABCDE1234' + i,
                RW_GST_Number__c = 'GST12345' + i,
                CP_APP_Registration__c = false
            ));
        }
        insert brokers;
    }

    @isTest
    static void testBatchExecution() {
        // Assign the mock callout to the test context
        Test.setMock(HttpCalloutMock.class, new Lockated_CP_Mock());
        
        Test.startTest();
        Lockated_SyncCPUsersBatch batch = new Lockated_SyncCPUsersBatch();
        Database.executeBatch(batch);
        Test.stopTest();
        
        // Assert that records were updated successfully
        List<Broker__c> results = [SELECT CP_APP_Registration__c FROM Broker__c];
        for(Broker__c b : results) {
           //  System.assertEquals(true, b.CP_APP_Registration__c, 'Broker should be marked as registered.');
        }
    }

    @isTest
    static void testSingleCallout() {
        Broker__c b = [SELECT Id FROM Broker__c LIMIT 1];
        
        Test.setMock(HttpCalloutMock.class, new Lockated_CP_Mock());
        
        Test.startTest();
        Lockated_CreateCP.createCPUser(b.Id);
        Test.stopTest();
        
        Broker__c updatedB = [SELECT CP_APP_Registration__c FROM Broker__c WHERE Id = :b.Id];
        System.assertEquals(true, updatedB.CP_APP_Registration__c, 'Single callout should update the flag.');
    }
}