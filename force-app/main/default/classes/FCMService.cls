public class FCMService {

    @future(callout=true)
    public static void sendNotification(String deviceToken, String bookingId, String ntype, String title, String body, String redirectionId, String notificationId) {
        String accessToken = FirebaseAuthService.getAccessToken();

        if(accessToken == null){
            System.debug('Access token not generated. Cannot send notification.');
            return;
        }

        /*Map<String,Object> notification = new Map<String,Object>{
            'title' => title,
            'body' => body
        };
        Map<String, Object> dataPayload = new Map<String, Object>{
            'title' => title,
            'message' => body,
            'client' => 'runwal_ps',
            'booking_number' => bookingId,
            'redirection_id' => recordId,
            'ntype' => ntype,
            'click_action' => 'FLUTTER_NOTIFICATION_CLICK'
        };
            
        
        Map<String,Object> message = new Map<String,Object>{
            'token' => deviceToken,
            'notification' => notification,
            'data' => dataPayload
        };

        Map<String,Object> payload = new Map<String,Object>{
            'message' => message
        };*/
            
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject();
        generator.writeFieldName('message');
        generator.writeStartObject();
        generator.writeStringField('token', deviceToken);
        generator.writeFieldName('notification');
        generator.writeStartObject();
        generator.writeStringField('title', (title != null)? title : '');
        generator.writeStringField('body', (body != null)? body : '');
        generator.writeEndObject();
        generator.writeFieldName('data');
        generator.writeStartObject();
        generator.writeStringField('title', (title != null)? title : '');
        generator.writeStringField('message', (body != null)? body : '');
        generator.writeStringField('client','runwal_ps');
        generator.writeStringField('booking_number', (bookingId != null)? bookingId : '');
        generator.writeStringField('ntype', (ntype != null)? ntype : '');
        generator.writeStringField('redirection_id', (redirectionId != null)? redirectionId : '');
        generator.writeStringField('notification_id', (notificationId != null)? notificationId : '');
        generator.writeStringField('click_action','FLUTTER_NOTIFICATION_CLICK');
        generator.writeEndObject();
        generator.writeFieldName('android');
        generator.writeStartObject();
        generator.writeFieldName('notification');
        generator.writeStartObject();
        generator.writeStringField('click_action','FLUTTER_NOTIFICATION_CLICK');
        generator.writeEndObject();
        generator.writeEndObject();
        generator.writeFieldName('apns');
        generator.writeStartObject();
        generator.writeFieldName('payload');
        generator.writeStartObject();
        generator.writeFieldName('aps');
        generator.writeStartObject();
        generator.writeStringField('click_action','FLUTTER_NOTIFICATION_CLICK');
        generator.writeEndObject();
        generator.writeEndObject();
        generator.writeEndObject();
        generator.writeEndObject();
        generator.writeEndObject();
        String jsonString = generator.getAsString();
        System.debug('jsonString: ' + jsonString);
            

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://fcm.googleapis.com/v1/projects/' + FirebaseAuthService.PROJECT_ID + '/messages:send');
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json');
        //req.setBody(JSON.serialize(payload));
        req.setBody(jsonString);

        //System.debug('payload: ' + JSON.serialize(payload));
        
        Http http = new Http();
        HttpResponse res = http.send(req);

        System.debug('FCM Response: ' + res);
        System.debug('FCM Response: ' + res.getBody());
        
        //Sample json
        /*{
            "message": {
                "token": "DEVICE_TOKEN",
                 "notification": {
                        "title": "New Lead Assigned",
                         "body": "Tap to view details"
                 },
                 "data": {
                     "recordId": "00Q5g00000ABCDE",
                      "type": "lead"
                 }
            }
        }
		
DEVICE_TOKEN = 'ftysHVoQRGitVXURrxGqKZ:APA91bGWz9K-xr4PUKKm9cZvaqvSXQjoqGyusUTLRJwRx6mMT_IvwA-yprLi--efcGQJSm9-23MaKAdT7WTSdNyhv2rEEVfK6YkH6OekOF12nKbSD8Spr_I'
        */
    }
    
}