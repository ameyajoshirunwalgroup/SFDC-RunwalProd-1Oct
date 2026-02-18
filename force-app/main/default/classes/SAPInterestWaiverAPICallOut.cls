Public Class SAPInterestWaiverAPICallOut implements Queueable, Database.AllowsCallouts {
    Public String sAccessToken; 
    Public String sEndPoint;
    Public  String sUserName;
    Public  String sPassword;
    public String cookies;
       
    private List<Id> waiverIds;
    public SAPInterestWaiverAPICallOut(List<Id> IWIds) {
        this.waiverIds = IWIds;
    }
    Public HTTPResponse GenrateAccessToken(){ 
        
        String csrf_token = 'fetch';
        SAP_Integration__mdt Config = [Select Id,DeveloperName, End_Point_URL__c, Username__c, Password__c From SAP_Integration__mdt 
                                       Where DeveloperName = 'Post_Interest_Waiver'];
        if(Config != null){
            sEndPoint = Config.End_Point_URL__c;
            sUserName = Config.Username__c;
            sPassword = Config.Password__c;
        }
        
        HTTP http = new HTTP();
        HttpRequest req = new HttpRequest();
        
        Blob headerValue = Blob.valueOf(sUserName + ':' + sPassword);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setEndpoint(sEndPoint);
        req.setMethod('HEAD');
        req.setHeader('Authorization', authorizationHeader);
        System.debug('authorizationHeader>>>>>>>' +authorizationHeader);
        
        req.setHeader('content-type','application/XML');  
        req.setHeader('Connection','keep-alive');
        req.setHeader('x-csrf-token',csrf_token);              
        System.debug(req.getBody());
        
        HttpResponse res = http.send(req);
        sAccessToken = res.getHeader('x-csrf-token');   
        cookies = res.getHeader('Set-Cookie');
        System.debug('sAccessToken1>>>>>' +sAccessToken);
        System.debug('cookies>>>>>' +cookies);
        System.debug(res.getBody());     
        System.debug(res.getStatusCode());
        system.debug(res.getHeaderKeys());
       /* if(lstIW != null || !lstIW.isEmpty()){
            ProcessInterestWaivers(lstIW, sAccessToken);
            system.debug('ProcessInterestWaivers' +lstIW +sAccessToken);
        }*/
        return res;  
    }
    //Public Void ProcessInterestWaivers(List<Id> lstIW){ 
    public void execute(QueueableContext context) {
        system.debug('waiverIds>>>>>' +waiverIds);
        Set<Id> setWaiverId = new Set<Id>();
        this.GenrateAccessToken();
        System.debug('sAccessToken2>>>>' +sAccessToken);
        List<Interest_Waiver__c> lstIWUpdate = new List<Interest_Waiver__c>();
        if(!waiverIds.isEmpty()){
            for(Id IWids :waiverIds){
                setWaiverId.add(IWids);
            }
        }
        system.debug('setWaiverId>>>>>>' +setWaiverId);
        
        List<Interest_Waiver__c> lstWaiver = [SELECT Id, Balance_Installment__c, Interest_Amount__c, Waiver_Amount__c, Approval_Status__c,
                                              Booking__c, Booking__r.Sale_Order__c, Booking__r.Opportunity__r.SAP_Customer_Number__c, Is_Send_To_SAP__c
                                              FROM Interest_Waiver__c WHERE Approval_Status__c  = 'Approved' AND Id IN: setWaiverId];
        
        if(!lstWaiver.isEmpty() && lstWaiver.size()>0){
            for (Interest_Waiver__c objWaiver : lstWaiver) {

                String salesDoc = objWaiver.Booking__r != null ? escapeXml(objWaiver.Booking__r.Sale_Order__c) : '';
                String custNumber = (objWaiver.Booking__r != null && objWaiver.Booking__r.Opportunity__r != null)
                    ? escapeXml(objWaiver.Booking__r.Opportunity__r.SAP_Customer_Number__c)
                    : '';
                String balIntAmt = objWaiver.Balance_Installment__c != null ? String.valueOf(objWaiver.Balance_Installment__c) : '0.00';
                String intAmt = objWaiver.Interest_Amount__c != null ? String.valueOf(objWaiver.Interest_Amount__c) : '0.00';
                String waivedAmt = objWaiver.Waiver_Amount__c != null ? String.valueOf(objWaiver.Waiver_Amount__c) : '0.00';
                
                // Build XML Payload
                    String xmlPayload = '<?xml version="1.0" encoding="utf-8"?>'
                    + '<entry xml:base="http://123.108.44.40:8002/sap/opu/odata/sap/ZSD_INTEREST_WAIVER_SRV/Interest_waiverSet"'
                    + ' xmlns="http://www.w3.org/2005/Atom"'
                    + ' xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata"'
                    + ' xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices">'
                    + '<content type="application/xml">'
                    + '    <m:properties>'
                    + '        <d:SalesDoc>' + salesDoc + '</d:SalesDoc>'
                    + '        <d:CustNumber>' + custNumber + '</d:CustNumber>'
                    + '        <d:BalIntAmt>' + balIntAmt + '</d:BalIntAmt>'
                    + '        <d:IntAmt>' + intAmt + '</d:IntAmt>'
                    + '        <d:IntWaivedAmt>' + waivedAmt + '</d:IntWaivedAmt>'
                    + '        <d:Adjusted>Y</d:Adjusted>'
                    + '        <d:AdjWaivedOffAmt>' + waivedAmt + '</d:AdjWaivedOffAmt>'
                    + '    </m:properties>'
                    + '</content>'
                    + '</entry>';
                
                system.debug('xmlPayload>>>>> ' +xmlPayload);
                system.debug('sEndPoint>>>>' +sEndPoint);
                system.debug('sUserName>>>>' +sUserName);
                system.debug('sPassword>>>>' +sPassword);
                system.debug('sAccessToken>>>>' +sAccessToken);
                Http http = new Http();
                HttpRequest req = new HttpRequest();
                
                Blob headerValue = Blob.valueOf(sUserName + ':' + sPassword);
                String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
                req.setEndpoint(sEndPoint);
                req.setMethod('POST');
                req.setHeader('Connection','keep-alive');
                req.setHeader('Authorization', authorizationHeader);
                req.setHeader('content-type','application/XML');        
                req.setHeader('x-csrf-token',sAccessToken); 
                req.setHeader('Cookie', cookies);
                system.debug('x-csrf-token>>>>>' +sAccessToken);
                req.setBody(xmlPayload);
                
                
                HttpResponse res = http.send(req);
                
                System.debug('SAP Response Status: ' + res.getStatus());
                System.debug('SAP Response Body: ' + res.getBody());
                 System.debug('SAP Response code: ' + res.getStatusCode());
                if(res.getStatus() == 'Created' && (res.getStatusCode() == 201 || res.getStatusCode() == 200)){
                    for(Interest_Waiver__c objIW : lstWaiver){
                        objIW.Is_Send_To_SAP__c = True;
                        lstIWUpdate.add(objIW);
                    }
                }
            }
        }
        
        if(!lstIWUpdate.isEmpty()){
            Update lstIWUpdate;
        }
    }
    
    Public static String escapeXml(String value) {
        if (value == null) return '';
        return value
            .replace('&', '&amp;')
            .replace('<', '&lt;')
            .replace('>', '&gt;')
            .replace('"', '&quot;')
            .replace('\'', '&apos;');
    }
    
}