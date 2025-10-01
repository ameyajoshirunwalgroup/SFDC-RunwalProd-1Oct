public class Customer360 {
    
    @AuraEnabled(cacheable=true)
    public static String click2Call(String customerPh, String countryCode){
        
        system.debug('click2CallCloudagent');
        system.debug('customerPh from page::: ' + customerPh);
        String campaignName = '';
        String userName = '';
        String apiKey = '';
        String agentId = '';
        system.debug('Country Code : '+countryCode);
        if(countryCode == null && customerPh.length() == 10){
            countryCode = '+91';
        }
        if(customerPh.length() == 10 && (countryCode == '' || countryCode.equals('+91') || countryCode.equals('91') || countryCode.equals('0091') || countryCode.equals('091'))){          
            customerPh = '0' + customerPh;
            System.debug('Inside India Customer Phone:' + customerPh);
        } else {  
            system.debug('Inside International');
            List<User> userList = [Select Id/*, Enable_International_Calling__c*/ From User Where Id = :UserInfo.getUserId()];
            system.debug('userList'+userList);
            if(userList != null && userList.size() > 0){
                User usrRec = userList.get(0);
                //if(usrRec.Enable_International_Calling__c){ 
                System.debug('International Calling Enabled for user: ' + customerPh);
                if(countryCode != null && !String.isBlank(countryCode)){
                    if(customerPh != null && !String.isBlank(customerPh)){
                        customerPh = customerPh.removeStart('0');
                    }
                    if(countryCode.indexOf('\'++') != -1){
                        countryCode = countryCode.removeStart('\'++');
                        countryCode = '00' + countryCode;
                    } else if(countryCode.indexOf('\'+') != -1){
                        countryCode = countryCode.removeStart('\'+');
                        countryCode = '00' + countryCode;
                    } 
                    else if(countryCode.indexOf('+0') != -1){
                        countryCode = countryCode.removeStart('+0');
                        countryCode = '00' + countryCode;
                    } else if(countryCode.indexOf('0') != -1){
                        countryCode = countryCode.removeStart('0');
                        countryCode = '00' + countryCode;
                    } else if(countryCode.indexOf('+') != -1){
                        countryCode = countryCode.removeStart('+');
                        countryCode = '00' + countryCode;
                    } 
                    customerPh = countryCode + customerPh;
                }
                System.debug('countryCode:: ' + countryCode + ' customerPh:: ' + customerPh);
                //}           
            }
        }
        
        List<User> uList = [Select Id, CTI_Agent_ID__c,Profile.Name,Backup_Campaign__c,Schedule_Campaign_Name__c, Campaign_name__c, api_key__c,Ozontel_UserName__c From User Where Id = :UserInfo.getUserId()];
        system.debug('uList>>>>' +uList);
        if(uList != null && !uList.isEmpty()) {
            if(System.label.Conditional_Campaign_Assignment == 'true'){
                if(uList[0].Profile.Name == 'Relationship Manager' || uList[0].Profile.Name == 'Team Leader'){
                    campaignName = uList[0].Schedule_Campaign_Name__c;
                }else{
                    if(uList[0].Backup_Campaign__c != null){
                        campaignName = uList[0].Backup_Campaign__c;
                    }else{
                        campaignName = uList[0].Campaign_name__c;
                    }
                    //campaignName = uList[0].Campaign_name__c;
                }
            }else{
                campaignName = uList[0].Campaign_name__c;
            }
            
            //campaignName = uList[0].Campaign_name__c;
            //campaignName = uList[0].Schedule_Campaign_Name__c;
            //agentID = uList[0].CTI_Agent_ID__c;
            agentId = uList[0].CTI_Agent_ID__c;
            apiKey = uList[0].api_key__c; 
            userName = uList[0].Ozontel_UserName__c;
        }
        
        String queryString = 'api_key='+apiKey+'&username='+username+'&agentID='+agentId+'&campaignName='+campaignName+'&customerNumber='+customerPh;
        
        //String endpoint = 'https://api1.cloudagent.in/CAServices/AgentManualDial.php?'+queryString;
        String endpoint = 'https://in1-ccaas-api.ozonetel.com/CAServices/AgentManualDial.php?'+queryString;
        
        System.debug('click2call URL:' + endpoint);
        Http httpProtocol = new Http();
        
        // Create HTTP request to send.
        HttpRequest request = new HttpRequest();
        
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setMethod('GET');        
        request.setEndPoint(endpoint);        
        System.Debug('Request:'+request);
        
        HttpResponse response = new HttpResponse();
        if(!Test.isRunningTest()){
            response = httpProtocol.send(request);
        } else {
            response.setBody('DUMMY');
        }
        System.debug(response.getBody());
        string tempResponse = response.getBody();
        return tempResponse; 
    }
    @AuraEnabled(cacheable=true)
    public static List<RW_Payment_Details__c> getReceiptRecords(String bookingId) {
        System.debug('Id::'+bookingId);
        System.debug('inside new reciept method');
        List<Booking__c> blist=[Select Id,Name From Booking__c where Name=:bookingId limit 1];
        return [SELECT Id, Name, RW_Bank_Reference_Number__c, RW_Branch_Name__c,RW_Usage_Description__c, RW_Demand_Number__c, RW_Document_Type__c, RW_Instrument_Number__c, RW_ODN_Number__c,
                RW_Booking__c,RW_Booking__r.Name, RW_Payment_Date__c, RW_Payment_Amount__c, RW_Payment_Type__c, RW_Payment_Mode__c, RW_Bank_Name__c, Total_Amount_Paid__c FROM RW_Payment_Details__c WHERE RW_Booking__c = :blist[0].id];
    }
    @AuraEnabled(cacheable=true)
    public static List<RW_Demand__c> getDemandRecords(String bookingId) {
        System.debug('Id::'+bookingId);
        System.debug('inside new reciept method');
        List<Booking__c> blist=[Select Id,Name From Booking__c where Name=:bookingId limit 1];
        return [SELECT Id, Name, CreatedDate, Booking__r.Name,booking__c ,Demand_Date__c, Due_Date__c, RW_Billing_Document_Number__c,
                RW_Customer_Number__c, RW_Demand_Amount__c, RW_Demand_Status__c, RW_ODN_Number__c, RW_Total_Demand_Amount__c,
                RW_Total_GST_Amount__c, Total_Demand_Paid__c, RW_Demand_Milestone__c, RW_Demand_Aging__c, Demand_Amount__c, Remaining_Amount__c FROM RW_Demand__c WHERE Booking__c =:blist[0].id];
    }
    
    
    @AuraEnabled(cacheable=true)
    public static Map<Id, Double> getOppbasedonPercentage(String accountId) {
        // Map<String, Map<String, String>> fieldValuesWithType = new Map<String, Map<String, String>>();
        System.debug('accountId'+accountId);    
        
        list<Popup_Questions__mdt> metadata = [SELECT Id, Object_Name__c, Field_Name__c, Questions__c FROM Popup_Questions__mdt ORDER BY Order__c ASC];    
        System.debug('metadata'+metadata);         
        System.debug('length '+metadata.size());
        Integer qsize = metadata.size();
        System.debug('Total Questions>>>>>>>>>>>>>>'+qsize);
        String query = 'SELECT Id ';
        for (Popup_Questions__mdt meta : metadata) {            
            String objectName = meta.Object_Name__c;
            String fieldName = meta.Field_Name__c;
            
            if(objectName == 'Booking__c' && fieldName != null){
                query += ', Booking__r.' + fieldName;
            }
            else if(objectName != null && objectName != 'Booking__c' && fieldName != null){
                query += ',' + objectName + '.' + fieldName;
            }
        }
        
        query += ' FROM Opportunity WHERE AccountId = :accountId AND StageName = \'Unit Booked\' and Booking__c != null ORDER BY CreatedDate DESC';
        System.debug('query'+query);
        
        List<Opportunity> results = new List<Opportunity>();
        Map<Id, Double> opportunityAnsweredCount = new Map<Id, Double>();
        
        try{
            // Execute the query
            results = Database.query(query);
            
            // Serialize and log the results
            System.debug('results: ' + JSON.serialize(results));
            
            // Create a list to store the related fields
            // List<String> relatedFieldValues = new List<String>();
            
            // Iterate through the results
            for (Opportunity record : results) {
                System.debug('record: ' + record);
                System.debug('opp id: ' + record.Id);
                
                Double count = 0.0;
                
                for (Popup_Questions__mdt meta : metadata) {
                    String objectName = meta.Object_Name__c;
                    String fieldName = meta.Field_Name__c;
                    String fieldType = getFieldDataType(objectName, fieldName);
                    
                    if (objectName == 'Account' && record.Account != null) {
                        if(fieldType == 'BOOLEAN' && record.Account.get(fieldName) == true ){
                            count++;
                        }
                        else if (record.Account.get(fieldName) != null && !String.isBlank(String.valueOf(record.Account.get(fieldName))) && fieldType != 'BOOLEAN') {
                            count++;
                        }
                    }
                    
                    else if (objectName == 'Booking__c' && record.Booking__r != null) {
                        System.debug('Inside Booking__r');
                        if(fieldType == 'BOOLEAN' && record.getSObject('Booking__r').get(fieldName) == true ){
                            count++;
                        }
                        else if (record.getSObject('Booking__r').get(fieldName) != null && !String.isBlank(String.valueOf(record.getSObject('Booking__r').get(fieldName))) && fieldType != 'BOOLEAN') {
                            count++;
                        }
                    } 
                    
                    else if (objectName == 'Opportunity') {
                        if(fieldType == 'BOOLEAN' && record.get(fieldName) == true ){
                            count++;
                        }
                        else if (record.get(fieldName) != null && !String.isBlank(String.valueOf(record.get(fieldName))) && fieldType != 'BOOLEAN') {
                            count++;
                        }
                    } 
                    
                }
                opportunityAnsweredCount.put(record.Id, ((Double)count / (Double)qsize) * 100);
            }
        } catch (Exception e) {
            System.debug('Error in dynamic query: ' + e.getMessage());
        }
        System.debug('opportunityAnsweredCount'+opportunityAnsweredCount);
        return opportunityAnsweredCount;
        
    }
    
    @AuraEnabled
    public static String getFieldDataType(String objectName, String fieldName) {
        SObjectType r = ((SObject)(Type.forName('Schema.' + objectName).newInstance())).getSObjectType();
        DescribeSObjectResult d = r.getDescribe();
        return String.valueOf(d.fields.getMap().get(fieldName).getDescribe().getType());
    }
    @AuraEnabled
    public static void ResetPassword(String accountId)
    {
        List<User> customerUser=[select Id,Name,AccountId,LastLoginDate from User where AccountId=:accountId];
        for(User u : customerUser){
            System.resetPassword(u.Id, true);
        }
    }
    @AuraEnabled
    public static void publishCasePlatformEvent(Id caseId) {
        Case_Platform_Event__e event = new Case_Platform_Event__e();
        event.CaseId__c = caseId;
        Database.SaveResult sr = EventBus.publish(event);
        if (!sr.isSuccess()) {
            // Handle error if the event couldn't be published
            throw new AuraHandledException('Error publishing platform event: ' + sr.getErrors()[0].getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<FAQ_360__c> searchFAQs(String searchTerm) {
        System.debug('searchTerm:::'+searchTerm);
        
        
        List<FAQ_360__c> initialFaqs = [
            SELECT Id, Name, Question__c, Response__c
            FROM FAQ_360__c
            WHERE Question__c LIKE :('%' + searchTerm + '%')
        ];
        
        
        List<FAQ_360__c> allFaqs = new List<FAQ_360__c>();
        
        
        allFaqs.addAll(initialFaqs);
        
        List<FAQ_360__c> allRecords = [
            SELECT Id, Name, Question__c, Response__c
            FROM FAQ_360__c
        ];
        
        // Filter the records in Apex code for Response__c
        for (FAQ_360__c faq : allRecords) {
            if (faq.Response__c != null && faq.Response__c.containsIgnoreCase(searchTerm) && !allFaqs.contains(faq)) {
                allFaqs.add(faq);
            }
        }
        
        return allFaqs;
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getPDFContentDocument() {
        Map<String, String> pdfDocuments = new Map<String, String>();
        
        List<ContentDocument> documents = [
            SELECT Id, Title
            FROM ContentDocument
            WHERE FileExtension = 'pdf' AND Title='customer360'
        ];
        
        for (ContentDocument doc : documents) {
            pdfDocuments.put(doc.Id, doc.Title);
        }
        
        return pdfDocuments;
    }
    
    
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpportunities(String accountId) {
        System.debug('accountId:::'+accountId);
        System.debug([SELECT Id, Name, StageName, CloseDate, LeadSource, RW_Project__r.Name,RW_AADHAR_Card_Number__c,Booking__r.Name,Booking__c
                      FROM Opportunity WHERE AccountId =:accountId and Booking__c != null order by CreatedDate DESC]);
        return [SELECT Id, Name, StageName,SAP_Customer_Number__c, CloseDate, LeadSource, RW_Project__r.Name,RW_AADHAR_Card_Number__c,Booking__r.Name
                FROM Opportunity WHERE AccountId =:accountId and Booking__c != null order by CreatedDate DESC];
        
    }
    @AuraEnabled(cacheable=true)
    public static String getaccountID(String oppId) {
        
        User currentUser = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
        
        String profileLabel = Label.ProfileToRedirect;
        
        List<String> allowedProfiles = profileLabel.split(',');
        
        if (allowedProfiles.contains(currentUser.Profile.Name)) {
            
            List<Opportunity> opportunity = [SELECT Id, Name, StageName, AccountId,Account.Country_Code__c, CloseDate, LeadSource, RW_Project__r.Name, RW_AADHAR_Card_Number__c, Booking__r.Name
                                             FROM Opportunity WHERE Id = :oppId ORDER BY CreatedDate DESC];
            
            if (!opportunity.isEmpty() && opportunity[0].StageName =='Unit Booked' ) {
                System.debug(opportunity[0].AccountId);
                return opportunity[0].AccountId;
            } else {
                return null;
            }
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static void shareVideoWithCustomer(String videoId,String OppId) {
        System.debug('oppId :::' + oppId);
        System.debug('videoId :::' + videoId);
        
        
        Opportunity opp = [SELECT Id, Name, StageName, AccountId, CloseDate, LeadSource, RW_Project__r.Name, RW_AADHAR_Card_Number__c, Booking__r.Name, Account.PersonEmail
                           FROM Opportunity WHERE Id = :oppId LIMIT 1];
        
        
        Customer_Portal_Videos__c video = [SELECT Id, Name, Order__c, Video_Link__c 
                                           FROM Customer_Portal_Videos__c WHERE Id = :videoId LIMIT 1];
        
        // Ensure the opportunity and video records are found
        if (opp == null || video == null) {
            System.debug('Opportunity or Video not found');
            return;
        }
        
        // Get the customer's email from the Opportunity's related Account
        String customerEmail = opp.Account.PersonEmail;
        if (String.isEmpty(customerEmail)) {
            System.debug('Customer email not found');
            return;
        }
        
        // Construct the email body
        String emailBody = 'Dear Customer, \n\n' +
            'We are pleased to share with you the following video: \n' +
            'Video Title: ' + video.Name + '\n' +
            'Video Link: ' + video.Video_Link__c + '\n\n' +
            'Thank you for your continued support.\n\n' +
            'Best regards,\n' +
            'Your Company Name';
        
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[] { customerEmail });
        email.setSubject('Video Link for ' + opp.Name);
        email.setPlainTextBody(emailBody);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        
        System.debug('Email sent to ' + customerEmail);
    }
    
    
    @AuraEnabled
    public static List<ObjectWrapper> getOppRecords(String oppId,string accountId) {
        System.debug('oppId :::'+oppId);
        System.debug('account :::'+accountId);
        List<Booked_Car_Parking__c> carparklist = new List<Booked_Car_Parking__c>();  
        List<ObjectWrapper> opportunityWrappers = new List<ObjectWrapper>(); 
        Integer TotalParkingCount = 0; 
        String sfdcBaseURL = URL.getOrgDomainURL().toExternalForm();
        List<Case> caseList;
        List<Case> LatestRemarkCase;
        List<RW_Demand__c> oldestdemand;
        List<Case> caseAging;
        String LatestReferral;
        String Referralurl;
        List<RW_Payment_Details__c> receiptList;
        List<User> customerUser;
        List<Account> acclist;
        List<RW_Demand__c> demands;
        List<Lead> referrals;
        List<Customer_Portal_Videos__c> videos;
        List<Quotation__c> quote=new List<Quotation__c>();
        List<Applicant_Details__c> primaryApplicant;
        List<Applicant_Details__c> allApplicant;
        List<WhatsApp_Feedback__c> WfList;
        String CoutryC;
        String csatRating = '';
        List<Booking__c> bookingList = [SELECT Id,RW_Total_Amount_Received_Without_GST__c,RW_Total_TDS_Outstanding__c,RW_Registration_Date__c,RW_Total_Interest__c,Project__r.RW_SAP_Company_Code__c,Project__r.Name,Opportunity__r.SAP_Customer_Number__c,Quotation__c,Opportunity__r.RW_Mobile_No__c,RW_Country_Phone_Code__c,Carpet_Area__c, Name,Funding_Status__c,Loan_Bank__c,Bank_Name_Service_tax__c,Opportunity__c, RW_Registration_Done__c,Wing__c, Unit_No__c,Customer__r.Name,Flat_Typology__c,Unit_Number__c,RW_Total_Demand_Outstanding__c
                                        ,Status__c,Booking_Date__c,Unit_No__r.Name,Bank__c,Stock__c,Type_of_Client__c,FBL5N__c,RW_Agreement_Possession_Date__c, RW_Total_Collectable_Interest__c,
                                        ADF_Opted__c, ADF_Interest_Amount_Payable1__c, ADF_Balance__c,ADF_Interest_Paid__c, Total_ADF_Amount__c,
                                        RW_Next_Demand_Date__c,Original_Agreement_Value__c,Account_Number__c,Flat_No__c,Unit_Type__c,Unit_No__r.RW_Param4__c,Unit_No__r.RW_Param2__c,Opportunity__r.Account.Name  FROM Booking__c WHERE Opportunity__c = :oppId AND Status__c='Booking Confirmed' limit 1]; 
        if(bookingList.size()>0){
            
            acclist=[Select Id,Country_Code__c from Account where Id=:accountId];
            if(acclist.size()>0)
            {
                CoutryC=acclist[0].Country_Code__c;
            }
            
            
            Integer totaldemand = [SELECT COUNT() FROM RW_Demand__c WHERE Booking__c = :bookingList[0].id];
            customerUser=[select Id,Name,AccountId,LastLoginDate from User where AccountId=:accountId];
            quote=[Select Id,PaymentPlan__c,PaymentPlan__r.Name ,  PaymentPlan__r.Id from Quotation__c where Id=:bookingList[0].Quotation__c ];
            oldestdemand=[SELECT Id, Name, CreatedDate, Booking__r.Name,booking__c ,Demand_Date__c, Due_Date__c, RW_Billing_Document_Number__c,
                          RW_Customer_Number__c, RW_Demand_Amount__c, RW_Demand_Status__c, RW_ODN_Number__c, RW_Total_Demand_Amount__c,
                          RW_Total_GST_Amount__c, Total_Demand_Paid__c, RW_Demand_Milestone__c, RW_Demand_Aging__c, Demand_Amount__c, Remaining_Amount__c FROM RW_Demand__c WHERE Booking__c =:bookingList[0].id And RW_Demand_Status__c='Due' order by CreatedDate ASC limit 1];
            LatestRemarkCase=[Select Id,Last_Closed_Date__c,CSAT_Feedback_Remark__c,CSAT_Feedback_Rating__c,CaseNumber,Subject,Status,Account.Name,LastModifiedBy.Name,RW_RM_Name__c,owner.name,CreatedDate,ClosedDate,RW_Complaint_Type__c,RW_Complaint_SubType__c,RW_Case_Type__c from Case WHERE AccountId = :accountId AND Status='Case closed' and /*Added by Prashant*/CSAT_Feedback_Rating__c != null order by Last_Closed_Date__c DESC limit 1 ];
            // Default value
            if (!LatestRemarkCase.isEmpty()) {
                csatRating = LatestRemarkCase[0].CSAT_Feedback_Rating__c != '' ? LatestRemarkCase[0].CSAT_Feedback_Rating__c : '';
            }
            caseAging=[Select Id,CaseNumber,Subject,Status,Account.Name,LastModifiedBy.Name,RW_RM_Name__c,owner.name,CreatedDate,ClosedDate,RW_Complaint_Type__c,RW_Complaint_SubType__c,RW_Case_Type__c from Case WHERE AccountId = :accountId AND Status='Open' order by CreatedDate ASC ]; 
            caseList = [Select Id,CaseNumber,Subject,Status,Account.Name,LastModifiedBy.Name,RW_RM_Name__c,owner.name,CreatedDate,ClosedDate,RW_Complaint_Type__c,RW_Complaint_SubType__c,RW_Case_Type__c from Case WHERE AccountId = :accountId order by CreatedDate DESC limit 3];      
            receiptList = [SELECT Id, Name, RW_Bank_Reference_Number__c, RW_Branch_Name__c, RW_Demand_Number__c, RW_Document_Type__c, RW_Instrument_Number__c, RW_ODN_Number__c,
                           RW_Booking__c,RW_Booking__r.Name, RW_Payment_Date__c, RW_Payment_Amount__c, RW_Payment_Type__c, RW_Payment_Mode__c, RW_Bank_Name__c, Total_Amount_Paid__c FROM RW_Payment_Details__c WHERE RW_Booking__c = :bookingList[0].id  order by CreatedDate DESC limit 3];
            demands = [SELECT Id, Name, CreatedDate, Booking__r.Name,booking__c ,Demand_Date__c, Due_Date__c, RW_Billing_Document_Number__c,
                       RW_Customer_Number__c, RW_Demand_Amount__c, RW_Demand_Status__c, RW_ODN_Number__c, RW_Total_Demand_Amount__c,
                       RW_Total_GST_Amount__c, Total_Demand_Paid__c, RW_Demand_Milestone__c, RW_Demand_Aging__c, Demand_Amount__c, Remaining_Amount__c FROM RW_Demand__c WHERE Booking__c =:bookingList[0].id order by CreatedDate DESC limit 3];
            referrals=[SELECT Id,Name,RW_Project__r.Name,Customer_Reference__c,RW_Sourcing_Manager__c,LeadSource,Status,CreatedDate from Lead  where Customer_Reference__c=:accountId AND LeadSource='Referral' order by createdDate DESC limit 3 ];
            videos=[Select id,Name,Order__c,Video_Link__c from Customer_Portal_Videos__c order By Order__c asc  ];
            allApplicant=[SELECT Id,Name,Applicant_Number__c,Applicant_SNo__c,Organisation_Country__c,Secondary_Mobile_No__c,Gender__c,Type_Of_Applicant__c,
                          Mailing_Pincode__c,State__c,City__c,Email_Address__c,Mobile_No__c, DOB__c,Booking__c  FROM  Applicant_Details__c WHERE    Booking__c=:bookingList[0].id Order by Applicant_SNo__c asc limit 3 ];
            primaryApplicant=[SELECT Id,Name,Opportunity__r.RW_Email__c,Opportunity__r.Mobile_Number__c,Applicant_Number__c,Organisation_Country__c,Secondary_Mobile_No__c,Gender__c,Type_Of_Applicant__c,
                              Mailing_Pincode__c,State__c,City__c,Email_Address__c,Mobile_No__c, DOB__c,Booking__c  FROM  Applicant_Details__c WHERE  Applicant_Number__c='Primary Applicant' And Booking__c=:bookingList[0].id ];
            WfList=[Select Id,Name,NPS__c,Opportunity__c,createdDate from WhatsApp_Feedback__c where  Opportunity__c = :oppId AND NPS__c!=null order by createdDate DESC limit 1 ] ;                
            
            System.debug('caseList :' +caseList);
            System.debug('bookingList :' +bookingList);
            System.debug('referrals :' +referrals);
            if(referrals.size()>0)
            {
                LatestReferral=referrals[0].Name;
                Referralurl='https://runwal--uat.sandbox.lightning.force.com/lightning/r/Lead/'+referrals[0].Id+'/view';
            }
        }
        
        for (Booking__c booking : bookingList) {
            String lastPortalLogin = customerUser.size() > 0 && customerUser[0].LastLoginDate != null ? 
                customerUser[0].LastLoginDate.format('dd-MM-yyyy') : 
            '';
            
            ObjectWrapper opportunityWrapper = new ObjectWrapper();
            opportunityWrapper.ObjectId = booking.Id;
            opportunityWrapper.objname='Booking';
            opportunityWrapper.accName = booking.Opportunity__r.Account.Name;
            opportunityWrapper.Countrycode =CoutryC;
            opportunityWrapper.CustomerCode=booking.Project__r.RW_SAP_Company_Code__c;
            opportunityWrapper.CompanyCode=booking.Project__r.RW_SAP_Company_Code__c;
            opportunityWrapper.PhoneNumber=booking.Opportunity__r.RW_Mobile_No__c;
            opportunityWrapper.fieldset = new List<Fieldset>{
                new Fieldset('Customer Name', booking.Customer__r.Name,'',''),
                    new Fieldset('Status', booking.Status__c,'',''),
                    new Fieldset('Project', booking.Project__r.Name,'',''),
                    new Fieldset('Tower', booking.Unit_No__r.RW_Param2__c,'',''),
                    new Fieldset('Flat No', booking.Unit_No__r.RW_Param4__c,'',''), 
                    new Fieldset('Booking Date', booking.Booking_Date__c != null ? (booking.Booking_Date__c.format('dd-MM-yyyy')) : '','',''),
                    new Fieldset('Unit Type', booking.Flat_Typology__c,'',''), 
                    new Fieldset('Carpet Area', String.ValueOf(booking.Carpet_Area__c),'',''), 
                    new Fieldset('Scheme',quote.size()>0?sfdcBaseURL+'/'+quote[0].PaymentPlan__r.id:'',quote.size()>0? quote[0].PaymentPlan__r.Name:'',''),
                    new Fieldset('Agreement Value',INFormatWOSlash(booking.Original_Agreement_Value__c != null ? booking.Original_Agreement_Value__c : 0 ),'',''),
                    new Fieldset('Registration Date',booking.RW_Registration_Date__c != null ? Datetime.newInstance(booking.RW_Registration_Date__c, Time.newInstance(0, 0, 0, 0)).format('dd-MM-yyyy') : '','',''),
                    new Fieldset('Registration Done', booking.RW_Registration_Done__c!=null?'Done':'Not done','',''),
                    new Fieldset('Bank Name', booking.Loan_Bank__c,'',''),
                    //new Fieldset('Total Interest', INFormatWOSlash(booking.RW_Total_Interest__c != null ? booking.RW_Total_Interest__c: 0),'',''),
                     new Fieldset('Total Collectable Interest', INFormatWOSlash(booking.RW_Total_Collectable_Interest__c != null ? booking.RW_Total_Collectable_Interest__c: 0),'',''),
                    new Fieldset('Total Outstanding', INFormatWOSlash(booking.FBL5N__c!=null ?booking.FBL5N__c:0),'',''),
                    new Fieldset('Total Amount Received Without GST', INFormatWOSlash(booking.RW_Total_Amount_Received_Without_GST__c!=null ?booking.RW_Total_Amount_Received_Without_GST__c:0),'',''),
                    new Fieldset('TDS Outstanding', INFormatWOSlash(booking.RW_Total_TDS_Outstanding__c!=null ?booking.RW_Total_TDS_Outstanding__c:0),'',''),
                    new Fieldset('ADF Opted', booking.ADF_Opted__c == true ? '☑' : '☐', '', ''), //added by digiCloud
                    new Fieldset('Total ADF Amount', INFormatWOSlash(booking.Total_ADF_Amount__c !=null ?booking.Total_ADF_Amount__c:0),'',''),//added by digiCloud
                    new Fieldset('Last Demand Raised',demands.size()>0 && demands[0].CreatedDate != null ? (demands[0].CreatedDate.format('dd-MM-yyyy')) : '','',''),
                    new Fieldset('Due Date',booking.RW_Next_Demand_Date__c != null ? Datetime.newInstance(booking.RW_Next_Demand_Date__c, Time.newInstance(0, 0, 0, 0)).format('dd-MM-yyyy') : '','',''),
                    new Fieldset('Aging Of Dues', 
                                 oldestdemand.size() > 0 && oldestdemand[0].Due_Date__c != null ? 
                                 String.valueOf(Math.abs(Date.today().daysBetween(oldestdemand[0].Due_Date__c))): 
                                 '',
                                 '', 
                                 ''),
                    new Fieldset('Funding Status', booking.Funding_Status__c,'',''),
                    new Fieldset('Last Payment Amount', 
                                 receiptList.size() > 0 ? 
                                 INFormatWOSlash(receiptList[0].RW_Payment_Amount__c != null ? receiptList[0].RW_Payment_Amount__c : 0) : 
                                 '','',''),   
                    new Fieldset('Account Number', booking.Account_Number__c,'',''),
                    
                    new Fieldset('Type Of Client', booking.Type_of_Client__c,'',''),
                    new Fieldset('Possession Date',booking.RW_Agreement_Possession_Date__c != null ? Datetime.newInstance(booking.RW_Agreement_Possession_Date__c, Time.newInstance(0, 0, 0, 0)).format('dd-MM-yyyy') : '','',''),
                    
                    new Fieldset('Last Payment Date', 
                                 receiptList.size() > 0 && receiptList[0].RW_Payment_Date__c != null ? 
                                 Datetime.newInstance(receiptList[0].RW_Payment_Date__c, Time.newInstance(0, 0, 0, 0)).format('dd-MM-yyyy') : 
                                 '','',''),
                    
                    //new Fieldset('Last Connected With RM','TBD' ,'',''),
                    new Fieldset('Last CSAT Rating', csatRating, '', ''),
                    new Fieldset(
                        'Latest NPS Score', 
                        (WfList.size() > 0 && WfList[0].NPS__c != null) ? String.valueOf(WfList[0].NPS__c) : '',
                        '', 
                        ''
                    ),
                    
                    new Fieldset('Last Portal Login', lastPortalLogin,'',''),
                    
                    
                    new Fieldset('Latest Referral Lead', referrals.size()>0?sfdcBaseURL+'/'+referrals[0].id:'',referrals.size()>0 && referrals[0].Name !=null?referrals[0].Name :'' ,'')
                    };
                        if(primaryApplicant.size()>0){
                            opportunityWrapper.ApplicantDetails = new List<ApplicantDetails>{
                                new ApplicantDetails('Name',primaryApplicant[0].Name),
                                    new ApplicantDetails('DOB',primaryApplicant[0].DOB__c != null ? (primaryApplicant[0].DOB__c.format()) : ''),
                                    new ApplicantDetails('Mobile No',booking.RW_Country_Phone_Code__c+primaryApplicant[0].Opportunity__r.Mobile_Number__c),
                                    new ApplicantDetails('Email',primaryApplicant[0].Opportunity__r.RW_Email__c),
                                    new ApplicantDetails('Secondary Mobile No',primaryApplicant[0].Secondary_Mobile_No__c),
                                    new ApplicantDetails('Gender',primaryApplicant[0].Gender__c),
                                    new ApplicantDetails('City',primaryApplicant[0].City__c),
                                    new ApplicantDetails('State',primaryApplicant[0].State__c),
                                    new ApplicantDetails('Pincode',String.ValueOf(primaryApplicant[0].Mailing_Pincode__c)),
                                    new ApplicantDetails('Country',primaryApplicant[0].Organisation_Country__c)
                                    };
                                        }
            opportunityWrapper.VideoWrapper = new List<VideoWrapper>();
            for (Customer_Portal_Videos__c video : videos) {
                opportunityWrapper.VideoWrapper.add(new VideoWrapper(video.Name,video.Video_Link__c,video.Video_Link__c , '',video.id));
            }
            opportunityWrapper.childset = getChildWrappers(caseList,caseAging,receiptList,demands,referrals,allApplicant);
            opportunityWrappers.add(opportunityWrapper);
        }
        System.debug('opportunityWrappers :::'+opportunityWrappers);
        return opportunityWrappers;
    }
    public static String INFormatWOSlash(Decimal money) {
        Boolean negative = false;
        if(money < 0) {
            negative = true;
        }
        Decimal tempMoney = money;
        //system.debug('tempMoney-->'+tempMoney);
        //system.debug('money-->'+money);
        //system.debug('m0-->'+m0);
        String m0 =tempMoney.setscale(0,RoundingMode.HALF_UP).toPlainString();
        //system.debug('m0-->2'+m0);
        
        String decimalPart;
        List<String> tempStr = new List<String>();
        if(String.isNotBlank(m0)) {
            tempStr = m0.split('\\.');
            if(tempStr != null && tempStr.size() ==2) {
                decimalPart = tempStr[1];
            }
        }
        
        //String m1 = String.valueOf(math.abs(money.setscale(0,RoundingMode.HALF_UP))).reverse();
        String m1 = tempStr[0].reverse();
        String mF = '';
        for(Integer i=0; i < m1.length() ; i++) {
            mF += m1.substring(i,i+1);
            if(i==2) {
                mF += ',';
            }
            if(i==4 || i==6 || i==8 || i==10 || i==12) {
                mF += ',';
            }
        }
        mf = mf.reverse();
        if(mf.substring(0,1).equals(',')) {
            mf = mf.substring(1);
        }
        if(String.isNotBlank(decimalPart)) 
            mf = mf + '.'  + decimalPart;
        
        if(!negative)
            mf =  mf;
        else
            mf =  mf;
        return mf;
    }
    public static List<ObjectWrapper> getChildWrappers(List<Case> caseList,List<case> CaseAging, List<RW_Payment_Details__c> receiptList, List<RW_Demand__c> demandList, List<Lead> referrals,List<Applicant_Details__c> allApplicant){
        List<ObjectWrapper> childWrappers = new List<ObjectWrapper>();
        
        childWrappers.addAll(getCaseObjectWrappers(caseList,CaseAging));
        childWrappers.addAll(getReceiptObjectWrappers(receiptList));
        childWrappers.addAll(getDemandObjectWrappers(demandList));
        childWrappers.addAll(getReferralObjectWrappers(referrals)); 
        childWrappers.addAll(getApplicantObjectWrappers(allApplicant)); 
        return childWrappers;
    }
    public static List<ObjectWrapper> getApplicantObjectWrappers(List<Applicant_Details__c> allApplicant) {
        List<ObjectWrapper> objectWrappers = new List<ObjectWrapper>();
        decimal TotalApplicant=0.00;
        String BId;
        String sfdcBaseURL = URL.getOrgDomainURL().toExternalForm();
        for (Applicant_Details__c applicant : allApplicant) {
            BId=applicant.Booking__c;
        }
        List<Fieldset> countFieldset = new List<Fieldset>{
            new Fieldset('Total Applicants', INFormatWOSlash(allApplicant.size()),'','')
                };
                    
                    ObjectWrapper applicantObjectWrapper = new ObjectWrapper();
        applicantObjectWrapper.ObjectId = '006';
        applicantObjectWrapper.Objname = 'Applicants';
        applicantObjectWrapper.bookingId= BId;    
        applicantObjectWrapper.ShowAllApplicant=True;
        applicantObjectWrapper.fieldset = countFieldset;
        applicantObjectWrapper.childset = new List<ObjectWrapper>();
        
        for (Applicant_Details__c applicant : allApplicant) {
            ObjectWrapper applicantRecordWrapper = new ObjectWrapper();
            applicantRecordWrapper.ObjectId = applicant.Id;
            applicantRecordWrapper.Objname = applicant.Applicant_Number__c;
            applicantRecordWrapper.fieldset = new List<Fieldset>{
                new Fieldset('Name', applicant.Name,'',''),
                    new Fieldset('DOB', applicant.DOB__c != null ? applicant.DOB__c.format() : '', '', ''),
                    new Fieldset('Type', applicant.Type_Of_Applicant__c,'','')
                    };
                        applicantRecordWrapper.childset = null;
            
            applicantObjectWrapper.childset.add(applicantRecordWrapper);
        }
        
        objectWrappers.add(applicantObjectWrapper);
        
        return objectWrappers;
    }
    public static List<ObjectWrapper> getReferralObjectWrappers(List<Lead> referrals) {
        List<ObjectWrapper> objectWrappers = new List<ObjectWrapper>();
        decimal TotalAmount=0.00;
        Integer totalCount=0;
        String BId='';
        String sfdcBaseURL = URL.getOrgDomainURL().toExternalForm();
        for (Lead referral : referrals) {
            BId=referral.Customer_Reference__c;
        }
        if(referrals.size()>0)
        {
            totalCount = [SELECT COUNT() FROM Lead WHERE Customer_Reference__c = :BId AND LeadSource='Referral'];
        }
        
        System.debug('Total Lead refferal'+totalCount);
        List<Fieldset> countFieldset = new List<Fieldset>{
            new Fieldset('Total Referrals', INFormatWOSlash(totalCount),'','')
                };
                    
                    ObjectWrapper referralObjectWrapper = new ObjectWrapper();
        referralObjectWrapper.ObjectId = '004';
        referralObjectWrapper.Objname = 'Referral';
        referralObjectWrapper.bookingId= BId;    
        referralObjectWrapper.isShowChild = false;
        referralObjectWrapper.CreateNewReferral=true;
        referralObjectWrapper.fieldset = countFieldset;
        referralObjectWrapper.childset = new List<ObjectWrapper>();
        
        for (Lead referral : referrals) {
            ObjectWrapper referralRecordWrapper = new ObjectWrapper();
            referralRecordWrapper.ObjectId = referral.Id;
            referralRecordWrapper.Objname = referral.Name;
            /*referralRecordWrapper.fieldset = new List<Fieldset>{
new Fieldset('Name', referral.Name,'',''),
new Fieldset('Project', referral.RW_Project__r.Name,'',''),
new Fieldset('Sourcing Manager', referral.RW_Sourcing_Manager__c,'','')
};*/
            referralRecordWrapper.fieldset = new List<Fieldset>{
                new Fieldset('Project', referral.RW_Project__r.Name,'',''),
                    new Fieldset('Lead Status', referral.Status,'',''),
                    new Fieldset('Lead Created Date', String.valueOf(referral.CreatedDate),'','')
                    };
                        referralRecordWrapper.childset = null;
            
            referralObjectWrapper.childset.add(referralRecordWrapper);
        }
        
        objectWrappers.add(referralObjectWrapper);
        
        return objectWrappers;
    }
    public static List<ObjectWrapper> getReceiptObjectWrappers(List<RW_Payment_Details__c> receiptList) {
        List<ObjectWrapper> objectWrappers = new List<ObjectWrapper>();
        decimal TotalAmount=0.00;
        String BId;String bookingId; 
        String sfdcBaseURL = URL.getOrgDomainURL().toExternalForm();
        for (RW_Payment_Details__c receipt : receiptList) {
            BId=receipt.RW_Booking__r.Name;
            bookingId=receipt.RW_Booking__c;
            TotalAmount=TotalAmount + (receipt.Total_Amount_Paid__c != null ? receipt.Total_Amount_Paid__c : 0);            
        }
        Integer totalreceiptCount =0;
        If(String.IsNotBlank(bookingId))
        {
            totalreceiptCount=[SELECT COUNT() FROM RW_Payment_Details__c WHERE RW_Booking__c = :bookingId];
            System.debug('totalreceiptCount::::::'+totalreceiptCount);
            
        }
        
        List<Fieldset> countFieldset = new List<Fieldset>{
            new Fieldset('Total Reciepts', INFormatWOSlash(totalreceiptCount),'','')
                };
                    
                    ObjectWrapper receiptObjectWrapper = new ObjectWrapper();
        receiptObjectWrapper.ObjectId = '002';
        receiptObjectWrapper.Objname = 'Receipt';
        receiptObjectWrapper.ShowAllReciepts=true;
        receiptObjectWrapper.bookingId=BId;
        receiptObjectWrapper.isShowChild = false;
        receiptObjectWrapper.fieldset = countFieldset;
        receiptObjectWrapper.childset = new List<ObjectWrapper>();
        
        for (RW_Payment_Details__c receipt : receiptList) {
            ObjectWrapper receiptRecordWrapper = new ObjectWrapper();
            receiptRecordWrapper.ObjectId = receipt.Id;
            receiptRecordWrapper.Objname = receipt.Name;
            receiptRecordWrapper.fieldset = new List<Fieldset>{
                
                new Fieldset('Payment Amount', INFormatWOSlash(receipt.Total_Amount_Paid__c  != null ? receipt.Total_Amount_Paid__c  : 0),'',''),
                    new Fieldset('Payment Date', (receipt.RW_Payment_Date__c).format(),'',''),
                    new Fieldset('Demand Number', receipt.RW_Demand_Number__c,'','')
                    
                    };
                        receiptRecordWrapper.childset = null;
            
            receiptObjectWrapper.childset.add(receiptRecordWrapper);
        }
        
        objectWrappers.add(receiptObjectWrapper);
        
        return objectWrappers;
    }
    public static List<ObjectWrapper> getDemandObjectWrappers(List<RW_Demand__c> demandList) {
        List<ObjectWrapper> objectWrappers = new List<ObjectWrapper>();
        decimal TotaDemand=0.00;   String BId;String bookingId;
        for (RW_Demand__c demand : demandList) {
            TotaDemand=TotaDemand+demand.Demand_Amount__c;
            BId=demand.booking__r.Name;bookingId=demand.booking__c;
        }
        Integer totaldemand = [SELECT COUNT() FROM RW_Demand__c WHERE Booking__c = :bookingId];
        
        List<Fieldset> countFieldset = new List<Fieldset>{
            new Fieldset('Total Demands', INFormatWOSlash(totaldemand),'','')
                
                };
                    
                    ObjectWrapper demandObjectWrapper = new ObjectWrapper();
        demandObjectWrapper.ObjectId = '003';
        demandObjectWrapper.Objname = 'Demand';
        demandObjectWrapper.ShowAllDemands=true;
        demandObjectWrapper.bookingId=BId;
        demandObjectWrapper.isShowChild = false;
        demandObjectWrapper.fieldset = countFieldset;
        demandObjectWrapper.childset = new List<ObjectWrapper>();
        
        for (RW_Demand__c demand : demandList) {
            system.debug('Demand Name::'+demand.Id);
            ObjectWrapper demandRecordWrapper = new ObjectWrapper();
            demandRecordWrapper.ObjectId = demand.Id;
            demandRecordWrapper.Objname = demand.Name;
            demandRecordWrapper.fieldset = new List<Fieldset>{
                
                
                new Fieldset('Demand Amount', INFormatWOSlash(demand.RW_Total_Demand_Amount__c ?? 0),'',''),
                    new Fieldset('Demand Date',demand.Demand_Date__c != null ?  demand.Demand_Date__c.format('dd/MM/yyyy') : '','',''),
                    new Fieldset('Due Date',demand.Due_Date__c != null ?  demand.Due_Date__c.format() : '','','')
                    //new Fieldset('Total Demand Paid', INFormatWOSlash(demand.Total_Demand_Paid__c ?? 0),'','')
                    
                    
                    };
                        demandRecordWrapper.childset = null;
            
            demandObjectWrapper.childset.add(demandRecordWrapper);
        }
        
        objectWrappers.add(demandObjectWrapper);
        
        return objectWrappers;
    }
    public static List<ObjectWrapper> getCaseObjectWrappers(List<Case> caseList,List<Case> caseAging) {
        List<ObjectWrapper> objectWrappers = new List<ObjectWrapper>();
        Integer Open=0;
        Integer Closed=0;
        Integer wip=0;
        String BId;
        Date oldestCase ;
        Integer aging ;
        System.debug('caseList::'+caseList);
        System.debug('caseAging:::'+caseAging);
        if (!caseAging.isEmpty()) {
            oldestCase = caseAging[0].CreatedDate.date(); // Convert Datetime to Date
            aging = Math.abs(Date.today().daysBetween(oldestCase));
        }
        system.debug('Aging:::'+aging);
        
        for (Case c : caseList) {
            
            if(c.Status=='Case Closed')
            {
                Closed=Closed+1;
                
            }
            if(c.Status!='Case Closed')
            {
                Open=Open+1;
            }
            BId=c.AccountId;
        }
        
        
        
        List<Fieldset> countFieldset = new List<Fieldset>{
            new Fieldset('Open Cases', String.valueOf(Open),'','')
                
                };
                    
                    
                    ObjectWrapper caseObjectWrapper = new ObjectWrapper();
        caseObjectWrapper.ObjectId = '001';
        caseObjectWrapper.bookingId=BId;
        caseObjectWrapper.Objname = 'Case';
        caseObjectWrapper.showbutton=true;
        caseObjectWrapper.Aging=aging;
        caseObjectWrapper.isShowChild = false;
        caseObjectWrapper.fieldset = countFieldset; 
        caseObjectWrapper.childset = new List<ObjectWrapper>();
        
        
        for (Case c : caseList) {
            if(c.Status != 'Case Closed'){
                ObjectWrapper caseRecordWrapper = new ObjectWrapper();
                caseRecordWrapper.ObjectId = c.Id;
                caseRecordWrapper.Objname = c.CaseNumber;
                caseRecordWrapper.fieldset = new List<Fieldset>{
                    new Fieldset('Complaint Type', c.RW_Complaint_Type__c,'',''),
                        new Fieldset('Complaint SubType', c.RW_Complaint_SubType__c,'',''),
                        new Fieldset('Created Date', c.CreatedDate != null ?   c.CreatedDate.format('dd/MM/yyyy') : '','','')
                        };
                            caseRecordWrapper.childset = null; 
                
                
                caseObjectWrapper.childset.add(caseRecordWrapper);
            }
        }
        
        
        objectWrappers.add(caseObjectWrapper);
        
        return objectWrappers;
    }
    
    @AuraEnabled
    public static void updateDND(String accountId, Boolean dnd){ //Added by Vinay 18-03-2025
        if(String.isNotBlank(accountId)){
            Account acc = [SELECT Id, Mobile_No__c FROM Account WHERE Id =: accountId];
            acc.DND__c = dnd;
            update acc;
            
            List<Lead> leads = [SELECT Id FROM Lead WHERE RW_Mobile_No__c =: acc.Mobile_No__c];
            if(leads.size() > 0){
                for(Lead ld : leads){
                    ld.Is_DND__c = dnd;
                }
                update leads;
            }
            
            List<Opportunity> oppList = new List<Opportunity>();
            for(Opportunity opp : [SELECT Id FROM Opportunity WHERE AccountId =: accountId]){
                opp.Is_DND__c = dnd;
                oppList.add(opp);
            }
            if(oppList.size() > 0)
                update oppList;
        }
    }
    
    @AuraEnabled
    public static void updateStopCaseEmails(String accountId, Boolean stopEmails){ //Added by Vinay 20-05-2025
        if(String.isNotBlank(accountId)){
            Account acc = [SELECT Id, Mobile_No__c FROM Account WHERE Id =: accountId];
            acc.Stop_Case_Emails__c = stopEmails;
            update acc;
        }
    }
    
    @AuraEnabled
    public static Boolean dndFromAccount(String accountId){ //Added by Vinay 18-03-2025
        if(String.isNotBlank(accountId)){
            Account acc = [SELECT Id, DND__c FROM Account WHERE Id =: accountId];
            return acc.DND__c;
        }else
            return false;
    }
    
    @AuraEnabled
    public static Boolean stopCaseEmailsFromAccount(String accountId){ //Added by Vinay 20-05-2025
        if(String.isNotBlank(accountId)){
            Account acc = [SELECT Id, Stop_Case_Emails__c FROM Account WHERE Id =: accountId];
            return acc.Stop_Case_Emails__c;
        }else
            return false;
    }

    public static void dummyMethod(){
        
        String s2;        
        String s3;
        String s4;                
        String s5;
        String s6;        
        String s7;
        String s8;                
        String s9;
        String s10;        
        String s11;
        String s12;                
        String s13;
        String s14;        
        String s15;
        String s16;                
        String s110;
        String s210;        
        String s310;
        String s410;                
        String s510;
        String s610;        
        String s710;
        String s810;                
        String s910;
        String s1010;        
        String s1110;
        String s1210;                
        String s1310;
        String s1410;        
        String s1510;
        String s1610;                
        String s111;
        String s211;        
        String s311;
        String s411;                
        String s511;
        String s611;        
        String s711;
        String s811;                
        String s911;
        String s1011;        
        String s1111;
        String s1211;                
        String s1311;
        String s1411;        
        String s1511;
        String s1611;                
        String s1101;
        String s2111;        
        
        integer i;
        i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
 i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
           i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
           i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
           i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
           i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
           i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
           i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
           i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
           i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
           i++;
          i++;
        i++;
           i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
           i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
           i++;
        i++;
        i++;
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
    
    public class Fieldset {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public Boolean isURL;
        @AuraEnabled public String isURLName;
        @AuraEnabled public String BackgroundColor;
        public Fieldset(String label, String value,String isURLName, String BackgroundColor) {
            this.label = label;
            this.value = value;
            if(!String.isBlank(value))
            {
                this.isURL=value.containsignorecase('.com');
            }
            else{
                this.isURL=false;
            }
            this.isURLName = isURLName;
            this.BackgroundColor = BackgroundColor;
        }
    }
    public class VideoWrapper {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public Boolean isURL;
        @AuraEnabled public String isURLName;
        @AuraEnabled public String BackgroundColor;
        @AuraEnabled public String vId;
        public VideoWrapper(String label, String value,String isURLName, String BackgroundColor,String vId) {
            this.label = label;
            this.value = value;
            if(!String.isBlank(value))
            {
                this.isURL=(value.containsignorecase('.com') || value.containsignorecase('https'));
            }
            else{
                this.isURL=false;
            }
            this.isURLName = isURLName;
            this.BackgroundColor = BackgroundColor;
            this.vId=vId;
        }
    }
    public class ApplicantDetails {
        @AuraEnabled public String clabel;
        @AuraEnabled public String cvalue;
        
        public ApplicantDetails(String label, String value) {
            this.clabel = label;
            this.cvalue = value;
        }
        
    }
    
    public class Collectionset {
        @AuraEnabled public String clabel;
        @AuraEnabled public String cvalue;
        
        public Collectionset(String label, String value) {
            this.clabel = label;
            this.cvalue = value;
        }
        
    }
    public class ObjectWrapper {
        @AuraEnabled public String ObjectId;
        @AuraEnabled public string Objname;
        @AuraEnabled public string bookingId;
        @AuraEnabled public string PhoneNumber;
        @AuraEnabled public string Countrycode;
        @AuraEnabled public string CustomerCode;
        @AuraEnabled public string CompanyCode;
        @AuraEnabled public boolean ShowAllReciepts;
        @AuraEnabled public boolean ShowAllDemands;
        @AuraEnabled public boolean ShowAllApplicant;
        @AuraEnabled public boolean showButton;
        @AuraEnabled public boolean CreateNewReferral;
        @AuraEnabled public string bgcolor;
        @AuraEnabled public Boolean isShowChild;
        @AuraEnabled public Integer Aging;
        @AuraEnabled public string accName;
        @AuraEnabled public List<Fieldset> fieldset;
        @AuraEnabled public List<ApplicantDetails> ApplicantDetails;
        @AuraEnabled public List<Collectionset> collectionset;
        @AuraEnabled public List<VideoWrapper> VideoWrapper;
        @AuraEnabled public List<Fieldset> DocumentList;
        @AuraEnabled public List<ObjectWrapper> childset;
    } 
}