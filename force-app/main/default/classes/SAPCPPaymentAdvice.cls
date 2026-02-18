public class SAPCPPaymentAdvice {
    public string BlobBody{get;set;}
    public Id cpId{get;set;}
    public String currentFiscalYear{get;set;}
    public String companycode{get;set;}
    public String docno{get;set;}
    Public list<Brokerage_Receipt__c> brokeragereceipt;
    Public list<Legal_Entity__c> legalentity;
    Public SAPCPPaymentAdvice(){
        cpId = ApexPages.currentPage().getParameters().get('id');
        system.debug('cpId::'+cpId);
        brokeragereceipt = new list<Brokerage_Receipt__c>();
        legalentity = new list<Legal_Entity__c>();
        brokeragereceipt = [Select Id,Name,Accounting_Document_No__c,Brokerage_Invoice__r.Booking__r.Project__r.RDS_Company_Code__c from Brokerage_Receipt__c where Id=:cpId];
        legalentity = [Select Id,name,RDS_Company_Code__c from Legal_Entity__c where Id=:brokeragereceipt[0].Brokerage_Invoice__r.Booking__r.Project__r.RDS_Company_Code__c];
        
    }
    Public void sendreq(){
        String currentFiscalYear = [SELECT FiscalYearSettings.Name FROM Period WHERE Type = 'Year' AND StartDate <= TODAY AND EndDate >= TODAY].FiscalYearSettings.Name;
        String companycode = legalentity[0].RDS_Company_Code__c;
        system.debug('companycode::'+companycode);
        String docno = brokeragereceipt[0].Accounting_Document_No__c;
        system.debug('docno::'+docno);
        //currentFiscalYear = '2021';
        //companycode = '6000';
        //docno = '150004286';
        String username = Label.SAP_Username;
        String password = Label.SAP_Password;
        //String username = 'rg_eyteam';
        //String password = 'ey@123';
        
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        //String Endpoint = 'http://123.108.44.40:8002/pdf/PA_PDF?sap-client=210&DOCNO='+docno+'&C_CODE='+companycode+'&FISC_YEAR='+currentFiscalYear+''; //SB
        String Endpoint = 'http://123.108.44.40:8002/pdf/PA_PDF?sap-client=300&DOCNO='+docno+'&C_CODE='+companycode+'&FISC_YEAR='+currentFiscalYear+'';   //PROD
        HttpRequest req = new HttpRequest();
        SAPCPPaymentAdviceParse jsonResponse = new SAPCPPaymentAdviceParse();
        Http http = new Http();
        system.debug('currentFiscalYear::'+currentFiscalYear);
        system.debug('companycode::'+companycode);
        system.debug('docno::'+docno);
        
        system.debug('Endpoint::'+Endpoint);
        req.setEndpoint(Endpoint);
        req.setMethod('GET');
        
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type', 'application/json');
        //req.setBody(body);
        //req.setTimeout(6000);   
        if(!Test.isRunningTest()){
            HttpResponse response1 = http.send(req);
            
            
            system.debug('response1::'+response1.getBody());
            
            jsonResponse = SAPCPPaymentAdviceParse.parse(response1.getBody());
            BlobBody = String.valueOf(jsonResponse.PDF);
            system.debug('BlobBody :: ' + BlobBody );
            system.debug('jsonResponse :: ' + jsonResponse );
        }
    }
    
    
    
}