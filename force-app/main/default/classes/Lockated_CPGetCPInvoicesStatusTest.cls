@isTest
private class Lockated_CPGetCPInvoicesStatusTest {

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
    static void testGetInvoiceSuccess() {
        CP_Brokerage__c brokerage = [SELECT Id FROM CP_Brokerage__c LIMIT 1];
        
        // Setup RestContext
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        
        request.requestUri = '/services/apexrest/cpGetCPInvoicesStatus/';
        request.httpMethod = 'GET';
        request.params.put('invId', brokerage.Id);
        
        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        Lockated_CPGetCPInvoicesStatus.doGet();
        Test.stopTest();

        // Verify Response
        System.assertEquals(200, response.statusCode, 'Status code should be 200');
        
        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(response.responseBody.toString());
        System.assertEquals('success', result.get('status'));
        
        // Verify Dynamic Status List logic
        List<Object> details = (List<Object>)result.get('details');
        Map<String, Object> firstDetail = (Map<String, Object>)details[0];
        List<Object> statusList = (List<Object>)firstDetail.get('statuslist');
        
        // "Invoice Uploaded" is step 3, so first 3 items should be "true"
        Map<String, Object> step3 = (Map<String, Object>)statusList[2];
        System.assertEquals('true', step3.get('status'));
    }

    @isTest
    static void testMissingParameters() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        
        request.requestUri = '/services/apexrest/cpGetCPInvoicesStatus/';
        request.httpMethod = 'GET';
        // invId is NOT added to params
        
        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        Lockated_CPGetCPInvoicesStatus.doGet();
        Test.stopTest();

        System.assertEquals(400, response.statusCode, 'Should return 400 for missing params');
        String body = response.responseBody.toString();
        System.assert(body.contains('Missing required parameters'), 'Error message should be present');
    }

    @isTest
    static void testRecordNotFound() {
        // Generate a fake Id
        String fakeId = Id.valueOf(CP_Brokerage__c.sObjectType.getDescribe().getKeyPrefix() + '000000000001');
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.params.put('invId', fakeId);
        
        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        Lockated_CPGetCPInvoicesStatus.doGet();
        Test.stopTest();

        System.assertEquals(404, response.statusCode, 'Should return 404 for non-existent record');
    }

    @isTest
    static void testStatusMappingLogic() {
        // Direct testing of the static helper method
        Test.startTest();
        List<Lockated_CPGetCPInvoicesStatus.statusWrapper> result = Lockated_CPGetCPInvoicesStatus.getDynamicStatusList('Payment in Progress');
        Test.stopTest();

        // 'Payment in Progress' is step 4
        // So step 1, 2, 3, 4 should be 'true', step 5 should be 'false'
        System.assertEquals(5, result.size());
        System.assertEquals('true', result[0].status); // Not Submitted
        System.assertEquals('true', result[3].status); // Payment in Progress
        System.assertEquals('false', result[4].status); // Payment Done
    }
}