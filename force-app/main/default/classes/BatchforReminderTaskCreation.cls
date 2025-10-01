//Added by Prashant to Create Reminder tasks on due. 29-3-25.
global class BatchforReminderTaskCreation implements Database.Batchable <sObject>, Database.AllowsCallouts, Schedulable, Database.Stateful{
    
    global Map<String, String> crnVsremtoSend = new Map<String, String>();
    global list<Booking__c> bookings = new list<Booking__c>();
    
    global Iterable<Booking__c> start(Database.BatchableContext BC){
        String username = System.label.SAP_Username;
        String password = System.label.SAP_Password;
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        //String Endpoint = 'http://123.108.44.40:8002/zsfdc_perc_sync/perc_sync?sap-client=300';
        String Endpoint = System.label.Reminder_letter_sync;
        
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        req.setEndpoint(Endpoint);
        req.setMethod('GET');
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(12000);
        
        List<RespData> resp = new List<RespData>();
        Boolean hasReponse = false;
        if(!Test.isRunningTest()){
            HttpResponse response = http.send(req);
            System.debug('Response Body: ' + (response.getBody()));
            if(response.getBody() != '[{"ERROR_LOG":"No data found!"}]'){
                resp = (List<RespData>)JSON.deserialize(response.getBody(), List<RespData>.class);
                hasReponse = true;
            }
            system.debug('resp::'+resp);   
        }else{
            RespData r = new RespData();
            r.BUKRS = '1234';
            r.KUNNR = '789123';
            r.REMINDER_TO_SEND = 'Test';
            resp = new List<RespData>{r};
                hasReponse = true;
        }
        
        List<String> crnList = new List<String>();
        
        List<Booking__c> bkgs = new List<Booking__c>(); 
        if(resp.size() > 0 && hasReponse){
            for(RespData res : resp){
                //system.debug('Response received');
                crnList.add(res.KUNNR);
                crnVsremtoSend.put(res.BUKRS+'_'+res.KUNNR, res.REMINDER_TO_SEND);
            }
            system.debug('crnList'+crnList);
            system.debug('crnVsremtoSend'+crnVsremtoSend);
            
            bkgs = [SELECT Id, Booking_Date__c,Allotment_Premium__c,RW_Project_Name__c,Unit_Number__c,Primary_Applicant_Name__c,RM_Name__c,Project__c,Unit_No__r.Relationship_Manager__r.User__r.isActive,
                    Unit_No__r.TowerName__r.Legal_Entity__r.RDS_Company_Code__c,Opportunity__r.Name,Name,Tower__r.Legal_Entity__r.RDS_Company_Code__c,Opportunity__r.SAP_Customer_Number__c, 
                    Opportunity__r.SalesOrder_Number__c,Unit_No__r.Relationship_Manager__r.User__c FROM Booking__c WHERE
                    Status__c = 'Booking Confirmed' and Opportunity__r.StageName = 'Unit Booked' and  Opportunity__r.SAP_Customer_Number__c =: crnList];
            bookings = bkgs;
            system.debug('Response received'+bkgs);
            return bkgs;
        }else{
            return bkgs;
        }
        
    }
    
    global void execute(Database.BatchableContext bc, list <Booking__c> blist){
        {
            system.debug('blist'+blist);
            system.debug('blist size'+blist.size());
            system.debug('crnVsremtoSend'+crnVsremtoSend);
            Id ReminderLetterRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Reminder letter').getRecordTypeId();
            list<CustomNotificationType> notificationType = [SELECT Id,DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'PushNotificationtoSM'];
            list<Task> tasklisttoUpdate = new list<Task>();
            if(!blist.isEmpty()){
                for(Booking__c b : blist){ 
                    String remindertoSend = crnVsremtoSend.get(b.Unit_No__r.TowerName__r.Legal_Entity__r.RDS_Company_Code__c+'_'+b.Opportunity__r.SAP_Customer_Number__c);
                    system.debug('remindertoSend >>>>>>>>>>> '+remindertoSend);
                    //String title = remindertoSend;
                    //Sring body = 'Dear Team,\n\nPlease check your email for the attached list of customers on which brokerage schemes have been tagged. Kindly proceed with the required document verification.\n\nRegards,';
                    
                    /*if (!notificationType.isEmpty()) {          
                        Messaging.CustomNotification customNotificationObj = new Messaging.CustomNotification();      
                        if(Test.isRunningTest()){
                            customNotificationObj.setBody(Body);   
                        }
                        customNotificationObj.setTitle('Reminder for Visit Follow-Up');  
                        customNotificationObj.setNotificationTypeId(notificationType[0].id);                     
                        customNotificationObj.setTargetId(opp.Id);
                        customNotificationObj.send(new Set<String> {u.Id});
                    }*/
                    
                    Task t = new Task();
                    t.WhatId = b.Opportunity__r.id;
                    t.OwnerId = b.Unit_No__r.Relationship_Manager__r.User__c;
                    t.Visitor_Name__c = b.Opportunity__r.Name;
                    Date todayDate = System.today();
                    DateTime createTime = DateTime.newInstance(todayDate, Time.newInstance(8, 15, 0, 0));                
                    t.ActivityDate = system.today().addDays(7);                    
                    t.Status = 'In-progress';
                    t.Subject = remindertoSend;
                    t.Task_Type__c = 'Reminder letter';
                    t.Type = 'Other';
                    t.RecordTypeId = ReminderLetterRecordTypeId;
                    t.Type_Of_Meeting__c = 'Outbound';
                    t.Priority = 'Normal';                    
                    String nbody1 = 'Dear Team,\n\nPlease check your email for the attached list of customers on which payment reminder has been triggered. Please inform the customer about their upcoming or overdue payment and kindly follow up to ensure timely processing.\n\nRegards,';
                    t.Description = nbody1;                    
                    if (b.Project__c != null) {
                        t.Project__c = b.Project__c;
                    }                    
                    // Set Reminder Time at 8:15 AM
                    t.ReminderDateTime = createTime;
                    t.IsReminderSet = true;        
                    tasklisttoUpdate.add(t);
                    
                }   
            }
            else{
                system.debug('No Customers found');
            }
            if(!tasklisttoUpdate.isEmpty()){
                Database.SaveResult[] wiList = Database.insert(tasklisttoUpdate, false);
                
                for(Database.SaveResult sr : wiList){
                    if(!sr.isSuccess()){
                        for(Database.Error err : sr.getErrors()){
                            System.debug(err.getStatusCode() + ':' + err.getMessage());
                        }
                    }
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext bc){
		if (!bookings.isEmpty()) {
            Map<Id, List<Booking__c>> rmVsBookingMap = new Map<Id, List<Booking__c>>();
			system.debug('crnVsremtoSend'+crnVsremtoSend);            
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            
            for (Booking__c booking : bookings) {              
                Id rmId;
                if(booking.Unit_No__r.Relationship_Manager__r.User__r.isActive){
                    rmId = booking.Unit_No__r.Relationship_Manager__r.User__c; 
                }else{
                    rmId = UserInfo.getUserId();
                }                 
                if (!rmVsBookingMap.containsKey(rmId)) {
                    rmVsBookingMap.put(rmId, new List<Booking__c>());
                }
                rmVsBookingMap.get(rmId).add(booking);
            }
            system.debug('rmVsBookingMap----->>>>'+rmVsBookingMap);
            if(!rmVsBookingMap.isEmpty()){
                list<CustomNotificationType> notificationType = [SELECT Id,DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'PaymentNotificationtoRM'];   
                Map<Id,User> rmMap = new Map<Id,User>([Select Id,Email, ManagerId, Manager.Email from User where Id IN: rmVsBookingMap.keySet()]);
        
                //Generate CSV content.
                for (Id rmId : rmVsBookingMap.keySet()) {
                    String finalstr = '';
                    list<String> ccAddress = new list<String>();
                    list<String> toAddress = new list<String>();
                    
                    String nbody = '';
                    String title = '';
                    title = 'Payment Reminder Notification';
                    nbody = 'Dear Team,\n\nPlease check your email for the attached list of customers on which payment reminder has been triggered. Please inform the customer about their upcoming or overdue payment and kindly follow up to ensure timely processing.\n\nRegards,';
                    
                    List<Booking__c> bookings = rmVsBookingMap.get(rmId);
                    
                    String csvheader = '';
                    csvheader = 'RM Name,Name Of Customer,Booking Date,Unit Number,Project Name,AV Value,SAP Customer Number,SAP Salesorder,Reminder to Send\n';
                    String csvbody = '';
                    
                    for (Booking__c b : bookings) {
                        Date bookingDateTemp = b.Booking_Date__c.date();
                        String bookingDate = bookingDateTemp.format();
                        String remindertoSend = crnVsremtoSend.get(b.Unit_No__r.TowerName__r.Legal_Entity__r.RDS_Company_Code__c+'_'+b.Opportunity__r.SAP_Customer_Number__c);
                        System.debug('Booking Date: ' + bookingDate);
                        String recordString = b.RM_Name__c + ',' + b.Primary_Applicant_Name__c+ ',' + bookingDate + ',' + b.Unit_Number__c + ',' + b.RW_Project_Name__c + ',' + Math.round(b.Allotment_Premium__c) + ',' + b.Opportunity__r.SAP_Customer_Number__c + ',' + b.Opportunity__r.SalesOrder_Number__c + ','+remindertoSend
                            +'\n';
                        csvbody += recordString;
                    }
                    
                    String csvContent = csvheader + csvbody;            
                    Blob csvBlob = Blob.valueOf(csvContent);
                    
                    //Send Email                    
                    if (rmMap.get(rmId).Email != null){              
                        toAddress.add(rmMap.get(rmId).Email);
                        //toAddress.add('prashant.chaurasia.os@runwalgroup.in');
                    }           
                    
                    if (rmMap.get(rmId).Manager != null && rmMap.get(rmId).Manager.Email != null){
                        ccAddress.add(rmMap.get(rmId).Manager.Email);
                    }          
                    
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    
                    email.setOrgWideEmailAddressId('0D25j0000008QPACA2');
                    
                    if (!toAddress.isEmpty()) {
                        email.setToAddresses(toAddress);//Original Email Id
                        //email.setToAddresses(new List<String>{'prashant.chaurasia.os@runwalgroup.in'});//Testing Email Id
                    }
                    if (!ccAddress.isEmpty()) {
                        email.setCcAddresses(ccAddress);
                        //email.setCcAddresses(new List<String>{'shraddha.shahari@runwalgroup.in'});//Testing Email Id
                    } 
                    
                    
                    String subject = 'Reminder to send Customers';
                    String body = '';
                    title = 'Payment Reminder Notification';
                    body = 'Dear Team,\n\nPlease check your email for the attached list of customers on which payment reminder has been triggered. Please inform the customer about their upcoming or overdue payment and kindly follow up to ensure timely processing.\n\nRegards,';
                    
                    email.setSubject(subject);
                    email.setPlainTextBody(body);
                    
                    Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                    attachment.setFileName('Reminder to Send Customers.csv');
                    attachment.setBody(csvBlob); 
                    attachment.setContentType('text/csv'); 
                    email.setFileAttachments(new List<Messaging.EmailFileAttachment>{attachment});
                    emailList.add(email);                
                    
                    system.debug('finalstr'+finalstr);
                    
                    if (!notificationType.isEmpty()) {  
                        system.debug('Inside Notification sent');
                        Messaging.CustomNotification customNotificationObj = new Messaging.CustomNotification();              
                        customNotificationObj.setBody(body);                
                        customNotificationObj.setTitle(subject);  
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
                
                if (!emailList.isEmpty()) {
                    Messaging.sendEmail(emailList);
                }
                
            }
        }        
    }
    
    global void execute(SchedulableContext dc) {
        BatchforReminderTaskCreation b = new BatchforReminderTaskCreation();
        Database.executeBatch(b, 50);
    }
    
    global class RespData{
        public String BUKRS;
        public String KUNNR;
        public String REMINDER_TO_SEND;
    }
}