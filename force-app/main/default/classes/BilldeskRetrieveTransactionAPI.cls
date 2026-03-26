global with sharing class BilldeskRetrieveTransactionAPI implements Database.Batchable<SObject>, Database.AllowsCallouts {

    global Database.QueryLocator start(Database.BatchableContext bc) {

        return Database.getQueryLocator([
            SELECT Id,
                   Order_Id__c,
                   Merchant_Id__c,
                   Status__c,
                   Booking__c
            FROM Payment_Transaction__c
            WHERE Status__c IN ('INITIATED','PENDING')
            AND Order_Id__c != NULL
        ]);
    }

    global void execute(Database.BatchableContext bc, List<Payment_Transaction__c> scope) {

        List<Payment_Transaction__c> updates = new List<Payment_Transaction__c>();
        List<ERP_Integration_Log__c> logList = new List<ERP_Integration_Log__c>();

        Map<String, Payment_Gateway__mdt> gatewayMap = getGatewayMap(scope);

        for (Payment_Transaction__c payment : scope) {
            String requestPayload;
            String rawJoseResponse;
            String decodedResponse;
            
            try {   
                Payment_Gateway__mdt gateway = gatewayMap.get(payment.Merchant_Id__c);

                if(gateway == null){
                    payment.Status__c = 'FAILED';
                    payment.Error_Desc__c = 'BillDesk metadata configuration missing';
                    updates.add(payment);
                    continue;
                }
                
                // ==============================
                // 🔹 Call Common Service
                // ==============================
                BillDeskCommonService.ResponseWrapper resWrap =
                    BillDeskCommonService.hitRetrieveAPI(
                        payment.Order_Id__c,
                        payment.Merchant_Id__c,
                        gateway.Client_Id__c,
                        gateway.Secret_Key__c
                    );

                rawJoseResponse = resWrap.rawResponse;
                decodedResponse = resWrap.decodedResponse;

                HttpResponse res = new HttpResponse();
                res.setStatusCode(resWrap.statusCode);
	
                payment.Retrieve_API_Response__c = decodedResponse;

                Map<String,Object> responseMap = (Map<String,Object>) JSON.deserializeUntyped(decodedResponse);

                String errorType  = getValue(responseMap,'transaction_error_type','error_type');
                String errorDesc  = getValue(responseMap,'transaction_error_desc','message');
                String errorCode  = getValue(responseMap,'transaction_error_code','error_code');

                String statusValue = responseMap.containsKey('status')
                    ? String.valueOf(responseMap.get('status'))
                    : null;

                if (res.getStatusCode() == 200) {
                    // 🔥 Update core fields
                    payment.Transaction_Id__c = (String) responseMap.get('transactionid');

                    payment.Bank_Ref_No__c = (String) responseMap.get('bank_ref_no');

                    payment.Auth_Status__c = (String) responseMap.get('auth_status') + ' ' + res.getStatusCode();

                    payment.Retrieve_API_Code__c = (String) responseMap.get('transaction_error_code');

                    payment.Retrieve_API_Desc__c = (String) responseMap.get('transaction_error_desc');

                    payment.Retrieve_API_Type__c = (String) responseMap.get('transaction_error_type');

                    // 🔥 Transaction Date
                    if (responseMap.containsKey('transaction_date')) {
                        payment.Transaction_Date__c =
                            Datetime.valueOf(
                                ((String)responseMap.get('transaction_date'))
                                    .replace('T',' ')
                                    .substring(0,19)
                            );
                    }

                    payment.Status__c = resolveStatus(errorType);
                    payment.Retrieve_API_Status__c = errorType;
                } else{

                    payment.Error_Status__c = statusValue;

					payment.Error_Code__c = errorCode;

                    payment.Error_Desc__c = errorDesc + ' ' + 'HTTP Error: ' + res.getStatusCode();

                    payment.Error_Type__c = errorType;

					//String errorType = (String) responseMap.get('transaction_error_type');
                    payment.Status__c = resolveStatus(errorType);
                    payment.Error_Status__c = errorType;

                } 
                logList.add(new ERP_Integration_Log__c(
                    API_Name__c = 'BilldeskRetrieveTransactionAPI',
                    StatusTxt__c= 'execute' + 'BillDesk Retrieve API' + ' ' + String.valueOf(responseMap.get('status')),
                    Booking__c = payment.Booking__c,
                    External_Id__c = payment.Order_Id__c,
                    Request__c= requestPayload,
                    Response__c= decodedResponse,
                    Status__c= errorType,
                    Error_Type__c= errorType,
                    Error_Reason__c= errorDesc + ' ' +  'HTTP Error: ' + ' ' + res.getStatusCode() + ' ' + errorCode
                ));

                updates.add(payment);

            } catch (Exception e) {

                payment.Status__c = 'FAILED';
                payment.Error_Desc__c = e.getMessage();
                payment.Error_Status__c = 'System Exception';
                updates.add(payment);

                logList.add(new ERP_Integration_Log__c(
                    API_Name__c = 'BilldeskRetrieveTransactionAPI',
                    StatusTxt__c= 'execute catch' + ' ' + 'BillDesk Retrieve API',
                    Booking__c = payment.Booking__c,
                    External_Id__c = payment.Order_Id__c,
                    Request__c= requestPayload,
                    Response__c= decodedResponse,
                    Status__c= 'FAILED',
                    Error_Reason__c = e.getMessage()
                ));
            }
        }

        if (!updates.isEmpty()) {
            update updates;
        }

        if (!logList.isEmpty()) {
            insert logList;
        }
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('BillDesk Retrieve Batch Completed');
    }

    //====================================================
    // Helper Method: Get Value with Fallback
    //====================================================

    private static String getValue(
        Map<String,Object> responseMap,
        String primaryKey,
        String fallbackKey){

        if(responseMap.containsKey(primaryKey) &&
           responseMap.get(primaryKey) != null){

            return String.valueOf(responseMap.get(primaryKey));
        }

        if(responseMap.containsKey(fallbackKey) &&
           responseMap.get(fallbackKey) != null){

            return String.valueOf(responseMap.get(fallbackKey));
        }

        return null;
    }

    //====================================================
    // Helper Method: Resolve Status
    //====================================================

    private static String resolveStatus(String errorType){
        system.debug('errorType------------------------>'+errorType);
        if(errorType == null) return 'PENDING';

        errorType = errorType.toLowerCase();

        if(errorType.contains('success'))
            return 'SUCCESSFUL';

        if(errorType.contains('failure'))
            return 'FAILED';

        if(errorType.contains('pending'))
            return 'PENDING';

        if(errorType.contains('cancel'))
            return 'CANCELLED';

        return 'PENDING';
    }

    private static Map<String, Payment_Gateway__mdt> getGatewayMap(List<Payment_Transaction__c> scope){

        Set<String> merchantIds = new Set<String>();

        for (Payment_Transaction__c payment : scope) {
            if (payment.Merchant_Id__c != null) {
                merchantIds.add(payment.Merchant_Id__c);
            }
        }

        Map<String, Payment_Gateway__mdt> gatewayMap = new Map<String, Payment_Gateway__mdt>();

        if (!merchantIds.isEmpty()) {

            for (Payment_Gateway__mdt gatewayRec : [
                SELECT Parent_Merchant_Id__c, Client_Id__c,Secret_Key__c
                FROM Payment_Gateway__mdt
                WHERE Parent_Merchant_Id__c IN :merchantIds
            ]) { 

                gatewayMap.put(gatewayRec.Parent_Merchant_Id__c, gatewayRec);
            }
        }

        return gatewayMap;
    }
}