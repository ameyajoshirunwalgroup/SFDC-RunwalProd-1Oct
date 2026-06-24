public class CPBrokerageInvoiceTriggerHandler {
    @future // Use @future to run this asynchronously and avoid Mixed DML errors
    public static void sendEmailmethod(Set<Id> cpBrokerageIds) {

        // 1. Find the Email Template
        // IMPORTANT: Update 'Channel_Partner_Invoice_Generation_Request'
        // to be the *exact* Developer Name / API Name of your template.
        EmailTemplate template = [
            SELECT Id, DeveloperName
            FROM EmailTemplate
            WHERE DeveloperName = 'Channel_Partner_Invoice_Generation_Request'
            LIMIT 1
        ];

        // 2. Get the records and the recipient email addresses
        List<CP_Brokerage__c> brokeragesToEmail = [
            SELECT Id, Channel_Partner__r.RW_Email__c, Channel_Partner__r.Name
            FROM CP_Brokerage__c
            WHERE Id IN :cpBrokerageIds
            AND Channel_Partner__r.RW_Email__c != null // Only get records with an email
        ];

        if (brokeragesToEmail.isEmpty()) {
            // No one to email, so we can stop.
            return;
        }
        // Get dummy contact email from custom label
        String dummyEmail = Label.EmailForChannelPartner;
        Contact dummyContacts = [SELECT Id,Email FROM Contact where Email =: dummyEmail  LIMIT 1];

        // 3. Create a list of emails to send
        List<Messaging.SingleEmailMessage> allEmails = new List<Messaging.SingleEmailMessage>();

        for (CP_Brokerage__c brokerage : brokeragesToEmail) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateId(template.Id);
            mail.setWhatId(brokerage.Id);
            mail.setTargetObjectId(dummyContacts.Id);
            mail.setToAddresses(new List<String>{ brokerage.Channel_Partner__r.RW_Email__c });
            mail.setSaveAsActivity(false);
            allEmails.add(mail);
        }

        // 4. Send all emails at once (bulk-safe)
        if (!allEmails.isEmpty()) {
            try {
                Messaging.sendEmail(allEmails);
            } catch (Exception e) {
                System.debug('Error sending Channel Partner emails: ' + e.getMessage());
            }
        }
    }
}