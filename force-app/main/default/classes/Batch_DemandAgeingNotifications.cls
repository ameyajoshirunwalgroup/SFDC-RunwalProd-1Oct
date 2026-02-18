global class Batch_DemandAgeingNotifications implements Database.Batchable<SObject>, Schedulable {
    
    // Query records where ageing is greater than 0 and required lookup fields exist
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Name, RW_Demand_Aging__c, PTP_Ageing__c,
            Booking__r.Project__r.Team_Leader__r.Email,
            Booking__r.Project__r.Team_Leader__r.Id
            FROM RW_Demand__c
            WHERE (RW_Demand_Aging__c > 0 AND PTP_Ageing__c > 0)
            AND Booking__r.Project__r.Team_Leader__r.Id != null
            AND Booking__r.Project__r.Team_Leader__r.Email != null
           
        ]);
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        system.debug('scope>>>>' +scope);
        // Fetch the email template once
        EmailTemplate emailTemplate;
        try {
            emailTemplate = [SELECT Id,DeveloperName
                             FROM EmailTemplate 
                             WHERE DeveloperName = 'Notify_TL_Regarding_Demand_Ageing_VF' 
                             LIMIT 1];
            system.debug('emailTemplate>>>>' +emailTemplate);
        } catch (Exception e) {
            System.debug('Email template not found: ' + e.getMessage());
            return; 
        }
        
        for (RW_Demand__c objDemand : (List<RW_Demand__c>)scope) {
            if (
                objDemand.Booking__r != null &&
                objDemand.Booking__r.Project__r != null &&
                objDemand.Booking__r.Project__r.Team_Leader__r != null
            ) {
                String toEmail = objDemand.Booking__r.Project__r.Team_Leader__r.Email;
                Id userId = objDemand.Booking__r.Project__r.Team_Leader__r.Id;
                
                if (String.isNotBlank(toEmail) && userId != null) {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setTargetObjectId(userId);       
                    email.setWhatId(objDemand.Id);          
                    email.setTemplateId(emailTemplate.Id);  
                    email.setSaveAsActivity(false);
                    email.setTreatTargetObjectAsRecipient(true);
                    
                    emailMessages.add(email);
                }
            }
        }
        system.debug('emailMessages>>>>' +emailMessages);
        if (!emailMessages.isEmpty()) {
            try {
                system.debug('EMail sent');
                Messaging.sendEmail(emailMessages);
            } catch (Exception e) {
                System.debug('Failed to send emails: ' + e.getMessage());
            }
        }
    }
    
    global void finish(Database.BatchableContext bc) {
    }
    
    // Schedulable implementation
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new Batch_DemandAgeingNotifications(), 200);
    }
}