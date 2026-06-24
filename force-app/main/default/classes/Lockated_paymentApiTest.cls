@IsTest
public class Lockated_paymentApiTest {

    // ---------------------------------------------------
    // Helper to prepare RestContext
    // ---------------------------------------------------
    private static void setupRestContext(String body) {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/lockated/payment';
        req.httpMethod = 'POST';
        req.requestBody = body != null ? Blob.valueOf(body) : null;

        RestContext.request = req;
        RestContext.response = new RestResponse();
    }

    // ---------------------------------------------------
    // 1️⃣ Test Empty Body
    // ---------------------------------------------------
    @IsTest
    static void testEmptyRequestBody() {

        setupRestContext(null);

        Test.startTest();
        Lockated_paymentApi.processPayment();
        Test.stopTest();

    }


    // ---------------------------------------------------
    // 2️⃣ Test Validation Error
    // ---------------------------------------------------
    @IsTest
    static void testValidationFailure() {

        // Missing paymentType
        String jsonBody = JSON.serialize(new Map<String,Object>{
            'bookingId' => 'BOOK123',
            'totalAmount' => 1000
        });

        setupRestContext(jsonBody);

        Test.startTest();
        Lockated_paymentApi.processPayment();
        Test.stopTest();

    }


    // ---------------------------------------------------
    // 3️⃣ Test Success Flow
    // ---------------------------------------------------
    @IsTest
    static void testSuccessFlow() {

        // We mock HTTP callouts inside BillDeskService
        Test.setMock(HttpCalloutMock.class, new BillDeskMockSuccess());

        String jsonBody = JSON.serialize(new Map<String,Object>{
            'bookingId' => 'BOOK123',
            'totalAmount' => 1000,
            'paymentType' => 'PRINCIPAL_GST'
        });

        setupRestContext(jsonBody);

        Test.startTest();
        Lockated_paymentApi.processPayment();
        Test.stopTest();

    }


    // ---------------------------------------------------
    // 4️⃣ Test Exception Flow
    // ---------------------------------------------------
    @IsTest
    static void testExceptionFlow() {

        // Force exception by sending invalid JSON
        setupRestContext('{ invalid json');

        Test.startTest();
        Lockated_paymentApi.processPayment();
        Test.stopTest();

    }


    // ---------------------------------------------------
    // Mock Callout
    // ---------------------------------------------------
    private class BillDeskMockSuccess implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {

            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);

            // Return dummy JOSE or JSON depending on your service expectation
            res.setBody('{"status":"SUCCESS","orderId":"BOOK123"}');

            return res;
        }
    }
}