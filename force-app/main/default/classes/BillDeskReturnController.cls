// public class BillDeskReturnController {
    
//     public String status   { get; set; }
//     public String orderId  { get; set; }
//     public String amount   { get; set; }
//     public String txnId    { get; set; }
//     public String bankRef  { get; set; }
    
//     public BillDeskReturnController() {
        
//         String msg = ApexPages.currentPage().getParameters().get('transaction_response');
//         System.debug('RAW MSG => ' + msg);
        
//         try {
            

//             // DECODE JOSE TOKEN (same as webhook)
//             String decodedJson = decodeJosePayload(msg);
//             System.debug('Decoded MSG => ' + decodedJson);

//             // Parse JSON
//             Map<String, Object> responseMap = 
//                 (Map<String, Object>) JSON.deserializeUntyped(decodedJson);  

//             String authStatus = (String) responseMap.get('auth_status');
//             orderId           = (String) responseMap.get('orderid');
//             amount            = (String) responseMap.get('amount');
//             txnId             = (String) responseMap.get('transactionid');
//             bankRef           = (String) responseMap.get('bank_ref_no');

//             System.debug('Auth Status => ' + authStatus);

//             if (authStatus == '0300') {
//                 status = 'SUCCESS';
//             } else if (authStatus == '0399') {
//                 status = 'PENDING';
//             } else if (authStatus == '0002') {
//                 status = 'CANCELLED';
//             } else {
//                 status = 'FAILURE';
//             }
            
//         } catch(Exception e) {
//             status = 'FAILURE';
//             System.debug('BillDeskReturn Error => ' + e.getMessage());
//         }
//     }

//     // DECODE JOSE — Same as Webhook Handler
//     private String decodeJosePayload(String jose) {
//         Integer firstDot  = jose.indexOf('.');
//         Integer secondDot = jose.lastIndexOf('.');

//         if(firstDot == -1 || secondDot == -1)
//             throw new CalloutException('Invalid JOSE payload');

//         String payload = jose.substring(firstDot + 1, secondDot);
//         return EncodingUtil.base64Decode(payload).toString();
//     }
// }

@RestResource(urlMapping='/paymentstatus')
global class BillDeskReturnController {
    
    @HttpPost
    global static void getPaymentStatus() {
        
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        
        Map<String, Object> result = new Map<String, Object>();
        String transactionResponse;
        String decodedJson;
        String orderId;
        
        try {
            RestRequest req = RestContext.request;

            // Get transaction_response from params
            transactionResponse = req.params.get('transaction_response');
            String orderIdParam = req.params.get('orderId'); 

            System.debug('RAW => ' + transactionResponse);
            System.debug('orderIdParam => ' + orderIdParam);

            // CASE 1 — SUCCESS / FAILURE RESPONSE
            if(String.isNotBlank(transactionResponse)){
                // Decode JOSE
                decodedJson = decodeJosePayload(transactionResponse);
                System.debug('Decoded JSON => ' + decodedJson);

                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(decodedJson);

                String authStatus = (String) responseMap.get('auth_status');
                orderId           = (String) responseMap.get('orderid');
                String amount     = (String) responseMap.get('amount');
                String txnId      = (String) responseMap.get('transactionid');
                String bankRef    = (String) responseMap.get('bank_ref_no');

                String status;
                if      (authStatus == '0300') status = 'SUCCESSFUL';
                else if (authStatus == '0399') status = 'FAILED';
                else if (authStatus == '0002') status = 'PENDING';
                else                           status = 'CANCELLED';

                // updatePaymentRecord(
                //     orderId,
                //     status,
                //     txnId,
                //     bankRef,
                //     authStatus,
                //     decodedJson
                // );

                // =============================
                // ERP LOG
                // =============================
                // logERP(
                //     'BillDesk Return',
                //     transactionResponse,
                //     decodedJson,
                //     status,
                //     null,
                //     orderId
                // );


                result.put('status', status);
                result.put('orderId', orderId);
                result.put('amount', amount);
                result.put('transactionId', txnId);
                result.put('bankRefNo', bankRef);
                result.put('message', status == 'SUCCESSFUL' ? 
                        'Payment Successful' : 'Payment Failed');

                res.statusCode = 200;
                res.responseBody = Blob.valueOf(JSON.serialize(result));
                return;
            }
            
            // CASE 2 — ERROR RESPONSE (NO transaction_response)
            if(String.isBlank(transactionResponse)) {

                String errorType    = req.params.get('error_type');
                String errorCode    = req.params.get('error_code');
                String errorMessage = req.params.get('message');
                String encryptedRes = req.params.get('encrypted_response');
                String status = req.params.get('status');

                System.debug('errorType => ' + errorType);

                if(String.isNotBlank(errorType)){
                    String finalStatus = 'PENDING';

                    if(errorType != 'duplicate_request_error'){
                        finalStatus = 'FAILED';
                    }

                    if(String.isNotBlank(encryptedRes)) {
                        try {
                            decodedJson = decodeJosePayload(encryptedRes);
                        } catch(Exception ex) {
                            decodedJson = encryptedRes;
                        }
                        system.debug('decodedJson------------>newwww'+decodedJson);
                    }

                    updatePaymentRecord(
                        orderIdParam,
                        finalStatus,
                        null,
                        null,
                        null,
                        errorCode,  
                        decodedJson,
                        errorType,
                        status,
                        errorMessage //Error_Desc__c
                    );

                    ERPIntegrationLogger.log(
                        'BillDeskReturnController',
                        'getPaymentStatus',
                        'BillDesk Return',
                        null,
                        orderIdParam,
                        encryptedRes,
                        decodedJson,
                        finalStatus,
                        errorType,
                        errorMessage
                    );

                    result.put('status', finalStatus);
                    result.put('orderId', orderIdParam);
                    result.put('message', errorMessage);

                    res.statusCode = 200;
                    res.responseBody = Blob.valueOf(JSON.serialize(result));
                    return;
                }
                // CASE 3 — NO DATA RECEIVED (No error and no transaction_response) 
                
                System.debug('res.responseBody111 --------> ' + JSON.serialize(result));
                result.put('status', 'PENDING');
                result.put('orderId', orderIdParam);
                result.put('message', 'Payment status not received. Please check back later');
                //logERP('BillDesk Return - Empty', null, null, 'PENDING', 'No transaction_response param', null);
                res.statusCode = 200;
                res.responseBody = Blob.valueOf(JSON.serialize(result));
                System.debug('res.responseBody222 --------> ' + JSON.serialize(result));
                return;
            }
            

        } catch(Exception e) {
            String errorDetails =
                'Type: ' + e.getTypeName() +
                ' | Message: ' + e.getMessage() +
                ' | Line: ' + e.getLineNumber();

            ERPIntegrationLogger.log(
                'BillDeskReturnController',
                'getPaymentStatus',
                'BillDesk Return',
                null,
                orderId,
                transactionResponse,
                null,
                'FAIL',
                'SYSTEM_EXCEPTION',
                errorDetails
            );
            result.put('status', 'FAILURE');
            result.put('message', e.getMessage());
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(JSON.serialize(result));
            System.debug('Error => ' + e.getMessage());
        }
    }

    // =====================================================
// JOSE BASE64URL DECODE METHOD
// =====================================================
    private static String decodeJosePayload(String transactionResponse) {

        if(String.isBlank(transactionResponse)) {
            throw new AuraHandledException('Transaction response is empty');
        }

        Integer firstDot  = transactionResponse.indexOf('.');
        Integer secondDot = transactionResponse.lastIndexOf('.');

        if(firstDot <= 0 || secondDot <= 0) {
            throw new AuraHandledException('Invalid JOSE format received');
        }

        String payload = transactionResponse.substring(firstDot + 1, secondDot);

        // Convert Base64URL → Base64
        payload = payload.replace('-', '+').replace('_', '/');

        // Add padding if missing
        // Fix padding safely
            Integer remainder = Math.mod(payload.length(), 4);
            while(remainder != 0) {
                payload += '=';
                remainder = Math.mod(payload.length(), 4);
            }

        return EncodingUtil.base64Decode(payload).toString();
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

    public static void updatePaymentRecord( String orderId, String status, String txnId, String bankRef, String authStatus,String errorCode,String rawResponse,String errorType, String Errorstatus, String errorMessage){
        try{
            Payment_Transaction__c payment = new Payment_Transaction__c(
                Order_Id__c = orderId,
                Status__c = status,
                Transaction_Id__c = txnId,
                Bank_Ref_No__c = bankRef,
                Auth_Status__c = authStatus,
                Transaction_Date__c = System.now(),
                Raw_Response__c = rawResponse,
                Error_Code__c =  errorCode,
                Error_Type__c = errorType,
                Error_Status__c = Errorstatus,
                Error_Desc__c = errorMessage
            );

            upsert payment Order_Id__c;

        }catch(Exception e){
            System.debug('Payment Update Error: ' + e.getMessage());
        }
    }

}