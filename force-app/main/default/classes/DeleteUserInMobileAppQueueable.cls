public class DeleteUserInMobileAppQueueable implements Queueable, Database.allowscallouts{
    
    public set<Id> accIds = new set<Id>();
    
    public DeleteUserInMobileAppQueueable(set<Id> acIds){
        accIds = acIds;
    }
    public void execute(QueueableContext context) {
        
        List<Society_Id__mdt> socityIds = [SELECT Id, Label, Value__c FROM Society_Id__mdt];
        Map<String, Country_Codes__c> countryNameCodes = Country_Codes__c.getall();
        Map<String, String> projNameVsSocityId = new Map<String, String>();
        for(Society_Id__mdt rec : socityIds){
            projNameVsSocityId.put(rec.Label, rec.Value__c);
        }
        System.debug('accIds: ' + accIds);
        
        List<Opportunity> opps = [SELECT Id, Name, AccountId, Account.FirstName, Account.LastName, Account.PersonEmail,Account.RW_Country__c,
                           Account.Mobile_No__c, Account.Ownership, RW_Project_Unit__r.RW_Param4__c,  Account.Country_Code__c,
                           RW_Project_Unit__r.RW_Param2__c, SAP_Customer_Number__c, Booking__c, RW_Project__r.Name
                           FROM Opportunity WHERE AccountId =: accIds AND Booking__r.Status__c IN ('Booking Cancelled – Refund Pending','Cancellation Initiated','Cancelled')];
        List<ERP_Integration_Log__c> logList = new List<ERP_Integration_Log__c>();
        for(Opportunity opp : opps){
            ERP_Integration_Log__c log = new ERP_Integration_Log__c();
            try{
                HttpRequest request = new HttpRequest();
                HttpResponse response = new HttpResponse();
                Http http = new Http();
                
                String str = '';
                Map<String,String> data = new Map<String,String>();
                data.put('customer_code', opp.SAP_Customer_Number__c);
                data.put('booking_number', opp.Booking__c);
                data.put('society_id', projNameVsSocityId.get(opp.RW_Project__r.Name));
                System.debug(JSON.Serialize(data));
                request.setEndpoint('https://snagging.lockated.com.invalid/runwal_remove_user_sap.json');//(.invalid) Added by Prashant
                request.setHeader('Content-Type', 'application/json');
                request.setMethod('POST');
                request.setHeader('Authorization', '0d93e348a9262bc36c2eb86612f119abe803f368ad503eb9');
                request.setTimeout(120000);
                request.setBody(JSON.Serialize(data));
                response = http.send(request);
                if(response.getStatusCode() == 200){
                    System.debug('Response: ' + response);
                }else{
                    
                    log.API_Name__c = 'User Creation/Delete';
                    log.Opportunity__c = opp.Id;
                    log.Request__c = JSON.Serialize(data);
                    log.Response__c = response.getStatus();
                    logList.add(log);
                }
            }catch(System.CalloutException e){
                System.debug('Error: ' + e.getMessage()); 
                log.Error_Reason__c =  e.getMessage();
            }finally{
                //logList.add(log);
            }
        }

        if(logList.size()>0){
            insert logList;
        }
        
    }
}