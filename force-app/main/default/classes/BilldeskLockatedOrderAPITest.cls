@IsTest
public class BilldeskLockatedOrderAPITest {

    // ==========================================
    // SUCCESS TEST
    // ==========================================
    @IsTest
    static void testCreateOrderSuccess(){

        Test.setMock(HttpCalloutMock.class, new SuccessMock());

        Test.startTest();
        BilldeskLockatedOrderAPI.ResponseBody resp =
            BilldeskLockatedOrderAPI.createBilldeskOrder('ORD111', 100);
        Test.stopTest();

    }

    // ==========================================
    // ERROR TEST
    // ==========================================
    @IsTest
    static void testCreateOrderError(){

        Test.setMock(HttpCalloutMock.class, new ErrorMock());

        Boolean exceptionThrown = false;

        Test.startTest();
        try{
            BilldeskLockatedOrderAPI.createBilldeskOrder('ORD222', 200);
        }catch(Exception e){
            exceptionThrown = true;
        }
        Test.stopTest();

    }

    // =========================================================
    // 🔹 MOCK CLASSES (INSIDE SAME TEST CLASS)
    // =========================================================

    private class SuccessMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req){

            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type','application/jose');

            String jsonResponse = JSON.serialize(new Map<String,Object>{
                'objectid' => 'order',
                'orderid' => 'ORD111',
                'bdorderid' => 'BD111',
                'mercid' => 'RNLSPLTUAT',
                'order_date' => '2026-03-03T10:00:00+05:30',
                'amount' => '100.00',
                'ru' => 'https://example.com',
                'itemcode' => 'DIRECT',
                'createdon' => '2026-03-03',
                'next_step' => 'redirect',
                'additional_info' => new Map<String,Object>(),
                'links' => new List<Object>{
                    new Map<String,Object>{
                        'href' => 'self',
                        'rel' => 'self',
                        'method' => 'GET'
                    },
                    new Map<String,Object>{
                        'href' => 'redirect',
                        'rel' => 'redirect',
                        'method' => 'POST',
                        'parameters' => new Map<String,Object>{
                            'mercid' => 'RNLSPLTUAT',
                            'bdorderid' => 'BD111',
                            'rdata' => 'rdataValue'
                        },
                        'valid_date' => '2026-03-03',
                        'headers' => new Map<String,Object>{
                            'authorization' => 'Bearer token'
                        }
                    }
                }
            });

            String header = EncodingUtil.base64Encode(Blob.valueOf('{"alg":"HS256"}'));
            String body   = EncodingUtil.base64Encode(Blob.valueOf(jsonResponse));

            res.setBody(header + '.' + body + '.signature');

            return res;
        }
    }

    private class ErrorMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req){

            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('Server Error');
            return res;
        }
    }
}