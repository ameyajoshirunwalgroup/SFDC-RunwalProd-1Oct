@IsTest
public class BilldeskRetrieveSchedulerTest {

    // ==============================================
    // Mock for Batch Callout
    // ==============================================
    private class RetrieveMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {

            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);

            String jsonResponse = JSON.serialize(new Map<String,Object>{
                'transactionid' => 'TXN999',
                'bank_ref_no' => 'BANK999',
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

    // ==============================================
    // TEST SCHEDULER EXECUTION
    // ==============================================
    @IsTest
    static void testSchedulerRunsBatch() {

        // Insert payment eligible for batch
        Payment_Transaction__c payment = new Payment_Transaction__c(
            Order_Id__c = 'SCHD123',
            Merchant_Id__c = 'MERCH1',
            Status__c = 'INITIATED'
        );
        insert payment;

        Test.setMock(HttpCalloutMock.class, new RetrieveMock());

        Test.startTest();

        // Schedule job
        String cronExp = '0 0 0 1 1 ? 2099'; 
        System.schedule(
            'Test Retrieve Scheduler',
            cronExp,
            new BilldeskRetrieveScheduler()
        );

        Test.stopTest();  // Executes scheduled job + batch

    }
}