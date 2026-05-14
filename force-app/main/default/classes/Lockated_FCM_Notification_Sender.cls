public class Lockated_FCM_Notification_Sender {
	// You must replace this with your Firebase Project ID
    //private static final String FIREBASE_PROJECT_ID = 'your-firebase-project-id';
    private static final String FIREBASE_PROJECT_ID = 'runwal-8fc5c';
    private static final String FCM_ENDPOINT = 'https://fcm.googleapis.com/v1/projects/' + FIREBASE_PROJECT_ID + '/messages:send';

    @future(callout=true)
    public static void sendPushNotification(String fcmToken, String title, String body) {
        try {
            String accessToken = Lockated_FCM_JWT_Generator.getAccessToken();

            HttpRequest request = new HttpRequest();
            request.setEndpoint(FCM_ENDPOINT);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Authorization', 'Bearer ' + accessToken);

            Map<String, Object> messagePayload = new Map<String, Object>();
            
            Map<String, Object> notification = new Map<String, Object>();
            notification.put('title', title);
            notification.put('body', body);
            messagePayload.put('notification', notification);

            messagePayload.put('token', fcmToken);

            Map<String, Object> requestBody = new Map<String, Object>();
            requestBody.put('message', messagePayload);

            request.setBody(JSON.serialize(requestBody));

            Http http = new Http();
            HttpResponse response = http.send(request);

            if (response.getStatusCode() == 200) {
                System.debug('FCM Notification sent successfully. Response: ' + response.getBody());
            } else {
                System.debug('FCM Notification failed. Status Code: ' + response.getStatusCode() + ', Body: ' + response.getBody());
            }
        } catch (Exception e) {
            System.debug('An error occurred while sending FCM notification: ' + e.getMessage());
        }
    }
}