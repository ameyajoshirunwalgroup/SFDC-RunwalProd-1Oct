global class ReferralAndLoyaltyEmailsBatch implements Database.Batchable<sObject>{
    
    global List<String> recIds;
    global String templateName;
    global String recTypeName;
    
     global ReferralAndLoyaltyEmailsBatch(List<String> recIds, String templateName, String recTypeName) {
        this.recIds = recIds;
        this.templateName = templateName;
        this.recTypeName = recTypeName;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id, Name, RW_Email__c, Account.PersonContactId FROM Opportunity WHERE Id =: this.recIds]);
    }
    
    global void execute(Database.BatchableContext bc, List<Opportunity> oppList){
        
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        String orgEmailAddress = Utility.getOrgWideEmailAddress();
        EmailTemplate template = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where Name =: templateName];
        
        for(Opportunity opp : oppList){
            System.debug('opp: ' + opp);
            Messaging.SingleEmailMessage Message = new Messaging.SingleEmailMessage();
            String htmlBody = template.HtmlValue;
            String plainTextBody = template.Body;
            message.toAddresses = new List<String>{opp.RW_Email__c};
            message.subject = template.Subject;
            message.setTemplateId(template.Id);
            message.setHtmlBody(htmlBody);   
            message.setPlainTextBody(plainTextBody);
            message.setOrgWideEmailAddressId(orgEmailAddress);
            //message.setTreatTargetObjectAsRecipient(false);
            message.setTargetObjectId(opp.Account.PersonContactId);
            message.setWhatId(opp.Id);
            emailList.add(message);
        }
         Messaging.SendEmailResult[] results = Messaging.sendEmail(emailList);
    }
    
    global void finish(Database.BatchableContext BC) {}  
}