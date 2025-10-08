global class DeleteScheduledCalls  implements Schedulable{
    
    global void execute(SchedulableContext sc){
        
        List<Scheduled_Call__c> scList = [SELECT Id, Mobile_Number__c, Customer_Name__c, Agent_Id__c, Schedule_Date__c, Ozonetel_Row_Id__c FROM Scheduled_Call__c WHERE CreatedDate = TODAY AND Ozonetel_Row_Id__c != null];
        String apiKey = System.label.Ozonetel_API_Key;
        System.debug('scList: ' + scList);
        for(Scheduled_Call__c sch : scList){
            String jsonData = '{"userName": "runwal", "rowId" : "'+ sch.Ozonetel_Row_Id__c + '"}';
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
                sch.Deleted_In_Ozonetel__c = true;
            }else{
                sch.Error_Message__c = resBody.message[0];
            }
        }
        update scList;
        
    }
        
    public class DeleteResponse{
        public String status;
        public List<String> message;
    }

}