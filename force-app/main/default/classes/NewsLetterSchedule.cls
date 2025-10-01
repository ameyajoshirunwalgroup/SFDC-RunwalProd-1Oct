global class NewsLetterSchedule implements Database.Batchable <sObject>, Schedulable{
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id, Name, RW_Email__c, Primary_Name__c, News_Letter_Date__c FROM Opportunity WHERE News_Letter_Date__c =: Date.today()]);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> opps){
        list <Messaging.SingleEmailMessage> mails = new list <Messaging.SingleEmailMessage>();
        EmailTemplate template = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='News_Letter'];
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        for(Attachment att : [select Name, Body, BodyLength from Attachment where ParentId = :template.Id]){
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            efa.setFileName(att.Name);
            efa.setBody(att.Body);
            fileAttachments.add(efa);
        }
        for(Opportunity opp : opps){
            String htmlBody = template.HtmlValue;
            htmlBody = htmlBody.replace('{!Opportunity.Primary_Name__c}', opp.Name);
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = new List<String>{opp.RW_Email__c};
            message.subject = template.Subject;
            message.setTemplateId(template.Id);
            message.setHtmlBody(htmlBody);   
            message.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());   
            /*List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
            for(Attachment att : [select Name, Body, BodyLength from Attachment where ParentId = :template.Id]){
                Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                efa.setFileName(att.Name);
                efa.setBody(att.Body);
                fileAttachments.add(efa);
            }*/
            message.setFileAttachments(fileAttachments);
            mails.add(message);
        }
        if(mails.size() > 0){
            Messaging.SendEmailResult[] result = Messaging.sendEmail(mails, false);
        	System.debug('result' + result);
        }
        
    }
    
    global void finish(Database.BatchableContext BC){

    }
    
    global void execute(SchedulableContext dc) {
        NewsLetterSchedule b = new NewsLetterSchedule();
        Database.executeBatch(b, 100);
    }
}