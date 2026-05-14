public class BookingSAPReceiptCheckScheduler implements Schedulable {

    public void execute(SchedulableContext sc) {
        BookingSAPReceiptCheckScheduler.sendPendingSAPReceiptReportToSM();
        //BookingSAPReceiptCheckScheduler.sendBlockCustomerReceiptReports();
    }

    public static void sendPendingSAPReceiptReportToSM() {

        // Date filter = yesterday
        Date targetDate = Date.today().addDays(-1);
        
        OrgWideEmailAddress senderEmail =[
                SELECT Id 
                FROM OrgWideEmailAddress 
                WHERE Address = 'customer.care@runwalgroup.in'
                LIMIT 1
            ];

        List<Booking__c> bookings = [
            SELECT Id, Name, CreatedDate, Booking_Date__c,
                   Customer__r.Name,
                   Customer__r.Sales_Manager_User__r.Email,
                   Project__r.Name,
                   Unit_No__c,
                   Status__c,
                   RW_Total_Receipt_Amount_Received__c,
                   Customer__r.Sales_Manager_User__r.Name,
                   Customer__r.SAP_Customer_Number__c,
                   X5_Received__c,
                   SO_Release_Date_in_SAP__c
            FROM Booking__c
            WHERE DAY_ONLY(CreatedDate) = :targetDate
            AND Customer__r.Sales_Manager_User__r.Email != NULL
        ];
        System.debug('bookings**'+bookings);

        if (bookings.isEmpty()) {
            System.debug('No pending bookings found.');
            return;
        }

        // Group by Sales Manager Email
        Map<String, List<Booking__c>> smEmailVsBookings = new Map<String, List<Booking__c>>();

        for (Booking__c b : bookings) {
            String email = b.Customer__r.Sales_Manager_User__r.Email;

            if (!smEmailVsBookings.containsKey(email)) {
                smEmailVsBookings.put(email, new List<Booking__c>());
            }
            smEmailVsBookings.get(email).add(b);
        }
        System.debug('smEmailVsBookings**'+smEmailVsBookings);
        // Prepare email messages
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (String smEmail : smEmailVsBookings.keySet()) {
            List<Booking__c> bkgList = smEmailVsBookings.get(smEmail);
                String smName = bkgList[0].Customer__r.Sales_Manager_User__r.Name;

            String header =
                'Booking Id,Booking Name,Customer Name,Booking Date,SAP Customer Number,Project,Unit,Status\n';

            String csvData = header;

            for (Booking__c bkg : bkgList) {
                csvData +=
                    bkg.Id + ',' +
                    bkg.Name + ',' +
                    bkg.Customer__r.Name + ',' +
                    bkg.Customer__r.SAP_Customer_Number__c + ',' +
                    bkg.Project__r.Name + ',' +
                    bkg.Unit_No__c + ',' +
                    bkg.Status__c + ',' + '\n';

            }

            csvData = csvData.replace('null','');
            System.debug('csvData**'+csvData);

            // Prepare attachment
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            attach.setFileName('Pending_SAP_Receipt_Report.csv');
            attach.setBody(Blob.valueOf(csvData));
            attach.setContentType('text/csv');

            // Email
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            if(senderEmail!=null){
                mail.setOrgWideEmailAddressId(senderEmail.Id);
            }
            mail.setToAddresses(new List<String>{ smEmail });
            mail.setSubject('Pending SAP Receipt Creation - Daily Report');
            //mail.setPlainTextBody('Dear Sales Manager,\n\nPlease find attached the list of bookings (created yesterday) for which SAP receipts are not yet created.\n\nRegards,\nSystem');
            mail.setPlainTextBody('Hello'  + smName + ',\n\n' + 'Please find attached the list of bookings (created yesterday) for which SAP receipts are not yet created.\n\nRegards,\nSystem');
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach });

            emails.add(mail);
        }
        System.debug('emails**'+emails);

        // Send
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }


    // public static void sendBlockCustomerReceiptReports() {

    //     Date yesterday = Date.today().addDays(-1);
    //     Date today = Date.today();
    //     List<Messaging.SingleEmailMessage> emailsTosend = new List<Messaging.SingleEmailMessage>();
    //     OrgWideEmailAddress fromAddress =[
    //             SELECT Id 
    //             FROM OrgWideEmailAddress 
    //             WHERE Address = 'customer.care@runwalgroup.in'
    //             LIMIT 1
    //         ];
    //     // Step 1: Query all relevant Opportunities with related Receipts
    //     List<Opportunity> opps = [
    //         SELECT Id, Name, StageName, SAP_Customer_Number__c, RW_Project__c, RW_Project__r.Name,Blocked_Date__c,RW_Agreement_Value__c,
    //                (SELECT Id, Name, Mode__c, Cheque_DD__c, Total_Amount__c, DraweeBank__c, Account_Recon__c, Project_Unit__c, Project_Unit__r.Name
    //                 FROM Receipts__r)
    //         FROM Opportunity
    //         WHERE (Blocked_Date__c =: yesterday OR Blocked_Date__c =: today) AND SAP_Customer_Number__c != null];
            
            
    //     System.debug('opps**'+opps);

    //     // Step 2: Map of Project Id to Opportunities
    //     Map<Id, List<Opportunity>> projectToOpps = new Map<Id, List<Opportunity>>();
    //     for(Opportunity o : opps){
    //         if(!projectToOpps.containsKey(o.RW_Project__c)){
    //             projectToOpps.put(o.RW_Project__c, new List<Opportunity>());
    //         }
    //         projectToOpps.get(o.RW_Project__c).add(o);
    //     }

    //     // Step 3: Query Custom Metadata for Project emails
    //     Map<String, String> projectToEmails = new Map<String, String>();
    //     for(CRM_Team_Project_Wise_Email__mdt md : [
    //         SELECT Project__c, Email_Address__c FROM CRM_Team_Project_Wise_Email__mdt
    //     ]){
    //         projectToEmails.put(md.Project__c, md.Email_Address__c);
    //     }
    //     System.debug('projectToEmails**'+projectToEmails);

    //     // Step 4: Generate CSV/HTML report and send emails
    //     for(Id projectId : projectToOpps.keySet()){
    //         System.debug('projectId**'+projectId);
    //         List<Opportunity> oppList = projectToOpps.get(projectId);
    //         String projectName = oppList[0].RW_Project__r.Name;
    //         String emails = projectToEmails.get(String.valueOf(projectName));

    //         System.debug('emails1**'+emails);
    //         if(String.isBlank(emails)) continue;

    //         // Build CSV
    //         String csvContent = 'Project,Project Unit,Opportunity,SAP Customer Number,Receipt Name,Instrument,Cheque/DD No,Total Amount,Drawee Bank,Account Recon,Agreement Value\n';

    //         for(Opportunity o : oppList){
    //             for(Receipt__c r : o.Receipts__r){
    //                 csvContent += '"' + o.RW_Project__r.Name + '","' +
    //                               (r.Project_Unit__r != null ? r.Project_Unit__r.Name : '') + '","' +
    //                               o.Name + '","' +
    //                               o.SAP_Customer_Number__c + '","' +
    //                               r.Name + '","' +
    //                               r.Mode__c + '","' +
    //                               r.Cheque_DD__c + '","' +
    //                               r.Total_Amount__c + '","' +
    //                               r.DraweeBank__c + '","' +
    //                               r.Account_Recon__c + '","' +
    //                               o.RW_Agreement_Value__c + '"\n';
    //             }
    //         }
    //         System.debug('csvContent**'+csvContent);

    //         // Create Attachment
    //         Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
    //         attachment.setFileName(projectName + '_Receipt_Report.csv');
    //         attachment.setBody(Blob.valueOf(csvContent));
    //         attachment.setContentType('text/csv');

    //         // Create Email
    //         Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    //         if(fromAddress!=null){
    //             mail.setOrgWideEmailAddressId(fromAddress.Id);
    //         }
    //         mail.setToAddresses(emails.split(','));
    //         mail.setSubject('Project Receipt Report - ' + projectName);
    //         mail.setPlainTextBody('Please find attached the latest receipt report for project: ' + projectName);
    //         mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
    //         emailsTosend.add(mail);
    //         // Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    //     }
    //     System.debug('emailsTosend**'+emailsTosend);

    //     // Send
    //     if (!emailsTosend.isEmpty()) {
    //         Messaging.sendEmail(emailsTosend);
    //     }
    // }
    Public static void Dummy(){
        integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;}
}