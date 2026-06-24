public with sharing class BillDeskCommonService {

    /**
     * Wrapper class to standardize response
     */
    public class ResponseWrapper {
        public Integer statusCode;
        public String rawResponse;
        public String decodedResponse;
        public String errorMessage;
    }

    /**
     * Common method to hit BillDesk Retrieve API
     */
    public static ResponseWrapper hitRetrieveAPI(
        String orderId,
        String merchantId,
        String clientId,
        String secretKey
    ) {
        ResponseWrapper resWrap = new ResponseWrapper();

        String rawResponse;
        String decodedResponse;

        try {
            // ==============================
            // 🔹 Input Validations
            // ==============================
            if (String.isBlank(orderId) || String.isBlank(merchantId)) {
                throw new AuraHandledException('OrderId or MerchantId is missing');
            }

            if (String.isBlank(clientId) || String.isBlank(secretKey)) {
                throw new AuraHandledException('ClientId or SecretKey is missing');
            }

            // ==============================
            // 🔹 Header Creation
            // ==============================
            String headerJson = JSON.serialize(new Map<String,Object>{
                'alg' => 'HS256',
                'clientid' => clientId
            });

            // ==============================
            // 🔹 Payload Creation
            // ==============================
            String payload = JSON.serialize(new Map<String,Object>{
                'mercid' => merchantId,
                'orderid' => orderId,
                'refund_details' => 'true'
            });

            // ==============================
            // 🔹 JWT Generation
            // ==============================
            String jwt = BilldeskLockatedOrderAPI.generateJWT(
                headerJson, payload, secretKey
            );

            // ==============================
            // 🔹 HTTP Request Setup
            // ==============================
            HttpRequest req = new HttpRequest();
            req.setEndpoint(System.label.BillDesk_Retrieve_Transaction_API_Endpoint);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/jose');
            req.setHeader('Accept', 'application/jose');
            req.setHeader('BD-Timestamp', System.now().format('yyyyMMddHHmmss'));
            req.setHeader('BD-Traceid', orderId + '_' + System.currentTimeMillis());
            req.setBody(jwt);

            // ==============================
            // 🔹 Callout Execution
            // ==============================
            HttpResponse response = new Http().send(req);

            resWrap.statusCode = response.getStatusCode();
            rawResponse = response.getBody();
            resWrap.rawResponse = rawResponse;

            // ==============================
            // 🔹 Decode Response
            // ==============================
            if (!String.isBlank(rawResponse)) {
                decodedResponse = BilldeskLockatedOrderAPI.decodeJose(rawResponse);
                resWrap.decodedResponse = decodedResponse;
            } else {
                resWrap.decodedResponse = null;
            }

            // ==============================
            // 🔹 ERP SUCCESS LOG
            // ==============================
            ERPIntegrationLogger.log(
                'BillDeskCommonService',
                'hitRetrieveAPI',
                'BillDesk Retrieve API',
                null,
                orderId,
                orderId,
                decodedResponse,
                'SUCCESS',
                null,
                null
            );

        } catch (Exception e) {

            resWrap.statusCode = 500;
            resWrap.errorMessage = e.getMessage();

            // ==============================
            // 🔹 ERP ERROR LOG
            // ==============================
            ERPIntegrationLogger.log(
                'BillDeskCommonService',
                'hitRetrieveAPI',
                'BillDesk Retrieve API',
                null,
                orderId,
                orderId,
                rawResponse,
                'FAIL',
                'SYSTEM_EXCEPTION',
                e.getMessage()
            );
        }

        return resWrap;
    }
}