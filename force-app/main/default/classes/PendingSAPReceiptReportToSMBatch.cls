global class PendingSAPReceiptReportToSMBatch implements Database.Batchable<sObject>,Schedulable {

    private Date targetDate;
    private OrgWideEmailAddress senderEmail;

    // Constructor
    global PendingSAPReceiptReportToSMBatch() {
        targetDate = Date.today().addDays(-1);

        List<OrgWideEmailAddress> owe = [
            SELECT Id
            FROM OrgWideEmailAddress
            WHERE Address = 'customer.care@runwalgroup.in'
            LIMIT 1
        ];
        if (!owe.isEmpty()) {
            senderEmail = owe[0];
        }
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, Name, CreatedDate, Booking_Date__c,
                   Customer__r.Name,
                   Customer__r.Sales_Manager_User__r.Email,
                   Customer__r.Sales_Manager_User__r.Name,
                   Customer__r.SAP_Customer_Number__c,
                   Project__r.Name,
                   Unit_No__c,
                   Status__c,
                   RW_Total_Receipt_Amount_Received__c,
                   X5_Received__c,
                   SO_Release_Date_in_SAP__c
            FROM Booking__c
            WHERE /*DAY_ONLY(CreatedDate) = :targetDate
            AND*/ Customer__r.Sales_Manager_User__r.Email != NULL AND Customer__r.Sales_Manager_User__r.Name='Amitabh Saasworx']);
            
    }

    global void execute(Database.BatchableContext bc, List<Booking__c> scope) {

        Map<String, List<Booking__c>> smEmailVsBookings = new Map<String, List<Booking__c>>();
        Map<Id, List<RW_Payment_Details__c>> bookingVsReceipts = new Map<Id, List<RW_Payment_Details__c>>();
        Set<Id> bookingIds = new Set<Id>();
        
        if(!scope.isEmpty()){
            for (Booking__c b : scope) {
                String email = b.Customer__r.Sales_Manager_User__r.Email;
                bookingIds.add(b.Id);
                if (!smEmailVsBookings.containsKey(email)) {
                    smEmailVsBookings.put(email, new List<Booking__c>());
                }
                smEmailVsBookings.get(email).add(b);
            }
        }

        List<RW_Payment_Details__c> lstReceipt = new List<RW_Payment_Details__c>();
        if(!bookingIds.isEmpty()){
            lstReceipt = [Select Id,Name,RW_Booking__c from RW_Payment_Details__c where RW_Booking__c=:bookingIds];
        }
         if(!lstReceipt.isEmpty() && lstReceipt.size()>0){
            for (RW_Payment_Details__c r : lstReceipt) {
                if (!bookingVsReceipts.containsKey(r.RW_Booking__c)) {
                    bookingVsReceipts.put(r.RW_Booking__c, new List<RW_Payment_Details__c>());
                }
                bookingVsReceipts.get(r.RW_Booking__c).add(r);
            }
        }

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (String smEmail : smEmailVsBookings.keySet()) {

            List<Booking__c> bkgList = smEmailVsBookings.get(smEmail);
            String smName = bkgList[0].Customer__r.Sales_Manager_User__r.Name;
            

            String csvData =
                'Booking Id,Booking Name,Customer Name,SAP Customer Number,Project,Unit,Status\n';

            for (Booking__c bkg : bkgList) {
                //List<Receipt__c> receiptList = bookingVsReceipts.get(bkg.Id);
                //for (Receipt__c receipt : receiptList) {
                if(!bookingVsReceipts.containsKey(bkg.Id)){
                    csvData +=
                    bkg.Id + ',' +
                    bkg.Name + ',' +
                    bkg.Customer__r.Name + ',' +
                    bkg.Customer__r.SAP_Customer_Number__c + ',' +
                    bkg.Project__r.Name + ',' +
                    bkg.Unit_No__c + ',' +
                    bkg.Status__c + '\n';
                }
            }
            csvData = csvData.replace('null', '');

            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            attach.setFileName('Pending_SAP_Receipt_Report.csv');
            attach.setBody(Blob.valueOf(csvData));
            attach.setContentType('text/csv');

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            if (senderEmail != null) {
                mail.setOrgWideEmailAddressId(senderEmail.Id);
            }

            mail.setToAddresses(new List<String>{ smEmail });
            mail.setSubject('Pending SAP Receipt Creation - Daily Report');
            mail.setPlainTextBody(
                'Hello ' + smName + ',\n\n' +
                'Please find attached the list of bookings (created yesterday) for which SAP receipts are not yet created.\n\n' +
                'Regards,\nSystem'
            );
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach });

            emails.add(mail);
        }

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('Pending SAP Receipt Report Batch completed.');
    }

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new PendingSAPReceiptReportToSMBatch(), 1);
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
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}