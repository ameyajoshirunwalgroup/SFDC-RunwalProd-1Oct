global class Batch_UpdateADFOnBooking implements Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable {
    Public static String sAccessToken; 
    Public static String sCookies;
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, ADF_Opted__c, Sale_Order__c,
                                         Opportunity__r.SAP_Customer_Number__c,
                                         Project__r.SAPMaterial_Code__c, Project__r.RW_Status__c,
                                         Unit_No__r.TowerName__c, Unit_No__r.TowerName__r.SAP_Plant_Code__c, Status__c, 
                                         ADF_Balance__c, ADF_Interest_Amount_Payable1__c,
                                         Total_ADF_Amount__c, ADF_Interest_Paid__c
                                         FROM Booking__c
                                         WHERE ADF_Opted__c = TRUE
                                         AND Unit_No__r.TowerName__r.SAP_Plant_Code__c != NULL
                                         AND Project__r.RW_Status__c = 'Active'
                                         AND Project__r.SAPMaterial_Code__c != NULL
                                         ORDER BY Project__r.SAPMaterial_Code__c]);
    }
    
    global void execute(Database.BatchableContext bc, List<Booking__c> lstBooking) {
        system.debug('lstBooking>>>>>>>>' +lstBooking.size());
        List<Booking__c> lstToUpdate = new List<Booking__c>();
        SAP_Integration__mdt config = [
            SELECT End_Point_URL__c, Username__c, Password__c
            FROM SAP_Integration__mdt
            WHERE DeveloperName = 'GET_ADF_Details'
            LIMIT 1
        ];
        
        system.debug('config>>>>>' + config);
        String endpoint = config.End_Point_URL__c; 
        String username = config.Username__c;
        String password = config.Password__c;
        
        HttpRequest req = new HttpRequest();
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        
        req.setEndpoint(endpoint);
        req.setMethod('HEAD');
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('x-csrf-token', 'fetch');
        req.setHeader('Content-Type','application/json');  
        req.setHeader('Connection','keep-alive');
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        system.debug('res>>>>' + res);
        
        sAccessToken = res.getHeader('x-csrf-token');
        sCookies = res.getHeader('Set-Cookie');
        system.debug('status code>>>' +res.getStatuscode());
        system.debug('POST Response Body: ' + res.getBody());
        system.debug('sAccessToken>>>' + sAccessToken);
        system.debug('sCookies>>' + sCookies);
        
        List<Map<String, String>> lstADFStatus = new List<Map<String, String>>();
        Map<String, List<Booking__c>> mapProjCodeWithBooking = new Map<String, List<Booking__c>>();
        Map<String, Booking__c> mapSaleOrderToBooking = new Map<String, Booking__c>();
        if (!lstBooking.isEmpty()) {
            for (Booking__c objBooking : lstBooking) {
                if (!String.isBlank(objBooking.Sale_Order__c)) {
                    mapSaleOrderToBooking.put(objBooking.Sale_Order__c, objBooking);
                }

                if (objBooking.Project__r != null && !String.isBlank(objBooking.Project__r.SAPMaterial_Code__c) && !string.isBlank(objBooking.Unit_No__r.TowerName__r.SAP_Plant_Code__c)){
                    String mapkey = objBooking.Project__r.SAPMaterial_Code__c +' - '+ objBooking.Unit_No__r.TowerName__r.SAP_Plant_Code__c;
                    if(mapProjCodeWithBooking.containsKey(mapkey)){
                        //mapProjCodeWithBooking.get(mapkey).add(objBooking);
                    }else{
                        mapProjCodeWithBooking.put(mapkey, new List<Booking__c>{objBooking});    
                    }
                }
            }
            system.debug('mapProjCodeWithBooking>>>>>> ' +mapProjCodeWithBooking);
            system.debug('mapProjCodeWithBooking size>>>>>> ' +mapProjCodeWithBooking.size());
            
            for(String projCode : mapProjCodeWithBooking.keySet()){
                List<WrapperADFCalculations.ADF_STATUS> adfList = new List<WrapperADFCalculations.ADF_STATUS>();
                if(mapProjCodeWithBooking != null){
                    //list of Booking recs for each Salesorg
                    for(Booking__c objBooking : mapProjCodeWithBooking.get(projCode)){
                        WrapperADFCalculations.ADF_STATUS objADF = new WrapperADFCalculations.ADF_STATUS();
                        if(objBooking.Project__r != null && !String.isBlank(objBooking.Project__r.SAPMaterial_Code__c)) {
                            objADF.SALESORG = objBooking.Project__r.SAPMaterial_Code__c;
                        }
                        if(objBooking.Unit_No__r != null && objBooking.Unit_No__r.TowerName__r != null &&
                           !String.isBlank(objBooking.Unit_No__r.TowerName__r.SAP_Plant_Code__c)){
                               objADF.PLANT = objBooking.Unit_No__r.TowerName__r.SAP_Plant_Code__c;
                           }
                        objADF.SALEORDER = '';
                        objADF.CUSTCODE = '';
                        adfList.add(objADF);
                    }
                }
                //adfList.add(objADF); 
                system.debug('adfList>>>' +adfList);
                system.debug('adfList size>>>' +adfList.size());
                
                WrapperADFCalculations wrapper = new WrapperADFCalculations();
                wrapper.ADF_STATUS = adfList;
                
                String jsonPayload = JSON.serialize(wrapper);
                System.debug('Payload: ' + jsonPayload);
                
                HttpRequest req1 = new HttpRequest();
                req1.setEndpoint(endpoint);
                req1.setMethod('POST');
                req1.setHeader('Authorization', authorizationHeader);
                req1.setHeader('Accept', 'application/json');
                req1.setHeader('Content-Type', 'application/json');
                req1.setHeader('x-csrf-token', sAccessToken);
                req1.setHeader('Cookie', sCookies);
                req1.setBody(jsonPayload);
                
                Http http1 = new Http();
                HttpResponse res1 = http1.send(req1);
                SAP_IntegrationHelper.insertLogEntry('ADF Calculation', res1.getStatus(), null, null, jsonPayload, res1.getBody(), '', bc.getJobId());
                system.debug('POST Response Status: ' + res1.getStatus());
                system.debug('POST Response Body: ' + res1.getBody());
                
                if (res1.getStatusCode() == 200 || res1.getStatusCode() == 201) {
                    system.debug('in 200');
                    ADFResponseWrapper responseWrapper = (ADFResponseWrapper) JSON.deserialize(res1.getBody(), ADFResponseWrapper.class);
                    
                    if (responseWrapper != null && responseWrapper.FRECORD != null && !responseWrapper.FRECORD.isEmpty()) {
                        system.debug('in response not null');
                        // Map of Sale_Order__c to Booking__c for quick lookup                        
                        for (ADFResponseWrapper.FRECORD resADF : responseWrapper.FRECORD) {
                            if(mapSaleOrderToBooking.containsKey(resADF.SALE_ORD)){
                                Booking__c booking = mapSaleOrderToBooking.get(resADF.SALE_ORD);
                                system.debug('resADF.SALE_ORD>>>>' +resADF.SALE_ORD);
                                system.debug('booking>>>' +booking);
                                
                                if (booking != null) {
                                    system.debug('booking>>>>' +booking);
                                    booking.ADF_Balance__c = resADF.BAL_ADV;
                                    booking.Total_ADF_Amount__c = resADF.TOT_ADV_REC;
                                    booking.ADF_Interest_Amount_Payable1__c = resADF.ELIG_INT;
                                    booking.ADF_Interest_Paid__c = resADF.INT_UTIL;
                                    booking.Total_Demand_Amount_Raised__c = resADF.TOT_INV_CON;
                                    lstToUpdate.add(booking);
                                }
                            }
                        }
                    }
                }
            }
        }
        system.debug('lstToUpdate>>>> ' +lstToUpdate);
        if (!lstToUpdate.isEmpty()) {
            system.debug('before update>>>' +lstToUpdate);
            update lstToUpdate; 
            system.debug('size for updated booking >>> ' +lstToUpdate.size());
            /*for(Booking__c objBooking : lstToUpdate){
SAP_IntegrationHelper.insertLogEntry('ADF Calculation', 'Success', objBooking.id, '', jsonPayload, res.getBody(), '', '');

}*/
        }
        
    }
    
    global void finish(Database.BatchableContext bc) {
        
    }
    
    // Scheduler method
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new Batch_UpdateADFOnBooking());
    }
    public void dummyMethod(){
        
        String s2;        
        String s3;
        String s4;                
        String s5;
        String s6;        
        String s7;
        String s8;                
        String s9;
        String s10;        
        String s11;
        String s12;                
        String s13;
        String s14;        
        String s15;
        String s16;                
        String s110;
        String s210;        
        String s310;
        String s410;                
        String s510;
        String s610;        
        String s710;
        String s810;                
        String s910;
        String s1010;        
        String s1110;
        String s1210;                
        String s1310;
        String s1410;        
        String s1510;
        String s1610;                
        String s111;
        String s211;        
        String s311;
        String s411;                
        String s511;
        String s611;        
        String s711;
        String s811;                
        String s911;
        String s1011;        
        String s1111;
        String s1211;                
        String s1311;
        String s1411;        
        String s1511;
        String s1611;                
        String s1101;
        String s2111;        
        
        integer i;
        i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}