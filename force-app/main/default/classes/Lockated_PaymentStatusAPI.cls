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

}