public class CreateUserWhenUnitBooked {
       
    @future(callout=true)
    public static void createuser(List<Id> accIds){
        
        List<Society_Id__mdt> socityIds = [SELECT Id, Label, Value__c FROM Society_Id__mdt];
        Map<String, Country_Codes__c> countryNameCodes = Country_Codes__c.getall();
        Map<String, String> projNameVsSocityId = new Map<String, String>();
        for(Society_Id__mdt rec : socityIds){
            projNameVsSocityId.put(rec.Label, rec.Value__c);
        }
        System.debug('accIds: ' + accIds);
        List<Account> accsToUpdate = new List<Account>();
        Set<Id> accountIds = new Set<Id>();
        /*Set<Id> accIds = new Set<Id>();
		List<User> users = [SELECT Id, Name, AccountId FROM User WHERE Id =: usrId];
        for(User usr : users){
            accIds.add(usr.AccountId);
        }*/
        
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
                data.put('email', opp.Account.PersonEmail);
                data.put('number', opp.Account.Mobile_No__c);
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
                
                System.debug(JSON.Serialize(data));
                
                //request.setEndpoint('https://snagging.lockated.com/runwal_add_user_sap.json'); //Commented by Vinay 03-12-2025
                //request.setEndpoint(System.label.Lockated_User_Creation_End_Point); //Added by Vinay 03-12-2025
                request.setEndpoint('https://uat-hi-society.lockated.com/runwal_add_user_sap.json?token=zffEgnJyTg8HycShPS3hYcE53Zpu1abCKUQUD9o06sk'); //Added by Vinay 03-12-2025
                request.setHeader('Content-Type', 'application/json');
                request.setMethod('POST');
                //request.setHeader('token', '0d93e348a9262bc36c2eb86612f119abe803f368ad503eb9'); //Commented by Vinay 03-12-2025
                //request.setHeader('token', System.label.Lockated_User_Creation_Key); //Added by Vinay 03-12-2025
                request.setTimeout(120000);
                request.setBody(JSON.Serialize(data));
                response = http.send(request);
                if(response.getStatusCode() == 200){
                    System.debug('Response: ' + response);
                    if(!accountIds.contains(opp.AccountId)){
                        Account acc = new Account();
                        acc.Id = opp.AccountId;
                        acc.Triggered_to_Lockated__c = true;
                        accsToUpdate.add(acc);
                        accountIds.add(opp.AccountId);
                    }
                }else{
                    log.API_Name__c = 'User Creation/Delete';
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
        update accsToUpdate;
    }
    
    @future(callout=true)
    public static void deleteuser(List<Id> accIds){
        
        List<Society_Id__mdt> socityIds = [SELECT Id, Label, Value__c FROM Society_Id__mdt];
        Map<String, Country_Codes__c> countryNameCodes = Country_Codes__c.getall();
        Map<String, String> projNameVsSocityId = new Map<String, String>();
        for(Society_Id__mdt rec : socityIds){
            projNameVsSocityId.put(rec.Label, rec.Value__c);
        }
        System.debug('accIds: ' + accIds);
        /*Set<Id> accIds = new Set<Id>();
		List<User> users = [SELECT Id, Name, AccountId FROM User WHERE Id =: usrId];
        for(User usr : users){
            accIds.add(usr.AccountId);
        }*/
        
        List<Opportunity> opps = [SELECT Id, Name, AccountId, Account.FirstName, Account.LastName, Account.PersonEmail,Account.RW_Country__c,
                           Account.Mobile_No__c, Account.Ownership, RW_Project_Unit__r.RW_Param4__c,  Account.Country_Code__c,
                           RW_Project_Unit__r.RW_Param2__c, SAP_Customer_Number__c, Booking__c, RW_Project__r.Name
                           FROM Opportunity WHERE AccountId =: accIds AND StageName IN ('Cancelled','Cancellation Initiated','Booking Cancelled – Refund Pending')];
        List<ERP_Integration_Log__c> logList = new List<ERP_Integration_Log__c>();
        for(Opportunity opp : opps){
            ERP_Integration_Log__c log = new ERP_Integration_Log__c();
            try{
                HttpRequest request = new HttpRequest();
                HttpResponse response = new HttpResponse();
                Http http = new Http();
                
                String str = '';
                Map<String,String> data = new Map<String,String>();
                data.put('customer_code', opp.SAP_Customer_Number__c);
                data.put('booking_number', opp.Booking__c);
                data.put('society_id', projNameVsSocityId.get(opp.RW_Project__r.Name));
                System.debug(JSON.Serialize(data));
                request.setEndpoint('https://uat-hi-society.lockated.com/runwal_remove_user_sap.json?token=zffEgnJyTg8HycShPS3hYcE53Zpu1abCKUQUD9o06sk');
                request.setHeader('Content-Type', 'application/json');
                request.setMethod('POST');
                //request.setHeader('Authorization', '0d93e348a9262bc36c2eb86612f119abe803f368ad503eb9');
                request.setTimeout(120000);
                request.setBody(JSON.Serialize(data));
                response = http.send(request);
                if(response.getStatusCode() == 200){
                    System.debug('Response: ' + response);
                }else{
                    
                    log.API_Name__c = 'User Creation/Delete';
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
    
    
    @future(callout=true)
    public static void createuserWithApplicants(List<Id> accIds){
        
        List<Society_Id__mdt> socityIds = [SELECT Id, Label, Value__c FROM Society_Id__mdt];
        Map<String, Country_Codes__c> countryNameCodes = Country_Codes__c.getall();
        Map<String, String> projNameVsSocityId = new Map<String, String>();
        for(Society_Id__mdt rec : socityIds){
            projNameVsSocityId.put(rec.Label, rec.Value__c);
        }
        System.debug('accIds: ' + accIds);
        List<Account> accsToUpdate = new List<Account>();
        Set<Id> accountIds = new Set<Id>();
        
        List<Opportunity> opps = [SELECT Id, Name, AccountId, Account.FirstName, Account.LastName, Account.PersonEmail,Account.RW_Country__c,
                           Account.Mobile_No__c, Account.Ownership, RW_Project_Unit__r.RW_Param4__c,  Account.Country_Code__c,
                           RW_Project_Unit__r.RW_Param2__c, SAP_Customer_Number__c, Booking__c, RW_Project__r.Name, RW_Project_Unit__c
                           FROM Opportunity WHERE AccountId =: accIds AND StageName = 'Unit Booked'];
        List<String> bkgIds = new List<String>();
        Map<String, String> bkgIdVsOppId = new Map<String, String>();
        for(Opportunity opp : opps){
            bkgIds.add(opp.Booking__c);
            bkgIdVsOppId.put(opp.Booking__c, opp.Id);
        }
        
        List<Applicant_Details__c> applicants = [SELECT Id,Applicant_Number__c,Booking__c,Booking__r.Opportunity__c,First_Name__c,Last_Name__c,Mobile_Number__c,Secondary_Mobile_Number__c,Email_Address__c FROM Applicant_Details__c WHERE Booking__c =: bkgIds];
        Map<String, List<Applicant_Details__c>> oppIdVsCoApplicantsMap = new Map<String, List<Applicant_Details__c>>();
        Map<String, Applicant_Details__c> oppIdVsPrimaryApplicant = new Map<String, Applicant_Details__c>();
        for(Applicant_Details__c app : applicants){
            if(app.Applicant_Number__c == 'Primary Applicant'){
                if(!oppIdVsPrimaryApplicant.containsKey(app.Booking__r.Opportunity__c)){
                    oppIdVsPrimaryApplicant.put(app.Booking__r.Opportunity__c, app);
                }
            }else{
                if(oppIdVsCoApplicantsMap.containsKey(app.Booking__r.Opportunity__c)){
                    oppIdVsCoApplicantsMap.get(app.Booking__r.Opportunity__c).add(app);
                }else{
                    oppIdVsCoApplicantsMap.put(app.Booking__r.Opportunity__c, new List<Applicant_Details__c>{app});
                }
            }
            
        }
        
         List<ERP_Integration_Log__c> logList = new List<ERP_Integration_Log__c>();
        for(Opportunity opp : opps){
            ERP_Integration_Log__c log = new ERP_Integration_Log__c();
            try{
                HttpRequest request = new HttpRequest();
                HttpResponse response = new HttpResponse();
                Http http = new Http();
                
                JSONGenerator generator = JSON.createGenerator(true);
                generator.writeStartObject();
                generator.writeStringField('account_id', opp.AccountId);
                generator.writeStringField('firstname', oppIdVsPrimaryApplicant.get(opp.Id).First_Name__c);
                generator.writeStringField('lastname', oppIdVsPrimaryApplicant.get(opp.Id).Last_Name__c);
                generator.writeStringField('primary_number', oppIdVsPrimaryApplicant.get(opp.Id).Mobile_Number__c);
                generator.writeStringField('email', oppIdVsPrimaryApplicant.get(opp.Id).Email_Address__c);
                generator.writeStringField('secondary_number', (oppIdVsPrimaryApplicant.get(opp.Id).Secondary_Mobile_Number__c != null)? oppIdVsPrimaryApplicant.get(opp.Id).Secondary_Mobile_Number__c : '');
                if(opp.RW_Project_Unit__c != null){
                    generator.writeStringField('flat', opp.RW_Project_Unit__r.RW_Param4__c);
                    generator.writeStringField('tower', opp.RW_Project_Unit__r.RW_Param2__c);
                }
                generator.writeStringField('customer_code', opp.SAP_Customer_Number__c);
                generator.writeStringField('booking_number', opp.Booking__c);
                generator.writeStringField('society_id', projNameVsSocityId.get(opp.RW_Project__r.Name));
                generator.writeStringField('country_code', (opp.Account.Country_Code__c != null)? opp.Account.Country_Code__c : '+91');
                if(opp.Account.RW_Country__c != null && countryNameCodes.get(opp.Account.RW_Country__c) != null){
                    generator.writeStringField('country_code_name', countryNameCodes.get(opp.Account.RW_Country__c).Code__c.toLowerCase());
                }else{
                   generator.writeStringField('country_code_name','in');
                }
                generator.writeStringField('status','1');
                generator.writeStringField('ownership', (opp.Account.Ownership != null)? opp.Account.Ownership : '');
                generator.writeStringField('is_primary','1');
                generator.writeFieldName('co_applicants');
                generator.writeStartArray();
                if(oppIdVsCoApplicantsMap.get(opp.Id) != null && oppIdVsCoApplicantsMap.get(opp.Id) != null){
                    for(Applicant_Details__c app : oppIdVsCoApplicantsMap.get(opp.Id)){
                        generator.writeStartObject();
                        generator.writeStringField('firstname', app.First_Name__c);
                        generator.writeStringField('lastname', app.Last_Name__c);
                        generator.writeStringField('primary_number', app.Mobile_Number__c);
                        generator.writeStringField('email', app.Email_Address__c);
                        generator.writeStringField('secondary_number', (oppIdVsPrimaryApplicant.get(opp.Id).Secondary_Mobile_Number__c != null)? oppIdVsPrimaryApplicant.get(opp.Id).Secondary_Mobile_Number__c : '');
                        generator.writeEndObject();
                    }
                }
                
                generator.writeEndArray();
                generator.writeEndObject();
        
                String jsonString = generator.getAsString();
                System.debug('jsonString: ' + jsonString);
                
                request.setEndpoint('https://uat-hi-society.lockated.com/runwal_add_user_sap.json?token=zffEgnJyTg8HycShPS3hYcE53Zpu1abCKUQUD9o06sk');
                request.setHeader('Content-Type', 'application/json');
                request.setMethod('POST');
                //request.setHeader('Authorization', '0d93e348a9262bc36c2eb86612f119abe803f368ad503eb9');
                request.setTimeout(120000);
                //request.setBody(JSON.Serialize(jsonString));
                request.setBody(jsonString);
                response = http.send(request);
                 System.debug('Response: ' + response);
                if(response.getStatusCode() == 200){
                    System.debug('Response: ' + response);
                    if(!accountIds.contains(opp.AccountId)){
                        Account acc = new Account();
                        acc.Id = opp.AccountId;
                        acc.Triggered_to_Lockated__c = true;
                        accsToUpdate.add(acc);
                        accountIds.add(opp.AccountId);
                    }
                }else{
                    log.API_Name__c = 'User Creation/Delete';
                    log.Opportunity__c = opp.Id;
                    log.Request__c = jsonString;
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
        update accsToUpdate;
        
    }
    
    @future(callout=true)
    public static void createUserWhenBookingConfirmed(List<Id> bkgIds){
        
        List<Society_Id__mdt> socityIds = [SELECT Id, Label, Value__c FROM Society_Id__mdt];
        Map<String, Country_Codes__c> countryNameCodes = Country_Codes__c.getall();
        Map<String, String> projNameVsSocityId = new Map<String, String>();
        for(Society_Id__mdt rec : socityIds){
            projNameVsSocityId.put(rec.Label, rec.Value__c);
        }
        
        List<Opportunity> opps = [SELECT Id, Name, AccountId, Account.FirstName, Account.LastName, Account.PersonEmail,Account.RW_Country__c,
                           Account.Mobile_No__c, Account.Ownership, RW_Project_Unit__r.RW_Param4__c,  Account.Country_Code__c,
                           RW_Project_Unit__r.RW_Param2__c, SAP_Customer_Number__c, Booking__c, RW_Project__r.Name, RW_Project_Unit__c
                           FROM Opportunity WHERE Booking__c =: bkgIds AND StageName = 'Unit Booked'];
        //List<String> bkgIds = new List<String>();
        Map<String, String> bkgIdVsOppId = new Map<String, String>();
        for(Opportunity opp : opps){
            bkgIds.add(opp.Booking__c);
            bkgIdVsOppId.put(opp.Booking__c, opp.Id);
        }
        
        List<Applicant_Details__c> applicants = [SELECT Id,Applicant_Number__c,Booking__c,Booking__r.Opportunity__c,First_Name__c,Last_Name__c,Mobile_Number__c,Secondary_Mobile_Number__c,Email_Address__c FROM Applicant_Details__c WHERE Booking__c =: bkgIds];
        Map<String, List<Applicant_Details__c>> oppIdVsCoApplicantsMap = new Map<String, List<Applicant_Details__c>>();
        Map<String, Applicant_Details__c> oppIdVsPrimaryApplicant = new Map<String, Applicant_Details__c>();
        for(Applicant_Details__c app : applicants){
            if(app.Applicant_Number__c == 'Primary Applicant'){
                if(!oppIdVsPrimaryApplicant.containsKey(app.Booking__r.Opportunity__c)){
                    oppIdVsPrimaryApplicant.put(app.Booking__r.Opportunity__c, app);
                }
            }else{
                if(oppIdVsCoApplicantsMap.containsKey(app.Booking__r.Opportunity__c)){
                    oppIdVsCoApplicantsMap.get(app.Booking__r.Opportunity__c).add(app);
                }else{
                    oppIdVsCoApplicantsMap.put(app.Booking__r.Opportunity__c, new List<Applicant_Details__c>{app});
                }
            }
            
        }
        
         List<ERP_Integration_Log__c> logList = new List<ERP_Integration_Log__c>();
        for(Opportunity opp : opps){
            ERP_Integration_Log__c log = new ERP_Integration_Log__c();
            try{
                HttpRequest request = new HttpRequest();
                HttpResponse response = new HttpResponse();
                Http http = new Http();
                
                JSONGenerator generator = JSON.createGenerator(true);
                generator.writeStartObject();
                generator.writeStringField('account_id', opp.AccountId);
                generator.writeStringField('firstname', oppIdVsPrimaryApplicant.get(opp.Id).First_Name__c);
                generator.writeStringField('lastname', oppIdVsPrimaryApplicant.get(opp.Id).Last_Name__c);
                generator.writeStringField('primary_number', oppIdVsPrimaryApplicant.get(opp.Id).Mobile_Number__c);
                generator.writeStringField('email', oppIdVsPrimaryApplicant.get(opp.Id).Email_Address__c);
                generator.writeStringField('secondary_number', (oppIdVsPrimaryApplicant.get(opp.Id).Secondary_Mobile_Number__c != null)? oppIdVsPrimaryApplicant.get(opp.Id).Secondary_Mobile_Number__c : '');
                if(opp.RW_Project_Unit__c != null){
                    generator.writeStringField('flat', opp.RW_Project_Unit__r.RW_Param4__c);
                    generator.writeStringField('tower', opp.RW_Project_Unit__r.RW_Param2__c);
                }
                generator.writeStringField('customer_code', opp.SAP_Customer_Number__c);
                generator.writeStringField('booking_number', opp.Booking__c);
                generator.writeStringField('society_id', projNameVsSocityId.get(opp.RW_Project__r.Name));
                generator.writeStringField('country_code', (opp.Account.Country_Code__c != null)? opp.Account.Country_Code__c : '+91');
                if(opp.Account.RW_Country__c != null && countryNameCodes.get(opp.Account.RW_Country__c) != null){
                    generator.writeStringField('country_code_name', countryNameCodes.get(opp.Account.RW_Country__c).Code__c.toLowerCase());
                }else{
                   generator.writeStringField('country_code_name','in');
                }
                generator.writeStringField('status','1');
                generator.writeStringField('ownership', (opp.Account.Ownership != null)? opp.Account.Ownership : '');
                generator.writeStringField('is_primary','1');
                generator.writeFieldName('co_applicants');
                generator.writeStartArray();
                if(oppIdVsCoApplicantsMap.get(opp.Id) != null && oppIdVsCoApplicantsMap.get(opp.Id) != null){
                    for(Applicant_Details__c app : oppIdVsCoApplicantsMap.get(opp.Id)){
                        generator.writeStartObject();
                        generator.writeStringField('firstname', app.First_Name__c);
                        generator.writeStringField('lastname', app.Last_Name__c);
                        generator.writeStringField('primary_number', app.Mobile_Number__c);
                        generator.writeStringField('email', app.Email_Address__c);
                        generator.writeStringField('secondary_number', (oppIdVsPrimaryApplicant.get(opp.Id).Secondary_Mobile_Number__c != null)? oppIdVsPrimaryApplicant.get(opp.Id).Secondary_Mobile_Number__c : '');
                        generator.writeEndObject();
                    }
                }
                
                generator.writeEndArray();
                generator.writeEndObject();
        
                String jsonString = generator.getAsString();
                System.debug('jsonString: ' + jsonString);
                
                request.setEndpoint('https://uat-hi-society.lockated.com/runwal_add_user_sap.json?token=zffEgnJyTg8HycShPS3hYcE53Zpu1abCKUQUD9o06sk');
                request.setHeader('Content-Type', 'application/json');
                request.setMethod('POST');
                //request.setHeader('Authorization', '0d93e348a9262bc36c2eb86612f119abe803f368ad503eb9');
                request.setTimeout(120000);
                //request.setBody(JSON.Serialize(jsonString));
                request.setBody(jsonString);
                response = http.send(request);
                 System.debug('Response: ' + response);
                if(response.getStatusCode() == 200){
                    System.debug('Response: ' + response);
                }else{
                    log.API_Name__c = 'User Creation/Delete';
                    log.Opportunity__c = opp.Id;
                    log.Request__c = jsonString;
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
    
    
    @future(callout=true)
    public static void createuserWhenApplicantCreated(List<Id> applicantIds){
        
        List<Applicant_Details__c> applicants = [SELECT Id,Applicant_Number__c,Booking__c,Booking__r.Opportunity__c,First_Name__c,Last_Name__c,Mobile_Number__c,Secondary_Mobile_Number__c,Email_Address__c FROM Applicant_Details__c WHERE Id =: applicantIds AND Booking__r.Opportunity__r.StageName = 'Unit Booked'];
        if(applicants.size() > 0){
            List<Society_Id__mdt> socityIds = [SELECT Id, Label, Value__c FROM Society_Id__mdt];
            Map<String, Country_Codes__c> countryNameCodes = Country_Codes__c.getall();
            Map<String, String> projNameVsSocityId = new Map<String, String>();
            for(Society_Id__mdt rec : socityIds){
                projNameVsSocityId.put(rec.Label, rec.Value__c);
            }
            System.debug('applicantIds: ' + applicantIds);
            
            Map<String, List<Applicant_Details__c>> bkgIdVsCoApplicantsMap = new Map<String, List<Applicant_Details__c>>();
            Map<String, Applicant_Details__c> bkgIdVsPrimaryApplicant = new Map<String, Applicant_Details__c>();
            List<Id> bkgIds = new List<Id>();
            for(Applicant_Details__c app : applicants){
                bkgIds.add(app.Booking__c);
                if(app.Applicant_Number__c == 'Primary Applicant'){
                    if(!bkgIdVsPrimaryApplicant.containsKey(app.Booking__c)){
                        bkgIdVsPrimaryApplicant.put(app.Booking__c, app);
                    }
                }else{
                    if(bkgIdVsCoApplicantsMap.containsKey(app.Booking__c)){
                        bkgIdVsCoApplicantsMap.get(app.Booking__c).add(app);
                    }else{
                        bkgIdVsCoApplicantsMap.put(app.Booking__c, new List<Applicant_Details__c>{app});
                    }
                }
                
            }
            
            List<ERP_Integration_Log__c> logList = new List<ERP_Integration_Log__c>();
            for(Booking__c bkg : [SELECT Id,Opportunity__r.AccountId FROM Booking__c WHERE Id =: bkgIds]){
                ERP_Integration_Log__c log = new ERP_Integration_Log__c();
                try{
                    HttpRequest request = new HttpRequest();
                    HttpResponse response = new HttpResponse();
                    Http http = new Http();
                    
                    JSONGenerator generator = JSON.createGenerator(true);
                    generator.writeStartObject();
                    generator.writeStringField('account_id', bkg.Opportunity__r.AccountId);
                    generator.writeStringField('firstname', bkgIdVsPrimaryApplicant.get(bkg.Id).First_Name__c);
                    generator.writeStringField('lastname', bkgIdVsPrimaryApplicant.get(bkg.Id).Last_Name__c);
                    generator.writeStringField('primary_number', bkgIdVsPrimaryApplicant.get(bkg.Id).Mobile_Number__c);
                    generator.writeStringField('email', bkgIdVsPrimaryApplicant.get(bkg.Id).Email_Address__c);
                    generator.writeStringField('secondary_number', (bkgIdVsPrimaryApplicant.get(bkg.Id).Secondary_Mobile_Number__c != null)? bkgIdVsPrimaryApplicant.get(bkg.Id).Secondary_Mobile_Number__c : '');
                    if(bkg.Unit_No__c != null){
                        generator.writeStringField('flat', bkg.Unit_No__r.RW_Param4__c);
                        generator.writeStringField('tower', bkg.Unit_No__r.RW_Param2__c);
                    }
                    generator.writeStringField('customer_code', bkg.Opportunity__r.SAP_Customer_Number__c);
                    generator.writeStringField('booking_number', bkg.Id);
                    generator.writeStringField('society_id', projNameVsSocityId.get(bkg.Project__r.Name));
                    generator.writeStringField('country_code', (bkg.Opportunity__r.Account.Country_Code__c != null)? bkg.Opportunity__r.Account.Country_Code__c : '+91');
                    if(bkg.Opportunity__r.Account.RW_Country__c != null && countryNameCodes.get(bkg.Opportunity__r.Account.RW_Country__c) != null){
                        generator.writeStringField('country_code_name', countryNameCodes.get(bkg.Opportunity__r.Account.RW_Country__c).Code__c.toLowerCase());
                    }else{
                        generator.writeStringField('country_code_name','in');
                    }
                    generator.writeStringField('status','1');
                    generator.writeStringField('ownership', (bkg.Opportunity__r.Account.Ownership != null)? bkg.Opportunity__r.Account.Ownership : '');
                    generator.writeStringField('is_primary','1');
                    generator.writeFieldName('co_applicants');
                    generator.writeStartArray();
                    if(bkgIdVsCoApplicantsMap.get(bkg.Id) != null && bkgIdVsCoApplicantsMap.get(bkg.Id) != null){
                        for(Applicant_Details__c app : bkgIdVsCoApplicantsMap.get(bkg.Id)){
                            generator.writeStartObject();
                            generator.writeStringField('firstname', app.First_Name__c);
                            generator.writeStringField('lastname', app.Last_Name__c);
                            generator.writeStringField('primary_number', app.Mobile_Number__c);
                            generator.writeStringField('email', app.Email_Address__c);
                            generator.writeStringField('secondary_number', (bkgIdVsPrimaryApplicant.get(bkg.Id).Secondary_Mobile_Number__c != null)? bkgIdVsPrimaryApplicant.get(bkg.Id).Secondary_Mobile_Number__c : '');
                            generator.writeEndObject();
                        }
                    }
                    
                    generator.writeEndArray();
                    generator.writeEndObject();
                    
                    String jsonString = generator.getAsString();
                    System.debug('jsonString: ' + jsonString);
                    
                    request.setEndpoint('https://uat-hi-society.lockated.com/runwal_add_user_sap.json?token=zffEgnJyTg8HycShPS3hYcE53Zpu1abCKUQUD9o06sk');
                    request.setHeader('Content-Type', 'application/json');
                    request.setMethod('POST');
                    //request.setHeader('Authorization', '0d93e348a9262bc36c2eb86612f119abe803f368ad503eb9');
                    request.setTimeout(120000);
                    //request.setBody(JSON.Serialize(jsonString));
                    request.setBody(jsonString);
                    response = http.send(request);
                    System.debug('Response: ' + response);
                    if(response.getStatusCode() == 200){
                        System.debug('Response: ' + response);
                    }else{
                        log.API_Name__c = 'User Creation/Delete';
                        log.Opportunity__c = bkg.Opportunity__c;
                        log.Request__c = jsonString;
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
    }
}