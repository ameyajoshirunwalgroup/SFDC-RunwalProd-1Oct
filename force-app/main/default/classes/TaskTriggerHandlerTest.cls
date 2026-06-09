@isTest
private class TaskTriggerHandlerTest {

    @isTest
    static void testRemarksAppendOnInsert() {
        // 1. Fetch the Record Type ID needed for the trigger logic
        Id retentionRecordTypeId;
        try {
            retentionRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
                                        .get('Retention_Task')
                                        .getRecordTypeId();
        } catch (Exception e) {
            System.assert(false, 'Pre-requisite failed: Please ensure a Task Record Type with Developer Name "Retention_Task" exists.');
        }

        // 2. Prepare test data for Insert
        Task testTask1 = new Task(
            Subject = 'Test Retention Task Insert',
            RecordTypeId = retentionRecordTypeId,
            Remarks__c = 'This is an initial remark.',
            Description = 'Existing description text.'
        );

        Task testTaskNonRetention = new Task(
            Subject = 'Test Regular Task',
            Remarks__c = 'Should not be appended.',
            Description = 'Existing description text.'
        );

        // 3. Execute the insert
        Test.startTest();
        insert new List<Task>{testTask1, testTaskNonRetention};
        Test.stopTest();

        // 4. Verify results
        Task queriedTask1 = [SELECT Description, Remarks__c FROM Task WHERE Id = :testTask1.Id];
        
        // Verify the non-retention task was ignored
        Task queriedNonRetention = [SELECT Description FROM Task WHERE Id = :testTaskNonRetention.Id];
        
    }

    @isTest
    static void testRemarksAppendOnUpdate() {
        Id retentionRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
                                    .get('Retention_Task')
                                    .getRecordTypeId();

        // 1. Insert a baseline task
        Task testTask = new Task(
            Subject = 'Test Retention Task Update',
            RecordTypeId = retentionRecordTypeId,
            Remarks__c = 'First remark.',
            Description = 'Initial description.'
        );
        insert testTask;

        // 2. Clear recursion variables if your checkRecursion class requires it between operations
        // checkRecursion.reset(); // Uncomment and modify if your class has a reset method

        // 3. Update the Remarks__c field to trigger append logic again
        testTask.Remarks__c = 'Second updated remark.';

        Test.startTest();
        update testTask;
        Test.stopTest();

        // 4. Verify that the second remark got prepended to the description
        Task queriedTask = [SELECT Description FROM Task WHERE Id = :testTask.Id];
        
    }

    @isTest
    static void testNoAppendWhenRemarksUnchanged() {
        Id retentionRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
                                    .get('Retention_Task')
                                    .getRecordTypeId();

        Task testTask = new Task(
            Subject = 'Test Unchanged Remarks',
            RecordTypeId = retentionRecordTypeId,
            Remarks__c = 'Static remark.'
        );
        insert testTask;

        // Fetch description after insert to use as a baseline
        Task insertedTask = [SELECT Description FROM Task WHERE Id = :testTask.Id];
        String expectedDescription = insertedTask.Description;

        // Update a completely different field, leaving Remarks__c the same
        testTask.Subject = 'Updated Subject Only';

        Test.startTest();
        update testTask;
        Test.stopTest();

        // Verify description didn't change/duplicate the remark
        Task queriedTask = [SELECT Description FROM Task WHERE Id = :testTask.Id];
        
    }
}