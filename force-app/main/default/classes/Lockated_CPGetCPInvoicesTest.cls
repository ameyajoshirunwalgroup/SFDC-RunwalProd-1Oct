@isTest
public class Lockated_CPGetCPInvoicesTest {
    @testSetup
    static void setupData() {
        // 1. Create a dummy Account or Invoice to act as the 'invId'
        Account dummyInvoice = new Account(Name = 'Test Invoice');
        insert dummyInvoice;
        
        Account dummyInvoiceData = new Account(Name = 'Test Invoice No Data');
        insert dummyInvoiceData;

        // 2. Create ContentVersion (This automatically creates ContentDocument)
        ContentVersion cv = new ContentVersion(
            Title = 'Invoice_Document',
            PathOnClient = 'Invoice_Document.pdf',
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true
        );
        insert cv;

        // 3. Get the ContentDocumentId created by Salesforce
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;

        // 4. Create ContentDocumentLink to link the File to the Record
        ContentDocumentLink cdl = new ContentDocumentLink(
            LinkedEntityId = dummyInvoice.Id,
            ContentDocumentId = conDocId,
            ShareType = 'V'
        );
        insert cdl;
    }
    @isTest
    static void testGetCPInvoices(){
        Account acc = [SELECT Id FROM Account where Name ='Test Invoice' LIMIT 1];
        if(acc!=null && acc.Id!=null){
            setupRestContext('test',acc.Id);
            Lockated_CPGetCPInvoices.getInvoice();
        }
    }
    @isTest
    static void testGetCPInvoicesForNullInv(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        if(acc!=null && acc.Id!=null){
            setupRestContext('test','');
            Lockated_CPGetCPInvoices.getInvoice();
        }
    }
    @isTest
    static void testGetCPInvoicesForInvWhereNodata(){
        Account acc = [SELECT Id FROM Account where Name ='Test Invoice No Data' LIMIT 1];
        if(acc!=null && acc.Id!=null){
            setupRestContext('test',acc.Id);
            Lockated_CPGetCPInvoices.getInvoice();
        }
    }
    private static void setupRestContext(String body,String perameter) {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/cpGetInvoiceDocument/';
        req.httpMethod = 'Get';
        req.addParameter('invId',perameter);
        req.requestBody = Blob.valueOf(body);
        
        RestContext.request = req;
        RestContext.response = res;
    }
}