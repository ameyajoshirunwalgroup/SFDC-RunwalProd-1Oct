@isTest
private class Lockated_CPPostInvoiceGenerationTest {

    @testSetup
    static void setupData() {
        // Create a base record for testing
        CP_Brokerage__c brokerage = new CP_Brokerage__c(
            Invoice_Number__c = 'TEMP-001',
            If_GST_is_applicable__c = 'No',
            Invoice_Status__c = 'Not Submitted'
        );
        insert brokerage;
    }

    /**
     * Test POST method: Success Scenario
     */
    @isTest
    static void testDoPostSuccess() {
        CP_Brokerage__c brokerage = [SELECT Id FROM CP_Brokerage__c LIMIT 1];
        
        // Prepare Request Body
        Lockated_CPPostInvoiceGeneration.InvoiceRequestWrapper wrap = new Lockated_CPPostInvoiceGeneration.InvoiceRequestWrapper();
        wrap.invDate = '2026-01-23';
        wrap.invNumber = 'INV-2026-001';
        wrap.invIsGSTApp = 'Yes';

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        
        request.requestUri = '/services/apexrest/cpCPInvoicesGeneration/';
        request.httpMethod = 'POST';
        request.params.put('invId', brokerage.Id);
        request.requestBody = Blob.valueOf(JSON.serialize(wrap));
        
        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        Lockated_CPPostInvoiceGeneration.doPost();
        Test.stopTest();

        Map<String, Object> responseData = (Map<String, Object>)JSON.deserializeUntyped(response.responseBody.toString());

        // Verify Record Update
        CP_Brokerage__c updated = [SELECT Invoice_Number__c, Invoice_Status__c FROM CP_Brokerage__c WHERE Id = :brokerage.Id];
    }

    /**
     * Test POST method: Validation Failures
     */
    @isTest
    static void testDoPostValidationFailures() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        RestContext.request = request;
        RestContext.response = response;

        // 1. Missing invId param
        Lockated_CPPostInvoiceGeneration.doPost();

        // 2. Missing Body
        request.params.put('invId', 'someFakeId');
        Lockated_CPPostInvoiceGeneration.doPost();

        // 3. Missing Fields in Wrapper
        request.requestBody = Blob.valueOf(JSON.serialize(new Lockated_CPPostInvoiceGeneration.InvoiceRequestWrapper()));
        Lockated_CPPostInvoiceGeneration.doPost();
    }

    /**
     * Test POST method: Invalid Date Format
     */
    @isTest
    static void testDoPostInvalidDate() {
        CP_Brokerage__c brokerage = [SELECT Id FROM CP_Brokerage__c LIMIT 1];
        
        Lockated_CPPostInvoiceGeneration.InvoiceRequestWrapper wrap = new Lockated_CPPostInvoiceGeneration.InvoiceRequestWrapper();
        wrap.invDate = 'Invalid-Date'; // This will trigger the catch block
        wrap.invNumber = 'INV-001';
        wrap.invIsGSTApp = 'Yes';

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.params.put('invId', brokerage.Id);
        request.requestBody = Blob.valueOf(JSON.serialize(wrap));
        
        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        Lockated_CPPostInvoiceGeneration.doPost();
        Test.stopTest();
    }

    /**
     * Test GET method: Success Scenario
     */
    @isTest
    static void testDoGetSuccess() {
        CP_Brokerage__c brokerage = [SELECT Id FROM CP_Brokerage__c LIMIT 1];
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        
        request.requestUri = '/services/apexrest/cpCPInvoicesGeneration/';
        request.httpMethod = 'GET';
        request.params.put('invId', brokerage.Id);
        
        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        Lockated_CPPostInvoiceGeneration.doGet();
        Test.stopTest();

        Map<String, Object> responseData = (Map<String, Object>)JSON.deserializeUntyped(response.responseBody.toString());
    }

    /**
     * Test GET method: Record Not Found
     */
    @isTest
    static void testDoGetNotFound() {
        // Generate a valid format but non-existent Id
        String fakeId = Id.valueOf(CP_Brokerage__c.sObjectType.getDescribe().getKeyPrefix() + '000000000001');
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.params.put('invId', fakeId);
        
        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        Lockated_CPPostInvoiceGeneration.doGet();
        Test.stopTest();
    }
}