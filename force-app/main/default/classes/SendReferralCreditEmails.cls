public class SendReferralCreditEmails {    
    public static void sendIntimationEmailtoRM(List<Id> rcIdSet) {
        System.debug('rcIdSet ' + rcIdSet);
        
        List<String> fileIds = new List<String>();
        
        List<Referral_Credits__c> rcList = [
            SELECT Id, Accounts_Head_Email__c, Accounts_Team_Email__c,Booking_RM__r.Email,Project_Name__c,Flat_no__c,Name_of_New_Customer__c,
            Name_of_Existing_Customer__c,Existing_Customer_Flat_no__c,Vendor_Code__c,SAP_Document_No__c
            FROM Referral_Credits__c
            WHERE Id IN :rcIdSet
        ];
        system.debug('rcList'+rcList);
        system.debug('rcList'+rcList[0].Booking_RM__r.Email);
        
        List<ContentDocumentLink> fileLinks = [
            SELECT ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :rcIdSet
        ];
        
        for(ContentDocumentLink c : fileLinks){
            fileIds.add(c.ContentDocumentId);
        }
        
        List<ContentVersion> files = [
            SELECT Id, Title, VersionData,FileExtension
            FROM ContentVersion
            WHERE ContentDocumentId IN :fileIds and IsLatest = true
        ];
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
        for (ContentVersion file : files) {
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            Blob fileData = file.VersionData;
            attachment.setBody(fileData);
            attachment.setFileName(file.Title + '.' + file.FileExtension);
            attachments.add(attachment);
        }
        
        List<String> ccAddress = new List<String>();
        List<String> toAddress = new List<String>();
        
        if(rcList[0].Booking_RM__r.Email!= null){
            toAddress.add(rcList[0].Booking_RM__r.Email);
        }else{
            toAddress.add(UserInfo.getUserEmail());
        }
       // if(!Test.isRunningTest()){
        // Prepare the email
       
      /*  if (!ccAddress.isEmpty()) {
            email.setCcAddresses(ccAddress);
            //email.setCcAddresses(new List<String>{'shraddha.shahari@runwalgroup.in'});//Testing Email Id
        } */
        
        String customerName = rcList[0].Name_of_Existing_Customer__c != null ? rcList[0].Name_of_Existing_Customer__c : 'N/A';
        String flatNumber = rcList[0].Existing_Customer_Flat_no__c != null ? rcList[0].Existing_Customer_Flat_no__c : 'N/A';
        String projectName = rcList[0].Project_Name__c != null ? rcList[0].Project_Name__c : 'N/A';
        String newCustName = rcList[0].Name_of_New_Customer__c != null ? rcList[0].Name_of_New_Customer__c : 'N/A';
        String newCustFlat = rcList[0].Flat_no__c != null ? rcList[0].Flat_no__c : 'N/A';

        String emailBody = 'Dear Sir/Ma\'am,<br/><br/>' +
            'Referral IOM for Customer ' + customerName + ', Unit no. ' + flatNumber + ' is eligible for Referral credit note/payout.<br/>' +            
            'Please generate and complete the signing process of Referral IOM and upload the same again in system for processing credit note / payouts.<br/><br/><br/>' +
            'List of Documents to upload with approved IOM :<br/>' +
            '<ol><li>Index II copy of Referrer</li><li>Index II copy of Referee</li><li>SCS copy of Referrer</li><li>d.	SCS copy of Referee (with name and unit no. of referrer mentioned as source)</li><li>Booking form of Referee with source mentioned as Referral with Referrer name and unit no mentioned.</li></ol><br/><br/>' +
        	'Referee details<br/>'+
            'Project : '+ projectName + '<br/>'+
            'Customer name :'+ newCustName + '<br/>'+
            'Unit no :'+ newCustFlat + '<br/>'+          
            'Thanks and Regards,<br/><br/>' +
            'Runwal Team<br/>';
         Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();  
        if (!toAddress.isEmpty()) {
            email.setToAddresses(toAddress);//Original Email Id
            // email.setToAddresses(new List<String>{'prashant.chaurasia.os@runwalgroup.in'});//Testing Email Id
            //email.setToAddresses(new List<String>{'prashant.chaurasia@stetig.in'});//Testing Email Id
        }
        email.setSubject('Referral Credit Note / Payout.');
        email.setHtmlBody(emailBody);
         //system.debug('emails'+email.setSubject);
        // system.debug('emails'+ email.setHtmlBody);
        system.debug('emails'+emails);
        if(!Test.isRunningTest()){
        email.setFileAttachments(attachments);
        }
        emails.add(email);
        system.debug('emails'+emails);
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
       // }
       // 
        Id referralCreditRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Referral Benefit').getRecordTypeId();            
        Task t = new task();
        t.OwnerId = rcList[0].Booking_RM__c;
        t.RecordTypeId = referralCreditRecordTypeId;
        t.Subject = 'Referral Benefit';
        t.WhatId = rcList[0].Id;
        insert t;
        
        
    }
    
    public static void sendIntimationEmailtoCRMHead(List<Id> rcIdSet) {
        System.debug('rcIdSet ' + rcIdSet);
        
        List<String> fileIds = new List<String>();
        
        List<Referral_Credits__c> rcList = [
            SELECT Id, Accounts_Head_Email__c, Accounts_Team_Email__c,Booking_RM__r.Email,Referral_Credit_Approver_L1__r.Email,
            Name_of_Existing_Customer__c,Existing_Customer_Flat_no__c,Vendor_Code__c,SAP_Document_No__c
            FROM Referral_Credits__c
            WHERE Id IN :rcIdSet
        ];
        
        List<ContentDocumentLink> fileLinks = [
            SELECT ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :rcIdSet
        ];
        
        for(ContentDocumentLink c : fileLinks){
            fileIds.add(c.ContentDocumentId);
        }
        
        List<ContentVersion> files = [
            SELECT Id, Title, VersionData,FileExtension
            FROM ContentVersion
            WHERE ContentDocumentId IN :fileIds and IsLatest = true
        ];
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
        for (ContentVersion file : files) {
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            Blob fileData = file.VersionData;
            attachment.setBody(fileData);
            attachment.setFileName(file.Title + '.' + file.FileExtension);
            attachments.add(attachment);
        }
        
        List<String> ccAddress = new List<String>();
        List<String> toAddress = new List<String>();
        
        if(rcList[0].Referral_Credit_Approver_L1__r.Email!= null){
            toAddress.add(rcList[0].Referral_Credit_Approver_L1__r.Email);
        }else{
            toAddress.add(UserInfo.getUserEmail());
        }
        
        // Prepare the email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();  
        if (!toAddress.isEmpty()) {
            email.setToAddresses(toAddress);//Original Email Id
           // email.setToAddresses(new List<String>{'prashant.chaurasia.os@runwalgroup.in'});//Testing Email Id
            //email.setToAddresses(new List<String>{'prashant.chaurasia@stetig.in'});//Testing Email Id
        }
        if (!ccAddress.isEmpty()) {
            email.setCcAddresses(ccAddress);
            //email.setCcAddresses(new List<String>{'shraddha.shahari@runwalgroup.in'});//Testing Email Id
        } 
        
        String customerName = rcList[0].Name_of_Existing_Customer__c != null ? rcList[0].Name_of_Existing_Customer__c : 'N/A';
        String flatNumber = rcList[0].Existing_Customer_Flat_no__c != null ? rcList[0].Existing_Customer_Flat_no__c : 'N/A';

        String emailBody = 'Dear Sir/Ma\'am,<br/><br/>' +
            'Referral IOM for Customer ' + customerName + ', Unit no. ' + flatNumber + ' has been processed in system as per attached approved IOM.<br/><br/><br/>' +            
            'Request your approval to process it further for credit note / payouts.<br/><br/><br/>' +
        	'Thanks and Regards,<br/>' +
            'Runwal Team<br/>';
        
        email.setSubject('Referrer approved IOM.');
        email.setHtmlBody(emailBody);        
        email.setFileAttachments(attachments);
        /*email.setSaveAsActivity(true);
        email.setWhatId(rcList[0].Id);*/
        
        emails.add(email);
        
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
    
    public static void sendIntimationEmailtoCRMHOD(List<Id> rcIdSet) {
        System.debug('rcIdSet ' + rcIdSet);
        
        List<String> fileIds = new List<String>();
        
        List<Referral_Credits__c> rcList = [
            SELECT Id, Accounts_Head_Email__c, Accounts_Team_Email__c,Booking_RM__r.Email,Referral_Credit_Approver_L2__r.Email,
            Name_of_Existing_Customer__c,Existing_Customer_Flat_no__c,Vendor_Code__c,SAP_Document_No__c
            FROM Referral_Credits__c
            WHERE Id IN :rcIdSet
        ];
        
        List<ContentDocumentLink> fileLinks = [
            SELECT ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :rcIdSet
        ];
        
        for(ContentDocumentLink c : fileLinks){
            fileIds.add(c.ContentDocumentId);
        }
        
        List<ContentVersion> files = [
            SELECT Id, Title, VersionData,FileExtension
            FROM ContentVersion
            WHERE ContentDocumentId IN :fileIds and IsLatest = true
        ];
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
        for (ContentVersion file : files) {
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            Blob fileData = file.VersionData;
            attachment.setBody(fileData);
            attachment.setFileName(file.Title + '.' + file.FileExtension);
            attachments.add(attachment);
        }
        
        List<String> ccAddress = new List<String>();
        List<String> toAddress = new List<String>();
        
        if(rcList[0].Referral_Credit_Approver_L2__r.Email!= null){
            toAddress.add(rcList[0].Referral_Credit_Approver_L2__r.Email);
        }else{
            toAddress.add(UserInfo.getUserEmail());
        }
        if(rcList[0].Booking_RM__r.Email!= null){
            ccAddress.add(rcList[0].Booking_RM__r.Email);
        }
        
        // Prepare the email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();  
        if (!toAddress.isEmpty()) {
            email.setToAddresses(toAddress);//Original Email Id
            // email.setToAddresses(new List<String>{'prashant.chaurasia.os@runwalgroup.in'});//Testing Email Id
            //email.setToAddresses(new List<String>{'prashant.chaurasia@stetig.in'});//Testing Email Id
        }
        if (!ccAddress.isEmpty()) {
            email.setCcAddresses(ccAddress);
            //email.setCcAddresses(new List<String>{'shraddha.shahari@runwalgroup.in'});//Testing Email Id
        }			 
        
        String customerName = rcList[0].Name_of_Existing_Customer__c != null ? rcList[0].Name_of_Existing_Customer__c : 'N/A';
        String flatNumber = rcList[0].Existing_Customer_Flat_no__c != null ? rcList[0].Existing_Customer_Flat_no__c : 'N/A';

        String emailBody = 'Dear Sir/Ma\'am,<br/><br/>' +
            'Referral IOM for Customer ' + customerName + ', Unit no. ' + flatNumber + ' has been approved by CRM Head as per attached approved IOM.<br/><br/><br/>' +            
            'Request your approval to process and share the same with accounts team for credit note / payouts.<br/><br/><br/>' +
        	'Thanks and Regards,<br/>' +
            'Runwal Team<br/>';
        
        email.setSubject('Referral Credit Note / Payout.');
        email.setHtmlBody(emailBody);        
        email.setFileAttachments(attachments);
        /*email.setSaveAsActivity(true);
        email.setWhatId(rcList[0].Id);*/
        
        emails.add(email);
        
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
    
    public static void sendEmailtoAccounts(List<Id> rcIdSet) {
        if (rcIdSet == null || rcIdSet.isEmpty()) {
            System.debug('No referral credit Ids passed.');
            return;
        }
        
        List<Referral_Credits__c> rcList = [
            SELECT Id, Accounts_Head_Email__c, Accounts_Team_Email__c, Booking_RM__r.Email,
            Name_of_Existing_Customer__c, Existing_Customer_Flat_no__c,
            Vendor_Code__c, SAP_Document_No__c
            FROM Referral_Credits__c
            WHERE Id IN :rcIdSet
        ];
        
        if (rcList.isEmpty()) {
            System.debug('No referral credit records found for given IDs: ' + rcIdSet);
            return;
        }
        
        // Attachments
        List<ContentDocumentLink> fileLinks = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :rcIdSet
        ];
        List<String> fileIds = new List<String>();
        for(ContentDocumentLink c : fileLinks) {
            fileIds.add(c.ContentDocumentId);
        }
        
        List<ContentVersion> files = new List<ContentVersion>();
        if (!fileIds.isEmpty()) {
            files = [
                SELECT Id, Title, VersionData, FileExtension
                FROM ContentVersion
                WHERE ContentDocumentId IN :fileIds AND IsLatest = true
            ];
        }
        
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
        for (ContentVersion file : files) {
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setBody(file.VersionData);
            attachment.setFileName(file.Title + '.' + file.FileExtension);
            attachments.add(attachment);
        }
        
        // Recipients
        List<String> toAddress = new List<String>();
        List<String> ccAddress = new List<String>();
        
        Referral_Credits__c rc = rcList[0];
        
        toAddress.add(rc.Accounts_Team_Email__c != null ? rc.Accounts_Team_Email__c : UserInfo.getUserEmail());
        if (rc.Accounts_Head_Email__c != null) ccAddress.add(rc.Accounts_Head_Email__c);
        if (rc.Booking_RM__r != null && rc.Booking_RM__r.Email != null) ccAddress.add(rc.Booking_RM__r.Email);
        
        // Email body
        String emailBody = 'Dear Sir/Ma\'am,<br/><br/>' +
            'Referral IOM for Customer ' + (rc.Name_of_Existing_Customer__c != null ? rc.Name_of_Existing_Customer__c : 'N/A') +
            ', Unit no. ' + (rc.Existing_Customer_Flat_no__c != null ? rc.Existing_Customer_Flat_no__c : 'N/A') + ' has been approved by CRM HOD.<br/>' +
            'Vendor Code - ' + (rc.Vendor_Code__c != null ? rc.Vendor_Code__c : 'N/A') + '<br/><br/>' +
            'SAP Document Number - ' + (rc.SAP_Document_No__c != null ? rc.SAP_Document_No__c : 'N/A') + '<br/><br/>' +
            'Request you to process the credit note/payout as per attached approved IOM.<br/><br/><br/>' +
            'Thanks and Regards,<br/>Runwal Team<br/>';
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        if (!toAddress.isEmpty()) email.setToAddresses(toAddress);
        //email.setToAddresses(new List<String>{'prashant.chaurasia@stetig.in'}); // testing
        if (!ccAddress.isEmpty()) email.setCcAddresses(ccAddress);
        email.setSubject('Vendor creation and expenses booked.');
        email.setHtmlBody(emailBody);
        if (!attachments.isEmpty()) email.setFileAttachments(attachments);
        
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
    }

    public static void send20PercentReport(){
        Date todaysDate = Date.today();
        List<Booking__c> bList = [SELECT Id, Name,Unit_No__r.Relationship_Manager__r.User__r.IsActive, Unit_No__r.Relationship_Manager__r.User__c,Primary_Applicant_Name__c,Flat_No__c,Unit_No__r.Relationship_Manager__r.RM_Email__c,Unit_No__r.Relationship_Manager__r.TL_Email__c,SO_Release_Date_in_SAP__c,
                                  Project__r.Name,RW_Total_Receipt_Amount_Received__c,Allotment_Premium__c,Booking_Date__c,Unit_No__r.TowerName__r.Name,Unit_Number__c,Zone__c,Opportunity__r.SAP_Customer_Number__c,Opportunity__r.SalesOrder_Number__c,RM_Name__c,
                                  Payment_Received__c,X5_Received__c,X5_Received_Date__c,RW_X9_99_Received__c,X9_90_Received_Date__c,Unit_No__r.Relationship_Manager__r.Name,RW_Total_Amount_Received_Without_GST__c,RW_Project_Name__c,
                                  Unit_No__r.Relationship_Manager__r.User__r.Manager.Id,Customer__r.StageName,RW_BRL_Number__c,Status__c,RW_Registration_Date__c,Project__r.CRM_MIS_Head__c,Project__r.Overall_CRM_Head__c,
                                  Project__r.Home_Loan_Email__c,Project__r.CRMHead__c,X20_Received_Date__c
                                  FROM Booking__c WHERE X20_Received_Date__c =: todaysDate and Status__c = 'Booking Confirmed' AND Customer__r.StageName = 'Unit Booked' 
                                  and Source_of_Booking__c = 'Referral' and Sub_Source__c = 'Existing client reference' and Referral_Passback__c < 1.00 
                                  order by Booking_Date__c desc 
                                 ];
        if (!bList.isEmpty()) {
            Map<Id, List<Booking__c>> groupedByBookingswithRms = new Map<Id, List<Booking__c>>();
            
            for (Booking__c booking : bList) {         
                Id rmId = booking.Unit_No__r.Relationship_Manager__r.User__c;
                if (!groupedByBookingswithRms.containsKey(rmId)) {
                    groupedByBookingswithRms.put(rmId, new List<Booking__c>());
                }
                groupedByBookingswithRms.get(rmId).add(booking);
            }
            system.debug('groupedByBookingswithRms----->>>>'+groupedByBookingswithRms);
            
            sendEmail(groupedByBookingswithRms);
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
                email.setToAddresses(toAddress);//Original Email Id
                //email.setToAddresses(new List<String>{'prashant.chaurasia.os@runwalgroup.in'});//Testing Email Id
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
    
    public static void sendEmailafterPosting(list<Id> rcIds) {
        //Send whatsapp msg...
        //Whatsapp template pending from business.
        //SendWhatsAppMsg.methodToSendWhatsAppMsg(param1, param2, param3, param4, param5, param6, param7, param8, param9, countryCode, MobileNo, elementName);
        //Also Send an Email to posting completion.
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
		List<Referral_Credits__c> refClist = [SELECT Id,SAP_Posting_Date__c,Name_of_New_Customer__c,Referral_Amount_Due__c,Reference_Booking__r.Primary_Applicant_Email__c,Reference_Booking__r.Future_Correspondence_Contact_Email__c FROM Referral_Credits__c WHERE Id IN :rcIds];
		
        for(Referral_Credits__c rf : refClist){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =: 'shraddha.shahari@runwalgroup.in'];
          
            if (owea.size() > 0) {
                email.setOrgWideEmailAddressId(owea[0].id);
            }
            String htmlBody = buildEmailBody(rf.Name_of_New_Customer__c,rf.Referral_Amount_Due__c);
            email.setToAddresses(new String[] {rf.Reference_Booking__r.Future_Correspondence_Contact_Email__c});
            email.setHtmlBody(htmlBody);
            email.WhatId = rf.Id;            
            email.setSaveAsActivity(true);
            email.setSubject('Credit Note Payout');
            emailList.add(email); 
            /*email.setSaveAsActivity(true);
        email.setWhatId(rcList[0].Id);*/
        }
        
        if (!emailList.isEmpty()) {
            try {
                Messaging.sendEmail(emailList);
            } catch (Exception ex) {
                system.debug('Error in sending emails: ' + ex.getMessage() + ' stack ' + ex.getStackTraceString());
                //responseList.add('Error: ' + ex.getMessage());
            }
        }
    }
    
    private static String buildEmailBody(String contactName, Decimal referralAmount) {
        return '<html>' +
            '<body style="background-color: #f4f4f4; margin: 0; padding: 20px; font-family: Arial, sans-serif; font-size: 14px; color: #333;">' +
            '<div style="max-width: 600px; margin: 0 auto; background-color: #ffffff; padding: 20px; border: 1px solid #ddd; border-radius: 6px;">' +
            '<p>Dear ' + contactName + ',</p>' +
            '<p>We are pleased to inform you that a credit note of <strong>Rs ' + referralAmount + '</strong> has been passed towards the referral benefit.</p>' +
            '<p>We thank you for your continued partnership with Runwal, keep referring and earning rewards with us!</p>' +
            '<p>Thank you for being a part of the Runwal family.</p>' +
            '<br/>' +
            '<p>Warm Regards,<br/>' +
            'Customer Support<br/>' +
            'Runwal Enterprises</p>' +
            '</div>' +
            '</body>' +
            '</html>';
    }



}