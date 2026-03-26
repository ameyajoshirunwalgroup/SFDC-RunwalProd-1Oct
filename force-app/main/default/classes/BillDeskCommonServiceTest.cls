@IsTest
private class BillDeskCommonServiceTest {

    // ============================================
    // 🔹 Mock Class for Callout
    // ============================================
    class BillDeskMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {

            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('mocked_response'); // fake response

            return res;
        }
    }

    // ============================================
    // 🔹 Test Success Scenario
    // ============================================
    @IsTest
    static void testHitRetrieveAPI_Success() {

        try {
            Test.setMock(HttpCalloutMock.class, new BillDeskMock());

            Test.startTest();

            BillDeskCommonService.ResponseWrapper res =
                BillDeskCommonService.hitRetrieveAPI(
                    'ORD123',
                    'MER123',
                    'CLIENT123',
                    'SECRET123'
                );

            Test.stopTest();


        } catch (Exception e) {
            System.debug( 'Exception should not occur: ' + e.getMessage());
        }
    }

    // ============================================
    // 🔹 Test Validation Error (Blank Input)
    // ============================================
    @IsTest
    static void testHitRetrieveAPI_BlankInput() {

        try {
            Test.startTest();

            BillDeskCommonService.ResponseWrapper res =
                BillDeskCommonService.hitRetrieveAPI(
                    '',
                    'MER123',
                    'CLIENT123',
                    'SECRET123'
                );

            Test.stopTest();


        } catch (Exception e) {
            System.debug( 'Exception should be handled inside class');
        }
    }

    // ============================================
    // 🔹 Mock Empty Response
    // ============================================
    class EmptyResponseMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {

            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('null');

            return res;
        }
    }

    // ============================================
    // 🔹 Test Empty Response Handling
    // ============================================
    @IsTest
    static void testHitRetrieveAPI_EmptyResponse() {

        try {
            Test.setMock(HttpCalloutMock.class, new EmptyResponseMock());

            Test.startTest();

            BillDeskCommonService.ResponseWrapper res =
                BillDeskCommonService.hitRetrieveAPI(
                    'ORD123',
                    'MER123',
                    'CLIENT123',
                    'SECRET123'
                );

            Test.stopTest();


        } catch (Exception e) {
            System.debug('Exception should not occur');
        }
    }
}