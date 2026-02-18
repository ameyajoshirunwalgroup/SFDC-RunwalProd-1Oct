public with sharing class EmailTemplateController {
    @AuraEnabled(cacheable=true)
    public static List<EmailTemplateWrapper> getEmailTemplates() {
        List<EmailTemplateWrapper> emailTemplates = new List<EmailTemplateWrapper>();

        List<EmailTemplate> templates = [SELECT Id, HtmlValue,Name FROM EmailTemplate WHERE Name IN ('Test 360')];

       for (Integer i = 0; i < templates.size(); i++) {
            EmailTemplate template = templates[i];
            // Add an index number formatted with leading zero
            String index = '0'+String.valueOf(i + 1);
            String indexedName = index + '. ' + template.Name;
            emailTemplates.add(new EmailTemplateWrapper(template.Id, indexedName, template.HtmlValue));
        }

        return emailTemplates;
    }
       @AuraEnabled(cacheable=true)
    public static List<Task> getTasksForOpportunity(Id opportunityId) {
     System.debug('Id::'+opportunityId);
    System.debug('inside getTasksForOpportunity');
        return [SELECT Id, Subject,	Task_Type__c,Call_Status__c,Call_Time__c,Description, CreatedDate, Communication_Type__c FROM Task WHERE WhatId = :opportunityId AND Task_Type__c='CRM Call' Order By CreatedDate DESC Limit 3 ];
    }
    @AuraEnabled
    public static void shareEmailTemplateWithRMCustomer(Id templateId, String OppId) {
        System.debug('templateId: ' + templateId);
        System.debug('oppId: ' + OppId);
        
       Opportunity opplist = [SELECT Id, AccountId, Account.PersonEmail FROM Opportunity WHERE Id = :OppId];
        EmailTemplate emailTemplate = [SELECT Body, HtmlValue, Subject FROM EmailTemplate WHERE Id = :templateId];
        String emailBody = emailTemplate.HtmlValue;
        String emailSubject = emailTemplate.Subject;
       String customerEmail = opplist.Account.PersonEmail;
       String loggedInUserEmail = UserInfo.getUserEmail();
        System.debug('loggedInUserEmail: ' + loggedInUserEmail);

        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Opportunity.fields.getMap();
        List<String> fieldList = new List<String>();

        for (String fieldName : fieldMap.keySet()) {
            fieldList.add(fieldName);
        }

        String soqlQuery = 'SELECT Account.PersonEmail, ' + String.join(fieldList, ', ') + ' FROM Opportunity WHERE Id = :OppId';

       
        List<Sobject> opp = Database.query(soqlQuery);

        /*String customerEmail = opp.Account.PersonEmail;
        if (String.isEmpty(customerEmail)) {
            System.debug('Customer email not found');
            return;
        }*/

        //Map<String, String> values = new Map<String, String>();
        for (String fieldName : fieldList) {
          //  values.put('Opportunity.' + fieldName, (String) opp.getSobject(fieldName) != null ?(String) opp.getSobject(fieldName) : '');
        }
      // System.debug('Name::::'+values.get('Opportunity.Name'));
      // System.debug('values::::'+values);
        
        emailBody = replaceMergeFields(emailBody, opp);
        emailSubject = replaceMergeFields(emailSubject, opp);

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[] {loggedInUserEmail });
        email.setCcAddresses(new String[]{'luv.dubey@stetig.in'});
        email.setSubject(emailSubject);
        email.setHtmlBody(emailBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    }
      @AuraEnabled
    public static void shareEmailTemplateWithRMOnly(Id templateId, String OppId) {
        System.debug('templateId: ' + templateId);
        System.debug('oppId: ' + OppId);
        
       Opportunity opplist = [SELECT Id, AccountId, Account.PersonEmail FROM Opportunity WHERE Id = :OppId];
        EmailTemplate emailTemplate = [SELECT Body, HtmlValue, Subject FROM EmailTemplate WHERE Id = :templateId];
        String emailBody = emailTemplate.HtmlValue;
        String emailSubject = emailTemplate.Subject;
       String customerEmail = opplist.Account.PersonEmail;
       String loggedInUserEmail = UserInfo.getUserEmail();
        System.debug('loggedInUserEmail: ' + loggedInUserEmail);

        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Opportunity.fields.getMap();
        List<String> fieldList = new List<String>();

        for (String fieldName : fieldMap.keySet()) {
            fieldList.add(fieldName);
        }

        String soqlQuery = 'SELECT Account.PersonEmail, ' + String.join(fieldList, ', ') + ' FROM Opportunity WHERE Id = :OppId';

       
        List<Sobject> opp = Database.query(soqlQuery);

        /*String customerEmail = opp.Account.PersonEmail;
        if (String.isEmpty(customerEmail)) {
            System.debug('Customer email not found');
            return;
        }*/

        //Map<String, String> values = new Map<String, String>();
        for (String fieldName : fieldList) {
          //  values.put('Opportunity.' + fieldName, (String) opp.getSobject(fieldName) != null ?(String) opp.getSobject(fieldName) : '');
        }
      // System.debug('Name::::'+values.get('Opportunity.Name'));
      // System.debug('values::::'+values);
        
        emailBody = replaceMergeFields(emailBody, opp);
        emailSubject = replaceMergeFields(emailSubject, opp);

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[] { customerEmail });
        email.setCcAddresses(new String[]{loggedInUserEmail});
        email.setSubject(emailSubject);
        email.setHtmlBody(emailBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    }
@AuraEnabled
    public static void shareEmailTemplateWithCustomer(Id templateId, String OppId) {
        System.debug('templateId: ' + templateId);
        System.debug('oppId: ' + OppId);

        // Fetch the email template
        EmailTemplate emailTemplate = [SELECT Body, HtmlValue, Subject FROM EmailTemplate WHERE Id = :templateId];
        String emailBody = emailTemplate.HtmlValue;
        String emailSubject = emailTemplate.Subject;

        // Fetch all Opportunity fields
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Opportunity.fields.getMap();
        List<String> fieldList = new List<String>();

        for (String fieldName : fieldMap.keySet()) {
            fieldList.add(fieldName);
        }

        String soqlQuery = 'SELECT Account.PersonEmail, ' + String.join(fieldList, ', ') + ' FROM Opportunity WHERE Id = :OppId';

       
        List<Sobject> opp = Database.query(soqlQuery);

        /*String customerEmail = opp.Account.PersonEmail;
        if (String.isEmpty(customerEmail)) {
            System.debug('Customer email not found');
            return;
        }*/

        //Map<String, String> values = new Map<String, String>();
        for (String fieldName : fieldList) {
          //  values.put('Opportunity.' + fieldName, (String) opp.getSobject(fieldName) != null ?(String) opp.getSobject(fieldName) : '');
        }
      // System.debug('Name::::'+values.get('Opportunity.Name'));
      // System.debug('values::::'+values);
        
        emailBody = replaceMergeFields(emailBody, opp);
        emailSubject = replaceMergeFields(emailSubject, opp);

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[] { 'luv.dubey@stetig.in' });
        email.setSubject(emailSubject);
        email.setHtmlBody(emailBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    }

    public static String replaceMergeFields(String template, List<Sobject> values) {
        String regex = '\\{!Opportunity\\.([a-zA-Z0-9_]+)\\}';
        Pattern pattern = Pattern.compile(regex);
        Matcher matcher = pattern.matcher(template);

        while (matcher.find()) {
            System.debug( ' matcher.group(0)'+matcher.group(0));
            String placeholder = matcher.group(0); 
            String fieldName = matcher.group(1);  
            System.debug( 'fieldName '+fieldName);
            System.debug( 'values.get(fieldName)'+values[0].get(fieldName));
            String fieldValue =  String.valueof(values[0].get(fieldName) ?? '');
            template = template.replace(placeholder, fieldValue);
        }
        return template;
    }
    
@AuraEnabled
public static void sendReceiptEmail(List<String> receiptIds) {
    System.debug('receiptIds:::' + receiptIds);
    
    List<RW_Payment_Details__c> recps = [
        SELECT Id, RW_Booking__r.Primary_Applicant_Name__c, RW_Booking__r.Primary_Applicant_Email__c, 
               RW_Accounting_Document_Number__c, RW_Company_Code__c, RW_Fiscal_Year__c, Name
        FROM RW_Payment_Details__c 
        WHERE Id IN :receiptIds
    ];

    List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
    Boolean isError = false;
    
    try {
        for (RW_Payment_Details__c rec : recps) {
            String pdfData;
            // Assuming this method returns the PDF data as a base64 string
            if (!Test.isRunningTest()) {
                pdfData = PDFController.getreceiptPdf(rec.Id); 
            } else {
                pdfData = 'Test'; // Mock data for testing
            }
            
            // Create attachment
            Messaging.EmailFileAttachment att = new Messaging.EmailFileAttachment();
            att.setFileName(rec.Name + '.pdf');
            att.setBody(EncodingUtil.base64Decode(pdfData));
            attachments.add(att);
        }
    } catch (Exception e) {
        System.debug('--Error--' + e.getMessage());
        isError = true;
    }

    if (!attachments.isEmpty() && !isError) {
        try {
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            // Assuming you want to send to the primary applicant's email
            String recipientEmail = recps.isEmpty() ? '' : recps[0].RW_Booking__r.Primary_Applicant_Email__c; 
           // message.setToAddresses(new List<String>{'luv.dubey@stetig.in'}); fOR TESTING 
            message.setToAddresses(new List<String>{recipientEmail});
            message.setSubject('Payment Receipts');

            // Compose email body
            String htmlBody = 'Dear ' + (recps.isEmpty() ? 'Customer' : recps[0].RW_Booking__r.Primary_Applicant_Name__c) + ',<br/><br/>'
                            + 'Please find the Receipt Letters as requested.<br/><br/>'
                            + 'Regards,<br/>Customer Care Team.';
            message.setHtmlBody(htmlBody);
            message.setFileAttachments(attachments);
            message.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
            
            // Send the email
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{message});
        } catch (Exception e) {
            System.debug('--Error while sending email--' + e.getMessage());
        }
    }
}
    @AuraEnabled
public static void sendDemandEmail(List<String> demandIds) {
    System.debug('demandIds:::' + demandIds);
    
    List<RW_Demand__c> dems = [
SELECT Id, Name, CreatedDate, Booking__r.Name,booking__c ,Demand_Date__c, Due_Date__c, RW_Billing_Document_Number__c,Booking__r.Primary_Applicant_Email__c,Booking__r.Primary_Applicant_Name__c,
                       RW_Customer_Number__c, RW_Demand_Amount__c, RW_Demand_Status__c, RW_ODN_Number__c, RW_Total_Demand_Amount__c,
                       RW_Total_GST_Amount__c, Total_Demand_Paid__c, RW_Demand_Milestone__c, RW_Demand_Aging__c, Demand_Amount__c, Remaining_Amount__c FROM RW_Demand__c  
        WHERE Id IN :demandIds
    ];

    List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
    Boolean isError = false;
    
    try {
        for (RW_Demand__c dem : dems) {
            String pdfData;
            // Assuming this method returns the PDF data as a base64 string
            if (!Test.isRunningTest()) {
                pdfData = PDFController.getdemandPdf(dem.Id); 
            } else {
                pdfData = 'Test'; // Mock data for testing
            }
            
            // Create attachment
            Messaging.EmailFileAttachment att = new Messaging.EmailFileAttachment();
            att.setFileName(dem.Name + '.pdf');
            att.setBody(EncodingUtil.base64Decode(pdfData));
            attachments.add(att);
        }
    } catch (Exception e) {
        System.debug('--Error--' + e.getMessage());
        isError = true;
    }

    if (!attachments.isEmpty() && !isError) {
        try {
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            // Assuming you want to send to the primary applicant's email
            String recipientEmail = dems.isEmpty() ? '' : dems[0].Booking__r.Primary_Applicant_Email__c; 
            // message.setToAddresses(new List<String>{'luv.dubey@stetig.in'}); fOR TESTING 
            message.setToAddresses(new List<String>{recipientEmail});
            message.setSubject('Demand Letter for payment towards the milestone');

            // Compose email body
            String htmlBody = 'Dear ' + (dems.isEmpty() ? 'Customer' : dems[0].Booking__r.Primary_Applicant_Name__c) + ',<br/><br/>'
                            + 'Please find the Demand Letters as requested.<br/><br/>'
                            + 'Regards,<br/>Customer Care Team.';
            message.setHtmlBody(htmlBody);
            message.setFileAttachments(attachments);
            message.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
            
            // Send the email
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{message});
        } catch (Exception e) {
            System.debug('--Error while sending email--' + e.getMessage());
        }
    }
}
     
    public class EmailTemplateWrapper {
        @AuraEnabled public String templateId { get; set; }
        @AuraEnabled public String name { get; set; }
          @AuraEnabled public String htmlValue { get; set; }
        public EmailTemplateWrapper(String templateId, String name, String htmlValue) {
            this.templateId = templateId;
            this.name = name;
              this.htmlValue = htmlValue;
        }
    }
}