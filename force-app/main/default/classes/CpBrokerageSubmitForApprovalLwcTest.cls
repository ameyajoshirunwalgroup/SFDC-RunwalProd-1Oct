@isTest
public class CpBrokerageSubmitForApprovalLwcTest {
     
    // Utility to create a CP_Brokerage__c record
    Public static CP_Brokerage__c createBrokerage(String typeOfClient, String brokerageType) {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];

    User testUser = new User(
        FirstName = 'Test',
        LastName = 'User',
        Alias = 'tuser',
        Email = 'testuser' + DateTime.now().getTime() + '@example.com',
        Username = 'testuser' + DateTime.now().getTime() + '@example.com',
        CommunityNickname = 'testuser' + DateTime.now().getTime(),
        ProfileId = p.Id,
        TimeZoneSidKey = 'Asia/Kolkata',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US'
    );
  insert testUser;
        CP_Brokerage__c cp = new CP_Brokerage__c(
           
            Type_of_Client__c = typeOfClient,
            Brokerage_Type__c = brokerageType,
            CP_Invoice_Clearing_L1__c = testUser.Id,
            Approval_Status_clearing__c=''
        );
        insert cp;
        return cp;
    }

    // Utility to create a Brokerage_Scheme__c record
    private static Brokerage_Scheme__c createScheme() {
        Brokerage_Scheme__c scheme = new Brokerage_Scheme__c(
            Name = 'Test Scheme'
        );
        insert scheme;
        return scheme;
    }
    
    
    
    @isTest
    static void testSendForApprovalInvoice() {
        Test.startTest();
        CP_Brokerage__c cp = createBrokerage('NRI', 'Additional Brokerage');
        Boolean result = CpBrokerageSubmitForApprovalLwc.SendForApprovalInvoice('Invoice Approval', cp.Id);
      //  System.assertEquals(true, result);
        Test.stopTest();
    }

    @isTest
    static void testCheckAttachment() {
        Brokerage_Scheme__c scheme = createScheme();
        Boolean result = CpBrokerageSubmitForApprovalLwc.CheckAttachment(scheme.Id);
       // System.assertEquals(false, result); // no files attached yet
    }

    @isTest
    static void testCheckAttachmentInvoice() {
        CP_Brokerage__c cp = createBrokerage('Local', 'Base Brokerage');
        Boolean result = CpBrokerageSubmitForApprovalLwc.CheckAttachmentInvoice(cp.Id);
       // System.assertEquals(true, result); // default set to true
    }

    @isTest
    static void testCreateContentLinkAndReturnFiles() {
        CP_Brokerage__c cp = createBrokerage('Local', 'Additional Brokerage');
        
        // Create dummy ContentVersion
        ContentVersion cv = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'testfile.pdf',
            VersionData = Blob.valueOf('Unit Test Content'),
            IsMajorVersion = true
        );
        insert cv;
        cv = [SELECT Id, ContentDocumentId,Title FROM ContentVersion WHERE Id = :cv.Id];
        
        // Wrap file for input
        CpBrokerageSubmitForApprovalLwc.Fileupload fileWrapper = new CpBrokerageSubmitForApprovalLwc.Fileupload();
        fileWrapper.name = cv.Title;
        fileWrapper.contentVersionId = cv.Id;
        
        List<Object> fileList = new List<Object>{fileWrapper};
        
        Test.startTest();
        List<Id> returnedIds = CpBrokerageSubmitForApprovalLwc.createContentLink(fileList, cp.Id);
       // System.assertNotEquals(0, returnedIds.size());
        
        List<ContentVersion> versions = CpBrokerageSubmitForApprovalLwc.returnFiles(new List<Object>{'fid(' + cv.Id + ')'});
      //  System.assertEquals(1, versions.size());
        
        List<ContentVersion> versionsIgnore = CpBrokerageSubmitForApprovalLwc.returnFilesignore(new List<Object>{'fid(' + cv.Id + ')'});
      //  System.assertEquals(1, versionsIgnore.size());
        Test.stopTest();
    }

    @isTest
    static void testCheckClientNRI() {
        CP_Brokerage__c cp = createBrokerage('NRI', 'Additional Brokerage');
        Boolean isnri = CpBrokerageSubmitForApprovalLwc.CheckClient(cp.Id);
       // System.assertEquals(true, isnri);
    }
    
    @isTest
    static void testCheckClientOuts() {
        CP_Brokerage__c cp = createBrokerage('Outstation', 'Base Brokerage');
        Boolean isOutstation = CpBrokerageSubmitForApprovalLwc.CheckClientOuts(cp.Id);
       // System.assertEquals(true, isOutstation);
    }
    
    @isTest
    static void testIsKicker() {
        CP_Brokerage__c cp = createBrokerage('Local', 'Kicker Incentive');
        Boolean iskicker = CpBrokerageSubmitForApprovalLwc.IsKicker(cp.Id);
       // System.assertEquals(true, iskicker);
    }
}