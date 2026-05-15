@RestResource(urlMapping='/crmbot/*')
global without sharing class CRMBotFlow {
	@HttpGet
    global static List<CustomerDetails> doGet(){
        RestRequest req = RestContext.request;
        //String crn = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        //String type =  req.params.get('type');
        String num =  req.params.get('number');
        List<Booking__c> bkgs = new List<Booking__c>();
        List<Opportunity> opps = new List<Opportunity>();
        CustomerDetails details = new CustomerDetails();
        List<CustomerDetails> detailsList = new List<CustomerDetails>();
        Booking__c bkg = new Booking__c();
        
        /*opps = [SELECT Id, Name, SAP_Customer_Number__c, Booking__c, Booking__r.Name, Booking__r.Status__c, Booking__r.Project__c, RW_Email__c,
                    Booking__r.RM_Name__c, Booking__r.Unit_No__r.RW_Param4__c, Booking__r.Unit_No__r.RW_Param2__c, Booking__r.Unit_No__r.RW_Param3__c,
                    Booking__r.RW_Booking_Confirmed_Date__c, Booking__r.RW_Total_Demand_Outstanding__c, Booking__r.RW_Project_Name__c,
                    Booking__r.Latest_Demand_Due_Date__c, RW_Project__r.RW_SAP_Company_Code__c, Booking__r.Unit_No__r.TowerName__r.Possession_Date__c,
                    Booking__r.Wing__c, Booking__r.Unit_No__r.TowerName__r.Zone_Name__r.Name, Booking__r.Unit_No__r.Relationship_Manager__r.User__c,
                    Booking__r.RW_Agreement_Possession_Date__c, Booking__r.RW_Registration_Date__c, Booking__r.FBL5N__c, Booking__r.RW_Total_Interest__c
                    FROM Opportunity WHERE StageName = 'Unit Booked' AND RW_Mobile_No__c =: num ORDER BY Booking__r.Booking_Date__c DESC];*/
        opps = [SELECT Id, Name, SAP_Customer_Number__c, Booking__c, Booking__r.Name, Booking__r.Status__c, Booking__r.Project__c, RW_Email__c,
                    Booking__r.RM_Name__c, Booking__r.Unit_No__r.RW_Param4__c, Booking__r.Unit_No__r.RW_Param2__c, Booking__r.Unit_No__r.RW_Param3__c,
                    Booking__r.RW_Booking_Confirmed_Date__c, Booking__r.RW_Total_Demand_Outstanding__c, Booking__r.RW_Project_Name__c,
                    Booking__r.Latest_Demand_Due_Date__c, RW_Project__r.RW_SAP_Company_Code__c, Booking__r.Unit_No__r.TowerName__r.Possession_Date__c,
                    Booking__r.Wing__c, Booking__r.Unit_No__r.TowerName__r.Zone_Name__r.Name, Booking__r.Unit_No__r.Relationship_Manager__r.User__c,
                    Booking__r.RW_Agreement_Possession_Date__c, Booking__r.RW_Registration_Date__c, Booking__r.FBL5N__c, Booking__r.RW_Total_Interest__c, Booking__r.Primary_Applicant_Name__c
                    FROM Opportunity WHERE StageName = 'Unit Booked' AND Mobile_No_with_Country_Code__c =: num AND Booking__c != null ORDER BY Booking__r.Booking_Date__c DESC];
        if(opps.size() > 0){
            for(Opportunity opp : opps){
                detailsList.add(custDetails(opp));
            }
            //return custDetails(opps[0]);
            return detailsList;
        }else{
            CustomerDetails details1 = new CustomerDetails();
            details1.message = 'Customer does not exist with this mobile number';
            detailsList.add(details1);
            //return details;
            return detailsList;
        }
        
        /*if(type == 'mobile'){
            opps = [SELECT Id, Name, SAP_Customer_Number__c, Booking__c, Booking__r.Name, Booking__r.Status__c, Booking__r.Project__c, RW_Email__c,
                    Booking__r.RM_Name__c, Booking__r.Unit_No__r.RW_Param4__c, Booking__r.Unit_No__r.RW_Param2__c, Booking__r.Unit_No__r.RW_Param3__c,
                    Booking__r.RW_Booking_Confirmed_Date__c, Booking__r.RW_Total_Demand_Outstanding__c, Booking__r.RW_Project_Name__c,
                    Booking__r.Latest_Demand_Due_Date__c, RW_Project__r.RW_SAP_Company_Code__c, Booking__r.Unit_No__r.TowerName__r.Possession_Date__c,
                    Booking__r.Wing__c, Booking__r.Unit_No__r.TowerName__r.Zone_Name__r.Name, Booking__r.Unit_No__r.Relationship_Manager__r.User__c,
                    Booking__r.RW_Agreement_Possession_Date__c, Booking__r.RW_Registration_Date__c, Booking__r.FBL5N__c
                    FROM Opportunity WHERE StageName = 'Unit Booked' AND RW_Mobile_No__c =: num ORDER BY Booking__r.Booking_Date__c DESC LIMIT 1];
            if(opps.size() > 0){
                return custDetails(opps[0]);
            }else{
                CustomerDetails details1 = new CustomerDetails();
                details.message = 'Customer does not exist with this mobile number';
                return details;
            }
        }else if(type == 'crn'){
            num = '%'+ num;
            opps = [SELECT Id, Name, SAP_Customer_Number__c, Booking__c, Booking__r.Name, Booking__r.Status__c, Booking__r.Project__c, RW_Email__c,
                    Booking__r.RM_Name__c, Booking__r.Unit_No__r.RW_Param4__c, Booking__r.Unit_No__r.RW_Param2__c, Booking__r.Unit_No__r.RW_Param3__c,
                    Booking__r.RW_Booking_Confirmed_Date__c, Booking__r.RW_Total_Demand_Outstanding__c, Booking__r.RW_Project_Name__c,
                    Booking__r.Latest_Demand_Due_Date__c, RW_Project__r.RW_SAP_Company_Code__c, Booking__r.Unit_No__r.TowerName__r.Possession_Date__c,
                    Booking__r.Wing__c, Booking__r.Unit_No__r.TowerName__r.Zone_Name__r.Name, Booking__r.Unit_No__r.Relationship_Manager__r.User__c,
                    Booking__r.RW_Agreement_Possession_Date__c, Booking__r.RW_Registration_Date__c, Booking__r.FBL5N__c
                    FROM Opportunity WHERE StageName = 'Unit Booked' AND SAP_Customer_Number__c like: num ORDER BY Booking__r.Booking_Date__c DESC LIMIT 1];
            if(opps.size() > 0){
                 return custDetails(opps[0]);
            }else{
                CustomerDetails details2 = new CustomerDetails();
                details.message = 'Customer does not exist with this crn number';
                return details;
            }
        }else{
            return null;
        }*/
        
    }
    
    global class CustomerDetails{
        global String Customer_Id; 
        global String Customer_Name;
        global String CRN_Number; 
        global String Booking_Id;
        global String Booking_Name;
        global String Booking_Status;
        global String RM_Name;
        global String RM_Id;
        global Date Booking_Confirmed_Date;
        global Decimal Demand_Outstanding;
        global Date Latest_Demand_Due_Date;
        global String Project_Name;
        global String Project_Id;
        global String Wing;
        global String Company_Code;
        global String Flat_Number;
        global String Floor;
        global String Tower_Name;
        global Date Possession_Date;
        global String Cluster;
        global String Customer_Email;
        global Date Registration_Date;
        global Decimal Total_Interest;
        global String message;
    }
    
    public static CustomerDetails custDetails(Opportunity opp){
        CustomerDetails details = new CustomerDetails();
        details.Customer_Id = opp.Id; 
        //details.Customer_Name = opp.Name;
        details.Customer_Name = (opp.Booking__r.Primary_Applicant_Name__c != null)? opp.Booking__r.Primary_Applicant_Name__c : opp.Name;
        details.CRN_Number = opp.SAP_Customer_Number__c; 
        details.Booking_Id = opp.Booking__c;
        details.Booking_Name = opp.Booking__r.Name;
        details.Booking_Status = opp.Booking__r.Status__c;
        details.RM_Name = opp.Booking__r.RM_Name__c;
        details.Booking_Confirmed_Date = opp.Booking__r.RW_Booking_Confirmed_Date__c;
        //details.Demand_Outstanding = opp.Booking__r.RW_Total_Demand_Outstanding__c;
        details.Demand_Outstanding = opp.Booking__r.FBL5N__c;
        details.Latest_Demand_Due_Date = opp.Booking__r.Latest_Demand_Due_Date__c;
        details.Project_Name = opp.Booking__r.RW_Project_Name__c;
        details.Wing = opp.Booking__r.Wing__c;
        details.Company_Code = opp.RW_Project__r.RW_SAP_Company_Code__c;
        details.Flat_Number = opp.Booking__r.Unit_No__r.RW_Param4__c;
        details.Floor = opp.Booking__r.Unit_No__r.RW_Param3__c;
        details.Tower_Name = opp.Booking__r.Unit_No__r.RW_Param2__c;
        //details.Possession_Date = opp.Booking__r.RW_Agreement_Possession_Date__c;
        details.Cluster = opp.Booking__r.Unit_No__r.TowerName__r.Zone_Name__r.Name;
        details.RM_Id = opp.Booking__r.Unit_No__r.Relationship_Manager__r.User__c;
        details.Project_Id = opp.Booking__r.Project__c;
        details.Customer_Email = opp.RW_Email__c;
        details.Registration_Date = opp.Booking__r.RW_Registration_Date__c;
        details.Total_Interest = opp.Booking__r.RW_Total_Interest__c;
        return details;
    }
    
    @HttpPost
    global static Details doPost(String crn, String customer, String option, String companyCode, String project, String booking, String rmId, String customer_email, String send_mail){
        //Added by coServe 08-01-2024 Start
        Id recId = booking;
        String sObjName = recId.getSObjectType().getDescribe().getName();
        Booking__c bkg = new Booking__c();
        if(sObjName == 'Booking__c'){
            bkg = [SELECT Id, Opportunity__c, RW_Agreement_Possession_Date__c,FBL5N__c FROM Booking__c WHERE Id =: booking LIMIT 1];
            booking = bkg.Opportunity__c;
        }
        
        Details det = new Details();
        
        //Added by coServe 08-01-2024 End
        if(option == 'Booking Confirmation Letter'){
            det = bookingConfirmLetter(crn, customer, project, booking, rmId, customer_email, send_mail);
        }else if(option == 'Account Statement'){
            det = accountStatement(crn, customer, companyCode, project, booking, rmId, customer_email, send_mail);
        }else if(option == 'Payment Online'){
            det = paymentOnline(crn, customer, project, booking, rmId, customer_email, send_mail);
        }else if(option == 'Latest Demand Letter'){
            det = latestDemandLetter(crn, customer, project, booking, rmId, customer_email, send_mail);
        }else if(option == 'Last 3 Demand Letters'){
            det = lastThreeDemands(crn, customer, project, booking, rmId, customer_email, send_mail);
        }else if(option == 'Latest Payment Receipt'){
            det = latestReceipt(crn, customer, project, booking, rmId, customer_email, send_mail);
        }else if(option == 'Last 3 Payment Receipts'){
            //det = lastThreeReceipts(crn, customer, project, booking, rmId, customer_email, send_mail);
        }else if(option == 'Current Outstanding'){
           det.currentOutstanding = String.valueOf(bkg.FBL5N__c);
        }else if(option == 'Possession Date'){
            det.possessionDate = String.valueOf(bkg.RW_Agreement_Possession_Date__c);
        }else if(option == 'Loan Process'){
            //loanProcess(crn, customer, project, booking, rmId, customer_email);
        }else if(option == 'Call Back'){
            //callBack(crn, customer, project, booking, rmId, customer_email);
        }else if(option == 'Interest Statement'){
            interestStatement(crn, customer, companyCode, project, booking, rmId, customer_email);
        }
        return det;
    }
       
    public static Details bookingConfirmLetter(String crn, String customer, String project, String booking, String rmId, String email, String send_mail){
        
        Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Service Task').getRecordTypeId();
        Task tsk = new Task();
        tsk.RecordTypeId = recordTypeId;
        tsk.Subject = 'Booking Confirmantion Letter';
        tsk.Priority = 'Normal';
        tsk.Status = 'Not Started';
        tsk.Project__c = (project != null && project != '') ? project : null;
        tsk.WhatId = booking;
        tsk.OwnerId = (rmId != null && rmId != '') ? rmId : UserInfo.getUserId();
        insert tsk;
        
        Details det = new Details();
        try{
            Booking__c bkg = [SELECT Id, Primary_Applicant_Name__c, Opportunity__r.RW_Mobile_No__c, Primary_Applicant_Email__c, RW_Project_Name__c,
                              Unit_No__r.TowerName__r.Zone_Name__r.Name, Unit_No__r.RW_Param2__c, Unit_No__r.RW_Param4__c, Allotment_Premium__c,
                              Quotation__r.Total_No_of_Parking__c, Flat_Typology__c, Quotation__r.PaymentPlan__r.Name, Source_of_Booking__c
                              FROM Booking__c WHERE Opportunity__c =: booking];
            //if(send_mail == 'yes' || send_mail == 'YES' || send_mail == 'Yes'){
                list<Messaging.SingleEmailMessage> messages = new list<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                EmailTemplate template = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName = 'Booking_Confirmation'];
                message.toAddresses = new List<String>{email};
                message.setTemplateId(template.Id);
                message.setTargetObjectId(Userinfo.getUserId());
                message.setTreatTargetObjectAsRecipient(false);
                message.setWhatId(bkg.Id);
                message.setSaveAsActivity(false);
                message.setUseSignature(false);
                message.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
                messages.add(message);
                Messaging.SendEmailResult[] result = Messaging.sendEmail(messages);
            //}
            
            
            BookingDetails bkgDetails = new BookingDetails();
            bkgDetails.primaryApplicant = bkg.Primary_Applicant_Name__c;
            bkgDetails.mobile = bkg.Opportunity__r.RW_Mobile_No__c;
            bkgDetails.email = bkg.Primary_Applicant_Email__c;
            bkgDetails.project = bkg.RW_Project_Name__c;
            bkgDetails.cluster = bkg.Unit_No__r.TowerName__r.Zone_Name__r.Name;
            bkgDetails.tower = bkg.Unit_No__r.RW_Param2__c;
            bkgDetails.flatNo = bkg.Unit_No__r.RW_Param4__c;
            bkgDetails.agreementValue = String.valueOf(bkg.Allotment_Premium__c);
            bkgDetails.carParkings = String.valueOf(bkg.Quotation__r.Total_No_of_Parking__c);
            bkgDetails.flatConfiguration = bkg.Flat_Typology__c;
            bkgDetails.paymentPlan = bkg.Quotation__r.PaymentPlan__r.Name;
            bkgDetails.bookingSource = bkg.Source_of_Booking__c;
            
            det.bookingDetails = bkgDetails;
            
            tsk.Status = 'Completed';
        }catch(Exception e){
            tsk.Description = 'Error: ' + e.getMessage();
            update tsk;
        }
        
        return det;
        
    }
    
    public static Details accountStatement(String crn, String customer, String companyCode, String project, String booking, String rmId, String email, String send_mail){
        
        /*Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Service Task').getRecordTypeId();
        Task tsk = new Task();
        tsk.RecordTypeId = recordTypeId;
        tsk.Subject = 'Account Statement';
        tsk.Priority = 'Normal';
        tsk.Status = 'Not Started';
        tsk.Project__c = (project != null && project != '') ? project : null;
        tsk.WhatId = booking;
        tsk.OwnerId = (rmId != null && rmId != '') ? rmId : UserInfo.getUserId();
        //insert tsk;*/
        String body;
        Boolean isError = false;
        List<Booking__c> bkg = [SELECT Id FROM Booking__c WHERE Opportunity__c =: booking];
        bkg[0].Send_Account_Statement__c = true;
        update bkg[0];
        /*try{
            if(!Test.isRunningTest()){
                //body = PDFController.getCustomerLedgerPdf(crn, companyCode);
                //body = PDFController.getCustLedgerPdf(booking);
                body = PDFController.getCustLedgerPdf(bkg[0].Id);
            }else{
                body = 'Test';
            }
        }catch(Exception e){
           System.debug('--Error--'+e.getMessage());
           isError = true;
           tsk.Description = 'Error: ' + e.getMessage(); 
        }
        insert tsk;
        try{
            //if(send_mail == 'yes' || send_mail == 'YES' || send_mail == 'Yes'){
                if(body != null && body != '' && !isError){
                    Messaging.EmailFileAttachment att = new Messaging.EmailFileAttachment();
                    att.setFileName('Account Statement.pdf');
                    att.setBody(EncodingUtil.base64Decode(body));
                    list<Messaging.SingleEmailMessage> messages = new list<Messaging.SingleEmailMessage>();
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.toAddresses = new List<String>{email};
                        message.subject = 'Account Statement';
                    String htmlBody = 'Dear ' + customer + ',<br/><br/>  Please find the Account statement as requested.';
                    htmlBody += '<br/><br/>Regards,<br/>Customer Care Team.';
                    message.setFileAttachments(new Messaging.EmailFileAttachment[] {att});
                    message.setHtmlBody(htmlBody);  
                    message.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
                    messages.add(message);
                    Messaging.SendEmailResult[] result = Messaging.sendEmail(messages);
                }
            //}
            tsk.Status = 'Completed';
        }catch(Exception e){
            System.debug('--Error--'+e.getMessage());
            tsk.Description = 'Error: ' + e.getMessage();
        }
        update tsk;*/
        Details det = new Details();
        //det.accountStatementLink = 'https://runwal.my.salesforce-sites.com/crmbotdoc?id='+bkg[0].Id+'&doc=acs';
        det.accountStatementLink = 'Please check your registered email for the Account statement';
        return det;
    }
    
    public static void interestStatement(String crn, String customer, String companyCode, String project, String booking, String rmId, String email){
        
        Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Service Task').getRecordTypeId();
        Task tsk = new Task();
        tsk.RecordTypeId = recordTypeId;
        tsk.Subject = 'Interest Statement';
        tsk.Priority = 'Normal';
        tsk.Status = 'Not Started';
        tsk.Project__c = (project != null && project != '') ? project : null;
        tsk.WhatId = booking;
        tsk.OwnerId = (rmId != null && rmId != '') ? rmId : UserInfo.getUserId();
        //insert tsk;
        String body;
        Boolean isError = false;
        List<Booking__c> bkg = [SELECT Id FROM Booking__c WHERE Opportunity__c =: booking];
        try{
            if(!Test.isRunningTest()){
                //body = PDFController.getCustomerLedgerPdf(crn, companyCode);
                //body = PDFController.getCustLedgerPdf(booking);
                body = PDFController.getinterestLedgerPdf(crn, companyCode);
            }else{
                body = 'Test';
            }
        }catch(Exception e){
            isError = true;
            tsk.Description = 'Error: ' + e.getMessage(); 
        }
        insert tsk;
        if(body != null && body != '' && !isError){
            Messaging.EmailFileAttachment att = new Messaging.EmailFileAttachment();
            att.setFileName('Interest Statement.pdf');
            att.setBody(EncodingUtil.base64Decode(body));
            list<Messaging.SingleEmailMessage> messages = new list<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = new List<String>{email};
            message.subject = 'Interest Statement';
            String htmlBody = 'Dear ' + customer + ',<br/><br/>  Please find the Interest statement as requested.';
            htmlBody += '<br/><br/>Regards,<br/>Customer Care Team.';
            message.setFileAttachments(new Messaging.EmailFileAttachment[] {att});
            message.setHtmlBody(htmlBody);  
            message.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
            messages.add(message);
            try{
                Messaging.SendEmailResult[] result = Messaging.sendEmail(messages);
                if(result[0].isSuccess()){
                    tsk.Status = 'Completed';
                }
            }catch(Exception e){
                tsk.Description = 'Error: ' + e.getMessage();
            }
            update tsk;
        }
        
    }
    
    public static Details paymentOnline(String crn, String customer, String project, String booking, String rmId, String email, String send_mail){
        
        Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Service Task').getRecordTypeId();
        Task tsk = new Task();
        tsk.RecordTypeId = recordTypeId;
        tsk.Subject = 'Payment Online';
        tsk.Priority = 'Normal';
        tsk.Status = 'Not Started';
        tsk.Project__c = (project != null && project != '') ? project : null;
        tsk.WhatId = booking;
        tsk.OwnerId = (rmId != null && rmId != '') ? rmId : UserInfo.getUserId();
        insert tsk;
        
        //String siteUrl = 'https://runwal.my.salesforce-sites.com/ivronlinepay?crn='+crn;
        String siteUrl = 'https://runwal.my.salesforce-sites.com/ivronlinepay?crn='+crn;

        try{
            //if(send_mail == 'yes' || send_mail == 'YES' || send_mail == 'Yes'){
                list<Messaging.SingleEmailMessage> messages = new list<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.toAddresses = new List<String>{email};
                    message.subject = 'Payment Online';
                String htmlBody = 'Dear ' + customer + ',<br/><br/> Please click below link to make payment<br/><br/>';
                htmlBody += siteUrl;
                htmlBody += '<br/><br/>Regards,<br/>Customer Care Team.';
                message.setHtmlBody(htmlBody);   
                message.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
                messages.add(message);
                Messaging.SendEmailResult[] result = Messaging.sendEmail(messages);
            //}   
            tsk.Status = 'Completed';
        }catch(Exception e){
            tsk.Description = 'Error: ' + e.getMessage();
        }
        update tsk;
        Details det = new Details();
        det.onlinePaymentLink = siteUrl;
        return det;
    }   
    
    public static Details latestDemandLetter(String crn, String customer, String project, String booking, String rmId, String email, String send_mail){
        
        Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Service Task').getRecordTypeId();
        Task tsk = new Task();
        tsk.RecordTypeId = recordTypeId;
        tsk.Subject = 'Latest Demand Letter';
        tsk.Priority = 'Normal';
        tsk.Status = 'Not Started';
        tsk.Project__c = (project != null && project != '') ? project : null;
        tsk.WhatId = booking;
        tsk.OwnerId = (rmId != null && rmId != '') ? rmId : UserInfo.getUserId();
        
        //List<RW_Demand__c> demands = [SELECT Id, Name FROM RW_Demand__c WHERE Booking__r.Opportunity__r.SAP_Customer_Number__c =: crn AND RW_Demand_Status__c != 'Revoke' AND Demand_Amount__c != 0 ORDER BY CreatedDate Desc LIMIT 1]; //Commented by coServe 15-10-2024
        
        //Added by coServe 15-10-2024 Start
        List<RW_Demand__c> demands = [SELECT Id, Name, (SELECT Id, Name, RW_Usage_Code__c FROM Demand_Items__r) FROM RW_Demand__c WHERE Booking__r.Opportunity__r.SAP_Customer_Number__c =: crn AND RW_Demand_Status__c != 'Revoke' AND Demand_Amount__c != 0 ORDER BY CreatedDate Desc];
        String demId;
        Integer index = 0;
        if(demands.size() > 0){
            do {
                Boolean otherChargeDem = false;
                for(RW_Demand_Item__c item : demands[index].Demand_Items__r){
                    if(item.RW_Usage_Code__c == null || item.RW_Usage_Code__c == ''){
                        otherChargeDem = true;
                    }
                }
                if(otherChargeDem == false){
                    demId = demands[index].Id;
                }
                index++;
            } while (demId == null && demands.size() > index);
        }
        
        //Added by coServe 15-10-2024 End
        
        String body;
        Boolean isError = false;
        try{
            if(!Test.isRunningTest() && demands.size() > 0){
                //body = PDFController.getdemandPdf(demands[0].Id); //Commented by coServe 15-10-2024
                body = PDFController.getdemandPdf(demId); //Added by coServe 15-10-2024
            }else if(Test.isRunningTest()){
                body = 'Test';
            }
        }catch(Exception e){
           isError = true;
           tsk.Description = 'Error: ' + e.getMessage();
        }
        insert tsk;
        try{
            //if(send_mail == 'yes' || send_mail == 'YES' || send_mail == 'Yes'){
                if(body != null && !isError){
                    Messaging.EmailFileAttachment att = new Messaging.EmailFileAttachment();
                    att.setFileName('Demand Letter.pdf');
                    att.setBody(EncodingUtil.base64Decode(body));
                    list<Messaging.SingleEmailMessage> messages = new list<Messaging.SingleEmailMessage>();
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.toAddresses = new List<String>{email};
                        message.subject = 'Latest Demand Letter';
                    String htmlBody = 'Dear ' + customer + ',<br/><br/>Please find the latest Demand letter as requested.';
                    htmlBody += '<br/><br/>Regards,<br/>Customer Care Team.';
                    message.setHtmlBody(htmlBody);
                    message.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
                    message.setFileAttachments(new Messaging.EmailFileAttachment[] {att});
                    messages.add(message);
                    Messaging.SendEmailResult[] result = Messaging.sendEmail(messages);
                }
            //}
            tsk.Status = 'Completed';
        }catch(Exception e){
            tsk.Description = 'Error: ' + e.getMessage();
        }
        update tsk;
        
        Details det = new Details();
        /*if(demands.size() > 0){ //Commented by coServe 15-10-2024
            det.latestDemandLink = 'https://runwal--uat.sandbox.my.salesforce-sites.com/crmbotdoc?id='+demands[0].Id+'&doc=dem';
        }*/
        if(demId != null){ //Added by coServe 15-10-2024
            det.latestDemandLink = 'https://runwal.my.salesforce-sites.com/crmbotdoc?id='+demId+'&doc=dem';
        }
        return det;
    }
    
    public static Details lastThreeDemands(String crn, String customer, String project, String booking, String rmId, String email, String send_mail){
        
        Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Service Task').getRecordTypeId();
        Task tsk = new Task();
        tsk.RecordTypeId = recordTypeId;
        tsk.Subject = 'Last 3 Demand Letters';
        tsk.Priority = 'Normal';
        tsk.Status = 'Not Started';
        tsk.Project__c = (project != null && project != '') ? project : null;
        tsk.WhatId = booking;
        tsk.OwnerId = (rmId != null && rmId != '') ? rmId : UserInfo.getUserId();
        
        //List<RW_Demand__c> demands = [SELECT Id, Name FROM RW_Demand__c WHERE Booking__r.Opportunity__r.SAP_Customer_Number__c =: crn AND RW_Demand_Status__c != 'Revoke' AND Demand_Amount__c != 0 ORDER BY CreatedDate Desc LIMIT 3]; //Commented by coServe 15-10-2024
        List<Messaging.EmailFileAttachment> atts = new List<Messaging.EmailFileAttachment>();
        //Added by coServe 15-10-2024 Start
        List<RW_Demand__c> demands = [SELECT Id, Name, (SELECT Id, Name, RW_Usage_Code__c FROM Demand_Items__r) FROM RW_Demand__c WHERE Booking__r.Opportunity__r.SAP_Customer_Number__c =: crn AND RW_Demand_Status__c != 'Revoke' AND Demand_Amount__c != 0 ORDER BY CreatedDate Desc];
        List<RW_Demand__c> demandsToSend = new List<RW_Demand__c>();
        Integer index = 0;
        if(demands.size() > 0){
            do {
                Boolean otherChargeDem = false;
                for(RW_Demand_Item__c item : demands[index].Demand_Items__r){
                    System.debug('RW_Usage_Code__c: ' + item.RW_Usage_Code__c);
                    if(item.RW_Usage_Code__c == null || item.RW_Usage_Code__c == ''){
                        otherChargeDem = true;
                    }
                }
                if(otherChargeDem == false){
                    demandsToSend.add(demands[index]);
                }
                index++;
            } while (demandsToSend.size() < 3 && demands.size() > index);
        }
        
        //Added by coServe 15-10-2024 End
        Boolean isError = false;
        List<String> demLinks = new List<String>();
        try{
            //for(RW_Demand__c dem : demands){ //Commented by coServe 15-10-2024
            for(RW_Demand__c dem : demandsToSend){
                String body1;
                if(!Test.isRunningTest() && demandsToSend.size() > 0){
                    body1 = PDFController.getdemandPdf(dem.Id);
                    demLinks.add('https://runwal.my.salesforce-sites.com/crmbotdoc?id='+dem.Id+'&doc=dem');
                }else if(Test.isRunningTest()){
                    body1 = 'Test';
                }
                Messaging.EmailFileAttachment att1 = new Messaging.EmailFileAttachment();
                att1.setFileName(dem.Name+'.pdf');
                att1.setBody(EncodingUtil.base64Decode(body1));
                atts.add(att1);  
            }
        }catch(Exception e){
           isError = true;
           tsk.Description = 'Error: ' + e.getMessage();
        }
        
        insert tsk;
        try{
            //if(send_mail == 'yes' || send_mail == 'YES' || send_mail == 'Yes'){
                if(atts != null && atts.size() > 0 && !isError){
                    list<Messaging.SingleEmailMessage> messages = new list<Messaging.SingleEmailMessage>();
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.toAddresses = new List<String>{email};
                        message.subject = 'Last 3 Demand Letters';
                    String htmlBody = 'Dear ' + customer + ',<br/><br/> Please find the last three Demand letters as requested.';
                    htmlBody += '<br/><br/>Regards,<br/>Customer Care Team.';
                    message.setHtmlBody(htmlBody);  
                    message.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
                    message.setFileAttachments(atts);
                    messages.add(message);
                    Messaging.SendEmailResult[] result = Messaging.sendEmail(messages);
                }
            //}
            tsk.Status = 'Completed';
        }catch(Exception e){
            tsk.Description = 'Error: ' + e.getMessage();
        }
        
        update tsk;
        
        Details det = new Details();
        det.last3DemandLinks = demLinks;
        return det;
        
    }
    
    public static Details latestReceipt(String crn, String customer, String project, String booking, String rmId, String email, String send_mail){
        /*Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Service Task').getRecordTypeId();
        Task tsk = new Task();
        tsk.RecordTypeId = recordTypeId;
        tsk.Subject = 'Latest Payment Receipt';
        tsk.Priority = 'Normal';
        tsk.Status = 'Not Started';
        tsk.Project__c = (project != null && project != '') ? project : null;
        tsk.WhatId = booking;
        tsk.OwnerId = (rmId != null && rmId != '') ? rmId : UserInfo.getUserId();*/
        List<RW_Payment_Details__c> recps = [SELECT Id, Name FROM RW_Payment_Details__c WHERE RW_Booking__r.Opportunity__r.SAP_Customer_Number__c =: crn AND RW_Document_Type__c IN ('DZ','DT','DF') AND Status__c != 'Reversed' ORDER BY CreatedDate Desc LIMIT 1];
        /*String body;
        Boolean isError = false;
        try{
           if(!Test.isRunningTest() && recps.size() > 0){
                body = PDFController.getreceiptPdf(recps[0].Id);
            }else if(Test.isRunningTest()){
                body = 'Test';
            } 
        }catch(Exception e){
           System.debug('--Error--'+e.getMessage());
           isError = true;
           tsk.Description = 'Error: ' + e.getMessage();
        }
        insert tsk;
        try{
            //if(send_mail == 'yes' || send_mail == 'YES' || send_mail == 'Yes'){
                if(body != null && !isError){
                    Messaging.EmailFileAttachment att = new Messaging.EmailFileAttachment();
                    att.setFileName('Receipt.pdf');
                    att.setBody(EncodingUtil.base64Decode(body));
                    list<Messaging.SingleEmailMessage> messages = new list<Messaging.SingleEmailMessage>();
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.toAddresses = new List<String>{email};
                        message.subject = 'Latest Payment Receipt';
                    String htmlBody = 'Dear ' + customer + ',<br/><br/>  Please find the latest Payment Receipt as requested.';
                    htmlBody += '<br/><br/>Regards,<br/>Customer Care Team.';
                    message.setHtmlBody(htmlBody); 
                    message.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
                    message.setFileAttachments(new Messaging.EmailFileAttachment[] {att});
                    messages.add(message);
                    Messaging.SendEmailResult[] result = Messaging.sendEmail(messages);
                }
            //}
            tsk.Status = 'Completed';
        }catch(Exception e){
            System.debug('--Error--'+e.getMessage());
            tsk.Description = 'Error: ' + e.getMessage();
        }
        update tsk;*/
        Details det = new Details();
        if(recps.size() > 0){
            recps[0].Send_Receipt_Letter__c = true;
            update recps[0];
            //det.latestReceiptLink = 'https://runwal.my.salesforce-sites.com/crmbotdoc?id='+recps[0].Id+'&doc=recp';
        }
        det.latestReceiptLink = 'Please check your registered email for Receipt Letter';
        return det;
    }
    
    // public static Details lastThreeReceipts(String crn, String customer, String project, String booking, String rmId, String email, String send_mail){
        
    //     /*Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Service Task').getRecordTypeId();
    //     Task tsk = new Task();
    //     tsk.RecordTypeId = recordTypeId;
    //     tsk.Subject = 'Last 3 Payment Receipts';
    //     tsk.Priority = 'Normal';
    //     tsk.Status = 'Not Started';
    //     tsk.Project__c = (project != null && project != '') ? project : null;
    //     tsk.WhatId = booking;
    //     tsk.OwnerId = (rmId != null && rmId != '') ? rmId : UserInfo.getUserId();*/
        
    //     List<RW_Payment_Details__c> recps = [SELECT Id, Name FROM RW_Payment_Details__c WHERE RW_Booking__r.Opportunity__r.SAP_Customer_Number__c =: crn AND RW_Document_Type__c IN ('DZ','DT','DF') AND Status__c != 'Reversed' ORDER BY CreatedDate Desc LIMIT 3];
    //     for(RW_Payment_Details__c rec : recps){
    //         rec.Send_Receipt_Letter__c = true;
    //     }
    //     update recps;
    //     /*List<Messaging.EmailFileAttachment> atts = new List<Messaging.EmailFileAttachment>();
    //     Boolean isError = false;
    //     List<String> recpLinks = new List<String>();
    //     try{
    //         for(RW_Payment_Details__c rec : recps){
    //             String body1;
    //             if(!Test.isRunningTest() && recps.size() > 0){
    //                 body1 = PDFController.getreceiptPdf(rec.Id);
    //                 recpLinks.add('https://runwal.my.salesforce-sites.com/crmbotdoc?id='+rec.Id+'&doc=recp');
    //             }else if(Test.isRunningTest()){
    //                 body1 = 'Test';
    //             }
    //             Messaging.EmailFileAttachment att1 = new Messaging.EmailFileAttachment();
    //             att1.setFileName(rec.Name+'.pdf');
    //             att1.setBody(EncodingUtil.base64Decode(body1));
    //             atts.add(att1);  
    //         }
    //     }catch(Exception e){
    //        System.debug('--Error--'+e.getMessage());
    //        isError = true;
    //        tsk.Description = 'Error: ' + e.getMessage();
    //     }
        
    //     insert tsk;
    //     try{
    //         //if(send_mail == 'yes' || send_mail == 'YES' || send_mail == 'Yes'){
    //             if(atts != null && atts.size() > 0 && !isError){
    //                 list<Messaging.SingleEmailMessage> messages = new list<Messaging.SingleEmailMessage>();
    //                 Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
    //                 message.toAddresses = new List<String>{email};
    //                     message.subject = 'Last 3 Payment Receipts';
    //                 String htmlBody = 'Dear ' + customer + ',<br/><br/>  Please find the last three Receipt Letters as requested.';
    //                 htmlBody += '<br/><br/>Regards,<br/>Customer Care Team.';
    //                 message.setHtmlBody(htmlBody);  
    //                 message.setFileAttachments(atts);
    //                 message.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
    //                 messages.add(message);
    //                 Messaging.SendEmailResult[] result = Messaging.sendEmail(messages);
    //             }
    //         //}
    //         tsk.Status = 'Completed';
    //     }catch(Exception e){
    //         System.debug('--Error--'+e.getMessage());
    //         tsk.Description = 'Error: ' + e.getMessage();
    //     }
    //     update tsk;*/
    //     Details det = new Details();
    //     //det.last3ReceiptLinks = recpLinks;
    //     det.last3ReceiptLinks = new List<String>{'Please check your registered email for Receipt Letters'};
    //     return det;
    // }
    
    global class Details{
        global String accountStatementLink;
        global String onlinePaymentLink;
        global String latestDemandLink;
        global List<String> last3DemandLinks;
        global String latestReceiptLink;
        global List<String> last3ReceiptLinks;
        global String currentOutstanding;
        global String possessionDate;
        global BookingDetails bookingDetails;
    }
    
    public class BookingDetails{
        public String primaryApplicant;
        public String mobile;
        public String email;
        public String project;
        public String cluster;
        public String tower;
        public String flatNo;
        public String agreementValue;
        public String carParkings;
        public String flatConfiguration;
        public String paymentPlan;
        public String bookingSource;
    }
    
    /*public static void loanProcess(String crn, String customer, String project, String booking, String rmId, String email){
        
        Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Service Task').getRecordTypeId();
        Task tsk = new Task();
        tsk.RecordTypeId = recordTypeId;
        tsk.Subject = 'Loan Process';
        tsk.Priority = 'Normal';
        tsk.Status = 'Not Started';
        tsk.Project__c = (project != null && project != '') ? project : null;
        tsk.WhatId = booking;
        tsk.OwnerId = (rmId != null && rmId != '') ? rmId : UserInfo.getUserId();
        insert tsk;
        
        list<Messaging.SingleEmailMessage> messages = new list<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        EmailTemplate template = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName = 'Loan_Assistance'];
        
        message.toAddresses = new List<String>{email};
        message.setTemplateId(template.Id);
        message.setTargetObjectId(Userinfo.getUserId());
        message.setTreatTargetObjectAsRecipient(false);
        message.setWhatId(booking);
        message.setSaveAsActivity(false);
        message.setUseSignature(false);
        message.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
        messages.add(message);
        try{
            Messaging.SendEmailResult[] result = Messaging.sendEmail(messages);
            if(result[0].isSuccess()){
                tsk.Status = 'Completed';
            }
        }catch(Exception e){
            System.debug('--Error--'+e.getMessage());
            tsk.Description = 'Error: ' + e.getMessage();
        }
        update tsk;
    }*/
    
    /*public static void callBack(String crn, String customer, String project, String booking, String rmId, String email){
        Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Service Task').getRecordTypeId();
        Task tsk = new Task();
        tsk.RecordTypeId = recordTypeId;
        tsk.Subject = 'Call Back';
        tsk.Priority = 'Normal';
        tsk.Status = 'Completed';
        tsk.Project__c = (project != null && project != '') ? project : null;
        tsk.WhatId = booking;
        tsk.OwnerId = (rmId != null && rmId != '') ? rmId : UserInfo.getUserId();
        try{
            insert tsk;
        }catch(exception e){
            System.debug('--error--: ' + e);
        }
        
    }*/
    
}