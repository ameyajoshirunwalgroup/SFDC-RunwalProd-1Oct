@RestResource(urlMapping='/cpGetMyLeads/*')
global without sharing class Lockated_CPGetMyLeads {
    
    @HttpGet
    global static void doGet() {
       RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        String cpId = req.params.get('cpId');
        Map<String, Object> errorResult = new Map<String, Object>();
        if(String.isBlank(cpId)){
            errorResult.put('status', 'error');
            errorResult.put('message', 'Please pass valid CP Id');
            res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
            res.statusCode = 400;
        }else{
            try{
                ResponseWrapper resp = new ResponseWrapper();
                Id CPRecordTypeId = Schema.SObjectType.Broker__c.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
                Id TempCPRecordTypeId = Schema.SObjectType.Broker__c.getRecordTypeInfosByName().get('Temp Channel Partner').getRecordTypeId();                
                list<Broker__c> brlist = [Select Id,RecordTypeId from Broker__c where Id =: cpId];
                if(!brlist.isEmpty()){
                    list<LeadDetails> ActiveLeadDetailslist = new list<LeadDetails>();
                    list<LeadDetails> InactiveLeadDetailslist = new list<LeadDetails>();
                    list<SiteVisitDetails> SiteVisitDetailslist = new list<SiteVisitDetails>();
                    list<BookingDetails> BookingDetailslist = new list<BookingDetails>();
                    list<lead> leadlist = [Select Id,Name,RW_Mobile_No__c,Email,RW_Project__c,CreatedDate,RW_Project__r.Name,Proposed_Visit_Date__c,IsActive__c,LeadSource,Walkin_Source__c,(Select Id,Generated_OTP__c from OTPs__r order by createddate desc limit 1) FROM Lead where 
                                               (Walkin_Channel_Partner__c = :cpId OR RW_Broker__c =: cpId)
                                               AND (LeadSource = 'Channel Partner' OR Walkin_Source__c = 'Channel Partner' OR LeadSource = 'Temp Channel Partner' OR Walkin_Source__c = 'Temp Channel Partner') order by createddate desc];
                    
                    list<Opportunity> opplist = [Select Id,Name,StageName,RW_Mobile_No__c,RW_Email__c,RW_Project__r.Name,Date_Of_Visit__c,Walkin_Source__c,Account.PersonEmail FROM Opportunity where
                                                 RW_Walkin_Channel_Partner__c  = : cpId 
                                                 AND (Walkin_Source__c  = 'Channel Partner'  OR Walkin_Source__c  = 'Temp Channel Partner')
                                                 AND StageName = 'Site Visit'  order by Date_Of_Visit__c desc];
                    
                    list<Booking__c> blist = [SELECT Id,Name,Booking_Date__c,Source_of_Booking__c,Status__c,Project__r.Name,Opportunity__r.Name,
                                              Additional_Brokerage_Accrued_Dashboards__c,Base_Brokerage_Accrued_Dashboards__c,Agreement_Value_for_brokers__c, 
                                              Project_Name__c,Unit_No__r.Name,Brokerage_Scheme__r.End_Date__c,Payment_Received__c,Registration_date_status__c 
                                              FROM Booking__c where 
                                              (Source_of_Booking__c ='Channel Partner' OR Source_of_Booking__c ='Temp Channel Partner' )  and BrokerIId__c =: cpId Order by Booking_Date__c Desc];
                    list<Applicant_Details__c> aplist = [Select Id,Booking__c,Mobile_Number__c,Email_Address__c,Applicant_Number__c,Name,Booking__r.Source_of_Booking__c from Applicant_Details__c
                                                         where Booking__c != null and (Booking__r.Source_of_Booking__c ='Channel Partner' OR Booking__r.Source_of_Booking__c ='Temp Channel Partner' )  and Booking__r.BrokerIId__c =: cpId  order by createddate desc];
                    
                    Set<Id> bookingIds = new Set<Id>();
                    Map<Id, Brokerage_Invoice__c> bookingToBrokerageInvoiceMap = new Map<Id, Brokerage_Invoice__c>();
                    if(!blist.isEmpty()){
                        for (Booking__c b : blist) {
                            bookingIds.add(b.Id);
                        }
                        List<Brokerage_Invoice__c> brokerageInvoices = [
                            SELECT Id,
                                   Booking__c,Status__c,
                            	   CP_Brokerage__c,
                                   CP_Brokerage__r.Status__c,
                                   CP_Brokerage__r.Brokerage_Type__c
                            FROM Brokerage_Invoice__c
                            WHERE Booking__c IN :bookingIds and CP_Brokerage__r.Brokerage_Type__c = 'Base Brokerage'
                        ];
                        
                        for (Brokerage_Invoice__c bi : brokerageInvoices) {
                            // If only ONE invoice per booking is expected
                            bookingToBrokerageInvoiceMap.put(bi.Booking__c, bi);
                        }
                    }
                    
                    
                    
                    Map<Id, List<Applicant_Details__c>> bookingIdVsApplicants = new Map<Id, List<Applicant_Details__c>>();
                    for (Applicant_Details__c ap : aplist) {
                        if (!bookingIdVsApplicants.containsKey(ap.Booking__c)) {
                            bookingIdVsApplicants.put(ap.Booking__c, new List<Applicant_Details__c>());
                        }
                        bookingIdVsApplicants.get(ap.Booking__c).add(ap);
                    }
                    if(brlist[0].RecordTypeId == CPRecordTypeId){
                        //Active and Inactive Leads
                        if(!leadlist.isEmpty()){
                            for(Lead l1 : leadlist ){
                                if(l1.LeadSource == 'Channel Partner' || l1.Walkin_Source__c == 'Channel Partner' ){
                                    if(l1.IsActive__c){
                                        LeadDetails l = new LeadDetails();
                                        l.name = l1.Name;
                                        l.leadId = l1.Id;
                                        l.mobile = l1.RW_Mobile_No__c;
                                        l.email = l1.Email;
                                        l.project = l1.RW_Project__r.Name;
                                        if(l1.CreatedDate != null) {
                                            Date d = Date.valueOf(l1.CreatedDate);
                                            DateTime dt = DateTime.newInstance(d.year(), d.month(), d.day());
                                            l.createdDate = dt.format('dd-MM-yyyy');
                                        } else {
                                            l.createdDate = null;
                                        }
                                        // l.siteVisitDate = Date.valueof(l1.Proposed_Visit_Date__c);  
                                        // *** DATE FIX FOR LEADS ***
                                        if(l1.Proposed_Visit_Date__c != null) {
                                            Date d = Date.valueOf(l1.Proposed_Visit_Date__c);
                                            DateTime dt = DateTime.newInstance(d.year(), d.month(), d.day());
                                            l.siteVisitDate = dt.format('dd-MM-yyyy');
                                        } else {
                                            l.siteVisitDate = null;
                                        }
                                        if (l1.OTPs__r != null && !l1.OTPs__r.isEmpty()) {
                                            l.inviteCode = l1.OTPs__r[0].Generated_OTP__c;
                                        } else {
                                            l.inviteCode = null;
                                        }
                                        if(l.siteVisitDate == null){
                                            l.visitType = 'New Site Visit';
                                        } else{
                                            l.visitType = 'Reschedule Visit';
                                        }  
                                        ActiveLeadDetailslist.add(l);
                                    }else{
                                        LeadDetails l = new LeadDetails();
                                        l.name = l1.Name;
                                        l.leadId = l1.Id;
                                        l.mobile = l1.RW_Mobile_No__c;
                                        l.email = l1.Email;
                                        l.project = l1.RW_Project__r.Name;
                                        if(l1.CreatedDate != null) {
                                            Date d = Date.valueOf(l1.CreatedDate);
                                            DateTime dt = DateTime.newInstance(d.year(), d.month(), d.day());
                                            l.createdDate = dt.format('dd-MM-yyyy');
                                        } else {
                                            l.createdDate = null;
                                        }
                                        // l.siteVisitDate = Date.valueof(l1.Proposed_Visit_Date__c);
                                        // *** DATE FIX FOR LEADS ***
                                        if(l1.Proposed_Visit_Date__c != null) {
                                            Date d = Date.valueOf(l1.Proposed_Visit_Date__c);
                                            DateTime dt = DateTime.newInstance(d.year(), d.month(), d.day());
                                            l.siteVisitDate = dt.format('dd-MM-yyyy');
                                        } else {
                                            l.siteVisitDate = null;
                                        }
                                        if (l1.OTPs__r != null && !l1.OTPs__r.isEmpty()) {
                                            l.inviteCode = l1.OTPs__r[0].Generated_OTP__c;
                                        } else {
                                            l.inviteCode = null;
                                        }
                                        if(l.siteVisitDate == null){
                                            l.visitType = 'New Site Visit';
                                        } else{
                                            l.visitType = 'Reschedule Visit';
                                        }  
                                        InactiveLeadDetailslist.add(l); 
                                    }
                                }
                            }
                        }
                        
                        //Site Visits
                        if(!opplist.isEmpty()){
                            for(Opportunity o : opplist ){
                                if(o.Walkin_Source__c  == 'Channel Partner'){
                                    SiteVisitDetails sv = new SiteVisitDetails();
                                    sv.oppId = o.id;
                                    sv.status = o.StageName;
                                    sv.name = o.Name;
                                    sv.mobile = o.RW_Mobile_No__c;
                                    if(o.AccountId!=null && o.Account.PersonEmail!=null){
                                    	sv.email = o.Account.PersonEmail;
                                    }
                                    sv.project = o.RW_Project__r.Name;
                                    // sv.siteVisitDate = o.Date_Of_Visit__c;
                                    if(o.Date_Of_Visit__c != null) {
                                        Date d = o.Date_Of_Visit__c;
                                        DateTime dt = DateTime.newInstance(d.year(), d.month(), d.day());
                                        sv.siteVisitDate = dt.format('dd-MM-yyyy');
                                    } else {
                                        sv.siteVisitDate = null;
                                    }
                                    SiteVisitDetailslist.add(sv);
                                }
                            }
                        }
                        
                        //Bookings       
                        if(!blist.isEmpty()){
                            for(Booking__c b1 : blist ){
                                if(b1.Source_of_Booking__c =='Channel Partner'){
                                    BookingDetails b = new BookingDetails();
                                    b.customerDetails = new list<CustomerDetails>();
                                    for(Applicant_Details__c ap : bookingIdVsApplicants.get(b1.id)){
                                        if(ap.Booking__r.Source_of_Booking__c =='Channel Partner'){
                                            CustomerDetails c = new CustomerDetails();
                                            c.name = ap.Name;
                                            c.emailId = ap.Email_Address__c;
                                            c.contactNo = ap.Mobile_Number__c;
                                            c.applicantNumber = ap.Applicant_Number__c;
                                            b.customerDetails.add(c);
                                        }
                                    }
                                    b.bookingSummary = new BookingSummary();
                                    b.bookingSummary.projectName = b1.Project_Name__c;
                                    b.bookingSummary.unit = b1.Unit_No__r.Name;
                                    // b.bookingSummary.bookingDate = String.valueof(Date.valueof(b1.Booking_Date__c));
                                    // === DATE FIX: Booking Date ===
                                    if(b1.Booking_Date__c != null) {
                                        Date d = Date.valueOf(b1.Booking_Date__c); // Convert to date
                                        DateTime dt = DateTime.newInstance(d.year(), d.month(), d.day()); // Convert to DateTime
                                        b.bookingSummary.bookingDate = dt.format('dd-MM-yyyy'); // Format
                                    } else {
                                        b.bookingSummary.bookingDate = null;
                                    }
                                    b.bookingSummary.bookingId = b1.Id;
                                    b.bookingSummary.status = b1.Status__c;
                                    
                                    b.financialDetails = new FinancialDetails();
                                    b.financialDetails.agreementValue = b1.Agreement_Value_for_brokers__c!=null ? b1.Agreement_Value_for_brokers__c : 0;
                                    b.financialDetails.percentagePaid = b1.Payment_Received__c!=null ? b1.Payment_Received__c : 0;
                                    b.financialDetails.registrationStatus = b1.Registration_date_status__c!=null ? b1.Registration_date_status__c : 'Un-Registered';
                                    b.financialDetails.brokerageStatus = 'Unpaid';
                                    if(bookingToBrokerageInvoiceMap.containsKey(b1.Id) && bookingToBrokerageInvoiceMap.get(b1.Id).Status__c!=null){
                                    	b.financialDetails.brokerageStatus = bookingToBrokerageInvoiceMap.get(b1.Id).Status__c;
                                    }
                                    BookingDetailslist.add(b);
                                }
                            }
                        }
                        
                        
                        
                    } 
                    else if(brlist[0].RecordTypeId == TempCPRecordTypeId){
                        //Active and Inactive Leads
                        if(!leadlist.isEmpty()){
                            for(Lead l1 : leadlist ){
                                if(l1.LeadSource == 'Temp Channel Partner' || l1.Walkin_Source__c == 'Temp Channel Partner' ){
                                    if(l1.IsActive__c){
                                        LeadDetails l = new LeadDetails();
                                        l.name = l1.Name;
                                        l.leadId = l1.Id;
                                        l.mobile = l1.RW_Mobile_No__c;
                                        l.email = l1.Email;
                                        l.project = l1.RW_Project__r.Name;
                                        if(l1.CreatedDate != null) {
                                            Date d = Date.valueOf(l1.CreatedDate);
                                            DateTime dt = DateTime.newInstance(d.year(), d.month(), d.day());
                                            l.createdDate = dt.format('dd-MM-yyyy');
                                        } else {
                                            l.createdDate = null;
                                        }
                                        // l.siteVisitDate = Date.valueof(l1.Proposed_Visit_Date__c);
                                        // *** DATE FIX FOR LEADS ***
                                        if(l1.Proposed_Visit_Date__c != null) {
                                            Date d = Date.valueOf(l1.Proposed_Visit_Date__c);
                                            DateTime dt = DateTime.newInstance(d.year(), d.month(), d.day());
                                            l.siteVisitDate = dt.format('dd-MM-yyyy');
                                        } else {
                                            l.siteVisitDate = null;
                                        }
                                        if(l.siteVisitDate == null){
                                            l.visitType = 'New Site Visit';
                                        } else{
                                            l.visitType = 'Reschedule Visit';
                                        } 
                                        if (l1.OTPs__r != null && !l1.OTPs__r.isEmpty()) {
                                            l.inviteCode = l1.OTPs__r[0].Generated_OTP__c;
                                        } else {
                                            l.inviteCode = null;
                                        }
                                        ActiveLeadDetailslist.add(l);
                                    }else{
                                        LeadDetails l = new LeadDetails();
                                        l.name = l1.Name;
                                        l.leadId = l1.Id;
                                        l.mobile = l1.RW_Mobile_No__c;
                                        l.email = l1.Email;
                                        l.project = l1.RW_Project__r.Name;
                                        if(l1.CreatedDate != null) {
                                            Date d = Date.valueOf(l1.CreatedDate);
                                            DateTime dt = DateTime.newInstance(d.year(), d.month(), d.day());
                                            l.createdDate = dt.format('dd-MM-yyyy');
                                        } else {
                                            l.createdDate = null;
                                        }
                                        //l.siteVisitDate = Date.valueof(l1.Proposed_Visit_Date__c);
                                        // *** DATE FIX FOR LEADS ***
                                        if(l1.Proposed_Visit_Date__c != null) {
                                            Date d = Date.valueOf(l1.Proposed_Visit_Date__c);
                                            DateTime dt = DateTime.newInstance(d.year(), d.month(), d.day());
                                            l.siteVisitDate = dt.format('dd-MM-yyyy');
                                        } else {
                                            l.siteVisitDate = null;
                                        }
                                        if (l1.OTPs__r != null && !l1.OTPs__r.isEmpty()) {
                                            l.inviteCode = l1.OTPs__r[0].Generated_OTP__c;
                                        } else {
                                            l.inviteCode = null;
                                        }
                                        if(l.siteVisitDate == null){
                                            l.visitType = 'New Site Visit';
                                        } else{
                                            l.visitType = 'Reschedule Visit';
                                        }
                                        InactiveLeadDetailslist.add(l);
                                    }
                                }
                            }
                        }
                        
                        //Site Visits
                        if(!opplist.isEmpty()){
                            for(Opportunity o : opplist ){
                                if(o.Walkin_Source__c  == 'Temp Channel Partner'){
                                    SiteVisitDetails sv = new SiteVisitDetails();
                                    sv.oppId = o.id;
                                    sv.status = o.StageName;
                                    sv.name = o.Name;
                                    sv.mobile = o.RW_Mobile_No__c;
                                    if(o.AccountId!=null && o.Account.PersonEmail!=null){
                                    	sv.email = o.Account.PersonEmail;
                                    }
                                    sv.project = o.RW_Project__r.Name;
                                    // sv.siteVisitDate = o.Date_Of_Visit__c;
                                    if(o.Date_Of_Visit__c != null) {
                                        Date d = o.Date_Of_Visit__c;
                                        DateTime dt = DateTime.newInstance(d.year(), d.month(), d.day());
                                        sv.siteVisitDate = dt.format('dd-MM-yyyy');
                                    } else {
                                        sv.siteVisitDate = null;
                                    }
                                    SiteVisitDetailslist.add(sv);   
                                }
                            }
                        }
                        
                        //Bookings
                        if(!blist.isEmpty()){
                            for(Booking__c b1 : blist ){
                                if(b1.Source_of_Booking__c =='Temp Channel Partner'){
                                    BookingDetails b = new BookingDetails();
                                    b.customerDetails = new list<CustomerDetails>();
                                    for(Applicant_Details__c ap : bookingIdVsApplicants.get(b1.id)){
                                        if(ap.Booking__r.Source_of_Booking__c =='Temp Channel Partner'){
                                            CustomerDetails c = new CustomerDetails();
                                            c.name = ap.Name;
                                            c.emailId = ap.Email_Address__c;
                                            c.contactNo = ap.Mobile_Number__c;
                                            c.applicantNumber = ap.Applicant_Number__c;
                                            b.customerDetails.add(c);
                                        }
                                    }
                                    b.bookingSummary = new BookingSummary();
                                    b.bookingSummary.projectName = b1.Project_Name__c;
                                    b.bookingSummary.unit = b1.Unit_No__r.Name;
                                    //b.bookingSummary.bookingDate = String.valueof(Date.valueof(b1.Booking_Date__c));
                                    // You might want to fix Booking Date format too:
                                    if(b1.Booking_Date__c != null) {
                                        Date d = Date.valueOf(b1.Booking_Date__c);
                                        b.bookingSummary.bookingDate = DateTime.newInstance(d.year(), d.month(), d.day()).format('dd-MM-yyyy');
                                    }
                                    b.bookingSummary.bookingId = b1.Id;
                                    b.bookingSummary.status = b1.Status__c;
                                    
                                    b.financialDetails = new FinancialDetails();
                                    b.financialDetails.agreementValue = b1.Agreement_Value_for_brokers__c!=null ? b1.Agreement_Value_for_brokers__c : 0;
                                    b.financialDetails.percentagePaid = b1.Payment_Received__c!=null ? b1.Payment_Received__c : 0;
                                    b.financialDetails.registrationStatus = b1.Registration_date_status__c!=null ? b1.Registration_date_status__c : 'Un-Registered';
                                    b.financialDetails.brokerageStatus = 'Unpaid';
                                    if(bookingToBrokerageInvoiceMap.containsKey(b1.Id) && bookingToBrokerageInvoiceMap.get(b1.Id).Status__c!=null){
                                    	b.financialDetails.brokerageStatus = bookingToBrokerageInvoiceMap.get(b1.Id).Status__c;
                                    }
                                    BookingDetailslist.add(b);
                                }
                            }
                        }
                    }
                    
                    resp.activeLeadDetails = ActiveLeadDetailslist;
                    resp.inactiveLeadDetails = InactiveLeadDetailslist;
                    resp.siteVisitDetails = SiteVisitDetailslist;
                    resp.bookingDetails = BookingDetailslist;
                    res.responseBody = Blob.valueOf(JSON.serialize(resp));
                    res.statusCode = 200;
                }else{
                    errorResult.put('status', 'error');
                    errorResult.put('message', 'No CP found with this ID');
                    res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                    res.statusCode = 400;
                }
                //return details;
                res.responseBody = Blob.valueOf(JSON.serialize(resp));
                res.statusCode = 200;
            }catch(exception e){
                errorResult.put('status', 'error');
                errorResult.put('message', e.getMessage() + ';  ' + e.getStackTraceString());
                res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                res.statusCode = 400;
            }
            
        }
    }
    
    
    @HttpPost
    global static void updateLeadSiteVisit() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        Map<String, Object> result = new Map<String, Object>();
        String cpId = req.params.get('cpId');
        if(String.isBlank(cpId)){
            result.put('status', 'error');
            result.put('message', 'Please pass valid CP Id');
            res.responseBody = Blob.valueOf(JSON.serialize(result));
            res.statusCode = 400;
        }else{
            try {
                // Parse incoming JSON request body
                Map<String, Object> reqBody = (Map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());
                String recordId = (String) reqBody.get('recordId');
                String proposedDateStr = (String) reqBody.get('proposedVisitDate'); 
                
                
                // Validation
                if (String.isBlank(recordId) || String.isBlank(proposedDateStr)) {
                    result.put('status', 'error');
                    result.put('message', 'recordId and proposedVisitDate are required.');
                    res.responseBody = Blob.valueOf(JSON.serialize(result));
                    res.statusCode = 400;
                    return;
                }
                
                // Parse date
                Date proposedDate = Date.valueOf(proposedDateStr);
                
                String objectName = getObjectNameFromRecordId(recordId);
                // Build response LeadDetails object
                BookVisitDetails ld = new BookVisitDetails();
                String msg = '';
                if(objectName == 'Lead'){
                // Fetch Lead
                Lead l = [
                    SELECT Id, Name ,RW_Project__r.Name,LastName,FirstName,
                    Status, RW_Project__c, RW_Sourcing_Manager__c,Lead_Sourcing_Manager__c,
                    Lead_Source__c, Lead_Sub_Source__c, Customer_Reference__c, LeadSource, OwnerId,
                    RW_Broker__c, Temp_Channel_Partner__c, Vertical__c, Generated_OTP_On_Lead__c, RW_Lead_Sub_Source__c,Proposed_Visit_Date__c
                    FROM Lead 
                    WHERE Id = :recordId 
                    LIMIT 1
                ];
                
                // Determine if this is a new site visit                
                if(l.Proposed_Visit_Date__c == null){
                    ld.visitType = 'New Site Visit';
                    msg = 'Site visit booked';
                } else{
                    ld.visitType = 'Reschedule Visit';
                    msg = 'Site visit rescheduled';
                }  
                
                // Update Proposed Visit Date
                l.Status = 'VCVP';
                l.Proposed_Visit_Date__c = proposedDate;
                update l;
                
                //ld.NewSiteVisit = newSiteVisit;
                ld.siteVisitDate = proposedDate;
                ld.recordId = l.Id;
                ld.project = l.RW_Project__r.Name;
                
                ld.otpGenerated = generateOtp(l);
                    
                }
                
                if(objectName == 'Opportunity'){
                    list<Opportunity> opplist = [Select Id,RW_Project__r.Name,First_Site_Visit_Date__c from Opportunity where Id =: recordId];
                    if(!opplist.isEmpty()){
                        // Determine if this is a new site visit
                        if(opplist[0].First_Site_Visit_Date__c == null){
                            ld.visitType = 'New Site Visit';
                            msg = 'Site visit booked';
                        } else{
                            ld.visitType = 'Reschedule Visit';
                            msg = 'Site visit rescheduled';
                        } 
                        
                        opplist[0].First_Site_Visit_Date__c = proposedDate;  
                        update opplist[0];
                        
                        ld.siteVisitDate = proposedDate;
                        ld.recordId = opplist[0].Id;
                        ld.project = opplist[0].RW_Project__r.Name;
                    }
                }
                
                // Prepare final response
                result.put('status', 'success');
                result.put('message', msg);
                result.put('leadDetails', ld);
                
                res.responseBody = Blob.valueOf(JSON.serialize(result));
                res.statusCode = 200;
                
            } catch (Exception e) {
                result.put('status', 'error');
                result.put('message', e.getMessage());
                res.responseBody = Blob.valueOf(JSON.serialize(result));
                res.statusCode = 400;
            }
    }
    }
    
    public static String getObjectNameFromRecordId(Id recordId) {
        String objectName = '';
        try {
            objectName = recordId.getSObjectType().getDescribe().getName();
        } catch (Exception e) {
            System.debug('Error getting object name: ' + e.getMessage());
        }
        return objectName;
    }

    public static OtpGenerated generateOtp(lead l) {
        OtpGenerated wr = new OtpGenerated();
        try {

            /*if (l.Status != 'VCVP') {
                wr.status = 'error';
                wr.message = 'This Customer does not have any site visit confirmed yet';
                return wr;
            } As Discussed with Shraddha The OTP Will Always Generate when vist is scheduling*/

            if (l.RW_Project__c == null) {
                wr.status = 'error';
                wr.message = 'Please add the Project in Lead.';
                return wr;
            }

            // Check if an active OTP already exists
            List<OTP__c> existingOtps = [
                SELECT Id, Generated_OTP__c, OTP_Expired__c, CreatedById
                FROM OTP__c
                WHERE Lead__c = :l.Id AND OTP_Expired__c = false order by createddate desc
                LIMIT 1
            ];
            
            if (!existingOtps.isEmpty()) {
                wr.status = 'exists';
                wr.message = existingOtps[0].Generated_OTP__c;
                return wr;
            }

            // Generate a new 5-digit OTP
            String OTPNumber;
            Integer len;
            do {
                Long y = Math.round(Math.random() * 100000);
                len = String.valueOf(y).length();
                OTPNumber = String.valueOf(y);
            } while (len < 5);
            
            if (String.isBlank(OTPNumber)) {
                wr.status = 'error';
                wr.message = 'OTP generation failed.';
                return wr;
            }

            OTP__c otp = new OTP__c();
            otp.Generated_OTP__c = OTPNumber;
            otp.OTP_Generated_on__c = String.valueOf(System.now());
            otp.User_Info__c = l.FirstName + ' ' + l.LastName;
            otp.Lead__c = l.Id;
            otp.Project__c = l.RW_Project__c;
			otp.OwnerId = l.OwnerId;
            otp.User__c = l.OwnerId;
            otp.OTP_Generate_For__c = l.LeadSource;
            otp.Channel_Partner_Lookup__c= l.RW_Broker__c ;

            l.Generated_OTP_On_Lead__c = OTPNumber;

            if (l.RW_Sourcing_Manager__c != null) {
                otp.Sourcing_Manager__c = l.RW_Sourcing_Manager__c;
            }
            
            if(l.Proposed_Visit_Date__c != null){
                otp.Customer_Site_Visit_On__c= String.valueOf(l.Proposed_Visit_Date__c);
            
            } else{
                List<Task> vcvpTaskList=[SELECT Id,Call_Proposed_date_of_visit__c,Call_Status__c,Call_Disposition_Custom__c 
                 From Task Where WhoId=:l.id AND Call_Status__c= 'Connected'
                  AND Call_Disposition_Custom__c='Visit Scheduled'
                  ORDER BY CreatedDate DESC LIMIT 1];
                
                 if (!vcvpTaskList.isEmpty() && vcvpTaskList[0].Call_Proposed_date_of_visit__c != null) {
                     otp.Customer_Site_Visit_On__c =  String.valueOf(vcvpTaskList[0].Call_Proposed_date_of_visit__c);
                   }
                 }
            

            insert otp;
            update l;

            wr.status = 'success';
            wr.message = OTPNumber;
            return wr;
        } 
        catch (Exception ex) {
            wr.status = 'error';
            wr.message = ex.getMessage();
            return wr;
        }
    }
    
    
    
    global class ResponseWrapper {
        public list<LeadDetails> activeLeadDetails;
        public list<LeadDetails> inactiveLeadDetails;
        public list<SiteVisitDetails> siteVisitDetails;
        public list<BookingDetails> bookingDetails;
    }
    
    public class LeadDetails{
        public String name;
        public String mobile;
        public String email;
        public String project;
        public String siteVisitDate;
        public String inviteCode;//Clearify Needed.(For now mapped the latest OTP generated )
        public String visitType;
        public String leadId;
        public String createdDate;
    }
    
    public class BookVisitDetails{
        public String recordId;
        public String project;
        public Date siteVisitDate;
        public String visitType;
        public OtpGenerated otpGenerated;
    }
    
    public class OtpGenerated{
        public string status;
        public string message;
    }
    
    public class SiteVisitDetails{
        public String oppId;
        public String status;
        public String name;
        public String mobile;
        public String email;
        public String project;
        public String siteVisitDate;
        public String protectionInDay;
    }
    
    public class BookingDetails{
        public list<CustomerDetails> customerDetails;
        public BookingSummary bookingSummary;
        public FinancialDetails financialDetails;
    }
    
    public class CustomerDetails{
        public String name;
        public String contactNo;
        public String emailId;
        public String applicantNumber;
    }
    
    public class BookingSummary{
        public String projectName;
        public String unit;
        public String bookingDate;
        public String bookingId;
        public String status;
    }
    
    public class FinancialDetails{
        public Decimal agreementValue;
        public Decimal percentagePaid;
        public String registrationStatus;
        public String brokerageStatus;///????
    }
    
}