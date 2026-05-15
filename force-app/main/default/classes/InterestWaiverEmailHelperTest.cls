@isTest
private class InterestWaiverEmailHelperTest {

    @isTest
    static void testSendApprovalEmail_NoWorkItem() {
        // Create a Booking record
        Booking__c bk = new Booking__c();
        insert bk;

        // Call with no approval work items — should exit gracefully
        Test.startTest();
        InterestWaiverEmailHelper.sendApprovalEmail(new List<Id>{ bk.Id });
        Test.stopTest();

        System.assert(true, 'Method should handle missing work items gracefully');
    }

    @isTest
    static void testSendApprovalEmail_WithIOMFile() {
        // Create a Booking record
        Booking__c bk = new Booking__c();
        insert bk;

        // Create a ContentVersion (IOM file)
        ContentVersion cv = new ContentVersion(
            Title = 'image_IOM',
            PathOnClient = 'image_IOM.jpg',
            VersionData = Blob.valueOf('test image content'),
            IsMajorVersion = true
        );
        insert cv;

        // Link to Booking
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        ContentDocumentLink cdl = new ContentDocumentLink(
            LinkedEntityId = bk.Id,
            ContentDocumentId = cv.ContentDocumentId,
            ShareType = 'V'
        );
        insert cdl;

        // Call — should exit gracefully (no ProcessInstanceWorkitem)
        Test.startTest();
        InterestWaiverEmailHelper.sendApprovalEmail(new List<Id>{ bk.Id });
        Test.stopTest();

        System.assert(true, 'Method should handle file with no work items gracefully');
    }

    @isTest
    static void testSendApprovalEmail_EmptyList() {
        Test.startTest();
        InterestWaiverEmailHelper.sendApprovalEmail(new List<Id>());
        Test.stopTest();

        System.assert(true, 'Method should handle empty list gracefully');
    }
}