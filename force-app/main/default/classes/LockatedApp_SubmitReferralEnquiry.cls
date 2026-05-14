@RestResource(urlMapping='/referralEnquiry/*')
global class LockatedApp_SubmitReferralEnquiry {

    @HttpPost
    global static void doPost(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        Map<String, Object> errorResult = new Map<String, Object>();
        //String postType = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        try{
            system.debug('req: ' + req.requestBody);
            String jsonBody = req.requestBody.toString();
            system.debug('jsonBody: ' + jsonBody);
            RefDetails resData = (RefDetails)JSON.deserialize(jsonBody, RefDetails.class);
            system.debug('resData: ' + resData);
            system.debug('booking: ' + resData.booking);
            String bkgId;
            if(resData.phase == 'Post Possession'){ //Added by Vinay 24-04-2026
                List<Project_Unit__c> units = [SELECT Id, Booking__c FROM Project_Unit__c WHERE RW_Project__r.Name =: resData.project AND RW_Param4__c =: resData.unit];
                if(units.size() > 0){
                    bkgId = units[0].Booking__c;
                    resData.booking = bkgId;
                }
            }
            if(String.isBlank(resData.booking)){
                errorResult.put('status', 'error');
                errorResult.put('message', 'Please pass valid Booking Id');
                res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                res.statusCode = 400;
            }else{
                List<Booking__c> bkgs = [SELECT Id, Opportunity__r.AccountId FROM Booking__c WHERE Id =: resData.booking];
                if(bkgs.size() == 0){
                    errorResult.put('status', 'error');
                    errorResult.put('message', 'No booking available with the Booking Id');
                    res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                    res.statusCode = 400;
                }else{
                    List<Project__c> projects = [SELECT Id, Name FROM Project__c WHERE RW_Status__c = 'Active'];
                    
                    Map<String, String> projMap = new Map<String, String>();
                    for(Project__c proj : projects){
                        projMap.put(proj.Name, proj.Id);
                    }
                    if(resData.reqType == 'Referral'){
                        Lead ld = new Lead();
                        ld.FirstName = resData.firstName;
                        ld.LastName = resData.lastName;
                        ld.RW_Mobile_No__c = resData.phone;
                        ld.Email = resData.email;
                        ld.RW_Project__c = projMap.get(resData.project);
                        ld.Customer_Reference__c = bkgs[0].Opportunity__r.AccountId;
                        ld.Description = resData.description;
                        ld.LeadSource = 'Referral';
                        ld.RW_Lead_Sub_Source__c = 'Existing client reference';
                        ld.Integration_Source__c = 'Lockated ' + resData.phase + ' App'; //Added by Vinay 24-04-2026
                        insert ld;
                        res.responseBody = Blob.valueOf('Referral details submitted successfully');
                    	res.statusCode = 200;
                    }else if(resData.reqType == 'Enquiry'){
                        Lead ld = new Lead();
                        ld.FirstName = resData.firstName;
                        ld.LastName = resData.lastName;
                        ld.RW_Mobile_No__c = resData.phone;
                        ld.Email = resData.email;
                        ld.RW_Project__c = projMap.get(resData.project);
                        ld.Description = resData.description;
                        ld.LeadSource = 'Loyalty';
                        ld.Integration_Source__c = 'Lockated ' + resData.phase + ' App'; //Added by Vinay 24-04-2026
                        insert ld;
                        res.responseBody = Blob.valueOf('Enquiry details submitted successfully');
                    	res.statusCode = 200;
                    }
                }
            }
        }catch(exception e){
            errorResult.put('status', 'error');
            errorResult.put('message', e.getMessage() + ';  ' + e.getStackTraceString());
            res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
            res.statusCode = 400;
        }
    }
    
    global class RefDetails{
        public String firstName;
        public String lastName;
        public String phone;
        public String email;
        public String project;
        public String booking;
        public String description;
        public String reqType;
        public String phase; //Added by Vinay 24-04-2026
        public String unit; //Added by Vinay 24-04-2026
    } 
}