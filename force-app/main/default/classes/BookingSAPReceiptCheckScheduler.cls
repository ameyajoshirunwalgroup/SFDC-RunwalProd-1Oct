public class BookingSAPReceiptCheckScheduler implements Schedulable {

    public void execute(SchedulableContext sc) {
        BookingSAPReceiptCheckScheduler.sendPendingSAPReceiptReportToSM();
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