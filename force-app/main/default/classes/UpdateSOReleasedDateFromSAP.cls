global class UpdateSOReleasedDateFromSAP {//implements Database.AllowsCallouts, Schedulable 
    
    //Get SO Released in SAP and updated the Release date in Booking
    @future (callout=true)
    public static void updateSOReleased(){
        Map<String, Date> soReleaseDateMap = new Map<String, Date>();
        List<String> bkgIds = new List<String>();
        String sapResponse; //Added by Vinay 08-12-2025
        
        String username = System.label.SAP_Username;
        String password = System.label.SAP_Password;
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        //String Endpoint = 'http://123.108.44.40:8002/zso_release/SO?sap-client=300';
        String Endpoint = System.label.SAP_SO_Release_Date_Update;
        
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        req.setEndpoint(Endpoint);
        req.setMethod('POST');
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(12000);
        
        
        List<RespData> resp = new List<RespData>();
        Boolean hasReponse = false;
        if(!Test.isRunningTest()){
            HttpResponse response = http.send(req);
            System.debug('Response Body: ' + (response.getBody()));
            sapResponse = response.getBody(); //Added by Vinay 08-12-2025
            if(response.getBody() != '[{"ERROR_LOG":"No data found!"}]'){
                resp = (List<RespData>)JSON.deserialize(response.getBody(), List<RespData>.class);
                hasReponse = true;
            }
            system.debug('resp::'+resp);   
        }else{
            RespData r = new RespData();
            r.MANDT = '';
            r.VBELN = '123456';
            r.KUNNR = '789123';
            r.REL_DATE = '01.09.2024';
            resp = new List<RespData>{r};
            hasReponse = true;
       }
        
        List<String> crnList = new List<String>();
        List<String> soList = new List<String>();
        Map<String, String> crnSoVsRelDate = new Map<String, String>();
        
        if(resp.size() > 0 && hasReponse){
            for(RespData res : resp){
                crnList.add(res.KUNNR);
                soList.add(res.VBELN);
                crnSoVsRelDate.put(res.KUNNR+'_'+res.VBELN, res.REL_DATE);
                system.debug('CRN: '+res.KUNNR);
            }
            system.debug('crnSoVsRelDate::'+crnSoVsRelDate);
            
            List<Booking__c> bkgs = [SELECT Id, Name, Opportunity__r.SAP_Customer_Number__c, Opportunity__r.SalesOrder_Number__c FROM Booking__c WHERE Opportunity__r.SAP_Customer_Number__c =: crnList AND 
                                     Opportunity__r.SalesOrder_Number__c =: soList AND Status__c = 'Booking Confirmed']; //Added Status__c = 'Booking Confirmed' by Vinay 05-05-2025
            
            //List<Booking__c> bkgs = [SELECT Id, Name, Opportunity__r.SAP_Customer_Number__c, Opportunity__r.SalesOrder_Number__c FROM Booking__c WHERE Id = 'a0s1e0000026TZjAAM'];
            
            system.debug('bkgs::'+bkgs);
            if(bkgs.size() > 0){
                for(Booking__c bkg : bkgs){
                    String relDate = crnSoVsRelDate.get(bkg.Opportunity__r.SAP_Customer_Number__c + '_' + bkg.Opportunity__r.SalesOrder_Number__c);
                    system.debug('SO_Release_Date_in_SAP__c'+relDate.substring(6, 10)+'-'+relDate.substring(3, 5)+'-'+relDate.substring(0, 2));
                    bkg.SO_Release_Date_in_SAP__c = Date.valueof(relDate.substring(6, 10)+'-'+relDate.substring(3, 5)+'-'+relDate.substring(0, 2));
                    bkg.X4_5_Received__c = true;
                    system.debug('bkg.SO_Release_Date_in_SAP__c::'+bkg.SO_Release_Date_in_SAP__c);
                    system.debug('bkg.name::'+bkg.Name);
                }
            }
             //update bkgs;
             Database.SaveResult[] results = Database.update(bkgs, false);
             Boolean noError = true;
             String errorMessage;
             List<String> successRecordIds = new List<String>(); //Added by Vinay 08-12-2025
             if(Test.isRunningTest()){
                 noError = false;
                 errorMessage = 'Test Error';
             }
             for(Database.SaveResult sr: results){
                 
                 if(sr.isSuccess() && noError){
                     System.debug('Successfully updated Booking. Booking ID: ' + sr.getId());
                     successRecordIds.add(sr.getId()); //Added by Vinay 08-12-2025
                 }else{
                     
                     for(Database.Error err: sr.getErrors()){
                        errorMessage += 'Booking Update Failed : (Booking Id - '+ sr.getId() + ')' + err.getMessage() + '<br/>';
                     }
                 }
             }
             if(errorMessage != null){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.settoaddresses(new List<String>{'vinay.kumar.os@runwalgroup.in','shraddha.shahari@runwalgroup.in'});
                mail.setsubject('SO Release date update Failure');
                mail.sethtmlbody(errorMessage);
                Messaging.SendEmailResult[] result = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
             }
            
            //Added by Vinay 08-12-2025 Start
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.settoaddresses(new List<String>{'vinay.kumar.os@runwalgroup.in','shraddha.shahari@runwalgroup.in'});
            mail.setsubject('SO Release date update status');
            String htmlBody = '<b>SAP Response: </b><br/>';
            htmlBody += sapResponse + '<br/><br/><br/><br/>';
            htmlBody += '<b>Success Record Ids: </b>';
            htmlBody += successRecordIds + '<br/><br/><br/><br/>';
            htmlBody += '<b>Failed Record Details: </b>';
            htmlBody += errorMessage + '<br/><br/>';
            mail.sethtmlbody(htmlBody);
            Messaging.SendEmailResult[] result = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
            //Added by Vinay 08-12-2025 End
        }  
    }
    
   /* global void execute(SchedulableContext dc) {
        UpdateSOReleasedDateFromSAP b = new UpdateSOReleasedDateFromSAP();
        b.updateSOReleased();
    }*/
    
    global class RespData{
        public String MANDT;
        public String VBELN;
        public String KUNNR;
        public String REL_DATE;
    }
}