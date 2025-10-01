public class SAPCreditNotADFAPICallout implements Queueable, Database.AllowsCallouts {
    
    public String sAccessToken; 
    public String sEndPoint;
    public String sUserName;
    public String sPassword;
    public String sCookies;
    
    private List<Id> CNIds;
    
    public SAPCreditNotADFAPICallout(List<Id> CNIds) {
        this.CNIds = CNIds;
    }
    
    public HttpResponse GenrateAccessToken() {
        HttpResponse res;
        try {
            String csrf_token = 'fetch';
            SAP_Integration__mdt config = [SELECT End_Point_URL__c, Username__c, Password__c 
                                           FROM SAP_Integration__mdt 
                                           WHERE DeveloperName = 'POST_CreditNote' LIMIT 1];
            
            if (config != null) {
                sEndPoint = config.End_Point_URL__c;
                sUserName = config.Username__c;
                sPassword = config.Password__c;
            }
            
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            
            Blob headerValue = Blob.valueOf(sUserName + ':' + sPassword);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            system.debug('authorizationHeader>>>>' +authorizationHeader);
            req.setEndpoint(sEndPoint);
            req.setMethod('HEAD');
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('content-type', 'application/json');
            req.setHeader('x-csrf-token', csrf_token);
            
            res = http.send(req);
            
            sAccessToken = res.getHeader('x-csrf-token');
            sCookies = res.getHeader('Set-Cookie');
            
            System.debug('AccessToken: ' + sAccessToken);
            System.debug('Cookies: ' + sCookies);
        } catch (Exception e) {
            System.debug('Error while generating CSRF token: ' + e.getMessage());
        }
        return res;
    }
    
    public void execute(QueueableContext context) {
        System.debug('CNIds: ' + CNIds);
        List<Credit_Note__c> lstCNUpdate = new List<Credit_Note__c>();
        
        try {
            if (CNIds == null || CNIds.isEmpty()){
                return;
            }
            GenrateAccessToken();
            
            List<Credit_Note__c> lstCN = [SELECT Id, Name, Booking__r.Opportunity__r.SAP_Customer_Number__c, Customer_Name__c,
                                          Interest_To_Be_Settled__c, Booking__r.Sale_Order__c, Reason_For_Settlement__c,
                                          Booking__r.Project__r.SAPMaterial_Code__c,Booking__r.Project__r.RW_SAP_Company_Code__c,
                                          ADF_Final_Approval_Date__c,CreatedDate, Sent_to_SAP__c
                                          FROM Credit_Note__c 
                                          WHERE Approval_Status__c = 'Approved' AND Id IN :CNIds];
            system.debug('lstCN>>>>>' +lstCN);
            
            if (lstCN == null || lstCN.isEmpty()){
                return;
            } 
            SAP_Integration__mdt config = [SELECT End_Point_URL__c, Username__c, Password__c // CSRF_Token__c 
                                           FROM SAP_Integration__mdt 
                                           WHERE DeveloperName = 'POST_CreditNote' LIMIT 1];
            system.debug('config>>>>' +config);
            
            List<WrapperADFCreditNote.ADF_CRN_Item> lstWrapp = new List<WrapperADFCreditNote.ADF_CRN_Item>();
            if(!lstCN.isEmpty() && lstCN.size()>0){
                system.debug('in if>>>> ');
                for (Credit_Note__c objCN : lstCN) {
                    system.debug('in for>>>>');
                    Date postingDate = objCN.ADF_Final_Approval_Date__c;        
                    String formattedPostingDate = String.valueOf(postingDate.year()) +(postingDate.month() < 10 ? '0' + postingDate.month() : String.valueOf(postingDate.month())) +(postingDate.day() < 10 ? '0' + postingDate.day() : String.valueOf(postingDate.day()));
                    String formattedDocDate;
                    Datetime documentDate = objCN.CreatedDate; 
                    formattedDocDate = documentDate.format('yyyyMMdd').trim();
                    
                    WrapperADFCreditNote.ADF_CRN_Item objADF_CN = new WrapperADFCreditNote.ADF_CRN_Item();
                    if(objCN.Booking__c != null && objCN.Booking__r.Opportunity__c != null && objCN.Booking__r.Opportunity__r.SAP_Customer_Number__c != null){
                        objADF_CN.Customer = objCN.Booking__r.Opportunity__r.SAP_Customer_Number__c;
                    }
                    else{
                        objADF_CN.Customer = '';
                    }
                    if(objCN.Booking__c!= null && objCN.Booking__r.Project__c != null && objCN.Booking__r.Project__r.RW_SAP_Company_Code__c != null){
                        objADF_CN.Comp_Code  = objCN.Booking__r.Project__r.RW_SAP_Company_Code__c;
                    }
                    else{
                        objADF_CN.Comp_Code = '';
                    }
                    if(formattedDocDate != null){
                        objADF_CN.Doc_Date   = formattedDocDate;
                    }
                    else {
                        objADF_CN.Doc_Date = ''; 
                    }
                    if(formattedPostingDate != null){
                        objADF_CN.Pstng_Date = formattedPostingDate;
                    }
                    else {
                        objADF_CN.Pstng_Date = ''; 
                    }
                    if(documentDate != null){
                        objADF_CN.Fisc_Year  = String.valueOf(documentDate.year());
                    } 
                    else{
                        objADF_CN.Fisc_Year = '';
                    }
                    if(objCN.Booking__c != null && objCN.Booking__r.Sale_Order__c != null){
                        objADF_CN.Ref_Doc_No = objCN.Name;
                    }
                    else{
                        objADF_CN.Ref_Doc_No = ''; 
                    }
                    if(!string.isBlank(objCN.Customer_Name__c)){
                        objADF_CN.Header_Txt = objCN.Customer_Name__c;
                    }
                    else{
                        objADF_CN.Header_Txt = '';
                    }
                    if(objCN.Reason_For_Settlement__c != null){
                        objADF_CN.Item_Text  = objCN.Reason_For_Settlement__c;
                    }
                    else{
                        objADF_CN.Item_Text = '';
                    }
                    objADF_CN.sCurrency   = 'INR';
                    if(objCN.Interest_To_Be_Settled__c != null){
                        objADF_CN.Amount = String.ValueOf(objCN.Interest_To_Be_Settled__c);
                    }
                    else{
                        objADF_CN.Amount = '';
                    }
                    lstWrapp.add(objADF_CN);
                    system.debug('lstWrapp>>>> ' +lstWrapp);
                    WrapperADFCreditNote wrapper = new WrapperADFCreditNote();
                    wrapper.ADF_CRN = lstWrapp;
                    String jsonPayload = JSON.serialize(wrapper);
                    System.debug('Payload: ' + jsonPayload);
                    system.debug('sAccessToken>>>>' +sAccessToken);
                    
                    Http http = new Http();
                    HttpRequest req = new HttpRequest();
                    Blob headerValue = Blob.valueOf(sUserName + ':' + sPassword);
                    String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
                    
                    req.setEndpoint(sEndPoint);
                    req.setMethod('POST');
                    req.setHeader('Authorization', authorizationHeader);
                    req.setHeader('content-type', 'application/json');
                    req.setHeader('x-csrf-token', sAccessToken);
                    req.setHeader('Cookie', sCookies);
                    req.setHeader('Connection', 'keep-alive');
                    req.setBody(jsonPayload);
                    
                    HttpResponse res = http.send(req);
                    
                    System.debug('SAP Response Status: ' + res.getStatus());
                    System.debug('SAP Response Code: ' + res.getStatusCode());
                    System.debug('SAP Response Body: ' + res.getBody());
                    
                    if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
                        WrapperResponseADFCreditNote resWrapp = (WrapperResponseADFCreditNote) JSON.deserialize(res.getBody(), WrapperResponseADFCreditNote.class);
                        system.debug('resWrapp>>.' +resWrapp);
                        if (resWrapp != null && resWrapp.FRECORD != null && !resWrapp.FRECORD.isEmpty()) {
                            system.debug('in if>>.' +resWrapp);
                            for (WrapperResponseADFCreditNote.FRECORD record : resWrapp.FRECORD) {
                                if (record.STATUS == 'Failure') {
                                    system.debug('in fail>>.' +record.STATUS);
                                    objCN.Sent_to_SAP__c = false;
                                    SAP_IntegrationHelper.insertLogEntry('ADF Credit Note', 'Failure', objCN.Id, objCN.Booking__c,jsonPayload, res.getBody(), record.INV_DOC_MSG, '');
                                }else if(record.STATUS == 'Success'){
                                    objCN.Sent_to_SAP__c = true;
                                    SAP_IntegrationHelper.insertLogEntry('ADF Credit Note', 'Success', objCN.Id, objCN.Booking__c, jsonPayload, res.getBody(), '', '');
                                }
                                lstCNUpdate.add(objCN);
                            }
                        }
                    }
                    
                    if (!lstCNUpdate.isEmpty()) {
                        System.debug('Sent to SAP ?' +lstCNUpdate);
                        update lstCNUpdate;
                    }
                }
            }
        } catch (Exception outerEx) {
            System.debug('Unexpected error in execute(): ' + outerEx.getMessage());
            SAP_IntegrationHelper.insertLogEntry('ADF Credit Note', 'Failure', '', '', '', '', outerEx.getMessage(), '');           
        }
    }
}