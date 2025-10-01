global class SendCampaignEmailsBatch implements Database.Batchable<String>{
    
    global List<String> emails;
    global String templateName;
    
    global SendCampaignEmailsBatch(List<String> emails, String templateName) {
        this.emails = emails;
        this.templateName = templateName;
    }
    
    global System.Iterable <String> start(Database.BatchableContext BC){
        
        return this.emails;
    }
    
    global void execute(Database.BatchableContext bc, List<String> emails){
        
        if(emails.size() > 0){
            try{
                List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
                String orgEmailAddress = Utility.getOrgWideEmailAddress();
                EmailTemplate template = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where Name =: templateName];
                List<Attachment> atts = [SELECT Id, Name, Body, ParentId, Parent.Name, ContentType  from Attachment where ParentId =: template.Id];
                List<Messaging.Emailfileattachment> emailAttachments = new List<Messaging.Emailfileattachment>();
                if(atts.size() > 0){
                    for(Attachment at : atts){
                        Messaging.Emailfileattachment att = new Messaging.Emailfileattachment();
                        att.setFileName(at.Name);
                        att.setBody(at.Body);
                        att.setContentType(at.ContentType);
                        emailAttachments.add(att);
                    }
                     
                }
                for(String email : emails){
                    Messaging.SingleEmailMessage Message = new Messaging.SingleEmailMessage();
                    String htmlBody = template.HtmlValue;
                    String plainTextBody = template.Body;
                    message.toAddresses = new List<String>{email};
                    message.subject = template.Subject;
                    message.setTemplateId(template.Id);
                    message.setHtmlBody(htmlBody);   
                    message.setPlainTextBody(plainTextBody);
                    message.setOrgWideEmailAddressId(orgEmailAddress);
                    if(atts.size() > 0){
                        message.setFileAttachments(emailAttachments);
                    }
                    emailList.add(message);
                }
                if(!Test.isRunningTest()){
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(emailList);
                }
            }catch(Exception e){
                system.debug('Exception :: '+e);
            }
        }
        
    }
    
	global void finish(Database.BatchableContext BC) {}  
}