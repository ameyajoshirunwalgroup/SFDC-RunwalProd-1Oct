public class ReminderFor5PercentPayment implements Schedulable{

    public void execute(SchedulableContext sc){
        
        Date dt = Date.today();
        List<Booking__c> bgsToSendNotification = [SELECT Id, Next_Reminder_Date_5_Payment__c, Opportunity__r.RW_Email__c, Opportunity__r.RW_Mobile_No__c, Opportunity__r.Account.Country_Code__c, Primary_Applicant_Email__c FROM Booking__c WHERE Status__c = 'Booking Confirmed' AND X4_5_Received__c = false AND Next_Reminder_Date_5_Payment__c =: dt];
        /*List<Booking__c> bgsToSendNotification = new List<Booking__c>();
        for(Booking__c bkg : bkgs){
            if(bkg.Next_Reminder_Date_5_Payment__c == Date.today()){
                bgsToSendNotification.add(bkg);
            }
        }*/
        
        if(bgsToSendNotification.size() > 0){
            List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
            for(Booking__c bkg : bgsToSendNotification){
                bkg.Next_Reminder_Date_5_Payment__c = Date.today() + 3;
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                //message.toAddresses = new List<String>{bkg.Opportunity__r.RW_Email__c};
                message.toAddresses = new List<String>{bkg.Primary_Applicant_Email__c};
                String emailBody = 'Dear Customer,<br/><br/>';
                emailBody += 'This is a reminder email.<br/>';
                emailBody += 'Request you to kindly clear the balance amount of 5% of your booked unit in Runwal to move ahead with your booking journey.<br/>';
                emailBody += 'Kindly contact your Sales Manager for further details.<br/><br/>';
                emailBody += 'Incase, you have paid 5%, then kindly ignore this email.<br/><br/>';
                emailBody += 'Regards,<br/>';
                emailBody += 'Runwal Group';
                String plainTextBody = 'Dear Customer,\n\n this is a reminder, request you to kindly clear the balance amount of 5% of your booked unit in Runwal to move ahead with your booking journey, kindly contact your sales manager for further details. \n\n Incase, you have paid 5%, then kindly ignore this email.';
                message.setHtmlBody(emailBody);
                message.setSubject('Reminder for Payment');
                message.setPlainTextBody(plainTextBody);
                message.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
                messages.add(message);
                if(!Test.isRunningTest()){
                    SendWhatsAppMsg.methodToSendWhatsAppMsg(null, null, null, null, null, null, null, null, null, bkg.Opportunity__r.Account.Country_Code__c, bkg.Opportunity__r.RW_Mobile_No__c, '4.5% Payment Reminder');
                }
            }
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            update bgsToSendNotification;
        }
    }
}