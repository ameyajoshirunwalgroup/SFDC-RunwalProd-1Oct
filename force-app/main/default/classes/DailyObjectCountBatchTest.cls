@isTest
private class DailyObjectCountBatchTest {

    @testSetup
    static void setupData() {
        // 1. Create Dummy Data to Count
        // We will insert 5 Accounts. The batch should count these as 5.
        List<Account> accList = new List<Account>();
        for(Integer i=0; i<5; i++) {
            accList.add(new Account(Name = 'Test Account ' + i));
        }
        insert accList;

        // 2. Configure the Custom Setting
        // This tells the batch WHICH objects to look for during the test.
        List<Daily_Object_Config__c> configs = new List<Daily_Object_Config__c>();

        // Config A: Valid Object (Account)
        Daily_Object_Config__c conf1 = new Daily_Object_Config__c();
        conf1.Name = 'Setting 1';
        conf1.API_Names__c = 'Account';
        configs.add(conf1);

        // Config B: Invalid/Fake Object (To test error handling/skipping)
        Daily_Object_Config__c conf2 = new Daily_Object_Config__c();
        conf2.Name = 'Setting 2';
        conf2.API_Names__c = 'Non_Existent_Object__c';
        configs.add(conf2);

        insert configs;
    }

    @isTest
    static void testBatchLogic() {
        // Start the test context
        Test.startTest();

        // Initialize and Run the Batch
        DailyObjectCountBatch batch = new DailyObjectCountBatch();
        Database.executeBatch(batch);

        // StopTest forces the asynchronous batch to finish immediately
        Test.stopTest();

        // --- ASSERTIONS --- //
        
        // 1. Query the result table (Object_Record_Count__c)
        List<Object_Record_Count__c> results = [
            SELECT Object_Name__c, Record_Count__c 
            FROM Object_Record_Count__c
        ];

        // 2. Validate that we ignored the "Non_Existent_Object__c"
        // We should only have 1 record (for Account)
        System.assertEquals(1, results.size(), 'We expected exactly 1 log record.');

        // 3. Validate the Account count
        Object_Record_Count__c log = results[0];
        System.assertEquals('Account', log.Object_Name__c, 'The object name should be Account');
        System.assertEquals(5, log.Record_Count__c, 'The record count should be 5 as per setup');
    }
    
    // Optional: Test the Scheduler if you created one
    @isTest
    static void testScheduler() {
        Test.startTest();
        String cronExp = '0 0 0 15 3 ? 2099'; // Some future date
        
        // Ensure you have the scheduler class named 'DailyObjectCountScheduler'
        // If not, you can remove this method.
        try {
            DailyObjectCountScheduler sch = new DailyObjectCountScheduler();
            String jobId = System.schedule('Test Scheduler', cronExp, sch);
            System.assert(jobId != null);
        } catch(Exception e) {
            // If scheduler class doesn't exist yet, ignore
        }
        Test.stopTest();
    }
}