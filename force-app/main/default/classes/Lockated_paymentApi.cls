@RestResource(urlMapping='/lockated/payment')
global with sharing class Lockated_paymentApi {

    @HttpPost
    global static void processPayment() {

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');

        String rawBody = '';
        String billDeskResponse = '';
        String errorMsg = '';

        LockatedRequest reqData;

        try {
            // 1️⃣ Read Request Body
            rawBody = (req.requestBody != null) ? req.requestBody.toString() : '';
            System.debug('🔹 Lockated Request => ' + rawBody);

            if(String.isBlank(rawBody)) {
                sendError(res, 400, 'Request body is empty');
                ERPIntegrationLogger.log(
                    'Lockated_paymentApi',
                    'processPayment',
                    'Lockated -> BillDesk',
                    null,
                    null,
                    rawBody,
                    null,
                    'FAIL',
                    'VALIDATION_ERROR',
                    'Request body is empty'
                );
                return;
            }

            // 2️⃣ Deserialize
            reqData = (LockatedRequest) JSON.deserialize(rawBody, LockatedRequest.class);

            // 3️⃣ Validate
            List<String> errors = validateRequest(reqData);
            if(!errors.isEmpty()) {
                String msg = 'Missing/Invalid fields: ' + String.join(errors, ', ');
                sendError(res, 400, msg);
                return;
            }

            // 4️⃣ Call BillDesk
            billDeskResponse = BillDeskService.createOrderRaw(reqData);

            // 5️⃣ Return BillDesk Response
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(billDeskResponse);

            // 6️⃣ Log Success
            ERPIntegrationLogger.log(
                'Lockated_paymentApi',
                'processPayment',
                'Lockated -> BillDesk',
                reqData.bookingId,
                reqData.bookingId,
                rawBody,
                billDeskResponse,
                'SUCCESS',
                null,
                null
            );

        } catch (Exception e) {

            errorMsg = e.getMessage();
            System.debug('❌ Lockated API Error => ' + errorMsg);

            sendError(res, 500, 'Internal Server Error: ' + errorMsg);

            ERPIntegrationLogger.log(
                'Lockated_paymentApi',
                'processPayment',
                'Lockated -> BillDesk',
                reqData != null ? reqData.bookingId : null,
                reqData != null ? reqData.bookingId : null,
                rawBody,
                billDeskResponse,
                'FAIL',
                'SYSTEM_EXCEPTION',
                errorMsg
            );
        }
    }

    // =========================
    // VALIDATION
    // =========================
    private static List<String> validateRequest(LockatedRequest reqData) {

        List<String> errors = new List<String>();

        if(reqData == null) {
            errors.add('Invalid JSON');
            return errors;
        }

        if(String.isBlank(reqData.bookingId)) errors.add('bookingId');
        if(reqData.totalAmount == null || reqData.totalAmount <= 0) errors.add('totalAmount');
        if(reqData.paymentType == null) errors.add('paymentType');

        return errors;
    }

    private static void sendError(RestResponse res, Integer statusCode, String message) {
        res.statusCode = statusCode;
        res.responseBody = Blob.valueOf(JSON.serialize(new Map<String,Object>{
            'status' => 'FAIL',
            'message' => message
        }));
    }


    // =========================
    // REQUEST WRAPPER
    // =========================
    global class LockatedRequest {
        public String bookingId;
        public Decimal totalAmount;
        public String paymentType; 
       
    }
}