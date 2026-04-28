public class SendWhatsappMsgtoCPBulkBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    private String query;
    private Boolean sendEmail;

    public SendWhatsappMsgtoCPBulkBatch(String q, Boolean se) {
        this.query = q;
        this.sendEmail = se;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Broker__c> brlist) {
        Map<Id, String> tempCPIdVsEmailMap = new Map<Id, String>();
        
        for(Broker__c b : brlist) {
            if (String.isBlank(b.RW_Mobile_No__c)) {
                continue; 
            }
            try {
                String brokerNumber = String.isNotBlank(b.RW_Broker_Number__c) ? b.RW_Broker_Number__c : '';                
                //String cpAppownloadLink = 'https://play.google.com/store/apps/details?id=com.lockated.runwal.cp&pcampaignid=web_share';
                //String cpAppownloadLink = 'https://tinyurl.com/RunwalElevate';
                String cpAppDownloadlinkAndroid = system.label.CP_App_Download_link_Android;
                String cpAppDownloadlinkIOS = system.label.CP_App_Download_link_IOS;
                SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(null,b.Name,b.RW_Email__c,b.RW_Mobile_No__c,null, null, null, null, null,'+91', b.RW_Mobile_No__c,'Registered CP App login');
                system.debug('sendEmail -> '+sendEmail);
                system.debug('RW_Email__c -> '+b.RW_Email__c);
                system.debug('Whatsapp Msg Sent');
                if(sendEmail && String.isNotBlank(b.RW_Email__c)) {
                    tempCPIdVsEmailMap.put(b.Id, b.RW_Email__c);
                }

            } catch (Exception e) {
                System.debug('Error sending WhatsApp for Broker ' + b.Id + ' - ' + e.getMessage());
            }
        }
        
        if(!tempCPIdVsEmailMap.isEmpty()){
            try {
                System.enqueueJob(new SendCPEmails(tempCPIdVsEmailMap, 'Temp_CP_creation_Email'));
            } catch (Exception e) {
                System.debug('Failed to enqueue email job: ' + e.getMessage());
            }
        }
    }
    
    public void finish(Database.BatchableContext bc){
        System.debug('WhatsApp Bulk Batch Completed.');
    }
}