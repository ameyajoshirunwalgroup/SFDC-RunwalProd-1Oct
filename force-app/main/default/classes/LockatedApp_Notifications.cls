public class LockatedApp_Notifications {
    
    public static Map<Id, Id> bkgIdVsLoanId;
    public static Map<Id, Date> bkgIdVsLogInDate = new Map<Id, Date>();
    
    //When Booking Confirmed  --> Booking Trigger
    public static void bookingConfirmedNotification(List<String> bkgIds){
        List<App_Notification__c> notifications = new List<App_Notification__c>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<LockatedApp_WhatsappMsgQueueable.ParameterWrap> wrapList = new List<LockatedApp_WhatsappMsgQueueable.ParameterWrap>();
        List<Post_Sales_App_Notifications__mdt> ntfDetails = [SELECT Title__c,Message__c,Notification_Type__c,Email_Subject__c,Email_Message__c,Whatsapp_Template_Name__c,Active__c  FROM Post_Sales_App_Notifications__mdt WHERE DeveloperName = 'Booking_Confirmation' AND Active__c = true LIMIT 1];
        if(ntfDetails.size() > 0 ){
            Post_Sales_App_Notifications__mdt details = ntfDetails[0];
            for(Booking__c bkg : [SELECT Id,Lockated_User_Device_ID__c,Primary_Applicant_Name__c,Primary_Applicant_Email__c,RW_Country_Phone_Code__c,Opportunity__r.RW_Mobile_No__c,Primary_Applicant_Mobile__c,Source_of_Booking__c FROM Booking__c WHERE Id =: bkgIds]){
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
                if(details.Whatsapp_Template_Name__c != null){
                    LockatedApp_WhatsappMsgQueueable.ParameterWrap wrap = LockatedApp_WhatsappMsgQueueable.wrapper(null,bkg.Primary_Applicant_Name__c,bkg.Source_of_Booking__c,null,null,null,null,null,null,bkg.RW_Country_Phone_Code__c, bkg.Primary_Applicant_Mobile__c,details.Whatsapp_Template_Name__c); 
                    wrapList.add(wrap);
                }
                if(bkg.Primary_Applicant_Email__c != null && details.Email_Message__c != null){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new List<String>{bkg.Primary_Applicant_Email__c});
                    mail.setSubject(details.Email_Subject__c);
                    mail.setPlainTextBody(details.Email_Message__c);
                    emailList.add(mail);
                }
            }
        }
        if(notifications.size() > 0){
            insert notifications;
        }
        if(emailList.size() > 0){
            Messaging.SendEmailResult[] result = Messaging.sendEmail(emailList);
        }
        if(wrapList.size() > 0){
            //System.enqueueJob(new LockatedApp_WhatsappMsgQueueable(wrapList));
            Database.executeBatch(new LockatedApp_WhatsappMsgQueueable(wrapList), 10);
        }
    }
    
    //When Booking Confirmed  --> Booking Trigger
    public static void homeLoanNotification(List<String> bkgIds){
        List<App_Notification__c> notifications = new List<App_Notification__c>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<LockatedApp_WhatsappMsgQueueable.ParameterWrap> wrapList = new List<LockatedApp_WhatsappMsgQueueable.ParameterWrap>();
        List<Post_Sales_App_Notifications__mdt> ntfDetails = [SELECT Title__c,Message__c,Notification_Type__c,Email_Subject__c,Email_Message__c,Whatsapp_Template_Name__c,Active__c FROM Post_Sales_App_Notifications__mdt WHERE DeveloperName = 'Home_Loan_Notification' AND Active__c = true LIMIT 1];
        if(ntfDetails.size() > 0){
            Post_Sales_App_Notifications__mdt details = ntfDetails[0];
            for(Booking__c bkg : [SELECT Id,Lockated_User_Device_ID__c,Primary_Applicant_Name__c,Primary_Applicant_Email__c,RW_Country_Phone_Code__c,Opportunity__r.RW_Mobile_No__c,Primary_Applicant_Mobile__c FROM Booking__c WHERE Id =: bkgIds]){
                if(bkg.Lockated_User_Device_ID__c != null && details.Message__c != null){
                    Set<String> deviceTokens = new Set<String>(bkg.Lockated_User_Device_ID__c.split(';'));
                    String message = ((details.Message__c.contains('{1}'))? details.Message__c.replace('{1}', (bkg.Primary_Applicant_Name__c != null)? bkg.Primary_Applicant_Name__c : 'Customer') : details.Message__c);
                    for(String token : deviceTokens){
                        App_Notification__c an = new App_Notification__c();
                        an.Booking__c = bkg.Id;
                        an.Title__c =  details.Title__c;
                        an.Message__c = message;
                        an.Notification_Type__c = details.Notification_Type__c;
                        an.Device_Token__c = token;
                        notifications.add(an);
                    }
                }
                if(bkg.Primary_Applicant_Email__c != null && details.Email_Message__c != null){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new List<String>{bkg.Primary_Applicant_Email__c});
                    mail.setSubject(details.Email_Subject__c);
                    mail.setPlainTextBody(details.Email_Message__c);
                    emailList.add(mail);
                }
                if(details.Whatsapp_Template_Name__c != null){
                    LockatedApp_WhatsappMsgQueueable.ParameterWrap wrap = LockatedApp_WhatsappMsgQueueable.wrapper(null,bkg.Primary_Applicant_Name__c,null,null,null,null,null,null,null,bkg.RW_Country_Phone_Code__c,bkg.Primary_Applicant_Mobile__c,details.Whatsapp_Template_Name__c); 
                    wrapList.add(wrap);
                }
            }
        }
        if(notifications.size() > 0){
            insert notifications;
        }
        if(emailList.size() > 0){
            Messaging.SendEmailResult[] result = Messaging.sendEmail(emailList);
        }
        if(wrapList.size() > 0){
            //System.enqueueJob(new LockatedApp_WhatsappMsgQueueable(wrapList));
            Database.executeBatch(new LockatedApp_WhatsappMsgQueueable(wrapList), 10);
        }
    }
    
    //When Sanction Date is updated in Loan record --> Loan Trigger
    public static void sanctionStatusNotification(List<Id> loanIds){
        List<App_Notification__c> notifications = new List<App_Notification__c>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<LockatedApp_WhatsappMsgQueueable.ParameterWrap> wrapList = new List<LockatedApp_WhatsappMsgQueueable.ParameterWrap>();
        List<Post_Sales_App_Notifications__mdt> ntfDetails = [SELECT Title__c,Message__c,Notification_Type__c,Email_Subject__c,Email_Message__c,Whatsapp_Template_Name__c,Active__c FROM Post_Sales_App_Notifications__mdt WHERE DeveloperName = 'Home_Loan_Sanction_Approved' AND Active__c = true LIMIT 1];
        if(ntfDetails.size() > 0){
            Post_Sales_App_Notifications__mdt details = ntfDetails[0];
            for(Loan__c ln : [SELECT Id,RW_Booking__c,RW_Booking__r.Lockated_User_Device_ID__c,RW_Booking__r.Primary_Applicant_Name__c,RW_Booking__r.RW_Country_Phone_Code__c,RW_Booking__r.Opportunity__r.RW_Mobile_No__c,RW_Booking__r.Primary_Applicant_Email__c,RW_Booking__r.Primary_Applicant_Mobile__c FROM Loan__c WHERE Id =: loanIds]){
                if(ln.RW_Booking__c != null && ln.RW_Booking__r.Lockated_User_Device_ID__c != null && details.Message__c != null){
                    Set<String> deviceTokens = new Set<String>(ln.RW_Booking__r.Lockated_User_Device_ID__c.split(';'));
                    String message = ((details.Message__c.contains('{1}'))? details.Message__c.replace('{1}', (ln.RW_Booking__r.Primary_Applicant_Name__c != null)? ln.RW_Booking__r.Primary_Applicant_Name__c : 'Customer') : details.Message__c);
                    for(String token : deviceTokens){
                        App_Notification__c an = new App_Notification__c();
                        an.Booking__c = ln.RW_Booking__c;
                        an.Title__c = details.Title__c;
                        an.Message__c = message;
                        an.Notification_Type__c = details.Notification_Type__c;
                        an.Device_Token__c = token;
                        an.Record_Id__c = ln.Id;
                        notifications.add(an);
                    }
                }
                if(details.Whatsapp_Template_Name__c != null){
                    LockatedApp_WhatsappMsgQueueable.ParameterWrap wrap = LockatedApp_WhatsappMsgQueueable.wrapper(null,ln.RW_Booking__r.Primary_Applicant_Name__c,null,null,null,null,null,null,null,ln.RW_Booking__r.RW_Country_Phone_Code__c,ln.RW_Booking__r.Primary_Applicant_Mobile__c,details.Whatsapp_Template_Name__c); 
                    wrapList.add(wrap);
                }
                if(ln.RW_Booking__r.Primary_Applicant_Email__c != null && details.Email_Message__c != null){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new List<String>{ln.RW_Booking__r.Primary_Applicant_Email__c});
                    mail.setSubject(details.Email_Subject__c);
                    mail.setPlainTextBody(details.Email_Message__c);
                    emailList.add(mail);
                }
            }
        }
        if(notifications.size() > 0){
            insert notifications;
        }
        if(emailList.size() > 0){
            Messaging.SendEmailResult[] result = Messaging.sendEmail(emailList);
        }
        if(wrapList.size() > 0){
            //System.enqueueJob(new LockatedApp_WhatsappMsgQueueable(wrapList));
            Database.executeBatch(new LockatedApp_WhatsappMsgQueueable(wrapList), 10);
        }
    }
    
    public static void ncfNotification(List<String> bkgIds){
        List<Post_Sales_App_Notifications__mdt> ntfDetails = [SELECT Title__c,Message__c,Notification_Type__c,Email_Subject__c,Email_Message__c,Whatsapp_Template_Name__c,Active__c FROM Post_Sales_App_Notifications__mdt WHERE DeveloperName = 'Request_for_Name_Confirmation_Form' AND Active__c = true LIMIT 1];
        if(ntfDetails.size() > 0){
            Post_Sales_App_Notifications__mdt details = ntfDetails[0];
            List<RW_Welcome_Call__c> welcomecalls = [SELECT Id,RW_Booking__c,RW_Booking__r.Lockated_User_Device_ID__c,RW_Booking__r.Primary_Applicant_Name__c,RW_Booking__r.RW_Country_Phone_Code__c,RW_Booking__r.Opportunity__r.RW_Mobile_No__c,RW_Booking__r.Primary_Applicant_Email__c,RW_Booking__r.Primary_Applicant_Mobile__c FROM RW_Welcome_Call__c WHERE RW_Booking__c =: bkgIds AND RW_Booking__r.NCF_Status__c = 'Pending'];
            if(welcomecalls.size() > 0){
                List<App_Notification__c> notifications = new List<App_Notification__c>();
                List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
                List<LockatedApp_WhatsappMsgQueueable.ParameterWrap> wrapList = new List<LockatedApp_WhatsappMsgQueueable.ParameterWrap>();
                
                    for(RW_Welcome_Call__c wc : welcomecalls){
                        if(wc.RW_Booking__c != null && wc.RW_Booking__r.Lockated_User_Device_ID__c != null && details.Message__c != null){
                            Set<String> deviceTokens = new Set<String>(wc.RW_Booking__r.Lockated_User_Device_ID__c.split(';'));
                            String message = (details.Message__c != null)? details.Message__c.replace('{1}', (wc.RW_Booking__r.Primary_Applicant_Name__c != null)? wc.RW_Booking__r.Primary_Applicant_Name__c : 'Customer') : '';
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
                        if(details.Whatsapp_Template_Name__c != null){
                            LockatedApp_WhatsappMsgQueueable.ParameterWrap wrap = LockatedApp_WhatsappMsgQueueable.wrapper(null,wc.RW_Booking__r.Primary_Applicant_Name__c,null,null,null,null,null,null,null,wc.RW_Booking__r.RW_Country_Phone_Code__c,wc.RW_Booking__r.Primary_Applicant_Mobile__c,details.Whatsapp_Template_Name__c); 
                            wrapList.add(wrap);
                        }
                        if(wc.RW_Booking__r.Primary_Applicant_Email__c != null && details.Email_Message__c != null){
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            mail.setToAddresses(new List<String>{wc.RW_Booking__r.Primary_Applicant_Email__c});
                            mail.setSubject(details.Email_Subject__c);
                            mail.setPlainTextBody(details.Email_Message__c);
                            emailList.add(mail);
                        }
                    }
                
                if(notifications.size() > 0){
                insert notifications;
                }
                if(emailList.size() > 0){
                    Messaging.SendEmailResult[] result = Messaging.sendEmail(emailList);
                }
                if(wrapList.size() > 0){
                    //System.enqueueJob(new LockatedApp_WhatsappMsgQueueable(wrapList));
                    Database.executeBatch(new LockatedApp_WhatsappMsgQueueable(wrapList), 10);
                }
            }
        }
    }
    
    //Correspondence address updated in applicant details record  --> Applicant Details Trigger
    public static void correspondenceAddressChangeNotification(List<Id> applicantIds){
        List<App_Notification__c> notifications = new List<App_Notification__c>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<LockatedApp_WhatsappMsgQueueable.ParameterWrap> wrapList = new List<LockatedApp_WhatsappMsgQueueable.ParameterWrap>();
        List<Post_Sales_App_Notifications__mdt> ntfDetails = [SELECT Title__c,Message__c,Notification_Type__c,Email_Subject__c,Email_Message__c,Whatsapp_Template_Name__c,Active__c FROM Post_Sales_App_Notifications__mdt WHERE DeveloperName = 'Address_Change_Confirmation' AND Active__c = true LIMIT 1];
        if(ntfDetails.size() > 0){
            Post_Sales_App_Notifications__mdt details = ntfDetails[0];
            for(Applicant_Details__c app : [SELECT Id,Name,Email_Address__c,Booking__c,Booking__r.Lockated_User_Device_ID__c,Applicant_Number__c,Booking__r.RW_Country_Phone_Code__c,Booking__r.Opportunity__r.RW_Mobile_No__c,Booking__r.Primary_Applicant_Mobile__c FROM Applicant_Details__c WHERE Id =: applicantIds]){
                if(app.Booking__c != null && app.Booking__r.Lockated_User_Device_ID__c != null && details.Message__c != null){
                    Set<String> deviceTokens = new Set<String>(app.Booking__r.Lockated_User_Device_ID__c.split(';'));
                    String message = ((details.Message__c.contains('{1}'))? details.Message__c.replace('{1}', (app.Name != null)? app.Name : 'Customer') : details.Message__c);
                    for(String token : deviceTokens){
                        App_Notification__c an = new App_Notification__c();
                        an.Booking__c = app.Booking__c;
                        an.Title__c = details.Title__c;
                        an.Message__c = message;
                        an.Record_Id__c = app.Id;
                        an.Device_Token__c = token;
                        if(app.Applicant_Number__c == 'Primary Applicant'){
                            an.Notification_Type__c = 'primary';
                        }else{
                            an.Notification_Type__c = 'coapplicant';
                        }
                        notifications.add(an);
                    }
                }
                if(details.Whatsapp_Template_Name__c != null){
                    LockatedApp_WhatsappMsgQueueable.ParameterWrap wrap = LockatedApp_WhatsappMsgQueueable.wrapper(null,app.Name,null,null,null,null,null,null,null,app.Booking__r.RW_Country_Phone_Code__c,app.Booking__r.Primary_Applicant_Mobile__c,details.Whatsapp_Template_Name__c); 
                    wrapList.add(wrap);
                }
                if(app.Email_Address__c != null && details.Email_Message__c != null){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new List<String>{app.Email_Address__c});
                    mail.setSubject(details.Email_Subject__c);
                    mail.setPlainTextBody(details.Email_Message__c);
                    emailList.add(mail);
                }
            }
        }
        if(notifications.size() > 0){
            insert notifications;
        }
        if(emailList.size() > 0){
            Messaging.SendEmailResult[] result = Messaging.sendEmail(emailList);
        }
        if(wrapList.size() > 0){
            //System.enqueueJob(new LockatedApp_WhatsappMsgQueueable(wrapList));
            Database.executeBatch(new LockatedApp_WhatsappMsgQueueable(wrapList), 10);
        }
    }
    
    //Phone number updated in applicant details record  --> Applicant Details Trigger
    public static void phoneNumberChangeNotification(List<Id> applicantIds){
        List<App_Notification__c> notifications = new List<App_Notification__c>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<LockatedApp_WhatsappMsgQueueable.ParameterWrap> wrapList = new List<LockatedApp_WhatsappMsgQueueable.ParameterWrap>();
        List<Post_Sales_App_Notifications__mdt> ntfDetails = [SELECT Title__c,Message__c,Notification_Type__c,Email_Subject__c,Email_Message__c,Whatsapp_Template_Name__c,Active__c FROM Post_Sales_App_Notifications__mdt WHERE DeveloperName = 'Phone_Number_Change_Confirmation'  AND Active__c = true LIMIT 1];
        if(ntfDetails.size() > 0){
            Post_Sales_App_Notifications__mdt details = ntfDetails[0];
            for(Applicant_Details__c app : [SELECT Id,Name,Email_Address__c,Booking__c,Booking__r.Lockated_User_Device_ID__c,Applicant_Number__c,Booking__r.RW_Country_Phone_Code__c,Booking__r.Opportunity__r.RW_Mobile_No__c,Booking__r.Primary_Applicant_Mobile__c FROM Applicant_Details__c WHERE Id =: applicantIds]){
                if(app.Booking__c != null && app.Booking__r.Lockated_User_Device_ID__c != null && details.Message__c != null){
                    Set<String> deviceTokens = new Set<String>(app.Booking__r.Lockated_User_Device_ID__c.split(';'));
                    String message = ((details.Message__c.contains('{1}'))? details.Message__c.replace('{1}', (app.Name != null)? app.Name : 'Customer') : details.Message__c);
                    for(String token : deviceTokens){
                        App_Notification__c an = new App_Notification__c();
                        an.Booking__c = app.Booking__c;
                        an.Title__c = details.Title__c;
                        an.Message__c = message;
                        an.Record_Id__c = app.Id;
                        an.Device_Token__c = token;
                        if(app.Applicant_Number__c == 'Primary Applicant'){
                            an.Notification_Type__c = 'primary';
                        }else{
                            an.Notification_Type__c = 'coapplicant';
                        }
                        notifications.add(an);
                    }
                }
                if(details.Whatsapp_Template_Name__c != null){
                    LockatedApp_WhatsappMsgQueueable.ParameterWrap wrap = LockatedApp_WhatsappMsgQueueable.wrapper(null,app.Name,null,null,null,null,null,null,null,app.Booking__r.RW_Country_Phone_Code__c,app.Booking__r.Primary_Applicant_Mobile__c,details.Whatsapp_Template_Name__c); 
                    wrapList.add(wrap);
                }
                if(app.Email_Address__c != null && details.Email_Message__c != null){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new List<String>{app.Email_Address__c});
                    mail.setSubject(details.Email_Subject__c);
                    mail.setPlainTextBody(details.Email_Message__c);
                    emailList.add(mail);
                }
            }
        }
        if(notifications.size() > 0){
            insert notifications;
        }
        if(emailList.size() > 0){
            Messaging.SendEmailResult[] result = Messaging.sendEmail(emailList);
        }
        if(wrapList.size() > 0){
            //System.enqueueJob(new LockatedApp_WhatsappMsgQueueable(wrapList));
            Database.executeBatch(new LockatedApp_WhatsappMsgQueueable(wrapList), 10);
        }
    }
    
    //When Registration date added in booking record --> Booking Trigger
    public static void registrationCongratulatoryNotification(List<String> bkgIds){
        List<App_Notification__c> notifications = new List<App_Notification__c>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<LockatedApp_WhatsappMsgQueueable.ParameterWrap> wrapList = new List<LockatedApp_WhatsappMsgQueueable.ParameterWrap>();
        List<Post_Sales_App_Notifications__mdt> ntfDetails = [SELECT Title__c,Message__c,Notification_Type__c,Email_Subject__c,Email_Message__c,Whatsapp_Template_Name__c,Active__c FROM Post_Sales_App_Notifications__mdt WHERE DeveloperName = 'Registration_Completion'  AND Active__c = true LIMIT 1];
        if(ntfDetails.size() > 0){
            Post_Sales_App_Notifications__mdt details = ntfDetails[0];
            for(Booking__c bkg : [SELECT Id,Lockated_User_Device_ID__c,Primary_Applicant_Name__c,Primary_Applicant_Email__c,RW_Country_Phone_Code__c,Opportunity__r.RW_Mobile_No__c FROM Booking__c WHERE Id =: bkgIds]){
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
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new List<String>{bkg.Primary_Applicant_Email__c});
                    mail.setSubject(details.Email_Subject__c);
                    mail.setPlainTextBody(details.Email_Message__c);
                    emailList.add(mail);
                }
            }
        }
        if(notifications.size() > 0){
            insert notifications;
        }
        if(emailList.size() > 0){
            Messaging.SendEmailResult[] result = Messaging.sendEmail(emailList);
        }
        if(wrapList.size() > 0){
            //System.enqueueJob(new LockatedApp_WhatsappMsgQueueable(wrapList));
            Database.executeBatch(new LockatedApp_WhatsappMsgQueueable(wrapList), 10);
        }
    }
    
    //When SAP Receipt record created  --> Receipt Trigger
    public static void paymentDetailsNotification(List<Id> receiptIds){
        List<App_Notification__c> notifications = new List<App_Notification__c>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<LockatedApp_WhatsappMsgQueueable.ParameterWrap> wrapList = new List<LockatedApp_WhatsappMsgQueueable.ParameterWrap>();
        List<Post_Sales_App_Notifications__mdt> ntfDetails = [SELECT Title__c,Message__c,Notification_Type__c,Email_Subject__c,Email_Message__c,Whatsapp_Template_Name__c,Active__c FROM Post_Sales_App_Notifications__mdt WHERE DeveloperName = 'Payment_Details_Upload_Request'  AND Active__c = true LIMIT 1];
        if(ntfDetails.size() > 0){
            Post_Sales_App_Notifications__mdt details = ntfDetails[0];
            for(RW_Payment_Details__c rec : [SELECT Id,RW_Booking__c,RW_Booking__r.Lockated_User_Device_ID__c,RW_Booking__r.Primary_Applicant_Name__c,RW_Booking__r.Primary_Applicant_Email__c,RW_Booking__r.RW_Country_Phone_Code__c,RW_Booking__r.Primary_Applicant_Mobile__c FROM RW_Payment_Details__c WHERE Id =: receiptIds]){
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
                if(rec.RW_Booking__r.Primary_Applicant_Email__c != null && details.Email_Message__c != null){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new List<String>{rec.RW_Booking__r.Primary_Applicant_Email__c});
                    mail.setSubject(details.Email_Subject__c);
                    mail.setPlainTextBody(details.Email_Message__c);
                    emailList.add(mail);
                }
            }
        }
        if(notifications.size() > 0){
            insert notifications;
        }
        if(emailList.size() > 0){
            Messaging.SendEmailResult[] result = Messaging.sendEmail(emailList);
        }
        if(wrapList.size() > 0){
            Database.executeBatch(new LockatedApp_WhatsappMsgQueueable(wrapList), 10);
        }
    }
    
    //When Demand record created  --> Demand Trigger
    public static void demandNotification(List<Id> demandIds){
        List<App_Notification__c> notifications = new List<App_Notification__c>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<LockatedApp_WhatsappMsgQueueable.ParameterWrap> wrapList = new List<LockatedApp_WhatsappMsgQueueable.ParameterWrap>();
        List<Post_Sales_App_Notifications__mdt> ntfDetails = [SELECT Title__c,Message__c,Notification_Type__c,Email_Subject__c,Email_Message__c,Whatsapp_Template_Name__c,Active__c FROM Post_Sales_App_Notifications__mdt WHERE DeveloperName = 'Demand_Raised_Notification'  AND Active__c = true LIMIT 1];
        if(ntfDetails.size() > 0){
            Post_Sales_App_Notifications__mdt details = ntfDetails[0];
            for(RW_Demand__c dem : [SELECT Id,Booking__c,Booking__r.Lockated_User_Device_ID__c,Booking__r.Primary_Applicant_Name__c,Booking__r.RW_Country_Phone_Code__c,Booking__r.Opportunity__r.RW_Mobile_No__c,Booking__r.Primary_Applicant_Email__c,Booking__r.Primary_Applicant_Mobile__c FROM RW_Demand__c WHERE Id =: demandIds]){
                if(dem.Booking__r.Lockated_User_Device_ID__c != null && details.Message__c != null){
                    Set<String> deviceTokens = new Set<String>(dem.Booking__r.Lockated_User_Device_ID__c.split(';'));
                    String message = ((details.Message__c.contains('{1}'))? details.Message__c.replace('{1}', (dem.Booking__r.Primary_Applicant_Name__c != null)? dem.Booking__r.Primary_Applicant_Name__c : 'Customer') : details.Message__c);
                    for(String token : deviceTokens){
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
                if(details.Whatsapp_Template_Name__c != null){
                    LockatedApp_WhatsappMsgQueueable.ParameterWrap wrap = LockatedApp_WhatsappMsgQueueable.wrapper(null,dem.Booking__r.Primary_Applicant_Name__c,null,null,null,null,null,null,null,dem.Booking__r.RW_Country_Phone_Code__c,dem.Booking__r.Primary_Applicant_Mobile__c,details.Whatsapp_Template_Name__c); 
                    wrapList.add(wrap);
                }
                if(dem.Booking__r.Primary_Applicant_Email__c != null && details.Email_Message__c != null){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new List<String>{dem.Booking__r.Primary_Applicant_Email__c});
                    mail.setSubject(details.Email_Subject__c);
                    mail.setPlainTextBody(details.Email_Message__c);
                    emailList.add(mail);
                }
            }
        }
        if(notifications.size() > 0){
            insert notifications;
        }
        if(emailList.size() > 0){
            Messaging.SendEmailResult[] result = Messaging.sendEmail(emailList);
        }
        if(wrapList.size() > 0){
            Database.executeBatch(new LockatedApp_WhatsappMsgQueueable(wrapList), 10);
        }
    }
    
    public static void referralLeadCreatedNotification(List<Lead> leads){
        List<App_Notification__c> notifications = new List<App_Notification__c>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<LockatedApp_WhatsappMsgQueueable.ParameterWrap> wrapList = new List<LockatedApp_WhatsappMsgQueueable.ParameterWrap>();
        List<Id> accIds = new List<Id>();
        for(Lead ld : leads){
            accIds.add(ld.Customer_Reference__c);
        }
        List<Booking__c> bkgs = [SELECT Id,Lockated_User_Device_ID__c,Primary_Applicant_Name__c,RW_Country_Phone_Code__c,Opportunity__r.RW_Mobile_No__c,Primary_Applicant_Email__c,Primary_Applicant_Mobile__c FROM Booking__c WHERE Opportunity__r.AccountId =: accIds];
        List<Post_Sales_App_Notifications__mdt> ntfDetails = [SELECT Title__c,Message__c,Notification_Type__c,Email_Subject__c,Email_Message__c,Whatsapp_Template_Name__c,Active__c FROM Post_Sales_App_Notifications__mdt WHERE DeveloperName = 'Referral_Lead'  AND Active__c = true LIMIT 1];
        if(ntfDetails.size() > 0){
            Post_Sales_App_Notifications__mdt details = ntfDetails[0];
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
                if(details.Whatsapp_Template_Name__c != null){
                    LockatedApp_WhatsappMsgQueueable.ParameterWrap wrap = LockatedApp_WhatsappMsgQueueable.wrapper(null,bkg.Primary_Applicant_Name__c,null,null,null,null,null,null,null,bkg.RW_Country_Phone_Code__c,bkg.Primary_Applicant_Mobile__c,details.Whatsapp_Template_Name__c); 
                    wrapList.add(wrap);
                }
                if(bkg.Primary_Applicant_Email__c != null && details.Email_Message__c != null){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new List<String>{bkg.Primary_Applicant_Email__c});
                    mail.setSubject(details.Email_Subject__c);
                    String body = ((details.Email_Message__c.contains('{1}'))? details.Email_Message__c.replace('{1}', (bkg.Primary_Applicant_Name__c != null)? bkg.Primary_Applicant_Name__c : 'Customer') : details.Email_Message__c);
                    mail.setPlainTextBody(body);
                    emailList.add(mail);
                }
            }
        }
        if(notifications.size() > 0){
            insert notifications;
        }
        if(emailList.size() > 0){
            Messaging.SendEmailResult[] result = Messaging.sendEmail(emailList);
        }
        if(wrapList.size() > 0){
            //System.enqueueJob(new LockatedApp_WhatsappMsgQueueable(wrapList));
            Database.executeBatch(new LockatedApp_WhatsappMsgQueueable(wrapList), 10);
        }
    }
    
    public static void referralVisitDoneNotification(List<Opportunity> opportunities){
        List<App_Notification__c> notifications = new List<App_Notification__c>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<LockatedApp_WhatsappMsgQueueable.ParameterWrap> wrapList = new List<LockatedApp_WhatsappMsgQueueable.ParameterWrap>();
        Map<String, String> customerIdVsOppName = new Map<String, String>();
        List<Id> accIds = new List<Id>();
        List<Post_Sales_App_Notifications__mdt> ntfDetails = [SELECT Title__c,Message__c,Notification_Type__c,Email_Subject__c,Email_Message__c,Whatsapp_Template_Name__c,Active__c FROM Post_Sales_App_Notifications__mdt WHERE DeveloperName = 'Referral_Site_Visit'  AND Active__c = true LIMIT 1];
        if(ntfDetails.size() > 0){
            Post_Sales_App_Notifications__mdt details = ntfDetails[0];
            for(Opportunity opp : opportunities){
                accIds.add(opp.Customer_Reference__c);
                customerIdVsOppName.put(opp.Customer_Reference__c, opp.Name);
            }
            List<Booking__c> bkgs = [SELECT Id,Lockated_User_Device_ID__c,Primary_Applicant_Name__c,RW_Country_Phone_Code__c,Opportunity__r.RW_Mobile_No__c,Primary_Applicant_Email__c,Opportunity__r.AccountId,Primary_Applicant_Mobile__c FROM Booking__c WHERE Opportunity__r.AccountId =: accIds];
            
            for(Booking__c bkg : bkgs){
                if(bkg.Lockated_User_Device_ID__c != null && details.Message__c != null){
                    Set<String> deviceTokens = new Set<String>(bkg.Lockated_User_Device_ID__c.split(';'));
                    String message = details.Message__c;
                    if(message.contains('{1}')){
                        message = message.replace('{1}', (bkg.Primary_Applicant_Name__c != null)? bkg.Primary_Applicant_Name__c : 'Customer');
                        if(details.Message__c.contains('{2}')){
                            message = message.replace('{2}', (customerIdVsOppName.get(bkg.Opportunity__r.AccountId)!= null)? customerIdVsOppName.get(bkg.Opportunity__r.AccountId) : '');
                        }
                    }
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
                if(details.Whatsapp_Template_Name__c != null){
                    LockatedApp_WhatsappMsgQueueable.ParameterWrap wrap = LockatedApp_WhatsappMsgQueueable.wrapper(null,bkg.Primary_Applicant_Name__c,customerIdVsOppName.get(bkg.Opportunity__r.AccountId),null,null,null,null,null,null,bkg.RW_Country_Phone_Code__c,bkg.Primary_Applicant_Mobile__c,details.Whatsapp_Template_Name__c); 
                    wrapList.add(wrap);
                }
                if(bkg.Primary_Applicant_Email__c != null && details.Email_Message__c != null){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new List<String>{bkg.Primary_Applicant_Email__c});
                    mail.setSubject(details.Email_Subject__c);
                    String body = details.Email_Message__c;
                    if(body.contains('{1}')){
                        body = body.replace('{1}', (bkg.Primary_Applicant_Name__c != null)? bkg.Primary_Applicant_Name__c : 'Customer');
                        if(details.Message__c.contains('{2}')){
                            body = body.replace('{2}', (customerIdVsOppName.get(bkg.Opportunity__r.AccountId)!= null)? customerIdVsOppName.get(bkg.Opportunity__r.AccountId) : '');
                        }
                    }
                    mail.setPlainTextBody(body);
                    emailList.add(mail);
                }
            }
        }
        if(notifications.size() > 0){
            insert notifications;
        }
        if(emailList.size() > 0){
            Messaging.SendEmailResult[] result = Messaging.sendEmail(emailList);
        }
        if(wrapList.size() > 0){
            //System.enqueueJob(new LockatedApp_WhatsappMsgQueueable(wrapList));
            Database.executeBatch(new LockatedApp_WhatsappMsgQueueable(wrapList), 10);
        }
    }
    
    public static void referralBookingNotification(List<Id> bookingIds){
        List<App_Notification__c> notifications = new List<App_Notification__c>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<LockatedApp_WhatsappMsgQueueable.ParameterWrap> wrapList = new List<LockatedApp_WhatsappMsgQueueable.ParameterWrap>();
        List<Id> accIds = new List<Id>();
        Map<String, String> customerIdVsApplicantName = new Map<String, String>();
        List<Post_Sales_App_Notifications__mdt> ntfDetails = [SELECT Title__c,Message__c,Notification_Type__c,Email_Subject__c,Email_Message__c,Whatsapp_Template_Name__c,Active__c FROM Post_Sales_App_Notifications__mdt WHERE DeveloperName = 'Referral_Booking'  AND Active__c = true LIMIT 1];
        if(ntfDetails.size() > 0){
            Post_Sales_App_Notifications__mdt details = ntfDetails[0];
            for(Booking__c bkg : [SELECT Id,Customer_Reference__c,Opportunity__r.Customer_Reference__c,Primary_Applicant_Name__c FROM Booking__c WHERE Id =: bookingIds]){
                accIds.add(bkg.Opportunity__r.Customer_Reference__c);
                customerIdVsApplicantName.put(bkg.Opportunity__r.Customer_Reference__c, bkg.Primary_Applicant_Name__c);
            }
            List<Booking__c> bkgs = [SELECT Id,Lockated_User_Device_ID__c,Primary_Applicant_Name__c,RW_Country_Phone_Code__c,Opportunity__r.RW_Mobile_No__c,Opportunity__r.AccountId,Primary_Applicant_Email__c,Primary_Applicant_Mobile__c FROM Booking__c WHERE Opportunity__c != null AND Opportunity__r.AccountId =: accIds];
            
            for(Booking__c bkg : bkgs){
                if(bkg.Lockated_User_Device_ID__c != null && details.Message__c != null && details.Message__c != null){
                    Set<String> deviceTokens = new Set<String>(bkg.Lockated_User_Device_ID__c.split(';'));
                    String message = details.Message__c;
                    if(message.contains('{1}')){
                        message = message.replace('{1}', (bkg.Primary_Applicant_Name__c != null)? bkg.Primary_Applicant_Name__c : 'Customer');
                        if(message.contains('{2}')){
                            message = message.replace('{2}', (customerIdVsApplicantName.get(bkg.Opportunity__r.AccountId) != null)? customerIdVsApplicantName.get(bkg.Opportunity__r.AccountId) : '');
                        }
                    }
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
                LockatedApp_WhatsappMsgQueueable.ParameterWrap wrap = LockatedApp_WhatsappMsgQueueable.wrapper(null,bkg.Primary_Applicant_Name__c,customerIdVsApplicantName.get(bkg.Opportunity__r.AccountId),null,null,null,null,null,null,bkg.RW_Country_Phone_Code__c,bkg.Primary_Applicant_Mobile__c,details.Whatsapp_Template_Name__c); 
                wrapList.add(wrap);
                if(bkg.Primary_Applicant_Email__c != null && details.Email_Message__c != null){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new List<String>{bkg.Primary_Applicant_Email__c});
                    mail.setSubject(details.Email_Subject__c);
                    String body = details.Email_Message__c;
                    if(body.contains('{1}')){
                        body = body.replace('{1}', (bkg.Primary_Applicant_Name__c != null)? bkg.Primary_Applicant_Name__c : 'Customer');
                        if(body.contains('{2}')){
                            body = body.replace('{2}', (customerIdVsApplicantName.get(bkg.Opportunity__r.AccountId) != null)? customerIdVsApplicantName.get(bkg.Opportunity__r.AccountId) : '');
                        }
                    }
                    mail.setPlainTextBody(body);
                    emailList.add(mail);
                }
            }
        }
        if(notifications.size() > 0){
            insert notifications;
        }
        if(emailList.size() > 0){
            Messaging.SendEmailResult[] result = Messaging.sendEmail(emailList);
        }
        if(wrapList.size() > 0){
            //System.enqueueJob(new LockatedApp_WhatsappMsgQueueable(wrapList));
            Database.executeBatch(new LockatedApp_WhatsappMsgQueueable(wrapList), 10);
        }
    }
    
	public static void caseStatusChangedNotification(List<Case> cases){
        List<App_Notification__c> notifications = new List<App_Notification__c>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<LockatedApp_WhatsappMsgQueueable.ParameterWrap> wrapList = new List<LockatedApp_WhatsappMsgQueueable.ParameterWrap>();
        List<Id> oppIds = new List<Id>();
        for(Case cs : cases){
            oppIds.add(cs.Opportunity__c);
        }
        List<Post_Sales_App_Notifications__mdt> ntfDetails = [SELECT Title__c,Message__c,Notification_Type__c,Email_Subject__c,Email_Message__c,Whatsapp_Template_Name__c,Active__c FROM Post_Sales_App_Notifications__mdt WHERE DeveloperName = 'Service_Request_Update'  AND Active__c = true LIMIT 1];
        if(ntfDetails.size() > 0){
            Post_Sales_App_Notifications__mdt details = ntfDetails[0];
            for(Opportunity opp : [SELECT Id,RW_Email__c,Booking__r.Lockated_User_Device_ID__c,Booking__c,Booking__r.RW_Country_Phone_Code__c,RW_Mobile_No__c,Booking__r.Primary_Applicant_Mobile__c FROM Opportunity WHERE Id =: oppIds]){
                if(opp.Booking__r.Lockated_User_Device_ID__c != null && details.Message__c != null){
                    Set<String> deviceTokens = new Set<String>(opp.Booking__r.Lockated_User_Device_ID__c.split(';'));
                    for(String token : deviceTokens){
                        App_Notification__c an = new App_Notification__c();
                        an.Booking__c = opp.Booking__c;
                        an.Title__c = details.Title__c;
                        an.Message__c =  details.Message__c;
                        an.Notification_Type__c = details.Notification_Type__c;
                        an.Device_Token__c = token;
                        notifications.add(an);
                    }
                }
                if(details.Whatsapp_Template_Name__c != null){
                    LockatedApp_WhatsappMsgQueueable.ParameterWrap wrap = LockatedApp_WhatsappMsgQueueable.wrapper(null,null,null,null,null,null,null,null,null,opp.Booking__r.RW_Country_Phone_Code__c,opp.Booking__r.Primary_Applicant_Mobile__c,details.Whatsapp_Template_Name__c); 
                    wrapList.add(wrap);
                }
                if(opp.RW_Email__c != null && details.Email_Message__c != null){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new List<String>{opp.RW_Email__c});
                    mail.setSubject(details.Email_Subject__c);
                    mail.setPlainTextBody(details.Email_Message__c);
                    emailList.add(mail);
                }
            }
        }
        if(notifications.size() > 0){
            insert notifications;
        }
        if(emailList.size() > 0){
            Messaging.SendEmailResult[] result = Messaging.sendEmail(emailList);
        }
        if(wrapList.size() > 0){
            //System.enqueueJob(new LockatedApp_WhatsappMsgQueueable(wrapList));
            Database.executeBatch(new LockatedApp_WhatsappMsgQueueable(wrapList), 10);
        }
    }
    
    public static void caseCreatedNotification(List<Case> cases){
        List<App_Notification__c> notifications = new List<App_Notification__c>();
        List<LockatedApp_WhatsappMsgQueueable.ParameterWrap> wrapList = new List<LockatedApp_WhatsappMsgQueueable.ParameterWrap>();
        List<Id> oppIds = new List<Id>();
        for(Case cs : [SELECT Id,Opportunity__c FROM Case WHERE Id =: cases]){
            oppIds.add(cs.Opportunity__c);
        }
        List<Post_Sales_App_Notifications__mdt> ntfDetails = [SELECT Title__c,Message__c,Notification_Type__c,Email_Subject__c,Email_Message__c,Whatsapp_Template_Name__c,Active__c FROM Post_Sales_App_Notifications__mdt WHERE DeveloperName = 'Service_Request_Created'  AND Active__c = true LIMIT 1];
        if(ntfDetails.size() > 0){
            Post_Sales_App_Notifications__mdt details = ntfDetails[0];
            for(Opportunity opp : [SELECT Id, Booking__r.Lockated_User_Device_ID__c,Booking__c,Booking__r.RW_Country_Phone_Code__c,RW_Mobile_No__c,Booking__r.Primary_Applicant_Mobile__c FROM Opportunity WHERE Id =: oppIds]){
                if(opp.Booking__r.Lockated_User_Device_ID__c != null && details.Message__c != null){
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
                if(details.Whatsapp_Template_Name__c != null){
                    LockatedApp_WhatsappMsgQueueable.ParameterWrap wrap = LockatedApp_WhatsappMsgQueueable.wrapper(null,null,null,null,null,null,null,null,null,opp.Booking__r.RW_Country_Phone_Code__c,opp.Booking__r.Primary_Applicant_Mobile__c,details.Whatsapp_Template_Name__c); 
                    wrapList.add(wrap);
                }
            }
        }
        if(notifications.size() > 0){
            insert notifications;
        }
        if(wrapList.size() > 0){
            //System.enqueueJob(new LockatedApp_WhatsappMsgQueueable(wrapList));
            Database.executeBatch(new LockatedApp_WhatsappMsgQueueable(wrapList), 10);
        }
    }
    
    public static void keyHandoverNotification(List<String> bkgIds){
        List<App_Notification__c> notifications = new List<App_Notification__c>();
        List<LockatedApp_WhatsappMsgQueueable.ParameterWrap> wrapList = new List<LockatedApp_WhatsappMsgQueueable.ParameterWrap>();
        List<Post_Sales_App_Notifications__mdt> ntfDetailsPossessionKeyHandover = [SELECT Title__c,Message__c,Notification_Type__c,Email_Subject__c,Email_Message__c,Whatsapp_Template_Name__c,Active__c FROM Post_Sales_App_Notifications__mdt WHERE DeveloperName = 'Possession_Key_Handover'  AND Active__c = true LIMIT 1];
        List<Post_Sales_App_Notifications__mdt> ntfDetailsPossessionCongratulatory = [SELECT Title__c,Message__c,Notification_Type__c,Email_Subject__c,Email_Message__c,Whatsapp_Template_Name__c,Active__c FROM Post_Sales_App_Notifications__mdt WHERE DeveloperName = 'Possession_Congratulatory'  AND Active__c = true LIMIT 1];

        Post_Sales_App_Notifications__mdt detailsPossessionKeyHandover = (ntfDetailsPossessionKeyHandover.size() > 0)? ntfDetailsPossessionKeyHandover[0] : null;
        Post_Sales_App_Notifications__mdt detailsPossessionCongratulatory = (ntfDetailsPossessionCongratulatory.size() > 0)? ntfDetailsPossessionCongratulatory[0] : null;
        for(Booking__c bkg : [SELECT Id,Lockated_User_Device_ID__c,Primary_Applicant_Name__c,Opportunity__r.Account.Country_Code__c,Opportunity__r.RW_Mobile_No__c,Unit_No__c,Unit_No__r.Name,Primary_Applicant_Mobile__c,RW_Country_Phone_Code__c FROM Booking__c WHERE Id =: bkgIds]){
            if(bkg.Lockated_User_Device_ID__c != null){
                Set<String> deviceTokens = new Set<String>(bkg.Lockated_User_Device_ID__c.split(';'));
                for(String token : deviceTokens){
                    if(detailsPossessionKeyHandover != null && detailsPossessionKeyHandover.Message__c != null){
                        App_Notification__c an = new App_Notification__c();
                        an.Booking__c = bkg.Id;
                        an.Title__c = detailsPossessionKeyHandover.Title__c;
                        an.Message__c = ((detailsPossessionKeyHandover.Message__c.contains('{1}'))? detailsPossessionKeyHandover.Message__c.replace('{1}', (bkg.Primary_Applicant_Name__c != null)? bkg.Primary_Applicant_Name__c : 'Customer') : detailsPossessionKeyHandover.Message__c);
                        an.Notification_Type__c = detailsPossessionKeyHandover.Notification_Type__c;
                        an.Device_Token__c = token;
                        notifications.add(an);
                    }
                    
                    if(detailsPossessionCongratulatory != null && detailsPossessionCongratulatory.Message__c != null){
                        App_Notification__c an2 = new App_Notification__c();
                        an2.Booking__c = bkg.Id;
                        an2.Title__c = detailsPossessionCongratulatory.Title__c;
                        String message = detailsPossessionCongratulatory.Message__c;
                        if(message.contains('{1}')){
                            message = message.replace('{1}', (bkg.Primary_Applicant_Name__c != null)? bkg.Primary_Applicant_Name__c : 'Customer');
                            if(message.contains('{2}')){
                                message = message.replace('{2}', (bkg.Unit_No__c != null)? bkg.Unit_No__r.Name : '');
                                if(message.contains('{3}')){
                                    message = message.replace('{3}', (bkg.Unit_No__c != null)? bkg.Unit_No__r.Name : '');
                                }
                            }
                        }
                        an2.Message__c = message;
                        an2.Notification_Type__c = detailsPossessionCongratulatory.Notification_Type__c;
                        an2.Device_Token__c = token;
                        notifications.add(an2);
                    }
                    
                }
            }
            if(detailsPossessionKeyHandover != null && detailsPossessionKeyHandover.Whatsapp_Template_Name__c != null){
                LockatedApp_WhatsappMsgQueueable.ParameterWrap wrap = LockatedApp_WhatsappMsgQueueable.wrapper(null,bkg.Primary_Applicant_Name__c,null,null,null,null,null,null,null,bkg.RW_Country_Phone_Code__c,bkg.Primary_Applicant_Mobile__c,detailsPossessionKeyHandover.Whatsapp_Template_Name__c); 
                wrapList.add(wrap);
            }
        }
        if(notifications.size() > 0){
            insert notifications;
        }
        if(wrapList.size() > 0){
            //System.enqueueJob(new LockatedApp_WhatsappMsgQueueable(wrapList));
            Database.executeBatch(new LockatedApp_WhatsappMsgQueueable(wrapList), 10);
        }
    }
    
    public static void agreementReceivedNotification(List<Booking__c> bkgs){
        List<App_Notification__c> notifications = new List<App_Notification__c>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<LockatedApp_WhatsappMsgQueueable.ParameterWrap> wrapList = new List<LockatedApp_WhatsappMsgQueueable.ParameterWrap>();
        List<Post_Sales_App_Notifications__mdt> ntfDetails = [SELECT Title__c,Message__c,Notification_Type__c,Email_Subject__c,Email_Message__c,Whatsapp_Template_Name__c,Active__c FROM Post_Sales_App_Notifications__mdt WHERE DeveloperName = 'Agreement_Document_Ready'  AND Active__c = true LIMIT 1];
        if(ntfDetails.size() > 0){
            Post_Sales_App_Notifications__mdt details = ntfDetails[0];
            for(Booking__c bkg : [SELECT Id,Lockated_User_Device_ID__c,Primary_Applicant_Name__c,Opportunity__r.Account.Country_Code__c,Opportunity__r.RW_Mobile_No__c,Primary_Applicant_Email__c,Primary_Applicant_Mobile__c,RW_Country_Phone_Code__c  FROM Booking__c WHERE Id =: bkgs]){
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
                if(details.Whatsapp_Template_Name__c != null){
                    LockatedApp_WhatsappMsgQueueable.ParameterWrap wrap = LockatedApp_WhatsappMsgQueueable.wrapper(null,bkg.Primary_Applicant_Name__c,null,null,null,null,null,null,null,bkg.RW_Country_Phone_Code__c,bkg.Primary_Applicant_Mobile__c,details.Whatsapp_Template_Name__c); 
                    wrapList.add(wrap);
                }
                if(bkg.Primary_Applicant_Email__c != null && details.Email_Message__c != null){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new List<String>{bkg.Primary_Applicant_Email__c});
                    mail.setSubject(details.Email_Subject__c);
                    mail.setPlainTextBody(details.Email_Message__c);
                    emailList.add(mail);
                }
            }
        }
        if(notifications.size() > 0){
            insert notifications;
        }
        if(emailList.size() > 0){
            Messaging.SendEmailResult[] result = Messaging.sendEmail(emailList);
        }
        if(wrapList.size() > 0){
            //System.enqueueJob(new LockatedApp_WhatsappMsgQueueable(wrapList));
            Database.executeBatch(new LockatedApp_WhatsappMsgQueueable(wrapList), 10);
        }
    }
    
    public static void rmChangedNotification(Set<Id> unitIds){
        List<App_Notification__c> notifications = new List<App_Notification__c>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<LockatedApp_WhatsappMsgQueueable.ParameterWrap> wrapList = new List<LockatedApp_WhatsappMsgQueueable.ParameterWrap>();
        List<Post_Sales_App_Notifications__mdt> ntfDetails = [SELECT Title__c,Message__c,Notification_Type__c,Email_Subject__c,Email_Message__c,Whatsapp_Template_Name__c,Active__c FROM Post_Sales_App_Notifications__mdt WHERE DeveloperName = 'Relationship_Manager_Change'  AND Active__c = true LIMIT 1];
        if(ntfDetails.size() > 0){
            Post_Sales_App_Notifications__mdt details = ntfDetails[0];
            for(Project_Unit__c unit : [SELECT Id,Booking__r.Lockated_User_Device_ID__c,Booking__r.Primary_Applicant_Name__c,Relationship_Manager__r.Name,Booking__r.Opportunity__r.Account.Country_Code__c,Booking__r.Opportunity__r.RW_Mobile_No__c,Booking__r.Primary_Applicant_Email__c,Booking__r.Primary_Applicant_Mobile__c,Booking__r.RW_Country_Phone_Code__c FROM Project_Unit__c WHERE Id =: unitIds]){
                if(unit.Booking__r.Lockated_User_Device_ID__c != null && details.Message__c != null){
                    Set<String> deviceTokens = new Set<String>(unit.Booking__r.Lockated_User_Device_ID__c.split(';'));
                    String message = details.Message__c;
                    if(message.contains('{1}')){
                        message = message.replace('{1}', (unit.Booking__r.Primary_Applicant_Name__c != null)? unit.Booking__r.Primary_Applicant_Name__c : 'Customer');
                        if(message.contains('{2}')){
                            message = message.replace('{2}', (unit.Relationship_Manager__r.Name != null)? unit.Relationship_Manager__r.Name : '');
                        }
                    }
                    for(String token : deviceTokens){
                        App_Notification__c an = new App_Notification__c();
                        an.Booking__c = unit.Booking__c;
                        an.Title__c = details.Title__c;
                        an.Message__c = message;
                        an.Notification_Type__c = details.Notification_Type__c;
                        an.Device_Token__c = token;
                        notifications.add(an);
                    }
                }
                if(details.Whatsapp_Template_Name__c != null){
                    LockatedApp_WhatsappMsgQueueable.ParameterWrap wrap = LockatedApp_WhatsappMsgQueueable.wrapper(null,unit.Booking__r.Primary_Applicant_Name__c,unit.Relationship_Manager__r.Name,null,null,null,null,null,null,unit.Booking__r.RW_Country_Phone_Code__c,unit.Booking__r.Primary_Applicant_Mobile__c,details.Whatsapp_Template_Name__c); 
                    wrapList.add(wrap);
                }
                if(unit.Booking__r.Primary_Applicant_Email__c != null && details.Email_Message__c != null){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new List<String>{unit.Booking__r.Primary_Applicant_Email__c});
                    mail.setSubject(details.Email_Subject__c);
                    String body = details.Email_Message__c;
                    if(body.contains('{1}')){
                        body = body.replace('{1}', (unit.Booking__r.Primary_Applicant_Name__c != null)? unit.Booking__r.Primary_Applicant_Name__c : 'Customer');
                        if(body.contains('{2}')){
                            body = body.replace('{2}', (unit.Relationship_Manager__r.Name != null)? unit.Relationship_Manager__r.Name : '');
                        }
                    }
                    mail.setPlainTextBody(body);
                    emailList.add(mail);
                }
            }
        }
        if(notifications.size() > 0){
            insert notifications;
        }
        if(emailList.size() > 0){
            Messaging.SendEmailResult[] result = Messaging.sendEmail(emailList);
        }
        if(wrapList.size() > 0){
            //System.enqueueJob(new LockatedApp_WhatsappMsgQueueable(wrapList));
            Database.executeBatch(new LockatedApp_WhatsappMsgQueueable(wrapList), 10);
        }
    }
    
    public static void caseClosedNotification(List<Id> casesIds){
        List<App_Notification__c> notifications = new List<App_Notification__c>();
        List<Id> oppIds = new List<Id>();
        Map<String, Case> oppIdVsCase = new Map<String, Case>();
        List<Post_Sales_App_Notifications__mdt> ntfDetails = [SELECT Title__c,Message__c,Notification_Type__c,Email_Subject__c,Email_Message__c,Whatsapp_Template_Name__c,Active__c FROM Post_Sales_App_Notifications__mdt WHERE DeveloperName = 'Case_Closed'  AND Active__c = true LIMIT 1];
        if(ntfDetails.size() > 0){
            Post_Sales_App_Notifications__mdt details = ntfDetails[0];
            for(Case cs : [SELECT Id,Opportunity__c,OwnerId,Owner.Name FROM Case WHERE Id =: casesIds]){
                oppIds.add(cs.Opportunity__c);
                oppIdVsCase.put(cs.Opportunity__c, cs);
            }
            
            for(Opportunity opp : [SELECT Id, Booking__r.Lockated_User_Device_ID__c,Booking__c FROM Opportunity WHERE Id =: oppIds]){
                if(opp.Booking__r.Lockated_User_Device_ID__c != null && details.Message__c != null){
                    Set<String> deviceTokens = new Set<String>(opp.Booking__r.Lockated_User_Device_ID__c.split(';'));
                    
                    String message = details.Message__c;
                    if(message.contains('{1}')){
                        message = message.replace('{1}', (oppIdVsCase != null && oppIdVsCase.get(opp.Id) != null && !Test.isRunningTest())? oppIdVsCase.get(opp.Id).Owner.Name : '');
                        if(message.contains('{2}')){
                            message.replace('{2}', System.label.Site_Url_New + '/csat/CaseFeedbackForm?id=' + oppIdVsCase.get(opp.Id).Id);
                        }
                    }
                    for(String token : deviceTokens){
                        App_Notification__c an = new App_Notification__c();
                        an.Booking__c = opp.Booking__c;
                        an.Title__c = details.Title__c;
                        an.Message__c = message;
                        an.Notification_Type__c = details.Notification_Type__c;
                        an.Device_Token__c = token;
                        notifications.add(an);
                    }
                }
            }
        }
        if(notifications.size() > 0){
            insert notifications;
        }
    }
    
    public static void reminderLetterTaskNotification(List<Task> tasks){
        List<App_Notification__c> notifications = new List<App_Notification__c>();
        List<Id> oppIds = new List<Id>();
        for(Task tsk : tasks){
            if(tsk.WhatId.getSObjectType().getDescribe().getName() == 'Opportunity'){
                oppIds.add(tsk.WhatId);
            }
        }
        List<Post_Sales_App_Notifications__mdt> ntfDetails = [SELECT Title__c,Message__c,Notification_Type__c,Email_Subject__c,Email_Message__c,Whatsapp_Template_Name__c,Active__c FROM Post_Sales_App_Notifications__mdt WHERE DeveloperName = 'Reminder_Letter'  AND Active__c = true LIMIT 1];
        if(ntfDetails.size() > 0){
            Post_Sales_App_Notifications__mdt details = ntfDetails[0];
            for(Opportunity opp : [SELECT Id, Booking__r.Lockated_User_Device_ID__c,Booking__c FROM Opportunity WHERE Id =: oppIds]){
                if(opp.Booking__r.Lockated_User_Device_ID__c != null && details.Message__c != null){
                    Set<String> deviceTokens = new Set<String>(opp.Booking__r.Lockated_User_Device_ID__c.split(';'));
                    for(String token : deviceTokens){
                        App_Notification__c an = new App_Notification__c();
                        an.Booking__c = opp.Booking__c;
                        an.Title__c = details.Title__c;
                        an.Message__c =  details.Message__c;
                        an.Notification_Type__c = details.Notification_Type__c;
                        an.Device_Token__c = token;
                        notifications.add(an);
                    }
                }
            }
        }
        if(notifications.size() > 0){
            insert notifications;
        }
    }
    
    public static void possessionGuidelinesNotification(List<Booking__c> bkgs){
        List<App_Notification__c> notifications = new List<App_Notification__c>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<LockatedApp_WhatsappMsgQueueable.ParameterWrap> wrapList = new List<LockatedApp_WhatsappMsgQueueable.ParameterWrap>();
        List<Post_Sales_App_Notifications__mdt> ntfDetails = [SELECT Title__c,Message__c,Notification_Type__c,Email_Subject__c,Email_Message__c,Whatsapp_Template_Name__c,Active__c FROM Post_Sales_App_Notifications__mdt WHERE DeveloperName = 'Possession_Guidelines'  AND Active__c = true LIMIT 1];
        if(ntfDetails.size() > 0){
            Post_Sales_App_Notifications__mdt details = ntfDetails[0];
            for(Booking__c bkg : bkgs){
                if(bkg.Lockated_User_Device_ID__c != null && details.Message__c != null){
                    Set<String> deviceTokens = new Set<String>(bkg.Lockated_User_Device_ID__c.split(';'));
                    for(String token : deviceTokens){
                        App_Notification__c an = new App_Notification__c();
                        an.Booking__c = bkg.Id;
                        an.Title__c = details.Title__c;
                        an.Message__c = details.Message__c;
                        an.Notification_Type__c = details.Notification_Type__c;
                        an.Device_Token__c = token;
                        notifications.add(an);
                    }
                }
                if(bkg.Primary_Applicant_Email__c != null && details.Email_Message__c != null){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new List<String>{bkg.Primary_Applicant_Email__c});
                    mail.setSubject(details.Email_Subject__c);
                    mail.setPlainTextBody(details.Email_Message__c);
                    emailList.add(mail);
                }
            }
        }
        if(notifications.size() > 0){
            insert notifications;
        }
        if(emailList.size() > 0){
            Messaging.SendEmailResult[] result = Messaging.sendEmail(emailList);
        }
        if(wrapList.size() > 0){
            //System.enqueueJob(new LockatedApp_WhatsappMsgQueueable(wrapList));
            Database.executeBatch(new LockatedApp_WhatsappMsgQueueable(wrapList), 10);
        }
    }
    
    public static void loanDocSubmissionNotification(List<Id> loanIds){
        List<App_Notification__c> notifications = new List<App_Notification__c>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<LockatedApp_WhatsappMsgQueueable.ParameterWrap> wrapList = new List<LockatedApp_WhatsappMsgQueueable.ParameterWrap>();
        List<Post_Sales_App_Notifications__mdt> ntfDetails = [SELECT Title__c,Message__c,Notification_Type__c,Email_Subject__c,Email_Message__c,Whatsapp_Template_Name__c,Active__c FROM Post_Sales_App_Notifications__mdt WHERE DeveloperName = 'Loan_Documentation_Submission_Reminder'  AND Active__c = true LIMIT 1];
        if(ntfDetails.size() > 0){
            Post_Sales_App_Notifications__mdt details = ntfDetails[0];
            List<Loan__c> loans = [SELECT Id,RW_Booking__c,RW_Booking__r.Lockated_User_Device_ID__c,RW_Booking__r.Primary_Applicant_Name__c,RW_Booking__r.RW_Country_Phone_Code__c,RW_Booking__r.Opportunity__r.RW_Mobile_No__c,RW_Booking__r.Primary_Applicant_Email__c,RW_Booking__r.Primary_Applicant_Mobile__c FROM Loan__c WHERE Id =: loanIds];
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
                if(details.Whatsapp_Template_Name__c != null){
                    LockatedApp_WhatsappMsgQueueable.ParameterWrap wrap = LockatedApp_WhatsappMsgQueueable.wrapper(null,ln.RW_Booking__r.Primary_Applicant_Name__c,null,null,null,null,null,null,null,ln.RW_Booking__r.RW_Country_Phone_Code__c,ln.RW_Booking__r.Primary_Applicant_Mobile__c,details.Whatsapp_Template_Name__c); 
                    wrapList.add(wrap);
                }
                //System.enqueueJob(new LockatedApp_WhatsappMsgQueueable(wrap));
                if(ln.RW_Booking__r.Primary_Applicant_Email__c != null && details.Email_Message__c != null){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new List<String>{ln.RW_Booking__r.Primary_Applicant_Email__c});
                    mail.setSubject(details.Email_Subject__c);
                    mail.setPlainTextBody(details.Email_Message__c);
                    emailList.add(mail);
                }
            }
        }
        if(notifications.size() > 0){
            insert notifications;
        }
        if(emailList.size() > 0){
            Messaging.SendEmailResult[] result = Messaging.sendEmail(emailList);
        }
        if(wrapList.size() > 0){
            //System.enqueueJob(new LockatedApp_WhatsappMsgQueueable(wrapList));
            Database.executeBatch(new LockatedApp_WhatsappMsgQueueable(wrapList), 10);
        }
    }
}