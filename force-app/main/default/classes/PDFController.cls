public class PDFController {

    
    @AuraEnabled
    public static string getPdf(){
        SapSoapFunctionsMcS.ZSD_SFDC_PDF_WS  pdf= new SapSoapFunctionsMcS.ZSD_SFDC_PDF_WS();
        
        String ZaccdocNum;
        String ZbdocNum = '9010025439';
        String ZcompCode;
        String ZcustNum;
        String ZdocType = 'DM';
        String ZfiYear;
        String ZsaleOrderNum;
        if(!Test.isRunningTest()){
            SapSoapFunctionsMcS.ZsdSfdcPdfResponse_element  pdfResponse = pdf.ZsdSfdcPdf(ZaccdocNum, ZbdocNum, ZcompCode, ZcustNum, ZdocType, ZfiYear, ZsaleOrderNum);
            return pdfResponse.ZpdfBase64;
        }else{
            return '';
        }
    }
    
    @AuraEnabled
    public static string getdemandPdf(string recordId){
        SapSoapFunctionsMcS.ZSD_SFDC_PDF_WS  pdf= new SapSoapFunctionsMcS.ZSD_SFDC_PDF_WS();
        
       RW_Demand__c demand = [SELECT Id, Name,RW_Billing_Document_Number__c, RW_Customer_Number__c FROM RW_Demand__c WHERE Id= :recordId];
        String ZaccdocNum;
        //String ZbdocNum = '9010000321';
      
        String ZcompCode;
        String ZcustNum;
        String ZdocType = 'DM';
        String ZfiYear;
        String ZsaleOrderNum;
      //SapSoapFunctionsMcS.ZsdSfdcPdfResponse_element  pdfResponse = pdf.ZsdSfdcPdf(ZaccdocNum, demand.RW_Billing_Document_Number__c, ZcompCode, ZcustNum, ZdocType, ZfiYear, ZsaleOrderNum);
        if(!Test.isRunningTest()){
            SapSoapFunctionsMcS.ZsdSfdcPdfResponse_element  pdfResponse = pdf.ZsdSfdcPdf(ZaccdocNum, demand.RW_Billing_Document_Number__c, ZcompCode, ZcustNum, ZdocType, ZfiYear, ZsaleOrderNum);
            return pdfResponse.ZpdfBase64;
        }else{
            return '';
        }
    }
    
     @AuraEnabled
    public static string getreceiptPdf(string recordId){
        SapSoapFunctionsMcS.ZSD_SFDC_PDF_WS  pdf= new SapSoapFunctionsMcS.ZSD_SFDC_PDF_WS();
        
       RW_Payment_Details__c receipt = [SELECT Id, Name,RW_Accounting_Document_Number__c, RW_Fiscal_Year__c, RW_Company_Code__c FROM RW_Payment_Details__c WHERE Id= :recordId];
        String ZaccdocNum = receipt.RW_Accounting_Document_Number__c;
        //String ZaccdocNum = '0180000190';
        //String ZbdocNum = '9010000321';
      
        String ZcompCode = receipt.RW_Company_Code__c;
       // String ZcompCode = '2000';
        String ZcustNum;
        String ZdocType = 'PM';
        String ZfiYear = receipt.RW_Fiscal_Year__c;
        //String ZfiYear = '2020';
        String ZsaleOrderNum;
        if(!Test.isRunningTest()){
            SapSoapFunctionsMcS.ZsdSfdcPdfResponse_element  pdfResponse = pdf.ZsdSfdcPdf(ZaccdocNum, null, ZcompCode, ZcustNum, ZdocType, ZfiYear, ZsaleOrderNum);
            return pdfResponse.ZpdfBase64;
        }else{
            return '';
        }
        
    }
    
    @AuraEnabled
    public static string getinterestLedgerPdf(string customerNumber,String companycode){
        SapSoapFunctionsMcS.ZSD_SFDC_PDF_WS  pdf= new SapSoapFunctionsMcS.ZSD_SFDC_PDF_WS();
        
        String ZaccdocNum;
        String ZbdocNum;
      
        String ZcompCode=companycode;
        String ZcustNum=customerNumber;
        String ZdocType = 'IL';
        String ZfiYear;
        String ZsaleOrderNum;
        
        //Added by coServe 14-10-2024 Start
        List<Booking__c> bkgs = [SELECT Id, Opportunity__r.SAP_Customer_Number__c, Interest_to_be_Applied__c FROM Booking__c WHERE Opportunity__r.SAP_Customer_Number__c = : customerNumber];
        if(bkgs.size() > 0 && bkgs[0].Interest_to_be_Applied__c == 'Yes'){
            ZsaleOrderNum = 'X';
        }
        //Added by coServe 14-10-2024 End
        
        if(!Test.isRunningTest()){
            SapSoapFunctionsMcS.ZsdSfdcPdfResponse_element  pdfResponse = pdf.ZsdSfdcPdf(ZaccdocNum, ZbdocNum, ZcompCode, ZcustNum, ZdocType, ZfiYear, ZsaleOrderNum);
            return pdfResponse.ZpdfBase64;
        }else{
            return '';
        }
    }
    
    @AuraEnabled
    public static List<RW_Demand__c> getdemandDetails(string recordId){
        return [SELECT Id, Name,RW_Billing_Document_Number__c,RW_Customer_Number__c,Booking__r.Primary_Applicant_Email__c FROM RW_Demand__c WHERE Id= :recordId];
    } 
  
  
    @AuraEnabled
    public static string getinttLedgerPdf(string recordId){
        SapSoapFunctionsMcS.ZSD_SFDC_PDF_WS  pdf= new SapSoapFunctionsMcS.ZSD_SFDC_PDF_WS();
        
        Booking__c book = [SELECT Id,Name,Opportunity__r.SAP_Customer_Number__c,Project__r.RW_SAP_Company_Code__c FROM Booking__c WHERE Id= :recordId];
        
        String ZaccdocNum;
        String ZbdocNum;
      
        String ZcompCode = book.Project__r.RW_SAP_Company_Code__c;
        String ZcustNum = book.Opportunity__r.SAP_Customer_Number__c;
        String ZdocType = 'IL';
        String ZfiYear;
        String ZsaleOrderNum;
        if(!Test.isRunningTest()){
            SapSoapFunctionsMcS.ZsdSfdcPdfResponse_element  pdfResponse = pdf.ZsdSfdcPdf(ZaccdocNum, ZbdocNum, ZcompCode, ZcustNum, ZdocType, ZfiYear, ZsaleOrderNum);
            return pdfResponse.ZpdfBase64;
        }else{
            return '';
        }
    }
    
    @AuraEnabled
    public static List<RW_Demand__c> sendDemandEmail(List<String> recordId, String pdfdata){
        List<Messaging.SingleEmailMessage> emailList =  new List<Messaging.SingleEmailMessage>();
        List<RW_Demand__c> demandList =  [SELECT Id, Name,RW_Billing_Document_Number__c, RW_Customer_Number__c, Booking__r.Primary_Applicant_Email__c,Booking__r.Primary_Applicant_Name__c, RW_Demand_Milestone__c FROM RW_Demand__c WHERE Id IN : recordId];
        List<String> emailsToSend = new List<String>();
        string emailSend = '';
         
        for(RW_Demand__c emails : demandList){
            if(emails.Booking__r.Primary_Applicant_Email__c !=null){
            emailSend = emails.Booking__r.Primary_Applicant_Email__c;
            emailsToSend.add(emailSend); 
            }
        }
        
       
        
        if(emailsToSend.size()>0){     
        for(RW_Demand__c cc : demandList){             
            EmailTemplate template = [SELECT Id, Name, Subject, HtmlValue, Body, developername FROM EmailTemplate WHERE developername = 'Demand_Letter' LIMIT 1];
            String htmlBody = template.HtmlValue; 
            String plainTextBody = template.Body;
            
            if(cc.Booking__r.Primary_Applicant_Name__c !=null){
            htmlBody = htmlBody.replace('{!RW_Demand__c.Booking__r.Primary_Applicant_Name__c}', cc.Booking__r.Primary_Applicant_Name__c);
            }else{
             htmlBody = htmlBody.replace('{!RW_Demand__c.Booking__r.Primary_Applicant_Name__c}', 'Applicant');
            }
           
            if(cc.Name != null){
                htmlBody = htmlBody.replace('{!RW_Demand__c.RW_Demand_Milestone__c}', cc.RW_Demand_Milestone__c);
            }else{
                htmlBody = htmlBody.replace('{!RW_Demand__c.RW_Demand_Milestone__c}', '');
            }
                
            
            if(cc.RW_Billing_Document_Number__c != null){
             htmlBody = htmlBody.replace('{!RW_Demand__c.RW_Billing_Document_Number__c}', cc.RW_Billing_Document_Number__c);
            }else{
               htmlBody = htmlBody.replace('{!RW_Demand__c.RW_Billing_Document_Number__c}',''); 
            }
       
            if(cc.Booking__r.Primary_Applicant_Name__c !=null){
              plainTextBody = plainTextBody.replace('{!RW_Demand__c.Booking__r.Primary_Applicant_Name__c}', cc.Booking__r.Primary_Applicant_Name__c);                
            }else{
              plainTextBody = plainTextBody.replace('{!RW_Demand__c.Booking__r.Primary_Applicant_Name__c}','Applicant'); 
            }
               
            if(cc.Name != null){
              plainTextBody=plainTextBody.replace('{!RW_Demand__c.RW_Demand_Milestone__c}', cc.RW_Demand_Milestone__c);
            }else{
              plainTextBody=plainTextBody.replace('{!RW_Demand__c.RW_Demand_Milestone__c}','');                
            }
                
            if(cc.RW_Billing_Document_Number__c != null){
              plainTextBody = plainTextBody.replace('{!RW_Demand__c.RW_Billing_Document_Number__c}', cc.RW_Billing_Document_Number__c);
            }else{
              plainTextBody = plainTextBody.replace('{!RW_Demand__c.RW_Billing_Document_Number__c}',''); 
            }
            
            
            Blob b = EncodingUtil.base64Decode(pdfdata);
                
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName('Demand -' + RW_Demand__c.RW_Demand_Milestone__c + '.pdf');
            efa.setBody(b);
         
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = emailsToSend;
            message.subject = template.Subject;
            message.setTemplateId(template.Id);
            message.setHtmlBody(htmlBody);   
            message.setPlainTextBody(plainTextBody);
            message.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
            message.setFileAttachments(new List<Messaging.EmailFileAttachment>{efa});
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            
            
        }
        }
        
        return demandList;
    }  
    
    @AuraEnabled
    public static List<RW_Payment_Details__c> sendReceiptEmail(List<String> recordId, String pdfdata){
        List<RW_Payment_Details__c> receipts = [SELECT Id, RW_Booking__r.Primary_Applicant_Name__c, RW_Booking__r.Primary_Applicant_Email__c, RW_Accounting_Document_Number__c FROM RW_Payment_Details__c WHERE Id =: recordId];
        List<String> emailsToSend = new List<String>();
        for(RW_Payment_Details__c rec : receipts){
            if(rec.RW_Booking__r.Primary_Applicant_Email__c != null){
                emailsToSend.add(rec.RW_Booking__r.Primary_Applicant_Email__c);
            }
        }
        if(emailsToSend.size() > 0){
            for(RW_Payment_Details__c rec : receipts){
                
                Blob b = EncodingUtil.base64Decode(pdfdata);
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName('Receipt - ' + rec.RW_Accounting_Document_Number__c + '.pdf');
                efa.setBody(b);
                
                String htmlBody = 'Dear ' + rec.RW_Booking__r.Primary_Applicant_Name__c + ',<br/><br/>';
                htmlBody += 'This is to inform you the receipt details has been attached for your reference for the receipt number - ' + rec.RW_Accounting_Document_Number__c;
                htmlBody += '<br/><br/>Please go through the attached file.<br/><br/>Thanks<br/>Runwal Team';
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.toAddresses = emailsToSend;
                message.subject = 'Receipt Letter';
                message.setHtmlBody(htmlBody);   
                message.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
                message.setFileAttachments(new List<Messaging.EmailFileAttachment>{efa});
                Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            }
        }
        return receipts;
    }
    
    
    @AuraEnabled
    public static string getagreementPdf(string salesorderNumber){
        SapSoapFunctionsMcS.ZSD_SFDC_PDF_WS  pdf= new SapSoapFunctionsMcS.ZSD_SFDC_PDF_WS();
        
        String ZaccdocNum;
        String ZbdocNum;
      
        String ZcompCode;
        String ZcustNum;
        String ZdocType = 'AD';
        String ZfiYear;
        String ZsaleOrderNum=salesorderNumber;
        if(!Test.isRunningTest()){
            SapSoapFunctionsMcS.ZsdSfdcPdfResponse_element  pdfResponse = pdf.ZsdSfdcPdf(ZaccdocNum, ZbdocNum, ZcompCode, ZcustNum, ZdocType, ZfiYear, ZsaleOrderNum);
            return pdfResponse.ZpdfBase64;
        }else{
            return '';
        }
    }
    
    
    @AuraEnabled
    public static string getCustomerLedgerPdf(string customerNumber,String companycode){
        SapSoapFunctionsMcS.ZSD_SFDC_PDF_WS  pdf= new SapSoapFunctionsMcS.ZSD_SFDC_PDF_WS();
        
        String ZaccdocNum;
        String ZbdocNum;
      
        String ZcompCode=companycode;
        String ZcustNum=customerNumber;
        //String ZcompCode='1000';
        //String ZcustNum='0020006430';
        String ZdocType = 'CL';
        String ZfiYear;
        String ZsaleOrderNum;
        if(!Test.isRunningTest()){
            SapSoapFunctionsMcS.ZsdSfdcPdfResponse_element  pdfResponse = pdf.ZsdSfdcPdf(ZaccdocNum, ZbdocNum, ZcompCode, ZcustNum, ZdocType, ZfiYear, ZsaleOrderNum);
            return pdfResponse.ZpdfBase64;
        }else{
            return '';
        }
    }
    
    @AuraEnabled
    public static string getCustLedgerPdf(string recordId){
        SapSoapFunctionsMcS.ZSD_SFDC_PDF_WS  pdf= new SapSoapFunctionsMcS.ZSD_SFDC_PDF_WS();
        
        Booking__c book = [SELECT Id,Name,Opportunity__r.SAP_Customer_Number__c,Project__r.RW_SAP_Company_Code__c FROM Booking__c WHERE Id= :recordId];
        
        
        String ZaccdocNum;
        String ZbdocNum;
      
        String ZcompCode = book.Project__r.RW_SAP_Company_Code__c;
        String ZcustNum = book.Opportunity__r.SAP_Customer_Number__c;
        //String ZcompCode='1000';
        //String ZcustNum='0020006430';
        String ZdocType = 'CL';
        String ZfiYear;
        String ZsaleOrderNum;
        if(!Test.isRunningTest()){
            SapSoapFunctionsMcS.ZsdSfdcPdfResponse_element  pdfResponse = pdf.ZsdSfdcPdf(ZaccdocNum, ZbdocNum, ZcompCode, ZcustNum, ZdocType, ZfiYear, ZsaleOrderNum);
            return pdfResponse.ZpdfBase64;
        }else{
            return '';
        }
    }
    
    

}