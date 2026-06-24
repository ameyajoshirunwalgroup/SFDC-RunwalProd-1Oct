@RestResource(urlMapping='/BillDeskSplitPayment')
global without sharing class BillDeskSplitPaymentWebhookHandler {

    @HttpPost
    global static void handleWebhook() {

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');

        String rawBody = '';
        String decodedJson = '';
        String orderId;
        String status;
        String errorMsg;
        System.debug('========== BILLDESK WEBHOOK START ==========');

        try {
            //Read raw JOSE payload
            rawBody = req.requestBody != null ? req.requestBody.toString() : '';
            System.debug('🔔 BillDesk Webhook RAW => ' + rawBody);

            if (String.isBlank(rawBody)) {
                throw new CalloutException('Empty webhook payload');
            }

            // Decode JOSE payload
            decodedJson = decodeJosePayload(rawBody);
            System.debug('Decoded Payload => ' + decodedJson);

            if(String.isBlank(decodedJson)){
                throw new CalloutException('Decoded payload empty');
            }

            Map<String,Object> rawMap =
                (Map<String,Object>)JSON.deserializeUntyped(decodedJson);

            //If error response
            if(rawMap.containsKey('error_type')){
                System.debug('Received Error Payload in Webhook');

                // logIntegration(
                //     'BillDesk Split Webhook ERROR',
                //     null,
                //     rawBody,
                //     decodedJson,
                //     'ERROR',
                //     (String)rawMap.get('message'),
                //     (String)rawMap.get('status')
                // );

                res.statusCode = 200;
                res.responseBody = Blob.valueOf(decodedJson);
                return;
            }

            //Deserialize JSON 
            BillDeskWebhookPayload payload =
                (BillDeskWebhookPayload) JSON.deserialize(decodedJson, BillDeskWebhookPayload.class);

            orderId = payload.orderid;

             // Verify signature
            if(orderId!=null){
                // Fetch secret key from metadata
                String secretKey = getSecretKey(orderId);
                if(!String.isBlank(secretKey)){
                    verifyJoseSignature(rawBody,secretKey);
                    System.debug('Signature Verified Successfully');
                }    
            }

            //Map Status
            status = mapStatus(payload.auth_status);
             System.debug('Mapped Status => ' + status);

             updatePaymentRecord(
                payload.orderid,
                status,
                payload.transactionid,
                payload.bank_ref_no,
                payload.auth_status,
                decodedJson,
                payload.transaction_date,
                payload.transaction_error_type,
                payload.transaction_error_code,
                payload.transaction_error_desc
            );

            //LOG WEBHOOK
            ERPIntegrationLogger.log(
                'BillDeskSplitPaymentWebhookHandler',
                'handleWebhook',
                'BillDesk Webhook',
                null,
                orderId,
                rawBody,
                decodedJson,
                status,
                null,
                null
            );

            //ACK to BillDesk
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(decodedJson);
            System.debug('Webhook Processed Successfully');
            System.debug('HTTP Response Code => 200');
            System.debug('========== BILLDESK WEBHOOK END SUCCESS ==========');

        } catch (Exception e) {

             errorMsg =
                'Type: ' + e.getTypeName() +
                ' | Message: ' + e.getMessage() +
                ' | Line: ' + e.getLineNumber() +
                ' | StackTrace: ' + e.getStackTraceString();

            System.debug('❌ BILLDESK WEBHOOK ERROR');
            System.debug(errorMsg);

            ERPIntegrationLogger.log(
                'BillDeskSplitPaymentWebhookHandler',
                'handleWebhook',
                'BillDesk Webhook',
                null,
                orderId,
                rawBody,
                decodedJson,
                'FAIL',
                'SYSTEM_EXCEPTION',
                errorMsg
            );


            res.statusCode = 500;
            res.responseBody = Blob.valueOf(
                JSON.serialize(new Map<String,Object>{
                    'status' => 'FAIL',
                    'message' => errorMsg
                })
            );
            System.debug('========== BILLDESK WEBHOOK END FAILURE ==========');
        }
    }

    // =========================
    // 🔐 VERIFY JOSE SIGNATURE
    // =========================
    private static void verifyJoseSignature(String jose, String secretKey) {

        List<String> parts = jose.split('\\.');
        if (parts.size() != 3)
            throw new CalloutException('Invalid JOSE structure');

        String headerPayload = parts[0] + '.' + parts[1];
        String receivedSignature = parts[2];

        Blob mac = Crypto.generateMac(
            'HmacSHA256',
            Blob.valueOf(headerPayload),
            Blob.valueOf(secretKey)
        );

        String expectedSignature = base64URLencode(mac);

        if (expectedSignature != receivedSignature)
            throw new CalloutException('Invalid BillDesk signature');
    }

    // =========================
    // 🔓 DECODE JOSE PAYLOAD
    // =========================
    private static String decodeJosePayload(String jose) {

    Integer firstDot  = jose.indexOf('.');
    Integer secondDot = jose.lastIndexOf('.');

    if (firstDot <= 0 || secondDot <= 0)
        throw new CalloutException('Invalid JOSE payload');

    String payload = jose.substring(firstDot + 1, secondDot);

    return decodeBase64Url(payload);
}

    // =========================
    // 📌 MAP BILLDESK STATUS
    // =========================
    private static String mapStatus(String authStatus) {

        if (authStatus == '0300') return 'SUCCESSFUL';
        if (authStatus == '0399') return 'FAILED';
        if (authStatus == '0002') return 'PENDING';
        return 'CANCELLED';
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
        String errorMsg,
        Integer httpStatus
    ) {
        try {
            ERP_Integration_Log__c log = new ERP_Integration_Log__c();
            log.API_Name__c     = apiName;
            log.External_Id__c  = orderId;
            log.Request__c      = requestBody;
            log.Response__c     = responseBody;
            log.Status__c       = status;
            log.Error_Reason__c = errorMsg + ' | HTTP_CODE: ' + httpStatus;
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

    private static String decodeBase64Url(String value){

    if(String.isBlank(value)) return null;

    value = value.replace('-', '+').replace('_', '/');

    Integer remainder = Math.mod(value.length(), 4);
    while(remainder != 0){
        value += '=';
        remainder = Math.mod(value.length(), 4);
    }

    return EncodingUtil.base64Decode(value).toString();
}

    // =========================
    // 📦 UPDATED WEBHOOK PAYLOAD WRAPPER
    // =========================
     global class BillDeskWebhookPayload {

        public String objectid;
        public String transactionid;
        public String orderid;
        public String mercid;
        public String amount;
        public String currency_code;

        public String auth_status;
        public String payment_method_type;
        public String transaction_error_code;
        public String transaction_error_desc;
        public String transaction_error_type;

        public String transaction_date;
        public String bank_ref_no;
        public String charge_amount;

        public String surcharge;
        public String discount;
        public String payment_category;
        public String txn_process_type;
        public String bankid;

        public List<SplitPayment> split_payment;

        
    }
    global class SplitPayment {
        public String mercid;
        public String amount;
    }

    public static void updatePaymentRecord( String orderId, String status, String txnId, String bankRef, String authStatus, String rawResponse , String transactionDate ,String errorCode, String errorType, String errorDesc ){
        try{
            if(String.isBlank(orderId)){
                System.debug('OrderId is blank. Skipping update.');
                return;
            }
            Payment_Transaction__c payment = new Payment_Transaction__c(
                Order_Id__c = orderId,
                Status__c = status,
                Transaction_Id__c = txnId,
                Bank_Ref_No__c = bankRef,
                Auth_Status__c = authStatus,
                Transaction_Date__c = parseBillDeskDate(transactionDate),
                Raw_Response__c = rawResponse
            );
            if(authStatus != '0300'){
                payment.Error_Code__c = errorCode;
                payment.Error_Type__c = errorType;
                payment.Error_Desc__c = errorDesc;
            }

            upsert payment Order_Id__c;

        }catch(Exception e){
            System.debug('Payment Update Error: ' + e.getMessage());
        }
    }

    private static Datetime parseBillDeskDate(String input){

    if(String.isBlank(input)) return null;

        // Remove timezone (+05:30) because Datetime.valueOf does not accept it
        if(input.contains('+')){
            input = input.substring(0, input.indexOf('+'));
        }

        return Datetime.valueOf(input.replace('T', ' '));
    }

    private static String getSecretKey(String orderId){
        if(String.isBlank(orderId)){
            return null;
        }

        List<Payment_Transaction__c> paymentList = [
            SELECT Merchant_Id__c
            FROM Payment_Transaction__c
            WHERE Order_Id__c = :orderId
            LIMIT 1
        ];

        if(paymentList.isEmpty()){
            return null;
        }

        List<Payment_Gateway__mdt> gatewayList = [
            SELECT Secret_Key__c
            FROM Payment_Gateway__mdt
            WHERE Parent_Merchant_Id__c = :paymentList[0].Merchant_Id__c
            LIMIT 1
        ];

        if(gatewayList.isEmpty()){
            return null;
        }

        return gatewayList[0].Secret_Key__c;
    }
}