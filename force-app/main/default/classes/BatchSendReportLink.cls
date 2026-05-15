global class BatchSendReportLink implements Database.Batchable<SObject>,Schedulable {

    public BatchSendReportLink() {}

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Booking_Source__c, Stake_Holder_Email__c, Project_Name__c 
            FROM Canvellation_Vertical__mdt
        ]);
    }

    global void execute(Database.BatchableContext BC, List<Canvellation_Vertical__mdt> scope) {
        if (!scope.isEmpty()) {
            System.enqueueJob(new DMLAndCalloutHandler(scope, 0));
        }
    }

    global void finish(Database.BatchableContext BC) {}
    global void execute(SchedulableContext dc) {
 
        BatchSendReportLink b = new BatchSendReportLink();
 
        Database.executeBatch(b, 50);
    }
    public class DMLAndCalloutHandler implements Queueable, Database.AllowsCallouts {
        private List<Canvellation_Vertical__mdt> records;
        private Integer index;

        public DMLAndCalloutHandler(List<Canvellation_Vertical__mdt> records, Integer index) {
            this.records = records;
            this.index = index;
        }
    
        public void execute(QueueableContext context) {
            if (index < records.size()) {
                Canvellation_Vertical__mdt record = records[index];

                try {
                    // Generate the report using SOQL
                    String reportCsv = generateReportCsv(record.Booking_Source__c, record.Project_Name__c);

                    // Prepare and send email with the CSV data
                    // Commented by Vinay 11-03-2025
                    /*sendEmailsWithAttachment(record.Stake_Holder_Email__c.split(','), reportCsv, record.Booking_Source__c, record.Project_Name__c);

                    // Enqueue the next job
                    if (index + 1 < records.size()) {
                        System.enqueueJob(new DMLAndCalloutHandler(records, index + 1));
                    }*/
                    if(reportCsv != null){
                        sendEmailsWithAttachment(record.Stake_Holder_Email__c.split(','), reportCsv, record.Booking_Source__c, record.Project_Name__c);
                        
                        // Enqueue the next job
                        if (index + 1 < records.size()) {
                            System.enqueueJob(new DMLAndCalloutHandler(records, index + 1));
                        }
                    }
                } catch (Exception e) {
                    System.debug('Error: ' + e.getMessage());
                }
            }
        }

        private String generateReportCsv(String bookingSource, String projectName) {
             Date thirtyDaysAgo = Date.today().addDays(-30);
            List<Booking__c> blist = [ SELECT Id,RW_Booking_Confirmed_Date__c,Formatted_Booking_Date__c,Customer__r.Name,Customer__r.RW_CIF_form_number__c,Customer__r.SAP_Customer_Number__c,Customer_Payment_Received1__c,Customer__r.RW_Agreement_Value__c,Customer__r.RW_Sourcing_Manager__c,Customer__r.Sourcing_Manager_User__c,Customer__r.Sourcing_Manager_User__r.Name,RM_Name__c,Bank_Loan_Status__c, Name, RW_Project_Name__c, Source_of_Booking__c ,Booking_Date__c,Flat_No__c
        FROM Booking__c 
        WHERE Source_of_Booking__c = :bookingSource 
          AND RW_Project_Name__c = :projectName  AND  Booking_Date__c >= :thirtyDaysAgo AND RW_Registration_Done__c='No']; //Added Customer__r.Sourcing_Manager_User__c,Customer__r.Sourcing_Manager_User__r.Name by Vinay 04-12-2025

           
            String header = 'Customer Name,Name,Project Name ,Source of Booking,Unit Number,Booking Date,Sourcing Manager,RM Name,Loan Status,Agreement Value,SAP Customer Number,CIF Number,Payment recieved% \n';
            //String finalstr = header;  //Commented by Vinay 11-03-2025
            String finalstr; //Added by Vinay 11-03-2025
            if(blist.size() > 0){ //Added by Vinay 11-03-2025
                finalstr = header; 
            }
for (Booking__c b : blist) {
    // Format RW_Booking_Confirmed_Date__c as dd-MM-yyyy
    String bookingDateFormatted = (b.Booking_Date__c != null) ? b.Booking_Date__c.format('dd-MM-yyyy') : '';
    
        // Handle null values for each field, replacing them with blank strings if null
        String customerName = (b.Customer__r.Name != null) ? b.Customer__r.Name : '';
        String name = (b.Name != null) ? b.Name : '';
        String projectNameField = (b.RW_Project_Name__c != null) ? b.RW_Project_Name__c : '';
        String sourceOfBooking = (b.Source_of_Booking__c != null) ? b.Source_of_Booking__c : '';
        String flatNo = (b.Flat_No__c != null) ? b.Flat_No__c : '';
        String sourcingManager = (b.Customer__r.Sourcing_Manager_User__c != null) ? b.Customer__r.Sourcing_Manager_User__r.Name : ''; // Replaced RW_Sourcing_Manager__c with Sourcing_Manager_User__r.Name by Vinay 04-12-2025
        String rmName = (b.RM_Name__c != null) ? b.RM_Name__c : '';
       
           
           String loanStatus = (b.Bank_Loan_Status__c != null && !String.isBlank(b.Bank_Loan_Status__c)) ? b.Bank_Loan_Status__c : '';

        String agreementValue = (b.Customer__r.RW_Agreement_Value__c != null) ? String.valueOf(b.Customer__r.RW_Agreement_Value__c) : '';
        String SAPNumber=(b.Customer__r.SAP_Customer_Number__c != null) ? String.valueOf(b.Customer__r.SAP_Customer_Number__c) : '';
        String CIFNumber=(b.Customer__r.RW_CIF_form_number__c != null) ? String.valueOf(b.Customer__r.RW_CIF_form_number__c) : '';
        String paymentReceived = (b.Customer_Payment_Received1__c != null) ? String.valueOf(b.Customer_Payment_Received1__c) : '';
        

    String recordString = b.Customer__r.Name + ',' + b.Name + ',' + b.RW_Project_Name__c + ',' + b.Source_of_Booking__c + ',' + b.Flat_No__c
        + ',' + bookingDateFormatted + ',' + b.Customer__r.Sourcing_Manager_User__r.Name + ',' + b.RM_Name__c + ',' + b.Bank_Loan_Status__c
        + ',' + b.Customer__r.RW_Agreement_Value__c +','+b.Customer__r.SAP_Customer_Number__c + ','+ b.Customer__r.RW_CIF_form_number__c + ',' + b.Customer_Payment_Received1__c + '\n'; // Replaced RW_Sourcing_Manager__c with Sourcing_Manager_User__r.Name by Vinay 04-12-2025
    
    finalstr += recordString;
}
return finalstr;

        }

        private void sendEmailsWithAttachment(List<String> emailAddresses, String csvData, String bookingSource, String projectName) {
            List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
               csvData = csvData.replace('null', '');
            for (String email : emailAddresses) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] { email });
                mail.setSubject('Report for ' + bookingSource + ' - ' + projectName);
                mail.setPlainTextBody('Please find the report data attached.');

                // Attach the CSV report
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName('Report_' + bookingSource + '_' + projectName + '.csv');
                attachment.setBody(Blob.valueOf(csvData));
                attachment.setContentType('text/csv');
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });

                emailsToSend.add(mail);
            }

            if (!emailsToSend.isEmpty()) {
                Messaging.sendEmail(emailsToSend);
            }
        }
    }
     
}