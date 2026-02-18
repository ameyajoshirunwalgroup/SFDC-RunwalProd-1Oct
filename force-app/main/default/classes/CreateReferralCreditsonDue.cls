//Added by Prashant to Create Referral Credit Record when customer is due.. //// 01-08-2025.////
global class CreateReferralCreditsonDue implements Database.Batchable<sObject>,Schedulable, Database.Stateful {
   global Set<Id> processedBookingIds = new Set<Id>();
    global Iterable<Booking__c> start(Database.BatchableContext BC) {

        List<Booking__c> bkgs = [SELECT Id, Name, Unit_No__r.Relationship_Manager__r.User__c, Customer__r.SAP_Customer_Number__c, Customer_Reference_Opportunity__r.SAP_Customer_Number__c, 
                                 Customer_Reference_Opportunity__r.Booking__c, Customer_Reference_Flat_No__c, Customer_Reference_Primary_Applicant_Nam__c, Unit_Number__c, 
                                 Primary_Applicant_Name__c, Referral_Amount_to_be_Adjusted__c, Project__r.CRM_MIS_Head__c, Project__r.CRMHead__c, Actual_Referral_Amount__c,
                                 TDS_5_to_be_deducted__c, X1_of_Agreement_Value__c, Referral__c, Source_of_Booking__c, Sub_Source__c, Registration_Status__c, Referral_Passback__c,
                                 X20_Received_Date__c, Customer_Reference_Opportunity__r.Booking__r.X20_Received_Date__c FROM Booking__c 
                                 WHERE Source_of_Booking__c = 'Referral' AND Sub_Source__c = 'Existing client reference' AND Registration_Status__c = 'Due' AND 
                                 Referral_Passback__c < 1 AND X20_Received_Date__c != null and referral_email_sent__c = false];

        return bkgs;
    }

    global void execute(Database.BatchableContext bc, List<Booking__c> bookings) {
        system.debug('bookings[0].Source_of_Booking__c -> '+ bookings[0].Source_of_Booking__c);
        system.debug('bookings[0].Sub_Source__c -> ' + bookings[0].Sub_Source__c);
        system.debug('bookings[0].Registration_Status__c -> ' + bookings[0].Registration_Status__c);
        system.debug('bookings[0].Referral_Passback__c -> ' + bookings[0].Referral_Passback__c);
        system.debug('bookings[0].X20_Received_Date__c -> ' + bookings[0].X20_Received_Date__c);
        system.debug('bookings[0].Customer_Reference_Opportunity__r -> ' + bookings[0].Customer_Reference_Opportunity__c);
        system.debug('bookings[0].Customer_Reference_Opportunity__r.Booking__r.X20_Received_Date__c -> ' + bookings[0].Customer_Reference_Opportunity__r.Booking__r.X20_Received_Date__c);
        
        list<Referral_Credits__c> rflist = new list<Referral_Credits__c>();
        for (Booking__c b : bookings) {
            processedBookingIds.add(b.Id);
            Referral_Credits__c r = new Referral_Credits__c();
            r.Accounts_Head__c = null;//To be Assigned...
            r.Booking_RM__c = b.Unit_No__r.Relationship_Manager__r.User__c;
            r.Booking__c = b.Id;
            r.CRN__c = b.Customer__r.SAP_Customer_Number__c;
            r.Existing_Customer_CRN__c = b.Customer_Reference_Opportunity__r.SAP_Customer_Number__c;
            r.Existing_Customer_Flat_no__c = b.Customer_Reference_Flat_No__c;
            r.Flat_no__c = b.Unit_Number__c;
            r.Name_of_Existing_Customer__c = b.Customer_Reference_Primary_Applicant_Nam__c;
            r.Name_of_New_Customer__c = b.Primary_Applicant_Name__c;
            r.Reference_Booking__c = b.Customer_Reference_Opportunity__r.Booking__c;
            r.Referral_Amount_Due__c = b.Referral_Amount_to_be_Adjusted__c;
            r.Referral_Credit_Approver_L1__c = b.Project__r.CRM_MIS_Head__c;
            r.Referral_Credit_Approver_L2__c = b.Project__r.CRMHead__c;
            r.Referral_In_Rs__c = b.Actual_Referral_Amount__c;
            r.TDS_5_to_be_deducted__c = b.TDS_5_to_be_deducted__c;
            r.X1_of_Agreement_Value__c = b.X1_of_Agreement_Value__c;
            String longText = '';
            longText = 'Customer Referral' +' '+ '('+ b.Primary_Applicant_Name__c +' )' +b.Unit_Number__c +' - '+  b.Referral__c +'%';
            r.long_text1__c = longText;
            rflist.add(r);
        }

        if (!rflist.isEmpty()) {
            system.debug('rflist -->>'+rflist);
            Database.insert(rflist, false);
        }
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('Total bookings processed = ' + processedBookingIds.size());
        System.debug('Booking Ids = ' + processedBookingIds);
        
        Date todaysDate = Date.today();
        List<Booking__c> bList = [SELECT Id, Name,Unit_No__r.Relationship_Manager__r.User__r.IsActive, Unit_No__r.Relationship_Manager__r.User__c,Primary_Applicant_Name__c,Flat_No__c,Unit_No__r.Relationship_Manager__r.RM_Email__c,Unit_No__r.Relationship_Manager__r.TL_Email__c,SO_Release_Date_in_SAP__c,
                                  Project__r.Name,RW_Total_Receipt_Amount_Received__c,Allotment_Premium__c,Booking_Date__c,Unit_No__r.TowerName__r.Name,Unit_Number__c,Zone__c,Opportunity__r.SAP_Customer_Number__c,Opportunity__r.SalesOrder_Number__c,RM_Name__c,
                                  Payment_Received__c,X5_Received__c,X5_Received_Date__c,RW_X9_99_Received__c,X9_90_Received_Date__c,Unit_No__r.Relationship_Manager__r.Name,RW_Total_Amount_Received_Without_GST__c,RW_Project_Name__c,
                                  Unit_No__r.Relationship_Manager__r.User__r.Manager.Id,Customer__r.StageName,RW_BRL_Number__c,Status__c,RW_Registration_Date__c,Project__r.CRM_MIS_Head__c,Project__r.Overall_CRM_Head__c,
                                  Project__r.Home_Loan_Email__c,Project__r.CRMHead__c,X20_Received_Date__c
                                  FROM Booking__c WHERE X20_Received_Date__c != null and Id IN: processedBookingIds
                                  order by Booking_Date__c desc 
                                 ];
        if (!bList.isEmpty()) {
            Map<Id, List<Booking__c>> crmHeadVsBookingMap = new Map<Id, List<Booking__c>>();
            
            for (Booking__c booking : bList) {         
                Id crmHead = booking.Project__r.CRM_MIS_Head__c;
                if (!crmHeadVsBookingMap.containsKey(crmHead)) {
                    crmHeadVsBookingMap.put(crmHead, new List<Booking__c>());
                }
                crmHeadVsBookingMap.get(crmHead).add(booking);
            }
            system.debug('crmHeadVsBookingMap----->>>>'+crmHeadVsBookingMap);
            
            sendEmail(crmHeadVsBookingMap);
            
            List<Booking__c> bookingsToUpdate = new List<Booking__c>();
            
            for (Id bookingId : processedBookingIds) {
                bookingsToUpdate.add(new Booking__c(
                    Id = bookingId,
                    referral_email_sent__c = true
                ));
            }
            
            if (!bookingsToUpdate.isEmpty()) {
                update bookingsToUpdate;
            }
            //sendEmailstoTL(groupedBy5percentBookingswithTLs, true);
            //sendEmailstoRM(groupedBy10percentBookingswithRms, false);
            //sendEmailstoTL(groupedBy10percentBookingswithTLs, false);
            
        }
        
      
    }
    
    private static String generateCSVContent(List<Booking__c> bookings) {
        String header = 'Name Of Customer,Booking Date,20% Payment Received Date,TAT of 20% Payment Received Date ,TAT from 20% payment received date till date ,Unit Number,Project Name,AV Value,Received Value,Percentage Paid,SAP Customer Number,SAP Salesorder Id\n';
        String body = '';
        
        for (Booking__c b : bookings) {
            Date bookingDateTemp = b.Booking_Date__c.date();
            String bookingDate = bookingDateTemp.format();
            System.debug('Booking Date: ' + bookingDate);
            //String paymentReceivedDate = b.SO_Release_Date_in_SAP__c != null ? b.SO_Release_Date_in_SAP__c.format() : '';
            Integer daysBetweenbooking;
            String recivedPercentDate;
            Integer daysBetweenpercentRectillNow;
            
            if(b.X20_Received_Date__c != null){
                daysBetweenpercentRectillNow = b.X20_Received_Date__c.daysBetween(system.today());
                recivedPercentDate = b.X20_Received_Date__c.format();
                daysBetweenbooking = b.Booking_Date__c.date().daysBetween(b.X20_Received_Date__c);
            }else{
                recivedPercentDate = system.today().format();
                daysBetweenbooking = b.Booking_Date__c.date().daysBetween(system.today());
            } 
            
            system.debug('daysBetweenpercentRectillNow ----->>>> '+daysBetweenpercentRectillNow);
            //Decimal percentagePaid = ((b.RW_Total_Amount_Received_Without_GST__c / b.Allotment_Premium__c) * 100).setScale(2, RoundingMode.HALF_UP);
            
            String recordString = b.Primary_Applicant_Name__c+ ',' + bookingDate + ',' + recivedPercentDate + ',' + daysBetweenbooking + ',' + daysBetweenpercentRectillNow + ',' + b.Unit_Number__c + ',' + b.RW_Project_Name__c + ',' + b.Opportunity__r.SAP_Customer_Number__c + ',' + b.Opportunity__r.SalesOrder_Number__c 
                +'\n';
            body += recordString;
            //System.debug('Booking Name: ' + b.Name + ', Flat: ' + b.Flat_No__c + ', RM Name: ' + b.Unit_No__r.Relationship_Manager__r.Name +', RM Id: '+b.Unit_No__r.Relationship_Manager__c);
            
        }
        
        return header + body;
    }
    
    private static void sendEmail(Map<Id, List<Booking__c>> groupedBookings) {
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Map<Id,User> rm_tlMap = new Map<Id,User>([Select Id,Email, ManagerId, Manager.Email,Name from User where Id IN: groupedBookings.keySet()]);
        
        list<CustomNotificationType> notificationType = [SELECT Id,DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'PaymentNotificationtoRM'];   
        
        
        for (Id rmId : groupedBookings.keySet()) {
            String finalstr = '';
            list<String> ccAddress = new list<String>();
            list<String> toAddress = new list<String>();
            
            String nbody = '';
            String title = '';
            title = 'PAYMENT MILESTONE RECD 20%.';
            nbody = 'Please check your email for the attached list of customers who have completed 20% of their payment, Please proceed with their Referral Credit Payout.';
            
            List<Booking__c> bookings = groupedBookings.get(rmId);
            
            String csvContent = generateCSVContent(bookings);            
            Blob csvBlob = Blob.valueOf(csvContent);
            
            if (rm_tlMap.get(rmId).Email != null){              
                toAddress.add(rm_tlMap.get(rmId).Email);
                //For testing purpose
                /*if (tlu.Email.endsWith('.invalid') && (tlu.Email == 'tejal.punjabi@runwalgroup.in.invalid' || tlu.Email == 'hiren.bhadra@runwalgroup.in.invalid')) {
String validEmail = tlu.Email.substring(0, tlu.Email.length() - 8);
toAddress.add(validEmail);
} else {
toAddress.add(tlu.Email);
}*/
            }           
            
            if (rm_tlMap.get(rmId).Manager != null && rm_tlMap.get(rmId).Manager.Email != null){
                ccAddress.add(rm_tlMap.get(rmId).Manager.Email);
            }          
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =: 'shraddha.shahari@runwalgroup.in']; //Commented by Vinay 29-05-2025
            
            if (owea.size() > 0) {
                email.setOrgWideEmailAddressId(owea[0].id);
            }
            //email.setOrgWideEmailAddressId('0D25j0000008QPACA2');
            
            //if (!toAddress.isEmpty()) {
            //email.setToAddresses(toAddress);//Original Email Id
            email.setToAddresses(new List<String>{'prashant.chaurasia.os@runwalgroup.in'});//Testing Email Id
            // email.setToAddresses(new List<String>{'prashant.chaurasia.os@runwalgroup.in'});//Testing Email Id
            //email.setToAddresses(new List<String>{'prashant.chaurasia@stetig.in'});//Testing Email Id
            //}
            if (!ccAddress.isEmpty()) {
                email.setCcAddresses(ccAddress);
                //email.setCcAddresses(new List<String>{'shraddha.shahari@runwalgroup.in'});//Testing Email Id
            } 
            
            
            String subject = '';
            String body = '';
            
            subject = 'NOTIFICATION : PAYMENT MILESTONE RECD 20%.' /*+ rm_tlMap.get(rmId).Name*/;
            body = 'Dear Team,\n\nPlease find the attached details of the customers whose 20% payment is completed, Please proceed with their Referral Credit Payout.\n\nRegards,';
            email.setSubject(subject);
            email.setPlainTextBody(body);
            
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName('Referral Credit Payout for customers post 20% payment completion.csv');
            attachment.setBody(csvBlob); 
            attachment.setContentType('text/csv'); 
            email.setFileAttachments(new List<Messaging.EmailFileAttachment>{attachment});
            emailList.add(email);                
            
            system.debug('finalstr'+finalstr);
            
            if (!notificationType.isEmpty()) {  
                system.debug('Inside Notification sent');
                Messaging.CustomNotification customNotificationObj = new Messaging.CustomNotification();              
                customNotificationObj.setBody(nbody);                
                customNotificationObj.setTitle(title);  
                customNotificationObj.setNotificationTypeId(notificationType[0].id);
                Map<String, Object> homePageRef = new Map<String, Object>{
                    'type' => 'standard__namedPage',
                        'attributes' => new Map<String, Object>{
                            'pageName' => 'home'
                                }
                };
                    
                    customNotificationObj.setTargetPageRef(JSON.serialize(homePageRef));
                //customNotificationObj.setTargetId(opp.Id);
                //customNotificationObj.send(new Set<String> {rmId});
                //customNotificationObj.send(new Set<String> {'0055j000007G2SJAA0'});
                system.debug('Notification sent');
            }
        }
        
        if (!emailList.isEmpty()) {
            Messaging.sendEmail(emailList);
        }
    }
    

    global void execute(SchedulableContext sc) {
        CreateReferralCreditsonDue job = new CreateReferralCreditsonDue();
        Database.executeBatch(job, 20);
    }
}