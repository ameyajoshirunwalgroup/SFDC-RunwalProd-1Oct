@IsTest
public class BillDeskReturnControllerTest {

    // ---------------------------------------
    // Helper – Base64URL Encode
    // ---------------------------------------
    private static String base64UrlEncode(String input){
        String output = EncodingUtil.base64Encode(Blob.valueOf(input));
        output = output.replace('+','-').replace('/','_');
        while(output.endsWith('=')){
            output = output.substring(0,output.length()-1);
        }
        return output;
    }

    // ---------------------------------------
    // Helper – Create Fake JOSE
    // ---------------------------------------
    private static String createJose(String payloadJson){

        String header = base64UrlEncode('{"alg":"HS256"}');
        String body   = base64UrlEncode(payloadJson);

        return header + '.' + body + '.dummySignature';
    }

    // ---------------------------------------
    // Setup REST Context
    // ---------------------------------------
    private static void setupContext(Map<String,String> params){

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/paymentstatus';
        req.httpMethod = 'POST';

        for(String key : params.keySet()){
            req.addParameter(key, params.get(key));
        }

        RestContext.request = req;
        RestContext.response = new RestResponse();
    }

    // ==========================================
    // 1️⃣ SUCCESS FLOW (auth_status = 0300)
    // ==========================================
    @IsTest
    static void testSuccessFlow(){

        String payload = JSON.serialize(new Map<String,Object>{
            'auth_status' => '0300',
            'orderid' => 'ORD100',
            'amount' => '1000',
            'transactionid' => 'TXN100',
            'bank_ref_no' => 'BANK100'
        });

        String jose = createJose(payload);

        setupContext(new Map<String,String>{
            'transaction_response' => jose
        });

        Test.startTest();
        BillDeskReturnController.getPaymentStatus();
        Test.stopTest();

    }


    // ==========================================
    // 2️⃣ FAILED FLOW (auth_status = 0399)
    // ==========================================
    @IsTest
    static void testFailedFlow(){

        String payload = JSON.serialize(new Map<String,Object>{
            'auth_status' => '0399',
            'orderid' => 'ORD200',
            'amount' => '500'
        });

        String jose = createJose(payload);

        setupContext(new Map<String,String>{
            'transaction_response' => jose
        });

        Test.startTest();
        BillDeskReturnController.getPaymentStatus();
        Test.stopTest();

    }


    // ==========================================
    // 3️⃣ ERROR TYPE FLOW
    // ==========================================
    @IsTest
    static void testErrorTypeFlow(){

        setupContext(new Map<String,String>{
            'orderId' => 'ORD300',
            'error_type' => 'some_error',
            'error_code' => 'E001',
            'message' => 'Payment failed',
            'status' => 'FAIL'
        });

        Test.startTest();
        BillDeskReturnController.getPaymentStatus();
        Test.stopTest();


    }


    // ==========================================
    // 4️⃣ NO DATA RECEIVED (PENDING)
    // ==========================================
    @IsTest
    static void testPendingWhenNoParams(){

        setupContext(new Map<String,String>{
            'orderId' => 'ORD400'
        });

        Test.startTest();
        BillDeskReturnController.getPaymentStatus();
        Test.stopTest();

    }


    // ==========================================
    // 5️⃣ CATCH BLOCK COVERAGE
    // ==========================================
    @IsTest
    static void testCatchBlock(){

        // Force invalid JOSE format
        setupContext(new Map<String,String>{
            'transaction_response' => 'invalid.token.format'
        });

        Test.startTest();
        BillDeskReturnController.getPaymentStatus();
        Test.stopTest();

    }
}