public class CPBrokerageTriggerHandler {
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
    
    //Added by Prashant/....5-1-26 START
    public static void updateTDSonChildInvoices(Set<Id> bIds) {
        List<CP_Brokerage__c> cpblist = [ SELECT Id, Total_Brokerage__c, SAP_TDS__c, (SELECT Id, Brokerage_In_Rs__c FROM Brokerage_Invoices__r) FROM CP_Brokerage__c WHERE Id IN :bIds];
        List<Brokerage_Invoice__c> bilist = new List<Brokerage_Invoice__c>();
        for (CP_Brokerage__c c : cpblist) {            
            if (c.Brokerage_Invoices__r == null || c.Brokerage_Invoices__r.isEmpty()) {
                continue;
            }            
            Decimal totalBrokerageParent = c.Total_Brokerage__c != null ? c.Total_Brokerage__c : 0;
            Decimal tdsParent = c.SAP_TDS__c != null ? c.SAP_TDS__c : 0;
            
            if (totalBrokerageParent == 0) {
                continue;
            }
            Decimal tdsRatio = tdsParent / totalBrokerageParent;            
            for (Brokerage_Invoice__c bi : c.Brokerage_Invoices__r) {                
                if (bi.Brokerage_In_Rs__c == null) continue;                
                bi.SAP_TDS__c = (bi.Brokerage_In_Rs__c * tdsRatio).setScale(2, RoundingMode.HALF_UP);
                bilist.add(bi);
            }
        }
        
        if(!bilist.isEmpty()){
            try{
                update bilist; 
            }catch(Exception e){
                system.debug('Invoice Update Error: ' + e.getMessage()); 
            } 
        }
    }

    //Added by Prashant/....5-1-26 END
}