public class LockatedApp_NotificationsSchedule  implements Schedulable{

    public List<App_Notification__c> notifications = new List<App_Notification__c>();
    
    public void execute(SchedulableContext SC){
        nextStepsGuideNotification(); //After 2 days of Booking Confirmed
        ncfNotification(); //Post 3 days of welcome call accepted
        clearanceOf5And10PercentNotification(); //Clearance of 5% & 10%- when 5% & 10% check box is enabled on booking record 
        loanDocSubmissionNotification(); //After 3 days of Logged In Date in loan record if loan is not sanctioned then this notification will be triggered
        outstandingDueNotification();
        newsLetterNotification();
        birthdayNotification();
        timeboundMilestoneNotification();
        paymentReminderNotification();
        refBkg20PercentPayed();
        
        if(notifications.size() > 0){
            insert notifications;
        }
    }
    
    public void nextStepsGuideNotification(){
        Date dt = Date.today() - 2;
        List<Booking__c> bkgs = [SELECT Id,Lockated_User_Device_ID__c,Primary_Applicant_Name__c,Primary_Applicant_Email__c,RW_Country_Phone_Code__c,Opportunity__r.RW_Mobile_No__c FROM Booking__c WHERE RW_Booking_Confirmed_Date__c =: dt];
        if(bkgs.size() > 0){
            List<Customer_Portal_Videos__c> portalVideos = [SELECT Id,Name,Video_Link__c FROM Customer_Portal_Videos__c];
            Map<String, String> videoNameVsLink = new Map<String, String>();
            for(Customer_Portal_Videos__c vid : portalVideos){
                if(vid.Name.contains('Booking To Registration')){
                    videoNameVsLink.put('Booking To Registration', vid.Video_Link__c);
                }else if(vid.Name.contains('Home Loan')){
                    videoNameVsLink.put('Home Loan', vid.Video_Link__c);
                }else if(vid.Name.contains('Possession')){
                    videoNameVsLink.put('Possession', vid.Video_Link__c);
                }
            }
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            for(Booking__c bkg : bkgs){
                if(bkg.Lockated_User_Device_ID__c != null){
                    List<String> deviceTokens = bkg.Lockated_User_Device_ID__c.split(';');
                    String bookingToRegistrationGuide = 'Dear ' + bkg.Primary_Applicant_Name__c + ',\n To help you on your home buying journey, a step-by-step guide from booking to registration is available on your Runwal app and email. Please review it carefully for a smooth process. For help, contact support.';
                    String bookingToRegistrationWalkthrough = 'Dear ' + bkg.Primary_Applicant_Name__c + ',\n Greetings from Runwal Enterprises !!! Please refer to this walkthrough for a smooth journey from booking to registration of your property: ' + System.label.Booking_to_Registration_Link;
                    String possessionWalkthrough = 'Dear ' + bkg.Primary_Applicant_Name__c + ',\n Greetings from Runwal Enterprises !!! Here is a detailed walkthrough about your property possession process: [Possession Walkthrough Link]';
                    String paymentUploadWalkthrough = 'Dear ' + bkg.Primary_Applicant_Name__c + ',\n Greetings from Runwal Enterprises !!! To make your payment upload hassle-free, please follow this step-by-step guide: [Payment Upload Walkthrough Link]';
                    String tdsPaymentsWalkthrough = 'Dear ' + bkg.Primary_Applicant_Name__c + ',\n Greetings from Runwal Enterprises !!! Pplease review the TDS payment process through this easy walkthrough: ' + System.label.TDS_Tutorial_Link;
                    String paymentsWalkthrough = 'Dear ' + bkg.Primary_Applicant_Name__c + ',\n Greetings from Runwal Enterprises !!! For your convenience, here is the complete payment process walkthrough: [Payments Walkthrough Link]';
                    for(String token : deviceTokens){
                        App_Notification__c an1 = new App_Notification__c();
                        an1.Booking__c = bkg.Id;
                        an1.Title__c = 'Booking to Registration Guide';
                        an1.Message__c = bookingToRegistrationGuide;
                        an1.Notification_Type__c = 'customer_guide_video';
                        an1.Device_Token__c = token;
                        notifications.add(an1);
                        
                        App_Notification__c an2 = new App_Notification__c();
                        an2.Booking__c = bkg.Id;
                        an2.Title__c = 'Booking to Registration Walkthrough';
                        an2.Message__c = bookingToRegistrationWalkthrough;
                        an2.Notification_Type__c = 'customer_guide_video';
                        an2.Device_Token__c = token;
                        notifications.add(an2);
                        
                        App_Notification__c an3 = new App_Notification__c();
                        an3.Booking__c = bkg.Id;
                        an3.Title__c = 'Possession Walkthrough';
                        an3.Message__c = possessionWalkthrough;
                        an3.Notification_Type__c = 'customer_guide_video';
                        an3.Device_Token__c = token;
                        notifications.add(an3);
                        
                        App_Notification__c an4 = new App_Notification__c();
                        an4.Booking__c = bkg.Id;
                        an4.Title__c = 'Payment Upload Walkthrough';
                        an4.Message__c = paymentUploadWalkthrough;
                        an4.Notification_Type__c = 'customer_guide_video';
                        an4.Device_Token__c = token;
                        notifications.add(an4);
                        
                        App_Notification__c an5 = new App_Notification__c();
                        an5.Booking__c = bkg.Id;
                        an5.Title__c = 'TDS Payments Walkthrough';
                        an5.Message__c = tdsPaymentsWalkthrough;
                        an5.Notification_Type__c = 'customer_guide_video';
                        an5.Device_Token__c = token;
                        notifications.add(an5);
                        
                        App_Notification__c an6 = new App_Notification__c();
                        an6.Booking__c = bkg.Id;
                        an6.Title__c = 'Payments Walkthrough';
                        an6.Message__c = paymentsWalkthrough;
                        an6.Notification_Type__c = 'customer_guide_video';
                        an6.Device_Token__c = token;
                        notifications.add(an6);
                    }
                }
                if(bkg.Primary_Applicant_Email__c != null){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new List<String>{bkg.Primary_Applicant_Email__c});
                    mail.setSubject('Next steps guide from booking to registration');
                    String body = 'Dear Customer, <br/><br/>';
                    body += 'Greetings from Runwal Enterprises!! <br/>';
                    body += 'To support your home buying journey with Runwal Enterprises, we have prepared a step-by-step guide from booking to registration. This includes all required actions for bank and self-funding customers. A detailed video walkthrough is now available on your Runwal app and via email.  We encourage you to review the guide carefully to ensure a smooth and timely registration process. For assistance, contact our support team.<br/><br/>';
                    mail.setHtmlBody(body);
                    emailList.add(mail);
                }
                SendWhatsAppMsg.methodToSendWhatsAppMsg(null,bkg.Primary_Applicant_Name__c,null,null,null,null,null,null,null,bkg.RW_Country_Phone_Code__c, bkg.Opportunity__r.RW_Mobile_No__c,'Booking to Registration Guide'); 
            }
            if(notifications.size() > 0){
               insert notifications;
            }
            if(emailList.size() > 0){
                Messaging.SendEmailResult[] result = Messaging.sendEmail(emailList);
            }
        }
    }
    
    public void ncfNotification(){
        Date dt = Date.today() - 3;
        List<RW_Welcome_Call__c> welcomecalls = [SELECT Id,RW_Booking__c,RW_Booking__r.Lockated_User_Device_ID__c,RW_Booking__r.Primary_Applicant_Name__c FROM RW_Welcome_Call__c WHERE RW_Welcome_Call_Accepted_date__c =: dt AND RW_Booking__r.NCF_Status__c = 'Pending'];
        if(welcomecalls.size() > 0){
            for(RW_Welcome_Call__c wc : welcomecalls){
                if(wc.RW_Booking__c != null && wc.RW_Booking__r.Lockated_User_Device_ID__c != null){
                    List<String> deviceTokens = wc.RW_Booking__r.Lockated_User_Device_ID__c.split(';');
                    String message = 'Dear ' + wc.RW_Booking__r.Primary_Applicant_Name__c + ',\n Congrats on your booking! Please share your Name Confirmation Form within 5 days to help us update records. Timely submission ensures smooth registration.';
                    for(String token : deviceTokens){
                        App_Notification__c an = new App_Notification__c();
                        an.Booking__c = wc.RW_Booking__c;
                        an.Title__c = 'Request for Name Confirmation Form (NCF)';
                        an.Message__c = message;
                        an.Notification_Type__c = 'ncf_form';
                        an.Device_Token__c = token;
                        notifications.add(an);
                    }
                }
            }
            if(notifications.size() > 0){
               insert notifications;
            }
        }
    }
    
    public void ncfReminderNotification(){
        Date dt = Date.today() - 6;
        List<RW_Welcome_Call__c> welcomecalls = [SELECT Id,RW_Booking__c,RW_Booking__r.Lockated_User_Device_ID__c,RW_Booking__r.Primary_Applicant_Name__c,RW_Welcome_Call_Accepted_date__c,RW_Booking__r.RW_Country_Phone_Code__c,RW_Booking__r.Opportunity__r.RW_Mobile_No__c,RW_Booking__r.Primary_Applicant_Email__c FROM RW_Welcome_Call__c WHERE RW_Welcome_Call_Accepted_date__c <=: dt AND RW_Booking__r.NCF_Status__c = 'Pending'];
        if(welcomecalls.size() > 0){
            Date today = Date.today();
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            for(RW_Welcome_Call__c wc : welcomecalls){
            	Integer daysPassed = (wc.RW_Welcome_Call_Accepted_date__c + 3).daysBetween(today);
                if(wc.RW_Booking__c != null && wc.RW_Booking__r.Lockated_User_Device_ID__c != null && daysPassed > 0 && Math.mod(daysPassed, 3) == 0){
                    List<String> deviceTokens = wc.RW_Booking__r.Lockated_User_Device_ID__c.split(';');
                    String message = 'Dear ' + wc.RW_Booking__r.Primary_Applicant_Name__c + ',\n Kindly share your Name Confirmation Form within 3 days to avoid registration delays.';
                    for(String token : deviceTokens){
                        App_Notification__c an = new App_Notification__c();
                        an.Booking__c = wc.RW_Booking__c;
                        an.Title__c = 'Reminder if NCF Not Shared';
                        an.Message__c = message;
                        an.Notification_Type__c = 'ncf_form';
                        an.Device_Token__c = token;
                        notifications.add(an);
                    }
                }
                SendWhatsAppMsg.methodToSendWhatsAppMsg(null,wc.RW_Booking__r.Primary_Applicant_Name__c,null,null,null,null,null,null,null,wc.RW_Booking__r.RW_Country_Phone_Code__c,wc.RW_Booking__r.Opportunity__r.RW_Mobile_No__c,'NCF Reminder'); 
                if(wc.RW_Booking__r.Primary_Applicant_Email__c != null){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new List<String>{wc.RW_Booking__r.Primary_Applicant_Email__c});
                    mail.setSubject('Reminder for Name Confirmation Form (NCF)');
                    String body = 'Dear Customer, <br/><br/>';
                    body += 'Greetings from Runwal Enterprises!! <br/>';
                    body += 'This is a gentle reminder to kindly share your Name Confirmation Form within the next 3 days to proceed with your registration. Timely submission will help avoid delays.<br/><br/>';
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
    }
    
    public void clearanceOf5And10PercentNotification(){
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
                    List<String> deviceTokens = bkg.Lockated_User_Device_ID__c.split(';');
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
                //SendWhatsAppMsg.methodToSendWhatsAppMsg(null,bkg.Primary_Applicant_Name__c,null,null,null,null,null,null,null,bkg.RW_Country_Phone_Code__c,bkg.Opportunity__r.RW_Mobile_No__c,'TDS Form Upload Reminder'); 
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
    }
    
    public void loanDocSubmissionNotification(){
        Date dt = Date.today() - 3;
        List<Loan__c> loans = [SELECT Id,RW_Booking__c,RW_Booking__r.Lockated_User_Device_ID__c,RW_Booking__r.Primary_Applicant_Name__c,RW_Booking__r.RW_Country_Phone_Code__c,RW_Booking__r.Opportunity__r.RW_Mobile_No__c,RW_Booking__r.Primary_Applicant_Email__c FROM Loan__c WHERE Logged_In_Date__c =: dt AND RW_Sanction_Status__c != 'Loan Sanctioned'];
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        for(Loan__c ln : loans){
            if(ln.RW_Booking__c != null && ln.RW_Booking__r.Lockated_User_Device_ID__c != null){
                List<String> deviceTokens = ln.RW_Booking__r.Lockated_User_Device_ID__c.split(';');
                String message = 'Dear ' + ln.RW_Booking__r.Primary_Applicant_Name__c + ',\n If funding through bank, kindly submit your loan documents within 3 days for sanction processing. Upload via Runwal app or contact your RM for assistance.';
                for(String token : deviceTokens){
                    App_Notification__c an = new App_Notification__c();
                    an.Booking__c = ln.RW_Booking__c;
                    an.Title__c = 'Loan Documentation Submission Reminder';
                    an.Message__c = message;
                    an.Notification_Type__c = 'my_loan';
                    an.Record_Id__c = ln.Id;
                    an.Device_Token__c = token;
                    notifications.add(an);
                }
            }
            SendWhatsAppMsg.methodToSendWhatsAppMsg(null,ln.RW_Booking__r.Primary_Applicant_Name__c,null,null,null,null,null,null,null,ln.RW_Booking__r.RW_Country_Phone_Code__c,ln.RW_Booking__r.Opportunity__r.RW_Mobile_No__c,'Loan Documentation Submission Reminder'); 
            if(ln.RW_Booking__r.Primary_Applicant_Email__c != null){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<String>{ln.RW_Booking__r.Primary_Applicant_Email__c});
                mail.setSubject('Loan Documentation Submission Reminder');
                String body = 'Dear Customer, <br/><br/>';
                body += 'Greetings from Runwal Enterprises!! <br/>';
                body += 'In case you are funding your unit from the bank we request you to kindly have your loan documentation submitted within 3 days to process the sanction from the bank.<br/><br/>';
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
    
    public void sanctionLetterSubmissionReminderNotification(){
        Date dt = Date.today() - 6;
        List<Loan__c> loans = [SELECT Id,RW_Booking__c,RW_Booking__r.Lockated_User_Device_ID__c,RW_Booking__r.Primary_Applicant_Name__c,Logged_In_Date__c,RW_Booking__r.RW_Country_Phone_Code__c,RW_Booking__r.Opportunity__r.RW_Mobile_No__c,RW_Booking__r.Primary_Applicant_Email__c FROM Loan__c WHERE Logged_In_Date__c <=: dt AND RW_Sanction_Status__c != 'Loan Sanctioned'];
        Date today = Date.today();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        for(Loan__c ln : loans){
            Integer daysPassed = (ln.Logged_In_Date__c + 3).daysBetween(today);
            if(ln.RW_Booking__c != null && ln.RW_Booking__r.Lockated_User_Device_ID__c != null && daysPassed > 0 && Math.mod(daysPassed, 3) == 0){
                List<String> deviceTokens = ln.RW_Booking__r.Lockated_User_Device_ID__c.split(';');
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
            SendWhatsAppMsg.methodToSendWhatsAppMsg(null,ln.RW_Booking__r.Primary_Applicant_Name__c,null,null,null,null,null,null,null,ln.RW_Booking__r.RW_Country_Phone_Code__c,ln.RW_Booking__r.Opportunity__r.RW_Mobile_No__c,'Sanction Letter Submission Reminder'); 
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
            insert notifications;
        }
        if(emailList.size() > 0){
            Messaging.SendEmailResult[] result = Messaging.sendEmail(emailList);
        }
    }
    
    public void outstandingDueNotification(){
        List<RW_Demand__c> demands = [SELECT Id,Due_Date__c,Booking__c,Booking__r.Lockated_User_Device_ID__c,Booking__r.Primary_Applicant_Name__c,Booking__r.Unit_No__c,Booking__r.Unit_No__r.Name,Booking__r.FBL5N__c,Booking__r.Unit_No__r.RW_Param4__c FROM RW_Demand__c WHERE RW_Demand_Status__c = 'Due' AND Booking__r.FBL5N__c > 50000];
        List<App_Notification__c> notifications = new List<App_Notification__c>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        for(RW_Demand__c dem : demands){
            Decimal demOut = dem.Booking__r.FBL5N__c;
            List<String> args = new String[]{'0','number','##,##,##,###.##'};
            String amount = String.format(demOut.format(), args);
            String message = 'Dear ' + dem.Booking__r.Primary_Applicant_Name__c + '\nThe outstanding amount towards your purchased unit ' + dem.Booking__r.Unit_No__r.RW_Param4__c + ' is Rs ' + amount + '. Kindly clear your dues before the due date to avoid any additional late payment charges. Please ignore this message if you already have paid the dues.';
            if(dem.Booking__c != null && dem.Booking__r.Lockated_User_Device_ID__c != null){
                List<String> deviceTokens = dem.Booking__r.Lockated_User_Device_ID__c.split(';');
                for(String token : deviceTokens){
                    if(Date.Today() == (dem.Due_Date__c - 10)){
                        App_Notification__c an = new App_Notification__c();
                        an.Booking__c = dem.Booking__c;
                        an.Title__c = 'Clear current outstanding dues';
                        an.Message__c = message;
                        an.Notification_Type__c = 'payments_due';
                        an.Record_Id__c = dem.Id;
                        an.Device_Token__c = token;
                        notifications.add(an);
                    }else if(Date.Today() == (dem.Due_Date__c - 5)){
                        App_Notification__c an = new App_Notification__c();
                        an.Booking__c = dem.Booking__c;
                        an.Title__c = 'Clear current outstanding dues';
                        an.Message__c = message;
                        an.Notification_Type__c = 'payments_due';
                        an.Record_Id__c = dem.Id;
                        an.Device_Token__c = token;
                        notifications.add(an);
                    }else if(Date.Today() == dem.Due_Date__c){
                        App_Notification__c an = new App_Notification__c();
                        an.Booking__c = dem.Booking__c;
                        an.Title__c = 'Clear current outstanding dues';
                        an.Message__c = message;
                        an.Notification_Type__c = 'payments_due';
                        an.Record_Id__c = dem.Id;
                        an.Device_Token__c = token;
                        notifications.add(an);
                    }else if(Date.Today() > dem.Due_Date__c){
                        Date today = Date.today();
                        Integer daysPassed = dem.Due_Date__c.daysBetween(today);
                        if (daysPassed > 0 && Math.mod(daysPassed, 7) == 0) {
                            App_Notification__c an = new App_Notification__c();
                            an.Booking__c = dem.Booking__c;
                            an.Title__c = 'Clear current outstanding dues';
                            an.Message__c = message;
                            an.Notification_Type__c = 'payments_due';
                            an.Record_Id__c = dem.Id;
                            an.Device_Token__c = token;
                            notifications.add(an);
                        }
                    }
                }
            }
            SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(dem.Booking__r.Opportunity__c,dem.Booking__r.Primary_Applicant_Name__c, dem.Booking__r.Unit_No__r.Name, amount, null, null, null, null, null, dem.Booking__r.RW_Country_Phone_Code__c, dem.Booking__r.Opportunity__r.RW_Mobile_No__c, 'Payment Due Alert WhatsApp');     
            if(dem.Booking__r.Primary_Applicant_Email__c != null){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<String>{dem.Booking__r.Primary_Applicant_Email__c});
                mail.setSubject('Clear current outstanding dues');
                mail.setHtmlBody(message);
                emailList.add(mail);
            }
        }
        System.debug('notifications: ' + notifications);
        if(notifications.size() > 0){
            insert notifications;
        }
        if(emailList.size() > 0){
            Messaging.SendEmailResult[] result = Messaging.sendEmail(emailList);
        }
    }
    
    public void newsLetterNotification(){
        List<Opportunity> opportunities = [SELECT Id,RW_Email__c,Booking__c,Booking__r.Lockated_User_Device_ID__c,Booking__r.RW_Country_Phone_Code__c,RW_Mobile_No__c FROM Opportunity WHERE News_Letter_Date__c = TODAY];
        if(opportunities.size() > 0){
            List<App_Notification__c> notifications = new List<App_Notification__c>();
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            for(Opportunity opp : opportunities){
                if(opp.Booking__c != null && opp.Booking__r.Lockated_User_Device_ID__c != null){
                    List<String> deviceTokens = opp.Booking__r.Lockated_User_Device_ID__c.split(';');
                    String message = 'Dear Customer,\n Greetings from Runwal Enterprises !!!\n The latest Runwal newsletter is now available on the Runwal Connect App.  Stay updated with all the latest news and offers.';
                    for(String token : deviceTokens){
                        App_Notification__c an = new App_Notification__c();
                        an.Booking__c = opp.Booking__c;
                        an.Title__c = 'Runwal Newsletter Notification';
                        an.Message__c = message;
                        an.Notification_Type__c = 'about/newsletter';
                        an.Device_Token__c = token;
                        notifications.add(an);
                    }
                }
                SendWhatsAppMsg.methodToSendWhatsAppMsg(null,null,null,null,null,null,null,null,null,opp.Booking__r.RW_Country_Phone_Code__c,opp.RW_Mobile_No__c,'Newsletter'); 
                if(opp.RW_Email__c != null){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new List<String>{opp.RW_Email__c});
                    mail.setSubject('Runwal Newsletter Notification');
                    String body = 'Dear Customer, <br/><br/>';
                    body += 'Greetings from Runwal Enterprises!! <br/>';
                    body += 'The latest Runwal newsletter is now available on the Runwal Connect App.  Stay updated with all the latest news and offers.<br/><br/>';
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
    }
    
    public void birthdayNotification(){
        Date today = System.today();
        List<Applicant_Details__c> applicants = [SELECT Id,Booking__c,Booking__r.Lockated_User_Device_ID__c,Booking__r.Primary_Applicant_Name__c FROM Applicant_Details__c WHERE Opportunity__r.StageName = 'Unit Booked' 
                                                 AND DAY_IN_MONTH(DOB__c) =: today.DAY() AND CALENDAR_MONTH(DOB__c) =: today.MONTH()];
        for(Applicant_Details__c app : applicants){
            if(app.Booking__c != null && app.Booking__r.Lockated_User_Device_ID__c != null){
                List<String> deviceTokens = app.Booking__r.Lockated_User_Device_ID__c.split(';');
                String message = 'Dear ' + app.Booking__r.Primary_Applicant_Name__c + ' ,\nGreetings from Runwal Group. \nOn this special day we would like to extend our best wishes!! We wish you a very happy birthday filled with health, happiness and success!! We thank you for being a part of the Runwal family.';
                for(String token : deviceTokens){
                    App_Notification__c an = new App_Notification__c();
                    an.Booking__c = app.Booking__c;
                    an.Title__c = 'BIRTHDAY WISHES ';
                    an.Message__c = 'Birthdat wishes';
                    an.Notification_Type__c = '';
                    an.Device_Token__c = token;
                    notifications.add(an);
                }
            }
        }
    }
    
    public void timeboundMilestoneNotification(){
        List<Booking__c> bkgs = [SELECT Id,Quotation__c,Lockated_User_Device_ID__c FROM Booking__c WHERE RW_Total_Demand_Raised__c = 0 AND Status__c = 'Booking Confirmed'];
        Set<Id> quoteIds = new Set<Id>();
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
                        List<String> deviceTokens = bkg.Lockated_User_Device_ID__c.split(';');
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
                        List<String> deviceTokens = bkg.Lockated_User_Device_ID__c.split(';');
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
                        List<String> deviceTokens = bkg.Lockated_User_Device_ID__c.split(';');
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
        }
    }
    
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
                        SendWhatsAppMsg.methodToSendWhatsAppMsg(null,dem.Booking__r.Primary_Applicant_Name__c,String.valueOf(dem.Remaining_Amount__c),'10',String.valueOf(dem.Due_Date__c),null,null,null,null,dem.Booking__r.RW_Country_Phone_Code__c,dem.Booking__r.Opportunity__r.RW_Mobile_No__c,'Payment Reminder Before Due Date'); 
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
                        SendWhatsAppMsg.methodToSendWhatsAppMsg(null,dem.Booking__r.Primary_Applicant_Name__c,String.valueOf(dem.Remaining_Amount__c),'7',String.valueOf(dem.Due_Date__c),null,null,null,null,dem.Booking__r.RW_Country_Phone_Code__c,dem.Booking__r.Opportunity__r.RW_Mobile_No__c,'Payment Reminder Before Due Date'); 
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
                        SendWhatsAppMsg.methodToSendWhatsAppMsg(null,dem.Booking__r.Primary_Applicant_Name__c,String.valueOf(dem.Remaining_Amount__c),'5',String.valueOf(dem.Due_Date__c),null,null,null,null,dem.Booking__r.RW_Country_Phone_Code__c,dem.Booking__r.Opportunity__r.RW_Mobile_No__c,'Payment Reminder Before Due Date'); 
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
                        SendWhatsAppMsg.methodToSendWhatsAppMsg(null,dem.Booking__r.Primary_Applicant_Name__c,String.valueOf(dem.Remaining_Amount__c),'0',String.valueOf(dem.Due_Date__c),null,null,null,null,dem.Booking__r.RW_Country_Phone_Code__c,dem.Booking__r.Opportunity__r.RW_Mobile_No__c,'Payment Reminder Before Due Date'); 
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
                            SendWhatsAppMsg.methodToSendWhatsAppMsg(null,dem.Booking__r.Primary_Applicant_Name__c,String.valueOf(dem.Remaining_Amount__c),String.valueOf(dem.Due_Date__c),null,null,null,null,null,dem.Booking__r.RW_Country_Phone_Code__c,dem.Booking__r.Opportunity__r.RW_Mobile_No__c,'Additional Charges Reminder'); 
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
        List<RW_Demand__c> demands = [SELECT Id,Due_Date__c,Booking__c,Booking__r.Lockated_User_Device_ID__c,Booking__r.Primary_Applicant_Name__c,Remaining_Amount__c FROM RW_Demand__c WHERE RW_Demand_Status__c = 'Due'];
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        for(RW_Demand__c dem : demands){
            String emailBody = 'Dear ' + dem.Booking__r.Primary_Applicant_Name__c + ', <br/><br/>';
            String subject;
            if(Date.Today() == (dem.Due_Date__c - 10)){
                SendWhatsAppMsg.methodToSendWhatsAppMsg(null,dem.Booking__r.Primary_Applicant_Name__c,String.valueOf(dem.Remaining_Amount__c),'10',String.valueOf(dem.Due_Date__c),null,null,null,null,dem.Booking__r.RW_Country_Phone_Code__c,dem.Booking__r.Opportunity__r.RW_Mobile_No__c,'Payment Reminder Before Due Date'); 
                subject = '10 days prior to due date';
                emailBody += 'This is a gentle reminder that your payment of ₹' + dem.Remaining_Amount__c + ' for your property is due in 10 days, on ' + dem.Due_Date__c + '. Kindly ensure timely payment to avoid any interest being charged on the outstanding amount.<br/>'; 
                emailBody += 'To ignore the demand incase if it’s already paid.<br/>';
                emailBody += 'Thank you for your attention.<br/><br/>';
                if(dem.Booking__c != null && dem.Booking__r.Lockated_User_Device_ID__c != null){
                    List<String> deviceTokens = dem.Booking__r.Lockated_User_Device_ID__c.split(';');
                    for(String token : deviceTokens){
                        App_Notification__c an = new App_Notification__c();
                        an.Booking__c = dem.Booking__c;
                        an.Title__c = 'Payment Reminder Before Due Date ';
                        an.Message__c = 'Dear ' + dem.Booking__r.Primary_Applicant_Name__c + ',\n This is a gentle reminder that ₹ ' + dem.Remaining_Amount__c + ' is due in 10 days on ' + dem.Due_Date__c + '. Please ensure timely payment to avoid interest. Ignore if already paid.';
                        an.Notification_Type__c = 'payment_dues';
                        an.Record_Id__c = dem.Id;
                        an.Device_Token__c = token;
                        notifications.add(an);
                    }
                }
            }else if(Date.Today() == (dem.Due_Date__c - 7)){
                SendWhatsAppMsg.methodToSendWhatsAppMsg(null,dem.Booking__r.Primary_Applicant_Name__c,String.valueOf(dem.Remaining_Amount__c),'7',String.valueOf(dem.Due_Date__c),null,null,null,null,dem.Booking__r.RW_Country_Phone_Code__c,dem.Booking__r.Opportunity__r.RW_Mobile_No__c,'Payment Reminder Before Due Date'); 
                subject = '7 days prior to due date';
                emailBody += 'Your payment of ₹' + dem.Remaining_Amount__c + ' remains due and is 7 days away from the due date, ' + dem.Due_Date__c + '. We encourage you to make the payment within the due date to avoid interest charges. <br/>'; 
                emailBody += 'To ignore the demand incase if it’s already paid. <br/>';
                emailBody += 'We appreciate your promptness.<br/><br/>';
                if(dem.Booking__c != null && dem.Booking__r.Lockated_User_Device_ID__c != null){
                    List<String> deviceTokens = dem.Booking__r.Lockated_User_Device_ID__c.split(';');
                    for(String token : deviceTokens){
                        App_Notification__c an = new App_Notification__c();
                        an.Booking__c = dem.Booking__c;
                        an.Title__c = 'Payment Reminder Before Due Date ';
                        an.Message__c = 'Dear ' + dem.Booking__r.Primary_Applicant_Name__c + ',\n This is a gentle reminder that ₹ ' + dem.Remaining_Amount__c + ' is due in 7 days on ' + dem.Due_Date__c + '. Please ensure timely payment to avoid interest. Ignore if already paid.';
                        an.Notification_Type__c = 'payment_dues';
                        an.Record_Id__c = dem.Id;
                        an.Device_Token__c = token;
                        notifications.add(an);
                    }
                }
            }else if(Date.Today() == (dem.Due_Date__c - 5)){
                SendWhatsAppMsg.methodToSendWhatsAppMsg(null,dem.Booking__r.Primary_Applicant_Name__c,String.valueOf(dem.Remaining_Amount__c),'5',String.valueOf(dem.Due_Date__c),null,null,null,null,dem.Booking__r.RW_Country_Phone_Code__c,dem.Booking__r.Opportunity__r.RW_Mobile_No__c,'Payment Reminder Before Due Date'); 
                subject = '5 days prior to due date';
                emailBody += 'This is a kind reminder that your payment of ₹' + dem.Remaining_Amount__c + ' is due in 5 days, on' + dem.Due_Date__c + '. Please ensure the due amount is cleared on or before the due date to prevent any interest being applied. <br/>'; 
                emailBody += 'To ignore the demand incase if it’s already paid. <br/>';
                emailBody += 'Thank you.<br/><br/>';
                if(dem.Booking__c != null && dem.Booking__r.Lockated_User_Device_ID__c != null){
                    List<String> deviceTokens = dem.Booking__r.Lockated_User_Device_ID__c.split(';');
                    for(String token : deviceTokens){
                        App_Notification__c an = new App_Notification__c();
                        an.Booking__c = dem.Booking__c;
                        an.Title__c = 'Payment Reminder Before Due Date ';
                        an.Message__c = 'Dear ' + dem.Booking__r.Primary_Applicant_Name__c + ',\n This is a gentle reminder that ₹ ' + dem.Remaining_Amount__c + ' is due in 5 days on ' + dem.Due_Date__c + '. Please ensure timely payment to avoid interest. Ignore if already paid.';
                        an.Notification_Type__c = 'payment_dues';
                        an.Record_Id__c = dem.Id;
                        an.Device_Token__c = token;
                        notifications.add(an);
                    }
                }
            }else if(Date.Today() == dem.Due_Date__c){
                SendWhatsAppMsg.methodToSendWhatsAppMsg(null,dem.Booking__r.Primary_Applicant_Name__c,String.valueOf(dem.Remaining_Amount__c),'0',String.valueOf(dem.Due_Date__c),null,null,null,null,dem.Booking__r.RW_Country_Phone_Code__c,dem.Booking__r.Opportunity__r.RW_Mobile_No__c,'Payment Reminder Before Due Date'); 
                subject = 'On the final day';
                emailBody += 'Today is the due date, ' + dem.Due_Date__c + ' for your payment of ' + dem.Remaining_Amount__c + '.Please arrange to make the payment today to avoid interest on the overdue amount. <br/>'; 
                emailBody += 'To ignore the demand incase if it’s already paid.<br/>';
                emailBody += 'We appreciate your cooperation.<br/><br/>';
                if(dem.Booking__c != null && dem.Booking__r.Lockated_User_Device_ID__c != null){
                    List<String> deviceTokens = dem.Booking__r.Lockated_User_Device_ID__c.split(';');
                    for(String token : deviceTokens){
                        App_Notification__c an = new App_Notification__c();
                        an.Booking__c = dem.Booking__c;
                        an.Title__c = 'Payment Reminder Before Due Date ';
                        an.Message__c = 'Dear ' + dem.Booking__r.Primary_Applicant_Name__c + ',\n This is a gentle reminder that ₹ ' + dem.Remaining_Amount__c + ' is due in 0 days on ' + dem.Due_Date__c + '. Please ensure timely payment to avoid interest. Ignore if already paid.';
                        an.Notification_Type__c = 'payment_dues';
                        an.Record_Id__c = dem.Id;
                        an.Device_Token__c = token;
                        notifications.add(an);
                    }
                }
            }else if(Date.Today() > dem.Due_Date__c){
                SendWhatsAppMsg.methodToSendWhatsAppMsg(null,dem.Booking__r.Primary_Applicant_Name__c,String.valueOf(dem.Remaining_Amount__c),String.valueOf(dem.Due_Date__c),null,null,null,null,null,dem.Booking__r.RW_Country_Phone_Code__c,dem.Booking__r.Opportunity__r.RW_Mobile_No__c,'Additional Charges Reminder'); 
                String dayName = DateTime.now().format('EEEE');
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
                if(dem.Booking__c != null && dem.Booking__r.Lockated_User_Device_ID__c != null){
                    List<String> deviceTokens = dem.Booking__r.Lockated_User_Device_ID__c.split(';');
                    for(String token : deviceTokens){
                        if(dayName == 'Wednesday' || dayName == 'Saturday'){
                            App_Notification__c an = new App_Notification__c();
                            an.Booking__c = dem.Booking__c;
                            an.Title__c = 'Additional Charges Reminder (Overdue Payment)';
                            an.Message__c = 'Dear ' + dem.Booking__r.Primary_Applicant_Name__c + ',\n Our records show payment of ₹' + dem.Remaining_Amount__c + ' due on ' + dem.Due_Date__c + ' is unpaid. Additional interest charges apply. Please clear the dues promptly. Ignore if already paid.';
                            an.Notification_Type__c = 'payment_dues';
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
        }
        if(emailList.size() > 0){
            Messaging.SendEmailResult[] result = Messaging.sendEmail(emailList);
        }
    }


    public void refBkg20PercentPayed(){
        List<App_Notification__c> notifications = new List<App_Notification__c>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<Id> bkgIds = new List<Id>();
        List<Booking__c> bkgs = new List<Booking__c>();
        for(Booking__c bkg : [SELECT Id,Customer_Reference__c,Opportunity__r.Customer_Reference__c,Lockated_User_Device_ID__c,Reference_Booking_X20_Received__c  FROM Booking__c WHERE Reference_Booking_X20_Received__c = true]){
            bkgIds.add(bkg.Id);
            bkgs.add(bkg);
        }
        List<App_Notification__c> existingNotificatios = [SELECT Id,Booking__c FROM App_Notification__c WHERE Booking__c =: bkgIds AND Title__c = 'REFERRAL 20% PAYED'];
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
            if(bkg.Lockated_User_Device_ID__c != null){
                List<String> deviceTokens = bkg.Lockated_User_Device_ID__c.split(';');
                String message = 'Dear ' + bkg.Primary_Applicant_Name__c + ',\n We are excited to inform you that you are now eligible to receive referral points as your referral has completed 20% payment of their agreement value and finalized their flat registration. \nThank you for your valuable referrals and for being part of the Runwal family!"';
                for(String token : deviceTokens){
                    App_Notification__c an = new App_Notification__c();
                    an.Booking__c = bkg.Id;
                    an.Title__c = 'Congratulations! You Are Now Eligible for Referral Points';
                    an.Message__c = message;
                    an.Notification_Type__c = 'my_refferals';
                    an.Device_Token__c = token;
                    notifications.add(an);
                }
            }
            SendWhatsAppMsg.methodToSendWhatsAppMsg(null,bkg.Primary_Applicant_Name__c,null,null,null,null,null,null,null,bkg.RW_Country_Phone_Code__c,bkg.Opportunity__r.RW_Mobile_No__c,'Referral 20 Percent Payed'); 
            if(bkg.Primary_Applicant_Email__c != null){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<String>{bkg.Primary_Applicant_Email__c});
                mail.setSubject('Congratulations! You Are Now Eligible for Referral Points');
                String body = 'Dear ' + bkg.Primary_Applicant_Name__c + ', <br/><br/>';
                body += 'We are excited to inform you that you are now eligible to receive referral points as your referral has completed 20% payment of their agreement value and finalized their flat registration. <br/><br/>';
                body += 'Thank you for your valuable referrals and for being part of the Runwal family! <br/><br/>';
                body += 'Warm regards,<br/>Runwal Enterprises';
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
    
}