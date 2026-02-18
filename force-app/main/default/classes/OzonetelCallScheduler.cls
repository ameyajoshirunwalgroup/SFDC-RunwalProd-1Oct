public class OzonetelCallScheduler {

    @future(callout = true)
    public static void scheduleCall(Set<Id> scIds){
        System.debug('--scheduleCall--');
        
        List<Scheduled_Call__c> scList = [SELECT Id, Mobile_Number__c, Customer_Name__c, Agent_Id__c, Schedule_Date__c FROM Scheduled_Call__c WHERE Id =: scIds];
        
        Map<String, Scheduled_Call__c> mobileVsScheduleCall = new Map<String, Scheduled_Call__c>();
        List<Scheduled_Call__c> schedulesToUpdate = new List<Scheduled_Call__c>();
        for(Scheduled_Call__c sc : scList){
            DateTime scDate = sc.Schedule_Date__c;
			String formattedDate = scDate.format('yyyy-MM-dd HH:mm:ss');
            String jsonData = '{ "userName": "runwal", "campaignName": "Scheduled_Call", "bulkData": { "map": [ "PhoneNumber", "Name", "AgentID", "ScheduledTime" ], "data": [ ';
            jsonData += '["'+ sc.Mobile_Number__c +'", "' + sc.Customer_Name__c + ' ", "' + sc.Agent_Id__c +'", "' + formattedDate + '"]';
            jsonData += ']}}';
            mobileVsScheduleCall.put(sc.Mobile_Number__c, sc);
            String apiKey = System.label.Ozonetel_API_Key;
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://in1-ccaas-api.ozonetel.com/ca_apis/CampaignScheduledData');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('apiKey', apiKey);
            req.setBody(jsonData);
            System.debug('jsonData: ' + jsonData);
            Http http = new Http();
            HTTPResponse res = new HttpResponse();
            if(!Test.isRunningTest()){
                res = http.send(req);
            } else {
                res.setBody('{"message": [{"Response": "success","msg": "Data updated successfully","campaign_name": "Scheduled_Call","ExpiryDate": null,"ScheduleTime": "2025-08-08 09:23:00",  "skill": null,"index": 0,"PhoneNumber": "9243562121","AgentID": "Agent","rowId": 34200252}],"status": "success"}');
            }
            
            ScheduleResponse resBody = new ScheduleResponse();
            System.debug('res.getBody(): ' + res.getBody());
            Map<String, Object> resMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            String status = (String) resMap.get('status');
            if(status == 'success'){
                resBody = (ScheduleResponse)JSON.deserialize(res.getBody(), ScheduleResponse.class);
                System.debug('res.getBody(): ' + res.getBody());
                System.debug('resBody: ' + resBody);
                if(resBody != null && resBody.message != null){
                    sc.Ozonetel_Row_Id__c = resBody.message[0].rowId;
                    /*for(Message msg : resBody.message){
                        if(mobileVsScheduleCall.get(msg.PhoneNumber) != null){
                            mobileVsScheduleCall.get(msg.PhoneNumber).Ozonetel_Row_Id__c = msg.rowId;
                        }
                    }
                    update mobileVsScheduleCall.values();*/
                    schedulesToUpdate.add(sc);
                }
            }else{
                sc.Error_Message__c = (String) resMap.get('message');
                schedulesToUpdate.add(sc);
            }
        }
        update schedulesToUpdate;
        
    }
    
    /*@future(callout = true)
    public static void scheduleCall(Set<Id> scIds){
        System.debug('--scheduleCall--');
        
        List<Scheduled_Call__c> scList = [SELECT Id, Mobile_Number__c, Customer_Name__c, Agent_Id__c, Schedule_Date__c FROM Scheduled_Call__c WHERE Id =: scIds];
        String jsonData = '{ "userName": "runwal", "campaignName": "Scheduled_Call", "bulkData": { "map": [ "PhoneNumber", "Name", "AgentID", "ScheduledTime" ], "data": [ ';
        Map<String, Scheduled_Call__c> mobileVsScheduleCall = new Map<String, Scheduled_Call__c>();
        for(Scheduled_Call__c sc : scList){
            DateTime scDate = sc.Schedule_Date__c;
			String formattedDate = scDate.format('yyyy-MM-dd HH:mm:ss');
            jsonData += '["'+ sc.Mobile_Number__c +'", "' + sc.Customer_Name__c + ' ", "' + sc.Agent_Id__c +'", "' + formattedDate + '"]';
            
            mobileVsScheduleCall.put(sc.Mobile_Number__c, sc);
        }
        jsonData += ']}}';
        String apiKey = System.label.Ozonetel_API_Key;
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://in1-ccaas-api.ozonetel.com/ca_apis/CampaignScheduledData');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('apiKey', apiKey);
        req.setBody(jsonData);
        System.debug('jsonData: ' + jsonData);
        Http http = new Http();
        HTTPResponse res = new HttpResponse();
        if(!Test.isRunningTest()){
            res = http.send(req);
        } else {
            res.setBody('{"message": [{"Response": "success","msg": "Data updated successfully","campaign_name": "Scheduled_Call","ExpiryDate": null,"ScheduleTime": "2025-08-08 09:23:00",  "skill": null,"index": 0,"PhoneNumber": "9243562121","AgentID": "Agent","rowId": 34200252}],"status": "success"}');
        }
        ScheduleResponse resBody = new ScheduleResponse();
        System.debug('res.getBody(): ' + res.getBody());
        Map<String, Object> resMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        String status = (String) resMap.get('status');
        if(status != 'error'){
            resBody = (ScheduleResponse)JSON.deserialize(res.getBody(), ScheduleResponse.class);
            System.debug('res.getBody(): ' + res.getBody());
            System.debug('resBody: ' + resBody);
            if(resBody != null && resBody.message != null){
                for(Message msg : resBody.message){
                    if(mobileVsScheduleCall.get(msg.PhoneNumber) != null){
                        mobileVsScheduleCall.get(msg.PhoneNumber).Ozonetel_Row_Id__c = msg.rowId;
                    }
                }
                update mobileVsScheduleCall.values();
            }
        }
        
    }*/
    
       
    @future(callout = true)
    public static void deleteScheduledCall(Set<Id> scIds){
        System.debug('--deleteScheduledCall--');
        
        List<Scheduled_Call__c> scList = [SELECT Id, Mobile_Number__c, Customer_Name__c, Agent_Id__c, Schedule_Date__c, Ozonetel_Row_Id__c FROM Scheduled_Call__c WHERE Id =: scIds AND Ozonetel_Row_Id__c != null];
        String apiKey = System.label.Ozonetel_API_Key;
        for(Scheduled_Call__c sc : scList){
            String jsonData = '{"userName": "runwal", "rowId" : "'+ sc.Ozonetel_Row_Id__c + '"}';
            System.debug('jsonData: ' + jsonData);
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://in1-ccaas-api.ozonetel.com/ca_apis/deleteScheduledData');
            req.setMethod('DELETE');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('apiKey', apiKey);
            req.setBody(jsonData);
            System.debug('jsonData: ' + jsonData);
            System.debug('req: ' + req.getBody());
            Http http = new Http();
            HTTPResponse res = new HttpResponse();
            if(!Test.isRunningTest()){
                res = http.send(req);
            } else {
                res.setBody('{"message":["1"],"status": "success"}');
            }
            System.debug('res.getBody(): ' + res.getBody());
            DeleteResponse resBody = new DeleteResponse();
            resBody = (DeleteResponse)JSON.deserialize(res.getBody(), DeleteResponse.class);
            if(resBody.status == 'success'){
                sc.Deleted_In_Ozonetel__c = true;
            }else{
                sc.Error_Message__c = resBody.message[0];
            }
            /*Map<String, Object> resMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            String status = (String) resMap.get('status');
            if(status == 'success'){
                sc.Deleted_In_Ozonetel__c = true;
            }else{
                List<String> errorMessages = (List<String>) resMap.get('message');
                List<Object> errors = (List<Object>) resMap.get('message');
                List<String> messages = new List<String>();
                for (Object o : errors) {
                    messages.add((String)o);
                }
                sc.Error_Message__c = errorMessages[0];
            }*/
        }
        update scList;
    }
    
    
    public class ScheduleResponse{
        public String status;
        public List<Message> message;
    }
    
    public class Message{
        public String Response;
        public String msg;
        public String campaign_name;
        public String ExpiryDate;
        public String ScheduleTime;
        public String skill;
        public String index;
        public String PhoneNumber;
        public String AgentID;
        public String rowId;
    }
    
    public class DeleteResponse{
        public String status;
        public List<String> message;
    }
}