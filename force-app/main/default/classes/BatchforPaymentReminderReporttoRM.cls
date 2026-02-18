global class BatchforPaymentReminderReporttoRM implements Database.Batchable<sObject>, Database.Stateful {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        /*list<Booking__c> blist = [
            SELECT Id, Name, Unit_No__r.Relationship_Manager__r.User__r.IsActive,
                   Unit_No__r.Relationship_Manager__r.User__c, Primary_Applicant_Name__c,
                   Flat_No__c, Unit_No__r.Relationship_Manager__r.RM_Email__c,
                   Unit_No__r.Relationship_Manager__r.TL_Email__c, SO_Release_Date_in_SAP__c,
                   Project__r.Name, RW_Total_Receipt_Amount_Received__c, Allotment_Premium__c,
                   Booking_Date__c, Unit_No__r.TowerName__r.Name, Unit_Number__c, Zone__c,
                   Opportunity__r.SAP_Customer_Number__c, Opportunity__r.SalesOrder_Number__c, RM_Name__c,
                   Payment_Received__c, X5_Received__c, X5_Received_Date__c, RW_X9_99_Received__c,
                   X9_90_Received_Date__c, Unit_No__r.Relationship_Manager__r.Name,
                   RW_Total_Amount_Received_Without_GST__c, RW_Project_Name__c,
                   Unit_No__r.Relationship_Manager__r.User__r.Manager.Id, Customer__r.StageName,
                   RW_BRL_Number__c, Status__c, RW_Registration_Date__c, Project__r.CRM_MIS_Head__c,
                   Project__r.Overall_CRM_Head__c, Project__r.Home_Loan_Email__c, Project__r.CRMHead__c
            FROM Booking__c
            WHERE Unit_No__r.Relationship_Manager__r.User__r.IsActive = true
            AND Unit_No__r.Relationship_Manager__r.User__c != null
            AND (X5_Received__c = true OR RW_X9_99_Received__c = true)
			AND CreatedDate >= 2024-12-01T00:00:00.000Z            
            AND RW_Registration_Date__c = null
            AND RW_BRL_Number__c = null
            AND Status__c = 'Booking Confirmed'
            AND Customer__r.StageName = 'Unit Booked'
            AND Unit_No__r.Relationship_Manager__r.User__r.Manager.Id != null
            ORDER BY Booking_Date__c DESC
        ];
        system.debug('bList'+bList);
        system.debug('user active'+bList[0].Unit_No__r.Relationship_Manager__r.User__r.IsActive);
        system.debug('user id--'+bList[0].Unit_No__r.Relationship_Manager__r.User__c);
        system.debug('5% received+'+bList[0].X5_Received__c);
        system.debug('10% received+'+bList[0].RW_X9_99_Received__c);
        system.debug('registration date+'+bList[0].RW_Registration_Date__c);
        system.debug('brl number+'+bList[0].RW_BRL_Number__c);
        system.debug('status +'+bList[0].Status__c);
        system.debug('stage name+'+bList[0].Customer__r.StageName);
        system.debug('manager id+'+bList[0].Unit_No__r.Relationship_Manager__r.User__r.Manager.Id);
        system.debug('amount received +'+bList[0].RW_Total_Receipt_Amount_Received__c);*/
        return Database.getQueryLocator([
            SELECT Id, Name, Unit_No__r.Relationship_Manager__r.User__r.IsActive,
                   Unit_No__r.Relationship_Manager__r.User__c, Primary_Applicant_Name__c,
                   Flat_No__c, Unit_No__r.Relationship_Manager__r.RM_Email__c,
                   Unit_No__r.Relationship_Manager__r.TL_Email__c, SO_Release_Date_in_SAP__c,
                   Project__r.Name, RW_Total_Receipt_Amount_Received__c, Allotment_Premium__c,
                   Booking_Date__c, Unit_No__r.TowerName__r.Name, Unit_Number__c, Zone__c,
                   Opportunity__r.SAP_Customer_Number__c, Opportunity__r.SalesOrder_Number__c, RM_Name__c,
                   Payment_Received__c, X5_Received__c, X5_Received_Date__c, RW_X9_99_Received__c,
                   X9_90_Received_Date__c, Unit_No__r.Relationship_Manager__r.Name,
                   RW_Total_Amount_Received_Without_GST__c, RW_Project_Name__c,
                   Unit_No__r.Relationship_Manager__r.User__r.Manager.Id, Customer__r.StageName,
                   RW_BRL_Number__c, Status__c, RW_Registration_Date__c, Project__r.CRM_MIS_Head__c,
                   Project__r.Overall_CRM_Head__c, Project__r.Home_Loan_Email__c, Project__r.CRMHead__c
            FROM Booking__c
            WHERE Unit_No__r.Relationship_Manager__r.User__r.IsActive = true
            AND Unit_No__r.Relationship_Manager__r.User__c != null
            AND (X5_Received__c = true OR RW_X9_99_Received__c = true)
			AND CreatedDate >= 2024-12-01T00:00:00.000Z            
            AND RW_Registration_Date__c = null
            AND RW_BRL_Number__c = null
            AND Status__c = 'Booking Confirmed'
            AND Customer__r.StageName = 'Unit Booked'
            AND Unit_No__r.Relationship_Manager__r.User__r.Manager.Id != null
            ORDER BY Booking_Date__c DESC
        ]);
    }
    
    global void execute(Database.BatchableContext bc, List<Booking__c> bList) {
        
        Map<Id, List<Booking__c>> Mapof5percentBookingswithRMs = new Map<Id, List<Booking__c>>();
        Map<Id, List<Booking__c>> Mapof10percentBookingswithRMs = new Map<Id, List<Booking__c>>();
        Map<Id, List<Booking__c>> Mapof5percentBookingswithTLs = new Map<Id, List<Booking__c>>();
        Map<Id, List<Booking__c>> Mapof10percentBookingswithTLs = new Map<Id, List<Booking__c>>();
        Map<Id, List<Booking__c>> Mapof5percentBookingswithCRMMisHeads = new Map<Id, List<Booking__c>>();
        Map<Id, List<Booking__c>> Mapof10percentBookingswithCRMMisHeads = new Map<Id, List<Booking__c>>();
        Map<Id, List<Booking__c>> Mapof5percentBookingswithCRMHeads = new Map<Id, List<Booking__c>>();
        Map<Id, List<Booking__c>> Mapof10percentBookingswithCRMHeads = new Map<Id, List<Booking__c>>();
        Map<String, List<Booking__c>> Mapof5percentBookingswithHomeLoanEmails = new Map<String, List<Booking__c>>();
        Map<String, List<Booking__c>> Mapof10percentBookingswithHomeLoanEmails = new Map<String, List<Booking__c>>();
        
        
        for (Booking__c booking : bList) {
            Id rmId = booking.Unit_No__r.Relationship_Manager__r.User__c;
            Id tlId = booking.Unit_No__r.Relationship_Manager__r.User__r.Manager.Id;
            Id CRMMisHead = booking.Project__r.CRM_MIS_Head__c;
            Id CRMHead = booking.Project__r.CRMHead__c;
            String HomeLoanEmail = booking.Project__r.Home_Loan_Email__c;
            
            if (booking.X5_Received__c == true && booking.RW_X9_99_Received__c == false) {
                if (!Mapof5percentBookingswithRMs.containsKey(rmId)) {
                    Mapof5percentBookingswithRMs.put(rmId, new List<Booking__c>());
                }
                Mapof5percentBookingswithRMs.get(rmId).add(booking);
                if (!Mapof5percentBookingswithTLs.containsKey(tlId)) {
                    Mapof5percentBookingswithTLs.put(tlId, new List<Booking__c>());
                }                
                Mapof5percentBookingswithTLs.get(tlId).add(booking);
                if(!Mapof5percentBookingswithCRMMisHeads.containsKey(CRMMisHead)){
                    Mapof5percentBookingswithCRMMisHeads.put(CRMMisHead,new list<Booking__c>());
                }
                Mapof5percentBookingswithCRMMisHeads.get(CRMMisHead).add(booking);                
                if(!Mapof5percentBookingswithCRMHeads.containsKey(CRMHead)){
                    Mapof5percentBookingswithCRMHeads.put(CRMHead,new list<Booking__c>());
                }
                Mapof5percentBookingswithCRMHeads.get(CRMHead).add(booking);                
                if(!Mapof5percentBookingswithHomeLoanEmails.containsKey(HomeLoanEmail)){
                    Mapof5percentBookingswithHomeLoanEmails.put(HomeLoanEmail,new list<Booking__c>());
                }
                Mapof5percentBookingswithHomeLoanEmails.get(HomeLoanEmail).add(booking);
                
            }
            if (booking.RW_X9_99_Received__c == true) {
                if (!Mapof10percentBookingswithRMs.containsKey(rmId)) {
                    Mapof10percentBookingswithRMs.put(rmId, new List<Booking__c>());
                }
                Mapof10percentBookingswithRMs.get(rmId).add(booking);
                if (!Mapof10percentBookingswithTLs.containsKey(tlId)) {
                    Mapof10percentBookingswithTLs.put(tlId, new List<Booking__c>());
                }
                Mapof10percentBookingswithTLs.get(tlId).add(booking);
                if(!Mapof10percentBookingswithCRMMisHeads.containsKey(CRMMisHead)){
                    Mapof10percentBookingswithCRMMisHeads.put(CRMMisHead,new list<Booking__c>());
                }
                Mapof10percentBookingswithCRMMisHeads.get(CRMMisHead).add(booking);
                if(!Mapof10percentBookingswithCRMHeads.containsKey(CRMHead)){
                    Mapof10percentBookingswithCRMHeads.put(CRMHead,new list<Booking__c>());
                }
                Mapof10percentBookingswithCRMHeads.get(CRMHead).add(booking);
                if(!Mapof10percentBookingswithHomeLoanEmails.containsKey(HomeLoanEmail)){
                    Mapof10percentBookingswithHomeLoanEmails.put(HomeLoanEmail,new list<Booking__c>());
                }
                Mapof10percentBookingswithHomeLoanEmails.get(HomeLoanEmail).add(booking);
            }
        }
        
        sendEmailstoRM(Mapof5percentBookingswithRMs, true);
        sendEmailstoTL(Mapof5percentBookingswithTLs, true);
        sendEmailstoRM(Mapof10percentBookingswithRMs, false);
        sendEmailstoTL(Mapof10percentBookingswithTLs, false);
        sendEmailstoTL(Mapof5percentBookingswithCRMMisHeads,true);
        sendEmailstoTL(Mapof5percentBookingswithCRMMisHeads,false);
        sendEmailstoTL(Mapof10percentBookingswithCRMMisHeads,true);
        sendEmailstoTL(Mapof10percentBookingswithCRMMisHeads,false);
        sendEmailstoTL(Mapof5percentBookingswithCRMHeads,true);
        sendEmailstoTL(Mapof5percentBookingswithCRMHeads,false);
        sendEmailstoTL(Mapof10percentBookingswithCRMHeads,true);
        sendEmailstoTL(Mapof10percentBookingswithCRMHeads,false);
        sendEmailstoHomeLoanTeam(Mapof5percentBookingswithHomeLoanEmails,true);
        sendEmailstoHomeLoanTeam(Mapof5percentBookingswithHomeLoanEmails,false);
        sendEmailstoHomeLoanTeam(Mapof10percentBookingswithHomeLoanEmails,true);
        sendEmailstoHomeLoanTeam(Mapof10percentBookingswithHomeLoanEmails,false);
        
    }
    
    global static String generateCSVContentforRM(List<Booking__c> bookings,Boolean isfivePercentTriggered) {
        String header = '';
        if(isfivePercentTriggered){
            header = 'Name Of Customer,Booking Date,5% Payment Received Date,TAT of 5% Payment Received Date ,TAT from 5% payment received date till date ,Unit Number,Project Name,AV Value,Received Value,Percentage Paid,SAP Customer Number,SAP Salesorder Id\n';
        }else{
            header = 'Name Of Customer,Booking Date,10% Payment Received Date,TAT of 10% Payment Received Date ,TAT from 10% payment received date till date ,Unit Number,Project Name,AV Value,Received Value,Percentage Paid,SAP Customer Number,SAP Salesorder Id\n';
        }
        String body = '';
        
        for (Booking__c b : bookings) {
            Date bookingDateTemp = b.Booking_Date__c.date();
            String bookingDate = bookingDateTemp.format();
            System.debug('Booking Date: ' + bookingDate);
            //String paymentReceivedDate = b.SO_Release_Date_in_SAP__c != null ? b.SO_Release_Date_in_SAP__c.format() : '';
            Integer daysBetweenbooking;
            String recivedPercentDate;
            Integer daysBetweenpercentRectillNow;
            if(isfivePercentTriggered){
                if(b.SO_Release_Date_in_SAP__c != null){
                    daysBetweenpercentRectillNow = b.SO_Release_Date_in_SAP__c.daysBetween(system.today());
                    recivedPercentDate = b.SO_Release_Date_in_SAP__c.format();
                    daysBetweenbooking = b.Booking_Date__c.date().daysBetween(b.SO_Release_Date_in_SAP__c);
                }else{
                    recivedPercentDate = system.today().format();
                    daysBetweenbooking = b.Booking_Date__c.date().daysBetween(system.today());
                }  
            }else{
                if(b.X9_90_Received_Date__c != null){
                    daysBetweenpercentRectillNow = b.X9_90_Received_Date__c.daysBetween(system.today());
                    recivedPercentDate = b.X9_90_Received_Date__c.format();
                    daysBetweenbooking = b.Booking_Date__c.date().daysBetween(b.X9_90_Received_Date__c);
                }else{
                    recivedPercentDate = system.today().format();
                    daysBetweenbooking = b.Booking_Date__c.date().daysBetween(system.today());
                }  
            }
            
            system.debug('daysBetweenpercentRectillNow ----->>>> '+daysBetweenpercentRectillNow);
            //Decimal percentagePaid = ((b.RW_Total_Amount_Received_Without_GST__c / b.Allotment_Premium__c) * 100).setScale(2, RoundingMode.HALF_UP);
            
                String recordString = b.Primary_Applicant_Name__c+ ',' + bookingDate + ',' + recivedPercentDate + ',' + daysBetweenbooking + ',' + daysBetweenpercentRectillNow + ',' + b.Unit_Number__c + ',' + b.RW_Project_Name__c + ',' + Math.round(b.Allotment_Premium__c) + ',' + Math.round(b.RW_Total_Amount_Received_Without_GST__c) + ',' + b.Payment_Received__c + '%' + ',' + b.Opportunity__r.SAP_Customer_Number__c + ',' + b.Opportunity__r.SalesOrder_Number__c 
                +'\n';
            body += recordString;
            System.debug('Booking Name: ' + b.Name + ', Flat: ' + b.Flat_No__c + ', RM Name: ' + b.Unit_No__r.Relationship_Manager__r.Name +', RM Id: '+b.Unit_No__r.Relationship_Manager__c);
            
        }
        
        return header + body;
    }
    
    global static String generateCSVContentforTL(List<Booking__c> bookings,Boolean isfivePercentTriggered) {
        String header = '';
        if(isfivePercentTriggered){
            header = 'RM Name,Name Of Customer,Booking Date,5% Payment Received Date,TAT of 5% Payment Received Date ,TAT from 5% payment received date till date ,Unit Number,Project Name,AV Value,Received Value,Percentage Paid,SAP Customer Number,SAP Salesorder Id\n';
        }else{
            header = 'RM Name,Name Of Customer,Booking Date,10% Payment Received Date,TAT of 10% Payment Received Date ,TAT from 10% payment received date till date ,Unit Number,Project Name,AV Value,Received Value,Percentage Paid,SAP Customer Number,SAP Salesorder Id\n';
        }
        String body = '';
        
        for (Booking__c b : bookings) {
            Date bookingDateTemp = b.Booking_Date__c.date();
            String bookingDate = bookingDateTemp.format();
            //String paymentReceivedDate = b.SO_Release_Date_in_SAP__c != null ? b.SO_Release_Date_in_SAP__c.format() : '';
            Integer daysBetweenbooking;
            String recivedPercentDate;
            Integer daysBetweenpercentRectillNow;
            if(isfivePercentTriggered){
                if(b.SO_Release_Date_in_SAP__c != null){
                    daysBetweenpercentRectillNow = b.SO_Release_Date_in_SAP__c.daysBetween(system.today());
                    recivedPercentDate = b.SO_Release_Date_in_SAP__c.format();
                    daysBetweenbooking = b.Booking_Date__c.date().daysBetween(b.SO_Release_Date_in_SAP__c);
                }else{
                    recivedPercentDate = system.today().format();
                    daysBetweenbooking = b.Booking_Date__c.date().daysBetween(system.today());
                }  
            }else{
                if(b.X9_90_Received_Date__c != null){
                    daysBetweenpercentRectillNow = b.X9_90_Received_Date__c.daysBetween(system.today());
                    recivedPercentDate = b.X9_90_Received_Date__c.format();
                    daysBetweenbooking = b.Booking_Date__c.date().daysBetween(b.X9_90_Received_Date__c);
                }else{
                    recivedPercentDate = system.today().format();
                    daysBetweenbooking = b.Booking_Date__c.date().daysBetween(system.today());
                }  
            }
            //Decimal percentagePaid = ((b.RW_Total_Amount_Received_Without_GST__c / b.Allotment_Premium__c) * 100).setScale(2, RoundingMode.HALF_UP);
            
            String recordString = b.RM_Name__c + ',' + b.Primary_Applicant_Name__c+ ',' + bookingDate + ',' + recivedPercentDate + ',' + daysBetweenbooking + ',' + daysBetweenpercentRectillNow + ',' + b.Unit_Number__c + ',' + b.RW_Project_Name__c + ',' + Math.round(b.Allotment_Premium__c) + ',' + Math.round(b.RW_Total_Amount_Received_Without_GST__c) + ',' + b.Payment_Received__c + '%' + ',' + b.Opportunity__r.SAP_Customer_Number__c + ',' + b.Opportunity__r.SalesOrder_Number__c 
                +'\n';
            body += recordString;
            System.debug('Booking Name: ' + b.Name + ', Flat: ' + b.Flat_No__c + ', RM Name: ' + b.Unit_No__r.Relationship_Manager__r.Name +', RM Id: '+b.Unit_No__r.Relationship_Manager__c);
            
        }
        
        return header + body;
    }
    
    global static list<Messaging.SingleEmailMessage> sendEmailstoRM(Map<Id, List<Booking__c>> groupedBookings, Boolean paymentReceivedX5) {
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Map<Id,User> rm_tlMap = new Map<Id,User>([Select Id,Email, ManagerId, Manager.Email from User where Id IN: groupedBookings.keySet()]);
        
        list<CustomNotificationType> notificationType = [SELECT Id,DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'PaymentNotificationtoRM'];   
        
        
        for (Id rmId : groupedBookings.keySet()) {
            String finalstr = '';
            list<String> ccAddress = new list<String>();
            list<String> toAddress = new list<String>();
            
            String nbody = '';
            String title = '';
            if(paymentReceivedX5){
                title = 'PAYMENT MILESTONE RECD 5%.';
                nbody = 'Please check your email for the attached list of customers who have completed 5% of their payment, but their registration remains pending. Kindly prioritize and proceed with the required follow-up.';
            }else{
                title = 'PAYMENT MILESTONE RECD 10%.';
                nbody = 'Please check your email for the attached list of customers who have completed 10% of their payment, but their registration remains pending. Kindly prioritize and proceed with the required follow-up.';
            }
            
            List<Booking__c> bookings = groupedBookings.get(rmId);
            
            String csvContent = generateCSVContentforRM(bookings,false);            
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
                //ccAddress.add(rm_tlMap.get(rmId).Manager.Email);
            }          
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            
            email.setOrgWideEmailAddressId('0D25j0000008QPACA2');
            
            if (!toAddress.isEmpty()) {
                email.setToAddresses(toAddress);//Original Email Id
                //email.setToAddresses(new List<String>{'prashant.chaurasia.os@runwalgroup.in'});//Testing Email Id
            }
            if (!ccAddress.isEmpty()) {
                //email.setCcAddresses(ccAddress);
                //email.setCcAddresses(new List<String>{'shraddha.shahari@runwalgroup.in'});//Testing Email Id
            } 
            
            
            String subject = '';
            String body = '';
            if(paymentReceivedX5){
                subject = 'NOTIFICATION : PAYMENT MILESTONE RECD 5%.';
                body = 'Dear Team,\n\nPlease find the attached details of the customers whose 5% payment is completed and Registration is not done.\n\nRegards,';
            }else{
                subject = 'NOTIFICATION : PAYMENT MILESTONE RECD 10%.';
                body = 'Dear Team,\n\nPlease find the attached details of the customers whose 10% payment is completed and Registration is not done.\n\nRegards,';
            }
            email.setSubject(subject);
            email.setPlainTextBody(body);
            
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName('Registration Not Done Customers Database.csv');
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
                customNotificationObj.send(new Set<String> {rmId});
                system.debug('Notification sent');
            }
        }
        
        //if (!emailList.isEmpty()) {
            return emailList;
            //Messaging.sendEmail(emailList);
        //}
    }
    
    global static list<Messaging.SingleEmailMessage> sendEmailstoTL(Map<Id, List<Booking__c>> groupedBookings,Boolean paymentReceivedX5) {
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Map<Id,User> rm_tlMap = new Map<Id,User>([Select Id,Email, ManagerId, Manager.Email from User where Id IN: groupedBookings.keySet()]);
        list<CustomNotificationType> notificationType = [SELECT Id,DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'PaymentNotificationtoRM'];   
       
        Map<Id,Project__c> projectNameVsProject = new Map<Id,Project__c>([Select id,Name,CRM_MIS_Head__r.Email,Home_Loan_Email__c,CRMHead__r.Email from Project__c]);
        
        for (Id tlId : groupedBookings.keySet()) {
            String finalstr = '';
            Set<String> ccAddress = new Set<String>();
            Set<String> toAddress = new Set<String>();
            
            String nbody = '';
            String title = '';
            if(paymentReceivedX5){
                title = 'NOTIFICATION : PAYMENT MILESTONE RECD 5%.';
                nbody = 'Please check your email for the attached list of customers who have completed 5% of their payment, but their registration remains pending. Kindly prioritize and proceed with the required follow-up.';
            }else{
                title = 'NOTIFICATION : PAYMENT MILESTONE RECD 10%.';
                nbody = 'Please check your email for the attached list of customers who have completed 10% of their payment, but their registration remains pending. Kindly prioritize and proceed with the required follow-up.';
            }
            
            System.debug('Manager User: ' + tlId);
            List<Booking__c> bookings = groupedBookings.get(tlId);
            
            String csvContent = generateCSVContentforTL(bookings,false);            
            Blob csvBlob = Blob.valueOf(csvContent);            
            
            if (rm_tlMap.get(tlId).Email != null){                
                toAddress.add(rm_tlMap.get(tlId).Email);
                //For testing purpose
                /*if (tlu.Email.endsWith('.invalid') && (tlu.Email == 'tejal.punjabi@runwalgroup.in.invalid' || tlu.Email == 'hiren.bhadra@runwalgroup.in.invalid')) {
String validEmail = tlu.Email.substring(0, tlu.Email.length() - 8);
toAddress.add(validEmail);
} else {
toAddress.add(tlu.Email);
}*/
            }          
            
            if (rm_tlMap.get(tlId).Manager != null && rm_tlMap.get(tlId).Manager.Email != null){
                //toAddress.add(rm_tlMap.get(tlId).Manager.Email);
            } 
            
            /*for(Booking__c b: bookings){
                if(projectNameVsProject.get(b.Project__c).CRM_MIS_Head__r.Email != null){
                    ccAddress.add(projectNameVsProject.get(b.Project__c).CRM_MIS_Head__r.Email);
                }
                if(projectNameVsProject.get(b.Project__c).CRMHead__r.Email != null){
                    ccAddress.add(projectNameVsProject.get(b.Project__c).CRMHead__r.Email);
                }
                if(projectNameVsProject.get(b.Project__c).Home_Loan_Email__c != null){
                    ccAddress.add(projectNameVsProject.get(b.Project__c).Home_Loan_Email__c);
                }
            }*/
            
            if (!toAddress.isEmpty()) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                String subject = '';
                String body = '';
                email.setOrgWideEmailAddressId('0D25j0000008QPACA2');
                
                if (paymentReceivedX5) {
                    subject = 'NOTIFICATION : PAYMENT MILESTONE RECD 5%.';
                    body = 'Dear Team,\n\nPlease find the attached details of the customers whose 5% payment is completed and Registration is not done.\n\nRegards,';
                } else {
                    subject = 'NOTIFICATION : PAYMENT MILESTONE RECD 10%.';
                    body = 'Dear Team,\n\nPlease find the attached details of the customers whose 10% payment is completed and Registration is not done.\n\nRegards,';
                }
                
                email.setSubject(subject);
                email.setToAddresses(new List<String>(toAddress)); // Original Email Ids
                //email.setToAddresses(new List<String>{'prashant.chaurasia.os@runwalgroup.in'});//Testing Email Id
                
                /*if (!ccAddress.isEmpty()) {
                    email.setCcAddresses(new List<String>(ccAddress));
                }*/
                
                email.setPlainTextBody(body);
                
                // Attach CSV file
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName('Registration Not Done Customers Database.csv');
                attachment.setBody(csvBlob);
                attachment.setContentType('text/csv');
                email.setFileAttachments(new List<Messaging.EmailFileAttachment>{attachment});
                
                emailList.add(email);
            }
            
            
            
            /*if (!notificationType.isEmpty()) {          
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
               customNotificationObj.send(new Set<String> {tlId});
           }*/
        }
        
        /*if (!emailList.isEmpty()) {
            Messaging.sendEmail(emailList);
        } */
        return emailList;
    }
    
    global static list<Messaging.SingleEmailMessage> sendEmailstoHeads(Map<Id, List<Booking__c>> groupedBookings,Boolean paymentReceivedX5) {
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Map<Id,User> projectHeadsIdVsEmailMap = new Map<Id,User>([Select Id,Email, ManagerId, Manager.Email from User where Id IN: groupedBookings.keySet()]);
        list<CustomNotificationType> notificationType = [SELECT Id,DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'PaymentNotificationtoRM'];   
       
        for (Id projectheadsId : groupedBookings.keySet()) {
            String finalstr = '';
            Set<String> ccAddress = new Set<String>();
            Set<String> toAddress = new Set<String>();
            
            String nbody = '';
            String title = '';
            if(paymentReceivedX5){
                title = 'NOTIFICATION : PAYMENT MILESTONE RECD 5%.';
                nbody = 'Please check your email for the attached list of customers who have completed 5% of their payment, but their registration remains pending. Kindly prioritize and proceed with the required follow-up.';
            }else{
                title = 'NOTIFICATION : PAYMENT MILESTONE RECD 10%.';
                nbody = 'Please check your email for the attached list of customers who have completed 10% of their payment, but their registration remains pending. Kindly prioritize and proceed with the required follow-up.';
            }
            
            System.debug('Project Head : ' + projectheadsId);
            List<Booking__c> bookings = groupedBookings.get(projectheadsId);
            
            String csvContent = generateCSVContentforTL(bookings,false);            
            Blob csvBlob = Blob.valueOf(csvContent);            
            
            if (projectHeadsIdVsEmailMap.get(projectheadsId).Email != null){                
                toAddress.add(projectHeadsIdVsEmailMap.get(projectheadsId).Email);
                //For testing purpose
                /*if (tlu.Email.endsWith('.invalid') && (tlu.Email == 'tejal.punjabi@runwalgroup.in.invalid' || tlu.Email == 'hiren.bhadra@runwalgroup.in.invalid')) {
String validEmail = tlu.Email.substring(0, tlu.Email.length() - 8);
toAddress.add(validEmail);
} else {
toAddress.add(tlu.Email);
}*/
            }          
            
           /* if (rm_tlMap.get(tlId).Manager != null && rm_tlMap.get(tlId).Manager.Email != null){
                toAddress.add(rm_tlMap.get(tlId).Manager.Email);
            } */
            
            /*for(Booking__c b: bookings){
                if(projectNameVsProject.get(b.Project__c).CRM_MIS_Head__r.Email != null){
                    ccAddress.add(projectNameVsProject.get(b.Project__c).CRM_MIS_Head__r.Email);
                }
                if(projectNameVsProject.get(b.Project__c).CRMHead__r.Email != null){
                    ccAddress.add(projectNameVsProject.get(b.Project__c).CRMHead__r.Email);
                }
                if(projectNameVsProject.get(b.Project__c).Home_Loan_Email__c != null){
                    ccAddress.add(projectNameVsProject.get(b.Project__c).Home_Loan_Email__c);
                }
            }*/
            
            if (!toAddress.isEmpty()) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                String subject = '';
                String body = '';
                email.setOrgWideEmailAddressId('0D25j0000008QPACA2');
                
                if (paymentReceivedX5) {
                    subject = 'NOTIFICATION : PAYMENT MILESTONE RECD 5%.';
                    body = 'Dear Team,\n\nPlease find the attached details of the customers whose 5% payment is completed and Registration is not done.\n\nRegards,';
                } else {
                    subject = 'NOTIFICATION : PAYMENT MILESTONE RECD 10%.';
                    body = 'Dear Team,\n\nPlease find the attached details of the customers whose 10% payment is completed and Registration is not done.\n\nRegards,';
                }
                
                email.setSubject(subject);
                email.setToAddresses(new List<String>(toAddress)); // Original Email Ids
                //email.setToAddresses(new List<String>{'prashant.chaurasia.os@runwalgroup.in'});//Testing Email Id
                
                /*if (!ccAddress.isEmpty()) {
                    email.setCcAddresses(new List<String>(ccAddress));
                }*/
                
                email.setPlainTextBody(body);
                
                // Attach CSV file
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName('Registration Not Done Customers Database.csv');
                attachment.setBody(csvBlob);
                attachment.setContentType('text/csv');
                email.setFileAttachments(new List<Messaging.EmailFileAttachment>{attachment});
                
                emailList.add(email);
            }
            
            
            
            /*if (!notificationType.isEmpty()) {          
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
               customNotificationObj.send(new Set<String> {tlId});
           }*/
        }
        
        /*if (!emailList.isEmpty()) {
            Messaging.sendEmail(emailList);
        }*/
        return emailList;
    }
    
    global static list<Messaging.SingleEmailMessage> sendEmailstoHomeLoanTeam(Map<String, List<Booking__c>> groupedBookings,Boolean paymentReceivedX5) {
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        list<CustomNotificationType> notificationType = [SELECT Id,DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'PaymentNotificationtoRM'];   
       
        for (String homeLoanEmail : groupedBookings.keySet()) {
            String finalstr = '';
            Set<String> ccAddress = new Set<String>();
            Set<String> toAddress = new Set<String>();
            
            String nbody = '';
            String title = '';
            if(paymentReceivedX5){
                title = 'NOTIFICATION : PAYMENT MILESTONE RECD 5%.';
                nbody = 'Please check your email for the attached list of customers who have completed 5% of their payment, but their registration remains pending. Kindly prioritize and proceed with the required follow-up.';
            }else{
                title = 'NOTIFICATION : PAYMENT MILESTONE RECD 10%.';
                nbody = 'Please check your email for the attached list of customers who have completed 10% of their payment, but their registration remains pending. Kindly prioritize and proceed with the required follow-up.';
            }
            
            System.debug('Project Home Loan Email : ' + homeLoanEmail);
            List<Booking__c> bookings = groupedBookings.get(homeLoanEmail);
            
            String csvContent = generateCSVContentforTL(bookings,false);            
            Blob csvBlob = Blob.valueOf(csvContent);            
            
            if (homeLoanEmail != null){                
                toAddress.add(homeLoanEmail);
                //For testing purpose
                /*if (tlu.Email.endsWith('.invalid') && (tlu.Email == 'tejal.punjabi@runwalgroup.in.invalid' || tlu.Email == 'hiren.bhadra@runwalgroup.in.invalid')) {
String validEmail = tlu.Email.substring(0, tlu.Email.length() - 8);
toAddress.add(validEmail);
} else {
toAddress.add(tlu.Email);
}*/
            }          
            
           /* if (rm_tlMap.get(tlId).Manager != null && rm_tlMap.get(tlId).Manager.Email != null){
                toAddress.add(rm_tlMap.get(tlId).Manager.Email);
            } */
            
            /*for(Booking__c b: bookings){
                if(projectNameVsProject.get(b.Project__c).CRM_MIS_Head__r.Email != null){
                    ccAddress.add(projectNameVsProject.get(b.Project__c).CRM_MIS_Head__r.Email);
                }
                if(projectNameVsProject.get(b.Project__c).CRMHead__r.Email != null){
                    ccAddress.add(projectNameVsProject.get(b.Project__c).CRMHead__r.Email);
                }
                if(projectNameVsProject.get(b.Project__c).Home_Loan_Email__c != null){
                    ccAddress.add(projectNameVsProject.get(b.Project__c).Home_Loan_Email__c);
                }
            }*/
            
            if (!toAddress.isEmpty()) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                String subject = '';
                String body = '';
                email.setOrgWideEmailAddressId('0D25j0000008QPACA2');
                
                if (paymentReceivedX5) {
                    subject = 'NOTIFICATION : PAYMENT MILESTONE RECD 5%.';
                    body = 'Dear Team,\n\nPlease find the attached details of the customers whose 5% payment is completed and Registration is not done.\n\nRegards,';
                } else {
                    subject = 'NOTIFICATION : PAYMENT MILESTONE RECD 10%.';
                    body = 'Dear Team,\n\nPlease find the attached details of the customers whose 10% payment is completed and Registration is not done.\n\nRegards,';
                }
                
                email.setSubject(subject);
                email.setToAddresses(new List<String>(toAddress)); // Original Email Ids
                //email.setToAddresses(new List<String>{'prashant.chaurasia.os@runwalgroup.in'});//Testing Email Id
                
                /*if (!ccAddress.isEmpty()) {
                    email.setCcAddresses(new List<String>(ccAddress));
                }*/
                
                email.setPlainTextBody(body);
                
                // Attach CSV file
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName('Registration Not Done Customers Database.csv');
                attachment.setBody(csvBlob);
                attachment.setContentType('text/csv');
                email.setFileAttachments(new List<Messaging.EmailFileAttachment>{attachment});
                
                emailList.add(email);
            }
            
            
            
            /*if (!notificationType.isEmpty()) {          
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
               customNotificationObj.send(new Set<String> {tlId});
           }*/
        }
        
       /* if (!emailList.isEmpty()) {
            Messaging.sendEmail(emailList);
        }*/
        return emailList;
    }
    
    global void finish(Database.BatchableContext bc) {
        System.debug('Batch execution completed');
    }
    
    public static void executeBatch() {
        BatchforPaymentReminderReporttoRM b = new BatchforPaymentReminderReporttoRM();
        Database.executeBatch(b, 10);
    }
}