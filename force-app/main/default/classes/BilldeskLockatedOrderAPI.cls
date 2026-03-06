public with sharing class BilldeskLockatedOrderAPI {

    // =====================================================
    // MAIN ENTRY METHOD
    // =====================================================
    public static ResponseBody createBilldeskOrder(String ecomOrderId, Decimal amount){
        String requestBody;
        String decodedJson;
        String orderId = ecomOrderId;
		try{

        String timestamp = getTimestamp();

        String header    = buildHeader();
        requestBody      = buildRequestBody(orderId, amount);
        String jwtToken  = generateJWT(header, requestBody);

        String joseResponse = callBilldesk(jwtToken, orderId, timestamp);
        decodedJson  = decodeJose(joseResponse);

		// 🔹 LOG 3 — FINAL JSON RESPONSE
       ERPIntegrationLogger.log(
                'BilldeskLockatedOrderAPI',
                'createBilldeskOrder',
                'BillDesk CreateOrder',
                null,
                orderId,
                requestBody,
                decodedJson,
                'SUCCESS',
                null,
                null
            );

        return (ResponseBody) JSON.deserialize(decodedJson, ResponseBody.class);

		}catch(Exception e){

            String errorDetails = 'Type: ' + e.getTypeName() + ' | Message: ' + e.getMessage() + ' | Line: ' + e.getLineNumber() + ' | StackTrace: ' + e.getStackTraceString();

            System.debug('===== BILLDESK CREATE ORDER ERROR =====');
            System.debug(errorDetails);

            ERPIntegrationLogger.log(
                'BilldeskLockatedOrderAPI',
                'createBilldeskOrder',
                'BillDesk CreateOrder',
                null,
                orderId,
                requestBody,
                decodedJson,
                'FAIL',
                'SYSTEM_EXCEPTION',
                errorDetails
            );

            throw e;
        }
    }

    // =====================================================
    // STEP 1 — BUILD HEADER JSON
    // =====================================================
    private static String buildHeader(){
        JSONGenerator header = JSON.createGenerator(false);
        header.writeStartObject();
        header.writeStringField('alg','HS256');
        header.writeStringField('clientid', 'rreplmuat');
        header.writeEndObject();
        return header.getAsString();
    }

    // =====================================================
    // STEP 2 — BUILD DEVICE OBJECT
    // =====================================================
    private static Device buildDevice(){
        Device device = new Device();
        device.init_channel = 'internet';
        device.ip = '104.161.128.0';
        device.accept_header = 'text/html';
        device.browser_tz = '-330';
        device.browser_color_depth = '32';
        device.browser_java_enabled = 'false';
        device.browser_screen_height = '601';
        device.browser_screen_width = '657';
        device.browser_language = 'en-US';
        device.browser_javascript_enabled = 'true';
        device.user_agent = 'Mozilla/5.0';
        return device;
    }

    // =====================================================
    // STEP 3 — BUILD REQUEST BODY
    // =====================================================
    private static String buildRequestBody(String orderId, Decimal amount){

        JSONGenerator body = JSON.createGenerator(false);
        body.writeStartObject();
        body.writeStringField('mercid', 'RNLSPLTUAT');
        body.writeStringField('orderid', orderId);
        body.writeStringField('amount', String.valueOf(amount.setScale(2)));
        body.writeStringField('order_date', DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX'));
        body.writeStringField('currency','356');
        //body.writeStringField('ru', System.label.BillDesk_Split_ReturnUrl);
        body.writeStringField('ru', System.label.BillDesk_Split_ReturnUrl + '?orderId=' + EncodingUtil.urlEncode(orderId, 'UTF-8'));
        body.writeStringField('itemcode','DIRECT');
        body.writeFieldName('device');
        body.writeObject(buildDevice());
        body.writeEndObject();

        return body.getAsString();
    }

    // =====================================================
    // STEP 4 — GENERATE JWT TOKEN
    // =====================================================
    public static String generateJWT(String headerJson, String bodyJson){

        String encodedHeader = base64URLencode(Blob.valueOf(headerJson));
        String encodedBody   = base64URLencode(Blob.valueOf(bodyJson));

        String jwt = encodedHeader + '.' + encodedBody;

        Blob signature = Crypto.generateMac(
            'hmacSHA256',
            Blob.valueOf(jwt),
            Blob.valueOf(System.label.Billdesk_Secret_Key)
        );

        return jwt + '.' + base64URLencode(signature);
    }

    // =====================================================
    // STEP 5 — HTTP CALLOUT
    // =====================================================
    private static String callBilldesk(String jwtToken, String orderId, String timestamp){

        HttpRequest req = new HttpRequest();
        req.setEndpoint(System.label.Billdesk_Payment_API);
        req.setMethod('POST');
        req.setHeader('content-Type','application/jose');
        req.setHeader('accept','application/jose');
        req.setHeader('bd-timestamp', timestamp);
        req.setHeader('bd-traceid', orderId);
        req.setBody(jwtToken);

        Http http = new Http();
        HttpResponse res = http.send(req);

        System.debug('HTTP Status Code => ' + res.getStatusCode());
        System.debug('HTTP Status => ' + res.getStatus());
        System.debug('HTTP Response Body => ' + res.getBody());

        if(res.getStatusCode() < 200 || res.getStatusCode() >= 300){
            throw new CalloutException(
                'BillDesk Orders API Failed | StatusCode: ' +
                res.getStatusCode() +
                ' | Response: ' +
                res.getBody()
            );
        }

        return res.getBody();
    }
    public static String decodeJose(String jose){

    if(String.isBlank(jose)){
        throw new CalloutException('Empty JOSE response from BillDesk');
    }

    Integer firstDot  = jose.indexOf('.');
    Integer secondDot = jose.lastIndexOf('.');

    if(firstDot <= 0 || secondDot <= 0){
        throw new CalloutException('Invalid JOSE format received');
    }

    String payload = jose.substring(firstDot + 1, secondDot);

    return decodeBase64Url(payload);
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

    private static String getTimestamp(){
        return System.now().format('yyyyMMddHHmmss');
    }

    // =====================================================
    // BASE64 URL ENCODE
    // =====================================================
    private static String base64URLencode(Blob input){
        String output = EncodingUtil.base64Encode(input);
        output = output.replace('+','-').replace('/','_');
        while(output.endsWith('=')){
            output = output.substring(0,output.length()-1);
        }
        return output;
    }

    // =====================================================
    // RESPONSE WRAPPER CLASSES
    // =====================================================
    public class ResponseBody{
        public String objectid;
        public String orderid;
        public String bdorderid;
        public String mercid;
        public String order_date;
        public String amount;
        public String ru;
        public AdditionaInfo additional_info;
        public String itemcode;
        public String createdon;
        public String next_step;
        public List<Link> links;
    }

    public class AdditionaInfo{
        public String additional_info1;
        public String additional_info2;
        public String additional_info3;
        public String additional_info4;
        public String additional_info5;
        public String additional_info6;
        public String additional_info7;
    }

    public class Link{
        public String href;
        public String rel;
        public String method;
        public Link_Parameters parameters;
        public String valid_date;
        public Link_Headers headers;
    }

    public class Link_Parameters{
        public String mercid;
        public String bdorderid;
        public String rdata;
    }

    public class Link_Headers{
        public String authorization;
    }

    public class Device{
        public String init_channel;
        public String ip;
        public String user_agent;
        public String accept_header;
        public String browser_tz;
        public String browser_color_depth;
        public String browser_java_enabled;
        public String browser_screen_height;
        public String browser_screen_width;
        public String browser_language;
        public String browser_javascript_enabled;
    }
    
	private static void logStep(String step, String request, String response, String status, String errorMsg, String extId){
    try{
        insert new ERP_Integration_Log__c(
            API_Name__c = step,
            Request__c = request,
            Response__c = response,
            Status__c = status,
            Error_Reason__c = errorMsg,
            External_Id__c = extId
        );
    }catch(Exception e){
        System.debug('Log Failed '+e.getMessage());
    }
}

}