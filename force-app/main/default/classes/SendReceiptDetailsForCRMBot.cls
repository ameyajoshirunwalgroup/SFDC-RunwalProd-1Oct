public class SendReceiptDetailsForCRMBot implements Queueable, Database.AllowsCallouts {
    
    private List<String> recpIds;
    
    public SendReceiptDetailsForCRMBot(List<String> receiptIds) {
        this.recpIds = receiptIds;
    }
    
    public void execute(QueueableContext context) {
        
        List<RW_Payment_Details__c> recps = [SELECT Id,Name,RW_Booking__r.Opportunity__r.RW_Email__c,RW_Booking__r.Primary_Applicant_Name__c,RW_Booking__r.Opportunity__r.Name,RW_Booking__r.Project__c,RW_Booking__r.Unit_No__r.Relationship_Manager__r.User__c,RW_Booking__r.Unit_No__r.Relationship_Manager__r.User__r.Id FROM RW_Payment_Details__c WHERE Id =: recpIds];
        
        /*if(recps.size() > 1){
            last3ReceiptLetter(recps);
        }else if(recps.size() == 1){
            latestReceiptLetter(recps);
        }*/
        latestReceiptLetter(recps);//Calling this latest receipt function with any condition - CHanged 25-11-24
    }
    
    //Commented by Prashant - New requirement - Last 3 payment - Changed - 25-11-24
    /*public static void last3ReceiptLetter(List<RW_Payment_Details__c> recps){
        
        String email = recps[0].RW_Booking__r.Opportunity__r.RW_Email__c;
        String customer = (recps[0].RW_Booking__r.Primary_Applicant_Name__c != null)? recps[0].RW_Booking__r.Primary_Applicant_Name__c : recps[0].RW_Booking__r.Opportunity__r.Name;
        
        Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Service Task').getRecordTypeId();
        Task tsk = new Task();
        tsk.RecordTypeId = recordTypeId;
        tsk.Subject = 'Last 3 Payment Receipts';
        tsk.Priority = 'Normal';
        tsk.Status = 'Not Started';
        tsk.Project__c = recps[0].RW_Booking__r.Project__c;
        tsk.WhatId = recps[0].RW_Booking__c;
        tsk.OwnerId = (recps[0].RW_Booking__r.Unit_No__r.Relationship_Manager__r.User__c != null && recps[0].RW_Booking__r.Unit_No__r.Relationship_Manager__r.User__c != '') ? recps[0].RW_Booking__r.Unit_No__r.Relationship_Manager__r.User__c : UserInfo.getUserId();
        //tsk.OwnerId = recps[0].RW_Booking__r.Unit_No__r.Relationship_Manager__r.User__c;
                       
        List<Messaging.EmailFileAttachment> atts = new List<Messaging.EmailFileAttachment>();
        Boolean isError = false;
        List<String> recpLinks = new List<String>();
        List<String> recpIds = new List<String>();
        try{
            for(RW_Payment_Details__c rec : recps){
                String body1;
                if(!Test.isRunningTest() && recps.size() > 0){
                    body1 = PDFController.getreceiptPdf(rec.Id);
                    recpLinks.add('https://runwal--uat.sandbox.my.salesforce-sites.com/crmbotdoc?id='+rec.Id+'&doc=recp');
                    recpIds.add(rec.Id);
                }else if(Test.isRunningTest()){
                    body1 = 'Test';
                }
                Messaging.EmailFileAttachment att1 = new Messaging.EmailFileAttachment();
                att1.setFileName(rec.Name+'.pdf');
                att1.setBody(EncodingUtil.base64Decode(body1));
                atts.add(att1);  
                rec.Send_Receipt_Letter__c = false;
            }
        }catch(Exception e){
            System.debug('--Error--'+e.getMessage());
            isError = true;
            tsk.Description = 'Error: ' + e.getMessage();
        }
        insert tsk;
        update recps;
        try{
            if(atts != null && atts.size() > 0 && !isError){
                list<Messaging.SingleEmailMessage> messages = new list<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.toAddresses = new List<String>{email};
                    message.subject = 'Last 3 Payment Receipts';
                String htmlBody = 'Dear ' + customer + ',<br/><br/>  Please find the last three Receipt Letters as requested.';
                htmlBody += '<br/><br/>Regards,<br/>Customer Care Team.';
                message.setHtmlBody(htmlBody);  
                message.setFileAttachments(atts);
                message.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
                messages.add(message);
                Messaging.SendEmailResult[] result = Messaging.sendEmail(messages);
            }
            tsk.Status = 'Completed';
        }catch(Exception e){
            System.debug('--Error--'+e.getMessage());
            tsk.Description = 'Error: ' + e.getMessage();
        }
        update tsk;
    }*/
    
    public static void latestReceiptLetter(List<RW_Payment_Details__c> recps){
        
        Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Service Task').getRecordTypeId();
        Task tsk = new Task();
        tsk.RecordTypeId = recordTypeId;
        tsk.Subject = 'Latest Payment Receipt';
        tsk.Priority = 'Normal';
        tsk.Status = 'Not Started';
        tsk.Project__c = recps[0].RW_Booking__r.Project__c;
        tsk.WhatId = recps[0].RW_Booking__c;
        //tsk.OwnerId = (recps[0].RW_Booking__r.Unit_No__r.Relationship_Manager__r.User__c != null && recps[0].RW_Booking__r.Unit_No__r.Relationship_Manager__r.User__c != '') ? recps[0].RW_Booking__r.Unit_No__r.Relationship_Manager__r.User__c : UserInfo.getUserId();   
        String owner = recps[0].RW_Booking__r.Unit_No__r.Relationship_Manager__r.User__c; 
        owner = (owner != null) ? owner : UserInfo.getUserId();
        tsk.OwnerId = owner;
                       
        String body;
        Boolean isError = false;
        String email = recps[0].RW_Booking__r.Opportunity__r.RW_Email__c;
        String customer = (recps[0].RW_Booking__r.Primary_Applicant_Name__c != null)? recps[0].RW_Booking__r.Primary_Applicant_Name__c : recps[0].RW_Booking__r.Opportunity__r.Name;
        try{
            if(!Test.isRunningTest() && recps.size() > 0){
                body = PDFController.getreceiptPdf(recps[0].Id);
            }else if(Test.isRunningTest()){
                body = 'Test';
            } 
        }catch(Exception e){
            isError = true;
            tsk.Description = 'Error: ' + e.getMessage();
        }
        insert tsk;
        recps[0].Send_Receipt_Letter__c = false;
        update recps[0];
        try{
            if(body != null && !isError){
                Messaging.EmailFileAttachment att = new Messaging.EmailFileAttachment();
                att.setFileName('Receipt.pdf');
                att.setBody(EncodingUtil.base64Decode(body));
                list<Messaging.SingleEmailMessage> messages = new list<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.toAddresses = new List<String>{email};
                    message.subject = 'Latest Payment Receipt';
                String htmlBody = 'Dear ' + customer + ',<br/><br/>  Please find the latest Payment Receipt as requested.';
                htmlBody += '<br/><br/>Regards,<br/>Customer Care Team.';
                message.setHtmlBody(htmlBody); 
                message.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
                message.setFileAttachments(new Messaging.EmailFileAttachment[] {att});
                messages.add(message);
                Messaging.SendEmailResult[] result = Messaging.sendEmail(messages);
            }
            tsk.Status = 'Completed';
        }catch(Exception e){
            tsk.Description = 'Error: ' + e.getMessage();
        }
        update tsk;
        //update recps;
    }
}