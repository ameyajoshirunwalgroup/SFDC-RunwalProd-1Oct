@IsTest
public class BilldeskRetrieveTransactionAPITest {

    // ======================================================
    // SUCCESS MOCK
    // ======================================================
    private class SuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {

            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type','application/jose');

            // Fake BillDesk JSON response
            String jsonResponse = JSON.serialize(new Map<String,Object>{
                'transactionid' => 'TXN123',
                'bank_ref_no' => 'BANK123',
                'auth_status' => '0300',
                'transaction_error_type' => 'success',
                'transaction_error_code' => '0',
                'transaction_error_desc' => 'Success',
                'transaction_date' => '2026-03-03T10:10:10'
            });

            String header = EncodingUtil.base64Encode(Blob.valueOf('{"alg":"HS256"}'));
            String body   = EncodingUtil.base64Encode(Blob.valueOf(jsonResponse));

            res.setBody(header + '.' + body + '.signature');

            return res;
        }
    }

    // ======================================================
    // ERROR MOCK
    // ======================================================
    private class ErrorMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {

            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);

            String jsonResponse = JSON.serialize(new Map<String,Object>{
                'status' => 'FAIL',
                'error_code' => '500',
                'message' => 'Server Error',
                'error_type' => 'failure'
            });

            String header = EncodingUtil.base64Encode(Blob.valueOf('{"alg":"HS256"}'));
            String body   = EncodingUtil.base64Encode(Blob.valueOf(jsonResponse));

            res.setBody(header + '.' + body + '.signature');

            return res;
        }
    }

    // ======================================================
    // TEST SUCCESS FLOW
    // ======================================================
    @IsTest
    static void testBatchSuccess() {
        Payment_Gateway__mdt gateway =
        [SELECT Bill_Desk_Merchant_ID__c, Bill_Desk_GST_Merchant_ID__c,Parent_Merchant_Id__c,Client_Id__c,Secret_Key__c
         FROM Payment_Gateway__mdt where DeveloperName='Runwal_Bliss_Tower_1Test'
         LIMIT 1];

        Payment_Transaction__c payment = new Payment_Transaction__c(
            Order_Id__c = 'ORD123',
            Merchant_Id__c = 'RNLSPLTUAT',
            Status__c = 'INITIATED'
        );
        insert payment;

        Test.setMock(HttpCalloutMock.class, new SuccessMock());

        Test.startTest();
        Database.executeBatch(new BilldeskRetrieveTransactionAPI(), 1);
        Test.stopTest();

    }

    // ======================================================
    // TEST FAILURE FLOW
    // ======================================================
    @IsTest
    static void testBatchFailure() {
        Payment_Gateway__mdt gateway =
        [SELECT Bill_Desk_Merchant_ID__c, Bill_Desk_GST_Merchant_ID__c,Parent_Merchant_Id__c,Client_Id__c,Secret_Key__c
         FROM Payment_Gateway__mdt where DeveloperName='Runwal_Bliss_Tower_1Test'
         LIMIT 1];

        Payment_Transaction__c payment = new Payment_Transaction__c(
            Order_Id__c = 'ORD456',
            Merchant_Id__c = 'RNLSPLTUAT',
            Status__c = 'PENDING'
        );
        insert payment;

        Test.setMock(HttpCalloutMock.class, new ErrorMock());

        Test.startTest();
        Database.executeBatch(new BilldeskRetrieveTransactionAPI(), 1);
        Test.stopTest();

    }
}