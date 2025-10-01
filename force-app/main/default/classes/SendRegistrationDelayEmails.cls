global class SendRegistrationDelayEmails {
    @InvocableMethod(label='Send RegistrationDelay Email')
    global static void SendEmail(EmailRequest[] requests){
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        for (EmailRequest req : requests) {
            EmailTemplate et = [SELECT Id, Subject, Htmlvalue FROM EmailTemplate WHERE Id = :req.TemplateId];
            List<Booking__c> bList = [SELECT Id, Name, Customer__r.Name,Project__r.Sales_Head__c,Flat_No__c,Booking_Date__c,Project__r.Sales_Head__r.Email, RW_Registration_Date__c,RW_Project_Name__c, Agreement_Value_for_brokers__c FROM Booking__c WHERE Id = :req.RecordId];
            String plainBody = et.HtmlValue;
            String plainSubject = et.Subject;
            plainBody = (bList[0].Customer__r.Name != null) ? plainBody.replace('{!Booking__c.Customer_Name__c}', bList[0].Customer__r.Name) : plainBody.replace('{!Booking__c.Customer_Name__c}', '');
            plainBody = (bList[0].RW_Project_Name__c != null) ? plainBody.replace('{!Booking__c.RW_Project_Name__c}', bList[0].RW_Project_Name__c) : plainBody.replace('{!Booking__c.RW_Project_Name__c}', ''); 
            plainBody = (bList[0].Name != null) ? plainBody.replace('{!Booking__c.Name}', bList[0].Name) : plainBody.replace('{!Booking__c.Name}', '');
            plainBody = (bList[0].Booking_Date__c != null) ? plainBody.replace('{!Booking__c.Booking_Date__c}', bList[0].Booking_Date__c.format()) : plainBody.replace('{!Booking__c.Booking_Date__c}', '');
            plainBody = (bList[0].RW_Registration_Date__c != null) ? plainBody.replace('{!Booking__c.RW_Registration_Date__c}', bList[0].RW_Registration_Date__c.format()) : plainBody.replace('{!Booking__c.RW_Registration_Date__c}', '');
            plainBody = (bList[0].Flat_No__c != null) ? plainBody.replace('{!Booking__c.Flat_No__c}', String.valueOf(bList[0].Flat_No__c)) : plainBody.replace('{!Booking__c.Flat_No__c}', '');

            // Split the email addresses into a list
            List<String> toAddress = req.toEmail.split(',');

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateId(et.Id);
            mail.setToAddresses(toAddress);
            mail.setSubject(plainSubject);
            mail.setHTMLBody(plainBody);
            mail.setWhatId(req.RecordId);
            mail.setSaveAsActivity(true);
            OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'customercare@runwalgroup.in'];
            if (owea.size() > 0) {
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            allmsg.add(mail); 
              if (bList[0].Project__r.Sales_Head__c != null && bList[0].Project__r.Sales_Head__r.Email != null) {
                Messaging.SingleEmailMessage salesHeadMail = new Messaging.SingleEmailMessage();
                salesHeadMail.setTemplateId(et.Id);
                salesHeadMail.setToAddresses(new List<String>{bList[0].Project__r.Sales_Head__r.Email});
                salesHeadMail.setSubject(plainSubject);
                salesHeadMail.setHTMLBody(plainBody);
                salesHeadMail.setWhatId(req.RecordId);
                salesHeadMail.setSaveAsActivity(true);
                
                // Set the OrgWideEmailAddress for Sales Head email
                if (owea.size() > 0) {
                    salesHeadMail.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                
                allmsg.add(salesHeadMail);
            }
        }
        Messaging.sendEmail(allmsg, false);
    }
    
    global class EmailRequest {
        @InvocableVariable(required=true)
        global String toEmail;
        
        @InvocableVariable(required=true)
        global String TemplateId;
        
        @InvocableVariable
        global String RecordId;
    }
}