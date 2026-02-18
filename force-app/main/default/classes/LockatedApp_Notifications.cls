public class LockatedApp_Notifications {
    
    public static Map<Id, Id> bkgIdVsLoanId;
    public static Map<Id, Date> bkgIdVsLogInDate = new Map<Id, Date>();
    
    //When Booking Confirmed  --> Booking Trigger
    public static void bookingConfirmedNotification(List<String> bkgIds){
        List<App_Notification__c> notifications = new List<App_Notification__c>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        for(Booking__c bkg : [SELECT Id,Lockated_User_Device_ID__c,Primary_Applicant_Name__c,Primary_Applicant_Email__c,RW_Country_Phone_Code__c,Opportunity__r.RW_Mobile_No__c FROM Booking__c WHERE Id =: bkgIds]){
            if(bkg.Lockated_User_Device_ID__c != null){
                List<String> deviceTokens = bkg.Lockated_User_Device_ID__c.split(';');
                String message = 'Dear ' + bkg.Primary_Applicant_Name__c + ',\n Thank you for booking with Runwal Enterprises! Your booking details are available on your Runwal app, email & WhatsApp. Stay updated at every step. For support, contact us anytime.';
                for(String token : deviceTokens){
                    App_Notification__c an = new App_Notification__c();
                    an.Booking__c = bkg.Id;
                    an.Title__c = 'Booking Confirmation';
                    an.Message__c = message;
                    an.Notification_Type__c = 'my_account';
                    an.Device_Token__c = token;
                    notifications.add(an);
                }
            }
            SendWhatsAppMsg.methodToSendWhatsAppMsg(null,bkg.Primary_Applicant_Name__c,null,null,null,null,null,null,null,bkg.RW_Country_Phone_Code__c, bkg.Opportunity__r.RW_Mobile_No__c,'Booking Details'); 
            if(bkg.Primary_Applicant_Email__c != null){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<String>{bkg.Primary_Applicant_Email__c});
                mail.setSubject('Booking Confirmation');
                String body = 'Dear Customer, <br/><br/>';
                body += 'Greetings from Runwal Enterprises!! <br/>';
                body += 'Thank you for booking with Runwal Enterprises! Your booking has been successfully recorded. Details including Tower, Unit, Phase, Project, Typology, Booking Date, Amount Value, Payment Schedule, and Amount Paid are now available on your Runwal app, email, and WhatsApp. Stay updated with every step of your journey. Please refer the below mentioned links to the Tutorials for your reference.  Should you have questions or require support, please reach out to us at any time. We are committed to ensuring a seamless experience for you.<br/><br/>';
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
    
    //When Booking Confirmed  --> Booking Trigger
    public static void homeLoanNotification(List<String> bkgIds){
        List<App_Notification__c> notifications = new List<App_Notification__c>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        for(Booking__c bkg : [SELECT Id,Lockated_User_Device_ID__c,Primary_Applicant_Name__c,Primary_Applicant_Email__c,RW_Country_Phone_Code__c,Opportunity__r.RW_Mobile_No__c FROM Booking__c WHERE Id =: bkgIds]){
            if(bkg.Lockated_User_Device_ID__c != null){
                List<String> deviceTokens = bkg.Lockated_User_Device_ID__c.split(';');
                String message = 'Dear ' + bkg.Primary_Applicant_Name__c + ',\n Your home loan details, brochures, and benefits of Runwal home loans are now accessible on the Runwal app, WhatsApp & email. For queries, our home loan team is here to assist you.';
                for(String token : deviceTokens){
                    App_Notification__c an = new App_Notification__c();
                    an.Booking__c = bkg.Id;
                    an.Title__c = 'Home Loan Notification';
                    an.Message__c = message;
                    an.Notification_Type__c = 'loan_assistance';
                    an.Device_Token__c = token;
                    notifications.add(an);
                }
            }
            if(bkg.Primary_Applicant_Email__c != null){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<String>{bkg.Primary_Applicant_Email__c});
                mail.setSubject('Home Loan Notification');
                String body = 'Dear Customer, <br/><br/>';
                body += 'Greetings from Runwal Enterprises!! <br/>';
                body += 'At Runwal Enterprises, we prioritize making your home loan journey easy. You can now access your home loan notification details, including brochures and benefits of opting for a Runwal home loan, via the Runwal app, WhatsApp, and email. Additionally, contact details of our home loan representatives are provided to guide you through the process. Should you have any queries regarding your home loan status or application, please don\'t hesitate to contact our team.<br/><br/>';
                mail.setHtmlBody(body);
                emailList.add(mail);
            }
            SendWhatsAppMsg.methodToSendWhatsAppMsg(null,bkg.Primary_Applicant_Name__c,null,null,null,null,null,null,null,bkg.RW_Country_Phone_Code__c, bkg.Opportunity__r.RW_Mobile_No__c,'Home Loan Notification'); 
        }
        if(notifications.size() > 0){
            insert notifications;
        }
        //createNotification(bkgIds, 'HOME LOAN', 'Home Loan', 'loan_assistance', '', null);
    }
    
    //When Sanction Date is updated in Loan record --> Loan Trigger
    public static void sanctionStatusNotification(List<Id> loanIds){
        List<App_Notification__c> notifications = new List<App_Notification__c>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        for(Loan__c ln : [SELECT Id,RW_Booking__c,RW_Booking__r.Lockated_User_Device_ID__c,RW_Booking__r.Primary_Applicant_Name__c,RW_Booking__r.RW_Country_Phone_Code__c,RW_Booking__r.Opportunity__r.RW_Mobile_No__c,RW_Booking__r.Primary_Applicant_Email__c FROM Loan__c WHERE Id =: loanIds]){
            if(ln.RW_Booking__c != null && ln.RW_Booking__r.Lockated_User_Device_ID__c != null){
                List<String> deviceTokens = ln.RW_Booking__r.Lockated_User_Device_ID__c.split(';');
                String message = 'Dear ' + ln.RW_Booking__r.Primary_Applicant_Name__c + ',\n Your home loan sanction has been approved and updated in our system. View details on the Runwal app. For any clarifications, our home loan team is ready to assist you.';
                for(String token : deviceTokens){
                    App_Notification__c an = new App_Notification__c();
                    an.Booking__c = ln.RW_Booking__c;
                    an.Title__c = 'Home Loan Sanction Approved';
                    an.Message__c = message;
                    an.Notification_Type__c = 'my_loan';
                    an.Device_Token__c = token;
                    an.Record_Id__c = ln.Id;
                    notifications.add(an);
                }
            }
            SendWhatsAppMsg.methodToSendWhatsAppMsg(null,ln.RW_Booking__r.Primary_Applicant_Name__c,null,null,null,null,null,null,null,ln.RW_Booking__r.RW_Country_Phone_Code__c,ln.RW_Booking__r.Opportunity__r.RW_Mobile_No__c,'Home Loan Sanction Approved'); 
            if(ln.RW_Booking__r.Primary_Applicant_Email__c != null){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<String>{ln.RW_Booking__r.Primary_Applicant_Email__c});
                mail.setSubject('Home Loan Sanction Approved');
                String body = 'Dear Customer, <br/><br/>';
                body += 'Greetings from Runwal Enterprises!! <br/>';
                body += 'We are pleased to inform you that the sanction for your home loan application has been approved and updated in our system. You can now view your sanction details, including sanctioned amount and next steps, easily on your Runwal app,  Should you need clarifications or support, our home loan team is here to assist you.<br/><br/>';
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
        //createNotification(bkgIds, 'SANCTION STATUS', 'Sanction Status', 'my_loan', '', null);
    }
    
    public static void ncfNotification(List<String> bkgIds){
        //Date dt = Date.today() - 3;
        List<RW_Welcome_Call__c> welcomecalls = [SELECT Id,RW_Booking__c,RW_Booking__r.Lockated_User_Device_ID__c,RW_Booking__r.Primary_Applicant_Name__c,RW_Booking__r.RW_Country_Phone_Code__c,RW_Booking__r.Opportunity__r.RW_Mobile_No__c,RW_Booking__r.Primary_Applicant_Email__c FROM RW_Welcome_Call__c WHERE RW_Booking__c =: bkgIds AND RW_Booking__r.NCF_Status__c = 'Pending'];
        if(welcomecalls.size() > 0){
            List<App_Notification__c> notifications = new List<App_Notification__c>();
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
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
                SendWhatsAppMsg.methodToSendWhatsAppMsg(null,wc.RW_Booking__r.Primary_Applicant_Name__c,null,null,null,null,null,null,null,wc.RW_Booking__r.RW_Country_Phone_Code__c,wc.RW_Booking__r.Opportunity__r.RW_Mobile_No__c,'NCF Request'); 
                if(wc.RW_Booking__r.Primary_Applicant_Email__c != null){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new List<String>{wc.RW_Booking__r.Primary_Applicant_Email__c});
                    mail.setSubject('Request for Name Confirmation Form (NCF)');
                    String body = 'Dear Customer, <br/><br/>';
                    body += 'Greetings from Runwal Enterprises!! <br/>';
                    body += 'Congratulations on your booking , in order to further process towards registration we request you to kindly share your \'Name Confirmation Form\'  within the next 5 days  in order for us to update the records.<br/><br/>';
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
    
    //Correspondence address updated in applicant details record  --> Applicant Details Trigger
    public static void correspondenceAddressChangeNotification(List<Id> applicantIds){
        List<App_Notification__c> notifications = new List<App_Notification__c>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        for(Applicant_Details__c app : [SELECT Id,Name,Email_Address__c,Booking__c,Booking__r.Lockated_User_Device_ID__c,Applicant_Number__c,Booking__r.RW_Country_Phone_Code__c,Booking__r.Opportunity__r.RW_Mobile_No__c FROM Applicant_Details__c WHERE Id =: applicantIds]){
            if(app.Booking__c != null && app.Booking__r.Lockated_User_Device_ID__c != null){
                List<String> deviceTokens = app.Booking__r.Lockated_User_Device_ID__c.split(';');
                String message = 'Dear ' + app.Name + ',\n Your address change request has been updated successfully with OTP verification. Confirmation sent on your mobile, email & WhatsApp. Contact support if you notice any issues.';
                for(String token : deviceTokens){
                    App_Notification__c an = new App_Notification__c();
                    an.Booking__c = app.Booking__c;
                    an.Title__c = 'Address Change Confirmation';
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
            SendWhatsAppMsg.methodToSendWhatsAppMsg(null,app.Name,null,null,null,null,null,null,null,app.Booking__r.RW_Country_Phone_Code__c,app.Booking__r.Opportunity__r.RW_Mobile_No__c,'Address Change Confirmation'); 
            if(app.Email_Address__c != null){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<String>{app.Email_Address__c});
                mail.setSubject('Address Change Confirmation');
                String body = 'Dear Customer, <br/><br/>';
                body += 'Greetings from Runwal Enterprises!! <br/>';
                body += 'Your request for a change of address has been successfully received and updated in our system. We have sent a confirmation notification to your registered mobile number, email ID, and via WhatsApp. For security, a two-step OTP verification process was used to validate this change. Should you notice any discrepancy or need further assistance, please contact our customer care immediately. Thank you for trusting Runwal Enterprises.<br/><br/>';
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
    
    //Phone number updated in applicant details record  --> Applicant Details Trigger
    public static void phoneNumberChangeNotification(List<Id> applicantIds){
        List<App_Notification__c> notifications = new List<App_Notification__c>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        for(Applicant_Details__c app : [SELECT Id,Name,Email_Address__c,Booking__c,Booking__r.Lockated_User_Device_ID__c,Applicant_Number__c,Booking__r.RW_Country_Phone_Code__c,Booking__r.Opportunity__r.RW_Mobile_No__c FROM Applicant_Details__c WHERE Id =: applicantIds]){
            if(app.Booking__c != null && app.Booking__r.Lockated_User_Device_ID__c != null){
                List<String> deviceTokens = app.Booking__r.Lockated_User_Device_ID__c.split(';');
                String message = 'Dear ' + app.Name + ',\n Your phone number has been updated successfully with OTP verification. Confirmation sent on your new number, email & WhatsApp. Contact Runwal support if you did not authorize this change.';
                for(String token : deviceTokens){
                    App_Notification__c an = new App_Notification__c();
                    an.Booking__c = app.Booking__c;
                    an.Title__c = 'Phone Number Change Confirmation';
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
            SendWhatsAppMsg.methodToSendWhatsAppMsg(null,app.Name,null,null,null,null,null,null,null,app.Booking__r.RW_Country_Phone_Code__c,app.Booking__r.Opportunity__r.RW_Mobile_No__c,'Phone Number Change Confirmation'); 
            if(app.Email_Address__c != null){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<String>{app.Email_Address__c});
                mail.setSubject('Phone Number Change Confirmation');
                String body = 'Dear Customer, <br/><br/>';
                body += 'Greetings from Runwal Enterprises!! <br/>';
                body += 'Your phone number change request has been successfully processed. We have sent a confirmation message to your new registered mobile number as well as your email and WhatsApp. This change was validated through an OTP-based two-step verification to ensure account security. If you did not authorize this request or require assistance, please contact Runwal customer support promptly.<br/><br/>';
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
    
    //When Registration date added in booking record --> Booking Trigger
    public static void registrationCongratulatoryNotification(List<String> bkgIds){
        List<App_Notification__c> notifications = new List<App_Notification__c>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        for(Booking__c bkg : [SELECT Id,Lockated_User_Device_ID__c,Primary_Applicant_Name__c,Primary_Applicant_Email__c,RW_Country_Phone_Code__c,Opportunity__r.RW_Mobile_No__c FROM Booking__c WHERE Id =: bkgIds]){
            if(bkg.Lockated_User_Device_ID__c != null){
                List<String> deviceTokens = bkg.Lockated_User_Device_ID__c.split(';');
                String message= 'Dear ' + bkg.Primary_Applicant_Name__c + ',\nOn this special day we would like to congratulate you on the successful registration of your purchased unit.';
                for(String token : deviceTokens){
                    App_Notification__c an = new App_Notification__c();
                    an.Booking__c = bkg.Id;
                    an.Title__c = 'Successful Completion of Registration';
                    an.Message__c = message;
                    an.Notification_Type__c = 'booking_overview';
                    an.Device_Token__c = token;
                    notifications.add(an);
                }
            }
            if(bkg.Primary_Applicant_Email__c != null){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<String>{bkg.Primary_Applicant_Email__c});
                mail.setSubject('Successful Completion of Registration');
                String body = 'Dear Customer, <br/><br/>';
                body += 'Greetings from Runwal Enterprises!! <br/>';
                body += 'On this special day we would like to congratulate you on the successful registration of your purchased unit. We wish you continued success and happiness & look forward to handing over your dream home in due course.<br/><br/>';
                mail.setHtmlBody(body);
                emailList.add(mail);
            }
            SendWhatsAppMsg.methodToSendWhatsAppMsg(null,bkg.Primary_Applicant_Name__c,null,null,null,null,null,null,null,bkg.RW_Country_Phone_Code__c,bkg.Opportunity__r.RW_Mobile_No__c,'Registration Date Entry'); 
        }
        if(notifications.size() > 0){
            insert notifications;
        }
        if(emailList.size() > 0){
            Messaging.SendEmailResult[] result = Messaging.sendEmail(emailList);
        }
    }
    
    //When SAP Receipt record created  --> Receipt Trigger
    public static void paymentDetailsNotification(List<Id> receiptIds){
        List<App_Notification__c> notifications = new List<App_Notification__c>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        for(RW_Payment_Details__c rec : [SELECT Id,RW_Booking__c,RW_Booking__r.Lockated_User_Device_ID__c,RW_Booking__r.Primary_Applicant_Name__c,RW_Booking__r.Primary_Applicant_Email__c FROM RW_Payment_Details__c WHERE Id =: receiptIds]){
            if(rec.RW_Booking__c != null && rec.RW_Booking__r.Lockated_User_Device_ID__c != null){
                List<String> deviceTokens = rec.RW_Booking__r.Lockated_User_Device_ID__c.split(';');
                String message = 'Dear ' + rec.RW_Booking__r.Primary_Applicant_Name__c + ',\n Kindly upload your payment details on the Runwal app to complete verification and receive your receipt.  Please find the link to upload the transaction details/UTR';
                for(String token : deviceTokens){
                    App_Notification__c an = new App_Notification__c();
                    an.Booking__c = rec.RW_Booking__c;
                    an.Title__c = 'Payment Details Upload Request';
                    an.Message__c = message;
                    an.Notification_Type__c = 'payments_received';
                    an.Record_Id__c = rec.Id;
                    an.Device_Token__c = token;
                    notifications.add(an);
                }
            }
            if(rec.RW_Booking__r.Primary_Applicant_Email__c != null){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<String>{rec.RW_Booking__r.Primary_Applicant_Email__c});
                mail.setSubject('Payment Details Upload Request');
                String body = 'Dear Customer, <br/><br/>';
                body += 'Greetings from Runwal Enterprises!! <br/>';
                body += 'Please note once you make the payment, please upload the transaction details on the Runwal Connect App or alternatively share it with your relationship manager to help them to trace your payment and share the payment receipt within 3 working days.<br/><br/>';
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
        //createNotification(bkgIds, 'PAYMENT DETAILS UPLOAD', 'Payment details uploaded', 'payments_received', receiptId, null);
    }
    
    //When Demand record created  --> Demand Trigger
    public static void tdsPaymentGuideNotification(List<Id> demandIds){
        List<App_Notification__c> notifications = new List<App_Notification__c>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        for(RW_Demand__c dem : [SELECT Id,Booking__c,Booking__r.Lockated_User_Device_ID__c,Booking__r.Primary_Applicant_Name__c,Booking__r.RW_Country_Phone_Code__c,Booking__r.Opportunity__r.RW_Mobile_No__c,Booking__r.Primary_Applicant_Email__c FROM RW_Demand__c WHERE Id =: demandIds]){
            if(dem.Booking__c != null && dem.Booking__r.Lockated_User_Device_ID__c != null){
                List<String> deviceTokens = dem.Booking__r.Lockated_User_Device_ID__c.split(';');
                String message = 'Dear ' + dem.Booking__r.Primary_Applicant_Name__c + ',\n Please upload your TDS Form 16b and 26QB together on the app';
                for(String token : deviceTokens){
                    App_Notification__c an = new App_Notification__c();
                    an.Booking__c = dem.Booking__c;
                    an.Title__c = 'TDS Form Upload Reminder';
                    an.Message__c = message;
                    an.Notification_Type__c = 'tds';
                    an.Record_Id__c = System.label.TDS_Tutorial_Link; 
                    an.Device_Token__c = token;
                    notifications.add(an);
                }
            }
            SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(null,dem.Booking__r.Primary_Applicant_Name__c,null,null,null,null,null,null,null,dem.Booking__r.RW_Country_Phone_Code__c,dem.Booking__r.Opportunity__r.RW_Mobile_No__c,'TDS Form Upload Reminder'); 
            if(dem.Booking__r.Primary_Applicant_Email__c != null){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<String>{dem.Booking__r.Primary_Applicant_Email__c});
                mail.setSubject('TDS Form Upload Reminder');
                String body = 'Dear Customer, <br/><br/>';
                body += 'Greetings from Runwal Enterprises!! <br/>';
                body += 'Kindly upload TDS Form 16b and 26QB together on the app.<br/><br/>';
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
    
    //When Demand record created  --> Demand Trigger
    public static void demandNotification(List<Id> demandIds){
        List<App_Notification__c> notifications = new List<App_Notification__c>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        for(RW_Demand__c dem : [SELECT Id,Booking__c,Booking__r.Lockated_User_Device_ID__c,Booking__r.Primary_Applicant_Name__c,Booking__r.RW_Country_Phone_Code__c,Booking__r.Opportunity__r.RW_Mobile_No__c,Booking__r.Primary_Applicant_Email__c FROM RW_Demand__c WHERE Id =: demandIds]){
            if(dem.Booking__r.Lockated_User_Device_ID__c != null){
                List<String> deviceTokens = dem.Booking__r.Lockated_User_Device_ID__c.split(';');
                String message = 'Dear ' + dem.Booking__r.Primary_Applicant_Name__c + ',\n Your payment demand has been raised for your unit with amount and due date. Please pay on or before due date. If bank-funded, please coordinate with your banker for disbursement. Please upload payment details within 3 days via app or share with RM.';
                for(String token : deviceTokens){
                    App_Notification__c an = new App_Notification__c();
                    an.Booking__c = dem.Booking__c;
                    an.Title__c = 'Demand Raised Notification';
                    an.Message__c = message;
                    an.Notification_Type__c = 'payments_due';
                    an.Record_Id__c = dem.Id;
                    an.Device_Token__c = token;
                    notifications.add(an);
                }
            }
            if(dem.Booking__r.Primary_Applicant_Email__c != null){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<String>{dem.Booking__r.Primary_Applicant_Email__c});
                mail.setSubject('Demand Raised Notification');
                String body = 'Dear Customer, <br/><br/>';
                body += 'Greetings from Runwal Enterprises!! <br/>';
                body += 'We would like to inform you that your demand has been raised towards your unit with the amount and due date . Please find attached demand letter. Request you to kindly make your payment on or before the due date.<br/><br/>';
                body += 'Incase if you are taking disbursement through your loaning bank, please do get in touch with your banker and share a consent as per their process to disburse monies before the due date. <br/><br/>';
                body += 'Please note once you make the payment, please upload the transaction details on the Runwal Connect App or alternatively share it with your relationship manager to help them to trace your payment and share the payment receipt within 3 working days. <br/><br/>';
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
    
    //When Credit Note receipt created  --> Receipt Trigger
    public static void creditNoteNotification(List<Id> receiptIds){
        List<App_Notification__c> notifications = new List<App_Notification__c>();
        for(RW_Payment_Details__c rec : [SELECT Id,RW_Booking__c,RW_Booking__r.Lockated_User_Device_ID__c FROM RW_Payment_Details__c WHERE Id =: receiptIds]){
            if(rec.RW_Booking__r.Lockated_User_Device_ID__c != null){
                List<String> deviceTokens = rec.RW_Booking__r.Lockated_User_Device_ID__c.split(';');
                for(String token : deviceTokens){
                    App_Notification__c an = new App_Notification__c();
                    an.Booking__c = rec.RW_Booking__c;
                    an.Title__c = 'CREDIT NOTE';
                    an.Message__c = 'Credit Note';
                    an.Notification_Type__c = 'loyalty';
                    an.Record_Id__c = rec.Id;
                    an.Device_Token__c = token;
                    notifications.add(an);
                }
            }
        }
        if(notifications.size() > 0){
            insert notifications;
        }
        //createNotification(bkgIds, 'CREDIT NOTE', 'Credit Note', 'loyalty', receiptId, null);
    }
    
    public static void referralLeadCreatedNotification(List<Lead> leads){
        List<App_Notification__c> notifications = new List<App_Notification__c>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<Id> accIds = new List<Id>();
        for(Lead ld : leads){
            accIds.add(ld.Customer_Reference__c);
        }
        List<Booking__c> bkgs = [SELECT Id,Lockated_User_Device_ID__c,Primary_Applicant_Name__c,RW_Country_Phone_Code__c,Opportunity__r.RW_Mobile_No__c,Primary_Applicant_Email__c FROM Booking__c WHERE Opportunity__r.AccountId =: accIds];
        for(Booking__c bkg : bkgs){
            if(bkg.Lockated_User_Device_ID__c != null){
                List<String> deviceTokens = bkg.Lockated_User_Device_ID__c.split(';');
                String message = 'Dear ' + bkg.Primary_Applicant_Name__c + ',\n We sincerely appreciate you referring your friends/family to Runwal Group. Your trust means the world to us, and we look forward to delivering the same quality and service to your referrals as you have experienced. Thank you for helping us grow the Runwal family!';
                for(String token : deviceTokens){
                    App_Notification__c an = new App_Notification__c();
                    an.Booking__c = bkg.Id;
                    an.Title__c = 'Thank You for Sharing Your Referral with Runwal Group';
                    an.Message__c = message;
                    an.Notification_Type__c = 'my_refferals';
                    an.Device_Token__c = token;
                    notifications.add(an);
                }
            }
            SendWhatsAppMsg.methodToSendWhatsAppMsg(null,bkg.Primary_Applicant_Name__c,null,null,null,null,null,null,null,bkg.RW_Country_Phone_Code__c,bkg.Opportunity__r.RW_Mobile_No__c,'Referral Lead Creation'); 
            if(bkg.Primary_Applicant_Email__c != null){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<String>{bkg.Primary_Applicant_Email__c});
                mail.setSubject('Thank You for Sharing Your Referral with Runwal Enterprises');
                String body = 'Dear ' + bkg.Primary_Applicant_Name__c + ', <br/><br/>';
                body += 'We sincerely appreciate you referring your friends/family to Runwal Enterprises. Your trust means the world to us, and we look forward to delivering the same quality and service to your referrals as you have experienced. <br/><br/>';
                body += 'Thank you for helping us grow the Runwal family! <br/><br/>';
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
    
    public static void referralVisitDoneNotification(List<Opportunity> opportunities){
        List<App_Notification__c> notifications = new List<App_Notification__c>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Map<String, String> customerIdVsOppName = new Map<String, String>();
        List<Id> accIds = new List<Id>();
        for(Opportunity opp : opportunities){
            accIds.add(opp.Customer_Reference__c);
            customerIdVsOppName.put(opp.Customer_Reference__c, opp.Name);
        }
        List<Booking__c> bkgs = [SELECT Id,Lockated_User_Device_ID__c,Primary_Applicant_Name__c,RW_Country_Phone_Code__c,Opportunity__r.RW_Mobile_No__c,Primary_Applicant_Email__c,Opportunity__r.AccountId FROM Booking__c WHERE Opportunity__r.AccountId =: accIds];
        for(Booking__c bkg : bkgs){
            if(bkg.Lockated_User_Device_ID__c != null){
                List<String> deviceTokens = bkg.Lockated_User_Device_ID__c.split(';');
                String message = 'Dear ' + bkg.Primary_Applicant_Name__c + ',\n We wanted to let you know that your referral, ' + customerIdVsOppName.get(bkg.Opportunity__r.AccountId) + ', recently visited our project site. Our team is assisting them with all the necessary details to help them find their perfect home. Thank you once again for your valued referral!';
                for(String token : deviceTokens){
                    App_Notification__c an = new App_Notification__c();
                    an.Booking__c = bkg.Id;
                    an.Title__c = 'Your Referral Has Visited Our Project';
                    an.Message__c = message;
                    an.Notification_Type__c = 'my_refferals';
                    an.Device_Token__c = token;
                    notifications.add(an);
                }
            }
            SendWhatsAppMsg.methodToSendWhatsAppMsg(null,bkg.Primary_Applicant_Name__c,customerIdVsOppName.get(bkg.Opportunity__r.AccountId),null,null,null,null,null,null,bkg.RW_Country_Phone_Code__c,bkg.Opportunity__r.RW_Mobile_No__c,'Referral Site Visit'); 
            if(bkg.Primary_Applicant_Email__c != null){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<String>{bkg.Primary_Applicant_Email__c});
                mail.setSubject('Your Referral Has Visited Our Project');
                String body = 'Dear ' + bkg.Primary_Applicant_Name__c + ', <br/><br/>';
                body += 'We wanted to let you know that your referral, ' + customerIdVsOppName.get(bkg.Opportunity__r.AccountId) + ', recently visited our project site. Our team is assisting them with all the necessary details to help them find their perfect home. <br/><br/>';
                body += 'Thank you once again for your valued referral! <br/><br/>';
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
    
    public static void referralBookingNotification(List<Id> bookingIds){
        List<App_Notification__c> notifications = new List<App_Notification__c>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<Id> accIds = new List<Id>();
        Map<String, String> customerIdVsApplicantName = new Map<String, String>();
        for(Booking__c bkg : [SELECT Id,Customer_Reference__c,Opportunity__r.Customer_Reference__c,Primary_Applicant_Name__c FROM Booking__c WHERE Id =: bookingIds]){
            accIds.add(bkg.Opportunity__r.Customer_Reference__c);
            customerIdVsApplicantName.put(bkg.Opportunity__r.Customer_Reference__c, bkg.Primary_Applicant_Name__c);
        }
        List<Booking__c> bkgs = [SELECT Id,Lockated_User_Device_ID__c,Primary_Applicant_Name__c,RW_Country_Phone_Code__c,Opportunity__r.RW_Mobile_No__c,Opportunity__r.AccountId FROM Booking__c WHERE Opportunity__r.AccountId =: accIds];
        for(Booking__c bkg : bkgs){
            if(bkg.Lockated_User_Device_ID__c != null){
                List<String> deviceTokens = bkg.Lockated_User_Device_ID__c.split(';');
                String message = 'Dear ' + bkg.Primary_Applicant_Name__c + ',\n We are thrilled to share that your referral, ' + customerIdVsApplicantName.get(bkg.Opportunity__r.AccountId) + ', has successfully booked a flat with Runwal Group! Your support in connecting us with valued customers is truly appreciated. Thank you for being a part of our journey.';
                for(String token : deviceTokens){
                    App_Notification__c an = new App_Notification__c();
                    an.Booking__c = bkg.Id;
                    an.Title__c = 'Exciting News: Your Referral Has Booked a Flat!';
                    an.Message__c = message;
                    an.Notification_Type__c = 'my_refferals';
                    an.Device_Token__c = token;
                    notifications.add(an);
                }
            }
            SendWhatsAppMsg.methodToSendWhatsAppMsg(null,bkg.Primary_Applicant_Name__c,customerIdVsApplicantName.get(bkg.Opportunity__r.AccountId),null,null,null,null,null,null,bkg.RW_Country_Phone_Code__c,bkg.Opportunity__r.RW_Mobile_No__c,'Referral Booking Done'); 
            if(bkg.Primary_Applicant_Email__c != null){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<String>{bkg.Primary_Applicant_Email__c});
                mail.setSubject('Exciting News: Your Referral Has Booked a Flat!');
                String body = 'Dear ' + bkg.Primary_Applicant_Name__c + ', <br/><br/>';
                body += 'We are thrilled to share that your referral, ' + customerIdVsApplicantName.get(bkg.Opportunity__r.AccountId) + ', has successfully booked a flat with Runwal Enterprises! Your support in connecting us with valued customers is truly appreciated. <br/><br/>';
                body += 'Thank you for being a part of our journey. <br/><br/>';
                body += 'Best regards,<br/>Runwal Enterprises';
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
    
	public static void caseStatusChangedNotification(List<Case> cases){
        List<App_Notification__c> notifications = new List<App_Notification__c>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<Id> oppIds = new List<Id>();
        for(Case cs : cases){
            oppIds.add(cs.Opportunity__c);
        }
        for(Opportunity opp : [SELECT Id,RW_Email__c,Booking__r.Lockated_User_Device_ID__c,Booking__c,Booking__r.RW_Country_Phone_Code__c,RW_Mobile_No__c FROM Opportunity WHERE Id =: oppIds]){
            if(opp.Booking__r.Lockated_User_Device_ID__c != null){
                List<String> deviceTokens = opp.Booking__r.Lockated_User_Device_ID__c.split(';');
                String message = 'Dear Customer,\n Greetings from Runwal Enterprises !!!\n The status of your service request has been updated. Please check your Runwal app for detailed updates and next steps.';
                for(String token : deviceTokens){
                    App_Notification__c an = new App_Notification__c();
                    an.Booking__c = opp.Booking__c;
                    an.Title__c = 'Service Request Update';
                    an.Message__c = message;
                    an.Notification_Type__c = 'service_request';
                    an.Device_Token__c = token;
                    notifications.add(an);
                }
            }
            SendWhatsAppMsg.methodToSendWhatsAppMsg(null,null,null,null,null,null,null,null,null,opp.Booking__r.RW_Country_Phone_Code__c,opp.RW_Mobile_No__c,'Service Request Update'); 
            if(opp.RW_Email__c != null){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<String>{opp.RW_Email__c});
                mail.setSubject('Service Request Update');
                String body = 'Dear Customer, <br/><br/>';
                body += 'Greetings from Runwal Enterprises !!! <br/>';
                body += 'The status of your service request has been updated. Please check your Runwal app for detailed updates and next steps.<br/><br/>';
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
    
    public static void caseCreatedNotification(List<Case> cases){
        List<App_Notification__c> notifications = new List<App_Notification__c>();
        List<Id> oppIds = new List<Id>();
        for(Case cs : cases){
            oppIds.add(cs.Opportunity__c);
        }
        for(Opportunity opp : [SELECT Id, Booking__r.Lockated_User_Device_ID__c,Booking__c,Booking__r.RW_Country_Phone_Code__c,RW_Mobile_No__c FROM Opportunity WHERE Id =: oppIds]){
            if(opp.Booking__r.Lockated_User_Device_ID__c != null){
                List<String> deviceTokens = opp.Booking__r.Lockated_User_Device_ID__c.split(';');
                String message = 'Dear Customer,\n Greetings from Runwal Enterprises !!!\n Your service request has been logged successfully. Our team will get back to you within 3 business days. Track status on your Runwal app.';
                for(String token : deviceTokens){
                    App_Notification__c an = new App_Notification__c();
                    an.Booking__c = opp.Booking__c;
                    an.Title__c = 'Service Request Created';
                    an.Message__c = message;
                    an.Notification_Type__c = 'service_request';
                    an.Device_Token__c = token;
                    notifications.add(an);
                }
            }
            SendWhatsAppMsg.methodToSendWhatsAppMsg(null,null,null,null,null,null,null,null,null,opp.Booking__r.RW_Country_Phone_Code__c,opp.RW_Mobile_No__c,'Service Request Created'); 
        }
        if(notifications.size() > 0){
            insert notifications;
        }
    }
    
    public static void keyHandoverNotification(List<String> bkgIds){
        List<App_Notification__c> notifications = new List<App_Notification__c>();
        for(Booking__c bkg : [SELECT Id,Lockated_User_Device_ID__c,Primary_Applicant_Name__c,Opportunity__r.Account.Country_Code__c,Opportunity__r.RW_Mobile_No__c FROM Booking__c WHERE Id =: bkgIds]){
            if(bkg.Lockated_User_Device_ID__c != null){
                List<String> deviceTokens = bkg.Lockated_User_Device_ID__c.split(';');
                String message = 'Dear ' + bkg.Primary_Applicant_Name__c + ',\n Greetings from Runwal Group. On this special day we would like to extend our best wishes on the successful handover of your dream home. We thank you once again for being a part of the Runwal Family and wish you continued success and happiness.';
                for(String token : deviceTokens){
                    App_Notification__c an = new App_Notification__c();
                    an.Booking__c = bkg.Id;
                    an.Title__c = 'POSSESSION KEY HANDOVER';
                    an.Message__c = message;
                    an.Notification_Type__c = 'home';
                    an.Device_Token__c = token;
                    notifications.add(an);
                }
            }
            SendWhatsAppMsg.methodToSendWhatsAppMsg(null,bkg.Primary_Applicant_Name__c,null,null,null,null,null,null,null,bkg.Opportunity__r.Account.Country_Code__c,bkg.Opportunity__r.RW_Mobile_No__c,'Possession Done Alert');
        }
        if(notifications.size() > 0){
            insert notifications;
        }
    }
    
    public static void agreementReceivedNotification(List<Booking__c> bkgs){
        List<App_Notification__c> notifications = new List<App_Notification__c>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        for(Booking__c bkg : [SELECT Id,Lockated_User_Device_ID__c,Primary_Applicant_Name__c,Opportunity__r.Account.Country_Code__c,Opportunity__r.RW_Mobile_No__c FROM Booking__c WHERE Id =: bkgs]){
            if(bkg.Lockated_User_Device_ID__c != null){
                List<String> deviceTokens = bkg.Lockated_User_Device_ID__c.split(';');
                String message = 'Dear ' + bkg.Primary_Applicant_Name__c + ',\n Your agreement document is ready for collection at the site office. Please visit at your convenience.';
                for(String token : deviceTokens){
                    App_Notification__c an = new App_Notification__c();
                    an.Booking__c = bkg.Id;
                    an.Title__c = 'Agreement Document Ready';
                    an.Message__c = message;
                    an.Notification_Type__c = 'final_agreement';
                    an.Device_Token__c = token;
                    notifications.add(an);
                }
            }
            SendWhatsAppMsg.methodToSendWhatsAppMsg(null,bkg.Primary_Applicant_Name__c,null,null,null,null,null,null,null,bkg.Opportunity__r.Account.Country_Code__c,bkg.Opportunity__r.RW_Mobile_No__c,'Agreement Document Ready');
            if(bkg.Primary_Applicant_Email__c != null){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<String>{bkg.Primary_Applicant_Email__c});
                mail.setSubject('Agreement Document Ready');
                String body = 'Dear ' + bkg.Primary_Applicant_Name__c + ', <br/><br/>';
                body += 'Greetings from Runwal Enterprises !!! <br/>';
                body += 'We are pleased to inform you that your agreement document is now ready for collection at the site office. <br/>Please visit the site office at your earliest convenience to collect your agreement.<br/><br/>';
                body += 'Thank you for choosing Runwal Enterprises. <br/>';
                body += 'Best regards,<br/> Runwal Enterprises <br/><br/>';
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
    
    public static void rmChangedNotification(Set<Id> unitIds){
        List<App_Notification__c> notifications = new List<App_Notification__c>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        for(Project_Unit__c unit : [SELECT Id,Booking__r.Lockated_User_Device_ID__c,Booking__r.Primary_Applicant_Name__c,Relationship_Manager__r.Name,Booking__r.Opportunity__r.Account.Country_Code__c,Booking__r.Opportunity__r.RW_Mobile_No__c,Booking__r.Primary_Applicant_Email__c FROM Project_Unit__c WHERE Id =: unitIds]){
            if(unit.Booking__r.Lockated_User_Device_ID__c != null){
                List<String> deviceTokens = unit.Booking__r.Lockated_User_Device_ID__c.split(';');
                String message = 'Dear ' + unit.Booking__r.Primary_Applicant_Name__c + ',\n Your Relationship Manager is updated to ' + unit.Relationship_Manager__r.Name + '. For any queries, please contact us.';
                for(String token : deviceTokens){
                    App_Notification__c an = new App_Notification__c();
                    an.Booking__c = unit.Booking__c;
                    an.Title__c = 'Relationship Manager Change';
                    an.Message__c = message;
                    an.Notification_Type__c = 'contact_rm';
                    an.Device_Token__c = token;
                    notifications.add(an);
                }
            }
            SendWhatsAppMsg.methodToSendWhatsAppMsg(null,unit.Booking__r.Primary_Applicant_Name__c,unit.Relationship_Manager__r.Name,null,null,null,null,null,null,unit.Booking__r.Opportunity__r.Account.Country_Code__c,unit.Booking__r.Opportunity__r.RW_Mobile_No__c,'Relationship Manager Change');
            if(unit.Booking__r.Primary_Applicant_Email__c != null){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<String>{unit.Booking__r.Primary_Applicant_Email__c});
                mail.setSubject('Update: Your Relationship Manager Has Changed');
                String body = 'Dear ' + unit.Booking__r.Primary_Applicant_Name__c + ', <br/><br/>';
                body += 'Greetings from Runwal Enterprises !!! <br/>';
                body += 'We would like to inform you that your Relationship Manager has been updated. Your new RM is ' + unit.Relationship_Manager__r.Name + ', who will assist you going forward. <br/>If you have any questions, please feel free to reach out.<br/><br/>';
                body += 'Thank you for your continued trust in Runwal Group. <br/>';
                body += 'Warm regards,<br/> Runwal Group <br/><br/>';
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
    
    public static void caseClosedNotification(List<Case> cases){
        List<App_Notification__c> notifications = new List<App_Notification__c>();
        List<Id> oppIds = new List<Id>();
        for(Case cs : cases){
            oppIds.add(cs.Opportunity__c);
        }
        for(Opportunity opp : [SELECT Id, Booking__r.Lockated_User_Device_ID__c,Booking__c FROM Opportunity WHERE Id =: oppIds]){
            if(opp.Booking__r.Lockated_User_Device_ID__c != null){
                List<String> deviceTokens = opp.Booking__r.Lockated_User_Device_ID__c.split(';');
                for(String token : deviceTokens){
                    App_Notification__c an = new App_Notification__c();
                    an.Booking__c = opp.Booking__c;
                    an.Title__c = 'CASE CLOSED';
                    an.Message__c = 'Case Closed';
                    an.Notification_Type__c = '';
                    an.Device_Token__c = token;
                    notifications.add(an);
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
        for(Opportunity opp : [SELECT Id, Booking__r.Lockated_User_Device_ID__c,Booking__c FROM Opportunity WHERE Id =: oppIds]){
            if(opp.Booking__r.Lockated_User_Device_ID__c != null){
                List<String> deviceTokens = opp.Booking__r.Lockated_User_Device_ID__c.split(';');
                for(String token : deviceTokens){
                    App_Notification__c an = new App_Notification__c();
                    an.Booking__c = opp.Booking__c;
                    an.Title__c = 'REMINDER NOTICE';
                    an.Message__c = 'Reminder Letter';
                    an.Notification_Type__c = 'reminder_letter';
                    an.Device_Token__c = token;
                    notifications.add(an);
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
        for(Booking__c bkg : bkgs){
            if(bkg.Lockated_User_Device_ID__c != null){
                List<String> deviceTokens = bkg.Lockated_User_Device_ID__c.split(';');
                for(String token : deviceTokens){
                    App_Notification__c an = new App_Notification__c();
                    an.Booking__c = bkg.Id;
                    an.Title__c = 'POSSESSION GUIDELINES ';
                    an.Message__c = 'Possession Guidelines';
                    an.Notification_Type__c = 'possession_guidelines';
                    an.Device_Token__c = token;
                    notifications.add(an);
                }
            }
            if(bkg.Primary_Applicant_Email__c != null){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<String>{bkg.Primary_Applicant_Email__c});
                mail.setSubject('Possession Guidelines');
                String body = 'Dear ' + bkg.Primary_Applicant_Name__c + ', <br/><br/>';
                body += 'Greetings from Runwal Enterprises !!! <br/>';
                body += 'Possession process and guidelines are now available on your Runwal Connect App. Ensure you follow all steps for a smooth handover.<br/><br/>';
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
    
    /*public static void createNotification(List<String> bkgIds, String title, String message, String ntype, String recordId, Date scheduledDate){
        if(bkgIds.size() > 0){
            List<Booking__c> bkgs = [SELECT Id, Lockated_User_Device_ID__c FROM Booking__c WHERE Id =: bkgIds];
            List<App_Notification__c> notifications = new List<App_Notification__c>();
            for(Booking__c bkg : bkgs){
                if(bkg.Lockated_User_Device_ID__c != null){
                    List<String> deviceTokens = bkg.Lockated_User_Device_ID__c.split(',');
                    for(String token : deviceTokens){
                        App_Notification__c an = new App_Notification__c();
                        an.Booking__c = bkg.Id;
                        an.Title__c = title;
                        an.Message__c = message;
                        an.Notification_Type__c = ntype;
                        if(ntype == 'my_loan'){
                            an.Record_Id__c = bkgIdVsLoanId.get(bkg.Id);
                        }else{
                            an.Record_Id__c = recordId;
                        }
                        if(ntype == 'my_loan' && bkgIdVsLogInDate.get(bkg.Id) != null){
                            an.Scheduled_On__c = bkgIdVsLogInDate.get(bkg.Id);
                        }else{
                            an.Scheduled_On__c = scheduledDate;
                        }
                        an.Device_Token__c = token;
                        notifications.add(an);
                    }
                }
            }
            if(notifications.size() > 0){
                insert notifications;
                for(App_Notification__c ntf : notifications){
                    if(ntf.Scheduled_On__c == null){
                        System.debug('ntf: ' + ntf.Device_Token__c);
                        //FCMService.sendNotification(ntf.Device_Token__c, ntf.Booking__c, ntf.Notification_Type__c, ntf.Title__c, ntf.Message__c, ntf.Record_Id__c);
                    }
                }
            }
        }
    }*/

}