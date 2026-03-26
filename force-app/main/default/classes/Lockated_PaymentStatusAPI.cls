@RestResource(urlMapping='/paymentStatus')
global with sharing class Lockated_PaymentStatusAPI {

    @HttpGet
    global static void getPaymentStatus() {

        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');

        Map<String, Object> result = new Map<String, Object>(); 
		String orderId;
        String bdOrderId;
        String merchantId;

        try {

            orderId = RestContext.request.params.get('orderId');
			bdOrderId  = RestContext.request.params.get('bdOrderId');
            merchantId = RestContext.request.params.get('merchantId');

            if(String.isBlank(orderId)) {
                res.statusCode = 400;
                result.put('status', 'FAIL');
                result.put('message', 'orderId is required');
                res.responseBody = Blob.valueOf(JSON.serialize(result));
                return;
            }

            List<Payment_Transaction__c> payments = [
            SELECT Status__c,
                   Amount__c,
                   Transaction_Id__c,
                   Bank_Ref_No__c,
                   Booking__c
            FROM Payment_Transaction__c
            WHERE Order_Id__c = :orderId
            LIMIT 1
        ];

        if(payments.isEmpty()) {
            // 🔹 No record yet
            result.put('orderId', orderId);
            result.put('status', 'PENDING');
            result.put('message', 'Payment record not found yet');

            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(result));
            return;
        }

        Payment_Transaction__c payment = payments[0];
            system.debug('payment.Status__c----->'+payment.Status__c);
            if(payment.Status__c == 'INITIATED' || payment.Status__c == 'PENDING') {

                Map<String,Object> bdWrapper =
                    BillDeskStatusService.fetchFullResponse(orderId, merchantId);

                String decodedResponse = (String) bdWrapper.get('decodedResponse');

                Integer statusCode = (Integer) bdWrapper.get('statusCode');
                Map<String,Object> bdResponse =
                    (Map<String,Object>) bdWrapper.get('body');

                String errorType  = getValue(bdResponse,'transaction_error_type','error_type');
                String errorDesc  = getValue(bdResponse,'transaction_error_desc','message');
                String errorCode  = getValue(bdResponse,'transaction_error_code','error_code');

                payment.Retrieve_API_Response__c = decodedResponse;

                if (statusCode == 200) {

                    payment.Transaction_Id__c = (String) bdResponse.get('transactionid');
                    payment.Bank_Ref_No__c = (String) bdResponse.get('bank_ref_no');
                    payment.Auth_Status__c = (String) bdResponse.get('auth_status') + ' ' + statusCode;

                    payment.Retrieve_API_Code__c = errorCode;
                    payment.Retrieve_API_Desc__c = errorDesc;
                    payment.Retrieve_API_Type__c = errorType;

                    if (bdResponse.containsKey('transaction_date') && bdResponse.get('transaction_date') != null) {
                        payment.Transaction_Date__c =
                            Datetime.valueOf(
                                ((String)bdResponse.get('transaction_date'))
                                    .replace('T',' ')
                                    .substring(0,19)
                            );
                    }

                    payment.Status__c = resolveStatus(errorType);
                    payment.Retrieve_API_Status__c = errorType;

                } else {

                    payment.Error_Status__c = errorType;
                    payment.Error_Code__c = errorCode;
                    payment.Error_Desc__c = errorDesc + ' HTTP Error: ' + statusCode;
                    payment.Error_Type__c = errorType;

                    payment.Status__c = resolveStatus(errorType);
                }

                update payment;
            }

            result.put('orderId', orderId);
            result.put('bookingId', payment.Booking__c);
            result.put('status', payment.Status__c);
            result.put('amount', payment.Amount__c);
            result.put('transactionId', payment.Transaction_Id__c);
            result.put('bankRefNo', payment.Bank_Ref_No__c);

			ERPIntegrationLogger.log(
                'Lockated_PaymentStatusAPI',
                'getPaymentStatus',
                'Payment Status API',
                payment.Booking__c,
                orderId,
                orderId,
                JSON.serialize(result),
                'SUCCESS',
                null,
                null
            );

            res.statusCode = 200;

        } catch (Exception e) {
			String errorDetails =
                'Type: ' + e.getTypeName() +
                ' | Message: ' + e.getMessage() +
                ' | Line: ' + e.getLineNumber();

            ERPIntegrationLogger.log(
                'Lockated_PaymentStatusAPI',
                'getPaymentStatus',
                'Payment Status API',
                null,
                orderId,
                orderId,
                null,
                'FAIL',
                'SYSTEM_EXCEPTION',
                errorDetails
            );

            result.put('status', 'FAIL');
            result.put('message', e.getMessage());

            res.statusCode = 500;
        }

        res.responseBody = Blob.valueOf(JSON.serialize(result));
    }

// 🔹 Helpers
public static String getValue(Map<String,Object> mapData, String k1, String k2) {

    if(mapData.containsKey(k1) && mapData.get(k1) != null) {
        return String.valueOf(mapData.get(k1));
    }

    if(mapData.containsKey(k2) && mapData.get(k2) != null) {
        return String.valueOf(mapData.get(k2));
    }

    return null;
}

    public static String resolveStatus(String errorType){
        system.debug('errorType------>'+errorType);

        if(errorType == null) return 'PENDING';

        errorType = errorType.toLowerCase();

        if(errorType.contains('success')) return 'SUCCESS';
        if(errorType.contains('failure')) return 'FAILED';
        if(errorType.contains('pending')) return 'PENDING';
        if(errorType.contains('cancel')) return 'CANCELLED';
        if(errorType.toLowerCase().contains('not_found_error')) return 'FAILED';

        return 'PENDING';
    }
}