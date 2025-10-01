global class PossessionGuidelinesSchedule implements Database.Batchable <sObject>, Database.AllowsCallouts, Schedulable{
    
    global EmailTemplate template;
    global String orgEmailAddress;
    
    global PossessionGuidelinesSchedule(){
        this.template = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName = 'Possession_Guidelines_Template'];
        this.orgEmailAddress = Utility.getOrgWideEmailAddress();
    }
	
    global Database.QueryLocator start(Database.BatchableContext BC){
        if(!Test.isRunningTest()){
            /*return Database.getQueryLocator([SELECT Id, Primary_Applicant_Email__c, Opportunity__r.Name, Opportunity__r.RW_Mobile_No__c, Opportunity__r.RW_Email__c, RW_Country_Phone_Code__c
                                         FROM Booking__c WHERE Possession_Guidelines_Sent_Date__c = null AND Payment_Received__c >= 95 AND Status__c ='Booking Confirmed']);*/ // Commented by coServe 09-07-2024
            return Database.getQueryLocator([SELECT Id, Primary_Applicant_Email__c, Opportunity__r.Name, Opportunity__r.RW_Mobile_No__c, Opportunity__r.RW_Email__c, RW_Country_Phone_Code__c
                                         FROM Booking__c WHERE Possession_Guidelines_Sent_Date__c = null AND Demanded_Principal__c >= 95 AND Status__c ='Booking Confirmed']); // Added by coServe 12-07-2024
        }else{
            return Database.getQueryLocator([SELECT Id, Primary_Applicant_Email__c, Opportunity__r.Name, Opportunity__r.RW_Mobile_No__c, Opportunity__r.RW_Email__c, RW_Country_Phone_Code__c
                                         FROM Booking__c]);
        }
        
    }
    
    global void execute(Database.BatchableContext BC, List<Booking__c> bkgs){
        list <Messaging.SingleEmailMessage> mails = new list <Messaging.SingleEmailMessage>();
        //EmailTemplate template = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName = 'Possession_Guidelines_Template'];
        //String orgEmailAddress = Utility.getOrgWideEmailAddress();
        for(Booking__c bkg : bkgs){
            bkg.Possession_Guidelines_Sent_Date__c = Date.today();
            /*Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String htmlBody = template.HtmlValue;
            String plainTextBody = template.Body;
            mail.toAddresses = new List<String>{bkg.Opportunity__r.RW_Email__c};
            //mail.toAddresses = new List<String>{'birendra.hati@runwalgroup.in'};
            mail.subject = template.Subject;
            mail.setTemplateId(template.Id);
            mail.setHtmlBody(htmlBody);   
            mail.setPlainTextBody(plainTextBody);
            mail.setOrgWideEmailAddressId(orgEmailAddress);
            mail.setTargetObjectId(Userinfo.getUserId());
        	mail.setTreatTargetObjectAsRecipient(false);
            mails.add(mail);*/
            String email = System.label.Possession_Guidelines_Email;
            String mobile = System.label.Possession_Guidelines_Mobile;
            Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
            String htmlBody1 = template.HtmlValue;
            String plainTextBody1 = template.Body;
            //mail.toAddresses = new List<String>{bkg.Opportunity__r.RW_Email__c};
            String toAddr;
            if(email != null && email != '' && email != 'null'){
                //mail1.toAddresses = new List<String>{email};
                toAddr = email;
            }else{
                //mail1.toAddresses = new List<String>{bkg.Opportunity__r.RW_Email__c};
                toAddr = bkg.Opportunity__r.RW_Email__c;
            }
            
            /*mail1.subject = template.Subject;
            mail1.setTemplateId(template.Id);
            mail1.setHtmlBody(htmlBody1);   
            mail1.setPlainTextBody(plainTextBody1);
            mail1.setOrgWideEmailAddressId(orgEmailAddress);
            mail1.setTargetObjectId(Userinfo.getUserId());
        	mail1.setTreatTargetObjectAsRecipient(false);
            mails.add(mail1);*/
            
            String fileURL = System.label.Possession_Guidelines_File_URL;
            if(!Test.isRunningTest()){
                //SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(null, null, null, null, null, null, null, fileURL, 'Possession Guidelines', bkg.RW_Country_Phone_Code__c, bkg.Opportunity__r.RW_Mobile_No__c, 'possession_guidelines');                    
                if(mobile != null && mobile != '' && mobile != 'null'){
                    SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(null, null, null, null, null, null, null, fileURL, 'Possession Guidelines', '+91', mobile, 'possession_guidelines');                    
                }else{
                    SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(null, null, null, null, null, null, null, fileURL, 'Possession Guidelines', bkg.RW_Country_Phone_Code__c, bkg.Opportunity__r.RW_Mobile_No__c, 'possession_guidelines');                    
                }
                
            }
            System.debug('toAddr: ' + toAddr);
            if(toAddr != null){
                mail1.toAddresses = new List<String>{toAddr};
                mail1.subject = template.Subject;
                mail1.setTemplateId(template.Id);
                mail1.setHtmlBody(htmlBody1);   
                mail1.setPlainTextBody(plainTextBody1);
                mail1.setOrgWideEmailAddressId(orgEmailAddress);
                mail1.setTargetObjectId(Userinfo.getUserId());
                mail1.setTreatTargetObjectAsRecipient(false);
                mails.add(mail1);
            }
        }
        System.debug('mails: ' + mails);
        Database.update(bkgs, false);
        if(mails.size() > 0){
            //Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
        }
        
    }
    
    global void finish(Database.BatchableContext BC){

    }
    
    global void execute(SchedulableContext dc) {

        PossessionGuidelinesSchedule b = new PossessionGuidelinesSchedule();
        Database.executeBatch(b, 1);
    }
}