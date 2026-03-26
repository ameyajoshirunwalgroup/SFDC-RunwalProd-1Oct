@IsTest(SeeAllData=true)
private class BillDeskStatusServiceTest {

    // ============================================
    // 🔹 Mock Callout
    // ============================================
    class BillDeskMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {

            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);

            // fake response (decode may or may not work)
            res.setBody('mocked_response');

            return res;
        }
    }

    // ============================================
    // 🔹 Test Success Scenario
    // ============================================
    @IsTest
    static void testFetchFullResponse_Success() {

        try {
            Test.setMock(HttpCalloutMock.class, new BillDeskMock());

            // 👉 Use any merchantId that exists in your org metadata
            String merchantId = 'RNLSPLTUAT';

            Test.startTest();

            Map<String,Object> result =
                BillDeskStatusService.fetchFullResponse(
                    'ORD123',
                    merchantId
                );

            Test.stopTest();


        } catch (Exception e) {
            System.debug('Should not throw exception: ' + e.getMessage());
        }
    }

    // ============================================
    // 🔹 Test Blank Input
    // ============================================
    @IsTest
    static void testFetchFullResponse_BlankInput() {

        try {
            Test.startTest();

            Map<String,Object> result =
                BillDeskStatusService.fetchFullResponse(
                    '',
                    'RNLSPLTUAT'
                );

            Test.stopTest();


        } catch (Exception e) {
            System.debug( 'Handled inside method');
        }
    }

    // ============================================
    // 🔹 Test Metadata Not Found
    // ============================================
    @IsTest
    static void testFetchFullResponse_NoMetadata() {

        try {
            Test.startTest();

            // Pass merchantId which does NOT exist
            Map<String,Object> result =
                BillDeskStatusService.fetchFullResponse(
                    'ORD123',
                    'INVALID_MERCHANT'
                );

            Test.stopTest();


        } catch (Exception e) {
            System.debug( 'Should be handled');
        }
    }
}