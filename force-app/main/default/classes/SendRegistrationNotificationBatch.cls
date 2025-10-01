global class SendRegistrationNotificationBatch implements Database.Batchable<sObject>,Database.Stateful
{ 
    global FINAL String strQuery;
    global List<String> errorMessages = new List<String>();
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id, RW_Registration_Reminder_Count__c, RW_Registration_Status__c, RW_Last_Registration_Reminder_Sent__c,  Project__r.Project_CRM_Lead__r.Email,Sales_Manager__r.Email, Unit_No__r.Relationship_Manager__r.RM_Email__c, Primary_Applicant_Email__c FROM Booking__c where RW_Registration_Status__c!='Registration Completed']);
    }
    
    global void execute(Database.BatchableContext BC, List<Booking__c> scopeList) {
        
        List<Booking__c> bookingToUpdate = new List<Booking__c>();    
        if(!scopeList.isEmpty()) { 
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            Integer reminderDays =  Integer.valueOf(System.Label.RW_SDR_Reminder_dates);
            system.debug('reminder days' + reminderDays);
            
            for (Booking__c reg : scopeList)
            {   
                Integer noOfDays;
                system.debug('SDR--->' + reg);
                if(reg.RW_Last_Registration_Reminder_Sent__c != null)
                {
                    noOfDays = System.today().daysBetween(reg.RW_Last_Registration_Reminder_Sent__c);
                }
                
                if(reg.RW_Last_Registration_Reminder_Sent__c == null && reg.RW_Registration_Reminder_Count__c == 0)
                {
                    reg.RW_Registration_Reminder_Count__c = 1;
                    system.debug('RW_Registration_Reminder_Count__c =>' + reg.RW_Registration_Reminder_Count__c);
                    bookingToUpdate.add(reg);
                    
                    //first reminder mail                    
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();   
                    EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'Registration Reminder 1'];
                    message.setTemplateID(emailTemplate.Id); 
                    Message.setTargetObjectId(UserInfo.getUserId());
                    String[] toAddresses = new String[] {reg.Primary_Applicant_Email__c};
                    String[] ccAddresses = new String[] {reg.Unit_No__r.Relationship_Manager__r.RM_Email__c};
                    Message.setToAddresses(toAddresses);
                    Message.setccAddresses(ccAddresses);
                    system.debug('toAdreess--->'+ toAddresses);
                    Message.SaveAsActivity = false;
                    mailList.add(Message);
                    
                    reg.RW_Last_Registration_Reminder_Sent__c = date.today();                
                }
                
                else if(math.mod(noOfDays,reminderDays)==0 && reg.RW_Registration_Reminder_Count__c == 1)
                {
                    //second reminder mail
                    reg.RW_Registration_Reminder_Count__c = 2;
                    system.debug('RW_Registration_Reminder_Count__c =>' + reg.RW_Registration_Reminder_Count__c);
                    bookingToUpdate.add(reg);
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();   
                    EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'Registration Reminder 2'];
                    message.setTemplateID(emailTemplate.Id);  
                    Message.setTargetObjectId(UserInfo.getUserId());
                    String[] toAddresses = new String[] {reg.Primary_Applicant_Email__c};
                    String[] ccAddresses = new String[] {reg.Unit_No__r.Relationship_Manager__r.RM_Email__c};
                    Message.setToAddresses(toAddresses);
                    Message.setccAddresses(ccAddresses);
                    Message.SaveAsActivity = false;
                    mailList.add(Message);
                    
                    reg.RW_Last_Registration_Reminder_Sent__c = date.today();
                }
                
                else if(math.mod(noOfDays,reminderDays)==0 && reg.RW_Registration_Reminder_Count__c == 2)
                {
                    //third reminder mail
                    reg.RW_Registration_Reminder_Count__c = 3;
                    system.debug('RW_Registration_Reminder_Count__c =>' + reg.RW_Registration_Reminder_Count__c);
                    bookingToUpdate.add(reg);
                    
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'Registration Reminder 3'];
                    message.setTemplateID(emailTemplate.Id);
                    Message.setTargetObjectId(UserInfo.getUserId());
                    String[] toAddresses = new String[] {reg.Primary_Applicant_Email__c};
                    String[] ccAddresses = new String[] {reg.Unit_No__r.Relationship_Manager__r.RM_Email__c};
                    Message.setToAddresses(toAddresses); 
                    Message.setccAddresses(ccAddresses);
                    Message.SaveAsActivity = false;
                    mailList.add(Message);   
                    
                    reg.RW_Last_Registration_Reminder_Sent__c = date.today();
                    
                }
                
            } 
            if(!mailList.isEmpty() ) {
                
                // Messaging.sendEmail(mailList);   
                Messaging.SendEmailResult[] results = Messaging.sendEmail(mailList);
                
                system.debug('Messaging ' + results[0]);
                
                if (results[0].success) {
                    System.debug('The email was sent successfully.');
                    
                } else{
                    System.debug('The email failed to send: ' + results[0].errors[0].message);
                }
                update bookingToUpdate;
            } 
            
        }
        
    }
    
    
    
    global void finish(Database.BatchableContext BC) { 
        
      
        
    }
    
}