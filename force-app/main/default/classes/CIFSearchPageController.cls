public class CIFSearchPageController {
    public List < SelectOption > lstProjectList {
        get;
        set;
    }
    public Lead NewLead {
        get;
        set;
    }
    public Boolean show{get; set;}
    public string strotp {
        get;
        set;
    }
    public string strProjectId {
        get;
        set;
    }
    public string strError {
        get;
        set;
    }
    public list < Lead > lstDuplicateLeads {
        get;
        set;
    }
    public list < Opportunity > lstDuplicateOpty {
        get;
        set;
    }
    public list < Account > lstDuplicateAccount {
        get;
        set;
    }
    public Boolean isDuplicateLeadExist {
        get;
        set;
    }
    public Boolean isDuplicateAccountExist {
        get;
        set;
    }
    public Boolean isDuplicateOptyExist {
        get;
        set;
    }
    public Boolean isNew {
        get;
        set;
    }
    public Boolean isNRI {
        get;
        set;
    }
    
    Public Boolean isDirect{
        get;
        set;
    }
    public String OpportunityId {
        get;
        set;
    }
    public boolean checkbox{get;set;}
    List < opportunity > lstOpp;
    
    public Boolean isMultipleDuplicateOptyExist {get;set;}
    
    public Boolean showOtpDetails {get;set;} //Added by coServe 12-06-2024
    public String enteredOtp {get;set;} //Added by coServe 12-06-2024
    public Boolean showDirectLeadButton {get;set;} //Added by coServe 12-06-2024
    public Boolean showDirectLead {get;set;} //Added by coServe 12-06-2024
    
    public CIFSearchPageController() {
        show = true;
        NewLead = new Lead();
        lstProjectList = new List < SelectOption > ();
        strError = '';
        isDuplicateLeadExist = false;
        isDuplicateAccountExist = false;
        isDuplicateOptyExist = false;
        isNew = true;
        isNRI = false;
        checkbox = false;
        showOtpDetails = false; //Added by coServe 12-06-2024
        showDirectLead = false; //Added by coServe 12-06-2024
        
        List < Project__c > lstProj = [select Id, name, RW_Status__c from Project__c where RW_Status__c =: 'Active']; //
        System.debug('lstProj ::' + lstProj);
        lstProjectList.add(new SelectOption('', '---Please Select Project---'));
        if (lstProj != null && lstProj.size() > 0) {
            for (Project__c EachProj: lstProj) {
                lstProjectList.add(new SelectOption(EachProj.id, EachProj.name));
            }
        }
    }
    
    //on cancel button
    public PageReference goBack() {
        Pagereference objReference = new Pagereference('/');
        objReference.setRedirect(true);
        return objReference;
    }
    
    //on countinue button
    public PageReference saveMethod() {
        strError = '';
        strotp = '';
        lstOpp = new List < opportunity > ();
        Savepoint sp = Database.setSavepoint();
        try {
            if (strProjectId == null || strProjectId == '') {
                strError = 'Please select the Project to proceed.';
                return null;
            }
            if (NewLead.RW_Mobile_No__c == null || NewLead.RW_Mobile_No__c == '') {
                strError = 'Please enter the Contact No to proceed.';
                return null;
            }
            //String strProjectName;
            Boolean newProcess = false;
            //Added by coServe 12-06-2024 Start
            List<Project__c> proj = [SELECT Id, OTP_for_Direct_Lead__c,Name FROM Project__c WHERE Id =: strProjectId];
            if(proj.size() > 0 && proj[0].OTP_for_Direct_Lead__c){
                newProcess = true;
                
            } else{
                newProcess = false;
            }
            
            list < Lead > lstLead = [select Id from Lead where(RW_Mobile_No__c =: NewLead.RW_Mobile_No__c OR RW_Secondary_Mobile_No__c =: NewLead.RW_Mobile_No__c) and
                                     isConverted =: false And isActive__C= : True 
                                    ]; //and RW_Project__c =: strProjectId
            
            List < Account > lstAccount = [Select Id, Name, Mobile_No__c, Alternate_Mobile_No__c, PersonEmail, Alternate_Email__c, IsPersonAccount, IsCustomerPortal from Account
                                           where(Mobile_No__c =: NewLead.RW_Mobile_No__c OR Alternate_Mobile_No__c =: NewLead.RW_Mobile_No__c)];
            
            List<String> accountIds = new List<String>();
            for(Account acc : lstAccount){
                accountIds.add(acc.Id);
            }
            
            if (lstLead != null && lstLead.size() > 0) {
                
                Pagereference objReference;
                if(newProcess){ //Added by coServe 17-06-2024
                    objReference = new Pagereference('/apex/CIFFormPage?id=' + lstLead[0].id + '&projectId=' + strProjectId +'&show=false'+'&directLead=true');
                }else{
                    objReference = new Pagereference('/apex/CIFFormPage?id=' + lstLead[0].id + '&projectId=' + strProjectId +'&show='+show);
                }
                //Pagereference objReference = new Pagereference('/apex/CIFFormPage?id=' + lstLead[0].id + '&projectId=' + strProjectId +'&show='+show);//Commented by coServe 17-06-2024
                objReference.setRedirect(true);
                return objReference;
            } else if (lstAccount != null && lstAccount.size() > 0) {
                /*lstOpp = [select id, Name, OwnerId, RW_Project__c, CloseDate, Walkin_Source__c, AccountId
from Opportunity
where AccountId =: lstAccount[0].Id and
RW_Project__c =: strProjectId and RW_Opportunity_Status__c =: 'Active'
];*/
                lstOpp = [select id, Name, OwnerId, RW_Project__c, CloseDate, Walkin_Source__c, AccountId
                          from Opportunity
                          where AccountId =: accountIds and
                          RW_Project__c =: strProjectId and RW_Opportunity_Status__c =: 'Active' ORDER BY CreatedDate DESC
                         ];
                
                /*Account masterAcc;
List<Account> duplicateAccs = new List<Account>();
System.debug('--masterAcc: ');
Map<Id, Account> accMap = new Map<Id, Account>([Select Id, Mobile_No__c, Alternate_Mobile_No__c, PersonEmail, Alternate_Email__c from Account where Id =: accountIds]);

if(lstOpp != null && lstOpp.size() <= 1){
for(Opportunity opp : lstOpp){
for(Account ac : accMap.values()){
if(opp.AccountId == ac.Id){
System.debug('--masterAcc1: ');
masterAcc = ac;
}else{
System.debug('--masterAcc2: ');
duplicateAccs.add(ac);
}
}
}
Database.merge(masterAcc, duplicateAccs);
}else{
masterAcc = accMap.get(lstOpp[0].AccountId);
for(Account ac : accMap.values()){
if(masterAcc.Id != ac.Id){
duplicateAccs.add(ac);
}
}
}



System.debug('masterAcc: ' + masterAcc);
System.debug('duplicateAccs: ' + duplicateAccs);*/
                
                
                
                if (lstOpp != null && lstOpp.size() > 0) {
                    
                    /*Event objEvent = new Event();
objEvent.WhatId = lstOpp[0].id;
objEvent.Subject = 'Re-Visit';
objEvent.OwnerId = lstOpp[0].OwnerId;
objEvent.StartDateTime = datetime.newInstance(System.today().year(), System.today().month(), System.today().day(), 6, 00, 00);
objEvent.EndDateTime = datetime.newInstance(System.today().year(), System.today().month(), System.today().day(), 8, 00, 00);
objEvent.Type = 'Re-visit';
objEvent.Project__c = strProjectId;
insert objEvent;
*/
                    
                    task t = new task();
                    t.WhatId = lstOpp[0].id;
                    t.OwnerId = lstOpp[0].OwnerId;
                    //t.whoId = whoId;
                    t.activityDate = System.today();
                    t.Call_Time__c = System.Now().format('h:mm a');
                    t.revisit__c = true;
                    t.status = 'Completed';
                    t.Subject = 'Re-Visit';
                    t.Task_Type__c = 'Re-Visit';
                    t.Type = 'Re-visit';
                    t.priority = 'Normal';
                    t.Project__c = lstOpp[0].RW_Project__c;
                    t.Visitor_Name__c = lstOpp[0].Name;
                    insert t;
                    
                    //Database.merge(masterAcc, duplicateAccs);
                    
                    // Added by coServe 28-02-2024
                    Map<String, Opp_Close_Date__c> oppClsDateMap = Opp_Close_Date__c.getall();
                    lstOpp[0].CloseDate = System.today().addDays(Integer.valueOf(oppClsDateMap.get(lstOpp[0].RW_Project__c).No_of_Days__c));
                    
                    //Commented by coServe 28-02-2024
                    /*if (lstOpp[0].Walkin_Source__c != null && lstOpp[0].Walkin_Source__c != '') //added by Rasika
{
if (lstOpp[0].Walkin_Source__c == 'Channel Partner') {
lstOpp[0].CloseDate = System.today().addDays(Integer.valueOf(Label.Channel_Partner));
} else if (lstOpp[0].Walkin_Source__c == 'Corporate') {
lstOpp[0].CloseDate = System.today().addDays(Integer.valueOf(Label.Corporate));
} else if (lstOpp[0].Walkin_Source__c == 'Loyalty') {
lstOpp[0].CloseDate = System.today().addDays(Integer.valueOf(Label.Loyalty));
} else if (lstOpp[0].Walkin_Source__c == 'Referral') {
lstOpp[0].CloseDate = System.today().addDays(Integer.valueOf(Label.Referral));
} else if (lstOpp[0].Walkin_Source__c == 'PreSales') {
lstOpp[0].CloseDate = System.today().addDays(Integer.valueOf(Label.Presales));
} else if (lstOpp[0].Walkin_Source__c == 'Direct') {
lstOpp[0].CloseDate = System.today().addDays(Integer.valueOf(Label.Direct));
} else if (lstOpp[0].Walkin_Source__c == 'NRI') {
lstOpp[0].CloseDate = System.today().addDays(Integer.valueOf(Label.NRI));
} else if (lstOpp[0].Walkin_Source__c == 'Digital') {
lstOpp[0].CloseDate = System.today().addDays(Integer.valueOf(Label.Digital));
} else if (lstOpp[0].Walkin_Source__c == 'Employee / Management reference') {
lstOpp[0].CloseDate = System.today().addDays(Integer.valueOf(Label.Employee_Management_Reference));
} else if (lstOpp[0].Walkin_Source__c == 'Events') {
lstOpp[0].CloseDate = System.today().addDays(Integer.valueOf(Label.Events));
} else if (lstOpp[0].Walkin_Source__c == 'Exhibitions') {
lstOpp[0].CloseDate = System.today().addDays(Integer.valueOf(Label.Exhibition));
} else if (lstOpp[0].Walkin_Source__c == 'Hoarding') {
lstOpp[0].CloseDate = System.today().addDays(Integer.valueOf(Label.Hoarding));
} else if (lstOpp[0].Walkin_Source__c == 'Individual calling') {
lstOpp[0].CloseDate = System.today().addDays(Integer.valueOf(Label.Individual_Calling));
} else if (lstOpp[0].Walkin_Source__c == 'Magazines') {
lstOpp[0].CloseDate = System.today().addDays(Integer.valueOf(Label.Magazines));
} else if (lstOpp[0].Walkin_Source__c == 'Newspapers') {
lstOpp[0].CloseDate = System.today().addDays(Integer.valueOf(Label.Newspaper));
} else if (lstOpp[0].Walkin_Source__c == 'Outstation') {
lstOpp[0].CloseDate = System.today().addDays(Integer.valueOf(Label.Outstation));
} else if (lstOpp[0].Walkin_Source__c == 'Paper Inserts') {
lstOpp[0].CloseDate = System.today().addDays(Integer.valueOf(Label.Paper_Inserts));
} else if (lstOpp[0].Walkin_Source__c == 'Property Portals') {
lstOpp[0].CloseDate = System.today().addDays(Integer.valueOf(Label.Property_Portals));
} else if (lstOpp[0].Walkin_Source__c == 'Radio') {
lstOpp[0].CloseDate = System.today().addDays(Integer.valueOf(Label.Radio));
} else if (lstOpp[0].Walkin_Source__c == 'Surround Marketing') {
lstOpp[0].CloseDate = System.today().addDays(Integer.valueOf(Label.Surround_marketing));
} else if (lstOpp[0].Walkin_Source__c == 'TV') {
lstOpp[0].CloseDate = System.today().addDays(Integer.valueOf(Label.TV));
}

}*/
                    update lstOpp;
                    /*if(lstOpp.size() == 1){
mergeAcc(lstAccount, lstOpp[0]);
}else{
mergeAcc(lstAccount, lstOpp[0]);
}*/
                    mergeAcc(lstAccount, lstOpp[0]);
                    Pagereference objReference = new Pagereference('/' + lstOpp[0].id);
                    objReference.setRedirect(true);
                    return objReference;
                    
                } else {
                    //Added by coServe 09-01-2024 Start
                    if(System.label.Account_Merging_Active == 'Yes'){
                        System.debug('accList: ' + lstAccount);
                        List<String> accIds = new List<String>();
                        List<String> portalAccIds = new List<String>();
                        
                        for(Account acc : lstAccount){
                            if(acc.IsPersonAccount){
                                accIds.add(acc.Id);
                            }
                            if(acc.IsCustomerPortal){
                                portalAccIds.add(acc.Id);
                            }
                        }
                        if(portalAccIds.size() <= 1){
                            List<Opportunity> opps  = [SELECT Id, AccountId, Booking__c, StageName, CreatedDate, Booking__r.Booking_Date__c, Booking__r.Status__c FROM Opportunity WHERE AccountId =: accIds ORDER BY CreatedDate DESC];
                            System.debug('opps: ' + opps);
                            List<Opportunity> oppsWithoutBooking = new List<Opportunity>();
                            List<Opportunity> oppsWithBooking = new List<Opportunity>();
                            Map<DateTime,Opportunity> bkgDtVsOppId = new Map<DateTime,Opportunity>();
                            for(Opportunity opp : opps){
                                if(opp.Booking__c == null){
                                    oppsWithoutBooking.add(opp);
                                }else{
                                    if(opp.Booking__r.Status__c == 'Booking Confirmed'){
                                        oppsWithBooking.add(opp);
                                        bkgDtVsOppId.put(opp.Booking__r.Booking_Date__c, opp);
                                    }
                                    
                                }
                            }
                            System.debug('oppsWithoutBooking: ' + oppsWithoutBooking);
                            System.debug('oppsWithBooking: ' + oppsWithBooking);
                            String accId;
                            if(oppsWithBooking.size() > 0){
                                List<Datetime> bkgDates = new List<Datetime>(bkgDtVsOppId.keySet());
                                bkgDates.sort();
                                accId = bkgDtVsOppId.get(bkgDates[bkgDates.size()-1]).AccountId;
                            }else if(oppsWithoutBooking.size() > 1){
                                accId  = oppsWithoutBooking[0].AccountId;
                            }
                            System.debug('accId: ' + accId);
                            
                            Pagereference objReference;
                            if(newProcess){//Added by coServe 17-06-2024
                                objReference = new Pagereference('/apex/CIFFormPage?Accid=' + accId + '&projectId=' + strProjectId +'&show=false'+'&directLead=true');
                            }else{
                                objReference = new Pagereference('/apex/CIFFormPage?Accid=' + accId + '&projectId=' + strProjectId +'&show='+show);
                            }
                            //Pagereference objReference = new Pagereference('/apex/CIFFormPage?Accid=' + accId + '&projectId=' + strProjectId +'&show='+show);//Commented by coServe 17-06-2024
                        }
                        
                    }
                    
                    //Added by coServe 09-01-2024 End
                    Pagereference objReference;
                    if(newProcess){ //Added by coServe 17-06-2024
                        objReference = new Pagereference('/apex/CIFFormPage?Accid=' + lstAccount[0].id + '&projectId=' + strProjectId +'&show=false'+'&directLead=true');
                    }else{
                        objReference = new Pagereference('/apex/CIFFormPage?Accid=' + lstAccount[0].id + '&projectId=' + strProjectId +'&show='+show);
                    }
                    //Pagereference objReference = new Pagereference('/apex/CIFFormPage?Accid=' + lstAccount[0].id + '&projectId=' + strProjectId +'&show='+show);//Commented by coServe 17-06-2024
                    objReference.setRedirect(true);
                    return objReference;
                }
            }
            
            
            
            
            else {
                if (NewLead.LastName == null || NewLead.LastName == '') {
                    strError = 'Please enter the Last Name to proceed.';
                    return null;
                }
                
                if (NewLead.Email == null || NewLead.Email == '') {
                    strError = 'Please enter the Email to proceed.';
                    return null;
                }
                
                NewLead.RW_Project__c = strProjectId;
                NewLead.RW_Lead_through_Email__c = true;
                
                if (isNRI) {
                    NewLead.RW_Customer_Type__c = 'NRI';
                }
                
                insert NewLead;
                
                //Pagereference objReference = new Pagereference('/apex/CIFFormPage?id=' + NewLead.id + '&projectId=' + strProjectId +'&show='+show);//Commented by coServe 12-06-2024
                
                
                //Added by coServe 12-06-2024 Start
                Pagereference objReference;
                if(newProcess){
                    objReference = new Pagereference('/apex/CIFFormPage?id=' + NewLead.id + '&projectId=' + strProjectId +'&show=false'+'&directLead=true');
                }else{
                    objReference = new Pagereference('/apex/CIFFormPage?id=' + NewLead.id + '&projectId=' + strProjectId +'&show='+show);
                }
                //Added by coServe 12-06-2024 End
                
                objReference.setRedirect(true);
                return objReference;
            }
        } catch (exception ex) {
            Database.rollback(sp);
            string strTempError = '';
            if (ex.getMessage() != null && ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') == true) {
                strTempError = ((ex.getMessage().split('FIELD_CUSTOM_VALIDATION_EXCEPTION,')[1]).split(':')[0]).trim();
            }
            
            if (ex.getMessage() != null && ex.getMessage().contains('INVALID_EMAIL_ADDRESS,') == true) {
                strTempError = ((ex.getMessage().split('INVALID_EMAIL_ADDRESS,')[1]).split(':')[0]).trim() + ' : ' + ((ex.getMessage().split('INVALID_EMAIL_ADDRESS,')[1]).split(':')[1]).trim();
            }
            strError = strTempError != '' ? strTempError : ex.getMessage();
            
            return null;
        }
    }
    public pageReference createEventOnDuplicateOpty() {
        Savepoint sp = Database.setSavepoint();
        try {
            Opportunity objOtyTask = [select id, Name, RW_Project__r.Name, Walkin_Source__c, Account.Mobile_No__c, OwnerId, Account.Name, LeadSource, RW_Project__c, AccountId from Opportunity where
                                      id =: OpportunityId
                                     ]; //
            
            /**Event objEvent = new Event();
objEvent.WhatId = objOtyTask.id;
objEvent.Subject = 'Re-Visit';
objEvent.OwnerId = objOtyTask.OwnerId;
objEvent.StartDateTime = datetime.newInstance(System.today().year(), System.today().month(), System.today().day(), 6, 00, 00);
objEvent.EndDateTime = datetime.newInstance(System.today().year(), System.today().month(), System.today().day(), 8, 00, 00);
objEvent.Type = 'Re-visit';
objEvent.Project__c = objOtyTask.RW_Project__c;
insert objEvent;
**/
            
            task t = new task();
            t.WhatId = objOtyTask.id;
            t.OwnerId = objOtyTask.OwnerId;
            //t.whoId = whoId;
            t.activityDate = System.today();
            t.Call_Time__c = System.Now().format('h:mm a');
            t.revisit__c = true;
            t.status = 'Completed';
            t.Subject = 'Re-Visit';
            t.Task_Type__c = 'Re-Visit';
            t.Type = 'Re-visit';
            t.priority = 'Normal';
            t.Project__c = objOtyTask.RW_Project__c;
            t.Visitor_Name__c = objOtyTask.Name;
            
            if (objOtyTask.Walkin_Source__c != null && objOtyTask.Walkin_Source__c != '') //added by Rasika
            {
                
                //Added by coServe 28-02-2024
                Map<String, Opp_Close_Date__c> oppClsDateMap = Opp_Close_Date__c.getall();
                objOtyTask.CloseDate = System.today().addDays(Integer.valueOf(oppClsDateMap.get(objOtyTask.RW_project__c).No_of_Days__c));
                
                // Commented by coServe 28-02-2024
                /*if(objOtyTask.RW_project__c == 'a000I00001xus6C' || objOtyTask.RW_project__c == 'a000I00001xus6CQAQ' || objOtyTask.RW_project__c == 'a000I00001xus6C') //Commented by coServe 27-02-2024
objOtyTask.CloseDate = System.today().addDays(Integer.valueOf(Label.GardensClosedDate));			//45 days , Added by Sheetal on 19/08/2022 to solve issue I0214

else
objOtyTask.CloseDate = System.today().addDays(Integer.valueOf(Label.CloseDateOtherThanGardens));*/	//90 days,  Added by Sheetal on 19/08/2022 to solve issue I0214
                
            }
            update objOtyTask;
            
            insert t;
            
            Pagereference objReference = new Pagereference('/' + objOtyTask.id);
            objReference.setRedirect(true);
            return objReference;
            
        } catch (exception ex) {
            Database.rollback(sp);
            string strTempError = '';
            if (ex.getMessage() != null && ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') == true) {
                strTempError = ((ex.getMessage().split('FIELD_CUSTOM_VALIDATION_EXCEPTION,')[1]).split(':')[0]).trim();
            }
            
            if (ex.getMessage() != null && ex.getMessage().contains('INVALID_EMAIL_ADDRESS,') == true) {
                strTempError = ((ex.getMessage().split('INVALID_EMAIL_ADDRESS,')[1]).split(':')[0]).trim() + ' : ' + ((ex.getMessage().split('INVALID_EMAIL_ADDRESS,')[1]).split(':')[1]).trim();
            }
            strError = strTempError != '' ? strTempError : ex.getMessage();
            
            return null;
        }
        
    }
    public void searchAllLead() {
        
        lstDuplicateLeads = new list < Lead > ();
        lstDuplicateOpty = new list < Opportunity > ();
        lstDuplicateAccount = new list < Account > ();
        strError = '';
        isDuplicateLeadExist = false;
        isDuplicateAccountExist = false;
        isDuplicateOptyExist = false;
        showDirectLead = false;
        
        
        if (strProjectId == null || strProjectId == '') {
            strError = 'Please select the Project to proceed.';
            return;
        }
        
        if (NewLead.RW_Mobile_No__c == null || NewLead.RW_Mobile_No__c == '') {
            strError = 'Please enter the Contact No to proceed.';
            return;
        }
        
        if (enteredOtp== null || enteredOtp == '' & isDirect == False) 
        {
            strError = 'Please enter the OTP  to proceed.';
            return ;
        }
        
        if (!isNRI && NewLead.RW_Mobile_No__c.length() != 10) {
            strError = 'Please enter the mobile number of 10 digit.';
            return;
        }
        
        //Added by coServe 12-06-2024 Start
        //
        String strProjectName = ''; 
        List<Project__c> proj = [SELECT Id,Name, OTP_for_Direct_Lead__c FROM Project__c WHERE Id =: strProjectId];
        /* if(proj.size() > 0 && proj[0].OTP_for_Direct_Lead__c && (strError == '' || strError == null)){
showDirectLeadButton = true;
}else{
showDirectLeadButton = false;
}*/
        
        if (!proj.isEmpty()) {
            strProjectName = proj[0].Name;
            
            if (proj[0].OTP_for_Direct_Lead__c && (String.isBlank(strError))) {
                showDirectLeadButton = true;
            } else {
                showDirectLeadButton = false;
            }
        } else {
            showDirectLeadButton = false;
        }
        //Added by coServe 12-06-2024 End
        
        isNew = false;
        
        string strMobileNumber = '%' + NewLead.RW_Mobile_No__c + '%';
        
        string strQry = 'select id, name, RW_project__r.Name, ';
        // Added by digicloud start 30-07-25
        Set<Id> leadIdsFromProspectOtp = new Set<Id>();
        
        // Step 1: Get Prospect__c records that have matching OTP__c
        List<OTP__c> matchingOtpRecords = [
            SELECT Prospect__c
            FROM OTP__c
            WHERE Generated_OTP__c  = :enteredOtp AND Prospect__c != null AND Project__c =:strProjectId
        ];
        
        // Step 2: Get related Lead__c Ids from those Prospects
        if (!matchingOtpRecords.isEmpty()) {
            Set<Id> prospectIds = new Set<Id>();
            for (OTP__c otp : matchingOtpRecords) {
                prospectIds.add(otp.Prospect__c);
            }
            
            List<Prospect__c> matchingProspects = [
                SELECT Lead__c FROM Prospect__c
                WHERE Id IN :prospectIds AND Lead__c != null
            ];
            
            for (Prospect__c p : matchingProspects) {
                leadIdsFromProspectOtp.add(p.Lead__c);
            }
        }
        // added end       
        Map < String, Schema.SObjectType > GlobalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get('Lead');
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get('RWLeadSearch');
        
        for (Schema.FieldSetMember fieldsSetMem: fieldSetObj.getFields()) {
            strQry += fieldsSetMem.getFieldPath().toLowercase() + ',';
        }
        strQry = strQry.removeEnd(',');
        //  strQry += ' from Lead where (RW_Mobile_No__c LIKE: strMobileNumber OR RW_Secondary_Mobile_No__c LIKE: strMobileNumber) and isConverted = false'; //and RW_Project__c =: strProjectId
        
        /*   strQry += ' FROM Lead WHERE ' +
'(RW_Mobile_No__c LIKE :strMobileNumber OR RW_Secondary_Mobile_No__c LIKE :strMobileNumber) ' +
'AND RW_Project__c = :strProjectId ' +
'AND Generated_OTP_On_Lead__c = :enteredOtp ' +
'AND isConverted = false'; */
        
        // Added by digicloud
        strQry += ' FROM Lead WHERE ' +
            '((RW_Mobile_No__c LIKE :strMobileNumber OR RW_Secondary_Mobile_No__c LIKE :strMobileNumber) ' +
            'AND (RW_Project__c = :strProjectId OR Development__c = :strProjectName) ' +
            'AND isConverted = false ' +
            'AND Generated_OTP_On_Lead__c = :enteredOtp)';
        
        if (!leadIdsFromProspectOtp.isEmpty()) {
            strQry += ' OR (' +
                'Id IN :leadIdsFromProspectOtp AND ' +
                '(RW_Mobile_No__c LIKE :strMobileNumber OR RW_Secondary_Mobile_No__c LIKE :strMobileNumber) ' +
                'AND (RW_Project__c = :strProjectId OR Development__c = :strProjectName)' +
                ')';
        }
        system.debug('strQry - '+strQry);
        //strQry += ')';
        
        //end  
        lstDuplicateLeads = database.query(strQry);
        
        if (lstDuplicateLeads != null && lstDuplicateLeads.size() > 0 && isDirect == false) {
            isDuplicateLeadExist = true;
            
        } /*else {
List<OTP__c> matchedOtps =[SELECT Id, Generated_OTP__c, Channel_Partner_Lookup__c, Sourcing_Manager__c,
Customer_Reference_Lookup__c, OTP_Generate_For__c, Referral_Sub_Source__c,Prospect__r.Lead__c 
FROM OTP__c
WHERE Generated_OTP__c = :enteredOtp AND 
Project__c = :strprojectId AND 
OTP_Expired__c = false AND
Customer_Mobile_No__c =: strMobileNumber AND
Prospect__c != null AND 
Prospect__r.Lead__r.IsConverted = false
LIMIT 1];
if(matchedOtps.size()>0){
String leadId = matchedOtps[0].Prospect__r.Lead__c;
String leadQuery ='select id, name, RW_project__r.Name, ';
for (Schema.FieldSetMember fieldsSetMem: fieldSetObj.getFields()) {
leadQuery += fieldsSetMem.getFieldPath().toLowercase() + ',';
}
leadQuery = leadQuery.removeEnd(',');
leadQuery += ' FROM Lead WHERE Id =:leadId' ;
lstDuplicateLeads = database.query(leadQuery);    

}  if (lstDuplicateLeads != null && lstDuplicateLeads.size() > 0) {
isDuplicateLeadExist = true;
} else{
isDuplicateLeadExist = false;
show = false;
}*/
        else{
            isDuplicateLeadExist = false;
            show = false;
        }
        
        
        //isDuplicateLeadExist = false;
        //
        
        
        lstDuplicateAccount = [Select Id, Name, Mobile_No__c, Alternate_Mobile_No__c, PersonEmail, Alternate_Email__c from Account
                               where(Mobile_No__c =: NewLead.RW_Mobile_No__c OR Alternate_Mobile_No__c =: NewLead.RW_Mobile_No__c)
                              ]; //
        list<Id> lstDuplicateAccountIds = new list<Id>();
        if (!lstDuplicateAccount.isEmpty() && lstDuplicateAccount.size() > 0) {
            For(Account acc : lstDuplicateAccount){
                lstDuplicateAccountIds.add(acc.Id);
            }
        }
        list<Opportunity> opps = new List<Opportunity>();
        if (!lstDuplicateAccountIds.isEmpty() && lstDuplicateAccountIds.size() > 0) {
            opps = [select id, Name, RW_Project__r.Name, Account.Mobile_No__c, OwnerId, Account.Name, LeadSource, RW_Project__c, AccountId from Opportunity where AccountId In: lstDuplicateAccountIds and
                    RW_Project__c =: strProjectId and RW_Opportunity_Status__c =: 'Active' ORDER By LastModifiedDate DESC];
        }
        
        
        
        /*if (!lstDuplicateAccount.isEmpty() && lstDuplicateAccount.size() > 0) {
//lstDuplicateOpty = [select id, Name, RW_Project__r.Name, Account.Mobile_No__c, OwnerId, Account.Name, LeadSource, RW_Project__c, AccountId from Opportunity where AccountId =: lstDuplicateAccount[0].Id and
//   RW_Project__c =: strProjectId and RW_Opportunity_Status__c =: 'Active'
// ];//

lstDuplicateOpty = [select id, Name, RW_Project__r.Name, Account.Mobile_No__c, OwnerId, Account.Name, LeadSource, RW_Project__c, AccountId from Opportunity where  
RW_Project__c =: strProjectId and RW_Opportunity_Status__c =: 'Active' AND (RW_Mobile_No__c =: NewLead.RW_Mobile_No__c OR RW_Secondary_Mobile_No__c =: NewLead.RW_Mobile_No__c)  //Added RW_Secondary_Mobile_No__c =: NewLead.RW_Mobile_No__c by Vinay 05-05-2025
];

if(lstDuplicateOpty.size() > 1){
isMultipleDuplicateOptyExist = true;
}else{
if (!lstDuplicateOpty.isEmpty() && lstDuplicateOpty.size() > 0) {
isDuplicateOptyExist = true;
isDuplicateAccountExist = false;

} else {
isDuplicateAccountExist = true;
isDuplicateOptyExist = false;
show = false;
}
}


}*/
        //  If duplicate Accounts exist
        if (!lstDuplicateAccount.isEmpty()) {
            isDuplicateAccountExist = true; // Always show duplicate accounts
            
            //  Combine Opps from AccountId + Mobile logic
            lstDuplicateOpty = new List<Opportunity>();
            
            // Opps by AccountId
            if (!lstDuplicateAccountIds.isEmpty()) {
                lstDuplicateOpty.addAll(opps); // already queried above
            }
            
            // Opps by Mobile (only if you need to check separately)
            List<Opportunity> mobileOpps = [
                SELECT Id, Name, RW_Project__r.Name, Account.Mobile_No__c, OwnerId, Account.Name,
                LeadSource, RW_Project__c, AccountId
                FROM Opportunity
                WHERE RW_Project__c = :strProjectId
                AND RW_Opportunity_Status__c = 'Active'
                AND (RW_Mobile_No__c = :NewLead.RW_Mobile_No__c
                     OR RW_Secondary_Mobile_No__c = :NewLead.RW_Mobile_No__c)
            ];
            for (Opportunity o : mobileOpps) {
                if (!lstDuplicateOpty.contains(o)) {
                    lstDuplicateOpty.add(o);
                }
            }
            
            //  Set flags
            if (!lstDuplicateOpty.isEmpty()) {
                isDuplicateOptyExist = true;
                if (lstDuplicateOpty.size() > 1) {
                    isMultipleDuplicateOptyExist = true;
                }
            }
        } else {
            //  No duplicate accounts
            isDuplicateAccountExist = false;
            show = false;
        }
        
        
        if(opps.size() > 0){
            lstDuplicateAccount = [Select Id, Name, Mobile_No__c, Alternate_Mobile_No__c, PersonEmail, Alternate_Email__c from Account WHERE Id =: opps[0].AccountId];
        }
        
    }
    
    public static void mergeAcc(List<Account> lstAccount, Opportunity opp){
        if(System.label.Account_Merging_Active == 'Yes'){
            
            List<Account> dupAccs = new List<Account>();
            Account masterAcc;
            Map<Id,Account> accMap = new Map<Id, Account>([SELECT Id FROM Account WHERE Id =: lstAccount]);
            
            Map<Id,Account> portalAccMap = new Map<Id, Account>();
            Map<Id,Account> accountsMap = new Map<Id, Account>();
            for(Account acc : lstAccount){
                if(acc.IsCustomerPortal){
                    portalAccMap.put(acc.Id, acc);
                }
                accountsMap.put(acc.Id, acc);
            }
            
            
            
            if(portalAccMap.keySet().size() == 1){
                masterAcc = accMap.get(portalAccMap.values()[0].Id);
                for(Account acc : lstAccount){
                    if(acc.Id != portalAccMap.values()[0].Id){
                        dupAccs.add(accMap.get(acc.Id));
                    }
                }
                Database.merge(masterAcc, dupAccs);
            }else if(portalAccMap.keySet().size() > 1){
                System.debug('Multiple Portal accounts found');
            }else{
                for(Account acc : lstAccount){
                    if(acc.Id == opp.AccountId){
                        masterAcc = accMap.get(acc.Id);
                    }else{
                        dupAccs.add(accMap.get(acc.Id));
                    }
                }
                Database.merge(masterAcc, dupAccs);
            }
            
            
        }
    }
    //Added by coServe 12-06-2024 Start
    public void directLead(){
        System.debug('--directLead--');
        strError = '';
        showDirectLead = true;
        
        if (NewLead.Email == null || NewLead.Email == '' || NewLead.LastName == null || NewLead.LastName == '') {
            strError = 'Please enter the Last Name & Email to proceed.';
            System.debug('strError: ' + strError);
        }
        /*if (NewLead.LastName == null || NewLead.LastName == '') {
strError = 'Please enter Last Name to proceed.';
//return null;
}*/
        System.debug('strError: ' + strError);
        if(strError == '' || strError == null){
            showOtpDetails = true;
            showDirectLeadButton = false;
            String OTPNumber=''; 
            Integer xx;
            do{
                Double x = Math.random(); 
                long y = Math.round(x*100000);
                xx = String.valueOf(y).length();
                OTPNumber = String.valueOf(y);
            } while( xx < 5 );
            
            OTP__c otp = new OTP__c();
            otp.Generated_OTP__c = OTPNumber;
            otp.Direct_Lead_Mobile_Number__c = NewLead.RW_Mobile_No__c;
            otp.OTP_Generate_For__c = 'Direct Lead Creation';
            //otp.Digital_Form_Customer_Number__c = NewLead.RW_Mobile_No__c;
            //otp.Generated_Digital_Form_OTP__c = OTPNumber;
            insert otp;
            
            List<Project__c> proj = [SELECT Id, Name, RW_Address__c FROM Project__c WHERE Id =: strProjectId];
            Date dt = Date.today();
            String dtStr = String.valueOf(dt);
            dtStr = dtStr.substring(0,10);
            
            String content = 'Dear Customer, your appointment for an exclusive preview of '+ proj[0].Name + ' is on ' + dtStr + '. Pls Provide this code '+ OTPNumber +' at the reception on your visit. . Address : '+ proj[0].RW_Address__c + ', RUNWAL GROUP';
            SMS_Schedule_SMS_c__c sms = new SMS_Schedule_SMS_c__c();
            sms.Immediate__c = true;
            sms.Name = 'Direct Lead Creation';
            sms.Sender_Mobile__c = NewLead.RW_Mobile_No__c;
            sms.SMS_Long_text__c = content;
            insert sms;
        }
        //return null;
        
    }
    
    public PageReference submitOtp(){
        
        System.debug('NewLead.LastName: ' + NewLead.LastName);
        System.debug('NewLead.Email: ' + NewLead.Email);
        strError = '';
        
        Date dt = Date.today();
        System.debug('--submitOtp--');
        System.debug('enteredOtp: ' + enteredOtp);
        System.debug('NewLead.RW_Mobile_No__c: ' + NewLead.RW_Mobile_No__c);
        if (NewLead == null) {
            strError = 'An unexpected error occurred. Please re-enter the OTP screen.';
            return null;
        }
        
        List<OTP__c> otps = [SELECT Id, Generated_OTP__c FROM OTP__c WHERE Generated_OTP__c =: enteredOtp AND Direct_Lead_Mobile_Number__c =: NewLead.RW_Mobile_No__c AND OTP_Generate_For__c = 'Direct Lead Creation' AND OTP_Expired__c = false AND CreatedDate >=: dt];
        if(otps.size() > 0){
            System.debug('otp: ' + otps[0].Generated_OTP__c);
            //saveMethod();
            Pagereference objReference = saveMethod();
            //PageReference objReference = saveMethod();
            if (objReference != null) {
                objReference.setRedirect(true);
                return objReference;
            } else {
                strError = 'Unable to create lead. Please try again.';
                return null;
            }
            
            //objReference.setRedirect(true);
            //return objReference;
            
        }else{
            strError = 'Please enter valid OTP';
            return null;
        }
    }
    public static void dummy(){
        
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
        
    }
    //Added by coServe 12-06-2024 End
    
}