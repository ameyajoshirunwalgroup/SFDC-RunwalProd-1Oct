global class SendSDRNotificationBatch implements Database.Batchable<sObject>,Database.Stateful
{ 
    global FINAL String strQuery;
    global List<String> errorMessages = new List<String>();
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id, Name, RW_SDR_Status__c,Primary_Applicant_Name__c, RW_Last_Reminder_letter_sent_date__c, RW_Email_Reminder_Count__c, Owner.Email, Project__r.Project_CRM_Lead__r.Email,Sales_Manager__r.Email, Unit_No__r.Relationship_Manager__r.RM_Email__c, Primary_Applicant_Email__c, Unit_No__r.Relationship_Manager__r.RM_Name__c, RW_Registration_Date__c, Unit_No__r.Name, Project__r.Name FROM Booking__c  where RW_SDR_Status__c!= 'Received' AND RW_SDR_Letter_Sent__c = true AND RW_Email_Reminder_Count__c < :Integer.valueOf(System.Label.RW_SDR_Reminder_dates)]);
    }
    
    global void execute(Database.BatchableContext BC, List<Booking__c> scopeList) {
        system.debug('scopeList ****' + scopeList);
        List<Booking__c> bookingToUpdate = new List<Booking__c>();    
        if(!scopeList.isEmpty()) { 
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            Integer reminderDays =  Integer.valueOf(System.Label.RW_SDR_Reminder_dates);
            
            for (Booking__c sdr : scopeList)
            {   
                Integer noOfDays;
                system.debug('SDR--->' + sdr);
                if(sdr.RW_Last_Reminder_letter_sent_date__c != null)
                {
                    noOfDays = System.today().daysBetween(sdr.RW_Last_Reminder_letter_sent_date__c);
                }
                
                if(sdr.RW_Last_Reminder_letter_sent_date__c == null && sdr.RW_Email_Reminder_Count__c == 0)
                {
                    sdr.RW_Email_Reminder_Count__c = 1;
                    system.debug('RW_Email_Reminder_Count__c =>' + sdr.RW_Email_Reminder_Count__c);
                    bookingToUpdate.add(sdr);
                    
                    //first reminder mail 
                    if(sdr.Primary_Applicant_Email__c !=null)
                    {
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();   
                    EmailTemplate template = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName = 'SDR_1'];
                    
                    String htmlBody = template.HtmlValue; 
                    String plainTextBody = template.Body;
                    system.debug('Email Template -->' + template);
                    system.debug('before replace -->');
                    
                    if(sdr.Primary_Applicant_Name__c !=null)
                    {
                    htmlBody = htmlBody.replace('{!Booking__c.Primary_Applicant_Name__c}', sdr.Primary_Applicant_Name__c);
                    plainTextBody = plainTextBody.replace('{!Booking__c.Primary_Applicant_Name__c}', sdr.Primary_Applicant_Name__c);
                  
                    }
                    else
                    {
                     htmlBody = htmlBody.replace('{!Booking__c.Primary_Applicant_Name__c}', 'Sir');
                     plainTextBody = plainTextBody.replace('{!Booking__c.Primary_Applicant_Name__c}', 'Sir');
                    }               
               
                    if(sdr.Unit_No__r.Name !=null)
                    {
                    htmlBody = htmlBody.replace('{!Booking__c.Unit_No__r.Name}', sdr.Unit_No__r.Name );
                    plainTextBody = plainTextBody.replace('{!Booking__c.Unit_No__r.Name}', sdr.Unit_No__r.Name ); 
                    }
                    else
                    {
                     htmlBody = htmlBody.replace('{!Booking__c.Unit_No__r.Name}', '');
                     plainTextBody = plainTextBody.replace('{!Booking__c.Unit_No__r.Name}', '');
                    }
                    if(sdr.Project__r.Name !=null)
                    {
                    htmlBody = htmlBody.replace('{!Booking__c.Project__r.Name}', sdr.Project__r.Name );
                    plainTextBody = plainTextBody.replace('{!Booking__c.Project__r.Name}', sdr.Project__r.Name ); 
                    }
                    else
                    {
                     htmlBody = htmlBody.replace('{!Booking__c.Project__r.Name}', '');
                     plainTextBody = plainTextBody.replace('{!Booking__c.Project__r.Name}', '');
                    }
               
                    
                    message.setTemplateID(template.Id);
                                        
                    String[] toAddresses = new String[] {sdr.Primary_Applicant_Email__c};
                    Message.setToAddresses(toAddresses);
                    if(sdr.Unit_No__r.Relationship_Manager__c != null && sdr.Unit_No__r.Relationship_Manager__r.RM_Email__c !=null)
                    {
                    String[] ccAddresses = new String[] {sdr.Unit_No__r.Relationship_Manager__r.RM_Email__c};  
                    Message.setccAddresses(ccAddresses);   
                    }   
                    Message.subject = template.Subject;
                    Message.setHtmlBody(htmlBody);   
                    Message.setPlainTextBody(plainTextBody);
                    Message.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());                   
                    Message.SaveAsActivity = false;
                    mailList.add(Message);
    
                    sdr.RW_Last_Reminder_letter_sent_date__c = date.today();
                    system.debug('Last Reminder sent Date --> '+  sdr.RW_Last_Reminder_letter_sent_date__c);   
                  }
                    
                }
                
                else if(math.mod(noOfDays,reminderDays)==0 && sdr.RW_Email_Reminder_Count__c == 1)
                {
                    //second reminder mail
                    sdr.RW_Email_Reminder_Count__c = 2;
                    system.debug('RW_Email_Reminder_Count__c =>' + sdr.RW_Email_Reminder_Count__c);
                    bookingToUpdate.add(sdr);
                    
                     if(sdr.Primary_Applicant_Email__c !=null)
                    {
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage(); 
                    
                    EmailTemplate template = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName = 'SDR_2'];
                    
                    String htmlBody = template.HtmlValue; 
                    String plainTextBody = template.Body;
                    system.debug('Email Template -->' + template);
                    system.debug('before replace -->');
                    
                    if(sdr.Primary_Applicant_Name__c !=null)
                    {
                    htmlBody = htmlBody.replace('{!Booking__c.Primary_Applicant_Name__c}', sdr.Primary_Applicant_Name__c);
                    plainTextBody = plainTextBody.replace('{!Booking__c.Primary_Applicant_Name__c}', sdr.Primary_Applicant_Name__c);
                    }
                    else
                    {
                     htmlBody = htmlBody.replace('{!Booking__c.Primary_Applicant_Name__c}', 'Sir');
                     plainTextBody = plainTextBody.replace('{!Booking__c.Primary_Applicant_Name__c}', 'Sir');
                    }               

                    if(sdr.Unit_No__r.Name !=null)
                    {
                    htmlBody = htmlBody.replace('{!Booking__c.Unit_No__r.Name}', sdr.Unit_No__r.Name );
                    plainTextBody = plainTextBody.replace('{!Booking__c.Unit_No__r.Name}', sdr.Unit_No__r.Name );
                    }
                    else
                    {
                     htmlBody = htmlBody.replace('{!Booking__c.Unit_No__r.Name}', '');
                     plainTextBody = plainTextBody.replace('{!Booking__c.Unit_No__r.Name}', '');
                    }
                    if(sdr.Project__r.Name !=null)
                    {
                    htmlBody = htmlBody.replace('{!Booking__c.Project__r.Name}', sdr.Project__r.Name );
                    plainTextBody = plainTextBody.replace('{!Booking__c.Project__r.Name}', sdr.Project__r.Name );
                    }
                    else
                    {
                     htmlBody = htmlBody.replace('{!Booking__c.Project__r.Name}', '');
                     plainTextBody = plainTextBody.replace('{!Booking__c.Project__r.Name}', '');
                    }
               
                    
                    String[] toAddresses = new String[] {sdr.Primary_Applicant_Email__c};
                    Message.setToAddresses(toAddresses);
                    if(sdr.Unit_No__r.Relationship_Manager__c != null && sdr.Unit_No__r.Relationship_Manager__r.RM_Email__c !=null)
                    {
                    String[] ccAddresses = new String[] {sdr.Unit_No__r.Relationship_Manager__r.RM_Email__c};  
                    Message.setccAddresses(ccAddresses);   
                    }   
                    Message.subject = template.Subject;
                    Message.setHtmlBody(htmlBody);   
                    Message.setPlainTextBody(plainTextBody);
                    Message.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());                   
                    Message.SaveAsActivity = false;
                    mailList.add(Message);
                   
                    
                    sdr.RW_Last_Reminder_letter_sent_date__c = date.today();
                }
                }
                
                else if(math.mod(noOfDays,reminderDays)==0 && sdr.RW_Email_Reminder_Count__c == 2)
                {
                    //third reminder mail
                    sdr.RW_Email_Reminder_Count__c = 3;
                    system.debug('RW_Email_Reminder_Count__c =>' + sdr.RW_Email_Reminder_Count__c);
                    bookingToUpdate.add(sdr);
                    
                     if(sdr.Primary_Applicant_Email__c !=null)
                    {
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    EmailTemplate template = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName = 'SDR_3'];
                    
                    String htmlBody = template.HtmlValue; 
                    String plainTextBody = template.Body;
                    system.debug('Email Template -->' + template);
                    system.debug('before replace -->');
                    
                    if(sdr.Primary_Applicant_Name__c !=null)
                    {
                    htmlBody = htmlBody.replace('{!Booking__c.Primary_Applicant_Name__c}', sdr.Primary_Applicant_Name__c);
                    plainTextBody = plainTextBody.replace('{!Booking__c.Primary_Applicant_Name__c}', sdr.Primary_Applicant_Name__c);
                    }
                    else
                    {
                     htmlBody = htmlBody.replace('{!Booking__c.Primary_Applicant_Name__c}', 'Sir');
                     plainTextBody = plainTextBody.replace('{!Booking__c.Primary_Applicant_Name__c}', 'Sir');
                    }               
                    if(sdr.Unit_No__r.Name !=null)
                    {
                    htmlBody = htmlBody.replace('{!Unit_No__r.Name}', sdr.Unit_No__r.Name );
                    plainTextBody = plainTextBody.replace('{!Unit_No__r.Name}', sdr.Unit_No__r.Name );
                    }
                    else
                    {
                     htmlBody = htmlBody.replace('{!Unit_No__r.Name}', '');
                     plainTextBody = plainTextBody.replace('{!Unit_No__r.Name}', '');
                    }
                    if(sdr.Project__r.Name !=null)
                    {
                    htmlBody = htmlBody.replace('{!Booking__c.Project__r.Name}', sdr.Project__r.Name );
                    plainTextBody = plainTextBody.replace('{!Booking__c.Project__r.Name}', sdr.Project__r.Name );
                    }
                    else
                    {
                     htmlBody = htmlBody.replace('{!Booking__c.Project__r.Name}', '');
                     plainTextBody = plainTextBody.replace('{!Booking__c.Project__r.Name}', '');
                    }
               
                    
                    String[] toAddresses = new String[] {sdr.Primary_Applicant_Email__c};
                    Message.setToAddresses(toAddresses);
                    if(sdr.Unit_No__r.Relationship_Manager__c != null && sdr.Unit_No__r.Relationship_Manager__r.RM_Email__c !=null)
                    {
                    String[] ccAddresses = new String[] {sdr.Unit_No__r.Relationship_Manager__r.RM_Email__c};  
                    Message.setccAddresses(ccAddresses);   
                    }   
                    Message.subject = template.Subject;
                    Message.setHtmlBody(htmlBody);   
                    Message.setPlainTextBody(plainTextBody);
                    Message.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());                   
                    Message.SaveAsActivity = false;
                    mailList.add(Message);
                    
                    sdr.RW_Last_Reminder_letter_sent_date__c = date.today();
                }
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