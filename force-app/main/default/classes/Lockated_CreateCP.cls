public class Lockated_CreateCP {
    // Boundary used to separate different parts of the form-data
    private static final String BOUNDARY = '----------------------------' + String.valueOf(DateTime.now().getTime());

    public static void createCPUser(Id contactId) {
        // 1. Fetch data (Assuming data is on a Contact or Custom Object)
        // Adjust fields based on your formula fields like Ageing or Registration Date
        Broker__c con = [SELECT Id,NAME_FIRST__c,NAME_LAST__c, RW_Email__c,CP_APP_Registration_Error__c, RW_Mobile_No__c,Broker_Pan_No__c,RW_GST_Number__c, CP_APP_Registration__c FROM Broker__c WHERE Id = :contactId LIMIT 1];
        String apiToken = 'dDOaBl-r-IL0C9zBevduQK3YCoUDdoTzM1nlXQvHSI4';
        String endpoint = 'https://runwal-cp-api.lockated.com/users/cp_registration.json?token='+apiToken;
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        
        req.setMethod('POST'); 
        
        req.setHeader('Content-Type', 'multipart/form-data; boundary=' + BOUNDARY);
        req.setHeader('Accept', 'application/json');
        
        //req.setHeader('Content-Type', 'multipart/form-data; boundary=' + BOUNDARY);
        // Note: Auth header is omitted as per your discovery that there is no auth currently
        
        // 2. Construct the Body
        String body = '';
        body += writeBodyParameter('user[firstname]', con.NAME_FIRST__c);
        body += writeBodyParameter('user[lastname]', con.NAME_LAST__c);
        body += writeBodyParameter('user[email]', con.RW_Email__c);
        body += writeBodyParameter('user[mobile]', con.RW_Mobile_No__c);
        body += writeBodyParameter('user[org_user_id]', con.Id); // Using as External ID
        body += writeBodyParameter('user[pan_number]', con.Broker_Pan_No__c);
        body += writeBodyParameter('user[gst_number]', con.RW_GST_Number__c);
        body += writeBodyParameter('user[password]', 'runwal@1234');
        
        // Final Boundary
        body += '--' + BOUNDARY + '--';

        req.setBody(body);
        req.setTimeout(120000);

        Http http = new Http();
        try {
            HttpResponse res = http.send(req);
            System.debug('Status: ' + res.getStatus());
            System.debug('Response: ' + res.getBody());
            if (res.getStatusCode() == 201) {
                con.CP_APP_Registration__c = true;
                update con; 
                System.debug('Success: Broker record updated.');
            } else {
                String errorMessage = 'Status Code: ' + res.getStatusCode();
                try {
                    Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                    if (results.containsKey('messages')) {
                        List<Object> msgList = (List<Object>) results.get('messages');
                        // Join messages into a single string if there are multiple
                        errorMessage = String.join(msgList, ', ');
                    } else if (results.containsKey('error')) {
                        errorMessage = (String) results.get('error');
                    }
                    con.CP_APP_Registration_Error__c = errorMessage;
                	update con;
                }catch(Exception ex){
                	System.debug('API Error: Received Status Code ' + res.getStatusCode());
                }
            }
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
    }

    private static String writeBodyParameter(String key, String value) {
        if (value == null) value = '';
        String content = '--' + BOUNDARY + '\r\n';
        content += 'Content-Disposition: form-data; name="' + key + '"\r\n\r\n';
        content += value + '\r\n';
        return content;
    }
}