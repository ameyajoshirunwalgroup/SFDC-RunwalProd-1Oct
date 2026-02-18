@RestResource(urlMapping='/customerNotifications/*')
global class Lockatedapp_CustomerNotifications {

    
    @HttpGet
    global static void doGet(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        Map<String, Object> errorResult = new Map<String, Object>();
        try{
            String jsonBody = req.requestBody.toString();
            ReqDetails det = (ReqDetails) JSON.deserialize(jsonBody, ReqDetails.class);
            List<App_Notification__c> notifications = [SELECT Id,Booking__c,Title__c,Message__c,Notification_Type__c,Device_Token__c,Read__c FROM App_Notification__c WHERE Booking__c =: det.bookingNumber AND Device_Token__c =: det.deviceToken ORDER By CreatedDate DESC LIMIT 20];
            res.responseBody = Blob.valueOf(JSON.serialize(notifications));
            res.statusCode = 200;
        }catch(exception e){
            errorResult.put('status', 'error');
            errorResult.put('message', e.getMessage() + ';  ' + e.getStackTraceString());
            res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
            res.statusCode = 400;
        }
    }
    
    public Class ReqDetails{
        public String bookingNumber;
        public String deviceToken;
    }
}