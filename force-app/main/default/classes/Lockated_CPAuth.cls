@RestResource(urlMapping='/cpAuth/*')
global without sharing class Lockated_CPAuth {
    
    @HttpGet
    global static void doGet(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        String cpId = req.params.get('id'); 
        String email = req.params.get('email');  
        String phone = req.params.get('phone'); 
        list<Broker__c> brlist = new list<Broker__c>();
        Map<String, Object> result = new Map<String, Object>();
        Id CPRecordTypeId = Schema.SObjectType.Broker__c.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
        Id TempCPRecordTypeId = Schema.SObjectType.Broker__c.getRecordTypeInfosByName().get('Temp Channel Partner').getRecordTypeId();
        try{
            String baseQuery = 'SELECT Id,Country__c,State__c,STREET__c,Bank_Branch__c,STR_SUPPL2__c,Account__r.Channel_Partner_Activated__c ,Sourcing_Manager__r.Name,Sourcing_Manager__r.Email,Sourcing_Manager__r.MobilePhone,STR_SUPPL3__c,Cheque_DD_Favouring_Name__c,Branch_Code__c,IFSC_Code__c,Account_Number__c,Bank_Name__c,Broker_Type__c,NAME_MIDDLE__c,Dialing_Country_Code1__c,Company_Name_As_per_RERA__c,RERA_Valid_till__c,Are_you_NRI__c,RW_GST_Number__c,Experience__c,Team_Size__c,House_Flat_Company__c, Name,OwnerId, RecordTypeId, CreatedById, LastModifiedById, Representative_Name__c, RW_Email__c, RW_Mobile_No__c, RW_Broker_Number__c, Address__c, Broker_Pan_No__c, City__c, Pin_Code__c, RW_RERA_Registration_Number__c, RW_Is_GST_Applicable__c, RW_Is_RERA_Applicable__c, Is_NRI_CP__c, SAP_CP_Code__c, Locality__c, Zone__c, Individual_CP__c, NAME_FIRST__c, NAME_LAST__c, RW_CreateFromIRIS__c, RW_IRIS_Sync__c, Unregistered_Channel_Partner__c, Place_of_Supply__c, Account__c, Approver_L1__c, Approver_L2__c, Channel_Partner_From_CP_Portal__c, Country_2__c, Is_T_C_Accepted__c, Project__c, Registration_Complete__c, State_Code__c, State_2__c, Activate_CP_Portal__c, Data_Error_Fixed__c, Deactivated__c, days_from_creation__c, Latest_RERA_Upload_Processed__c, Latest_CC_Upload_Processed__c, Valid_RERA_certificate__c, Valid_competency_certificate__c FROM Broker__c';
            
            List<String> whereClauses = new List<String>();
            if (String.isNotBlank(cpId)) {
                whereClauses.add('Id = :cpId');
            }else{
                if (String.isNotBlank(email) && String.isNotBlank(phone)) {
                    whereClauses.add('(RW_Email__c = :email OR RW_Mobile_No__c = :phone)');
                } else if (String.isNotBlank(email)) {
                    whereClauses.add('RW_Email__c = :email');
                } else if (String.isNotBlank(phone)) {
                    whereClauses.add('RW_Mobile_No__c = :phone');
                }
            }
            
            
            String query = baseQuery;
            if (!whereClauses.isEmpty()) {
                query += ' WHERE ' + String.join(whereClauses, ' AND ');
            } else {
                result.put('status', 'error');
                result.put('message', 'Please provide email or phone.');
                res.responseBody = Blob.valueOf(JSON.serialize(result));
                res.statusCode = 400;
                return;
            }
            
            System.debug('Final Query => ' + query);
            
            brlist = Database.query(query);
            system.debug('brlist -> '+brlist);
            if (!brlist.isEmpty()) {
                CPDetailsWrapper cp = new CPDetailsWrapper();
                cp.basicDetails = new GetBasicDetails();
                cp.address = new Address();
                cp.bankDetails = new BankDetails();
                cp.documents = new list<Attachment>();
                cp.sourcingManagerDetails = new SourcingManagerDet();
                cp.id = brlist[0].Id;
                cp.basicDetails.channelPartnerType = brlist[0].Broker_Type__c;
                cp.basicDetails.project = brlist[0].Project__c;
                List<String> nameParts = new List<String>();
                // Check each part; if it exists, add it to the list
                if (String.isNotBlank(brlist[0].NAME_FIRST__c)) {
                    nameParts.add(brlist[0].NAME_FIRST__c);
                }
                if (String.isNotBlank(brlist[0].NAME_MIDDLE__c)) {
                    nameParts.add(brlist[0].NAME_MIDDLE__c);
                }
                if (String.isNotBlank(brlist[0].NAME_LAST__c)) {
                    nameParts.add(brlist[0].NAME_LAST__c);
                }
                cp.basicDetails.fullName = String.join(nameParts, ' ');
                cp.basicDetails.emailAddress = brlist[0].RW_Email__c;
                cp.basicDetails.mobileNo = brlist[0].RW_Mobile_No__c;
                cp.basicDetails.panNo = brlist[0].Broker_Pan_No__c;
                cp.basicDetails.countryCode = brlist[0].Dialing_Country_Code1__c;
                cp.basicDetails.companyName = brlist[0].Company_Name_As_per_RERA__c;
                cp.basicDetails.reraNo = brlist[0].RW_RERA_Registration_Number__c;
                // cp.basicDetails.reraValidTill = String.valueOf(brlist[0].RERA_Valid_till__c);
                if(brlist[0].RERA_Valid_till__c != null) {
                    Date d = Date.valueOf(brlist[0].RERA_Valid_till__c);
                    DateTime dt = DateTime.newInstance(d.year(), d.month(), d.day());
                    cp.basicDetails.reraValidTill = dt.format('dd-MM-yyyy');
                } else {
                    cp.basicDetails.reraValidTill = null;
                }
                //cp.basicDetails.hasCompetencyCert = brlist[0].RW_Is_CC_Applicable__c == true ? 'Yes' : 'No';//Commented by Prashant as discussed with team to discard use of CC. 12/12/25.
                //cp.basicDetails.ccValidTill = String.valueOf(brlist[0].CC_Valid_till__c);
                //cp.basicDetails.ccScheduledExamDate = String.valueOf(brlist[0].CC_Scheduled_Exam_Date__c);
                cp.basicDetails.nri = brlist[0].Are_you_NRI__c;
                cp.basicDetails.gstApplicable = brlist[0].RW_Is_GST_Applicable__c == true ? 'Yes' : 'No';
                cp.basicDetails.gstNo = brlist[0].RW_GST_Number__c;
                cp.basicDetails.experience = brlist[0].Experience__c;
                cp.basicDetails.placeOfOperation = brlist[0].Place_of_Supply__c;
                //cp.basicDetails.averageQuarterlyBusiness = 'Comming soon....';
                cp.basicDetails.teamSize = brlist[0].Team_Size__c;
                
                if(brlist[0].RecordTypeId == CPRecordTypeId){
                    cp.basicDetails.cpType = 'Permanent';
                }
                if(brlist[0].RecordTypeId == TempCPRecordTypeId){
                    cp.basicDetails.cpType = 'Temporary';
                    getTemporaryAccess(cp,brlist[0]);
                }
                
                if(cp.basicDetails.cpType == 'Permanent' ){
                    if(brlist[0].Account__r.Channel_Partner_Activated__c){
                        cp.basicDetails.cpStatus = 'Registered';
                    }else{
                        cp.basicDetails.cpStatus = 'UnRegistered';
                    }
                }
                
                //Calculating AVG Quarterly Business..... 15-01-26.
                list<Booking__c> blist = [select Id,Name,Opportunity__c,BrokerIId__c,Agreement_Value_for_brokers__c,Project__c,Tower__c,Status__c,Additional_Brokerage_Accrued_Dashboards__c,
                                          Base_Brokerage_Accrued_Dashboards__c,Project_Name__c,Unit_No__r.Name,Brokerage_Scheme__r.End_Date__c,Booking_Date__c,Payment_Received__c,Registration_date_status__c,
                                          RW_X9_99_Received__c,RW_Registration_Done__c,Brokerage_Scheme__c from Booking__c where Project__c != null and Status__c = 'Booking Confirmed'
                                          and BrokerIId__c =: brlist[0].Id and Opportunity__c != null
                                          AND BrokerIId__r.Valid_RERA_certificate__c = true 	
                                          ORDER BY Booking_Date__c DESC];
                
                //Last FY + Current FY..
                Date todayDate = Date.today();
                Integer currentMonth = todayDate.month();
                Integer lastFYMonths = 12;      
                Integer currentFYMonths;
                if (currentMonth >= 4) {
                    currentFYMonths = currentMonth - 3;
                } else {
                    currentFYMonths = currentMonth + 9;
                }
                Integer totalMonthCount = lastFYMonths + currentFYMonths;  
                Integer currentYr = todayDate.year();
                Integer previousYr = currentYr - 1;
                System.debug('Current Year: ' + currentYr);
                Date previousFYDate = Date.newInstance(previousYr, 04, 01);
                Date currentFYDate = Date.newInstance(currentYr, 03, 31); 
                System.debug('Current Month: ' + currentMonth);
                System.debug('Current FY Months: ' + currentFYMonths);
                System.debug('Total Month Count (Last FY + Current FY): ' + totalMonthCount);
                Decimal AVtillNow = 0;
                if(!blist.isEmpty()){
                    for(Booking__c b : blist){
                        AVtillNow += b.Agreement_Value_for_brokers__c;
                        /*if(b.Booking_Date__c != null &&  b.Booking_Date__c >= previousFYDate && b.Booking_Date__c <= currentFYDate ){
                           	Agreement_Value_for_brokers__c
                        }*/
                    }
                }
                AVtillNow = AVtillNow.setScale(2, RoundingMode.HALF_UP);
                Decimal AvgMonthlyBusiness = (AVtillNow/totalMonthCount).setScale(2, RoundingMode.HALF_UP);
                Decimal AvgQuarterlyBusiness = AvgMonthlyBusiness * 3;
                cp.basicDetails.averageQuarterlyBusiness = String.ValueOf(AvgQuarterlyBusiness);
                //Calculating AVG Quarterly Business..... 15-01-26. END
                
                // --- NEW AOP LOGIC START Added By Aditya ---
                Date today = Date.today();
                List<AOP__c> activeAOPs = [SELECT Id FROM AOP__c 
                                           WHERE Channel_Partner__c = :brlist[0].Id 
                                           AND Start_Date__c <= :today 
                                           AND End_Date__c >= :today 
                                           LIMIT 1];
                
                cp.basicDetails.isAop = !activeAOPs.isEmpty();
                
                //Get Lead And opportunity(Added by Aditya)
                Map<Id, Lead> leadMap = new Map<Id, Lead>([
                    SELECT Id FROM Lead 
                    WHERE RW_Broker__c = :cp.id AND LeadSource = 'Channel Partner'
                ]);
                
                Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([
                    SELECT Id FROM Opportunity 
                    WHERE RW_Broker__c = :cp.id OR RW_Walkin_Channel_Partner__c = :cp.id
                ]);
                
                Set<Id> leadIds = leadMap.keySet();
				Set<Id> oppIds = oppMap.keySet();
                // Ended by Aditya
                
                //CP Calender Details
                cp.calenderDetails = new Map<String, List<CalenderDetails>>();                
                List<Task> taskList = [SELECT Id, Subject, ActivityDate FROM Task WHERE 
                                       (WhoId =: cp.id OR WhatId =: cp.id) OR
                                       (WhoId IN :leadIds AND Task_Type__c = 'Site Visit') OR
                                       (WhatId IN :oppIds AND Task_Type__c = 'Site Visit') ORDER BY ActivityDate ];  
                for (Task t : taskList) {
                    if (t.ActivityDate != null) {                        
                        if (!cp.calenderDetails.containsKey(String.valueOf(t.ActivityDate))) {
                            cp.calenderDetails.put(String.valueOf(t.ActivityDate), new List<CalenderDetails>());
                        }
                        CalenderDetails cd = new CalenderDetails();
                        cd.eventId = t.Id;
                        cd.subject = t.Subject;
                        // cd.activityDate = String.valueOf(t.ActivityDate);   
                        if(t.ActivityDate != null) {
                            Date d = Date.valueOf(t.ActivityDate);
                            DateTime dt = DateTime.newInstance(d.year(), d.month(), d.day());
                            cd.activityDate = dt.format('dd-MM-yyyy');
                        } else {
                            cd.activityDate = null;
                        }                     
                        cp.calenderDetails.get(String.valueOf(t.ActivityDate)).add(cd);
                    }
                }
                
               /* List<Event> eventList = [SELECT Id,Subject,ActivityDate FROM Event where Channel_Partner__c = : cp.Id ORDER BY ActivityDate  ];                
                for (Event e : eventList) {
                    if (e.ActivityDate != null) {                        
                        if (!cp.calenderDetails.containsKey(String.valueOf(e.ActivityDate))) {
                            cp.calenderDetails.put(String.valueOf(e.ActivityDate), new List<CalenderDetails>());
                        }
                        CalenderDetails cd = new CalenderDetails();
                        cd.eventId = e.Id;
                        cd.subject = e.Subject;
                        cd.activityDate = String.valueOf(e.ActivityDate);                        
                        cp.calenderDetails.get(String.valueOf(e.ActivityDate)).add(cd);
                    }
                }*///Commented as discussed with Shraddha.3-12-25.
                
                Id CP_MEET_RECORDTYPE_ID =Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('CP_Meets').getRecordTypeId();
                
                List<CampaignMember> brokerMembers = [SELECT Id,CampaignId, RSVP__c FROM CampaignMember WHERE Contact.Account.Channel_Partner__c = :cp.Id AND Campaign.RecordTypeId = :CP_MEET_RECORDTYPE_ID AND Campaign.Type__c = 'CP Meets'];
                
                Map<Id, CampaignMember> campaignIdVsMemberMap = new Map<Id, CampaignMember>();
                Set<Id> campaignIds = new Set<Id>();
                for (CampaignMember cm : brokerMembers) {
                    campaignIdVsMemberMap.put(cm.CampaignId, cm);
                    campaignIds.add(cm.CampaignId);
                }
                
                List<Campaign> brokerCampaigns = [SELECT Id, Name, Event_Date_Time__c, Event_Location__c, Description, Status FROM Campaign WHERE Id IN :campaignIds ORDER BY Event_Date_Time__c DESC];
                
                for (Campaign camp : brokerCampaigns) {
                    
                    if (camp.Event_Date_Time__c != null) {  
                        CalenderDetails cd = new CalenderDetails();
                        Date d = Date.valueOf(camp.Event_Date_Time__c);
                        DateTime dt = DateTime.newInstance(d.year(), d.month(), d.day());
                        cd.activityDate = dt.format('dd-MM-yyyy');
                        if (!cp.calenderDetails.containsKey(String.valueOf(camp.Event_Date_Time__c.date()))) {
                            cp.calenderDetails.put(String.valueOf(camp.Event_Date_Time__c.date()), new List<CalenderDetails>());
                        }
                        cd.eventId = camp.Id;
                        cd.subject = camp.Name;
                        // cd.activityDate = String.valueOf(camp.Event_Date_Time__c);     //Event_Date_Time__c           
                        cp.calenderDetails.get(String.valueOf(camp.Event_Date_Time__c.date())).add(cd);
                    }
                }
                
                
                
                
                cp.address.houseFlatCompany = brlist[0].House_Flat_Company__c;
                cp.address.country = brlist[0].Country__c;    
                cp.address.streetAddress1 = brlist[0].STREET__c;
                cp.address.streetAddress2 = brlist[0].STR_SUPPL2__c;
                cp.address.streetAddress3 = brlist[0].STR_SUPPL3__c;
                cp.address.stateRegion = brlist[0].State__c;
                cp.address.city = brlist[0].City__c;
                cp.address.zipPinCode = brlist[0].Pin_Code__c;
                
                cp.bankDetails.chequeDdFavouringName = brlist[0].Cheque_DD_Favouring_Name__c;
                cp.bankDetails.branchCode = brlist[0].Branch_Code__c;
                cp.bankDetails.bankAccountIfscCode = brlist[0].IFSC_Code__c;
                cp.bankDetails.bankAccountNumber = brlist[0].Account_Number__c;
                cp.bankDetails.bankName = brlist[0].Bank_Name__c;
                cp.bankDetails.branchName = brlist[0].Bank_Branch__c;
                
                if(brlist[0].Sourcing_Manager__c != null){
                    cp.sourcingManagerDetails.fullName = brlist[0].Sourcing_Manager__r.Name;
                    cp.sourcingManagerDetails.emailAddress = brlist[0].Sourcing_Manager__r.Email;
                    cp.sourcingManagerDetails.mobileNumber = brlist[0].Sourcing_Manager__r.MobilePhone;
                }
                                    
                cp.documents = getCPAttachments(cp.id);
                //cp.opportunityDetails
                cp.opportunityDetails = getOpportunitiesForBroker(brlist[0].Id);
                
                 list<Lead> leadlist = [SELECT Id,IsConverted FROM lead where RW_Broker__c =: brlist[0].Id or Walkin_Channel_Partner__c =: brlist[0].Id order by createddate desc];
                 list<Lead> recents = [SELECT Id,IsConverted,Name,Project_Name__c FROM lead where isConverted = true and (RW_Broker__c =: brlist[0].Id or Walkin_Channel_Partner__c =: brlist[0].Id) order by createddate desc limit 5];
                cp.cpPerformanceDetails = new cpPerformance();
                cp.cpPerformanceDetails.leadsGenerated = 0;
                cp.cpPerformanceDetails.leadsConverted = 0;
                cp.cpPerformanceDetails.ConversionRate = 0;
                cp.cpPerformanceDetails.recentConversions = new list<RecentConversions>(); 
                if(!leadlist.isEmpty()){
                    for(Lead l : leadlist){
                        cp.cpPerformanceDetails.leadsGenerated +=1;
                        if(l.IsConverted){
                            cp.cpPerformanceDetails.leadsConverted +=1;
                        }
                    }
                    system.debug('cp.cpPerformanceDetails.leadsGenerated -> '+cp.cpPerformanceDetails.leadsGenerated);
                    system.debug('cp.cpPerformanceDetails.leadsConverted -> '+cp.cpPerformanceDetails.leadsConverted);
                    system.debug('cp.cpPerformanceDetails.ConversionRate -> '+ (Decimal.valueof(cp.cpPerformanceDetails.leadsConverted) / Decimal.valueof(cp.cpPerformanceDetails.leadsGenerated)));
                    cp.cpPerformanceDetails.ConversionRate = (Decimal.valueof(cp.cpPerformanceDetails.leadsConverted) / Decimal.valueof(cp.cpPerformanceDetails.leadsGenerated)).setscale(2,RoundingMode.HALF_UP) * 100;
                
                }
                if(!recents.isEmpty()){
                    for(Lead l : recents){
                        RecentConversions r = new RecentConversions();
                        r.customerName = l.Name;
                        r.project = l.Project_Name__c;
                        cp.cpPerformanceDetails.recentConversions.add(r);
                    }
                }
                
                res.responseBody = Blob.valueOf(JSON.serialize(cp));
                System.debug('Check Response Body-->'+JSON.serialize(cp));
                res.statusCode = 200;
            } else {
                result.put('status', 'error');
                result.put('message', 'No Broker found for given details.');
                res.responseBody = Blob.valueOf(JSON.serialize(result));
                res.statusCode = 404;
            }
            
        } catch (Exception e) {
            result.put('status', 'error');
            result.put('message', e.getMessage() + ';  ' + e.getStackTraceString());
            res.responseBody = Blob.valueOf(JSON.serialize(result));
            res.statusCode = 500;
        }
        
        //Map<String, Attachment> attMap = getCPAttachments(cpId);
        //return JSON.serialize(attMap);
        
    }
    
    @HttpPost
    global static void doPost(){                
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        system.debug(req.requestBody);
        String cptype = req.params.get('cptype');
        system.debug('cptype -> '+cptype);
        String jsonBody = req.requestBody.toString();
        
        Map<String, Object> response = new Map<String, Object>();
        if(cptype == 'CP'){
            response = handleCP(jsonBody);
            res.responseBody = Blob.valueOf(JSON.serialize(response));
            res.statusCode = 200;
        } else if(cptype == 'TempCP'){
            response = handleTempCP(jsonBody);
            res.responseBody = Blob.valueOf(JSON.serialize(response));
            res.statusCode = 200;
        }
        else {
            Map<String, Object> errorResult = new Map<String, Object>();
            errorResult.put('status', 'error');
            errorResult.put('message', 'Please enter a valid CP type');
            res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
            res.statusCode = 400;
        }
        
    }
    
    public static Map<String,Object> handleCP(String jsonBody){
        
        cpRegistrationWrapper data = (cpRegistrationWrapper) JSON.deserialize(jsonBody,cpRegistrationWrapper.class);
        
        Map<String, Object> response = new Map<String, Object>();
        
        // Check if CP already exists with same email or PAN
        /*List<Broker__c> existing = [SELECT Id, Name, RW_Email__c, Broker_Pan_No__c,RW_Mobile_No__c FROM Broker__c WHERE 
                                    RW_Email__c = :data.email OR Broker_Pan_No__c = :data.panNo OR RW_Mobile_No__c =: data.phone LIMIT 1];*/
        
        String query = 'SELECT Id, Name, RW_Email__c, Broker_Pan_No__c, RW_Mobile_No__c FROM Broker__c WHERE ' +
                       '(RW_Email__c = \'' + String.escapeSingleQuotes(data.email) + '\' ' +
                       'OR Broker_Pan_No__c = \'' + String.escapeSingleQuotes(data.panNo) + '\' ' +
                       'OR RW_Mobile_No__c = \'' + String.escapeSingleQuotes(data.phone) + '\')';

        // If we have a recordId, exclude it from the duplicate search
        if (String.isNotBlank(data.recordId)) {
            query += ' AND Id != \'' + String.escapeSingleQuotes(data.recordId) + '\'';
        }
        
        query += ' LIMIT 1';

        List<Broker__c> existing = Database.query(query);
        
        if (!existing.isEmpty()) {
            response.put('status', 'error');
            response.put('message', 'Partner already exists with this email, PAN or Mobile');
            return response;
        }
        
        //If passed validations, insert Broker__c record 
        Broker__c cp = new Broker__c();        
        if(String.isNotBlank(data.recordId)){
            cp.Id = data.recordId;
        }
        cp.RW_Email__c = data.email;
        cp.RW_Mobile_No__c = data.phone;	
        cp.Broker_Pan_No__c = data.panNo;
        cp.Company_Name_As_per_RERA__c = data.companyName;
        cp.Name = data.fullName;
        if (data.companyName != null) {
            cp.Name = data.companyName;
        } else {
            cp.Name = data.fullName;
        }
        Id CPRecordTypeId = Schema.SObjectType.Broker__c.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
        cp.RecordTypeId = CPRecordTypeId;
        cp.RW_RERA_Registration_Number__c = data.reraRegistrationNumber;
        cp.RERA_Valid_till__c = String.isNotBlank(data.reraValidTill) ? Date.valueOf(data.reraValidTill) : null;
        cp.Broker_Type__c = data.partnerType;
        cp.Project__c = data.projectId;	
        cp.Dialing_Country_Code1__c = data.countryCode;
        /*cp.RW_Is_CC_Applicable__c = Boolean.valueOf(data.hasCompetencyCert);
        if(cp.RW_Is_CC_Applicable__c){
            cp.CC_Valid_till__c = String.isNotBlank(data.ccValidTill) ? Date.valueOf(data.ccValidTill) : null;
        }else{
            cp.CC_Scheduled_Exam_Date__c = String.isNotBlank(data.ccScheduledExamDate) ? Date.valueOf(data.ccScheduledExamDate) : null;
        }*/
        cp.Is_NRI_CP__c = data.isNri;
        if(cp.Is_NRI_CP__c){
            cp.Are_you_NRI__c = 'Yes';
        }else{
            cp.Are_you_NRI__c = 'No';
        }
        cp.RW_Is_GST_Applicable__c = data.isGstApplicable;
        if(cp.RW_Is_GST_Applicable__c){
            cp.RW_GST_Number__c = data.gstNumber;
        }
        cp.Experience__c = data.experience;
        cp.Place_of_Supply__c = data.operationPlace;
        cp.Team_Size__c = data.teamSize;
        cp.Expertise__c = data.expertise; 
        cp.Developers_Worked_For__c = data.developerWorkedFor;
        cp.House_Flat_Company__c = data.address.houseFlatCompany;
        cp.STREET__c = data.address.streetAddress1;
        cp.STR_SUPPL2__c = data.address.streetAddress2;
        cp.STR_SUPPL3__c = data.address.streetAddress3;
        cp.STR_SUPPL1__c = cp.House_Flat_Company__c + ',' + cp.STREET__c;
        cp.Country__c = data.address.country;
        cp.State__c = data.address.stateRegion;
        cp.City__c = data.address.city;
        cp.Pin_Code__c = data.address.zipPinCode;
        cp.Cheque_DD_Favouring_Name__c = data.bankDetails.chequeDdFavouringName;
        cp.Branch_Code__c = data.bankDetails.branchCode;
        cp.IFSC_Code__c = data.bankDetails.bankAccountIfscCode;
        cp.Account_Number__c = data.bankDetails.bankAccountNumber;
        cp.Bank_Name__c = data.bankDetails.bankName;
        cp.Bank_Branch__c = data.bankDetails.branchName;        
        cp.Created_from_Lockated__c = true;
        
        list<String> approvers = CPRegisterationController.getApprovers(data.projectId);
        if(!approvers.isEmpty()){
            cp.Approver_L1__c = approvers[0];
            cp.Approver_L2__c = approvers[1];
        }        
        cp.Is_T_C_Accepted__c = true;
        cp.Registration_Complete__c = true;
        upsert cp;
        
        list<ContentVersion> cvlist = new list<ContentVersion>();
        For(Documents d : data.documents){
            system.debug('Attachment -> '+d.attachment);
            system.debug('fileName -> '+d.fileName);
            system.debug('fileType -> '+d.fileType);
            String base64Data = d.attachment;  
            Blob fileBody = EncodingUtil.base64Decode(base64Data);
            if(String.isNotBlank(d.attachment)){
                ContentVersion cv = new ContentVersion(
                    VersionData = fileBody,
                    PathOnClient = d.fileName + '.' + d.fileType,
                    Title = d.fileName
                );
                cvlist.add(cv);
            }
        }
        system.debug('cvlist -> '+cvlist);
        if(!cvlist.isEmpty()){
            insert cvlist;
            
            List<ContentDocumentLink> links = new List<ContentDocumentLink>();            
            for (ContentVersion cv : [Select Id,ContentDocumentId from ContentVersion where Id =: cvlist]) {
                links.add(new ContentDocumentLink(
                    ContentDocumentId = cv.ContentDocumentId, 
                    LinkedEntityId = cp.id,  
                    ShareType = 'V',     
                    Visibility = 'AllUsers'
                ));
            }            
            insert links;
        }
        
        /*String base64Data = data.attachment;  
Blob fileBody = EncodingUtil.base64Decode(base64Data);

ContentVersion cv = new ContentVersion(
VersionData = fileBody,
PathOnClient = data.fileName + '.' + data.fileType,
Title = data.fileName
);
insert cv;*/
        
        
        
        response.put('status', 'success');
        response.put('message', 'Partner registered successfully');
        response.put('cpId', cp.Id);
        
        return response;
    }
    
    public static Map<String,Object> handleTempCP(String jsonBody){
        
        tempCPWrapper data = (tempCPWrapper) JSON.deserialize(jsonBody,tempCPWrapper.class);
        
        Map<String, Object> response = new Map<String, Object>();
        
        // Check if CP already exists with same email or PAN
        List<Broker__c> existing = [SELECT Id, Name, RW_Email__c, Broker_Pan_No__c,RW_Mobile_No__c FROM Broker__c WHERE 
                                    RW_Email__c = :data.email OR Broker_Pan_No__c = :data.panNo OR RW_Mobile_No__c =: data.phone LIMIT 1];
        
        if (!existing.isEmpty()) {
            response.put('status', 'error');
            response.put('message', 'Partner already exists with this email, PAN or Mobile');
            return response;
        }
        
        //If passed validations, insert Broker__c record 
        Broker__c cp = new Broker__c();        
        cp.NAME_FIRST__c = data.firstName;
        cp.NAME_MIDDLE__c = data.middleName;
        cp.NAME_LAST__c = data.lastName;
        if (cp.NAME_MIDDLE__c != null) {
            cp.Name = data.firstName + ' ' + data.middleName + ' ' + data.lastName;
        } else {
            cp.Name = data.firstName + ' ' + data.lastName;
        }
        cp.RW_Email__c = data.email;
        cp.Broker_Pan_No__c = data.panno;
        cp.Company_Name__c = data.companyName;
        cp.Company_Name_As_per_RERA__c = data.companyName;
        cp.RW_Mobile_No__c = data.phone;
        Id tempRecordTypeId = Schema.SObjectType.Broker__c.getRecordTypeInfosByName().get('Temp Channel Partner').getRecordTypeId();
        cp.RecordTypeId = tempRecordTypeId;     
        //cp.Sourcing_Manager__c = UserInfo.getUserId();
        
        insert cp;      
        
        response.put('status', 'success');
        response.put('message', 'Temporary Partner created successfully');
        response.put('cpId', cp.Id);
        
        return response;
    }
    
    public static list<Attachment> getCPAttachments(String cpId) {        
        list<Attachment> attMaplist = new list<Attachment>();
        
        // Step 1: Get all files linked to the Channel Partner record
        List<ContentDocumentLink> cdlList = [
            SELECT ContentDocumentId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :cpId
        ];
        
        if (cdlList.isEmpty()) {
            System.debug('⚠️ No documents linked to: ' + cpId);
            return attMaplist;
        }
        
        Set<Id> docIds = new Set<Id>();
        for (ContentDocumentLink cdl : cdlList) {
            docIds.add(cdl.ContentDocumentId);
        }

        List<ContentVersion> versions = [
            SELECT Id, Title, FileType, ContentDocumentId, VersionData 
            FROM ContentVersion 
            WHERE ContentDocumentId IN :docIds 
            AND IsLatest = true
        ];

        for (ContentVersion cv : versions) {
            Attachment att = new Attachment();
            att.attachmentName = cv.Title;
            att.attachmentType = cv.FileType;
            att.attachmentId = cv.ContentDocumentId;
            
            // Convert the Blob (VersionData) to a Base64 String
            if (cv.VersionData != null) {
                att.url = EncodingUtil.base64Encode(cv.VersionData);
            }
            
            // Use 'base64Body' (or whatever field name you prefer) instead of 'url'
            // att.url = ... (Removed as requested)
            
            attMaplist.add(att);
        }
        
        System.debug('✅ attMaplist size => ' + attMaplist.size());
        return attMaplist;
    }
    
     public static List<opportunityDetails> getOpportunitiesForBroker(Id brokerId) {
        List<opportunityDetails> oppDetailsList = new List<opportunityDetails>();
        if (brokerId == null) return oppDetailsList;

        List<Opportunity> oppList = [
            SELECT Id, Name, RW_Email__c, RW_Phone_No__c, RW_Broker__c ,StageName,Project_Name__c
            FROM Opportunity
            WHERE  StageName = 'Unit Booked' and RW_Broker__c  = :brokerId Order by Createddate desc
        ];

        for (Opportunity opp : oppList) {
            opportunityDetails oppWrap = new opportunityDetails();
            oppWrap.opportunityId = opp.Id;
            oppWrap.name = opp.Name;
            oppWrap.email = opp.RW_Email__c;
            oppWrap.phone = opp.RW_Phone_No__c ;
            oppWrap.status = opp.StageName;
            oppWrap.project = opp.Project_Name__c;
            oppDetailsList.add(oppWrap);
        }
        return oppDetailsList;
    }
    
    public static void getTemporaryAccess(CPDetailsWrapper cp, Broker__c broker){
        List<String> fieldsToCheck = new List<String>();
    
        // 1. Fetch fields from Custom Metadata Type
        // Note: Custom Metadata queries do not count toward SOQL limits
        List<CP_Profile_Field__mdt> configuredFields = [
            SELECT Field_API_Name__c 
            FROM CP_Profile_Field__mdt 
            WHERE Field_API_Name__c != NULL
        ];
    
        for(CP_Profile_Field__mdt mdt : configuredFields){
            fieldsToCheck.add(mdt.Field_API_Name__c);
        }
        Integer filledFields = 0;
        Integer totalFields = fieldsToCheck.size();
        
        // 2. Iterate and check if fields are populated on the queried record
        for(String fieldApi : fieldsToCheck){
            // Check if not null and not empty string
            if(broker.get(fieldApi) != null && String.isNotBlank(String.valueOf(broker.get(fieldApi)))){
                filledFields++;
            }
        }
        
        // 3. Calculate Percentage
        if(totalFields > 0){
            Decimal percentage = (Decimal.valueOf(filledFields) / Decimal.valueOf(totalFields)) * 100;
            // Format to 2 decimal places and assign to wrapper
            cp.basicDetails.temporaryAccess = String.valueOf(percentage.setScale(2));
        } else {
            cp.basicDetails.temporaryAccess = '0';
        }
    }
    
    public class Attachment{
        public String attachmentId;
        public String attachmentName;
        public String attachmentType;
        public String url;
    }
    
    global class cpDetailsPost{
        public cpRegistrationWrapper cpCreationRequest;
    }
    
    public class cpRegistrationWrapper {
        public String partnerType;
        public String projectId;
        public String fullName;
        public String email;
        public String phone;
        public String panNo;
        public String countryCode;
        public String companyName;
        public String reraRegistrationNumber;
        public String reraValidTill;
        //public Boolean hasCompetencyCert;
        public String ccValidTill;
        public String ccScheduledExamDate;
        public Boolean isNri;
        public Boolean isGstApplicable;
        public String gstNumber;
        public String experience;
        public String operationPlace;
        public String avgQuarterBusiness;
        public String teamSize;
        public String expertise;
        public String developerWorkedFor;
        
        public Address address;
        public BankDetails bankDetails;
        public list<Documents> documents;
        public String recordId;
    }
    
    public class CPDetailsWrapper {
        public String id;
        public GetBasicDetails basicDetails;
        public SourcingManagerDet sourcingManagerDetails;
        public Address address;
        public BankDetails bankDetails;
        public Map<String, List<CalenderDetails>> calenderDetails;
        public list<Attachment> documents;
        public list<opportunityDetails> opportunityDetails;
        public cpPerformance cpPerformanceDetails; 
    }
        
        public class GetBasicDetails {
            public String channelPartnerType;
            public String project;
            public String fullName;
            public String emailAddress;
            public String mobileNo;
            public String panNo;
            public String countryCode;
            public String companyName;
            public String reraNo;
            public String reraValidTill;
            //public String hasCompetencyCert;
            public String ccValidTill;
            public String ccScheduledExamDate;
            public String nri;
            public String gstApplicable;
            public String gstNo;
            public String experience;
            public String placeOfOperation;
            public String averageQuarterlyBusiness;
            public String teamSize;
            public String cpType;
            public String cpStatus;
            public String temporaryAccess;
            public Boolean isAop;
        }
        
    public class SourcingManagerDet{
        public String fullName;
        public String mobileNumber;
        public String emailAddress;
    }
    
    public class CalenderDetails{
        public String eventId;
        public String subject;
        public String activityDate;
    }
    
    public class cpPerformance{
        public Integer leadsGenerated;
        public Integer leadsConverted;
        public Decimal ConversionRate;
        public list<RecentConversions> recentConversions;
    }
    
    public class RecentConversions{
        public string project;
        public string customerName;
    }
        
   
    
    public class tempCPWrapper {
        public String companyName;
        public String firstName;
        public String middleName;
        public String lastName;
        public String phone;
        public String email;
        public String panNo;
        public String aadhaarNo;
    }
    
    public class Address {
        public String houseFlatCompany;
        public String streetAddress1;
        public String streetAddress2;
        public String streetAddress3;
        public String country;
        public String stateRegion;
        public String city;
        public String zipPinCode;
    }
    
    public class BankDetails {
        public String chequeDdFavouringName;
        public String branchCode;
        public String bankAccountIfscCode;
        public String bankAccountNumber;
        public String bankName;
        public String branchName;
    }
    
    public class Documents {
        public string fileName;
        public string fileType;
        public string attachment;
    } 
    
    public class opportunityDetails {
        public string opportunityId;
        public string name;
        public string email;
        public string phone;
        public string status;
        public string project;
    } 
    
    public static Id getProjectId(String projectName){
        list<Project__c> pj = [Select Id from Project__c where Name =: projectName limit 1];
        if(!pj.isEmpty()){
            return pj[0].Id;
        }else{
            return 'No Project Found with this Name';
        }
    }
    
}