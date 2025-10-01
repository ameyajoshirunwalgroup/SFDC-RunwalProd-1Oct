public without sharing class UpdateMobileAndEmailController {
	
    @AuraEnabled
    public static Opportunity oppRecord(String recId){
        Opportunity opp = [SELECT Id, RW_Mobile_No__c, RW_Secondary_Mobile_No__c, RW_Email__c, RW_Secondary_Email__c, Account.Country_Code_2__c,
                           Account.Dialing_Country_2__c, Secondary_Mobile_No_Masked__c, Mobile_Number__c, Account.Country_Code__c FROM Opportunity WHERE Id =: recId];
        return opp;
    }
    
    @AuraEnabled
    public static List<String> getCountryCodeList(){
       List<String> countryCodeValuesList= new List<String>();
		//Schema.DescribeFieldResult fieldResult = Account.Country_Code_2__c.getDescribe();
        Schema.DescribeFieldResult fieldResult = Account.Country_Code__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			countryCodeValuesList.add(pickListVal.getValue());
		}     
		return countryCodeValuesList;
    }
    
    @AuraEnabled
    public static List<String> getSecondaryCountryCodeList(){
       List<String> countryCodeValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = Account.Country_Code_2__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			countryCodeValuesList.add(pickListVal.getValue());
		}     
		return countryCodeValuesList;
    }
    
    @AuraEnabled
    public static List<String> getDialingCountryList(){
       List<String> dialingCountryValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = Account.Dialing_Country_2__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			dialingCountryValuesList.add(pickListVal.getLabel());
		}     
		return dialingCountryValuesList;
    }
    
    @AuraEnabled
    public static void updateMobileNumber(Id recId, String mobNum, String secMobNum, String countryCode, String dailingCountry, String email, String secEmail, String secCountryCode){
        
        Opportunity opp = [SELECT Id, Name, Overall_CRM_Head__c, RW_Project__r.Overall_CRM_Head__c,TL_Name__c FROM Opportunity WHERE Id =: recId];
        
        List<Applicant_Details__c> apps = new List<Applicant_Details__c>();
        if((mobNum != null && mobNum != '') || (secMobNum != null && secMobNum != '') || (email != null && email != '')){
            apps = [SELECT Id, Opportunity__c, Send_Applicant_Update_To_SAP__c FROM Applicant_Details__c WHERE Opportunity__c =: opp.Id AND Applicant_Number__c = 'Primary Applicant']; //Added by coServe 20-06-2024
        }
        //List<Applicant_Details__c> apps = [SELECT Id, Opportunity__c, Send_Applicant_Update_To_SAP__c FROM Applicant_Details__c WHERE Opportunity__c =: opp.Id AND Applicant_Number__c = 'Primary Applicant']; //Added by coServe 20-06-2024
        
        
        //Opportunity opp = new Opportunity();
        //opp.Id = recId;
        if(mobNum != null && mobNum != ''){
            opp.Temp_Mobile__c = mobNum;
        }
        if(secMobNum != null && secMobNum != ''){
            opp.Temp_Secondary_Mobile__c = secMobNum;
        }
        if(email != null && email != ''){
            opp.Temp_Email__c = email;
        }
        if(secEmail != null && secEmail != ''){
            opp.Temp_Secondary_Email__c = secEmail;
        }
        if(countryCode != null && countryCode != ''){
            opp.Temp_Country_Code__c = countryCode;
        }
        if(dailingCountry != null && dailingCountry != ''){
            opp.Temp_Dialing_Country__c = dailingCountry;
        }
        
        if(opp.Overall_CRM_Head__c == null){
            opp.Overall_CRM_Head__c = opp.RW_Project__r.Overall_CRM_Head__c;
        }
        list<String> updateTLonOppsIds = new list<String>();       
          if(opp.TL_Name__c == null){
            updateTLonOppsIds.add(opp.Id);            
        }
        if(!updateTLonOppsIds.isEmpty()){
            system.debug('Inside updateTLonOppsIds');
            updateTLonOpportunity(updateTLonOppsIds);
        }
        
        if(secCountryCode != null && secCountryCode != ''){
            opp.Temp_Secondary_Country_Code__c = secCountryCode;
        }
        update opp;
        if(apps.size() > 0){
            System.debug('apps[0].Send_Applicant_Update_To_SAP__c: ' + apps[0].Send_Applicant_Update_To_SAP__c);
            if(apps[0].Send_Applicant_Update_To_SAP__c == true){ //Added by coServe 20-06-2024
                System.debug('apps[0].Send_Applicant_Update_To_SAP__c: ' + apps[0].Send_Applicant_Update_To_SAP__c);
                apps[0].Send_Applicant_Update_To_SAP__c = false;
                update apps[0];
            }
        }
        
        try{
            Approval.ProcessSubmitRequest req = New Approval.ProcessSubmitRequest();
            req.setComments('Submitting request for approval.');
            req.setObjectId(opp.id);
            req.setProcessDefinitionNameOrId('Update_Mobile_And_Email_Latest');
            req.setSkipEntryCriteria(true);
            Approval.ProcessResult result = Approval.process(req);
            Approval.unlock(opp.Id);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    /*public static void updateTLonOpportunity(List<String> oppIds){
        //Added by Prashant for getting TL user for the record
        list<Opportunity> opps = [Select Id,RW_Project_Unit__r.Relationship_Manager__r.User__c from Opportunity where Id IN: oppIds];
        list<Opportunity> oppstoUpdate = new list<Opportunity>(); 
        if(!opps.isEmpty()){
            for(Opportunity opp: opps){
                if(opp.RW_Project_Unit__r.Relationship_Manager__r.User__c != null){
                    system.debug('RM---->>>>>'+opp.RW_Project_Unit__r.Relationship_Manager__r.User__c);
                    list<User> ulist = [Select Id,ManagerId from User where Id =: opp.RW_Project_Unit__r.Relationship_Manager__r.User__c];
                    if(ulist[0].ManagerId != null){
                        system.debug('Manager - TL --->>>>'+ulist[0].ManagerId);
                        opp.TL_Name__c = ulist[0].ManagerId;
                        oppstoUpdate.add(opp);
                    }
                }
            }
        }
        if(!oppstoUpdate.isEmpty()){
            try{
                update oppstoUpdate;
            }catch(Exception e){
                system.debug('Error while updating Opportunity : '+e.getMessage());
            }
        }
        
    }*/	
    
    //Added by Prashant to update TL on Opportunity for Mobile and email Approval
    /*public static void updateTLonOpportunity(String RMName,Id oppId){        
        //list<Opportunity> opps = [Select Id,RW_Project_Unit__r.Relationship_Manager__r.User__c from Opportunity where Id IN: oppIds];
         list<User> RMUser = [Select Id,ManagerId from User where Name = : RMName];
        list<Opportunity> oppstoUpdate = new list<Opportunity>(); 
        if(!RMUser.isEmpty()){
            if(RMUser[0].ManagerId != null){
                system.debug('Manager - TL --->>>>'+RMUser[0].ManagerId);
                Opportunity opp = new Opportunity();
                opp.TL_Name__c = RMUser[0].ManagerId;
                opp.Id = oppId;
                oppstoUpdate.add(opp);
            }
        }
        if(!oppstoUpdate.isEmpty()){
            try{
                update oppstoUpdate;
            }catch(Exception e){
                system.debug('Error while updating Opportunity : '+e.getMessage());
            }
        }
        
    }*/
    
    //Added by Prashant to update TL on Opportunity for Mobile and email Approval
    public static void updateTLonOpportunity(List<String> oppIds){
        //Added by Prashant for getting TL user for the record
        list<Opportunity> opps = [Select Id,RW_RM_Name__c from Opportunity where Id IN: oppIds];
        list<Opportunity> oppstoUpdate = new list<Opportunity>();
        list<User> RMUser = [Select Id,ManagerId from User where Id =: UserInfo.getUserId()];
        if(!opps.isEmpty()){
            for(Opportunity opp: opps){
                
                if(!RMUser.isEmpty()){
                    if(RMUser[0].ManagerId != null){
                        system.debug('Manager - TL --->>>>'+RMUser[0].ManagerId);
                        Opportunity opp1 = new Opportunity();
                        opp1.TL_Name__c = RMUser[0].ManagerId;
                        opp1.Id = opp.Id;
                        oppstoUpdate.add(opp1);
                    }
                }
            }
        }
        if(!oppstoUpdate.isEmpty()){
            try{
                system.debug('Update Opp');
                update oppstoUpdate;
            }catch(Exception e){
                system.debug('Error while updating Opportunity : '+e.getMessage());
            }
        }
        
    }
    
    
    
    public static void updateOriginalFields(List<String> oppIds){
        List<String> accIds = new List<String>();
        //List<String> oppIds = new List<String>();
        Map<String, Map<String,String>> accDetMap = new Map<String, Map<String,String>>();
        Boolean updateApplicant = false;
        
        List<Opportunity> opps = [SELECT Id, Name, AccountId, Temp_Email__c, Temp_Country_Code__c, Temp_Dialing_Country__c, Temp_Mobile__c, 
                                  Temp_Secondary_Email__c, Temp_Secondary_Mobile__c, Temp_Secondary_Country_Code__c FROM Opportunity WHERE Id =: oppIds];
        
        for(Opportunity opp : opps){
            //oppIds.add(opp.Id);
            accIds.add(opp.AccountId);
        }
        Map<String, Applicant_Details__c> appMap = new Map<String, Applicant_Details__c>();
        List<Applicant_Details__c> apps = [SELECT Id, Opportunity__c FROM Applicant_Details__c WHERE Opportunity__c =: oppIds AND Applicant_Number__c = 'Primary Applicant'];
        for(Applicant_Details__c app : apps){
            appMap.put(app.Opportunity__c, app);
        }
        
        Map<String, Account> oppIdVsAccMap = new Map<String, Account>();
        Map<Id,Account> accMap = new Map<Id, Account>([SELECT Id FROM Account WHERE Id =: accIds]);
        
        for(Opportunity opp : opps){
            oppIdVsAccMap.put(opp.Id, accMap.get(opp.AccountId));
        }
        
        for(Opportunity opp : opps){
            accIds.add(opp.AccountId);
            accDetMap.put(opp.AccountId, new Map<String,String>());
            if(opp.Temp_Email__c != null && opp.Temp_Email__c != ''){
                opp.RW_Email__c = opp.Temp_Email__c;
                accDetMap.get(opp.AccountId).put('Temp_Email__c', opp.Temp_Email__c);
                if(appMap.get(opp.Id) != null){
                    appMap.get(opp.Id).Email_Address__c = opp.Temp_Email__c;
                    appMap.get(opp.Id).Send_Applicant_Update_To_SAP__c = true; //Added by coServe 21-06-2024
                    updateApplicant = true;
                }
                oppIdVsAccMap.get(opp.Id).RW_Email__c = opp.Temp_Email__c;
                oppIdVsAccMap.get(opp.Id).PersonEmail = opp.Temp_Email__c;
                opp.Temp_Email__c = null;
                
            }
            if(opp.Temp_Mobile__c != null && opp.Temp_Mobile__c != ''){
                opp.RW_Mobile_No__c = opp.Temp_Mobile__c;
                accDetMap.get(opp.AccountId).put('Temp_Mobile__c', opp.Temp_Mobile__c);
                if(appMap.get(opp.Id) != null){
                    appMap.get(opp.Id).Mobile_Number__c = opp.Temp_Mobile__c;
                    appMap.get(opp.Id).Send_Applicant_Update_To_SAP__c = true; //Added by coServe 21-06-2024
                    updateApplicant =true;
                }
                oppIdVsAccMap.get(opp.Id).Mobile_No__c = opp.Temp_Mobile__c;
                opp.Temp_Mobile__c = null;
            }
            if(opp.Temp_Secondary_Email__c != null && opp.Temp_Secondary_Email__c != ''){
                opp.RW_Secondary_Email__c = opp.Temp_Secondary_Email__c;
                accDetMap.get(opp.AccountId).put('Temp_Secondary_Email__c', opp.Temp_Secondary_Email__c);
                oppIdVsAccMap.get(opp.Id).RW_Secondary_Email__pc = opp.Temp_Secondary_Email__c;
                opp.Temp_Secondary_Email__c = null;
            }
            if(opp.Temp_Secondary_Mobile__c != null && opp.Temp_Secondary_Mobile__c != ''){
                opp.RW_Secondary_Mobile_No__c = opp.Temp_Secondary_Mobile__c;
                accDetMap.get(opp.AccountId).put('Temp_Secondary_Mobile__c', opp.Temp_Secondary_Mobile__c);
                if(appMap.get(opp.Id) != null){
                    appMap.get(opp.Id).Secondary_Mobile_Number__c = opp.Temp_Secondary_Mobile__c;
                    appMap.get(opp.Id).Send_Applicant_Update_To_SAP__c = true; //Added by coServe 21-06-2024
                    updateApplicant = true;
                }
                oppIdVsAccMap.get(opp.Id).RW_Secondary_Mobile_No__pc = opp.Temp_Secondary_Mobile__c;
                opp.Temp_Secondary_Mobile__c = null;
            }
            if(opp.Temp_Country_Code__c != null && opp.Temp_Country_Code__c != '' && opp.Temp_Country_Code__c != 'None'){
                accDetMap.get(opp.AccountId).put('Temp_Country_Code__c', opp.Temp_Country_Code__c);
                oppIdVsAccMap.get(opp.Id).Country_Code__c = opp.Temp_Country_Code__c;
                opp.Temp_Country_Code__c = null;
            }
            if(opp.Temp_Secondary_Country_Code__c != null && opp.Temp_Secondary_Country_Code__c != '' && opp.Temp_Secondary_Country_Code__c != 'None'){
                accDetMap.get(opp.AccountId).put('Temp_Secondary_Country_Code__c', opp.Temp_Secondary_Country_Code__c);
                oppIdVsAccMap.get(opp.Id).Country_Code_2__c = opp.Temp_Secondary_Country_Code__c;
                opp.Temp_Secondary_Country_Code__c = null;
            }
            /*if(opp.Temp_Dialing_Country__c != null && opp.Temp_Dialing_Country__c != '' && opp.Temp_Dialing_Country__c != 'None'){
                accDetMap.get(opp.AccountId).put('Temp_Dialing_Country__c', opp.Temp_Dialing_Country__c);
                oppIdVsAccMap.get(opp.Id).Dialing_Country_2__c = opp.Temp_Dialing_Country__c;
                opp.Temp_Dialing_Country__c = null;
            }*/
        }
        
        update opps;
        update oppIdVsAccMap.values();
        if(updateApplicant){
            update appMap.values();
        }
        
        /*List<Account> accToUpdate = new List<Account>();
        System.debug('accDetMap: ' + accDetMap);
        for(String accId : accIds){
            Account acc = new Account();
            acc.Id = accId;
            if(accDetMap.get(accId).get('Temp_Mobile__c') != null){
                acc.Mobile_No__c = accDetMap.get(accId).get('Temp_Mobile__c');
            }
            if(accDetMap.get(accId).get('Temp_Secondary_Mobile__c') != null){
                acc.RW_Secondary_Mobile_No__pc = accDetMap.get(accId).get('Temp_Secondary_Mobile__c');
            }
            if(accDetMap.get(accId).get('Temp_Email__c') != null){
                acc.RW_Email__c = accDetMap.get(accId).get('Temp_Email__c');
            }
            if(accDetMap.get(accId).get('Temp_Secondary_Email__c') != null){
                acc.RW_Secondary_Email__pc = accDetMap.get(accId).get('Temp_Secondary_Email__c');
            }
            if(accDetMap.get(accId).get('Temp_Country_Code__c') != null && accDetMap.get(accId).get('Temp_Country_Code__c') != 'None'){
                acc.Country_Code_2__c = accDetMap.get(accId).get('Temp_Country_Code__c');
            }
            if(accDetMap.get(accId).get('Temp_Dialing_Country__c') != null && accDetMap.get(accId).get('Temp_Dialing_Country__c') != 'None'){
                acc.Dialing_Country_2__c = accDetMap.get(accId).get('Temp_Dialing_Country__c');
            }
            accToUpdate.add(acc);
        }
        update accToUpdate;*/
    }
    
    public static void clearTempFields(List<String> oppIds){
        List<Opportunity> opps = [SELECT Id, Name, AccountId, Temp_Email__c, Temp_Country_Code__c, Temp_Dialing_Country__c, Temp_Mobile__c, 
                                  Temp_Secondary_Email__c, Temp_Secondary_Mobile__c FROM Opportunity WHERE Id =: oppIds];
        
        for(Opportunity opp : opps){
            opp.Temp_Country_Code__c = null;
            opp.Temp_Dialing_Country__c = null;
            opp.Temp_Email__c = null;
            opp.Temp_Mobile__c = null;
            opp.Temp_Secondary_Email__c = null;
            opp.Temp_Secondary_Mobile__c = null;
            opp.Temp_Secondary_Country_Code__c = null;
        }
        update opps;
    }

}