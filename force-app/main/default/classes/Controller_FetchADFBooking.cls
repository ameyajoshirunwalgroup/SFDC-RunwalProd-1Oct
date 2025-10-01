public with sharing class Controller_FetchADFBooking {
    
    Public static String sAccessToken; 
    Public static String sCookies;
    
    private static Void fetchCSRFToken(String endpoint, String username, String password) {
        system.debug('endpoint>>>' +endpoint);
        system.debug('username>>>' +username);
        system.debug('password>>>' +password);
        
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
        system.debug('res>>>>' +res);
        sAccessToken = res.getHeader('x-csrf-token');
        sCookies = res.getHeader('Set-Cookie');
        
        system.debug('sAccessToken>>>'+sAccessToken);
        system.debug('sCookies>>'+sCookies);
    }
    
    
    @AuraEnabled
    public static void fetchADFDetail(Id bookingId) {
        //  try {
        Booking__c objBooking = [SELECT Id, ADF_Opted__c, Sale_Order__c, Opportunity__r.SAP_Customer_Number__c,
                                 Project__r.RW_Project_Code__c,Project__r.SAPMaterial_Code__c,
                                 Unit_No__r.TowerName__c,  Unit_No__r.TowerName__r.SAP_Plant_Code__c,
                                 ADF_Balance__c,ADF_Interest_Amount_Payable1__c,Total_ADF_Amount__c,ADF_Interest_Paid__c
                                 FROM Booking__c
                                 WHERE Id = :bookingId AND ADF_Opted__c = true];
        
        system.debug('objBooking>>>>' +objBooking);
        
        SAP_Integration__mdt config = [SELECT End_Point_URL__c, Username__c, Password__c
                                       FROM SAP_Integration__mdt
                                       WHERE DeveloperName = 'GET_ADF_Details'
                                       LIMIT 1];
        
        
        String endpoint = config.End_Point_URL__c;
        
        if(objBooking != null){
            system.debug('in if');
            List<WrapperADFCalculations.ADF_STATUS> lstWrapp = new List<WrapperADFCalculations.ADF_STATUS>();
            WrapperADFCalculations.ADF_STATUS objADF = new WrapperADFCalculations.ADF_STATUS();
            
            if(!String.isBlank(objBooking.Project__r.SAPMaterial_Code__c)){
                objADF.SALESORG = objBooking.Project__r.SAPMaterial_Code__c;
            } 
            if(objBooking.Unit_No__r != null && objBooking.Unit_No__r.TowerName__r != null &&
               !String.isBlank(objBooking.Unit_No__r.TowerName__r.SAP_Plant_Code__c)){
                   objADF.PLANT = objBooking.Unit_No__r.TowerName__r.SAP_Plant_Code__c;
               }
            if(!String.isBlank(objBooking.Opportunity__r.SAP_Customer_Number__c)){
                objADF.CUSTCODE = objBooking.Opportunity__r.SAP_Customer_Number__c;
            }
            else{
                objADF.CUSTCODE = '';
            }
            
            if(!String.isBlank(objBooking.Sale_Order__c)){
                objADF.SALEORDER = objBooking.Sale_Order__c;
            }
            else{
                objADF.SALEORDER = '';
            }
            
            lstWrapp.add(objADF);
            system.debug('lstWrapp>>>>'+lstWrapp);
            
            WrapperADFCalculations wrapper = new WrapperADFCalculations();
            wrapper.ADF_STATUS = lstWrapp;
            
            String jsonPayload = JSON.serialize(wrapper);
            System.debug('Payload: ' + jsonPayload);
            fetchCSRFToken(config.End_Point_URL__c, config.Username__c, config.Password__c);
            // FIXED: HTTP Request for GET method without body
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            
            Blob headerValue = Blob.valueOf(config.Username__c + ':' + config.Password__c);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            
            // Build query parameters instead of using request body for GET
            /*   String queryParams = '?';
if(!String.isBlank(objADF.CUSTCODE)){
queryParams += 'CUSTCODE=' + EncodingUtil.urlEncode(objADF.CUSTCODE, 'UTF-8') + '&';
}
if(!String.isBlank(objADF.SALEORDER)){
queryParams += 'SALEORDER=' + EncodingUtil.urlEncode(objADF.SALEORDER, 'UTF-8') + '&';
}
if(!String.isBlank(objADF.SALESORG)){
queryParams += 'SALESORG=' + EncodingUtil.urlEncode(objADF.SALESORG, 'UTF-8') + '&';
}

// Remove trailing '&' if exists
if(queryParams.endsWith('&')){
queryParams = queryParams.substring(0, queryParams.length() - 1);
}
*/
            // Set endpoint with query parameters
            req.setEndpoint(endpoint);// + queryParams);
            system.debug('Final endpoint with params: ' + endpoint);// + queryParams);
            
            req.setMethod('POST');
            req.setHeader('Authorization', authorizationHeader);
            system.debug('authorizationHeader>>>' + authorizationHeader);
            req.setHeader('Accept', 'application/json');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Connection', 'keep-alive');
            req.setHeader('Accept-Encoding', 'gzip, deflate, br');
            req.setHeader('x-csrf-token', sAccessToken);
            req.setHeader('Cookie', sCookies);
            // DO NOT set body for GET requests in Salesforce
            req.setBody(jsonPayload); // This was causing the issue
            
            HttpResponse res = http.send(req);
            
            system.debug('res>>>>' + res.getStatusCode());
            system.debug('res>>>>' + res.getStatus());
            system.debug('Response body>>>>>' + res.getBody());
            
            if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
                ADFResponseWrapper responseWrapper = (ADFResponseWrapper) JSON.deserialize(res.getBody(), ADFResponseWrapper.class);
                Boolean isUpdated = false;
                if (responseWrapper != null && responseWrapper.FRECORD != null && !responseWrapper.FRECORD.isEmpty()) {
                    for (ADFResponseWrapper.FRECORD resADF : responseWrapper.FRECORD) {
                        //  if(resADF.SALE_ORD == objBooking.Sale_Order__c  && (resADF.CUST_CODE == objBooking.Opportunity__r.SAP_Customer_Number__c )){ // || resADF.CUST_CODE.StartsWith('00' +objBooking.Opportunity__r.SAP_Customer_Number__c ) 
                        objBooking.ADF_Balance__c = resADF.BAL_ADV;
                        objBooking.Total_ADF_Amount__c = resADF.TOT_ADV_REC;
                        objBooking.ADF_Interest_Amount_Payable1__c = resADF.ELIG_INT;
                        objBooking.ADF_Interest_Paid__c = resADF.INT_UTIL;
                        objBooking.Total_Demand_Amount_Raised__c = resADF.TOT_INV_CON;
                        isUpdated = true;
                        // }
                    }
                }
                
                if(isUpdated){
                    system.debug('in update operation');
                    update objBooking;
                  SAP_IntegrationHelper.insertLogEntry('ADF Calculation', 'Success', objBooking.id, '', jsonPayload, res.getBody(), '', '');
                } else {
                    SAP_IntegrationHelper.insertLogEntry('ADF Calculation', 'Failed', objBooking.id, '', jsonPayload, res.getBody(), '', '');
                    throw new AuraHandledException('No matching ADF record found for the given Booking.');
                    
                }
                
            } else {
                 SAP_IntegrationHelper.insertLogEntry('ADF Calculation', 'Failed', objBooking.id, '', jsonPayload, res.getBody(), '', '');
                throw new AuraHandledException('Failed to fetch from SAP. Status: ' + res.getStatus());
            }
        }
        else{
            throw new AuraHandledException('ADF is not opted for this Booking');
        }
    }
}