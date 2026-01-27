@isTest
public class Lockated_CPUploadCPInvoicesTest {
    @testSetup
    static void setupData() {
        // Create a dummy Project/Booking structure if needed for the inner loop
        // Note: Replace with actual field/object names if they differ in your org
        CP_Brokerage__c brokerage = new CP_Brokerage__c(
            Invoice_Number__c = 'INV-1001',
            Invoice_Status__c = 'Invoice Uploaded', // Step 3
            Total_Invoice_Amount__c = 5000.00
        );
        insert brokerage;
    }
    @isTest
    static void testGetActiveProjectsSuccess() {
        CP_Brokerage__c brokerage = [SELECT Id FROM CP_Brokerage__c LIMIT 1];
        // Prepare JSON Request Body
        Lockated_CPUploadCPInvoices.FileRequest fileReq = new Lockated_CPUploadCPInvoices.FileRequest();
        fileReq.fileData = EncodingUtil.base64Encode(Blob.valueOf('Test File Content'));
        fileReq.fileName = 'TestInvoice.pdf';
        
        setupRestContext(fileReq,brokerage.Id);
        Lockated_CPUploadCPInvoices.uploadInvoice();
    }
    @isTest
    static void testGetInvNull() {
        CP_Brokerage__c brokerage = [SELECT Id FROM CP_Brokerage__c LIMIT 1];
        // Prepare JSON Request Body
        Lockated_CPUploadCPInvoices.FileRequest fileReq = new Lockated_CPUploadCPInvoices.FileRequest();
        fileReq.fileData = EncodingUtil.base64Encode(Blob.valueOf('Test File Content'));
        fileReq.fileName = 'TestInvoice.pdf';
        
        setupRestContext(fileReq,'');
        Lockated_CPUploadCPInvoices.uploadInvoice();
    }
    @isTest
    static void testGetJsonBlank() {
        CP_Brokerage__c brokerage = [SELECT Id FROM CP_Brokerage__c LIMIT 1];
        // Prepare JSON Request Body
        Lockated_CPUploadCPInvoices.FileRequest fileReq = new Lockated_CPUploadCPInvoices.FileRequest();
        /*fileReq.fileData = EncodingUtil.base64Encode(Blob.valueOf('Test File Content'));
        fileReq.fileName = 'TestInvoice.pdf';*/
        
        setupRestContextForNullBody(fileReq,brokerage.Id);
        Lockated_CPUploadCPInvoices.uploadInvoice();
    }
    private static void setupRestContext(Lockated_CPUploadCPInvoices.FileRequest fileReq,String brokId) {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/cpUploadInvoices/';
        req.httpMethod = 'Post';
        req.params.put('invId', brokId);
        req.requestBody = Blob.valueOf(JSON.serialize(fileReq));
        
        RestContext.request = req;
        RestContext.response = res;
    }
    private static void setupRestContextForNullBody(Lockated_CPUploadCPInvoices.FileRequest fileReq,String brokId) {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/cpUploadInvoices/';
        req.httpMethod = 'Post';
        req.params.put('invId', brokId);
        // req.requestBody = Blob.valueOf(JSON.serialize(fileReq));
        
        RestContext.request = req;
        RestContext.response = res;
    }
}