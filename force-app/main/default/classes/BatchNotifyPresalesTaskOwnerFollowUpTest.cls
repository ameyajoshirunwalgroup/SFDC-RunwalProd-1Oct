@isTest
private class BatchNotifyPresalesTaskOwnerFollowUpTest {

    @testSetup
    static void setupData() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@test.com',
            Username = 'testuser+' + System.currentTimeMillis() + '@test.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Presales Task').getRecordTypeId();

        Task t = new Task(
            Subject = 'Test Follow-up Task',
            OwnerId = testUser.Id,
            RecordTypeId = recordTypeId,
            Next_Action_Date__c = Date.today(),
            Status = 'Not Started'
        );
        insert t;
    }

    @isTest
    static void testBatchExecution() {
        CustomNotificationType notificationType = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'PushNotificationtoSM' LIMIT 1];

        Test.startTest();
        BatchNotifyPresalesTaskOwnerFollowUp.callBatchNotifyPresalesTaskOwnerFollowUp();
        SchBatchNotifyPresalesTaskOwnerFollowUp sch = new SchBatchNotifyPresalesTaskOwnerFollowUp();
        sch.execute(null);
        Test.stopTest();

    }
}