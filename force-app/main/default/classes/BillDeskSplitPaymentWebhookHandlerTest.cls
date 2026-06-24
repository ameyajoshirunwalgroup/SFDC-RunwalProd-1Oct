@IsTest
public class BillDeskSplitPaymentWebhookHandlerTest {

    // --------------------------------------------------
    // Helper: Base64URL Encode
    // --------------------------------------------------
    private static String base64UrlEncode(Blob input){
        String output = EncodingUtil.base64Encode(input);
        output = output.replace('+','-').replace('/','_');
        while(output.endsWith('=')){
            output = output.substring(0,output.length()-1);
        }
        return output;
    }

    // --------------------------------------------------
    // Helper: Create Valid JOSE With Signature
    // --------------------------------------------------
    private static String createSignedJose(String payloadJson){

        String headerJson = '{"alg":"HS256"}';

        String encodedHeader = base64UrlEncode(Blob.valueOf(headerJson));
        String encodedBody   = base64UrlEncode(Blob.valueOf(payloadJson));

        String headerPayload = encodedHeader + '.' + encodedBody;

        Blob mac = Crypto.generateMac(
            'HmacSHA256',
            Blob.valueOf(headerPayload),
            Blob.valueOf(System.label.Billdesk_Secret_Key)
        );

        String signature = base64UrlEncode(mac);

        return headerPayload + '.' + signature;
    }

    // --------------------------------------------------
    // Setup REST Context
    // --------------------------------------------------
    private static void setupContext(String joseBody){

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/BillDeskSplitPayment';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(joseBody);

        RestContext.request = req;
        RestContext.response = new RestResponse();
    }

    // ==================================================
    // 1️⃣ SUCCESS FLOW
    // ==================================================
    @IsTest
    static void testSuccessWebhook(){
         Payment_Transaction__c payment = new Payment_Transaction__c(
            Order_Id__c = 'ORD900',
            Merchant_Id__c = 'RNLSPLTUAT',
            Status__c = 'INITIATED'
        );
        insert payment;

        String payload = JSON.serialize(new Map<String,Object>{
            'orderid' => 'ORD900',
            'auth_status' => '0300',
            'transactionid' => 'TXN900',
            'bank_ref_no' => 'BANK900',
            'transaction_date' => '2026-03-03T10:00:00+05:30'
        });

        String jose = createSignedJose(payload);

        setupContext(jose);

        Test.startTest();
        BillDeskSplitPaymentWebhookHandler.handleWebhook();
        Test.stopTest();

        
    }

    // ==================================================
    // 2️⃣ ERROR PAYLOAD FLOW
    // ==================================================
    @IsTest
    static void testErrorPayload(){
		 Payment_Transaction__c payment = new Payment_Transaction__c(
            Order_Id__c = 'ORD900',
            Merchant_Id__c = 'RNLSPLTUAT',
            Status__c = 'INITIATED'
        );
        insert payment;
        
        String payload = JSON.serialize(new Map<String,Object>{
            'error_type' => 'some_error',
            'message' => 'Invalid transaction'
        });

        String jose = createSignedJose(payload);

        setupContext(jose);

        Test.startTest();
        BillDeskSplitPaymentWebhookHandler.handleWebhook();
        Test.stopTest();

    }

    // ==================================================
    // 3️⃣ INVALID SIGNATURE (Catch Block)
    // ==================================================
    @IsTest
    static void testInvalidSignature(){

        // Wrong signature intentionally
        String payload = JSON.serialize(new Map<String,Object>{
            'orderid' => 'ORD901',
            'auth_status' => '0300'
        });

        String header = base64UrlEncode(Blob.valueOf('{"alg":"HS256"}'));
        String body   = base64UrlEncode(Blob.valueOf(payload));

        String fakeJose = header + '.' + body + '.invalidsignature';

        setupContext(fakeJose);

        Test.startTest();
        BillDeskSplitPaymentWebhookHandler.handleWebhook();
        Test.stopTest();

    }

    // ==================================================
    // 4️⃣ EMPTY PAYLOAD (Catch Block)
    // ==================================================
    @IsTest
    static void testEmptyPayload(){

        setupContext('');

        Test.startTest();
        BillDeskSplitPaymentWebhookHandler.handleWebhook();
        Test.stopTest();

    }
}