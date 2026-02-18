public class Lockated_FirebasePushService {
    
    /*public static void sendPush(String deviceToken, String title, String body) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        
        // Endpoint for Firebase Cloud Messaging
        req.setEndpoint('https://fcm.googleapis.com/fcm/send');
        req.setMethod('POST');
        
        // 🔑 Use your Firebase Server Key
        req.setHeader('Authorization', 'key=YOUR_FIREBASE_SERVER_KEY');
        req.setHeader('Content-Type', 'application/json');
        
        // Build JSON payload
        Map<String, Object> payload = new Map<String, Object>();
        payload.put('to', deviceToken);
        
        Map<String, Object> notification = new Map<String, Object>();
        notification.put('title', title);
        notification.put('body', body);
        
        payload.put('notification', notification);
        
        req.setBody(JSON.serialize(payload));
        
        HttpResponse res = http.send(req);
        System.debug('FCM Response: ' + res.getBody());
    }*/
    


    

}