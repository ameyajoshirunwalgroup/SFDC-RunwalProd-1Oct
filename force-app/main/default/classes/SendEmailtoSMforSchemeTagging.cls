public class SendEmailtoSMforSchemeTagging {
	 public static void SendEmailtoSMforSchemeTagging(list<Id> bids){
        
        List<Booking__c> bList = [SELECT Id, Name,Unit_No__r.Relationship_Manager__r.User__r.IsActive, Unit_No__r.Relationship_Manager__r.User__c,Primary_Applicant_Name__c,Flat_No__c,Unit_No__r.Relationship_Manager__r.RM_Email__c,Unit_No__r.Relationship_Manager__r.TL_Email__c,SO_Release_Date_in_SAP__c,
                                  Project__r.Name,RW_Total_Receipt_Amount_Received__c,Allotment_Premium__c,Booking_Date__c,Unit_No__r.TowerName__r.Name,Unit_Number__c,Zone__c,Opportunity__r.SAP_Customer_Number__c,Opportunity__r.SalesOrder_Number__c,RM_Name__c,
                                  Payment_Received__c,X5_Received__c,X5_Received_Date__c,RW_X9_99_Received__c,X9_90_Received_Date__c,Unit_No__r.Relationship_Manager__r.Name,RW_Total_Amount_Received_Without_GST__c,RW_Project_Name__c,
                                  Unit_No__r.Relationship_Manager__r.User__r.Manager.Id,Customer__r.StageName,RW_BRL_Number__c,Status__c,RW_Registration_Date__c,Project__r.CRM_MIS_Head__c,Project__r.Overall_CRM_Head__c,
                                  Project__r.Home_Loan_Email__c,Project__r.CRMHead__c,Sales_Manager__c,Brokerage__c,Sales_Manager__r.Name
                                  FROM Booking__c
                                  WHERE Id IN: bids and Sales_Manager__c != null and Sales_Manager__r.IsActive = true order by Booking_Date__c desc 
                                 ];
         system.debug('bList'+bList);
         system.debug('user active'+bList[0].Sales_Manager__c);
         system.debug('user id--'+bList[0].Brokerage__c);
         system.debug('5% received+'+bList[0].Primary_Applicant_Name__c);
         system.debug('10% received+'+bList[0].Unit_Number__c);
         system.debug('registration date+'+bList[0].RW_Project_Name__c);
         system.debug('brl number+'+bList[0].Allotment_Premium__c);
        if (!bList.isEmpty()) {
            Map<Id, List<Booking__c>> SalesManagerVsBookingMap = new Map<Id, List<Booking__c>>();
            
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            
            for (Booking__c booking : bList) {              
                Id smId = booking.Sales_Manager__c;                   
                if (!SalesManagerVsBookingMap.containsKey(smId)) {
                    SalesManagerVsBookingMap.put(smId, new List<Booking__c>());
                }
                SalesManagerVsBookingMap.get(smId).add(booking);
            }
            system.debug('SalesManagerVsBookingMap----->>>>'+SalesManagerVsBookingMap);
            if(!SalesManagerVsBookingMap.isEmpty()){
                sendEmails(SalesManagerVsBookingMap);
            }
        }
        
        
     } 	
    
    public static void sendEmails(Map<Id, List<Booking__c>> SalesManagerVsBookingMap) {
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Map<Id,User> smUserMap = new Map<Id,User>([Select Id,Email,ManagerId,Manager.Email from User where Id IN: SalesManagerVsBookingMap.keySet()]);
        
        list<CustomNotificationType> notificationType = [SELECT Id,DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'PaymentNotificationtoRM'];   
        
        
        for (Id smId : SalesManagerVsBookingMap.keySet()) {
            String finalstr = '';
            list<String> ccAddress = new list<String>();
            list<String> toAddress = new list<String>();
            
            String nbody = '';
            String title = '';
            title = 'BROKERAGE SCHEME TAGGED..PLEASE PROCEED WITH DOCUMENT VERIFICATION!';
            nbody = 'Please check your email for the attached list of customers on which brokerage schemes have been tagged. Kindly proceed with the required document verification.';
            
            List<Booking__c> bookings = SalesManagerVsBookingMap.get(smId);
            
            String csvContent = generateCSVContent(bookings);   
            system.debug('csvContent'+csvContent);
            Blob csvBlob;
            if(!Test.isRunningTest()){
                csvBlob = Blob.valueOf(csvContent);
            }
            if (smUserMap.get(smId).Email != null){              
                toAddress.add(smUserMap.get(smId).Email);
                //toAddress.add('prashant.chaurasia.os@runwalgroup.in');
            }           
            
            if (smUserMap.get(smId).Manager != null && smUserMap.get(smId).Manager.Email != null){
                //ccAddress.add(smUserMap.get(smId).Manager.Email);
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
             title = 'BROKERAGE SCHEME TAGGED..PLEASE PROCEED WITH DOCUMENT VERIFICATION!';
            body = 'Dear Team,\n\nPlease check your email for the attached list of customers on which brokerage schemes have been tagged. Kindly proceed with the required document verification.\n\nRegards,';
            
            email.setSubject(subject);
            email.setPlainTextBody(body);
            
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName('Brokerage Scheme Tagged Customers.csv');
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
                customNotificationObj.send(new Set<String> {smId});
                //customNotificationObj.send(new Set<String> {'0055j000007G2SJAA0'});//Test Id
                system.debug('Notification sent');
            }
        }
        if(!Test.isRunningTest()){
            if (!emailList.isEmpty()) {            
                Messaging.sendEmail(emailList);           
            }
        }
    }
    
    public static String generateCSVContent(List<Booking__c> bookings) {
        String header = '';
        header = 'Sales Manager,Name Of Customer,Booking Number,Booking Date,Unit Number,Project Name,AV Value,SAP Customer Number,SAP Salesorder,Brokerage %\n';
        String body = '';
        
        for (Booking__c b : bookings) {
            Date bookingDateTemp = b.Booking_Date__c.date();
            String bookingDate = bookingDateTemp.format();
            System.debug('Booking Date: ' + bookingDate);
            system.debug('Sales_Manager__r.Name'+b.Sales_Manager__r.Name);
            System.debug('Primary_Applicant_Name__c: ' + b.Primary_Applicant_Name__c);
            System.debug('Name: ' + b.Name);
            System.debug('Unit_Number__c: ' + b.Unit_Number__c);
            System.debug('RW_Project_Name__c: ' + b.RW_Project_Name__c);
            System.debug('Allotment_Premium__c: ' + b.Allotment_Premium__c);
            System.debug('SAP_Customer_Number__c: ' + b.Opportunity__r.SAP_Customer_Number__c);
            System.debug('SalesOrder_Number__c: ' + b.Opportunity__r.SalesOrder_Number__c);
            System.debug('Brokerage__c: ' + b.Brokerage__c);
                String recordString = b.Sales_Manager__r.Name + ',' + b.Primary_Applicant_Name__c+ ',' + b.Name + ',' + bookingDate + ',' + b.Unit_Number__c + ',' + b.RW_Project_Name__c + ',' + Math.round(b.Allotment_Premium__c) + ',' + b.Opportunity__r.SAP_Customer_Number__c + ',' + b.Opportunity__r.SalesOrder_Number__c+ ',' + b.Brokerage__c 
                +'\n';
            body += recordString;
            System.debug('Booking Name: ' + b.Name + ', Flat: ' + b.Flat_No__c + ', RM Name: ' + b.Unit_No__r.Relationship_Manager__r.Name +', RM Id: '+b.Unit_No__r.Relationship_Manager__c);
        }
        
        return header + body;
    }
 
    
    
    
    
}