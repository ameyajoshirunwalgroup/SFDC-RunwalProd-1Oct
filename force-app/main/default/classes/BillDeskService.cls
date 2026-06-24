public with sharing class BillDeskService {

    // =====================================================
    // MAIN METHOD
    // =====================================================
    public static String createOrderRaw(Lockated_paymentApi.LockatedRequest data) {

        String requestBody;
        String decodedResponse = '';
        String orderId;

        try {
            System.debug('Incoming Request Data => ' + JSON.serialize(data));
            orderId = generateUniqueOrderId(data);

            Booking__c booking = getBooking(data.bookingId);

            // Fetch metadata
            Payment_Gateway__mdt gateway = getPaymentGateway(booking.Project__r.Name, booking.Unit_No__r.TowerName__r.Name);

            PaymentSplit split = calculatePaymentSplit( data.totalAmount, data.paymentType, booking );

            requestBody = buildRequestBody(data, orderId, split, booking,gateway);
            System.debug('BillDesk ECOM Request Body => ' + requestBody);
            
            String jwtToken = generateJoseToken(requestBody,gateway);
            System.debug('Generated JWT Token => ' + jwtToken);

            String timestamp = System.now().format('yyyyMMddHHmmss');

            HttpResponse response = callBillDeskAPI(jwtToken, orderId, timestamp);
            System.debug('HTTP Status Code => ' + response.getStatusCode());
            System.debug('HTTP Status => ' + response.getStatus());
            System.debug('Raw JOSE Response => ' + response.getBody());

            // return response.getBody();

            // decodedResponse = decodeBillDeskResponse(response.getBody());  

            // saveIntegrationLog('BillDesk', data.bookingId, requestBody, decodedResponse, 'SUCCESS', null, orderId);

            // return decodedResponse;


            //🔹 STEP 1 — Decode ECOM response
            decodedResponse = decodeBillDeskResponse(response.getBody());
            System.debug('Decoded ECOM Response => ' + decodedResponse);

            // 🔹 STEP 2 — Extract ecom_orderid from ECOM response
            Map<String,Object> ecomMap = (Map<String,Object>) JSON.deserializeUntyped(decodedResponse);

            String ecomOrderId = (String) ecomMap.get('ecom_orderid');
            System.debug('Extracted ecom_orderid => ' + ecomOrderId);

            if(String.isBlank(ecomOrderId)){
                throw new CalloutException('BillDesk ECOM orderid missing in response');
            }

            // 🔹 STEP 3 — CALL CREATE ORDER API (New Class)
            BilldeskLockatedOrderAPI.ResponseBody orderResp = BilldeskLockatedOrderAPI.createBilldeskOrder(
                    ecomOrderId, // Use the ID returned from the Ecom API
                    data.totalAmount,
                    gateway
                );

            System.debug('Lockated Order API Response => ' + JSON.serialize(orderResp));

            // 🔹 STEP 4 — Convert final response to JSON
            String finalResponse = buildExactBilldeskResponse(orderResp);
            System.debug('Final Response Sent To UI => ' + finalResponse);

            //Create Transaction Response Record
            createPaymentRecord(orderResp.orderid,orderResp.bdorderid,data.bookingId,orderResp.mercid,Decimal.valueOf(orderResp.amount),orderResp.links[1].parameters.rdata,orderResp.links[1].href, data.paymentType, split.principal, split.gst, gateway);

            // 🔹 STEP 5 — Save final success log
            ERPIntegrationLogger.log(
                'BillDeskService',
                'createOrderRaw',
                'BillDesk ECOM',
                data.bookingId,
                orderId,
                requestBody,
                finalResponse,
                'SUCCESS',
                null,
                null
            );

            // 🔹 STEP 6 — Return FINAL response to Lockated/UI
            return finalResponse;


        } catch (Exception e) {

            ERPIntegrationLogger.log(
                'BillDeskService',
                'createOrderRaw',
                'BillDesk ECOM',
                data != null ? data.bookingId : null,
                orderId,
                requestBody,
                decodedResponse,
                'FAIL',
                'SYSTEM_EXCEPTION',
                e.getMessage()
            );

            return JSON.serialize(new Map<String,Object>{
                'status' => 'FAIL',
                'error_type' => e.getTypeName(),
                'message' => e.getMessage(),
                'line_number' => e.getLineNumber()
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

            if(gstPercent == null || gstPercent <= 0)  gstPercent = 0;//throw new CalloutException('Invalid GST % on Booking');

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
    public static String buildRequestBody(Lockated_paymentApi.LockatedRequest data, String orderId, PaymentSplit split, Booking__c booking,Payment_Gateway__mdt gateway) {

        //Payment_Gateway__mdt gateway = getPaymentGateway( booking.Project__r.Name, booking.Unit_No__r.TowerName__r.Name );
        if(String.isBlank(gateway.Parent_Merchant_Id__c)){
            throw new CalloutException('BillDesk Parent Merchant Id missing in metadata');
        }

        String principalMerchantId = gateway.Bill_Desk_Split_Principal_Merchant_ID__c;  
        String gstMerchantId       = gateway.Bill_Desk_Split_GST_Merchant_ID__c;  

        if(String.isBlank(principalMerchantId))
            throw new CalloutException('Principal Merchant ID missing');

        if(split.gst > 0 && String.isBlank(gstMerchantId))
            throw new CalloutException('GST Merchant ID missing');

        

        Map<String,Object> body = new Map<String,Object>();

        String CURRENCY_KEY = 'currency';

        //body.put('mercid', 'RNLSPLTUAT');
        body.put('mercid', gateway.Parent_Merchant_Id__c);
        body.put('amount', String.valueOf(data.totalAmount.setScale(2)));
        body.put('order_ref_no', orderId);
        body.put('ecom_order_date', DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ss') + '+05:30');
        // body.put('ru', System.label.BillDesk_Split_ReturnUrl);
        body.put('ru', System.label.BillDesk_Split_ReturnUrl + '?orderId=' + EncodingUtil.urlEncode(orderId, 'UTF-8'));
        body.put(CURRENCY_KEY, '356');
        body.put('itemcode', 'DIRECT');

        // SPLIT PAYMENT (MANDATORY)
        List<Object> splitList = new List<Object>();

        // 🔹 CASE 1 — Same merchant for Principal + GST
        if(principalMerchantId == gstMerchantId){

            Decimal totalAmount = split.principal + split.gst;

            splitList.add(
                createSplitMerchant(
                    principalMerchantId,
                    totalAmount,
                    booking.Name + '_PG'
                )
            );

        }
        else{

            // 🔹 CASE 2 — Different merchants (existing logic)

            if(split.principal > 0)
                splitList.add(createSplitMerchant(principalMerchantId, split.principal, booking.Name + '_P'));

            if(split.gst > 0)
                splitList.add(createSplitMerchant(gstMerchantId, split.gst, booking.Name + '_G'));
        }

        body.put('split_payment', splitList);

        return JSON.serialize(body);
    }

    public static Map<String,Object> createSplitMerchant(String mercId, Decimal amount, String customerRef) {

        return new Map<String,Object>{
            'mercid'           => mercId,
            'amount'           => String.valueOf(amount.setScale(2)),
            'customer_refid'   => customerRef+ System.now().format('yyyyMMddHHmmss'),
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
    public static String generateJoseToken(String requestBody,Payment_Gateway__mdt gateway) {
        if(String.isBlank(gateway.Client_Id__c)){
            throw new CalloutException('BillDesk Client Id missing in Payment Gateway Metadata');
        }

        if(String.isBlank(gateway.Secret_Key__c)){
            throw new CalloutException('BillDesk Secret Key missing in Payment Gateway Metadata');
        }

        JSONGenerator header = JSON.createGenerator(false);
        header.writeStartObject();
        header.writeStringField('alg', 'HS256');
        //header.writeStringField('clientid', 'rreplmuat');    //for testing 
        header.writeStringField('clientid', gateway.Client_Id__c);    //for testing 

        header.writeEndObject();

        String encodedHeader = base64URLencode(Blob.valueOf(header.getAsString()));
        String encodedBody   = base64URLencode(Blob.valueOf(requestBody));

        String jwt = encodedHeader + '.' + encodedBody;

        Blob signature = Crypto.generateMac(
            'hmacSHA256',
            Blob.valueOf(jwt),
            Blob.valueOf(gateway.Secret_Key__c)   
        );

        return jwt + '.' + base64URLencode(signature);
    }

    public static HttpResponse callBillDeskAPI(String jwtToken, String orderId, String timestamp) {

        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('callout:BillDesk_API' + System.Label.BillDesk_Split_Create_Order_Path);

        req.setHeader('Content-Type', 'application/jose');
        req.setHeader('Accept', 'application/jose');
        req.setHeader('bd-timestamp', timestamp);
        req.setHeader('bd-traceid', orderId+ '_TRC');

        req.setBody(jwtToken);

        Http http = new Http();
        HttpResponse response = http.send(req);

        System.debug('==== BillDesk API RESPONSE START ====');
        System.debug('Status Code => ' + response.getStatusCode());
        System.debug('Status => ' + response.getStatus());
        System.debug('Response Body => ' + response.getBody());
        System.debug('==== BillDesk API RESPONSE END ====');

        // If non-200, throw proper exception
        if(response.getStatusCode() < 200 || response.getStatusCode() >= 300){
            throw new CalloutException(
                'BillDesk HTTP Error | StatusCode: ' +
                response.getStatusCode() +
                ' | Response: ' +
                response.getBody()
            );
        }

        return response;
    }

    // =====================================================
    // RESPONSE DECODE
    // =====================================================
    // public static String decodeBillDeskResponse(String joseResponse) {

    //     Integer firstDot = joseResponse.indexOf('.');
    //     Integer secondDot = joseResponse.lastIndexOf('.');

    //     if(firstDot == -1 || secondDot == -1) return joseResponse;

    //     String payload = joseResponse.substring(firstDot + 1, secondDot);
    //     return EncodingUtil.base64Decode(payload).toString();
    // }
    public static String decodeBillDeskResponse(String joseResponse) {

        if(String.isBlank(joseResponse))
            throw new CalloutException('Empty BillDesk response');

        Integer firstDot  = joseResponse.indexOf('.');
        Integer secondDot = joseResponse.lastIndexOf('.');

        if(firstDot <= 0 || secondDot <= 0)
            throw new CalloutException('Invalid JOSE format received');

        String payload = joseResponse.substring(firstDot + 1, secondDot);

        return decodeBase64Url(payload);
    }

    public static String decodeBase64Url(String value){

        if(String.isBlank(value)) return null;

        value = value.replace('-', '+').replace('_', '/');

        Integer remainder = Math.mod(value.length(), 4);
        while(remainder != 0){
            value += '=';
            remainder = Math.mod(value.length(), 4);
        }

        return EncodingUtil.base64Decode(value).toString();
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
    public static Booking__c getBooking(String bookingId) {
        return [
            SELECT Id, Name, GST_Percent__c,
                   Project__r.Name,
                   Unit_No__r.TowerName__r.Name
            FROM Booking__c
            WHERE Id = :bookingId
            LIMIT 1
        ];
    }

    public static Payment_Gateway__mdt getPaymentGateway(String projectName, String towerName) {
        List<Payment_Gateway__mdt> gatewayList = [
            SELECT Bill_Desk_Split_Principal_Merchant_ID__c, Bill_Desk_Split_GST_Merchant_ID__c ,Parent_Merchant_Id__c,Client_Id__c,Secret_Key__c
            FROM Payment_Gateway__mdt
            WHERE Project_Name__c = :projectName
            AND Project_Tower__c = :towerName
            LIMIT 1
        ];

        if(gatewayList.isEmpty()){
            throw new CalloutException(
                'BillDesk configuration missing for Project: ' +
                projectName + ' Tower: ' + towerName
            );
        }

        return gatewayList[0];
    }

    public static String generateUniqueOrderId(Lockated_paymentApi.LockatedRequest data) {
        return data.bookingId+'_'+system.now().format('yyyyMMddHHmmss');
    }

    public static String buildExactBilldeskResponse(BilldeskLockatedOrderAPI.ResponseBody resp){
        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartObject();

        // EXACT ORDER AS BILLDESK DOC
        gen.writeStringField('objectid', resp.objectid);
        gen.writeStringField('orderid', resp.orderid);
        gen.writeStringField('bdorderid', resp.bdorderid);
        gen.writeStringField('mercid', resp.mercid);
        gen.writeStringField('order_date', resp.order_date);
        gen.writeStringField('amount', resp.amount);
        gen.writeStringField('currency', '356');
        gen.writeStringField('ru', resp.ru);

        // additional_info
        gen.writeFieldName('additional_info');
        gen.writeStartObject();
        gen.writeStringField('additional_info1', resp.additional_info.additional_info1);
        gen.writeStringField('additional_info2', resp.additional_info.additional_info2);
        gen.writeStringField('additional_info3', resp.additional_info.additional_info3);
        gen.writeStringField('additional_info4', resp.additional_info.additional_info4);
        gen.writeStringField('additional_info5', resp.additional_info.additional_info5);
        gen.writeStringField('additional_info6', resp.additional_info.additional_info6);
        gen.writeStringField('additional_info7', resp.additional_info.additional_info7);
        gen.writeEndObject();

        gen.writeStringField('itemcode', resp.itemcode);
        gen.writeStringField('createdon', resp.createdon);
        gen.writeStringField('next_step', resp.next_step);

        // LINKS ARRAY
        gen.writeFieldName('links');
        gen.writeStartArray();

        // self link
        gen.writeStartObject();
        gen.writeStringField('href', resp.links[0].href);
        gen.writeStringField('rel', resp.links[0].rel);
        gen.writeStringField('method', resp.links[0].method);
        gen.writeEndObject();

        // redirect link
        gen.writeStartObject();
        gen.writeStringField('href', resp.links[1].href);
        gen.writeStringField('rel', resp.links[1].rel);
        gen.writeStringField('method', resp.links[1].method);

        gen.writeFieldName('parameters');
        gen.writeStartObject();
        gen.writeStringField('mercid', resp.links[1].parameters.mercid);
        gen.writeStringField('bdorderid', resp.links[1].parameters.bdorderid);
        gen.writeStringField('rdata', resp.links[1].parameters.rdata);
        gen.writeEndObject();

        gen.writeStringField('valid_date', resp.links[1].valid_date);

        gen.writeFieldName('headers');
        gen.writeStartObject();
        gen.writeStringField('authorization', resp.links[1].headers.authorization);
        gen.writeEndObject();

        gen.writeEndObject();
        gen.writeEndArray();

        gen.writeStringField('status', 'ACTIVE');
        // ✅ NEW — Add payment_page_url for Lockated Mobile
        String merchantId = resp.links[1].parameters.mercid;
        String bdOrderId  = resp.links[1].parameters.bdorderid;
        String rdataValue = resp.links[1].parameters.rdata;
        String paymentUrl = resp.links[1].href;

        String paymentPageUrl = System.Label.Billdesk_Site_URL + '/BillDeskSplitPaymentPage'
                + '?orderId=' + EncodingUtil.urlEncode(resp.orderid, 'UTF-8');
            // + '?merchantid=' + EncodingUtil.urlEncode(merchantId, 'UTF-8')
            // + '&bdorderid='  + EncodingUtil.urlEncode(bdOrderId, 'UTF-8')
            // + '&rdata='      + EncodingUtil.urlEncode(rdataValue, 'UTF-8')
            // + '&payment_url='+ EncodingUtil.urlEncode(paymentUrl, 'UTF-8');

        gen.writeStringField('payment_page_url', paymentPageUrl);

        gen.writeEndObject();

        return gen.getAsString();
    }

    public static void createPaymentRecord( String orderId, String bdOrderId, String bookingId, String mercId, Decimal amount, String rdata, String paymentUrl ,String paymentType, Decimal principalAmount, Decimal gstAmount, Payment_Gateway__mdt gateway){
        try{
            Payment_Transaction__c payment = new Payment_Transaction__c(
                Order_Id__c = orderId,
                BillDesk_Order_Id__c = bdOrderId,
                Booking__c = String.isNotBlank(bookingId) ? bookingId : null,
                Merchant_Id__c = mercId,
                Amount__c = amount,
                Status__c = 'INITIATED',
                RData__c = rdata, 
                Payment_Url__c = paymentUrl,
                Payment_Type__c = paymentType,
                Principal_Amount__c = principalAmount,
                GST_Amount__c = gstAmount,
                Parent_Merchant_Id__c=gateway.Parent_Merchant_Id__c
            );

            insert payment;

        }catch(Exception e){
            System.debug('Payment Create Error: ' + e.getMessage());
        }
    }

}