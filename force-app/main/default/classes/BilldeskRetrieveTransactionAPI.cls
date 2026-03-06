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

        for (Payment_Transaction__c payment : scope) {
            String requestPayload;
            String rawJoseResponse;
            String decodedResponse;
            
            try {   
                // 🔹 Step 1 – Header
                String headerJson =
                    '{"alg":"HS256","clientid":"rreplmuat"}';   //for uat

                // 🔹 Step 2 – Payload
                requestPayload = JSON.serialize(new Map<String,Object>{
                    'mercid'         => payment.Merchant_Id__c,
                    'orderid'        => payment.Order_Id__c,
                    'refund_details' => 'true'
                });

                // 🔹 Step 3 – Generate JWT
                String jwtToken =
                    BilldeskLockatedOrderAPI.generateJWT(headerJson, requestPayload);

                // 🔹 Step 4 – Prepare headers
                String timestamp =
                    System.now().format('yyyyMMddHHmmss');

                String traceId =
                    payment.Order_Id__c + '_' +
                    String.valueOf(System.currentTimeMillis());

                HttpRequest req = new HttpRequest();
                req.setEndpoint(System.label.BillDesk_Retrieve_Transaction_API_Endpoint);
                req.setMethod('POST');

                req.setHeader('Content-Type', 'application/jose');
                req.setHeader('Accept', 'application/jose');
                req.setHeader('BD-Timestamp', timestamp);
                req.setHeader('BD-Traceid', traceId);
                //req.setHeader('Authorization', 'Bearer ' + jwtToken);
                req.setBody(jwtToken);

                Http http = new Http();
                HttpResponse res = http.send(req);

                // 🔹 Store raw JOSE always
                rawJoseResponse = res.getBody();
				decodedResponse = BilldeskLockatedOrderAPI.decodeJose(rawJoseResponse);
	
                payment.Retrieve_API_Response__c = decodedResponse;

                Map<String,Object> responseMap = (Map<String,Object>) JSON.deserializeUntyped(decodedResponse);

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

                    // 🔥 Final Status Logic
                    String errorType = (String) responseMap.get('transaction_error_type');

                    if (errorType == 'success') {
                        payment.Status__c = 'SUCCESSFULL';
                        
                    } else if (errorType == 'failure'){
                        payment.Status__c = 'FAILED';
                        
                    }else if (errorType == 'PENDING') {
						payment.Status__c = 'PENDING';
						
					}
					else if (errorType == 'CANCELLED') {
						payment.Status__c = 'CANCELLED';
					}
					else{
						payment.Status__c = 'CANCELLED';
					}
                    payment.Retrieve_API_Status__c = errorType;
                } else{

                    // 🔥 Not found – keep INITIATED
                    payment.Error_Status__c = String.valueOf(responseMap.get('status'));

					payment.Error_Code__c = (String) responseMap.get('error_code');

                    payment.Error_Desc__c = (String) responseMap.get('message') + ' ' + 'HTTP Error: ' + res.getStatusCode();

                    payment.Error_Type__c = (String) responseMap.get('error_type');

					String errorType = (String) responseMap.get('transaction_error_type');

                    if (errorType == 'success') {
                        payment.Status__c = 'SUCCESSFULL';
                        
                    } else if (errorType == 'failure'){
                        payment.Status__c = 'FAILED';
                        
                    }else if (errorType == 'pending') {
						payment.Status__c = 'PENDING';
						
					}
					else if (errorType == 'cancel') {
						payment.Status__c = 'CANCELLED';
					}
					else{
						payment.Status__c = 'CANCELLED';
					}
                    payment.Error_Status__c = errorType;

                } 

                String errorType = responseMap.containsKey('transaction_error_type') &&
                   responseMap.get('transaction_error_type') != null
                    ? String.valueOf(responseMap.get('transaction_error_type'))
                    : String.valueOf(responseMap.get('error_type'));

                String errorDesc = responseMap.containsKey('transaction_error_desc') &&
                                responseMap.get('transaction_error_desc') != null
                    ? String.valueOf(responseMap.get('transaction_error_desc'))
                    : String.valueOf(responseMap.get('message'));

                String errorCode = responseMap.containsKey('transaction_error_code') &&
                                responseMap.get('transaction_error_code') != null
                    ? String.valueOf(responseMap.get('transaction_error_code'))
                    : String.valueOf(responseMap.get('error_code'));

                String statusValue = responseMap.containsKey('status')
                    ? String.valueOf(responseMap.get('status'))
                    : '';


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
}