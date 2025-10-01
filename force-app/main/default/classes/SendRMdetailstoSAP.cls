global class SendRMdetailstoSAP {//implements Schedulable,Database.AllowsCallouts 
    
    public static void calloutToSAP(String jsonBody) {
        String username = Label.SAP_Username;
        String password = Label.SAP_Password;
        String endPointURL = Label.SAP_RM_details_Endpoint;
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPointURL);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', authorizationHeader);
        req.setTimeout(12000);
        req.setBody(jsonBody);
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug('Response Status: ' + res.getStatusCode());
        System.debug('Response Body: ' + res.getBody());
    }
    
    
    public static void updateRMUpdationDate(Set<Id> puIds){
        list<Project_Unit__c> putoUpdate = new list<Project_Unit__c>();
        if(!puIds.isEmpty()){
            for(Id puId :  puIds){
                Project_Unit__c pu = new Project_Unit__c();
                pu.Id = puId;
                pu.RM_Updation_Date__c = system.today();
                putoUpdate.add(pu);
            }
        }
        if(!putoUpdate.isEmpty()){
            try{
                update putoUpdate;
            }catch(Exception e){
                system.debug('Error while updating project unit---->>>'+e.getMessage());
            }
        }
    }
    
    public static void updateSourcingM_ClosingM_Updation_Date(Set<Id> oppIds){
        list<Opportunity> oppstoUpdate = new list<Opportunity>();
        if(!oppIds.isEmpty()){
            for(Id oppId : oppIds){
                Opportunity opp = new Opportunity();
                opp.Id = oppId;
                opp.Last_Sourcing_Closing_Mgr_Change__c = system.today();
                oppstoUpdate.add(opp);  
            }
        }
        if(!oppstoUpdate.isEmpty()){
            try{
                update oppstoUpdate;
            }catch(Exception e){
                system.debug('Error while updating Opportunity---->>>'+e.getMessage());
            }
        }
    }
    
    global class ResponseData{
        public String BUKRS;
        public String WERKS;
        public String KUNNR;
        public String MATNR;
        public String SOURCING_MNGR;
        public String CLOSING_MNGR;
        public String RM_NAME;
        public String RM_NUMBER;
        public String RM_EMAIL;
    }
}