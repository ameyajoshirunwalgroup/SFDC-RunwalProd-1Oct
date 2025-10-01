global class DateOf5n10n20PercentReceivedSyncFromSAP implements Database.Batchable <sObject>, Database.AllowsCallouts, Schedulable, Database.Stateful{
    
    global Map<String, String> crnSoVsRelDate5 = new Map<String, String>();
    global Map<String, String> crnSoVsRelDate10 = new Map<String, String>();
    global Map<String, String> crnSoVsRelDate20 = new Map<String, String>();//Added by Prashant to store 20% Date and Amt. 
    global Iterable<Booking__c> start(Database.BatchableContext BC){
        String username = System.label.SAP_Username;
        String password = System.label.SAP_Password;
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        //String Endpoint = 'http://123.108.44.40:8002/zsfdc_perc_sync/perc_sync?sap-client=300';
        String Endpoint = System.label.Date_of_5_10_received_sync;
        
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        req.setEndpoint(Endpoint);
        req.setMethod('GET');
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(120000);
        
        List<RespData> resp = new List<RespData>();
        Boolean hasReponse = false;
        if(!Test.isRunningTest()){
            HttpResponse response = http.send(req);
            if(response.getBody() != '[{"ERROR_LOG":"No data found!"}]'){
                resp = (List<RespData>)JSON.deserialize(response.getBody(), List<RespData>.class);
                hasReponse = true;
            }
        }else{
            RespData r = new RespData();
            r.VBELN = '123456';
            r.KUNNR = '789123';
            r.AMT_5P = 10000;
            r.DATE_5P = '2025-01-01';
            r.AMT_10P = 100000;
            r.DATE_10P = '2025-08-01';
            r.AMT_20P = 100000;
            r.DATE_20P = '2025-08-01';
            resp = new List<RespData>{r};
            hasReponse = true;
        }
        
        List<String> crnList = new List<String>();
        List<String> soList = new List<String>();
        
        List<Booking__c> bkgs = new List<Booking__c>(); 
        if(resp.size() > 0 && hasReponse){
            for(RespData res : resp){
                crnList.add(res.KUNNR);
                soList.add(res.VBELN);
                crnSoVsRelDate5.put(res.KUNNR+'_'+res.VBELN, res.DATE_5P);
                crnSoVsRelDate10.put(res.KUNNR+'_'+res.VBELN, res.DATE_10P);
                crnSoVsRelDate20.put(res.KUNNR+'_'+res.VBELN, res.DATE_20P);
            }
            
            bkgs = [SELECT Id, Name, Opportunity__r.SAP_Customer_Number__c, Opportunity__r.SalesOrder_Number__c FROM Booking__c WHERE Opportunity__r.SAP_Customer_Number__c =: crnList AND Opportunity__r.SalesOrder_Number__c =: soList];
            return bkgs;
        }else{
            return bkgs;
        }
            
    }
    
    global void execute(Database.BatchableContext bc, list <Booking__c> bookings){
        if(bookings.size() > 0){
            for(Booking__c bkg : bookings){
                String relDate5 = crnSoVsRelDate5.get(bkg.Opportunity__r.SAP_Customer_Number__c + '_' + bkg.Opportunity__r.SalesOrder_Number__c);
                String relDate10 = crnSoVsRelDate10.get(bkg.Opportunity__r.SAP_Customer_Number__c + '_' + bkg.Opportunity__r.SalesOrder_Number__c);
                String relDate20 = crnSoVsRelDate20.get(bkg.Opportunity__r.SAP_Customer_Number__c + '_' + bkg.Opportunity__r.SalesOrder_Number__c);
                bkg.X5_Received_Date__c = (relDate5 != '' && relDate5 != '--')? Date.valueof(relDate5) : null;
                bkg.X9_90_Received_Date__c = (relDate10 != '' && relDate10 != '--')? Date.valueof(relDate10) : null;
                bkg.X20_Received_Date__c = (relDate20 != '' && relDate20 != '--')? Date.valueof(relDate20) : null;
            }
            //update bookings;
            Database.update(bookings, false);
        }
    }
    
    global void finish(Database.BatchableContext bc){
        
    }
    
    global void execute(SchedulableContext dc) {
        DateOf5n10n20PercentReceivedSyncFromSAP b = new DateOf5n10n20PercentReceivedSyncFromSAP();
        Database.executeBatch(b, 20);
    }
    
    global class RespData{
        public String VBELN;
        public String KUNNR;
        public Decimal AMT_5P;
        public String DATE_5P;
        public Decimal AMT_10P;
        public String DATE_10P;
        public Decimal AMT_20P;
        public String DATE_20P;
    }
}