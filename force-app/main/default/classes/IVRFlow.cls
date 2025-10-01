@RestResource(urlMapping='/ivr/*')
global without sharing class IVRFlow {
    @HttpGet
    global static CustomerDetails doGet(){
        RestRequest req = RestContext.request;
        String crn = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        
        String type;
        String num;
        
        type =  req.params.get('type');
        num =  req.params.get('number');
        
        Boolean oldLogic = false;
        
        if(type != null && num != null){
            oldLogic = true;
        }else{
            oldLogic = false;
        }
	
		System.debug('type1: ' + type);	
        System.debug('num1: ' + num);
        System.debug('oldLogic: ' + oldLogic);
        
       
        Boolean checkWithCode = false;
        String updatedMobile;
        if(!oldLogic){
            String jsonBody;
            if(!Test.isRunningTest()){
                jsonBody = req.requestBody.toString();
            }else{
                jsonBody = '{"type":"mobile","number":"1234567890"}';
            }
            
            System.debug('jsonBody: ' + jsonBody);
            
            Map<String,Object> result = (Map<String,Object>)JSON.deserializeUntyped(jsonBody); 
            for (String key : result.keySet()){
                if(key == 'type'){
                    type = String.valueof(result.get(key));
                }
                if(key == 'number'){
                    num = String.valueOf(result.get(key));
                }
            }
            System.debug('type: ' + type);
            System.debug('num: ' + num);
            
            //Added by coServe 05-04-2024 Start
            
            
            
            updatedMobile = num.deleteWhitespace();
            updatedMobile = updatedMobile.replace('+','');
            
            if(updatedMobile != null && updatedMobile != ''){
                while(updatedMobile.length() > 1 && updatedMobile.subString(0,1) == '0'){
                    //updatedMobile = updatedMobile.replace(updatedMobile.subString(0,1),'');
                    updatedMobile = updatedMobile.subString(1,updatedMobile.length());
                }
                
                if(updatedMobile.subString(0,1) == '(' && updatedMobile.contains(')')){
                    updatedMobile = updatedMobile.replace('(', '');
                    updatedMobile = updatedMobile.replace(')', '');
                    updatedMobile = '1' + updatedMobile;
                    checkWithCode = true;
                }else if(updatedMobile.length() > 4 && updatedMobile.subString(3,4) == '-'){
                    updatedMobile = updatedMobile.replace('-', '');
                    updatedMobile = '1' + updatedMobile;
                }
                
                if(updatedMobile.length() < 10){
                    checkWithCode = false;
                }else if(updatedMobile.length() > 10){
                    checkWithCode = true;
                }else if(updatedMobile.length() == 10){
                    if(num.subString(0,1) == '0' || num.subString(0,1) == '+'){
                        checkWithCode = true;
                    }else{
                        checkWithCode = false;
                    }
                }
            }
            
            
            system.debug(' checkWithCode :: '+checkWithCode);
            system.debug(' updatedMobile :: '+updatedMobile);
            //Added by coServe 05-04-2024 End
            
        }
        
        List<Booking__c> bkgs = new List<Booking__c>();
        List<Opportunity> opps = new List<Opportunity>();
        CustomerDetails details = new CustomerDetails();
        Booking__c bkg = new Booking__c();
        
        
        if(type == 'mobile'){
            if(oldLogic == true && num != null && num != ''){
                System.debug('--91');
                opps = [SELECT Id, Name, SAP_Customer_Number__c, Booking__c, Booking__r.Name, Booking__r.Status__c, Booking__r.Project__c, RW_Email__c,
                        Booking__r.RM_Name__c, Booking__r.Unit_No__r.RW_Param4__c, Booking__r.Unit_No__r.RW_Param2__c, Booking__r.Unit_No__r.RW_Param3__c,
                        Booking__r.RW_Booking_Confirmed_Date__c, Booking__r.RW_Total_Demand_Outstanding__c, Booking__r.RW_Project_Name__c,
                        Booking__r.Latest_Demand_Due_Date__c, RW_Project__r.RW_SAP_Company_Code__c, Booking__r.Unit_No__r.TowerName__r.Possession_Date__c,
                        Booking__r.Wing__c, Booking__r.Unit_No__r.TowerName__r.Zone_Name__r.Name, Booking__r.Unit_No__r.Relationship_Manager__r.User__c,
                        Booking__r.RW_Agreement_Possession_Date__c, Booking__r.RW_Registration_Date__c, Booking__r.FBL5N__c, Booking__r.RW_Total_Interest__c,
                        Booking__r.Primary_Applicant_Name__c
                        FROM Opportunity WHERE StageName = 'Unit Booked' AND RW_Mobile_No__c =: num ORDER BY Booking__r.Booking_Date__c DESC LIMIT 1];
            }else if(updatedMobile != null && updatedMobile != ''){
                if(checkWithCode){
                    opps = [SELECT Id, Name, SAP_Customer_Number__c, Booking__c, Booking__r.Name, Booking__r.Status__c, Booking__r.Project__c, RW_Email__c,
                            Booking__r.RM_Name__c, Booking__r.Unit_No__r.RW_Param4__c, Booking__r.Unit_No__r.RW_Param2__c, Booking__r.Unit_No__r.RW_Param3__c,
                            Booking__r.RW_Booking_Confirmed_Date__c, Booking__r.RW_Total_Demand_Outstanding__c, Booking__r.RW_Project_Name__c,
                            Booking__r.Latest_Demand_Due_Date__c, RW_Project__r.RW_SAP_Company_Code__c, Booking__r.Unit_No__r.TowerName__r.Possession_Date__c,
                            Booking__r.Wing__c, Booking__r.Unit_No__r.TowerName__r.Zone_Name__r.Name, Booking__r.Unit_No__r.Relationship_Manager__r.User__c,
                            Booking__r.RW_Agreement_Possession_Date__c, Booking__r.RW_Registration_Date__c, Booking__r.FBL5N__c, Booking__r.RW_Total_Interest__c,
                            Booking__r.Primary_Applicant_Name__c
                            FROM Opportunity WHERE StageName = 'Unit Booked' AND Mobile_No_with_Country_Code__c =: updatedMobile ORDER BY Booking__r.Booking_Date__c DESC LIMIT 1];
                    if(opps.size() == 0){
                        opps = [SELECT Id, Name, SAP_Customer_Number__c, Booking__c, Booking__r.Name, Booking__r.Status__c, Booking__r.Project__c, RW_Email__c,
                            Booking__r.RM_Name__c, Booking__r.Unit_No__r.RW_Param4__c, Booking__r.Unit_No__r.RW_Param2__c, Booking__r.Unit_No__r.RW_Param3__c,
                            Booking__r.RW_Booking_Confirmed_Date__c, Booking__r.RW_Total_Demand_Outstanding__c, Booking__r.RW_Project_Name__c,
                            Booking__r.Latest_Demand_Due_Date__c, RW_Project__r.RW_SAP_Company_Code__c, Booking__r.Unit_No__r.TowerName__r.Possession_Date__c,
                            Booking__r.Wing__c, Booking__r.Unit_No__r.TowerName__r.Zone_Name__r.Name, Booking__r.Unit_No__r.Relationship_Manager__r.User__c,
                            Booking__r.RW_Agreement_Possession_Date__c, Booking__r.RW_Registration_Date__c, Booking__r.FBL5N__c, Booking__r.RW_Total_Interest__c,
                            Booking__r.Primary_Applicant_Name__c
                            FROM Opportunity WHERE StageName = 'Unit Booked' AND Account.Mobile_No__c =: updatedMobile ORDER BY Booking__r.Booking_Date__c DESC LIMIT 1];
                    }
                }else{
                    opps = [SELECT Id, Name, SAP_Customer_Number__c, Booking__c, Booking__r.Name, Booking__r.Status__c, Booking__r.Project__c, RW_Email__c,
                            Booking__r.RM_Name__c, Booking__r.Unit_No__r.RW_Param4__c, Booking__r.Unit_No__r.RW_Param2__c, Booking__r.Unit_No__r.RW_Param3__c,
                            Booking__r.RW_Booking_Confirmed_Date__c, Booking__r.RW_Total_Demand_Outstanding__c, Booking__r.RW_Project_Name__c,
                            Booking__r.Latest_Demand_Due_Date__c, RW_Project__r.RW_SAP_Company_Code__c, Booking__r.Unit_No__r.TowerName__r.Possession_Date__c,
                            Booking__r.Wing__c, Booking__r.Unit_No__r.TowerName__r.Zone_Name__r.Name, Booking__r.Unit_No__r.Relationship_Manager__r.User__c,
                            Booking__r.RW_Agreement_Possession_Date__c, Booking__r.RW_Registration_Date__c, Booking__r.FBL5N__c, Booking__r.RW_Total_Interest__c,
                            Booking__r.Primary_Applicant_Name__c
                            FROM Opportunity WHERE StageName = 'Unit Booked' AND Account.Mobile_No__c =: updatedMobile ORDER BY Booking__r.Booking_Date__c DESC LIMIT 1];
                }
            }
            
            
            
            
            System.debug('opps: ' + opps);
            if(opps.size() > 0){
                return custDetails(opps[0]);
            }else{
                CustomerDetails details1 = new CustomerDetails();
                details.message = 'Customer does not exist with this mobile number';
                return details;
            }
        }else if(type == 'crn' && num != null && num != ''){
            num = '%'+ num;
            opps = [SELECT Id, Name, SAP_Customer_Number__c, Booking__c, Booking__r.Name, Booking__r.Status__c, Booking__r.Project__c, RW_Email__c,
                    Booking__r.RM_Name__c, Booking__r.Unit_No__r.RW_Param4__c, Booking__r.Unit_No__r.RW_Param2__c, Booking__r.Unit_No__r.RW_Param3__c,
                    Booking__r.RW_Booking_Confirmed_Date__c, Booking__r.RW_Total_Demand_Outstanding__c, Booking__r.RW_Project_Name__c,
                    Booking__r.Latest_Demand_Due_Date__c, RW_Project__r.RW_SAP_Company_Code__c, Booking__r.Unit_No__r.TowerName__r.Possession_Date__c,
                    Booking__r.Wing__c, Booking__r.Unit_No__r.TowerName__r.Zone_Name__r.Name, Booking__r.Unit_No__r.Relationship_Manager__r.User__c,
                    Booking__r.RW_Agreement_Possession_Date__c, Booking__r.RW_Registration_Date__c, Booking__r.FBL5N__c, Booking__r.RW_Total_Interest__c,
                    Booking__r.Primary_Applicant_Name__c
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
        }
        
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
        //details.Customer_Name = opp.Name; //Commented by coServe 25-06-2024
        details.Customer_Name = (opp.Booking__r.Primary_Applicant_Name__c != null)? opp.Booking__r.Primary_Applicant_Name__c : opp.Name;//Added by coServe 25-06-2024
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
    global static void doPost(String crn, String customer, String option, String companyCode, String project, String booking, String rmId, String customer_email){
        try{
            System.debug('--option--:' + option);
            //Added by coServe 08-01-2024 Start
            Id recId = booking;
            String sObjName = recId.getSObjectType().getDescribe().getName();
            if(sObjName == 'Booking__c'){
                Booking__c bkg = [SELECT Id, Opportunity__c FROM Booking__c WHERE Id =: booking LIMIT 1];
                booking = bkg.Opportunity__c;
            }
            //Added by coServe 08-01-2024 End
            
            if(option == 'Booking Confirmation Letter'){
                bookingConfirmLetter(crn, customer, project, booking, rmId, customer_email);
            }else if(option == 'Account Statement'){
                accountStatement(crn, customer, companyCode, project, booking, rmId, customer_email);
            }else if(option == 'Payment Online'){
                paymentOnline(crn, customer, project, booking, rmId, customer_email);
            }else if(option == 'Latest Demand Letter'){
                latestDemandLetter(crn, customer, project, booking, rmId, customer_email);
            }else if(option == 'Last 3 Demand Letters'){
                lastThreeDemands(crn, customer, project, booking, rmId, customer_email);
            }else if(option == 'Latest Payment Receipt'){
                latestReceipt(crn, customer, project, booking, rmId, customer_email);
            }else if(option == 'Last 3 Payment Receipts'){
                lastThreeReceipts(crn, customer, project, booking, rmId, customer_email);
            }else if(option == 'Loan Process'){
                loanProcess(crn, customer, project, booking, rmId, customer_email);
            }else if(option == 'Call Back'){
                callBack(crn, customer, project, booking, rmId, customer_email);
            }else if(option == 'Interest Statement'){
                interestStatement(crn, customer, companyCode, project, booking, rmId, customer_email);
            }
        }catch(exception e){ // Added by Vinay 23-06-2025
            ERP_Integration_Log__c log = new ERP_Integration_Log__c();
            log.Booking__c = (booking != '')? booking : null;
            log.request__c = 'crn: ' + crn + ', customer: ' + customer +  ', option: ' + option + ', companyCode: ' + companyCode + ', project: ' + project + ', booking: ' + booking + ', rmId: ' + rmId + ', customer_email: ' + customer_email;
            log.API_name__c = 'IVR';
            log.response__c = e.getMessage();
            log.Status__c = 'Failure';
            log.Error_Type__c = 'Data Error';
            log.Error_Reason__c = e.getMessage();
            insert log;
        }
    }
    
    public static void bookingConfirmLetter(String crn, String customer, String project, String booking, String rmId, String email){
        
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
        
        /*list<Messaging.SingleEmailMessage> messages = new list<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        EmailTemplate template = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName = 'Booking_Confirmation'];
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
        update tsk;*/
        
    }
    
    public static void accountStatement(String crn, String customer, String companyCode, String project, String booking, String rmId, String email){
        
        Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Service Task').getRecordTypeId();
        Task tsk = new Task();
        tsk.RecordTypeId = recordTypeId;
        tsk.Subject = 'Account Statement';
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
            try{
                Messaging.SendEmailResult[] result = Messaging.sendEmail(messages);
                System.debug('--result--: ' + result);
                if(result[0].isSuccess()){
                    tsk.Status = 'Completed';
                }
            }catch(Exception e){
                System.debug('--Error--'+e.getMessage());
                tsk.Description = 'Error: ' + e.getMessage();
            }
            update tsk;
        }
        
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
            System.debug('--Error--'+e.getMessage());
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
                System.debug('--result--: ' + result);
                if(result[0].isSuccess()){
                    tsk.Status = 'Completed';
                }
            }catch(Exception e){
                System.debug('--Error--'+e.getMessage());
                tsk.Description = 'Error: ' + e.getMessage();
            }
            update tsk;
        }
        
    }
    
    public static void paymentOnline(String crn, String customer, String project, String booking, String rmId, String email){
        
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
        
        String siteUrl = 'https://runwal.my.salesforce-sites.com/ivronlinepay?crn='+crn;
        
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
    }   
    
    public static void latestDemandLetter(String crn, String customer, String project, String booking, String rmId, String email){
        
        Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Service Task').getRecordTypeId();
        Task tsk = new Task();
        tsk.RecordTypeId = recordTypeId;
        tsk.Subject = 'Latest Demand Letter';
        tsk.Priority = 'Normal';
        tsk.Status = 'Not Started';
        tsk.Project__c = (project != null && project != '') ? project : null;
        tsk.WhatId = booking;
        tsk.OwnerId = (rmId != null && rmId != '') ? rmId : UserInfo.getUserId();
        
        List<RW_Demand__c> demands = [SELECT Id, Name FROM RW_Demand__c WHERE Booking__r.Opportunity__r.SAP_Customer_Number__c =: crn AND RW_Demand_Status__c != 'Revoke' AND Demand_Amount__c != 0 ORDER BY CreatedDate Desc LIMIT 1];
        String body;
        Boolean isError = false;
        try{
            if(!Test.isRunningTest() && demands.size() > 0){
                body = PDFController.getdemandPdf(demands[0].Id);
            }else if(Test.isRunningTest()){
                body = 'Test';
            }
        }catch(Exception e){
            System.debug('--Error--'+e.getMessage());
            isError = true;
            tsk.Description = 'Error: ' + e.getMessage();
        }
        insert tsk;
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
        }
    }
    
    public static void lastThreeDemands(String crn, String customer, String project, String booking, String rmId, String email){
        
        Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Service Task').getRecordTypeId();
        Task tsk = new Task();
        tsk.RecordTypeId = recordTypeId;
        tsk.Subject = 'Last 3 Demand Letters';
        tsk.Priority = 'Normal';
        tsk.Status = 'Not Started';
        tsk.Project__c = (project != null && project != '') ? project : null;
        tsk.WhatId = booking;
        tsk.OwnerId = (rmId != null && rmId != '') ? rmId : UserInfo.getUserId();
        
        List<RW_Demand__c> demands = [SELECT Id, Name FROM RW_Demand__c WHERE Booking__r.Opportunity__r.SAP_Customer_Number__c =: crn AND RW_Demand_Status__c != 'Revoke' AND Demand_Amount__c != 0 ORDER BY CreatedDate Desc LIMIT 3];
        List<Messaging.EmailFileAttachment> atts = new List<Messaging.EmailFileAttachment>();
        Boolean isError = false;
        try{
            for(RW_Demand__c dem : demands){
                String body1;
                if(!Test.isRunningTest() && demands.size() > 0){
                    body1 = PDFController.getdemandPdf(dem.Id);
                }else if(Test.isRunningTest()){
                    body1 = 'Test';
                }
                Messaging.EmailFileAttachment att1 = new Messaging.EmailFileAttachment();
                att1.setFileName(dem.Name+'.pdf');
                att1.setBody(EncodingUtil.base64Decode(body1));
                atts.add(att1);  
            }
        }catch(Exception e){
            System.debug('--Error--'+e.getMessage());
            isError = true;
            tsk.Description = 'Error: ' + e.getMessage();
        }
        
        insert tsk;
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
        }
        
    }
    
    public static void latestReceipt(String crn, String customer, String project, String booking, String rmId, String email){
        Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Service Task').getRecordTypeId();
        Task tsk = new Task();
        tsk.RecordTypeId = recordTypeId;
        tsk.Subject = 'Latest Payment Receipt';
        tsk.Priority = 'Normal';
        tsk.Status = 'Not Started';
        tsk.Project__c = (project != null && project != '') ? project : null;
        tsk.WhatId = booking;
        tsk.OwnerId = (rmId != null && rmId != '') ? rmId : UserInfo.getUserId();
        
        List<RW_Payment_Details__c> recps = [SELECT Id, Name FROM RW_Payment_Details__c WHERE RW_Booking__r.Opportunity__r.SAP_Customer_Number__c =: crn AND RW_Document_Type__c IN ('DZ','DT','DF') AND Status__c != 'Reversed' ORDER BY CreatedDate Desc LIMIT 1];
        String body;
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
        }
    }
    
    public static void lastThreeReceipts(String crn, String customer, String project, String booking, String rmId, String email){
        
        Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Service Task').getRecordTypeId();
        Task tsk = new Task();
        tsk.RecordTypeId = recordTypeId;
        tsk.Subject = 'Last 3 Payment Receipts';
        tsk.Priority = 'Normal';
        tsk.Status = 'Not Started';
        tsk.Project__c = (project != null && project != '') ? project : null;
        tsk.WhatId = booking;
        tsk.OwnerId = (rmId != null && rmId != '') ? rmId : UserInfo.getUserId();
        
        List<RW_Payment_Details__c> recps = [SELECT Id, Name FROM RW_Payment_Details__c WHERE RW_Booking__r.Opportunity__r.SAP_Customer_Number__c =: crn AND RW_Document_Type__c IN ('DZ','DT','DF') AND Status__c != 'Reversed' ORDER BY CreatedDate Desc LIMIT 3];
        List<Messaging.EmailFileAttachment> atts = new List<Messaging.EmailFileAttachment>();
        Boolean isError = false;
        try{
            for(RW_Payment_Details__c rec : recps){
                String body1;
                if(!Test.isRunningTest() && recps.size() > 0){
                    body1 = PDFController.getreceiptPdf(rec.Id);
                }else if(Test.isRunningTest()){
                    body1 = 'Test';
                }
                Messaging.EmailFileAttachment att1 = new Messaging.EmailFileAttachment();
                att1.setFileName(rec.Name+'.pdf');
                att1.setBody(EncodingUtil.base64Decode(body1));
                atts.add(att1);  
            }
        }catch(Exception e){
            System.debug('--Error--'+e.getMessage());
            isError = true;
            tsk.Description = 'Error: ' + e.getMessage();
        }
        
        insert tsk;
        if(atts != null && atts.size() > 0 && !isError){
            list<Messaging.SingleEmailMessage> messages = new list<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = new List<String>{email};
                message.subject = 'Last 3 Payment Receipts';
            String htmlBody = 'Dear ' + customer + ',<br/><br/>  Please find the last three Receipt Letters as requested.';
            htmlBody += '<br/><br/>Regards,<br/>Customer Care Team.';
            message.setHtmlBody(htmlBody);  
            message.setFileAttachments(atts);
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
        }
    }
    
    public static void loanProcess(String crn, String customer, String project, String booking, String rmId, String email){
        
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
    }
    
    public static void callBack(String crn, String customer, String project, String booking, String rmId, String email){
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
        
    }
}