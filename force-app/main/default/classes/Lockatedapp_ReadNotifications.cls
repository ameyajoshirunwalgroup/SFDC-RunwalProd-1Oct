@RestResource(urlMapping='/readNotification/*')
global class Lockatedapp_ReadNotifications {

    @HttpPost
    global static void doPost(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        Map<String, Object> errorResult = new Map<String, Object>();
        try{
            String notificationId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
            App_Notification__c ntf = new App_Notification__c();
            ntf.Id = notificationId;
            ntf.Read__c = true;
            update ntf;
            res.responseBody = Blob.valueOf(JSON.serialize('Notification marked as read'));
            res.statusCode = 200;
        }catch(exception e){
            errorResult.put('status', 'error');
            errorResult.put('message', e.getMessage() + ';  ' + e.getStackTraceString());
            res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
            res.statusCode = 400;
        }
    }
}