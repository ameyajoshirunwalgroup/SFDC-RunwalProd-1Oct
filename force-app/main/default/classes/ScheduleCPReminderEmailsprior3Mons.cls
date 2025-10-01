global class ScheduleCPReminderEmailsprior3Mons implements Schedulable {
    global void execute(SchedulableContext sc) {
        Date threeMonthsFromNow = System.today().addMonths(3);
        Id cpRecordTypeId = Schema.SObjectType.Broker__c.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
        List<Broker__c> cplist = [SELECT Id,Sourcing_Manager__c,Sourcing_Manager__r.Email,RW_Email__c,CC_Valid_till__c,RERA_Valid_till__c,OwnerId FROM Broker__c WHERE (CC_Valid_till__c =: threeMonthsFromNow or RERA_Valid_till__c =: threeMonthsFromNow) and RecordTypeId =: cpRecordTypeId]; 
        system.debug('cplist -> '+cplist);
        
        EmailTemplate etRERA3monstoCP = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Send_Email_to_CP_for_RERA_Expiring_in_3_months' LIMIT 1];
        EmailTemplate etRERA3monstoSM = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Send_Email_to_Sourcing_for_RERA_Expiring_in_3_months' LIMIT 1];
        EmailTemplate etCC3monstoCP = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Send_Email_to_CP_for_CC_Expiring_in_3_months' LIMIT 1];
        EmailTemplate etCC3monstoSM = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Send_Email_to_Sourcing_for_CC_Expiring_in_3_months' LIMIT 1];
        list<Contact> dummyContact = [Select id from Contact limit 1];
		
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        for (Broker__c br : cplist) {
            if (br.Sourcing_Manager__c != null && br.Sourcing_Manager__r.Email != null) {
                Messaging.SingleEmailMessage smemail;
                
                if (br.RERA_Valid_till__c == threeMonthsFromNow) {
                    smemail = new Messaging.SingleEmailMessage();
                    smemail.setTemplateId(etRERA3monstoSM.Id);
                    smemail.setTargetObjectId(dummyContact[0].Id);
                    smemail.setTreatTargetObjectAsRecipient(false);
                    smemail.setUseSignature(false);
                    smemail.setBccSender(false);
                    smemail.setWhatId(br.Id);
                    smemail.toAddresses = new String[] { br.Sourcing_Manager__r.Email };
                    smemail.setSaveAsActivity(false);
                    emails.add(smemail);
                }
                
                if (br.CC_Valid_till__c == threeMonthsFromNow) {
                    smemail = new Messaging.SingleEmailMessage();
                    smemail.setTemplateId(etCC3monstoSM.Id);
                    smemail.setTargetObjectId(dummyContact[0].Id);
                    smemail.setTreatTargetObjectAsRecipient(false);
                    smemail.setUseSignature(false);
                    smemail.setBccSender(false);
                    smemail.setWhatId(br.Id);
                    smemail.setToAddresses(new String[] { br.Sourcing_Manager__r.Email });
                    smemail.setSaveAsActivity(false);
                    emails.add(smemail);
                }
            } else {
                System.debug('No Sourcing Manager email');
            }
            
            if (!String.isBlank(br.RW_Email__c)) {
                Messaging.SingleEmailMessage cpemail;
                
                if (br.RERA_Valid_till__c == threeMonthsFromNow) {
                    cpemail = new Messaging.SingleEmailMessage();
                    cpemail.setTemplateId(etRERA3monstoCP.Id);
                    cpemail.setTargetObjectId(dummyContact[0].Id);
                    cpemail.setTreatTargetObjectAsRecipient(false);
                    cpemail.setUseSignature(false);
                    cpemail.setBccSender(false);
                    cpemail.setWhatId(br.Id);
                    cpemail.setToAddresses(new String[] { br.RW_Email__c });
                    cpemail.setSaveAsActivity(false);
                    emails.add(cpemail);
                }
                
                if (br.CC_Valid_till__c == threeMonthsFromNow) {
                    cpemail = new Messaging.SingleEmailMessage();
                    cpemail.setTemplateId(etCC3monstoCP.Id);
                    cpemail.setTargetObjectId(dummyContact[0].Id);
                    cpemail.setTreatTargetObjectAsRecipient(false);
                    cpemail.setUseSignature(false);
                    cpemail.setBccSender(false);
                    cpemail.setWhatId(br.Id);
                    cpemail.setToAddresses(new String[] { br.RW_Email__c });
                    cpemail.setSaveAsActivity(false);
                    emails.add(cpemail);
                }
            } else {
                System.debug('No Channel Partner email');
            }
        }
        
        if (!emails.isEmpty()) {
            try {
                Messaging.sendEmail(emails);
            } catch (Exception ex) {
                system.debug('Error in sending emails: ' + ex.getMessage() + ' stack ' + ex.getStackTraceString());
            }
        }

    }
}