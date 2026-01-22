public class LockatedApp_UserDetailUpdate implements Queueable, Database.AllowsCallouts{

    List<AccountUpdateWrap> accWrap = new List<AccountUpdateWrap>();

    public LockatedApp_UserDetailUpdate(List<AccountUpdateWrap> accWrap) {
        this.accWrap = accWrap;
    }
    
    public void execute(QueueableContext context){
        
        List<Society_Id__mdt> socityIds = [SELECT Id, Label, Value__c FROM Society_Id__mdt];
        Map<String, Country_Codes__c> countryNameCodes = Country_Codes__c.getall();
        Map<String, String> projNameVsSocityId = new Map<String, String>();
        for(Society_Id__mdt rec : socityIds){
            projNameVsSocityId.put(rec.Label, rec.Value__c);
        }

        
        System.debug('accWrap: ' + accWrap);
        List<Account> accsToUpdate = new List<Account>();
        Set<Id> accountIds = new Set<Id>();
        Map<String, AccountUpdateWrap> accWrapMap = new Map<String, AccountUpdateWrap>();
        List<String> primaryUpdatedAccIds = new List<String>();
        List<String> secondaryUpdatedAccIds = new List<String>();
        for(AccountUpdateWrap wrap : accWrap){
            accWrapMap.put(wrap.acc.Id, wrap);
            if(wrap.primaryMobileChanged || wrap.primaryEmailChanged){
                primaryUpdatedAccIds.add(wrap.acc.Id);
            }
            if(wrap.secondaryMobileChanged || wrap.secondaryEmailChanged){
                secondaryUpdatedAccIds.add(wrap.acc.Id);
            }
        }
        if(primaryUpdatedAccIds.size() > 0){
            updateuser(primaryUpdatedAccIds, accWrapMap, projNameVsSocityId, countryNameCodes);
        }
        if(secondaryUpdatedAccIds.size() > 0){
            updateuser(secondaryUpdatedAccIds, accWrapMap, projNameVsSocityId, countryNameCodes);
        }
    }
    
    public static void updateuser(List<String> accIds, Map<String, AccountUpdateWrap> accWrapMap, Map<String, String> projNameVsSocityId, Map<String, Country_Codes__c> countryNameCodes){
        
                
        List<Opportunity> opps = [SELECT Id, Name, AccountId, Account.FirstName, Account.LastName, Account.PersonEmail,Account.RW_Country__c,
                           Account.Mobile_No__c, Account.Ownership, RW_Project_Unit__r.RW_Param4__c,  Account.Country_Code__c,
                           RW_Project_Unit__r.RW_Param2__c, SAP_Customer_Number__c, Booking__c, RW_Project__r.Name, RW_Project_Unit__c
                           FROM Opportunity WHERE AccountId =: accIds AND StageName = 'Unit Booked'];
        List<ERP_Integration_Log__c> logList = new List<ERP_Integration_Log__c>();
        for(Opportunity opp : opps){
            ERP_Integration_Log__c log = new ERP_Integration_Log__c();
            try{
                HttpRequest request = new HttpRequest();
                HttpResponse response = new HttpResponse();
                Http http = new Http();
                
                String str = '';
                Map<String,String> data = new Map<String,String>();
                data.put('account_id', opp.AccountId);
                data.put('firstname', opp.Account.FirstName);
                data.put('lastname', opp.Account.LastName);
                //data.put('email', opp.Account.PersonEmail);
                //data.put('number', opp.Account.Mobile_No__c);
                if(opp.RW_Project_Unit__c != null){
                    data.put('flat', opp.RW_Project_Unit__r.RW_Param4__c);
                    data.put('tower', opp.RW_Project_Unit__r.RW_Param2__c);
                }
                data.put('customer_code', opp.SAP_Customer_Number__c);
                data.put('booking_number', opp.Booking__c);
                data.put('society_id', projNameVsSocityId.get(opp.RW_Project__r.Name));
                if(opp.Account.Country_Code__c != null){
                    data.put('country_code', opp.Account.Country_Code__c);
                }else{
                    data.put('country_code', '+91');
                }
                if(opp.Account.RW_Country__c != null && countryNameCodes.get(opp.Account.RW_Country__c) != null){
                    data.put('country_code_name', countryNameCodes.get(opp.Account.RW_Country__c).Code__c.toLowerCase());
                }else{
                    data.put('country_code_name', 'in');
                }
                data.put('status', '1');
                data.put('ownership', opp.Account.Ownership);
                data.put('is_primary', '1');
                
                
                System.debug('accWrapMap.get(opp.AccountId): ' + accWrapMap.get(opp.AccountId));
                if(accWrapMap.get(opp.AccountId).primaryMobileChanged){
                    data.put('mobile_changed','true');
                    data.put('existing_mobile', accWrapMap.get(opp.AccountId).oldPrimaryMobile);
                    data.put('number', accWrapMap.get(opp.AccountId).newPrimaryMobile);
                }
                if(accWrapMap.get(opp.AccountId).primaryEmailChanged){
                    data.put('email_changed','true');
                    data.put('existing_email', accWrapMap.get(opp.AccountId).oldPrimaryEmail);
                    data.put('email', accWrapMap.get(opp.AccountId).newPrimaryEmail);
                }
                if(accWrapMap.get(opp.AccountId).secondaryMobileChanged){
                    data.put('mobile_changed','true');
                    data.put('existing_mobile', accWrapMap.get(opp.AccountId).oldSecondaryMobile);
                    data.put('number', accWrapMap.get(opp.AccountId).newSecondaryMobile);
                }
                if(accWrapMap.get(opp.AccountId).secondaryEmailChanged){
                    data.put('email_changed','true');
                    data.put('existing_email', accWrapMap.get(opp.AccountId).oldSecondaryEmail);
                    data.put('email', accWrapMap.get(opp.AccountId).newSecondaryEmail);
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
                    log.Opportunity__c = opp.Id;
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
    
    public class AccountUpdateWrap{
        public Account acc;
        public String accountId;
        public Boolean primaryMobileChanged = false;
        public Boolean primaryEmailChanged = false;
        public Boolean secondaryMobileChanged = false;
        public Boolean secondaryEmailChanged = false;
        public String oldPrimaryMobile;
        public String oldPrimaryEmail;
        public String oldSecondaryMobile;
        public String oldSecondaryEmail;
        public String newPrimaryMobile;
        public String newPrimaryEmail;
        public String newSecondaryMobile;
        public String newSecondaryEmail;
    }
}