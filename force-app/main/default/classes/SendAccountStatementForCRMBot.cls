public class SendAccountStatementForCRMBot implements Queueable, Database.AllowsCallouts {
    
    private List<String> bkgIds;
    
    public SendAccountStatementForCRMBot(List<String> bkIds) {
        this.bkgIds = bkIds;
    }
    
    public void execute(QueueableContext context) {
        
        List<Booking__c> bkgs = [SELECT Id,Project__c,Unit_No__r.Relationship_Manager__r.User__c,Opportunity__r.RW_Email__c,Opportunity__r.Name, Primary_Applicant_Name__c FROM Booking__c WHERE Id =: bkgIds];
        
        String email = bkgs[0].Opportunity__r.RW_Email__c;
        String customer = (bkgs[0].Primary_Applicant_Name__c != null)? bkgs[0].Primary_Applicant_Name__c : bkgs[0].Opportunity__r.Name;
        
        Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Service Task').getRecordTypeId();
        Task tsk = new Task();
        tsk.RecordTypeId = recordTypeId;
        tsk.Subject = 'Account Statement';
        tsk.Priority = 'Normal';
        tsk.Status = 'Not Started';
        tsk.Project__c = bkgs[0].Project__c;
        tsk.WhatId = bkgs[0].Id;
        //tsk.OwnerId = (bkgs[0].Unit_No__r.Relationship_Manager__r.User__c != null && bkgs[0].Unit_No__r.Relationship_Manager__r.User__c != '') ? bkgs[0].Unit_No__r.Relationship_Manager__r.User__c : UserInfo.getUserId();
        String owner = bkgs[0].Unit_No__r.Relationship_Manager__r.User__c;
        owner = (owner != null) ? owner : UserInfo.getUserId();
        tsk.OwnerId = owner;
        //insert tsk;
        String body;
        Boolean isError = false;
        try{
            if(!Test.isRunningTest()){
                body = PDFController.getCustLedgerPdf(bkgs[0].Id);
            }else{
                body = 'Test';
            }
        }catch(Exception e){
            isError = true;
            tsk.Description = 'Error: ' + e.getMessage(); 
        }
        insert tsk;
        try{
            if(body != null && body != '' && !isError){
                Messaging.EmailFileAttachment att = new Messaging.EmailFileAttachment();
                att.setFileName('Account Statement.pdf');
                att.setBody(EncodingUtil.base64Decode(body));
                list<Messaging.SingleEmailMessage> messages = new list<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.toAddresses = new List<String>{email};
                message.subject = 'Account Statement';
                String htmlBody = 'Dear ' + customer + ',<br/><br/>  Please find the Account statement as requested.';
                htmlBody += '<br/><br/>Regards,<br/>Customer Care Team.';
                message.setFileAttachments(new Messaging.EmailFileAttachment[] {att});
                message.setHtmlBody(htmlBody);  
                message.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
                messages.add(message);
                Messaging.SendEmailResult[] result = Messaging.sendEmail(messages);
                bkgs[0].Send_Account_Statement__c = false;//Added for Triggering mails multiple times-depening on the customer.Changed - 25-11-24
            }
            tsk.Status = 'Completed';
        }catch(Exception e){
            tsk.Description = 'Error: ' + e.getMessage();
        }
        update tsk;
        update bkgs[0];
    }
}