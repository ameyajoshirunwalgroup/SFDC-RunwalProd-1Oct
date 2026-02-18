@RestResource(urlMapping='/billdesk/webhook')
global without sharing class BillDeskSplitPaymentWebhookHandler {

    @HttpPost
    global static void handleWebhook() {
        // insert new ERP_Integration_Log__c(
        //     API_Name__c = 'BillDesk',
        //     Status__c   = 'Success'
        // );

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');

        String rawBody = '';
        String decodedJson = '';
        String orderId;
        String status;
        String errorMsg;

        try {
            // 1️⃣ Read raw JOSE payload
            rawBody = req.requestBody != null ? req.requestBody.toString() : '';
            System.debug('🔔 BillDesk Webhook RAW => ' + rawBody);

            if (String.isBlank(rawBody)) {
                throw new CalloutException('Empty webhook payload');
            }

            // 2️⃣ OPTIONAL (Recommended): Verify signature
            //verifyJoseSignature(rawBody);

            // 3️⃣ Decode JOSE payload
            decodedJson = decodeJosePayload(rawBody);
            System.debug('✅ Decoded BillDesk Payload => ' + decodedJson);

            // 4️⃣ Deserialize JSON
            BillDeskWebhookPayload payload =
                (BillDeskWebhookPayload) JSON.deserialize(decodedJson, BillDeskWebhookPayload.class);

            orderId = payload.orderid;
            status  = mapStatus(payload.auth_status);

            // 5️⃣ LOG ONLY (NO UPDATE)
            logIntegration(
                'BillDesk',
                orderId,
                rawBody,
                decodedJson,
                status,
                payload.transaction_error_desc
            );

            // 6️⃣ ACK to BillDesk
            res.statusCode = 200;
            res.responseBody = Blob.valueOf('{"status":"ACK"}');

        } catch (Exception e) {

            errorMsg = e.getMessage();
            System.debug('❌ BillDesk Webhook Error => ' + errorMsg);

            logIntegration(
                'BillDesk',
                orderId,
                rawBody,
                decodedJson,
                'FAIL',
                errorMsg
            );

            res.statusCode = 500;
            res.responseBody = Blob.valueOf(
                JSON.serialize(new Map<String,Object>{
                    'status' => 'FAIL',
                    'message' => errorMsg
                })
            );
        }
    }

    // =========================
    // 🔐 VERIFY JOSE SIGNATURE
    // =========================
    private static void verifyJoseSignature(String jose) {

        List<String> parts = jose.split('\\.');
        if (parts.size() != 3) {
            throw new CalloutException('Invalid JOSE structure');
        }

        String headerPayload = parts[0] + '.' + parts[1];
        String receivedSignature = parts[2];

        Blob mac = Crypto.generateMac(
            'HmacSHA256',
            Blob.valueOf(headerPayload),
            Blob.valueOf(System.label.Billdesk_Secret_Key)
        );

        String expectedSignature = base64URLencode(mac);

        if (expectedSignature != receivedSignature) {
            throw new CalloutException('Invalid BillDesk signature');
        }
    }

    // =========================
    // 🔓 DECODE JOSE PAYLOAD
    // =========================
    private static String decodeJosePayload(String jose) {

        Integer firstDot  = jose.indexOf('.');
        Integer secondDot = jose.lastIndexOf('.');

        if (firstDot == -1 || secondDot == -1) {
            throw new CalloutException('Invalid JOSE payload');
        }

        String payload = jose.substring(firstDot + 1, secondDot);
        return EncodingUtil.base64Decode(payload).toString();
    }

    // =========================
    // 📌 MAP BILLDESK STATUS
    // =========================
    private static String mapStatus(String authStatus) {

        if (authStatus == '0300') return 'SUCCESS';
        if (authStatus == '0399') return 'PENDING';
        if (authStatus == '0002') return 'CANCELLED';
        return 'FAIL';
    }

    // =========================
    // 🧾 ERP INTEGRATION LOG
    // =========================
    private static void logIntegration(
        String apiName,
        String orderId,
        String requestBody,
        String responseBody,
        String status,
        String errorMsg
    ) {
        try {
            ERP_Integration_Log__c log = new ERP_Integration_Log__c();
            log.API_Name__c     = apiName;
            log.External_Id__c  = orderId;
            log.Request__c      = requestBody;   // RAW JOSE
            log.Response__c     = responseBody;  // DECODED JSON
            log.Status__c       = status;
            log.Error_Reason__c = errorMsg;
            insert log;
        } catch (Exception e) {
            System.debug('❌ ERP Log Error => ' + e.getMessage());
        }
    }

    // =========================
    // 🔑 BASE64 URL ENCODE
    // =========================
    private static String base64URLencode(Blob input) {
        String output = EncodingUtil.base64Encode(input);
        output = output.replace('+', '-').replace('/', '_');
        while (output.endsWith('=')) {
            output = output.substring(0, output.length() - 1);
        }
        return output;
    }

    // =========================
    // 📦 WEBHOOK PAYLOAD WRAPPER
    // =========================
    global class BillDeskWebhookPayload {
        public String objectid;
        public String transactionid;
        public String orderid;
        public String mercid;
        public String amount;
        public String currencyCode;
        public String auth_status;
        public String payment_method_type;
        public String transaction_error_code;
        public String transaction_error_desc;
        public String transaction_error_type;
    }
}