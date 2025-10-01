public class NonReleasedSalesordersReport  implements Schedulable{

    public void execute(SchedulableContext SC){
        nonReleasedSoReportProject();
        nonReleasedSoReportSM();
    }
    
    /*public static void nonReleasedSoReport(){
        nonReleasedSoReportProject();
        nonReleasedSoReportSM();
    }*/
    
    
    @future (callout=true)
    public static void nonReleasedSoReportProject(){
        Datetime dt = DateTime.newInstance(2024,12,01);
        List<Booking__c> bookings = [SELECT Id, Name, Booking_Date__c, Allotment_Premium__c, Opportunity__r.Name, Project__r.Name, Sales_Managers__c, Sales_Head__r.Name, Project__r.Sales_Head__r.Name, Opportunity__r.SAP_Customer_Number__c, Opportunity__r.SalesOrder_Number__c, Unit_Number__c, Status__c, RW_Total_Receipt_Amount_Received__c, Receipts__c, Receipts__r.Name  FROM Booking__c WHERE Id NOT IN (SELECT RW_Booking__c FROM RW_Welcome_Call__c) AND Status__c = 'Booking Confirmed' AND X5_Received__c = false AND SO_Release_Date_in_SAP__c = null AND Project__c != null AND CreatedDate >=: dt ORDER BY Project__c];
        if(bookings.size() > 0){
            
            List<String> toAddresses = System.label.Non_Released_SO_Report_Email_Ids.split(',');
            if(toAddresses.size() > 0){
                List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
                String header = 'Booking Id,Booking Name,Customer Name,Booking Date,SAP Customer Number,SalesOrder Number,Project,Unit Number,Status,Total Amount Received,Allotment Premium,Receipt \n';
                
                String data = header;
                for(Booking__c bkg : bookings){
                    Integer ageing = Date.valueOf(bkg.Booking_Date__c).daysBetween(Date.today());
                    data += bkg.Id + ',' + bkg.Name + ',' + bkg.Opportunity__r.Name + ',' + bkg.Booking_Date__c + ',' + bkg.Opportunity__r.SAP_Customer_Number__c + ',' + bkg.Opportunity__r.SalesOrder_Number__c + ',' + bkg.Project__r.Name + ',' + bkg.Unit_Number__c + ',' + bkg.Status__c + ',' + bkg.RW_Total_Receipt_Amount_Received__c + ',' + bkg.Allotment_Premium__c + ',' + bkg.Receipts__r.Name + ',' + '\n';
                }
                data = data.replace('null','');
                
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName('Non Release Salesorders.csv');
                attachment.setBody(Blob.valueOf(data));
                attachment.setContentType('text/csv');
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(toAddresses);
                mail.setSubject('Non Release Salesorders');
                mail.setPlainTextBody('Please find the reports attached.');
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
                emailsToSend.add(mail);
                
                if(emailsToSend.size() > 0){
                    Messaging.sendEmail(emailsToSend);
                }
                
            }
        }
        
    }
    
    @future (callout=true)
    public static void nonReleasedSoReportSM(){
        Datetime dt = DateTime.newInstance(2024,12,01);
        List<Booking__c> bookings = [SELECT Id, Name, Booking_Date__c, Allotment_Premium__c, Opportunity__r.Name, Project__r.Name, Sales_Managers__c, Sales_Head__r.Name, Project__r.Sales_Head__r.Name, Opportunity__r.SAP_Customer_Number__c, Opportunity__r.SalesOrder_Number__c, Unit_Number__c, Status__c, RW_Total_Receipt_Amount_Received__c, Receipts__c, Receipts__r.Name, Opportunity__r.RW_Sales_Associate__c  FROM Booking__c WHERE Id NOT IN (SELECT RW_Booking__c FROM RW_Welcome_Call__c) AND Status__c = 'Booking Confirmed' AND X5_Received__c = false AND SO_Release_Date_in_SAP__c = null AND Project__c != null AND CreatedDate >=: dt];
        if(bookings.size() > 0){
            Map<String, List<Booking__c>> smVsBkgMap = new Map<String, List<Booking__c>>();
            Set<String> smNames = new Set<String>();
            for(Booking__c bkg : bookings){
                if(String.isNotBlank(bkg.Opportunity__r.RW_Sales_Associate__c)){
                    if(smVsBkgMap.containsKey(bkg.Opportunity__r.RW_Sales_Associate__c)){
                        smVsBkgMap.get(bkg.Opportunity__r.RW_Sales_Associate__c).add(bkg);
                    }else{
                        smVsBkgMap.put(bkg.Opportunity__r.RW_Sales_Associate__c, new List<Booking__c>{bkg});
                    }
                    smNames.add(bkg.Opportunity__r.RW_Sales_Associate__c);
                }
            }
            List<User> smUsers = [SELECT Id, Name, Email FROM User WHERE Name =: smNames AND Profile.Name != 'Runwal Customer Portal'];
            Map<String, String> userNameVsEmail = new Map<String, String>();
            for(User usr : smUsers){
                userNameVsEmail.put(usr.Name, usr.Email);
            }
            List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
            String header = 'Booking Id,Booking Name,Customer Name,Booking Date,SAP Customer Number,SalesOrder Number,Project,Unit Number,Status,Total Amount Received,Allotment Premium,Receipt \n';
            for(String sm : userNameVsEmail.keySet()){
                if(smVsBkgMap.get(sm) != null && smVsBkgMap.get(sm).size() > 0){
                    String data = header;
                    for(Booking__c bkg : smVsBkgMap.get(sm)){
                        Integer ageing = Date.valueOf(bkg.Booking_Date__c).daysBetween(Date.today());
                        data += bkg.Id + ',' + bkg.Name + ',' + bkg.Opportunity__r.Name + ',' + bkg.Booking_Date__c +  ',' + bkg.Opportunity__r.SAP_Customer_Number__c + ',' + bkg.Opportunity__r.SalesOrder_Number__c + ',' + bkg.Project__r.Name + ',' + bkg.Unit_Number__c + ',' + bkg.Status__c + ',' + bkg.RW_Total_Receipt_Amount_Received__c + ',' + bkg.Allotment_Premium__c + ',' + bkg.Receipts__r.Name + ',' + '\n';
                    }
                    //List<String> toAddresses = new List<String>();
                    data = data.replace('null','');
                    //toAddresses.add(userNameVsEmail.get(sm));
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new List<String>{userNameVsEmail.get(sm)});
                    mail.setSubject('Non Release Salesorders' + ' - ' + sm);
                    mail.setPlainTextBody('Please find the report attached.');
                    
                    Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                    attachment.setFileName('Non Release Salesorders' + ' - ' + sm + '.csv');
                    attachment.setBody(Blob.valueOf(data));
                    attachment.setContentType('text/csv');
                    mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
                    
                    emailsToSend.add(mail);
                }
            }
            if(emailsToSend.size() > 0){
                Messaging.sendEmail(emailsToSend);
            }
        }
        
    }
    
   
}