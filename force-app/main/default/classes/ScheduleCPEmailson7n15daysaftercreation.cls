global class ScheduleCPEmailson7n15daysaftercreation implements Schedulable {
    global void execute(SchedulableContext sc) {
        Id tempRecordTypeId = Schema.SObjectType.Broker__c.getRecordTypeInfosByName().get('Temp Channel Partner').getRecordTypeId();
        List<Broker__c> cplist = [SELECT Id,CreatedDate,Name,Sourcing_Manager__c,Sourcing_Manager__r.Name,Sourcing_Manager__r.Email,Sourcing_Manager__r.Manager.Name,
                                  Sourcing_Manager__r.Manager.Email,days_from_creation__c,RW_Broker_Number__c FROM Broker__c WHERE 
                                  /*Id = 'a019I00000NH65VQAT'*/(days_from_creation__c = 7 or days_from_creation__c =15) and RecordTypeId =: tempRecordTypeId]; 
        system.debug('cplist -> '+cplist);
        EmailTemplate etsevendays = [SELECT Id,HtmlValue, Body,Subject FROM EmailTemplate WHERE DeveloperName = 'Send_Email_to_Sourcing_after_7_days_of_Temp_Creation' LIMIT 1];
        EmailTemplate etfifteendays = [SELECT Id,HtmlValue, Body,Subject FROM EmailTemplate WHERE DeveloperName = 'Send_Email_to_Sourcing_after_15_days_of_Temp_Creation' LIMIT 1];
        list<Contact> dummyContact = [Select id from Contact limit 1];
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        if(!cplist.isEmpty()){
            for(Broker__c br: cplist){
                if (br.Sourcing_Manager__c != null) {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    if(br.days_from_creation__c == 7) {
                        email.setTemplateId(etSevenDays.Id);//Send email to sourcing after 7 days of temp cp creation
                        email.setToAddresses(new String[] {br.Sourcing_Manager__r.Email});///Send to User.
                        //email.setToAddresses(new String[] {'prashant.chaurasia.os@runwalgroup.in'});///Send to Admin for Testing.
                    } else if (br.days_from_creation__c == 15) {
                        email.setTemplateId(etFifteenDays.Id);//Send email to sourcing after 15 days of temp cp creation
                        //etfifteendays.HtmlValue.replace('{!Manager}', br.CreatedBy.Manager.Name); 
                        //etfifteendays.HtmlValue.replace('{!Manager}', br.CreatedBy.Manager.Name);
                        String subject = etFifteenDays.Subject;
                        subject = subject.replace('{!Broker__c.Name}', br.Name);
                        String htmlBody = etFifteenDays.HtmlValue;
                        htmlBody = htmlBody.replace('{!Manager}', br.Sourcing_Manager__r.Manager.Name);
                        htmlBody = htmlBody.replace('{!Broker__c.Name}', br.Name);
                        htmlBody = htmlBody.replace('{!Broker__c.CreatedBy}', br.Sourcing_Manager__r.Name); 
                        htmlBody = htmlBody.replace('{!Broker__c.RW_Broker_Number__c}', br.RW_Broker_Number__c); 
                        String plainBody = etFifteenDays.Body;
                        plainBody = plainBody.replace('{!Manager}', br.Sourcing_Manager__r.Manager.Name);
                        plainBody = plainBody.replace('{!Broker__c.Name}', br.Name);
                        plainBody = plainBody.replace('{!Broker__c.CreatedBy}', br.Sourcing_Manager__r.Name); 
                        plainBody = plainBody.replace('{!Broker__c.RW_Broker_Number__c}', br.RW_Broker_Number__c); 
                        email.setSubject(subject);
                        email.setHtmlBody(htmlBody);
                        email.setPlainTextBody(plainBody); 
                        email.setToAddresses(new String[] {br.Sourcing_Manager__r.Manager.Email}); 
                        email.setCcAddresses(new String[] {br.Sourcing_Manager__r.Email});
                    }
                    email.setTargetObjectId(dummyContact[0].Id);
                    email.setTreatTargetObjectAsRecipient(false);
                    email.setUseSignature(false);
                    email.setBccSender(false);
                    email.setWhatId(br.Id);                               
                    email.setSaveAsActivity(false);
                    emails.add(email);
                }
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