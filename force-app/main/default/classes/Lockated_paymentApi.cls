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
                logIntegration(null, rawBody, null, 'FAIL', 'Request body is empty');
                return;
            }

            // 2️⃣ Deserialize
            reqData = (LockatedRequest) JSON.deserialize(rawBody, LockatedRequest.class);

            // 3️⃣ Validate
            List<String> errors = validateRequest(reqData);
            if(!errors.isEmpty()) {
                String msg = 'Missing/Invalid fields: ' + String.join(errors, ', ');
                sendError(res, 400, msg);
                logIntegration(reqData.bookingId, rawBody, null, 'FAIL', msg);
                return;
            }

            // 4️⃣ Call BillDesk
            billDeskResponse = BillDeskService.createOrderRaw(reqData);

            // 5️⃣ Return BillDesk Response
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(billDeskResponse);

            // 6️⃣ Log Success
            logIntegration(reqData.bookingId, rawBody, billDeskResponse, 'SUCCESS', null);

        } catch (Exception e) {

            errorMsg = e.getMessage();
            System.debug('❌ Lockated API Error => ' + errorMsg);

            sendError(res, 500, 'Internal Server Error: ' + errorMsg);

            logIntegration(
                reqData != null ? reqData.bookingId : null,
                rawBody,
                billDeskResponse,
                'FAIL',
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

    private static void logIntegration(String bookingId, String requestBody, String responseBody, String status, String errorMessage) {
        try {
            ERP_Integration_Log__c log = new ERP_Integration_Log__c();
            log.API_Name__c = 'Lockated -> BillDesk';
            log.Booking__c = bookingId;
            log.Request__c = requestBody;
            log.Response__c = responseBody;
            log.Status__c = status;
            log.Error_Reason__c = errorMessage;
            insert log;
        } catch (Exception e) {
            System.debug('❌ Log Failed => ' + e.getMessage());
        }
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