public without sharing class DemandReminderDateUpdate implements Schedulable{
    
    public void execute(SchedulableContext SC){
        updateReminderDate();
    }
	
    @future(callout=true)
    public static void updateReminderDate(){
        
        String username = Label.SAP_Username; 	
        String password = Label.SAP_Password;
        Blob headerValue = Blob.valueOf(username + ':' + password);
        
        Date dt = Date.today() - 1;
        String dtStr = String.valueOf(dt);
        dtStr = dtStr.replace('-','');
        
        Http http = new Http();
        HttpRequest req = new HttpRequest(); 
        req.setMethod('GET');
        req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(headerValue)); 
        //req.setEndpoint('http://123.108.44.40:8002/rem_api/reminder?sap-client=300&getdate='+dtStr);
        req.setEndpoint(System.label.SAP_Demand_Reminder_Date_Endpoint+dtStr);
        
        String respBody;
        if(!Test.isRunningTest()){
            HTTPResponse res = http.send(req);
            System.debug('res!!! getBody '+res.getBody());
            System.debug('res!!! getStatusCode '+res.getStatusCode());
            respBody = res.getBody();
        }else{
            
            respBody = '[{"KUNNR":"123456","VBELN":"98564","REM_DATE":"' + String.valueOf(dt) + '","REM_TYPE":"Reminder 1"}]';
        }
        List<DemandDetails> data = (List<DemandDetails>)JSON.deserialize(respBody, List<DemandDetails>.class);
        System.debug('data: ' + data);
        Map<String, DemandDetails> detailsMap = new Map<String, DemandDetails>();
        for(DemandDetails det : data){
            detailsMap.put(det.VBELN,det);
        }
        List<RW_Demand__c> demands = [SELECT Id, Name, RW_Billing_Document_Number__c FROM RW_Demand__c WHERE RW_Billing_Document_Number__c =: detailsMap.keySet()];
        //List<RW_Demand__c> demands = [SELECT Id, Name, RW_Billing_Document_Number__c FROM RW_Demand__c WHERE Id = 'a1o1e000000AhdMAAS'];
        //demands[0].Reminder_Date__c = Date.valueOf(detailsMap.get('9010183990').REM_DATE);
        //demands[0].Reminder_Type__c = detailsMap.get('9010183990').REM_TYPE;
        //update demands[0];
        
        System.debug('demands: ' + demands.size());
        if(demands.size() > 0){
            for(RW_Demand__c dem : demands){
                dem.Reminder_Date__c = Date.valueOf(detailsMap.get(dem.RW_Billing_Document_Number__c).REM_DATE);
                dem.Reminder_Type__c = detailsMap.get(dem.RW_Billing_Document_Number__c).REM_TYPE;
            }
            update demands;
        }
    }
    
    public class DemandDetails{
        public string KUNNR;
        public string VBELN;
        public string REM_DATE;
        public string REM_TYPE;
        
    }
}