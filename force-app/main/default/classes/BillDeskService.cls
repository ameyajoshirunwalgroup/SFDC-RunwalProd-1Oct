public with sharing class BillDeskService {

    // =====================================================
    // MAIN METHOD
    // =====================================================
    public static String createOrderRaw(Lockated_paymentApi.LockatedRequest data) {

        String requestBody;
        String decodedResponse = '';
        String orderId;

        try {
            orderId = generateUniqueOrderId(data);

            Booking__c booking = getBooking(data.bookingId);

            PaymentSplit split = calculatePaymentSplit(
                data.totalAmount,
                data.paymentType,
                booking
            );

            requestBody = buildRequestBody(data, orderId, split, booking);
            System.debug('BillDesk Request Body => ' + requestBody);

            String jwtToken = generateJoseToken(requestBody);

            String timestamp = System.now().format('yyyyMMddHHmmss');
            HttpResponse response = callBillDeskAPI(jwtToken, orderId, timestamp);

            decodedResponse = decodeBillDeskResponse(response.getBody());

            saveIntegrationLog('BillDesk', data.bookingId, requestBody, decodedResponse, 'SUCCESS', null, orderId);

            return decodedResponse;

        } catch (Exception e) {

            saveIntegrationLog('BillDesk', data.bookingId, requestBody, decodedResponse, 'FAIL', e.getMessage(), orderId);

            return JSON.serialize(new Map<String,Object>{
                'status' => 'FAIL',
                'message' => e.getMessage()
            });
        }
    }

    // =====================================================
    // PAYMENT SPLIT CALCULATION
    // =====================================================
    private class PaymentSplit {
        public Decimal principal;
        public Decimal gst;
    }

    private static PaymentSplit calculatePaymentSplit(Decimal totalAmount, String paymentType, Booking__c booking) {

        PaymentSplit split = new PaymentSplit();
        Decimal gstPercent = booking.GST_Percent__c;

        if(paymentType == 'PRINCIPAL_GST' || paymentType == 'CUSTOM_AMOUNT') {

            if(gstPercent == null || gstPercent <= 0)
                throw new CalloutException('Invalid GST % on Booking');

            split.gst = (totalAmount * gstPercent / (100 + gstPercent)).setScale(2);
            split.principal = (totalAmount - split.gst).setScale(2);
        }
        else if(paymentType == 'GST_ONLY') {
            split.gst = totalAmount.setScale(2);
            split.principal = 0;
        }
        else {
            throw new CalloutException('Invalid paymentType: ' + paymentType);
        }

        return split;
    }

    // =====================================================
    // BUILD ECOM REQUEST BODY
    // =====================================================
    private static String buildRequestBody(Lockated_paymentApi.LockatedRequest data, String orderId, PaymentSplit split, Booking__c booking) {

        Payment_Gateway__mdt gateway = getPaymentGateway(
            booking.Project__r.Name,
            booking.Unit_No__r.TowerName__r.Name
        );

        String principalMerchantId = 'RNL1';
        String gstMerchantId       = 'RNL2';

        if(String.isBlank(principalMerchantId))
            throw new CalloutException('Principal Merchant ID missing');

        if(split.gst > 0 && String.isBlank(gstMerchantId))
            throw new CalloutException('GST Merchant ID missing');

        Map<String,Object> body = new Map<String,Object>();

        String CURRENCY_KEY = 'currency';

        body.put('mercid', 'RNLSPLTUAT');
        body.put('amount', String.valueOf(data.totalAmount.setScale(2)));
        body.put('order_ref_no', orderId);
        body.put('ecom_order_date', DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX'));
        body.put('ru', System.label.Billdesk_Site_URL);
        body.put(CURRENCY_KEY, '356');
        body.put('itemcode', 'DIRECT');

        // SPLIT PAYMENT (MANDATORY)
        List<Object> splitList = new List<Object>();

        if(split.principal > 0)
            splitList.add(createSplitMerchant(principalMerchantId, split.principal, booking.Name + '_P'));

        if(split.gst > 0)
            splitList.add(createSplitMerchant(gstMerchantId, split.gst, booking.Name + '_G'));

        body.put('split_payment', splitList);

        return JSON.serialize(body);
    }

    private static Map<String,Object> createSplitMerchant(String mercId, Decimal amount, String customerRef) {

        return new Map<String,Object>{
            'mercid'           => mercId,
            'amount'           => String.valueOf(amount.setScale(2)),
            'customer_refid'   => customerRef,
            'additional_info1' => 'Booking',
            'additional_info2' => 'Salesforce',
            'additional_info3' => 'SplitPayment',
            'additional_info4' => 'NA',
            'additional_info5' => 'NA',
            'additional_info6' => 'NA'
        };
    }

    // =====================================================
    // JWT GENERATION
    // =====================================================
    private static String generateJoseToken(String requestBody) {

        JSONGenerator header = JSON.createGenerator(false);
        header.writeStartObject();
        header.writeStringField('alg', 'HS256');
        header.writeStringField('clientid', 'rreplmuat');
        header.writeEndObject();

        String encodedHeader = base64URLencode(Blob.valueOf(header.getAsString()));
        String encodedBody   = base64URLencode(Blob.valueOf(requestBody));

        String jwt = encodedHeader + '.' + encodedBody;

        Blob signature = Crypto.generateMac(
            'hmacSHA256',
            Blob.valueOf(jwt),
            Blob.valueOf('PnNz3ujffwJXqLUI5AuDiH2JXlu6kPWh')
        );

        return jwt + '.' + base64URLencode(signature);
    }

    private static HttpResponse callBillDeskAPI(String jwtToken, String orderId, String timestamp) {

        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('callout:BillDesk_API/u2/payments/ve1_2/ecomorders/create');

        req.setHeader('Content-Type', 'application/jose');
        req.setHeader('Accept', 'application/jose');
        req.setHeader('bd-timestamp', timestamp);
        req.setHeader('bd-traceid', orderId + '_' + timestamp);

        req.setBody(jwtToken);

        return new Http().send(req);
    }

    // =====================================================
    // RESPONSE DECODE
    // =====================================================
    public static String decodeBillDeskResponse(String joseResponse) {

        Integer firstDot = joseResponse.indexOf('.');
        Integer secondDot = joseResponse.lastIndexOf('.');

        if(firstDot == -1 || secondDot == -1) return joseResponse;

        String payload = joseResponse.substring(firstDot + 1, secondDot);
        return EncodingUtil.base64Decode(payload).toString();
    }

    public static String base64URLencode(Blob input) {
        String output = EncodingUtil.base64Encode(input);
        output = output.replace('+', '-').replace('/', '_');
        while(output.endsWith('=')) {
            output = output.substring(0, output.length()-1);
        }
        return output;
    }

    // =====================================================
    // BOOKING + METADATA
    // =====================================================
    private static Booking__c getBooking(String bookingId) {
        return [
            SELECT Id, Name, GST_Percent__c,
                   Project__r.Name,
                   Unit_No__r.TowerName__r.Name
            FROM Booking__c
            WHERE Id = :bookingId
            LIMIT 1
        ];
    }

    private static Payment_Gateway__mdt getPaymentGateway(String projectName, String towerName) {
        return [
            SELECT Bill_Desk_Merchant_ID__c, Bill_Desk_GST_Merchant_ID__c
            FROM Payment_Gateway__mdt
            WHERE Project_Name__c = :projectName
            AND Project_Tower__c = :towerName
            LIMIT 1
        ];
    }

    private static void saveIntegrationLog(String apiName, String bookingId, String requestBody, String responseBody, String status, String errorMsg, String externalId) {
        try {
            insert new ERP_Integration_Log__c(
                API_Name__c = apiName,
                Booking__c = bookingId,
                Request__c = requestBody,
                Response__c = responseBody,
                Status__c = status,
                Error_Reason__c = errorMsg,
                External_Id__c = externalId
            );
        } catch(Exception e) {
            System.debug('Log error: ' + e.getMessage());
        }
    }

    private static String generateUniqueOrderId(Lockated_paymentApi.LockatedRequest data) {
        return data.bookingId + '_' + DateTime.now().getTime();
    }
}