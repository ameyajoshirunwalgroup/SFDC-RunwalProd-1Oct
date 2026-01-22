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
                              Type_Of_Client_Formula__c, CreatedDate, Opportunity__r.RW_Walkin_Channel_Partner__c,
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

    //Added by Dolly
    global void finish(Database.BatchableContext bc) {
        System.debug('Inside Finish Method');
        System.debug('Total Bookings Retrieved: ' + bookingListToUpdate.size());

        if (bookingListToUpdate.isEmpty()) {
            return;
        }

        // Fetch CP Users (Approvers + Managers)
        Map<Id, User> cpUsers_Map = new Map<Id, User>(
            [SELECT Id, Name, Email, Manager.Email 
            FROM User 
            WHERE Profile.Name IN ('CP Access', 'CP Billing Access')]
        );

        // Collect Project IDs
        Set<Id> projectIds = new Set<Id>();
        for (Booking__c b : bookingListToUpdate) {
            if (b.Project__c != null) {
                projectIds.add(b.Project__c);
            }
        }   

        // Fetch approvers mapped by project
        Map<Id, Map<String, Team_Members__c>> projectIdToApproversMap =TeamMemberService.getProjectTeamMembers(projectIds, 'CP Approvers Team', new List<String>{ 'CP MIS', 'CP Invoice Approver L1' });

        Map<Id, List<Booking__c>> approverVsBookings = new Map<Id, List<Booking__c>>();
        for (Booking__c b : bookingListToUpdate) {
            if (b.Project__c != null && projectIdToApproversMap.containsKey(b.Project__c)) {
                Map<String, Team_Members__c> approverMap = projectIdToApproversMap.get(b.Project__c);
                if(approverMap!=null){
                    Team_Members__c approverMIS = approverMap.get('CP MIS');
                    Team_Members__c approverL1  = approverMap.get('CP Invoice Approver L1');

                    //Add MIS User
                     if (approverMIS != null && approverMIS.User__c != null) {
                        if (!approverVsBookings.containsKey(approverMIS.User__c)) {
                            approverVsBookings.put(approverMIS.User__c, new List<Booking__c>());
                        }
                        approverVsBookings.get(approverMIS.User__c).add(b);
                    }

                    // Add L1 Approver
                    if (approverL1 != null && approverL1.User__c != null) {
                        if (!approverVsBookings.containsKey(approverL1.User__c)) {
                            approverVsBookings.put(approverL1.User__c, new List<Booking__c>());
                        }
                        approverVsBookings.get(approverL1.User__c).add(b);
                    }
                }

            } 
        }
        System.debug('approverVsBookings => ' + approverVsBookings);

        // Build & send all emails
        List<Messaging.SingleEmailMessage> emailList = buildEmailsForApprovers(approverVsBookings, cpUsers_Map);

        if (!emailList.isEmpty()) {
            Messaging.sendEmail(emailList);
            System.debug('Emails Sent: ' + emailList.size());
        }
    }  

    //Added by Dolly
    private OrgWideEmailAddress getOrgWideEmail() {
        try {
            return [
                SELECT Id 
                FROM OrgWideEmailAddress 
                WHERE DisplayName = 'CRM Gardens'
                LIMIT 1
            ];
        } catch (Exception ex) {
            System.debug('OWEA not found: ' + ex.getMessage());
            return null;
        }
    }

    //Added by Dolly
    private List<Messaging.SingleEmailMessage> buildEmailsForApprovers(Map<Id, List<Booking__c>> approverVsBookings, Map<Id, User> cpUsers_Map) {

        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        // Fetch org-wide email once
        OrgWideEmailAddress owea = getOrgWideEmail();

        String header = 'Name Of Customer,Booking Date,Unit Number,Project Name,Broker Name,Brokerage Scheme,Brokerage,Passback,SAP Customer Number,SAP Salesorder Id\n';

        for (Id approverId : approverVsBookings.keySet()) {
            User approverUser = cpUsers_Map.get(approverId);
            // Skip if no user / no email
            if (approverUser == null || String.isBlank(approverUser.Email)) {
                System.debug('Skipping approver with no email: ' + approverId);
                continue;
            }

            // Build recipient lists
            List<String> toAddress = new List<String>();
            List<String> ccAddress = new List<String>();

            if (cpUsers_Map != null && approverUser.Email != null) {
                toAddress.add(approverUser.Email);
            }

            if (cpUsers_Map != null && approverUser.Manager != null && approverUser.Manager.Email != null) {
                ccAddress.add(approverUser.Manager.Email);
            }
            system.debug('toAddress---->'+toAddress);
            system.debug('ccAddress---->'+ccAddress);

            // Build CSV body
            String body = '';
            for (Booking__c b : approverVsBookings.get(approverId)) {
                String bookingDate = b.Booking_Date__c != null ?
                                    b.Booking_Date__c.format() : '';
                
                body += b.Primary_Applicant_Name__c + ',' +
                        bookingDate + ',' +
                        b.Unit_Number__c + ',' +
                        b.RW_Project_Name__c + ',' +
                        b.Broker_Name__c + ',' +
                        b.Brokerage_Scheme_Name__c + ',' +
                        b.Brokerage__c + ',' +
                        b.Passback__c + ',' +
                        b.Opportunity__r.SAP_Customer_Number__c + ',' +
                        b.Opportunity__r.SalesOrder_Number__c + '\n';
            }

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setOrgWideEmailAddressId(owea.Id);
            email.setToAddresses(toAddress);
            email.setCcAddresses(ccAddress);
            email.setSubject('List of Customers for Your Projects');
            email.setPlainTextBody('Please find the attached list of bookings for your approval.');

            // CSV Attachment
            Blob csvBlob = Blob.valueOf(header + body);
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();

            attachment.setFileName('Bookings_For_Approver_' + approverUser.Name.replace(' ', '_') + '.csv');
            attachment.setBody(csvBlob);
            attachment.setContentType('text/csv');

            email.setFileAttachments(new List<Messaging.EmailFileAttachment>{ attachment });

            emailList.add(email);
        }

        return emailList;
    }  
}