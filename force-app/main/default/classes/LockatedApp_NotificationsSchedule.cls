public class LockatedApp_NotificationsSchedule  implements Schedulable{

    public List<App_Notification__c> notifications = new List<App_Notification__c>();
    List<LockatedApp_WhatsappMsgQueueable.ParameterWrap> wrapList = new List<LockatedApp_WhatsappMsgQueueable.ParameterWrap>();
    
    public void execute(SchedulableContext SC){
        /*nextStepsGuideNotification(); //After 2 days of Booking Confirmed
        ncfReminderNotification();
        clearanceOf5And10PercentNotification(); //Clearance of 5% & 10%- when 5% & 10% check box is enabled on booking record 
        loanDocSubmissionNotification(); //After 3 days of Logged In Date in loan record if loan is not sanctioned then this notification will be triggered
        sanctionLetterSubmissionReminder();
        outstandingDueNotification();
        newsLetterNotification();
        birthdayNotification();
        paymentReminderNotification();
        refBkg20PercentPayed();
        tdsPaymentGuideNotification();
        milestonePaymentAchievement();*/
        //paymentDetailsNotification();
        
        if(notifications.size() > 0){
            insert notifications;
        }
        if(wrapList.size() > 0){
            //System.enqueueJob(new LockatedApp_WhatsappMsgQueueable(wrapList));
            Database.executeBatch(new LockatedApp_WhatsappMsgQueueable(wrapList), 10);
        }
    }
    
    public void nextStepsGuideNotification(){
        List<Post_Sales_App_Notifications__mdt> ntfDetails = [SELECT Title__c,Message__c,Notification_Type__c,Email_Subject__c,Email_Message__c,Whatsapp_Template_Name__c,Active__c FROM Post_Sales_App_Notifications__mdt WHERE DeveloperName = 'Booking_to_Registration_Guide' AND Active__c = true LIMIT 1];
        if(ntfDetails.size() > 0){
            Post_Sales_App_Notifications__mdt details = ntfDetails[0];
            Date dt = Date.today() - 2;
            List<Booking__c> bkgs = [SELECT Id,Lockated_User_Device_ID__c,Primary_Applicant_Name__c,Primary_Applicant_Email__c,RW_Country_Phone_Code__c,Opportunity__r.RW_Mobile_No__c,Primary_Applicant_Mobile__c FROM Booking__c WHERE RW_Booking_Confirmed_Date__c =: dt];
            if(bkgs.size() > 0){
                List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
                for(Booking__c bkg : bkgs){
                    if(bkg.Lockated_User_Device_ID__c != null && details.Message__c != null){
                        Set<String> deviceTokens = new Set<String>(bkg.Lockated_User_Device_ID__c.split(';'));
                        String message = ((details.Message__c.contains('{1}'))? details.Message__c.replace('{1}', (bkg.Primary_Applicant_Name__c != null)? bkg.Primary_Applicant_Name__c : 'Customer') : details.Message__c);
                        for(String token : deviceTokens){
                            App_Notification__c an = new App_Notification__c();
                            an.Booking__c = bkg.Id;
                            an.Title__c = details.Title__c;
                            an.Message__c = message;
                            an.Notification_Type__c = details.Notification_Type__c;
                            an.Device_Token__c = token;
                            notifications.add(an);
                        }
                    }
                    if(bkg.Primary_Applicant_Email__c != null && details.Email_Message__c != null){
                        String body = DynamicEmailService.generateEmailBody(bkg.Id, 'Booking_to_Registration_Guide', 'Body');
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(new List<String>{bkg.Primary_Applicant_Email__c});
                        mail.setSubject(details.Email_Subject__c);
                        mail.setPlainTextBody(body);
                        emailList.add(mail);
                    }
                    //SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(null,bkg.Primary_Applicant_Name__c,null,null,null,null,null,null,null,bkg.RW_Country_Phone_Code__c, bkg.Opportunity__r.RW_Mobile_No__c,'Booking to Registration Guide'); 
                    if(details.Whatsapp_Template_Name__c != null){
                        LockatedApp_WhatsappMsgQueueable.ParameterWrap wrap = LockatedApp_WhatsappMsgQueueable.wrapper(null,bkg.Primary_Applicant_Name__c,null,null,null,null,null,null,null,bkg.RW_Country_Phone_Code__c,bkg.Primary_Applicant_Mobile__c,details.Whatsapp_Template_Name__c); 
                        wrapList.add(wrap);
                    }
                    //System.enqueueJob(new LockatedApp_WhatsappMsgQueueable(wrap));
                }
                if(notifications.size() > 0){
                //insert notifications;
                }
                if(emailList.size() > 0){
                    Messaging.SendEmailResult[] result = Messaging.sendEmail(emailList);
                }
                
            }
        }
    }
    
    public void ncfReminderNotification(){
        List<Post_Sales_App_Notifications__mdt> ntfDetails = [SELECT Title__c,Message__c,Notification_Type__c,Email_Subject__c,Email_Message__c,Whatsapp_Template_Name__c,Active__c FROM Post_Sales_App_Notifications__mdt WHERE DeveloperName = 'Reminder_if_NCF_Not_Shared' AND Active__c = true LIMIT 1];
        if(ntfDetails.size() > 0){
            Post_Sales_App_Notifications__mdt details = ntfDetails[0];
            Date dt = Date.today() - 3;
            List<RW_Welcome_Call__c> welcomecalls = [SELECT Id,RW_Booking__c,RW_Booking__r.Lockated_User_Device_ID__c,RW_Booking__r.Primary_Applicant_Name__c,RW_Welcome_Call_Accepted_date__c,RW_Booking__r.RW_Country_Phone_Code__c,RW_Booking__r.Opportunity__r.RW_Mobile_No__c,RW_Booking__r.Primary_Applicant_Email__c,RW_Booking__r.Primary_Applicant_Mobile__c FROM RW_Welcome_Call__c WHERE RW_Welcome_Call_Accepted_date__c <=: dt AND RW_Booking__r.NCF_Status__c = 'Pending'];
            if(welcomecalls.size() > 0){
                Date today = Date.today();
                List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
                
                for(RW_Welcome_Call__c wc : welcomecalls){
                    Integer daysPassed = (wc.RW_Welcome_Call_Accepted_date__c + 3).daysBetween(today);
                    if(wc.RW_Booking__c != null && wc.RW_Booking__r.Lockated_User_Device_ID__c != null && details.Message__c != null && daysPassed > 0 && Math.mod(daysPassed, 3) == 0){
                        Set<String> deviceTokens = new Set<String>(wc.RW_Booking__r.Lockated_User_Device_ID__c.split(';'));
                        String message = ((details.Message__c.contains('{1}'))? details.Message__c.replace('{1}', (wc.RW_Booking__r.Primary_Applicant_Name__c != null)? wc.RW_Booking__r.Primary_Applicant_Name__c : 'Customer') : details.Message__c);
                        for(String token : deviceTokens){
                            App_Notification__c an = new App_Notification__c();
                            an.Booking__c = wc.RW_Booking__c;
                            an.Title__c = details.Title__c;
                            an.Message__c = message;
                            an.Notification_Type__c = details.Notification_Type__c;
                            an.Device_Token__c = token;
                            notifications.add(an);
                        }
                    }
                    //SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(null,wc.RW_Booking__r.Primary_Applicant_Name__c,null,null,null,null,null,null,null,wc.RW_Booking__r.RW_Country_Phone_Code__c,wc.RW_Booking__r.Opportunity__r.RW_Mobile_No__c,'NCF Reminder'); 
                    if(details.Whatsapp_Template_Name__c != null){
                        LockatedApp_WhatsappMsgQueueable.ParameterWrap wrap = LockatedApp_WhatsappMsgQueueable.wrapper(null,wc.RW_Booking__r.Primary_Applicant_Name__c,null,null,null,null,null,null,null,wc.RW_Booking__r.RW_Country_Phone_Code__c,wc.RW_Booking__r.Primary_Applicant_Mobile__c,details.Whatsapp_Template_Name__c); 
                        wrapList.add(wrap);
                    }
                    //System.enqueueJob(new LockatedApp_WhatsappMsgQueueable(wrap));
                    if(wc.RW_Booking__r.Primary_Applicant_Email__c != null && details.Email_Message__c != null){
                        String body = DynamicEmailService.generateEmailBody(wc.RW_Booking__c, 'Reminder_if_NCF_Not_Shared', 'Body');
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(new List<String>{wc.RW_Booking__r.Primary_Applicant_Email__c});
                        mail.setSubject(details.Email_Subject__c);
                        mail.setPlainTextBody(body);
                        emailList.add(mail);
                    }
                }
                if(notifications.size() > 0){
                //insert notifications;
                }
                if(emailList.size() > 0){
                    //Messaging.SendEmailResult[] result = Messaging.sendEmail(emailList);
                }
            }
        }
    }
    
    /*public void clearanceOf5And10PercentNotification(){
        Map<Id,Booking__c> bkgMap = new Map<Id, Booking__c>([SELECT Id,RW_Total_Amount_Received_Without_GST__c,Allotment_Premium__c,Lockated_User_Device_ID__c,Primary_Applicant_Name__c FROM Booking__c WHERE RW_Total_Amount_Received_Without_GST__c > 0]);
        List<App_Notification__c> notifications = new List<App_Notification__c>();
        Map<Id, App_Notification__c> fivePercent = new Map<Id, App_Notification__c>();
        Map<Id, App_Notification__c> tenPercent = new Map<Id, App_Notification__c>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        for(App_Notification__c ntf : [SELECT Id,Booking__c,Clearance_of_5__c,Clearance_of_10__c FROM App_Notification__c WHERE Booking__c =: bkgMap.keySet() AND (Clearance_of_5__c = true OR Clearance_of_10__c = true)]){
            if(ntf.Clearance_of_5__c){
                    fivePercent.put(ntf.Booking__c, ntf);
            }else if(ntf.Clearance_of_10__c){
                tenPercent.put(ntf.Booking__c, ntf);
            }
        }
        if(bkgMap.size() > 0){
            for(Booking__c bkg : bkgMap.values()){
                if(bkg.Lockated_User_Device_ID__c != null){
                    //List<String> deviceTokens = bkg.Lockated_User_Device_ID__c.split(';');
                    Set<String> deviceTokens = new Set<String>(bkg.Lockated_User_Device_ID__c.split(';'));
                    String message = 'Dear ' + bkg.Primary_Applicant_Name__c + ',\n Please clear your pending dues as per the payment schedule to avoid extra charges and registration delay. Check your Runwal app or contact support if needed.';
                    for(String token : deviceTokens){
                        Decimal val = ((bkg.RW_Total_Amount_Received_Without_GST__c * 100)/bkg.Allotment_Premium__c).setScale(2, RoundingMode.HALF_UP);
                        System.debug('val: ' + val);
                        if(val >= 10 && tenPercent.get(bkg.Id) == null){
                            App_Notification__c an = new App_Notification__c();
                            an.Booking__c = bkg.Id;
                            an.Title__c = 'Payment Reminder for Dues';
                            an.Message__c = message;
                            an.Notification_Type__c = 'demand';
                            an.Device_Token__c = token;
                            an.Clearance_of_10__c = true;
                            notifications.add(an);
                        }else if(val >= 5 && fivePercent.get(bkg.Id) == null){
                            App_Notification__c an = new App_Notification__c();
                            an.Booking__c = bkg.Id;
                            an.Title__c = 'Payment Reminder for Dues';
                            an.Message__c = message;
                            an.Notification_Type__c = 'demand';
                            an.Device_Token__c = token;
                            an.Clearance_of_5__c = true;
                            notifications.add(an);
                        }
                    }
                }
                //SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(null,bkg.Primary_Applicant_Name__c,null,null,null,null,null,null,null,bkg.RW_Country_Phone_Code__c,bkg.Opportunity__r.RW_Mobile_No__c,'TDS Form Upload Reminder'); 
                if(bkg.Primary_Applicant_Email__c != null){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new List<String>{bkg.Primary_Applicant_Email__c});
                    mail.setSubject('Payment Reminder for Dues');
                    String body = 'Dear Customer, <br/><br/>';
                    body += 'Greetings from Runwal Enterprises!! <br/>';
                    body += 'we request you to kindly clear your dues as per the payment schedule.<br/><br/>';
                    mail.setHtmlBody(body);
                    emailList.add(mail);
                }
            }
            if(notifications.size() > 0){
                insert notifications;
            }
            if(emailList.size() > 0){
                Messaging.SendEmailResult[] result = Messaging.sendEmail(emailList);
            }
        }
    }*/
    
    public void clearanceOf5And10PercentNotification(){
        List<Post_Sales_App_Notifications__mdt> ntfDetails = [SELECT Title__c,Message__c,Notification_Type__c,Email_Subject__c,Email_Message__c,Whatsapp_Template_Name__c,Active__c FROM Post_Sales_App_Notifications__mdt WHERE DeveloperName = 'Payment_Reminder_for_Dues' AND Active__c = true LIMIT 1];
        if(ntfDetails.size() > 0){
            Post_Sales_App_Notifications__mdt details = ntfDetails[0];
            Map<Id,Booking__c> bkgMap = new Map<Id, Booking__c>([SELECT Id,RW_Total_Amount_Received_Without_GST__c,Allotment_Premium__c,Lockated_User_Device_ID__c,Primary_Applicant_Name__c,Primary_Applicant_Email__c,RW_Country_Phone_Code__c,Primary_Applicant_Mobile__c,(SELECT Id, CreatedDate FROM Demands__r ORDER By CreatedDate ASC LIMIT 1) FROM Booking__c WHERE RW_Total_Demand_Raised__c > 0 AND RW_Registration_Date__c = null AND (X5_Received__c = false OR RW_X9_99_Received__c = false)]);
            List<App_Notification__c> notifications = new List<App_Notification__c>();
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            
            if(bkgMap.size() > 0){
                
                for(Booking__c bkg : bkgMap.values()){
                    RW_Demand__c dem = bkg.Demands__r[0];
                    if(bkg.Lockated_User_Device_ID__c != null && details.Message__c != null){
                        Set<String> deviceTokens = new Set<String>(bkg.Lockated_User_Device_ID__c.split(';'));
                        String message = ((details.Message__c.contains('{1}'))? details.Message__c.replace('{1}', (bkg.Primary_Applicant_Name__c != null)? bkg.Primary_Applicant_Name__c : 'Customer') : details.Message__c);
                        for(String token : deviceTokens){
                            Date today = Date.today();
                            Integer daysPassed = Date.valueOf(dem.Createddate).daysBetween(today);
                            if (daysPassed > 0 && Math.mod(daysPassed, 5) == 0){
                                App_Notification__c an = new App_Notification__c();
                                an.Booking__c = bkg.Id;
                                an.Title__c = details.Title__c;
                                an.Message__c = message;
                                an.Notification_Type__c = details.Notification_Type__c;
                                an.Device_Token__c = token;
                                an.Clearance_of_10__c = true;
                                notifications.add(an);
                            }
                        }
                    }
                    //SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(null,bkg.Primary_Applicant_Name__c,null,null,null,null,null,null,null,bkg.RW_Country_Phone_Code__c,bkg.Opportunity__r.RW_Mobile_No__c,'TDS Form Upload Reminder'); 
                    if(bkg.Primary_Applicant_Email__c != null && details.Email_Message__c != null){
                        String body = DynamicEmailService.generateEmailBody(dem.Id, 'Payment_Reminder_for_Dues', 'Body');
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(new List<String>{bkg.Primary_Applicant_Email__c});
                        mail.setSubject(details.Email_Subject__c);
                        mail.setPlainTextBody(body);
                        emailList.add(mail);
                    }
                    if(details.Whatsapp_Template_Name__c != null){
                        LockatedApp_WhatsappMsgQueueable.ParameterWrap wrap = LockatedApp_WhatsappMsgQueueable.wrapper(null,bkg.Primary_Applicant_Name__c,null,null,null,null,null,null,null,bkg.RW_Country_Phone_Code__c,bkg.Primary_Applicant_Mobile__c,details.Whatsapp_Template_Name__c); 
                        wrapList.add(wrap);
                    }
                }
                if(notifications.size() > 0){
                    //insert notifications;
                }
                if(emailList.size() > 0){
                    Messaging.SendEmailResult[] result = Messaging.sendEmail(emailList);
                }
            }
        }
    }
    
    public void loanDocSubmissionNotification(){
        List<Post_Sales_App_Notifications__mdt> ntfDetails = [SELECT Title__c,Message__c,Notification_Type__c,Email_Subject__c,Email_Message__c,Whatsapp_Template_Name__c,Active__c FROM Post_Sales_App_Notifications__mdt WHERE DeveloperName = 'Loan_Documentation_Submission_Reminder' AND Active__c = true LIMIT 1];
        if(ntfDetails.size() > 0){
            Post_Sales_App_Notifications__mdt details = ntfDetails[0];
            List<Loan__c> loans = [SELECT Id,RW_Booking__c,RW_Booking__r.Lockated_User_Device_ID__c,RW_Booking__r.Primary_Applicant_Name__c,RW_Booking__r.RW_Country_Phone_Code__c,RW_Booking__r.Opportunity__r.RW_Mobile_No__c,RW_Booking__r.Primary_Applicant_Email__c,RW_Booking__r.Primary_Applicant_Mobile__c FROM Loan__c WHERE RW_Loan_Record_Status__c = 'HL Documentation Initiated'];
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            List<Id> loanIds = new List<Id>();
            for(Loan__c ln : loans){
                loanIds.add(ln.Id);
            }
            Map<Id,Date> loanIdVsNotificationDate = new Map<Id, Date>();
            for(App_Notification__c ntf : [SELECT Id,Record_Id__c,CreatedDate FROM App_Notification__c WHERE Record_Id__c =: loanIds AND Title__c = 'Loan Documentation Submission Reminder']){
                loanIdVsNotificationDate.put(ntf.Record_Id__c,Date.valueOf(ntf.CreatedDate));
            }
            
            for(Loan__c ln : loans){
                if(ln.RW_Booking__c != null && ln.RW_Booking__r.Lockated_User_Device_ID__c != null && details.Message__c != null){
                    Set<String> deviceTokens = new Set<String>(ln.RW_Booking__r.Lockated_User_Device_ID__c.split(';'));
                    String message = ((details.Message__c.contains('{1}'))? details.Message__c.replace('{1}', (ln.RW_Booking__r.Primary_Applicant_Name__c != null)? ln.RW_Booking__r.Primary_Applicant_Name__c : 'Customer') : details.Message__c);
                    Date today = Date.today();
                    Integer daysPassed = (loanIdVsNotificationDate != null && loanIdVsNotificationDate.get(ln.Id) != null)? loanIdVsNotificationDate.get(ln.Id).daysBetween(today) : 0;
                    if (daysPassed > 0 && Math.mod(daysPassed, 3) == 0){
                        for(String token : deviceTokens){
                            App_Notification__c an = new App_Notification__c();
                            an.Booking__c = ln.RW_Booking__c;
                            an.Title__c = details.Title__c;
                            an.Message__c = message;
                            an.Notification_Type__c = details.Notification_Type__c;
                            an.Record_Id__c = ln.Id;
                            an.Device_Token__c = token;
                            notifications.add(an);
                        }
                    }
                }
                //SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(null,ln.RW_Booking__r.Primary_Applicant_Name__c,null,null,null,null,null,null,null,ln.RW_Booking__r.RW_Country_Phone_Code__c,ln.RW_Booking__r.Opportunity__r.RW_Mobile_No__c,'Loan Documentation Submission Reminder'); 
                if(details.Whatsapp_Template_Name__c != null){
                    LockatedApp_WhatsappMsgQueueable.ParameterWrap wrap = LockatedApp_WhatsappMsgQueueable.wrapper(null,ln.RW_Booking__r.Primary_Applicant_Name__c,null,null,null,null,null,null,null,ln.RW_Booking__r.RW_Country_Phone_Code__c,ln.RW_Booking__r.Primary_Applicant_Mobile__c,details.Whatsapp_Template_Name__c); 
                    wrapList.add(wrap);
                }
                //System.enqueueJob(new LockatedApp_WhatsappMsgQueueable(wrap));
                if(ln.RW_Booking__r.Primary_Applicant_Email__c != null && details.Email_Message__c != null){
                    String body = DynamicEmailService.generateEmailBody(ln.Id, 'Loan_Documentation_Submission_Reminder', 'Body');
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new List<String>{ln.RW_Booking__r.Primary_Applicant_Email__c});
                    mail.setSubject(details.Email_Subject__c);
                    mail.setPlainTextBody(body);
                    emailList.add(mail);
                }
            }
            if(notifications.size() > 0){
                //insert notifications;
            }
            if(emailList.size() > 0){
                //Messaging.SendEmailResult[] result = Messaging.sendEmail(emailList);
            }
        }
        
    }
    
    public void sanctionLetterSubmissionReminder(){

        List<Post_Sales_App_Notifications__mdt> ntfDetails = [SELECT Title__c,Message__c,Notification_Type__c,Email_Subject__c,Email_Message__c,Whatsapp_Template_Name__c,Active__c FROM Post_Sales_App_Notifications__mdt WHERE DeveloperName = 'Sanction_Letter_Submission_Reminder' AND Active__c = true LIMIT 1];
        if(ntfDetails.size() > 0){
            Post_Sales_App_Notifications__mdt details = ntfDetails[0];
            Date dt = Date.today() - 3;
            List<Loan__c> loans = [SELECT Id,RW_Booking__c,RW_Booking__r.Lockated_User_Device_ID__c,RW_Booking__r.Primary_Applicant_Name__c,RW_Booking__r.RW_Country_Phone_Code__c,RW_Booking__r.Opportunity__r.RW_Mobile_No__c,RW_Booking__r.Primary_Applicant_Email__c,RW_Booking__r.Primary_Applicant_Mobile__c FROM Loan__c WHERE Logged_In_Date__c =: dt AND RW_Sanction_Status__c != 'Loan Sanctioned'];
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            
            for(Loan__c ln : loans){
                if(ln.RW_Booking__c != null && ln.RW_Booking__r.Lockated_User_Device_ID__c != null && details.Message__c != null){
                    Set<String> deviceTokens = new Set<String>(ln.RW_Booking__r.Lockated_User_Device_ID__c.split(';'));
                    String message = ((details.Message__c.contains('{1}'))? details.Message__c.replace('{1}', (ln.RW_Booking__r.Primary_Applicant_Name__c != null)? ln.RW_Booking__r.Primary_Applicant_Name__c : 'Customer') : details.Message__c);
                    for(String token : deviceTokens){
                        App_Notification__c an = new App_Notification__c();
                        an.Booking__c = ln.RW_Booking__c;
                        an.Title__c = details.Title__c;
                        an.Message__c = message;
                        an.Notification_Type__c = details.Notification_Type__c;
                        an.Record_Id__c = ln.Id;
                        an.Device_Token__c = token;
                        notifications.add(an);
                    }
                }
                //SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(null,ln.RW_Booking__r.Primary_Applicant_Name__c,null,null,null,null,null,null,null,ln.RW_Booking__r.RW_Country_Phone_Code__c,ln.RW_Booking__r.Opportunity__r.RW_Mobile_No__c,'Sanction Letter Submission Reminder'); 
                if(details.Whatsapp_Template_Name__c != null){
                    LockatedApp_WhatsappMsgQueueable.ParameterWrap wrap = LockatedApp_WhatsappMsgQueueable.wrapper(null,ln.RW_Booking__r.Primary_Applicant_Name__c,null,null,null,null,null,null,null,ln.RW_Booking__r.RW_Country_Phone_Code__c,ln.RW_Booking__r.Primary_Applicant_Mobile__c,details.Whatsapp_Template_Name__c); 
                    wrapList.add(wrap);
                }
                if(ln.RW_Booking__r.Primary_Applicant_Email__c != null && details.Email_Message__c != null){
                    String body = DynamicEmailService.generateEmailBody(ln.Id, 'Sanction_Letter_Submission_Reminder', 'Body');
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new List<String>{ln.RW_Booking__r.Primary_Applicant_Email__c});
                    mail.setSubject(details.Email_Subject__c);
                    mail.setPlainTextBody(body);
                    emailList.add(mail);
                }
            }
            if(notifications.size() > 0){
                //insert notifications;
            }
            if(emailList.size() > 0){
                //Messaging.SendEmailResult[] result = Messaging.sendEmail(emailList);
            }
        }
        
    }
    
    /*public void sanctionLetterSubmissionReminderNotification(){
        Date dt = Date.today() - 6;
        List<Loan__c> loans = [SELECT Id,RW_Booking__c,RW_Booking__r.Lockated_User_Device_ID__c,RW_Booking__r.Primary_Applicant_Name__c,Logged_In_Date__c,RW_Booking__r.RW_Country_Phone_Code__c,RW_Booking__r.Opportunity__r.RW_Mobile_No__c,RW_Booking__r.Primary_Applicant_Email__c FROM Loan__c WHERE Logged_In_Date__c <=: dt AND RW_Sanction_Status__c != 'Loan Sanctioned'];
        Date today = Date.today();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        for(Loan__c ln : loans){
            Integer daysPassed = (ln.Logged_In_Date__c + 3).daysBetween(today);
            if(ln.RW_Booking__c != null && ln.RW_Booking__r.Lockated_User_Device_ID__c != null && daysPassed > 0 && Math.mod(daysPassed, 3) == 0){
                //List<String> deviceTokens = ln.RW_Booking__r.Lockated_User_Device_ID__c.split(';');
                Set<String> deviceTokens = new Set<String>(ln.RW_Booking__r.Lockated_User_Device_ID__c.split(';'));
                String message = 'Dear ' + ln.RW_Booking__r.Primary_Applicant_Name__c + ',\n Please upload your home loan sanction letter within 3 days to proceed further with your booking and avoid delays.';
                for(String token : deviceTokens){
                    App_Notification__c an = new App_Notification__c();
                    an.Booking__c = ln.RW_Booking__c;
                    an.Title__c = 'Sanction Letter Submission Reminder';
                    an.Message__c = message;
                    an.Notification_Type__c = 'my_loan';
                    an.Record_Id__c = ln.Id;
                    an.Device_Token__c = token;
                    notifications.add(an);
                }
            }
            SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(null,ln.RW_Booking__r.Primary_Applicant_Name__c,null,null,null,null,null,null,null,ln.RW_Booking__r.RW_Country_Phone_Code__c,ln.RW_Booking__r.Opportunity__r.RW_Mobile_No__c,'Sanction Letter Submission Reminder'); 
            if(ln.RW_Booking__r.Primary_Applicant_Email__c != null){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<String>{ln.RW_Booking__r.Primary_Applicant_Email__c});
                mail.setSubject('Sanction Letter Submission Reminder');
                String body = 'Dear Customer, <br/><br/>';
                body += 'Greetings from Runwal Enterprises!! <br/>';
                body += 'Please submit your home loan sanction letter within 3 days to proceed further with your booking. Upload via Runwal app or contact Your RM for assistance to avoid delays.<br/><br/>';
                mail.setHtmlBody(body);
                emailList.add(mail);
            }
        }
        if(notifications.size() > 0){
            //insert notifications;
        }
        if(emailList.size() > 0){
            Messaging.SendEmailResult[] result = Messaging.sendEmail(emailList);
        }
    }*/
    
    public void outstandingDueNotification(){
        List<Post_Sales_App_Notifications__mdt> ntfDetails = [SELECT Title__c,Message__c,Notification_Type__c,Email_Subject__c,Email_Message__c,Whatsapp_Template_Name__c,Active__c FROM Post_Sales_App_Notifications__mdt WHERE DeveloperName = 'Clear_current_outstanding_dues' AND Active__c = true LIMIT 1];
        if(ntfDetails.size() > 0){
            Post_Sales_App_Notifications__mdt details = ntfDetails[0];
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            List<RW_Demand__c> demands = [SELECT Id,Due_Date__c,Booking__c,Booking__r.Opportunity__c,Booking__r.Lockated_User_Device_ID__c,Booking__r.Primary_Applicant_Name__c,Booking__r.Unit_No__c,Booking__r.Unit_No__r.Name,Booking__r.FBL5N__c,Booking__r.Unit_No__r.RW_Param4__c,Booking__r.Primary_Applicant_Mobile__c,Booking__r.RW_Country_Phone_Code__c,Booking__r.Primary_Applicant_Email__c FROM RW_Demand__c WHERE RW_Demand_Status__c = 'Due' AND Booking__r.FBL5N__c > 50000];
            
            for(RW_Demand__c dem : demands){
                Decimal demOut = dem.Booking__r.FBL5N__c;
                List<String> args = new String[]{'0','number','##,##,##,###.##'};
                String amount = String.format(demOut.format(), args);
                String message;
                if(dem.Booking__c != null && dem.Booking__r.Lockated_User_Device_ID__c != null && details.Message__c != null){
                    message = details.Message__c;
                    if(message.contains('{1}')){
                        message = message.replace('{1}', (dem.Booking__r.Primary_Applicant_Name__c != null)? dem.Booking__r.Primary_Applicant_Name__c : 'Customer');
                        if(message.contains('{2}')){
                            message = message.replace('{2}', (dem.Booking__r.Unit_No__r != null && dem.Booking__r.Unit_No__r.RW_Param4__c != null)? dem.Booking__r.Unit_No__r.RW_Param4__c : '');
                            if(message.contains('{3}')){
                                message = message.replace('{2}',(amount != null)? amount : '');
                            }
                        }
                    }
                    //List<String> deviceTokens = dem.Booking__r.Lockated_User_Device_ID__c.split(';');
                    Set<String> deviceTokens = new Set<String>(dem.Booking__r.Lockated_User_Device_ID__c.split(';'));
                    for(String token : deviceTokens){
                        if(dem.Due_Date__c != null){                    
                            if(Date.Today() == (dem.Due_Date__c - 10)){
                                App_Notification__c an = new App_Notification__c();
                                an.Booking__c = dem.Booking__c;
                                an.Title__c =  details.Title__c;
                                an.Message__c = message;
                                an.Notification_Type__c = details.Notification_Type__c;
                                an.Record_Id__c = dem.Id;
                                an.Device_Token__c = token;
                                notifications.add(an);
                            }else if(Date.Today() == (dem.Due_Date__c - 5)){
                                App_Notification__c an = new App_Notification__c();
                                an.Booking__c = dem.Booking__c;
                                an.Title__c =  details.Title__c;
                                an.Message__c = message;
                                an.Notification_Type__c = details.Notification_Type__c;
                                an.Record_Id__c = dem.Id;
                                an.Device_Token__c = token;
                                notifications.add(an);
                            }else if(Date.Today() == dem.Due_Date__c){
                                App_Notification__c an = new App_Notification__c();
                                an.Booking__c = dem.Booking__c;
                                an.Title__c =  details.Title__c;
                                an.Message__c = message;
                                an.Notification_Type__c = details.Notification_Type__c;
                                an.Record_Id__c = dem.Id;
                                an.Device_Token__c = token;
                                notifications.add(an);
                            }else if(Date.Today() > dem.Due_Date__c){
                                Date today = Date.today();
                                Integer daysPassed = dem.Due_Date__c.daysBetween(today);
                                if (daysPassed > 0 && Math.mod(daysPassed, 7) == 0) {
                                    App_Notification__c an = new App_Notification__c();
                                    an.Booking__c = dem.Booking__c;
                                    an.Title__c = details.Title__c;
                                    an.Message__c = message;
                                    an.Notification_Type__c = details.Notification_Type__c;
                                    an.Record_Id__c = dem.Id;
                                    an.Device_Token__c = token;
                                    notifications.add(an);
                                }
                            }
                        }
                    }
                }
                //SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(dem.Booking__r.Opportunity__c,dem.Booking__r.Primary_Applicant_Name__c, dem.Booking__r.Unit_No__r.Name, amount, null, null, null, null, null, dem.Booking__r.RW_Country_Phone_Code__c, dem.Booking__r.Opportunity__r.RW_Mobile_No__c, 'Payment Due Alert WhatsApp');     
                if(details.Whatsapp_Template_Name__c != null){
                    LockatedApp_WhatsappMsgQueueable.ParameterWrap wrap = LockatedApp_WhatsappMsgQueueable.wrapper(dem.Booking__r.Opportunity__c,dem.Booking__r.Primary_Applicant_Name__c, dem.Booking__r.Unit_No__r.Name, amount,null,null,null,null,null,dem.Booking__r.RW_Country_Phone_Code__c,dem.Booking__r.Primary_Applicant_Mobile__c,details.Whatsapp_Template_Name__c); 
                    wrapList.add(wrap);
                }
                //System.enqueueJob(new LockatedApp_WhatsappMsgQueueable(wrap));
                if(dem.Booking__r.Primary_Applicant_Email__c != null && details.Email_Message__c != null){
                    String subject = DynamicEmailService.generateEmailBody(dem.Id, 'Clear_current_outstanding_dues', 'Subject');
                    String body = DynamicEmailService.generateEmailBody(dem.Id, 'Clear_current_outstanding_dues', 'Body');
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new List<String>{dem.Booking__r.Primary_Applicant_Email__c});
                    mail.setSubject(subject);
                    mail.setPlainTextBody(body);
                    emailList.add(mail);
                }
            }
            System.debug('notifications: ' + notifications);
            if(notifications.size() > 0){
                //insert notifications;
            }
            if(emailList.size() > 0){
                Messaging.SendEmailResult[] result = Messaging.sendEmail(emailList);
            }
        }
        
    }
    
    public void newsLetterNotification(){

        List<Post_Sales_App_Notifications__mdt> ntfDetails = [SELECT Title__c,Message__c,Notification_Type__c,Email_Subject__c,Email_Message__c,Whatsapp_Template_Name__c,Active__c FROM Post_Sales_App_Notifications__mdt WHERE DeveloperName = 'Newsletter' AND Active__c = true LIMIT 1];
        if(ntfDetails.size() > 0){
            Post_Sales_App_Notifications__mdt details = ntfDetails[0];
            List<Opportunity> opportunities = [SELECT Id,RW_Email__c,Booking__c,Booking__r.Lockated_User_Device_ID__c,Booking__r.RW_Country_Phone_Code__c,RW_Mobile_No__c,Booking__r.Primary_Applicant_Mobile__c FROM Opportunity WHERE News_Letter_Date__c = TODAY];
            if(opportunities.size() > 0){
                List<App_Notification__c> notifications = new List<App_Notification__c>();
                List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
                
                for(Opportunity opp : opportunities){
                    if(opp.Booking__c != null && opp.Booking__r.Lockated_User_Device_ID__c != null && details.Message__c != null){
                        Set<String> deviceTokens = new Set<String>(opp.Booking__r.Lockated_User_Device_ID__c.split(';'));
                        for(String token : deviceTokens){
                            App_Notification__c an = new App_Notification__c();
                            an.Booking__c = opp.Booking__c;
                            an.Title__c = details.Title__c;
                            an.Message__c = details.Message__c;
                            an.Notification_Type__c = details.Notification_Type__c;
                            an.Device_Token__c = token;
                            notifications.add(an);
                        }
                    }
                    //SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(null,null,null,null,null,null,null,null,null,opp.Booking__r.RW_Country_Phone_Code__c,opp.RW_Mobile_No__c,'Newsletter'); 
                    if(details.Whatsapp_Template_Name__c != null){
                        LockatedApp_WhatsappMsgQueueable.ParameterWrap wrap = LockatedApp_WhatsappMsgQueueable.wrapper(null,null,null,null,null,null,null,null,null,opp.Booking__r.RW_Country_Phone_Code__c,opp.Booking__r.Primary_Applicant_Mobile__c,details.Whatsapp_Template_Name__c); 
                        wrapList.add(wrap);
                    }
                    //System.enqueueJob(new LockatedApp_WhatsappMsgQueueable(wrap));
                    if(opp.RW_Email__c != null && details.Email_Message__c != null){
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(new List<String>{opp.RW_Email__c});
                        mail.setSubject(details.Email_Subject__c);
                        mail.setPlainTextBody(details.Email_Message__c);
                        emailList.add(mail);
                    }
                }
                if(notifications.size() > 0){
                    //insert notifications;
                }
                if(emailList.size() > 0){
                    Messaging.SendEmailResult[] result = Messaging.sendEmail(emailList);
                }
            }
        }
    }
    
    public void birthdayNotification(){

        List<Post_Sales_App_Notifications__mdt> ntfDetails = [SELECT Title__c,Message__c,Notification_Type__c,Email_Subject__c,Email_Message__c,Whatsapp_Template_Name__c,Active__c FROM Post_Sales_App_Notifications__mdt WHERE DeveloperName = 'Birthday_Wishes' AND Active__c = true LIMIT 1];
        if(ntfDetails.size() > 0){
            Post_Sales_App_Notifications__mdt details = ntfDetails[0];
            Date today = System.today();
            List<Applicant_Details__c> applicants = [SELECT Id,Booking__c,Booking__r.Lockated_User_Device_ID__c,Booking__r.Primary_Applicant_Name__c,Booking__r.RW_Country_Phone_Code__c,Mobile_Number__c FROM Applicant_Details__c WHERE Opportunity__r.StageName = 'Unit Booked' 
                                                    AND DAY_IN_MONTH(DOB__c) =: today.DAY() AND CALENDAR_MONTH(DOB__c) =: today.MONTH()];
            List<App_Notification__c> notifications = new List<App_Notification__c>();
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            for(Applicant_Details__c app : applicants){
                if(app.Booking__c != null && app.Booking__r.Lockated_User_Device_ID__c != null && details.Message__c != null){
                    Set<String> deviceTokens = new Set<String>(app.Booking__r.Lockated_User_Device_ID__c.split(';'));
                    String message = ((details.Message__c.contains('{1}'))? details.Message__c.replace('{1}', (app.Booking__r.Primary_Applicant_Name__c != null)? app.Booking__r.Primary_Applicant_Name__c : 'Customer') : details.Message__c);
                    for(String token : deviceTokens){
                        App_Notification__c an = new App_Notification__c();
                        an.Booking__c = app.Booking__c;
                        an.Title__c = details.Title__c ;
                        an.Message__c = message;
                        an.Notification_Type__c = details.Notification_Type__c;
                        an.Device_Token__c = token;
                        notifications.add(an);
                    }
                }
                if(details.Whatsapp_Template_Name__c != null){
                    LockatedApp_WhatsappMsgQueueable.ParameterWrap wrap = LockatedApp_WhatsappMsgQueueable.wrapper(null,app.Booking__r.Primary_Applicant_Name__c,null,null,null,null,null,System.label.Birthday_Wish_Image_Link,'Birthday Wish',app.Booking__r.RW_Country_Phone_Code__c,app.Mobile_Number__c,details.Whatsapp_Template_Name__c); 
                    wrapList.add(wrap);
                }
                if(app.Email_Address__c != null && details.Email_Message__c != null){
                    String body = DynamicEmailService.generateEmailBody(app.Id, 'Birthday_Wishes', 'Body');
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new List<String>{app.Email_Address__c});
                    mail.setSubject(details.Email_Subject__c);
                    mail.setPlainTextBody(body);
                    emailList.add(mail);
                }
            }
            if(notifications.size() > 0){
                //insert notifications;
            }
            if(emailList.size() > 0){
                Messaging.SendEmailResult[] result = Messaging.sendEmail(emailList);
            }
        }
    }
    
    /*public void timeboundMilestoneNotification(){
        List<Booking__c> bkgs = [SELECT Id,Quotation__c,Lockated_User_Device_ID__c FROM Booking__c WHERE RW_Total_Demand_Raised__c = 0 AND Status__c = 'Booking Confirmed'];
        Set<Id> quoteIds = new Set<Id>();
        List<App_Notification__c> notifications = new List<App_Notification__c>();
        Map<String, Booking__c> quoteIdVsBooking = new Map<String, Booking__c>();
        for(Booking__c bkg : bkgs){
            quoteIds.add(bkg.Quotation__c);
            quoteIdVsBooking.put(bkg.Quotation__c, bkg);
        }
        if(quoteIds.size() > 0){
            List<Customer_Pay_Plan_Header__c> cpphList = [SELECT Id,Quotation__c FROM Customer_Pay_Plan_Header__c WHERE Quotation__c =: quoteIds AND Global_Charge_Name__c = 'Basic'];
            List<Id> cpphIds = new List<Id>();
            Map<String, String> cpphIdVsQuoteId = new Map<String, String>();
            for(Customer_Pay_Plan_Header__c cpph : cpphList){
                cpphIds.add(cpph.Id);
                cpphIdVsQuoteId.put(cpph.Id, cpph.Quotation__c);
            }
            
            List<Standard_Customer_Pay_Plan_Detail__c> scppdList = [SELECT Id,Customer_Pay_Plan_Header__c,Due_Date__c FROM Standard_Customer_Pay_Plan_Detail__c WHERE Customer_Pay_Plan_Header__c =: cpphIds AND Project_Construction_Stages__c = null];
            Map<String, List<Standard_Customer_Pay_Plan_Detail__c>> cpphIdVsScppdList = new Map<String, List<Standard_Customer_Pay_Plan_Detail__c>>();
            Date dt = Date.today();
            List<String> tenDaysPrior = new List<String>();
            List<String> sevenDaysPrior = new List<String>();
            List<String> fiveDaysPrior = new List<String>();
            List<String> onDueDate = new List<String>();
            for(Standard_Customer_Pay_Plan_Detail__c scppd: scppdList){
                if(cpphIdVsScppdList.get(scppd.Customer_Pay_Plan_Header__c) != null){
                    cpphIdVsScppdList.get(scppd.Customer_Pay_Plan_Header__c).add(scppd);
                }else{
                    cpphIdVsScppdList.put(scppd.Customer_Pay_Plan_Header__c, new List<Standard_Customer_Pay_Plan_Detail__c>{scppd});
                }
                if(scppd.Due_Date__c == (dt - 10)){
                    tenDaysPrior.add(scppd.Customer_Pay_Plan_Header__c);
                }else if(scppd.Due_Date__c == (dt - 7)){
                    sevenDaysPrior.add(scppd.Customer_Pay_Plan_Header__c);
                }else if(scppd.Due_Date__c == (dt - 5)){
                    fiveDaysPrior.add(scppd.Customer_Pay_Plan_Header__c);
                }else if(scppd.Due_Date__c == dt){
                    onDueDate.add(scppd.Customer_Pay_Plan_Header__c);
                }
            }
            
            if(tenDaysPrior.size() > 0){
                for(String cpph : tenDaysPrior){
                    Booking__c bkg = quoteIdVsBooking.get(cpphIdVsQuoteId.get(cpph));
                    if(bkg.Lockated_User_Device_ID__c != null){
                        //List<String> deviceTokens = bkg.Lockated_User_Device_ID__c.split(';');
                        Set<String> deviceTokens = new Set<String>(bkg.Lockated_User_Device_ID__c.split(';'));
                        for(String token : deviceTokens){
                            App_Notification__c an = new App_Notification__c();
                            an.Booking__c = bkg.Id;
                            an.Title__c = 'TIMEBOUND MILESTONES';
                            an.Message__c = 'Timebound milestone 10 days prior';
                            an.Notification_Type__c = 'payments_due';
                            an.Device_Token__c = token;
                            notifications.add(an);
                        }
                    }
                }
            }
            if(sevenDaysPrior.size() > 0){
                for(String cpph : sevenDaysPrior){
                    Booking__c bkg = quoteIdVsBooking.get(cpphIdVsQuoteId.get(cpph));
                    if(bkg.Lockated_User_Device_ID__c != null){
                        //List<String> deviceTokens = bkg.Lockated_User_Device_ID__c.split(';');
                        Set<String> deviceTokens = new Set<String>(bkg.Lockated_User_Device_ID__c.split(';'));
                        for(String token : deviceTokens){
                            App_Notification__c an = new App_Notification__c();
                            an.Booking__c = bkg.Id;
                            an.Title__c = 'TIMEBOUND MILESTONES';
                            an.Message__c = 'Timebound milestone 7 days prior';
                            an.Notification_Type__c = 'payments_due';
                            an.Device_Token__c = token;
                            notifications.add(an);
                        }
                    }
                }
            }
            if(fiveDaysPrior.size() > 0){
                for(String cpph : fiveDaysPrior){
                    Booking__c bkg = quoteIdVsBooking.get(cpphIdVsQuoteId.get(cpph));
                    if(bkg.Lockated_User_Device_ID__c != null){
                        //List<String> deviceTokens = bkg.Lockated_User_Device_ID__c.split(';');
                        Set<String> deviceTokens = new Set<String>(bkg.Lockated_User_Device_ID__c.split(';'));
                        for(String token : deviceTokens){
                            App_Notification__c an = new App_Notification__c();
                            an.Booking__c = bkg.Id;
                            an.Title__c = 'TIMEBOUND MILESTONES';
                            an.Message__c = 'Timebound milestone 5 days prior';
                            an.Notification_Type__c = 'payments_due';
                            an.Device_Token__c = token;
                            notifications.add(an);
                        }
                    }
                }
            }
            if(onDueDate.size() > 0){
                for(String cpph : onDueDate){
                    Booking__c bkg = quoteIdVsBooking.get(cpphIdVsQuoteId.get(cpph));
                    if(bkg.Lockated_User_Device_ID__c != null){
                        List<String> deviceTokens = bkg.Lockated_User_Device_ID__c.split(';');
                        for(String token : deviceTokens){
                            App_Notification__c an = new App_Notification__c();
                            an.Booking__c = bkg.Id;
                            an.Title__c = 'TIMEBOUND MILESTONES';
                            an.Message__c = 'Timebound milestone on due date';
                            an.Notification_Type__c = 'payments_due';
                            an.Device_Token__c = token;
                            notifications.add(an);
                        }
                    }
                }
            }
            
            if(notifications.size() > 0){
                //insert notifications;
            }
        }
    }*/
    
    /*public void paymentReminderNotification(){
        List<RW_Demand__c> demands = [SELECT Id,Due_Date__c,Booking__c,Booking__r.Lockated_User_Device_ID__c,Booking__r.Primary_Applicant_Name__c,Remaining_Amount__c FROM RW_Demand__c WHERE RW_Demand_Status__c = 'Due'];
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        for(RW_Demand__c dem : demands){
            String emailBody = 'Dear ' + dem.Booking__r.Primary_Applicant_Name__c + ', <br/><br/>';
            String subject;
            if(dem.Booking__c != null && dem.Booking__r.Lockated_User_Device_ID__c != null){
                List<String> deviceTokens = dem.Booking__r.Lockated_User_Device_ID__c.split(';');
                //String beforeDueMessage = 'Dear ' + dem.Booking__r.Primary_Applicant_Name__c + ',\n This is a gentle reminder that ₹[Amount] is due in 10 days on [Due Date]. Please ensure timely payment to avoid interest. Ignore if already paid.';
                //String afterDueMessage = 'Dear ' + dem.Booking__r.Primary_Applicant_Name__c + ',\n Our records show payment of ₹[Outstanding Amount] due on [Due Date] is unpaid. Additional interest charges apply. Please clear the dues promptly. Ignore if already paid.';
                for(String token : deviceTokens){
                    if(Date.Today() == (dem.Due_Date__c - 10)){
                        App_Notification__c an = new App_Notification__c();
                        an.Booking__c = dem.Booking__c;
                        an.Title__c = 'Payment Reminder Before Due Date ';
                        an.Message__c = 'Dear ' + dem.Booking__r.Primary_Applicant_Name__c + ',\n This is a gentle reminder that ₹ ' + dem.Remaining_Amount__c + ' is due in 10 days on ' + dem.Due_Date__c + '. Please ensure timely payment to avoid interest. Ignore if already paid.';
                        an.Notification_Type__c = 'payment_dues';
                        an.Record_Id__c = dem.Id;
                        an.Device_Token__c = token;
                        notifications.add(an);
                        SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(null,dem.Booking__r.Primary_Applicant_Name__c,String.valueOf(dem.Remaining_Amount__c),'10',String.valueOf(dem.Due_Date__c),null,null,null,null,dem.Booking__r.RW_Country_Phone_Code__c,dem.Booking__r.Opportunity__r.RW_Mobile_No__c,'Payment Reminder Before Due Date'); 
                        subject = '10 days prior to due date';
                        emailBody += 'This is a gentle reminder that your payment of ₹' + dem.Remaining_Amount__c + ' for your property is due in 10 days, on ' + dem.Due_Date__c + '. Kindly ensure timely payment to avoid any interest being charged on the outstanding amount.<br/>'; 
                        emailBody += 'To ignore the demand incase if it’s already paid.<br/>';
                        emailBody += 'Thank you for your attention.<br/><br/>';
                    }else if(Date.Today() == (dem.Due_Date__c - 7)){
                        App_Notification__c an = new App_Notification__c();
                        an.Booking__c = dem.Booking__c;
                        an.Title__c = 'Payment Reminder Before Due Date ';
                        an.Message__c = 'Dear ' + dem.Booking__r.Primary_Applicant_Name__c + ',\n This is a gentle reminder that ₹ ' + dem.Remaining_Amount__c + ' is due in 7 days on ' + dem.Due_Date__c + '. Please ensure timely payment to avoid interest. Ignore if already paid.';
                        an.Notification_Type__c = 'payment_dues';
                        an.Record_Id__c = dem.Id;
                        an.Device_Token__c = token;
                        notifications.add(an);
                        SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(null,dem.Booking__r.Primary_Applicant_Name__c,String.valueOf(dem.Remaining_Amount__c),'7',String.valueOf(dem.Due_Date__c),null,null,null,null,dem.Booking__r.RW_Country_Phone_Code__c,dem.Booking__r.Opportunity__r.RW_Mobile_No__c,'Payment Reminder Before Due Date'); 
                        subject = '7 days prior to due date';
                        emailBody += 'Your payment of ₹' + dem.Remaining_Amount__c + ' remains due and is 7 days away from the due date, ' + dem.Due_Date__c + '. We encourage you to make the payment within the due date to avoid interest charges. <br/>'; 
                        emailBody += 'To ignore the demand incase if it’s already paid. <br/>';
                        emailBody += 'We appreciate your promptness.<br/><br/>';
                    }else if(Date.Today() == (dem.Due_Date__c - 5)){
                        App_Notification__c an = new App_Notification__c();
                        an.Booking__c = dem.Booking__c;
                        an.Title__c = 'Payment Reminder Before Due Date ';
                        an.Message__c = 'Dear ' + dem.Booking__r.Primary_Applicant_Name__c + ',\n This is a gentle reminder that ₹ ' + dem.Remaining_Amount__c + ' is due in 5 days on ' + dem.Due_Date__c + '. Please ensure timely payment to avoid interest. Ignore if already paid.';
                        an.Notification_Type__c = 'payment_dues';
                        an.Record_Id__c = dem.Id;
                        an.Device_Token__c = token;
                        notifications.add(an);
                        SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(null,dem.Booking__r.Primary_Applicant_Name__c,String.valueOf(dem.Remaining_Amount__c),'5',String.valueOf(dem.Due_Date__c),null,null,null,null,dem.Booking__r.RW_Country_Phone_Code__c,dem.Booking__r.Opportunity__r.RW_Mobile_No__c,'Payment Reminder Before Due Date'); 
                        subject = '5 days prior to due date';
                        emailBody += 'This is a kind reminder that your payment of ₹' + dem.Remaining_Amount__c + ' is due in 5 days, on' + dem.Due_Date__c + '. Please ensure the due amount is cleared on or before the due date to prevent any interest being applied. <br/>'; 
                        emailBody += 'To ignore the demand incase if it’s already paid. <br/>';
                        emailBody += 'Thank you.<br/><br/>';
                    }else if(Date.Today() == dem.Due_Date__c){
                        App_Notification__c an = new App_Notification__c();
                        an.Booking__c = dem.Booking__c;
                        an.Title__c = 'Payment Reminder Before Due Date ';
                        an.Message__c = 'Dear ' + dem.Booking__r.Primary_Applicant_Name__c + ',\n This is a gentle reminder that ₹ ' + dem.Remaining_Amount__c + ' is due in 0 days on ' + dem.Due_Date__c + '. Please ensure timely payment to avoid interest. Ignore if already paid.';
                        an.Notification_Type__c = 'payment_dues';
                        an.Record_Id__c = dem.Id;
                        an.Device_Token__c = token;
                        notifications.add(an);
                        SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(null,dem.Booking__r.Primary_Applicant_Name__c,String.valueOf(dem.Remaining_Amount__c),'0',String.valueOf(dem.Due_Date__c),null,null,null,null,dem.Booking__r.RW_Country_Phone_Code__c,dem.Booking__r.Opportunity__r.RW_Mobile_No__c,'Payment Reminder Before Due Date'); 
                        subject = 'On the final day';
                        emailBody += 'Today is the due date, ' + dem.Due_Date__c + ' for your payment of ' + dem.Remaining_Amount__c + '.Please arrange to make the payment today to avoid interest on the overdue amount. <br/>'; 
                        emailBody += 'To ignore the demand incase if it’s already paid.<br/>';
                        emailBody += 'We appreciate your cooperation.<br/><br/>';
                    }else if(Date.Today() > dem.Due_Date__c){
                        String dayName = DateTime.now().format('EEEE');
                        if(dayName == 'Wednesday' || dayName == 'Saturday'){
                            App_Notification__c an = new App_Notification__c();
                            an.Booking__c = dem.Booking__c;
                            an.Title__c = 'Additional Charges Reminder (Overdue Payment)';
                            an.Message__c = 'Dear ' + dem.Booking__r.Primary_Applicant_Name__c + ',\n Our records show payment of ₹' + dem.Remaining_Amount__c + ' due on ' + dem.Due_Date__c + ' is unpaid. Additional interest charges apply. Please clear the dues promptly. Ignore if already paid.';
                            an.Notification_Type__c = 'payment_dues';
                            an.Record_Id__c = dem.Id;
                            an.Device_Token__c = token;
                            notifications.add(an);
                            SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(null,dem.Booking__r.Primary_Applicant_Name__c,String.valueOf(dem.Remaining_Amount__c),String.valueOf(dem.Due_Date__c),null,null,null,null,null,dem.Booking__r.RW_Country_Phone_Code__c,dem.Booking__r.Opportunity__r.RW_Mobile_No__c,'Additional Charges Reminder'); 
                            if(dayName == 'Wednesday'){
                                subject = 'Additional Charges & Pending Dues';
                                emailBody += 'Greetings from Runwal Enterprises !!!';
                                emailBody += 'Our records indicate that the payment of ' + dem.Remaining_Amount__c + ' due on ' + dem.Due_Date__c + 'is yet to be received. Please note that as the payment is overdue, additional interest charges have now been applied as per the terms. <br/>'; 
                                emailBody += 'Kindly settle the outstanding amount at the earliest to avoid further charges.<br/>';
                                emailBody += 'To ignore the demand incase if it’s already paid.<br/>';
                                emailBody += 'Thank you.<br/><br/>';
                            }else if(dayName == 'Saturday'){
                                subject = 'Additional Charges & Pending Dues';
                                emailBody += 'Greetings from Runwal Enterprises !!!';
                                emailBody += 'This is a friendly reminder that your pending payment of ' + dem.Remaining_Amount__c + ' originally due on ' + dem.Due_Date__c + 'remains unpaid. Please be informed that additional interest charges have accrued on the overdue amount. <br/>'; 
                                emailBody += 'We request you to clear the pending dues promptly to avoid further penalties. <br/>';
                                emailBody += 'To ignore the demand incase if it’s already paid.<br/>';
                                emailBody += 'We appreciate your prompt attention.<br/><br/>';
                            }
                            
                        }
                    }
                    if(dem.Booking__r.Primary_Applicant_Email__c != null){
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(new List<String>{dem.Booking__r.Primary_Applicant_Email__c});
                        mail.setSubject(subject);
                        mail.setHtmlBody(emailBody);
                        emailList.add(mail);
                    }
                }
                if(emailList.size() > 0){
                    Messaging.SendEmailResult[] result = Messaging.sendEmail(emailList);
                }
            }
        }
    }*/
    
    public void paymentReminderNotification(){
        List<Post_Sales_App_Notifications__mdt> ntfDetails = [SELECT DeveloperName,Title__c,Message__c,Notification_Type__c,Email_Subject__c,Email_Message__c,Whatsapp_Template_Name__c,Active__c FROM Post_Sales_App_Notifications__mdt WHERE Active__c = true AND DeveloperName IN ('Payment_Reminder_Before_Due_Date','Payment_Reminder_On_Due_Date','Additional_Charges_Reminder')];
        
        if(ntfDetails.size() > 0){
            Map<String, Post_Sales_App_Notifications__mdt> ntfDetailsMap = new Map<String, Post_Sales_App_Notifications__mdt>();
            Post_Sales_App_Notifications__mdt detailsBeforeDueDate;
            Post_Sales_App_Notifications__mdt detailsOnDueDate;
            Post_Sales_App_Notifications__mdt detailsAdditionalCharges;
            for(Post_Sales_App_Notifications__mdt det : ntfDetails){
                if(det.DeveloperName == 'Payment_Reminder_Before_Due_Date'){
                    detailsBeforeDueDate = det;
                }else if(det.DeveloperName == 'Payment_Reminder_On_Due_Date'){
                    detailsOnDueDate = det;
                }else if(det.DeveloperName == 'Additional_Charges_Reminder'){
                    detailsAdditionalCharges = det;
                }
            }
            List<RW_Demand__c> demands = [SELECT Id,Due_Date__c,Booking__c,Booking__r.Lockated_User_Device_ID__c,Booking__r.Primary_Applicant_Name__c,Remaining_Amount__c,Booking__r.Primary_Applicant_Mobile__c,Booking__r.RW_Country_Phone_Code__c,Booking__r.Primary_Applicant_Email__c FROM RW_Demand__c WHERE RW_Demand_Status__c = 'Due'];
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            List<App_Notification__c> notifications = new List<App_Notification__c>();
            
            for(RW_Demand__c dem : demands){
                String emailBody;
                String subject;
                if(Date.Today() == (dem.Due_Date__c - 10)){
                    //SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(null,dem.Booking__r.Primary_Applicant_Name__c,String.valueOf(dem.Remaining_Amount__c),'10',String.valueOf(dem.Due_Date__c),null,null,null,null,dem.Booking__r.RW_Country_Phone_Code__c,dem.Booking__r.Opportunity__r.RW_Mobile_No__c,'Payment Reminder Before Due Date'); 
                    if(detailsBeforeDueDate != null && detailsBeforeDueDate.Whatsapp_Template_Name__c != null){
                        LockatedApp_WhatsappMsgQueueable.ParameterWrap wrap = LockatedApp_WhatsappMsgQueueable.wrapper(null,dem.Booking__r.Primary_Applicant_Name__c,String.valueOf(dem.Remaining_Amount__c),'10',String.valueOf(dem.Due_Date__c),null,null,null,null,dem.Booking__r.RW_Country_Phone_Code__c,dem.Booking__r.Primary_Applicant_Mobile__c,detailsBeforeDueDate.Whatsapp_Template_Name__c); 
                        wrapList.add(wrap);
                    }
                    //System.enqueueJob(new LockatedApp_WhatsappMsgQueueable(wrap));
                    if(detailsBeforeDueDate != null && detailsBeforeDueDate.Email_Message__c != null){
						emailBody = DynamicEmailService.generateEmailBody(dem.Id, 'Payment_Reminder_Before_Due_Date', 'Body');
                        if(emailBody.contains('{days}')){
                            emailBody = emailBody.replace('{days}', '10');
                        }
                    }
                    if(dem.Booking__c != null && dem.Booking__r.Lockated_User_Device_ID__c != null && detailsBeforeDueDate != null && detailsBeforeDueDate.Message__c != null){
                        Set<String> deviceTokens = new Set<String>(dem.Booking__r.Lockated_User_Device_ID__c.split(';'));
                        String message = (detailsBeforeDueDate != null && detailsBeforeDueDate.Message__c != null)? detailsBeforeDueDate.Message__c.replace('{1}', (dem.Booking__r.Primary_Applicant_Name__c != null)? dem.Booking__r.Primary_Applicant_Name__c : 'Customer') : '';
                        message = (message != '')? message.replace('{2}', String.valueOf(dem.Remaining_Amount__c)) : '';
                        message = (message != '')? message.replace('{3}', '10') : '';
                        message = (message != '')? message.replace('{4}', String.valueOf(dem.Due_Date__c)) : '';
                        
                        for(String token : deviceTokens){
                            App_Notification__c an = new App_Notification__c();
                            an.Booking__c = dem.Booking__c;
                            an.Title__c = detailsBeforeDueDate.Title__c;
                            an.Message__c = message;
                            an.Notification_Type__c = detailsBeforeDueDate.Notification_Type__c;
                            an.Record_Id__c = dem.Id;
                            an.Device_Token__c = token;
                            notifications.add(an);
                        }
                    }
                }else if(Date.Today() == (dem.Due_Date__c - 7)){
                    //SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(null,dem.Booking__r.Primary_Applicant_Name__c,String.valueOf(dem.Remaining_Amount__c),'7',String.valueOf(dem.Due_Date__c),null,null,null,null,dem.Booking__r.RW_Country_Phone_Code__c,dem.Booking__r.Opportunity__r.RW_Mobile_No__c,'Payment Reminder Before Due Date'); 
                    LockatedApp_WhatsappMsgQueueable.ParameterWrap wrap = LockatedApp_WhatsappMsgQueueable.wrapper(null,dem.Booking__r.Primary_Applicant_Name__c,String.valueOf(dem.Remaining_Amount__c),'7',String.valueOf(dem.Due_Date__c),null,null,null,null,dem.Booking__r.RW_Country_Phone_Code__c,dem.Booking__r.Primary_Applicant_Mobile__c,detailsBeforeDueDate.Whatsapp_Template_Name__c); 
                    wrapList.add(wrap);
                    //System.enqueueJob(new LockatedApp_WhatsappMsgQueueable(wrap));
                    emailBody = DynamicEmailService.generateEmailBody(dem.Id, 'Payment_Reminder_Before_Due_Date', 'Body');
                    if(emailBody.contains('{days}')){
                        emailBody = emailBody.replace('{days}', '7');
                    }
                    if(dem.Booking__c != null && dem.Booking__r.Lockated_User_Device_ID__c != null){
                        Set<String> deviceTokens = new Set<String>(dem.Booking__r.Lockated_User_Device_ID__c.split(';'));
                        String message = (detailsBeforeDueDate != null && detailsBeforeDueDate.Message__c != null)? detailsBeforeDueDate.Message__c.replace('{1}', (dem.Booking__r.Primary_Applicant_Name__c != null)? dem.Booking__r.Primary_Applicant_Name__c : 'Customer') : '';
                        message = (message != '')? message.replace('{2}', String.valueOf(dem.Remaining_Amount__c)) : '';
                        message = (message != '')? message.replace('{3}', '7') : '';
                        message = (message != '')? message.replace('{4}', String.valueOf(dem.Due_Date__c)) : '';
                        for(String token : deviceTokens){
                            App_Notification__c an = new App_Notification__c();
                            an.Booking__c = dem.Booking__c;
                            an.Title__c = (detailsBeforeDueDate != null)? detailsBeforeDueDate.Title__c : '';
                            an.Message__c = message;
                            an.Notification_Type__c = (detailsBeforeDueDate != null)? detailsBeforeDueDate.Notification_Type__c : '';
                            an.Record_Id__c = dem.Id;
                            an.Device_Token__c = token;
                            notifications.add(an);
                        }
                    }
                }else if(Date.Today() == (dem.Due_Date__c - 5)){
                    //SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(null,dem.Booking__r.Primary_Applicant_Name__c,String.valueOf(dem.Remaining_Amount__c),'5',String.valueOf(dem.Due_Date__c),null,null,null,null,dem.Booking__r.RW_Country_Phone_Code__c,dem.Booking__r.Opportunity__r.RW_Mobile_No__c,'Payment Reminder Before Due Date'); 
                    LockatedApp_WhatsappMsgQueueable.ParameterWrap wrap = LockatedApp_WhatsappMsgQueueable.wrapper(null,dem.Booking__r.Primary_Applicant_Name__c,String.valueOf(dem.Remaining_Amount__c),'5',String.valueOf(dem.Due_Date__c),null,null,null,null,dem.Booking__r.RW_Country_Phone_Code__c,dem.Booking__r.Primary_Applicant_Mobile__c,detailsBeforeDueDate.Whatsapp_Template_Name__c); 
                    wrapList.add(wrap);
                    emailBody = DynamicEmailService.generateEmailBody(dem.Id, 'Payment_Reminder_Before_Due_Date', 'Body');
                    if(emailBody.contains('{days}')){
                        emailBody = emailBody.replace('{days}', '5');
                    }
                    if(dem.Booking__c != null && dem.Booking__r.Lockated_User_Device_ID__c != null){
                        Set<String> deviceTokens = new Set<String>(dem.Booking__r.Lockated_User_Device_ID__c.split(';'));
                        String message = (detailsBeforeDueDate != null && detailsBeforeDueDate.Message__c != null)? detailsBeforeDueDate.Message__c.replace('{1}', (dem.Booking__r.Primary_Applicant_Name__c != null)? dem.Booking__r.Primary_Applicant_Name__c : 'Customer') : '';
                        message = (message != '')? message.replace('{2}', String.valueOf(dem.Remaining_Amount__c)) : '';
                        message = (message != '')? message.replace('{3}', '5') : '';
                        message = (message != '')? message.replace('{4}', String.valueOf(dem.Due_Date__c)) : '';
                        for(String token : deviceTokens){
                            App_Notification__c an = new App_Notification__c();
                            an.Booking__c = dem.Booking__c;
                            an.Title__c = (detailsBeforeDueDate != null)? detailsBeforeDueDate.Title__c : '';
                            an.Message__c = message;
                            an.Notification_Type__c = (detailsBeforeDueDate != null)? detailsBeforeDueDate.Notification_Type__c : '';
                            an.Record_Id__c = dem.Id;
                            an.Device_Token__c = token;
                            notifications.add(an);
                        }
                    }
                }else if(Date.Today() == dem.Due_Date__c){
                    //SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(null,dem.Booking__r.Primary_Applicant_Name__c,String.valueOf(dem.Remaining_Amount__c),'0',String.valueOf(dem.Due_Date__c),null,null,null,null,dem.Booking__r.RW_Country_Phone_Code__c,dem.Booking__r.Opportunity__r.RW_Mobile_No__c,'Payment Reminder Before Due Date'); 
                    LockatedApp_WhatsappMsgQueueable.ParameterWrap wrap = LockatedApp_WhatsappMsgQueueable.wrapper(null,dem.Booking__r.Primary_Applicant_Name__c,String.valueOf(dem.Remaining_Amount__c),'0',String.valueOf(dem.Due_Date__c),null,null,null,null,dem.Booking__r.RW_Country_Phone_Code__c,dem.Booking__r.Primary_Applicant_Mobile__c,detailsOnDueDate.Whatsapp_Template_Name__c); 
                    wrapList.add(wrap);
                    //System.enqueueJob(new LockatedApp_WhatsappMsgQueueable(wrap));
                    subject = DynamicEmailService.generateEmailBody(dem.Id, 'Payment_Reminder_On_Due_Date', 'Subject');
                    emailBody = DynamicEmailService.generateEmailBody(dem.Id, 'Payment_Reminder_On_Due_Date', 'Body');
                    if(dem.Booking__c != null && dem.Booking__r.Lockated_User_Device_ID__c != null){
                        Set<String> deviceTokens = new Set<String>(dem.Booking__r.Lockated_User_Device_ID__c.split(';'));
                        String message = (detailsOnDueDate != null && detailsOnDueDate.Message__c != null)? detailsOnDueDate.Message__c.replace('{1}', (dem.Booking__r.Primary_Applicant_Name__c != null)? dem.Booking__r.Primary_Applicant_Name__c : 'Customer') : '';
                        message = (message != '')? message.replace('{2}', String.valueOf(dem.Remaining_Amount__c)) : '';
                        message = (message != '')? message.replace('{3}', String.valueOf(dem.Due_Date__c)) : '';
                        for(String token : deviceTokens){
                            App_Notification__c an = new App_Notification__c();
                            an.Booking__c = dem.Booking__c;
                            an.Title__c = (detailsOnDueDate != null)? detailsOnDueDate.Title__c : '';
                            an.Message__c = message.replace('{3}', '5');
                            an.Notification_Type__c = (detailsOnDueDate != null)? detailsOnDueDate.Notification_Type__c : '';
                            an.Record_Id__c = dem.Id;
                            an.Device_Token__c = token;
                            notifications.add(an);
                        }
                    }
                }else if(Date.Today() > dem.Due_Date__c){
                    //SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(null,dem.Booking__r.Primary_Applicant_Name__c,String.valueOf(dem.Remaining_Amount__c),String.valueOf(dem.Due_Date__c),null,null,null,null,null,dem.Booking__r.RW_Country_Phone_Code__c,dem.Booking__r.Opportunity__r.RW_Mobile_No__c,'Additional Charges Reminder'); 
                    LockatedApp_WhatsappMsgQueueable.ParameterWrap wrap = LockatedApp_WhatsappMsgQueueable.wrapper(null,dem.Booking__r.Primary_Applicant_Name__c,String.valueOf(dem.Remaining_Amount__c),String.valueOf(dem.Due_Date__c),null,null,null,null,null,dem.Booking__r.RW_Country_Phone_Code__c,dem.Booking__r.Primary_Applicant_Mobile__c,detailsAdditionalCharges.Whatsapp_Template_Name__c); 
                    wrapList.add(wrap);
                    String dayName = DateTime.now().format('EEEE');
                    if(dayName == 'Wednesday' || dayName == 'Saturday'){
                        subject = (detailsAdditionalCharges != null && detailsAdditionalCharges.Message__c != null)? detailsAdditionalCharges.Message__c : '';
                        emailBody = (detailsAdditionalCharges != null && detailsAdditionalCharges.Email_Message__c != null)? detailsAdditionalCharges.Email_Message__c.replace('{1}', (dem.Booking__r.Primary_Applicant_Name__c != null)? dem.Booking__r.Primary_Applicant_Name__c : 'Customer') : '';
                        emailBody = (emailBody != '')? emailBody.replace('{2}', String.valueOf(dem.Remaining_Amount__c)) : '';
                        emailBody = (emailBody != '')? emailBody.replace('{3}', String.valueOf(dem.Due_Date__c)) : '';
                    }
                    if(dem.Booking__c != null && dem.Booking__r.Lockated_User_Device_ID__c != null){
                        Set<String> deviceTokens = new Set<String>(dem.Booking__r.Lockated_User_Device_ID__c.split(';'));
                        String message = (detailsAdditionalCharges != null && detailsAdditionalCharges.Message__c != null)? detailsAdditionalCharges.Message__c.replace('{1}', (dem.Booking__r.Primary_Applicant_Name__c != null)? dem.Booking__r.Primary_Applicant_Name__c : 'Customer') : '';
                        message = (message != '')? message.replace('{2}', String.valueOf(dem.Remaining_Amount__c)) : '';
                        message = (message != '')? message.replace('{3}', String.valueOf(dem.Due_Date__c)) : '';
                        for(String token : deviceTokens){
                            if(dayName == 'Wednesday' || dayName == 'Saturday'){
                                App_Notification__c an = new App_Notification__c();
                                an.Booking__c = dem.Booking__c;
                                an.Title__c = (detailsAdditionalCharges != null)? detailsAdditionalCharges.Title__c : '';
                                an.Message__c = message;
                                an.Notification_Type__c = (detailsAdditionalCharges != null)? detailsAdditionalCharges.Notification_Type__c : '';
                                an.Record_Id__c = dem.Id;
                                an.Device_Token__c = token;
                                notifications.add(an);
                            }
                        }
                    }
                }
                if(dem.Booking__r.Primary_Applicant_Email__c != null){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new List<String>{dem.Booking__r.Primary_Applicant_Email__c});
                    mail.setSubject(subject);
                    mail.setHtmlBody(emailBody);
                    emailList.add(mail);
                }
                if(notifications.size() > 0){
                    //insert notifications;
                }
            }
            if(emailList.size() > 0){
                Messaging.SendEmailResult[] result = Messaging.sendEmail(emailList);
            }
        }
    }


    public void refBkg20PercentPayed(){

        List<Post_Sales_App_Notifications__mdt> ntfDetails = [SELECT Title__c,Message__c,Notification_Type__c,Email_Subject__c,Email_Message__c,Whatsapp_Template_Name__c,Active__c FROM Post_Sales_App_Notifications__mdt WHERE DeveloperName = 'Referral_20_Percent_Payed' AND Active__c = true LIMIT 1];
        if(ntfDetails.size() > 0){
            Post_Sales_App_Notifications__mdt details = ntfDetails[0];
            List<App_Notification__c> notifications = new List<App_Notification__c>();
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            List<Id> bkgIds = new List<Id>();
            List<Booking__c> bkgs = new List<Booking__c>();
            
            for(Booking__c bkg : [SELECT Id,Customer_Reference__c,Opportunity__r.Customer_Reference__c,Lockated_User_Device_ID__c,Reference_Booking_X20_Received__c,RW_Country_Phone_Code__c,Primary_Applicant_Mobile__c,Primary_Applicant_Name__c,Primary_Applicant_Email__c  FROM Booking__c WHERE Reference_Booking_X20_Received__c = true]){
                bkgIds.add(bkg.Id);
                bkgs.add(bkg);
            }
            //List<App_Notification__c> existingNotificatios = [SELECT Id,Booking__c FROM App_Notification__c WHERE Booking__c =: bkgIds AND Title__c = 'REFERRAL 20% PAYED'];
            List<App_Notification__c> existingNotificatios = [SELECT Id,Booking__c FROM App_Notification__c WHERE Booking__c =: bkgIds AND Title__c =: details.Title__c];
            Map<String, String> bkgIdVsNotificationId = new Map<String, String>();
            for(App_Notification__c ntf : existingNotificatios){
                bkgIdVsNotificationId.put(ntf.Booking__c, ntf.Id);
            }
            List<Booking__c> bookings = new List<Booking__c>();
            for(Booking__c bkg : bkgs){
                if(bkgIdVsNotificationId.get(bkg.Id) == null){
                    bookings.add(bkg);
                }
            }
            
            for(Booking__c bkg : bookings){
                if(bkg.Lockated_User_Device_ID__c != null && details.Message__c != null){
                    Set<String> deviceTokens = new Set<String>(bkg.Lockated_User_Device_ID__c.split(';'));
                    String message = ((details.Message__c.contains('{1}'))? details.Message__c.replace('{1}', (bkg.Primary_Applicant_Name__c != null)? bkg.Primary_Applicant_Name__c : 'Customer') : details.Message__c);
                    for(String token : deviceTokens){
                        App_Notification__c an = new App_Notification__c();
                        an.Booking__c = bkg.Id;
                        an.Title__c = details.Title__c;
                        an.Message__c = message;
                        an.Notification_Type__c = details.Notification_Type__c;
                        an.Device_Token__c = token;
                        notifications.add(an);
                    }
                }
                //SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(null,bkg.Primary_Applicant_Name__c,null,null,null,null,null,null,null,bkg.RW_Country_Phone_Code__c,bkg.Opportunity__r.RW_Mobile_No__c,'Referral 20 Percent Payed'); 
                if(details.Whatsapp_Template_Name__c != null){
                    LockatedApp_WhatsappMsgQueueable.ParameterWrap wrap = LockatedApp_WhatsappMsgQueueable.wrapper(null,bkg.Primary_Applicant_Name__c,null,null,null,null,null,null,null,bkg.RW_Country_Phone_Code__c,bkg.Primary_Applicant_Mobile__c,details.Whatsapp_Template_Name__c); 
                    wrapList.add(wrap);
                }
                //System.enqueueJob(new LockatedApp_WhatsappMsgQueueable(wrap));
                if(bkg.Primary_Applicant_Email__c != null && details.Email_Message__c != null){
                    String body = DynamicEmailService.generateEmailBody(bkg.Id, 'Referral_20_Percent_Payed', 'Body');
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new List<String>{bkg.Primary_Applicant_Email__c});
                    mail.setSubject(details.Email_Subject__c);
                    mail.setPlainTextBody(body);
                    emailList.add(mail);
                }
            }
            if(notifications.size() > 0){
                //insert notifications;
            }
            if(emailList.size() > 0){
                Messaging.SendEmailResult[] result = Messaging.sendEmail(emailList);
            }
        }
    }
    
    
    public void tdsPaymentGuideNotification(){
        List<App_Notification__c> notifications = new List<App_Notification__c>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<Post_Sales_App_Notifications__mdt> ntfDetails = [SELECT Title__c,Message__c,Notification_Type__c,Email_Subject__c,Email_Message__c,Whatsapp_Template_Name__c,Active__c FROM Post_Sales_App_Notifications__mdt WHERE DeveloperName = 'TDS_Payment_Form_upload_reminder' AND Active__c = true LIMIT 1];
        if(ntfDetails.size() > 0){
            Post_Sales_App_Notifications__mdt details = ntfDetails[0];
            for(Booking__c bkg : [SELECT Id,Lockated_User_Device_ID__c,Primary_Applicant_Name__c,RW_Country_Phone_Code__c,Opportunity__r.RW_Mobile_No__c,Primary_Applicant_Email__c,Primary_Applicant_Mobile__c FROM Booking__c WHERE RW_Total_TDS_Outstanding__c > 500]){
                if(bkg.Lockated_User_Device_ID__c != null && details.Message__c != null){
                    Set<String> deviceTokens = new Set<String>(bkg.Lockated_User_Device_ID__c.split(';'));
                    String message = ((details.Message__c.contains('{1}'))? details.Message__c.replace('{1}', (bkg.Primary_Applicant_Name__c != null)? bkg.Primary_Applicant_Name__c : 'Customer') : details.Message__c);
                    for(String token : deviceTokens){
                        App_Notification__c an = new App_Notification__c();
                        an.Booking__c = bkg.Id;
                        an.Title__c = details.Title__c;
                        an.Message__c = message;
                        an.Notification_Type__c = details.Notification_Type__c;
                        an.Record_Id__c = System.label.TDS_Tutorial_Link; 
                        an.Device_Token__c = token;
                        notifications.add(an);
                    }
                }
                //SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(null,bkg.Primary_Applicant_Name__c,null,null,null,null,null,null,null,bkg.RW_Country_Phone_Code__c,bkg.Opportunity__r.RW_Mobile_No__c,'TDS Form Upload Reminder'); 
                if(details.Whatsapp_Template_Name__c != null){
                    LockatedApp_WhatsappMsgQueueable.ParameterWrap wrap = LockatedApp_WhatsappMsgQueueable.wrapper(null,bkg.Primary_Applicant_Name__c,null,null,null,null,null,null,null,bkg.RW_Country_Phone_Code__c,bkg.Primary_Applicant_Mobile__c,details.Whatsapp_Template_Name__c); 
                    wrapList.add(wrap);
                }
                //System.enqueueJob(new LockatedApp_WhatsappMsgQueueable(wrap));
                if(bkg.Primary_Applicant_Email__c != null && details.Email_Message__c != null){
                    String body = DynamicEmailService.generateEmailBody(bkg.Id, 'TDS_Payment_Form_upload_reminder', 'Body');
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new List<String>{bkg.Primary_Applicant_Email__c});
                    mail.setSubject(details.Email_Subject__c);
                    mail.setPlainTextBody(body);
                    emailList.add(mail);
                }
            }
            if(notifications.size() > 0){
                //insert notifications;
            }
            if(emailList.size() > 0){
                Messaging.SendEmailResult[] result = Messaging.sendEmail(emailList);
            }
        }
    }

	public void milestonePaymentAchievement(){

        List<Post_Sales_App_Notifications__mdt> ntfDetails = [SELECT Title__c,Message__c,Notification_Type__c,Email_Subject__c,Email_Message__c,Whatsapp_Template_Name__c,Active__c FROM Post_Sales_App_Notifications__mdt WHERE DeveloperName = 'Milestone_Payment_Achievement' AND Active__c = true LIMIT 1];
        if(ntfDetails.size() > 0){
            Post_Sales_App_Notifications__mdt details = ntfDetails[0];
            Map<Id,Booking__c> bkgMap = new Map<Id, Booking__c>([SELECT Id,RW_Total_Amount_Received_Without_GST__c,Allotment_Premium__c,Lockated_User_Device_ID__c,Primary_Applicant_Name__c,RW_Country_Phone_Code__c,Primary_Applicant_Mobile__c FROM Booking__c WHERE RW_Total_Amount_Received_Without_GST__c > 0 AND LastModifiedDate = TODAY]);
            List<App_Notification__c> notifications = new List<App_Notification__c>();
            Map<Id, App_Notification__c> fivePercent = new Map<Id, App_Notification__c>();
            Map<Id, App_Notification__c> tenPercent = new Map<Id, App_Notification__c>();
            Map<String, List<String>> bkgVsMilestones = new Map<String, List<String>>();
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            
            for(App_Notification__c ntf : [SELECT Id,Booking__c,Title__c FROM App_Notification__c WHERE Booking__c =: bkgMap.keySet() AND Title__c like '%Milestone Payment Achievement%']){
                if(bkgVsMilestones.get(ntf.Booking__c) != null){
                    bkgVsMilestones.get(ntf.Booking__c).add(ntf.Title__c);
                }else{
                    bkgVsMilestones.put(ntf.Booking__c, new List<String>{ntf.Title__c});
                }
            }
            if(bkgMap.size() > 0){
                for(Booking__c bkg : bkgMap.values()){
                    Integer percentage;
                    //String body;
                    if(bkg.Lockated_User_Device_ID__c != null && details.Message__c != null){
                        Set<String> deviceTokens = new Set<String>(bkg.Lockated_User_Device_ID__c.split(';'));
                        String message = (details != null && details.Message__c != null)? details.Message__c.replace('{1}', bkg.Primary_Applicant_Name__c) : '';
                        Decimal val = ((bkg.RW_Total_Amount_Received_Without_GST__c * 100)/bkg.Allotment_Premium__c).setScale(2, RoundingMode.HALF_UP);
                        System.debug('val: ' + val);
                        for(String token : deviceTokens){
                            if(val == 100 && !bkgVsMilestones.get(bkg.Id).contains('Milestone Payment Achievement 100%')){
                                percentage = 100;
                                App_Notification__c an = new App_Notification__c();
                                an.Booking__c = bkg.Id;
                                an.Title__c = (details != null && details.Title__c != null)? details.Title__c.replace('{1}', '100') : '';
                                message = (message != '')? message.replace('{2}', '100') : '';
                                an.Message__c = message;
                                an.Notification_Type__c = (details != null)? details.Notification_Type__c : '';
                                an.Device_Token__c = token;
                                notifications.add(an);
                            }else if(val == 75 && !bkgVsMilestones.get(bkg.Id).contains('Milestone Payment Achievement 75%')){
                                percentage = 75;
                                App_Notification__c an = new App_Notification__c();
                                an.Booking__c = bkg.Id;
                                an.Title__c = (details != null && details.Title__c != null)? details.Title__c.replace('{1}', '75') : '';
                                message = (message != '')? message.replace('{2}', '75') : '';
                                an.Message__c = message;
                                an.Notification_Type__c = (details != null)? details.Notification_Type__c : '';
                                an.Device_Token__c = token;
                                notifications.add(an);
                            }else if(val == 50 && !bkgVsMilestones.get(bkg.Id).contains('Milestone Payment Achievement 50%')){
                                percentage = 50;
                                App_Notification__c an = new App_Notification__c();
                                an.Booking__c = bkg.Id;
                                an.Title__c = (details != null && details.Title__c != null)? details.Title__c.replace('{1}', '50') : '';
                                message = (message != '')? message.replace('{2}', '50') : '';
                                an.Message__c = message;
                                an.Notification_Type__c = (details != null)? details.Notification_Type__c : '';
                                an.Device_Token__c = token;
                                notifications.add(an);
                            }else if(val == 20 && !bkgVsMilestones.get(bkg.Id).contains('Milestone Payment Achievement 20%')){
                                percentage = 20;
                                App_Notification__c an = new App_Notification__c();
                                an.Booking__c = bkg.Id;
                                an.Title__c = (details != null && details.Title__c != null)? details.Title__c.replace('{1}', '20') : '';
                                message = (message != '')? message.replace('{2}', '20') : '';
                                an.Message__c = message;
                                an.Notification_Type__c = (details != null)? details.Notification_Type__c : '';
                                an.Device_Token__c = token;
                                notifications.add(an);
                            }else if(val == 15 && !bkgVsMilestones.get(bkg.Id).contains('Milestone Payment Achievement 15%')){
                                percentage = 15;
                                App_Notification__c an = new App_Notification__c();
                                an.Booking__c = bkg.Id;
                                an.Title__c = (details != null && details.Title__c != null)? details.Title__c.replace('{1}', '15') : '';
                                message = (message != '')? message.replace('{2}', '15') : '';
                                an.Message__c = message;
                                an.Notification_Type__c = (details != null)? details.Notification_Type__c : '';
                                an.Device_Token__c = token;
                                notifications.add(an);
                            }
                        }
                        if(details.Whatsapp_Template_Name__c != null && (val == 15 || val == 20 || val == 50 || val == 75 || val == 100)){
                            LockatedApp_WhatsappMsgQueueable.ParameterWrap wrap = LockatedApp_WhatsappMsgQueueable.wrapper(null,bkg.Primary_Applicant_Name__c,String.valueOf(val),null,null,null,null,null,null,bkg.RW_Country_Phone_Code__c,bkg.Primary_Applicant_Mobile__c,details.Whatsapp_Template_Name__c); 
                            wrapList.add(wrap);
                        }
                    }
                    //SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(null,bkg.Primary_Applicant_Name__c,null,null,null,null,null,null,null,bkg.RW_Country_Phone_Code__c,bkg.Opportunity__r.RW_Mobile_No__c,'TDS Form Upload Reminder'); 
                    if(bkg.Primary_Applicant_Email__c != null && details.Email_Message__c != null){
                        String body = DynamicEmailService.generateEmailBody(bkg.Id, 'Milestone_Payment_Achievement', 'Body');
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(new List<String>{bkg.Primary_Applicant_Email__c});
                        mail.setSubject(details.Email_Subject__c);
                        mail.setPlainTextBody(body);
                        emailList.add(mail);
                    }
                }
                if(notifications.size() > 0){
                    //insert notifications;
                }
                if(emailList.size() > 0){
                    Messaging.SendEmailResult[] result = Messaging.sendEmail(emailList);
                }
            }
        }
    }    
    
    public static void paymentDetailsNotification(){
        List<RW_Payment_Details__c> receipts = [SELECT Id,RW_Booking__c,RW_Booking__r.Lockated_User_Device_ID__c,RW_Booking__r.Primary_Applicant_Name__c,RW_Booking__r.Primary_Applicant_Email__c,RW_Booking__r.RW_Country_Phone_Code__c,RW_Booking__r.Primary_Applicant_Mobile__c FROM RW_Payment_Details__c WHERE CreatedDate = TODAY];
        List<App_Notification__c> notifications = new List<App_Notification__c>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<LockatedApp_WhatsappMsgQueueable.ParameterWrap> wrapList = new List<LockatedApp_WhatsappMsgQueueable.ParameterWrap>();
        List<Post_Sales_App_Notifications__mdt> ntfDetails = [SELECT Title__c,Message__c,Notification_Type__c,Email_Subject__c,Email_Message__c,Whatsapp_Template_Name__c,Active__c FROM Post_Sales_App_Notifications__mdt WHERE DeveloperName = 'Payment_Details_Upload_Request'  AND Active__c = true LIMIT 1];
        if(ntfDetails.size() > 0){
            Post_Sales_App_Notifications__mdt details = ntfDetails[0];
            for(RW_Payment_Details__c rec : receipts){
                if(rec.RW_Booking__c != null && rec.RW_Booking__r.Lockated_User_Device_ID__c != null && details.Message__c != null){
                    Set<String> deviceTokens = new Set<String>(rec.RW_Booking__r.Lockated_User_Device_ID__c.split(';'));
                    String message = ((details.Message__c.contains('{1}'))? details.Message__c.replace('{1}', (rec.RW_Booking__r.Primary_Applicant_Name__c != null)? rec.RW_Booking__r.Primary_Applicant_Name__c : 'Customer') : details.Message__c);
                    for(String token : deviceTokens){
                        App_Notification__c an = new App_Notification__c();
                        an.Booking__c = rec.RW_Booking__c;
                        an.Title__c = details.Title__c;
                        an.Message__c = message;
                        an.Notification_Type__c = details.Notification_Type__c;
                        an.Record_Id__c = rec.Id;
                        an.Device_Token__c = token;
                        notifications.add(an);
                    }
                }
                if(details.Whatsapp_Template_Name__c != null){
                    LockatedApp_WhatsappMsgQueueable.ParameterWrap wrap = LockatedApp_WhatsappMsgQueueable.wrapper(null,rec.RW_Booking__r.Primary_Applicant_Name__c,null,null,null,null,null,null,null,rec.RW_Booking__r.RW_Country_Phone_Code__c,rec.RW_Booking__r.Primary_Applicant_Mobile__c,details.Whatsapp_Template_Name__c); 
                    wrapList.add(wrap);
                }
                //System.enqueueJob(new LockatedApp_WhatsappMsgQueueable(wrap));
                if(rec.RW_Booking__r.Primary_Applicant_Email__c != null && details.Email_Message__c != null){
                    /*String body = DynamicEmailService.generateEmailBody(rec.Id,'Payment_Details_Upload_Request', 'Body');
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new List<String>{rec.RW_Booking__r.Primary_Applicant_Email__c});
                    mail.setSubject(details.Email_Subject__c);
                    mail.setPlainTextBody(body);
                    emailList.add(mail);*/
                }
            }
        }
        if(notifications.size() > 0){
            //insert notifications;
        }
        if(emailList.size() > 0){
            Messaging.SendEmailResult[] result = Messaging.sendEmail(emailList);
        }
        if(wrapList.size() > 0){
            //System.enqueueJob(new LockatedApp_WhatsappMsgQueueable(wrapList));
            //Database.executeBatch(new LockatedApp_WhatsappMsgQueueable(wrapList), 10);
            /*for(LockatedApp_WhatsappMsgQueueable.ParameterWrap wrap : wrapList){
                if(!Test.isRunningTest()){
                    SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(wrap.param1,wrap.param2,wrap.param3,wrap.param4,wrap.param5,wrap.param6,wrap.param7,wrap.param8,wrap.param9,wrap.param10,wrap.param11,wrap.param12); 
                }
            }*/
        }
    }
}