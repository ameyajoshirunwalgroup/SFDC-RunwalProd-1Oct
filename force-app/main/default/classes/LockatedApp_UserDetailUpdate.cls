public class LockatedApp_UserDetailUpdate implements Queueable, Database.AllowsCallouts{

    List<ApplicantUpdateWrap> appWrap = new List<ApplicantUpdateWrap>();

    public LockatedApp_UserDetailUpdate(List<ApplicantUpdateWrap> appWrap) {
        this.appWrap = appWrap;
    }
    
    public void execute(QueueableContext context){
        
        List<Society_Id__mdt> socityIds = [SELECT Id, Label, Value__c FROM Society_Id__mdt];
        Map<String, Country_Codes__c> countryNameCodes = Country_Codes__c.getall();
        Map<String, String> projNameVsSocityId = new Map<String, String>();
        for(Society_Id__mdt rec : socityIds){
            projNameVsSocityId.put(rec.Label, rec.Value__c);
        }

        
        System.debug('appWrap: ' + appWrap);
        Map<String, ApplicantUpdateWrap> appWrapMap = new Map<String, ApplicantUpdateWrap>();
        List<String> primaryUpdatedAppIds = new List<String>();
        List<String> secondaryUpdatedAppIds = new List<String>();
        for(ApplicantUpdateWrap wrap : appWrap){
            appWrapMap.put(wrap.applicantId, wrap);
            if(wrap.primaryMobileChanged || wrap.primaryEmailChanged){
                primaryUpdatedAppIds.add(wrap.applicantId);
            }
            if(wrap.secondaryMobileChanged){
                secondaryUpdatedAppIds.add(wrap.applicantId);
            }
        }
        if(primaryUpdatedAppIds.size() > 0){
            updateuser(primaryUpdatedAppIds, appWrapMap, projNameVsSocityId, countryNameCodes);
        }
        if(secondaryUpdatedAppIds.size() > 0){
            updateuser(secondaryUpdatedAppIds, appWrapMap, projNameVsSocityId, countryNameCodes);
        }
    }
    
    public static void updateuser(List<String> appIds, Map<String, ApplicantUpdateWrap> accWrapMap, Map<String, String> projNameVsSocityId, Map<String, Country_Codes__c> countryNameCodes){
        
        
        List<Applicant_Details__c> appList = [SELECT Id,Opportunity__c,Booking__c,Booking__r.Opportunity__r.AccountId,First_Name__c,Last_Name__c,
                                              Booking__r.Opportunity__r.RW_Project_Unit__r.RW_Param4__c,Booking__r.Opportunity__r.RW_Project_Unit__r.RW_Param2__c,
                                              Booking__r.Opportunity__r.SAP_Customer_Number__c,Booking__r.Opportunity__r.RW_Project__r.Name,Email_Address__c,Mobile_Number__c,
                                              Booking__r.Opportunity__r.Account.Country_Code__c,Booking__r.Opportunity__r.Account.RW_Country__c,Booking__r.Opportunity__r.Account.Ownership
                                              FROM Applicant_Details__c WHERE Id =: appIds];
                
        List<ERP_Integration_Log__c> logList = new List<ERP_Integration_Log__c>();
        for(Applicant_Details__c app : appList){
            ERP_Integration_Log__c log = new ERP_Integration_Log__c();
            try{
                HttpRequest request = new HttpRequest();
                HttpResponse response = new HttpResponse();
                Http http = new Http();
                
                String str = '';
                Map<String,String> data = new Map<String,String>();
                data.put('account_id', app.Booking__r.Opportunity__r.AccountId);
                data.put('firstname', app.First_Name__c);
                data.put('lastname', app.Last_Name__c);
                if(app.Booking__r.Opportunity__r.RW_Project_Unit__c != null){
                    data.put('flat', app.Booking__r.Opportunity__r.RW_Project_Unit__r.RW_Param4__c);
                    data.put('tower', app.Booking__r.Opportunity__r.RW_Project_Unit__r.RW_Param2__c);
                }
                data.put('customer_code', app.Booking__r.Opportunity__r.SAP_Customer_Number__c);
                data.put('booking_number', app.Booking__c);
                data.put('society_id', projNameVsSocityId.get(app.Booking__r.Opportunity__r.RW_Project__r.Name));
                if(app.Booking__r.Opportunity__r.Account.Country_Code__c != null){
                    data.put('country_code', app.Booking__r.Opportunity__r.Account.Country_Code__c);
                }else{
                    data.put('country_code', '+91');
                }
                if(app.Booking__r.Opportunity__r.Account.RW_Country__c != null && countryNameCodes.get(app.Booking__r.Opportunity__r.Account.RW_Country__c) != null){
                    data.put('country_code_name', countryNameCodes.get(app.Booking__r.Opportunity__r.Account.RW_Country__c).Code__c.toLowerCase());
                }else{
                    data.put('country_code_name', 'in');
                }
                data.put('status', '1');
                data.put('ownership', app.Booking__r.Opportunity__r.Account.Ownership);
                data.put('is_primary', '1');
                
                data.put('number', app.Mobile_Number__c);
                data.put('email', app.Email_Address__c);
                data.put('mobile_changed','false');
                data.put('email_changed','false');
                System.debug('accWrapMap.get(app.Id): ' + accWrapMap.get(app.Id));
                if(accWrapMap.get(app.Id).primaryMobileChanged){
                    data.put('mobile_changed','true');
                    data.put('existing_mobile', accWrapMap.get(app.Id).oldPrimaryMobile);
                    data.put('number', accWrapMap.get(app.Id).newPrimaryMobile);
                }
                if(accWrapMap.get(app.Id).primaryEmailChanged){
                    data.put('email_changed','true');
                    data.put('existing_email', accWrapMap.get(app.Id).oldPrimaryEmail);
                    data.put('email', accWrapMap.get(app.Id).newPrimaryEmail);
                }
                if(accWrapMap.get(app.Id).secondaryMobileChanged){
                    data.put('mobile_changed','true');
                    data.put('existing_mobile', accWrapMap.get(app.Id).oldSecondaryMobile);
                    data.put('number', accWrapMap.get(app.Id).newSecondaryMobile);
                }
                
                System.debug('data: ' + JSON.Serialize(data));
                
                request.setEndpoint('https://hi-society.lockated.com/runwal_add_user_sap.json?token=0d93e348a9262bc36c2eb86612f119abe803f368ad503eb9'); //Added by Vinay 03-12-2025
                request.setHeader('Content-Type', 'application/json');
                request.setMethod('POST');
                request.setTimeout(120000);
                request.setBody(JSON.Serialize(data));
                if(!Test.isRunningTest()){
                    response = http.send(request);
                }
                if(response.getStatusCode() == 200){
                    System.debug('Response: ' + response);
                }else{
                    log.API_Name__c = 'User Update';
                    log.Opportunity__c = app.Booking__r.Opportunity__c;
                    log.Request__c = JSON.Serialize(data);
                    log.Response__c = response.getStatus();
                    logList.add(log);
                }
            }catch(System.CalloutException e){
                System.debug('Error: ' + e.getMessage()); 
                log.Error_Reason__c =  e.getMessage();
            }finally{
                //logList.add(log);
            }
        }
        if(logList.size()>0){
            insert logList;
        }
    }
    
    
    
    public class ApplicantUpdateWrap{
        public String applicantId;
        public Boolean primaryMobileChanged = false;
        public Boolean primaryEmailChanged = false;
        public Boolean secondaryMobileChanged = false;
        public String oldPrimaryMobile;
        public String oldPrimaryEmail;
        public String oldSecondaryMobile;
        public String newPrimaryMobile;
        public String newPrimaryEmail;
        public String newSecondaryMobile;
    }
}