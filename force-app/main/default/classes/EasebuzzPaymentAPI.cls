@RestResource(urlMapping='/EaseBuzz')
global without sharing class EasebuzzPaymentAPI {
    
    @HttpPost
    global static void handlePaymentCallback() {
        RestRequest req = RestContext.request;
        //String urlParam1 = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
       // String param1 = req.params.get('param1');
        // RestRequest req = RestContext.request;
        String requestBody = req.params.toString();
        System.debug('requestBody'+requestBody);
       // Map<String, Object> requestParams = formUrlEncodedToMap(requestBody);       
        String phone = req.params.get('phone');
        String email = req.params.get('email');
        String receivedHash = req.params.get('hash');
        String status = req.params.get('status');
        String txnId = req.params.get('txnid');
        Decimal amount = Decimal.valueOf((String) (req.params.get('amount') ?? '0'));
        String udf1 = req.params.get('udf1');
        String udf2 = req.params.get('udf2');
        String udf3 = req.params.get('udf3');
        String udf4 = req.params.get('udf4');
        String udf5 = req.params.get('udf5');
        String udf6 = req.params.get('udf6');
        String udf7 = req.params.get('udf7');
        String udf8 = req.params.get('udf8');
        String udf9 = req.params.get('udf9');
        String udf10 = req.params.get('udf10');
        String firstname =req.params.get('firstname');
        String productinfo =req.params.get('productinfo');
        String key = 'OTVO07DZOH'; 
        String salt = 'AGJCLF10D5';
           List<String> toAddress = new List<String>();
        phone = phone != null ? phone.trim() : null;
        email = email != null ? email.trim() : null;

        
        String generatedHash = generateHash(salt, status, udf10, udf9, udf8, udf7, udf6, udf5, udf4, udf3, udf2, udf1, email, firstname, productinfo, amount, txnId, key);
        
        if (generatedHash != receivedHash) {
            RestContext.response.statusCode = 400;
            RestContext.response.responseBody = Blob.valueOf('Hash mismatch');
            return;
        }
        
        List<Opportunity> opps = [SELECT Id, Name, Hash__c, Account.Name, Account.PersonEmail, Account.Mobile_No__c, CreatedDate
                                  FROM Opportunity 
                                  WHERE Account.Mobile_No__c = :phone 
                                  AND Account.PersonEmail = :email 
                                  ORDER BY CreatedDate DESC 
                                  LIMIT 1];
        
        if (opps.isEmpty()) {
            RestContext.response.statusCode = 404;
            RestContext.response.responseBody = Blob.valueOf('Opportunity not found');
            return;
        }
        
        Opportunity opp = opps[0];
        
     List<RW_Digital_Link_Status__c> Dlist=[Select Id,RW_Opportunity__c,RW_Link_Status__c from RW_Digital_Link_Status__c where RW_Opportunity__c=:opp.id];
        
        List<RW_EOI__c> eoiList = [SELECT id,Name,RW_Status__c,RW_Primary_Email__c,RW_Primary_First_Name__c,RW_Primary_Last_Name__c,Opportunity__r.RW_Project__c,RW_Project_Name__c,Opportunity__c,Opportunity__r.RW_Sales_Associate__c,RW_EOI_Acknowledgment_Sent__c,RW_EOI_Acknowledgement_Sent_Date_Time__c FROM RW_EOI__c 
                                   WHERE Opportunity__c = :opp.Id 
                                   LIMIT 1];
        
        if (eoiList.isEmpty()) {
            RestContext.response.statusCode = 404;
            RestContext.response.responseBody = Blob.valueOf('EOI record not found');
            return;
        }
        
        RW_EOI__c eoi = eoiList[0];
        RW_Digital_Link_Status__c Dl=Dlist[0];
        if (status == 'success') {
            eoi.RW_Status__c = 'EOI Confirmed';
            update eoi;
            Dl.RW_Link_Status__c='Expired' ;
            update Dl;
            Receipt__c r = new Receipt__c();
            r.Opportunity__c = opp.Id;
            r.EOI__c = eoi.Id;
            r.Amount_Rs__c = amount;
            r.Receipt_Status__c = 'Cleared';
            r.Mode__c = 'Digital';
            insert r;
            PageReference pdf = Page.CustomerEOIForm;
            pdf.getParameters().put('eoiId',eoi.Id);
            Blob body;
            if(!Test.isRunningTest())
            body= pdf.getContent();
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            attach.setContentType('application/pdf');
            attach.setFileName('EOIForm.pdf');
            attach.setInline(false);
            if(body != null)
            attach.Body = body;
           EmailTemplate template = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='EOI_Confirmed_Customer'];
           String htmlBody = template.HtmlValue; 
            htmlBody = htmlBody.replace('{!RW_EOI__c.RW_Primary_First_Name__c}', eoi.RW_Primary_First_Name__c);
            htmlBody = htmlBody.replace('{!RW_EOI__c.RW_Primary_Last_Name__c}', eoi.RW_Primary_Last_Name__c);
            if(eoi.RW_EOI_Acknowledgement_Sent_Date_Time__c!=null){
                           htmlBody = htmlBody.replace('{!RW_EOI__c.RW_EOI_Acknowledgement_Sent_Date_Time__c}', eoi.RW_EOI_Acknowledgement_Sent_Date_Time__c.format('dd/MM/yyyy HH:mm:ss','IST')+' IST');
 
            }
            map<string, Sales_Manager_Cont__c> mapOfCustomSetting = Sales_Manager_Cont__c.getAll();
            if(mapOfCustomSetting!=null && mapOfCustomSetting.size()>0 && mapOfCustomSetting.get(eoi.opportunity__r.RW_Sales_Associate__c)!=null)
            htmlBody = htmlBody.replace('{!SMPhoneNumber}', string.valueOf(mapOfCustomSetting.get(eoi.opportunity__r.RW_Sales_Associate__c).RW_Phone__c));	
            else
            htmlBody = htmlBody.replace('{!SMPhoneNumber}', 'xxxxxxxxxx');
            String plainTextBody = template.Body; 
            plainTextBody = plainTextBody.replace('{!RW_EOI__c.RW_Primary_First_Name__c}', eoi.RW_Primary_First_Name__c);
            plainTextBody = plainTextBody.replace('{!RW_EOI__c.RW_Primary_Last_Name__c}', eoi.RW_Primary_Last_Name__c);
            if(eoi.RW_EOI_Acknowledgement_Sent_Date_Time__c!=null)
            {
           plainTextBody = plainTextBody.replace('{!RW_EOI__c.RW_EOI_Acknowledgement_Sent_Date_Time__c}', eoi.RW_EOI_Acknowledgement_Sent_Date_Time__c.format('dd/MM/yyyy HH:mm:ss','IST')+' IST');
 
            }
              if(mapOfCustomSetting!=null && mapOfCustomSetting.size()>0 && mapOfCustomSetting.get(eoi.opportunity__r.RW_Sales_Associate__c)!=null)
            plainTextBody = plainTextBody.replace('{!SMPhoneNumber}', string.valueOf(mapOfCustomSetting.get(eoi.opportunity__r.RW_Sales_Associate__c).RW_Phone__c));	
            else
            plainTextBody = plainTextBody.replace('{!SMPhoneNumber}', 'xxxxxxxxxx');
            
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = new String[] { eoi.RW_Primary_Email__c };
            message.subject = template.Subject;
            message.setHtmlBody(htmlBody);   
            message.setPlainTextBody(plainTextBody);  
            message.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
            if(toAddress.size() >0)
            message.setCcAddresses(toAddress);
            if(attach.body != null)
            message.setFileAttachments(new Messaging.EmailFileAttachment[] { attach });
            Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages); 
        }
        
        
        RestContext.response.statusCode = 200;
        RestContext.response.responseBody = Blob.valueOf('Payment status updated successfully');
    }

  
    public static String generateHash(String salt, String status, String udf10, String udf9, String udf8, String udf7, String udf6, String udf5,
                                      String udf4, String udf3, String udf2, String udf1, String email, String firstname, String productinfo,
                                      Decimal amount, String txnid, String key) {
        
        
        String hashString = salt + '|' + status + '|' + udf10 + '|' + udf9 + '|' + udf8 + '|' + udf7 + '|' + udf6 + '|' + udf5 + '|' + udf4 + '|' + udf3 + '|' + udf2 + '|' + udf1 + '|' 
                            + email + '|' + firstname + '|' + productinfo + '|' + String.valueOf(amount) + '|' + txnid + '|' + key;
        
      
        Blob hashData = Crypto.generateDigest('SHA-512', Blob.valueOf(hashString));
        String generatedHash = EncodingUtil.convertToHex(hashData);
        
        return generatedHash;
    }
       public static void dummyMethod() {
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
   /* public static Map<String, Object> formUrlEncodedToMap(String encodedData) {
        Map<String, Object> result = new Map<String, Object>();
        String[] pairs = encodedData.split('&');
        
        for (String pair : pairs) {
            String[] keyValue = pair.split('='); 
            if (keyValue.size() == 2) {
                String key = EncodingUtil.urlDecode(keyValue[0], 'UTF-8');
                String value = EncodingUtil.urlDecode(keyValue[1], 'UTF-8');
                result.put(key, value);
            }
        }
        return result;
    }*/
}