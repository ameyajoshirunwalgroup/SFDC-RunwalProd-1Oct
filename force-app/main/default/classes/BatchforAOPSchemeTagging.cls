global class BatchforAOPSchemeTagging implements Database.Batchable<sObject>,Database.Stateful {//, Schedulable   
    public list<Booking__c> bookingListToUpdate = new list<Booking__c>();
    Public static void callBatchforAOPSchemeTagging(){
        BatchforAOPSchemeTagging  bb = new BatchforAOPSchemeTagging();
        Database.executeBatch(bb,50);
    }
    global Database.QueryLocator start(Database.BatchableContext bc){
        system.debug('Inside start method----');
         return Database.getQueryLocator([SELECT Id, Name, Start_Date__c, End_Date__c, Legacy_booking_treated__c, Category__c, Channel_Partner__c, RecordTypeId 
                                  FROM AOP__c WHERE CreatedDate < TODAY AND RecordType.Name = 'AOP' AND Legacy_booking_treated__c = false]); 
    }
    
    global void execute(Database.BatchableContext bc, List<AOP__c> AOPScheme){
        system.debug('Inside execute method----');
        System.debug('AOPScheme --> ' + AOPScheme);
        System.debug('AOPScheme Size --> ' + AOPScheme.size());

        //List<Booking__c> bookingListToUpdate = new List<Booking__c>();
        List<AOP__c> AOPSchemetoUpdate = new List<AOP__c>();
        Map<Id, List<Booking__c>> aopIdvsBkListMap = new Map<Id, List<Booking__c>>();

        List<Date> startDates = new List<Date>();
        List<Date> endDates = new List<Date>();
        List<String> channelPartners = new List<String>();

        if (!AOPScheme.isEmpty()) {
            for (AOP__c aop : AOPScheme) {
                startDates.add(aop.Start_Date__c);
                endDates.add(aop.End_Date__c);
                if(!channelPartners.contains(aop.Channel_Partner__c)){
                    channelPartners.add(aop.Channel_Partner__c);
                }
            }
        }

        startDates.sort();
        endDates.sort();

        System.debug('Sorted startDates --> ' + startDates);
        System.debug('Sorted endDates --> ' + endDates);
         Date leastStartDate;
         Date atMostEndDate;
        leastStartDate = startDates[0];
       atMostEndDate = endDates[endDates.size() - 1];
        
        System.debug('Least startDate --> ' + leastStartDate);
        System.debug('At most endDate --> ' + atMostEndDate);
        list<Booking__c> bookingList = [SELECT Id, Quotation__r.Quote_Status__c, Quotation__r.Discount_9_L__c, Name, Opportunity__c, BrokerIId__c, Agreement_Value_for_brokers__c, Project__c, 
                              Booking_Date__c, Tower__c, X5_Received__c, RW_X9_99_Received__c, RW_Registration_Done__c, Brokerage_Scheme__c, Is_Special_Brokerage_Scheme__c, 
                              Type_Of_Client_Formula__c, CreatedDate, Opportunity__r.RW_Walkin_Channel_Partner__c,Project__r.CP_Invoice_Approver_L1__c,Project__r.CP_Invoice_Approver_L2__c,
                              Primary_Applicant_Name__c,Unit_Number__c,RW_Project_Name__c,Brokerage_Scheme_Name__c,Brokerage__c,Passback__c,
                              Opportunity__r.SAP_Customer_Number__c,Opportunity__r.SalesOrder_Number__c,Flat_No__c,Broker_Name__c
                       FROM Booking__c 
                       WHERE DAY_ONLY(CreatedDate) >= :leastStartDate AND DAY_ONLY(CreatedDate) <= :atMostEndDate 
                             AND Opportunity__r.RW_Walkin_Channel_Partner__c =: channelPartners
                             AND AOP_Scheme__c = null 
                             AND Status__c IN ('Booking Confirmed','UnProcessed','Sent for Approval')   
                             AND Quotation__r.Quote_Status__c = 'Valid' 
                             AND Quotation__r.Discount_9_L__c = null 
                       ORDER BY CreatedDate DESC];

        System.debug('Total Bookings Found: ' + bookingList.size());
        System.debug('Total AOP scheme Found: ' + AOPScheme.size());

         if (!bookingList.isEmpty() && !AOPScheme.isEmpty()) {
             for (AOP__c aop : AOPScheme) {
                 for (Booking__c bk : bookingList) {
                     if (bk.CreatedDate >= aop.Start_Date__c && bk.CreatedDate <= aop.End_Date__c && bk.Opportunity__r.RW_Walkin_Channel_Partner__c == aop.Channel_Partner__c) {
                        system.debug('Booking__c record ' + bk.Id + ' matches AOP__c ' + aop.Id);
                        
                        if (!aopIdvsBkListMap.containsKey(aop.Id)) {
                            aopIdvsBkListMap.put(aop.Id, new List<Booking__c>());
                            system.debug('Initialized new list for AOP Id: ' + aop.Id);
                        }
                        
                        aopIdvsBkListMap.get(aop.Id).add(bk);
                        system.debug('Added Booking__c ' + bk.Id + ' to AOP Id: ' + aop.Id);
                    } else {
                        system.debug('Booking__c ' + bk.Id + ' does not match AOP__c ' + aop.Id);
                    }
                 }
             }
         }
              
        System.debug('AOP ID to Booking List Map --> ' + aopIdvsBkListMap);
        
        for (Id aopId : aopIdvsBkListMap.keySet()) {
            for (Booking__c bk : aopIdvsBkListMap.get(aopId)) {
                if (!bookingListToUpdate.contains(bk)) {
                    bk.AOP_Scheme__c = aopId;
                    bk.Is_AOP_CP_Applicable__c = true;
                    bookingListToUpdate.add(bk);
                }
            }
        }

        System.debug('Total Bookings to Update --> ' + bookingListToUpdate.size());
        System.debug('bookingListToUpdate: ' + bookingListToUpdate);

        if (!bookingListToUpdate.isEmpty()) {
            Database.update(bookingListToUpdate, false);
        }
        
        List<AOP__c> aopRecordsToUpdate = [SELECT Id, Legacy_booking_treated__c FROM AOP__c WHERE Id IN :aopIdvsBkListMap.keySet()];
        for (AOP__c aop : aopRecordsToUpdate) {
            aop.Legacy_booking_treated__c = true;
        }
        update aopRecordsToUpdate;
    }
    /*
    global void finish(Database.BatchableContext bc) {
        System.debug('I ma in Finish Method----');
        System.debug('I ma in Finish Method----'+bookingListToUpdate);
       Map<String,list<Booking__c>> cpappId1vsBookingListMap = new Map<String,list<Booking__c>>();
               Map<String,list<Booking__c>> cpappId2vsBookingListMap = new Map<String,list<Booking__c>>();
        
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Map<Id,User> cpUsers_Map = new Map<Id,User>([Select id,name,Email from user where Profile.Name = 'CP Access' or Profile.Name = 'CP Billing Access']);
        
        list<CustomNotificationType> notificationType = [SELECT Id,DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'PaymentNotificationtoRM'];   
        
        String header = 'Name Of Customer,Booking Date,Unit Number,Project Name,Brokerage Scheme,Brokerage,Passback,SAP Customer Number,SAP Salesorder Id\n';
        String body = '';  
        
        for(Booking__c b:bookingListToUpdate){
            if(b.Project__r.CP_Invoice_Approver_L1__c != null && b.Project__r.CP_Invoice_Approver_L2__c != null){               
                Id cpAppr1;
                if(b.Project__r.CP_Invoice_Approver_L1__c != null)
                	cpAppr1 = b.Project__r.CP_Invoice_Approver_L1__c;
                else
                    cpAppr1 = UserInfo.getUserId();
                Id cpAppr2;
                if(b.Project__r.CP_Invoice_Approver_L2__c != null)
                	cpAppr2 = b.Project__r.CP_Invoice_Approver_L2__c;
                else
                    cpAppr2 = UserInfo.getUserId();
                if (!cpappId1vsBookingListMap.containsKey(cpAppr1)) {
                    cpappId1vsBookingListMap.put(cpAppr1, new List<Booking__c>());
                }
                cpappId1vsBookingListMap.get(cpAppr1).add(b);
                if (!cpappId2vsBookingListMap.containsKey(cpAppr2)) {
                    cpappId2vsBookingListMap.put(cpAppr2, new List<Booking__c>());
                }
                cpappId1vsBookingListMap.get(cpAppr2).add(b);
            }
        }
        
        for (Id cpId : cpappId1vsBookingListMap.keySet()) {  
            list<String> ccAddress = new list<String>();
            list<String> toAddress = new list<String>();
            List<Booking__c> bookings = cpappId1vsBookingListMap.get(cpId);
            if(!bookings.isEmpty()){
                for(Booking__c b: bookings){
                    Date bookingDateTemp = b.Booking_Date__c.date();
                    String bookingDate = bookingDateTemp.format();
                    System.debug('Booking Date: ' + bookingDate);
                    String recordString = b.Primary_Applicant_Name__c+ ',' + bookingDate + ',' + b.Unit_Number__c + ',' + b.RW_Project_Name__c + ',' + b.Brokerage_Scheme_Name__c + ',' + b.Brokerage__c + ',' + b.Passback__c + ',' + b.Opportunity__r.SAP_Customer_Number__c + ',' + b.Opportunity__r.SalesOrder_Number__c 
                        +'\n';
                    body += recordString;
                    System.debug('Booking Name: ' + b.Name + ', Flat: ' + b.Flat_No__c);  
                    
                }    
            }   
            
            if (cpUsers_Map.get(cpId).Email != null){              
                toAddress.add(cpUsers_Map.get(cpId).Email);
            }           
            
            if (cpUsers_Map.get(cpId).Manager != null && cpUsers_Map.get(cpId).Manager.Email != null){
                ccAddress.add(cpUsers_Map.get(cpId).Manager.Email);
            }          
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            
            email.setOrgWideEmailAddressId('0D25j0000008QPACA2');
            
            if (!toAddress.isEmpty()) {
                //email.setToAddresses(toAddress);//Original Email Id
                email.setToAddresses(new List<String>{'prashant.chaurasia.os@runwalgroup.in'});//Testing Email Id
            }
            if (!ccAddress.isEmpty()) {
                //email.setCcAddresses(ccAddress);
                //email.setCcAddresses(new List<String>{'shraddha.shahari@runwalgroup.in'});//Testing Email Id
            } 
            String csvContent = header + body;            
        Blob csvBlob = Blob.valueOf(csvContent);
        
        email.setSubject('List of customers whose AOP scheme have been tagged');
            email.setPlainTextBody(body);
            
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName('Database.csv');
            attachment.setBody(csvBlob); 
            attachment.setContentType('text/csv'); 
            email.setFileAttachments(new List<Messaging.EmailFileAttachment>{attachment});
            emailList.add(email);                
            
        }

        
        if (!emailList.isEmpty()) {
            Messaging.sendEmail(emailList);																																																																																																																																																																																																																																																																																																													
        }
    }
    
    
    */
    
    global void finish(Database.BatchableContext bc) {
    System.debug('Inside Finish Method');

    System.debug('Total Bookings Retrieved: ' + bookingListToUpdate.size());

        if(bookingListToUpdate.size()>0){
            Map<Id, User> cpUsers_Map = new Map<Id, User>(
                [SELECT Id, Name, Email, Manager.Email FROM User WHERE Profile.Name IN ('CP Access', 'CP Billing Access')]
            );
            system.debug('cpUsers_Map'+cpUsers_Map);
            Map<Id, List<Booking__c>> approverVsBookings = new Map<Id, List<Booking__c>>();
            
            for (Booking__c b : bookingListToUpdate) {
                if (b.Project__c != null) {
                    Id approver1 = b.Project__r.CP_Invoice_Approver_L1__c;
                    Id approver2 = b.Project__r.CP_Invoice_Approver_L2__c;
                    
                    List<Id> approvers = new List<Id>();
                    if (approver1 != null) approvers.add(approver1);
                    if (approver2 != null) approvers.add(approver2);
                    
                    for (Id approver : approvers) {
                        if (!approverVsBookings.containsKey(approver)) {
                            approverVsBookings.put(approver, new List<Booking__c>());
                        }
                        approverVsBookings.get(approver).add(b);
                    }
                } 
            }
            
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            String header = 'Name Of Customer,Booking Date,Unit Number,Project Name,Broker Name,Brokerage Scheme,Brokerage,Passback,SAP Customer Number,SAP Salesorder Id\n';
            
            system.debug('approverVsBookings'+approverVsBookings);
            for (Id approverId : approverVsBookings.keySet()) {
                List<String> toAddress = new List<String>(); 
                //List<String> toAddress = (approver.Email != null) ? new List<String>{approver.Email} : new List<String>();
                if(!Test.isRunningTest()){
                    if(cpUsers_Map != null && cpUsers_Map.get(approverId).Email != null){
                        toAddress.add(cpUsers_Map.get(approverId).Email);
                    }
                }
                //toAddress = new List<String>{'prashant.chaurasia.os@runwalgroup.in'}; 
                list<String> ccAddress = new list<String>();
                if(!Test.isRunningTest()){
                    if(cpUsers_Map != null && cpUsers_Map.get(approverId).Manager.Email != null){
                        ccAddress.add(cpUsers_Map.get(approverId).Manager.Email);
                    }
                }
                List<Booking__c> bookings = approverVsBookings.get(approverId);
                String body = '';
                
                for (Booking__c b : bookings) {
                    Date bookingDateTemp = b.Booking_Date__c.date();
                    String bookingDate = bookingDateTemp.format();
                    System.debug('Booking Date: ' + bookingDate);
                    body += b.Primary_Applicant_Name__c + ',' + bookingDate + ',' + b.Unit_Number__c + ',' + b.RW_Project_Name__c + ',' + b.Broker_Name__c + ',' + b.Brokerage_Scheme_Name__c + ',' + b.Brokerage__c + ',' + b.Passback__c + ',' + b.Opportunity__r.SAP_Customer_Number__c + ',' + b.Opportunity__r.SalesOrder_Number__c + '\n';
                }
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setOrgWideEmailAddressId('0D25j0000008QPACA2');
                email.setToAddresses(toAddress);
                email.setCcAddresses(ccAddress);
                email.setSubject('List of Customers for Your Projects');
                email.setPlainTextBody('Please find the attached list of bookings for your approval.');
                
                String csvContent = header + body;            
                Blob csvBlob = Blob.valueOf(csvContent);
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                if(!Test.isRunningTest()){
                    attachment.setFileName('Bookings_For_Approver_' + cpUsers_Map.get(approverId).Name.replace(' ', '_') + '.csv');
                    attachment.setBody(csvBlob);
                    attachment.setContentType('text/csv');
                    email.setFileAttachments(new List<Messaging.EmailFileAttachment>{attachment});
                    
                    emailList.add(email);
                }
            }
            
            if (!emailList.isEmpty()) {
                Messaging.sendEmail(emailList);
                System.debug('Emails Sent: ' + emailList.size());
            }
            
            
        }
}    
}