public class SendCPEmails implements Queueable, Database.AllowsCallouts {

    private Map<Id, String> tempCPIdVsEmailMap;
    private String emailTemplateName;

    public SendCPEmails(Map<Id, String> tempCPIdVsEmailMap, String templateName) {
        this.tempCPIdVsEmailMap = tempCPIdVsEmailMap;
        this.emailTemplateName = templateName;
    }

    public void execute(QueueableContext context) {
        EmailTemplate selectedTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = :emailTemplateName LIMIT 1];
        Contact dummyContact = [SELECT Id FROM Contact LIMIT 1];
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Id br : tempCPIdVsEmailMap.keySet()) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTemplateId(selectedTemplate.Id);
            email.setTargetObjectId(dummyContact.Id);
            email.setTreatTargetObjectAsRecipient(false);
            email.setUseSignature(false);
            email.setBccSender(false);
            email.setWhatId(br);
            email.setToAddresses(new String[] {tempCPIdVsEmailMap.get(br)});
            email.setSaveAsActivity(false);
            emails.add(email);
        }

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
}



/*public class SendCPEmails {
    @future(callout=true)
    public static void SendTempCPCreationEmail(Map<Id,String> tempCPIdVsEmailMap){
        EmailTemplate tempCPCreation = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Temp_CP_creation_Email' LIMIT 1];
        list<Contact> dummyContact = [Select id from Contact limit 1];
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for(Id br: tempCPIdVsEmailMap.keyset()){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTemplateId(tempCPCreation.Id);
            email.setTargetObjectId(dummyContact[0].Id);
            email.setTreatTargetObjectAsRecipient(false);
            email.setUseSignature(false);
            email.setBccSender(false);
            email.setWhatId(br);
            email.setToAddresses(new String[] {tempCPIdVsEmailMap.get(br)});                
            email.setSaveAsActivity(false);
            emails.add(email);
        }
       
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
}*/