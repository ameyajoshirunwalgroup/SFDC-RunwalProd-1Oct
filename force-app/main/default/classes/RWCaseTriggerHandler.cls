public class RWCaseTriggerHandler 
{
    public void runTrigger()
    {
        // Method will be called to handle Before insert events
        if (Trigger.isBefore && Trigger.isInsert)
        {
            onBeforeInsert((list<Case>) trigger.new, (map<id, Case>) trigger.OldMap);
        }
        
        // Method will be called to handle Before Update events
        if (Trigger.isBefore && Trigger.isUpdate)
        {
            onBeforeUpdate((list<Case>) trigger.new, (map<id, Case>) trigger.OldMap);
        }
        
        // Method will be called to handle After Insert events
        if (Trigger.isAfter && Trigger.isInsert)
        {
            
            onAfterInsert((list<Case>) trigger.new, (map<id, Case>) trigger.OldMap);
        }
        
        // Method will be called to handle After Update eventssss
        
        if (Trigger.isAfter && Trigger.isUpdate) 
        {
            onAfterUpdate((list<Case>) trigger.new, (map<id, Case>) trigger.OldMap);
            
        }
        
        if (Trigger.isAfter && Trigger.isUpdate) 
        {
            onAfterUpdate((list<Case>) trigger.new, (map<id, Case>) trigger.OldMap);
            
        }
        
    }
    public void onBeforeInsert(list<Case> lstTriggerNew, map<id, Case> mapTriggerOld)
    {
        
        updateProjectWeb(lstTriggerNew);
        updateProjectField(lstTriggerNew,mapTriggerOld);   
        //updateOwnerByRMSelected(lstTriggerNew, null);
        updateManagerEmail(lstTriggerNew, null);
        //AssignOwnertoGenQueue(lstTriggerNew);
        updateEntitlementOnCase(lstTriggerNew, null);
        caseownerUpdateForsingleOppo(lstTriggerNew, null);
        updatecasestatus(lstTriggerNew);
        updateAccountId(lstTriggerNew); //Added by coServe 28-12-2023
        //updateOwnersfieldonCase(lstTriggerNew,mapTriggerOld);
        updateEscalationTAT(lstTriggerNew, null); // Added by coServe 13-11-2024
        updateRMNameasOwnerforWalkinCases(lstTriggerNew);
        //LocobuzzCaseAssignment.assignToProjectSpoc(lstTriggerNew); // Added by Vinay 16-01-2025
        //assigneOwnerPostPossession(lstTriggerNew); //Added by Vinay 07-03-2025
        checkForCancelledCustomer(lstTriggerNew); //Added by Vinay 04-04-2025
        //changeOwnerFromSysAdminToRM(lstTriggerNew); //Added by Vinay 18-04-2025 to reassign the owner from System Admin to RM
        
    }
    
    public static void ownerAssignment(List<Case> caseList){
        List<Id> oppIds = new List<Id>();
        for(Case cs : caseList){
            if(cs.Opportunity__c != null){
                oppIds.add(cs.Opportunity__c);
            }
        }
        if(oppIds != null){
            Map<Id,Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Id,Booking__c,Booking__r.RW_Key_handover_date__c FROM Opportunity WHERE Id =: oppIds]);
            for(Case cs : caseList){
                
                if(cs.Opportunity__c != null && oppMap.get(cs.Opportunity__c).Booking__c != null && oppMap.get(cs.Opportunity__c).Booking__r.RW_Key_handover_date__c != null){
                    System.debug('cs.Opportunity__r.Booking__r.RW_Key_handover_date__c: ' + oppMap.get(cs.Opportunity__c).Booking__r.RW_Key_handover_date__c);
                    System.debug('cs.Opportunity__r.Booking__r.RW_Key_handover_date__c: ' + oppMap.get(cs.Opportunity__c).Booking__r.RW_Key_handover_date__c + 60);
                    if(cs.CreatedDate > (oppMap.get(cs.Opportunity__c).Booking__r.RW_Key_handover_date__c + 60)){
                        cs.OwnerId = System.label.Default_Facility_Management_User;
                        cs.FM_Team_Assigned__c = true; 
                    }
                }
            }
        }
        
    }

    //Added by Vinay 18-04-2025 Start
    /*public void changeOwnerFromSysAdminToRM(List<Case> lstTriggerNew){ 
        Set<String> rmNames = new Set<String>();
        List<Case> caseList = new List<Case>();
        for(Case cs : lstTriggerNew){
            if(cs.OwnerId == System.label.System_Administrator_User_Id){
                rmNames.add(cs.RW_RM_Name__c);
                caseList.add(cs);
            }
        }
        if(rmNames.size() > 0){
            List<User> userList = [SELECT Id, Name FROM User WHERE Name =: rmNames];
            Map<String, Id> userMap = new Map<String, Id>();
            for(User usr : userList){
                userMap.put(usr.Name, usr.Id);
            }
            for(Case c : caseList){
                c.OwnerId = userMap.get(c.RW_RM_Name__c);
            }
        }
    }*/
    //Added by Vinay 18-04-2025 End
    
    public void checkForCancelledCustomer(list<Case> lstCase){ //Added by Vinay 04-04-2025
        Map<Id,Id> caseIdVsAccId = new Map<Id, Id>();
        Set<Id> accIds = new Set<Id>();
        Set<Id> oppIds = new Set<Id>();
        for(Case cs : lstCase){
            if(String.isNotBlank(cs.AccountId)){
                caseIdVsAccId.put(cs.Id, cs.AccountId);
                accIds.add(cs.AccountId);
                if(String.isNotBlank(cs.Opportunity__c))
                	oppIds.add(cs.Opportunity__c);
            }
        }
        
        
        if(caseIdVsAccId.size() > 0){
            Map<Id,Account> accMap = new Map<Id, Account>([SELECT Id, (SELECT Id, StageName FROM Opportunities) FROM Account WHERE Id =: accIds]);
            for(Case cs : lstCase){
                if(cs.AccountId != null && accMap.get(cs.AccountId) != null && accMap.get(cs.AccountId).Opportunities != null && accMap.get(cs.AccountId).Opportunities.size() > 0){
                    Integer oppCount = accMap.get(cs.AccountId).Opportunities.size();
                    Integer cancelledOppCount = 0;
                    for(Opportunity opp : accMap.get(cs.AccountId).Opportunities){
                        if(opp.StageName == 'Cancelled'){
                            cancelledOppCount += 1;
                            //cs.addError('Case can not be created for Cancelled Customer');
                        }
                    }
                    System.debug('oppCount: ' +  oppCount);
                    System.debug('cancelledOppCount: ' +  cancelledOppCount);
                    if(oppCount == cancelledOppCount){
                        //cs.addError('Case can not be created for Cancelled Customer');
                        cs.Stop_Emails__c = true;
                        //cs.Status = 'Case Closed';
                        //cs.RW_RM_Remarks__c = 'Cancelled Customer';
                    }
                }
                /*if(accMap.get(cs.AccountId).No_of_Opportunities__c > 0 && accMap.get(cs.AccountId).Active_Opportunities__c == 0){
                    cs.addError('Case can not be created for Cancelled Customer');
                }*/
            }
        }
        
        if(oppIds.size() > 0){
            Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Id, StageName FROM Opportunity WHERE Id =: oppIds]);
            for(Case cs : lstCase){
                if(cs.Opportunity__c != null && oppMap.get(cs.Opportunity__c).StageName == 'Cancelled'){
                    cs.Stop_Emails__c = true;
                }
            }
        }
    }
    //Added by Vinay 07-03-2025
    public void assigneOwnerPostPossession(list<Case> lstCase){
        
        /*if(checkRecursion.isFirstRun()){
        List<Id> oppIds = new list<Id>();
        List<Case> caseWithOpportunity = new List<Case>();
        for(Case cs : lstCase){
            System.debug('cs.OwnerId: ' + cs.OwnerId);
            System.debug('cs.Post_Possession_Customer__c: ' + cs.Post_Possession_Customer__c);
            System.debug('cs.Opportunity__c: ' + cs.Opportunity__c);
            if(cs.Post_Possession_Customer__c && cs.Opportunity__c != null && cs.OwnerId != System.label.Default_Facility_Management_User){
                oppIds.add(cs.Opportunity__c);
                caseWithOpportunity.add(cs);
            }
        }
        if(oppIds.size() > 0){
            Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Id,  Booking__c, Booking__r.RW_Key_handover_date__c, Booking__r.Primary_Applicant_Name__c, Booking__r.Primary_Applicant_Email__c, Booking__r.Project__r.FM_Team__c FROM Opportunity WHERE Id =: oppIds]);
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            String orgEmail = Utility.getOrgWideEmailAddress();
            User usr = [SELECT Id, Name, FirstName, LastName, Email FROM User WHERE Id =: System.label.Default_Facility_Management_User];
            for(Case cs : caseWithOpportunity){
                if(oppMap.get(cs.Opportunity__c).Booking__c != null && oppMap.get(cs.Opportunity__c).Booking__r.RW_Key_handover_date__c != null){
                    //cs.OwnerId = System.label.Default_Facility_Management_User;
                    //cs.RW_RM_Name__c = 'Admin Stetig';
                    cs.OwnerId = usr.Id;
                    cs.RW_RM_Name__c = usr.FirstName + ' ' + usr.LastName;
                    System.debug('cs.OwnerId: ' + cs.OwnerId);
                    System.debug('cs.Post_Possession_Customer__c: ' + cs.Post_Possession_Customer__c);
                    System.debug('cs.Opportunity__c: ' + cs.Opportunity__c);
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new List<String>{oppMap.get(cs.Opportunity__c).Booking__r.Primary_Applicant_Email__c, 'vinay.kumar.os@runwalgroup.in'});
                    //mail.setToAddresses(new List<String>{'vinay.kumar.os@runwalgroup.in'});
                    mail.setOrgWideEmailAddressId(orgEmail);
                    String htmlBody = '<html> Dear Customer,<br/><br/>'; // + oppMap.get(cs.Opportunity__c).Booking__r.Primary_Applicant_Name__c + '<br/><br/>'; 
                    htmlBody += 'Thank you for reaching out. Your request has been forwarded to our Facility Management team. You can also contact the FM at ' + oppMap.get(cs.Opportunity__c).Booking__r.Project__r.FM_Team__c + '. They will get in touch with you shortly to assist with your concern. <br/><br/>';
                    htmlBody += 'Best Regards, <br/> Runwal</html>';
                    mail.subject = 'Case Created';
                    mail.setHtmlBody(htmlBody);
                    mails.add(mail);
                }
            }
            Messaging.SendEmailResult[] result = Messaging.sendEmail(mails);
        }
        }*/
        if(checkRecursion.isFirstRun()){
            
            
            List<Id> oppIds = new list<Id>();
            List<Case> caseWithOpportunity = new List<Case>();
            List<Id> caseIds = new list<Id>();
            for(Case cs : lstCase){
                //if(cs.Opportunity__c != null && cs.FM_Team_Assigned__c == false && cs.Customer_Lifecycle_Touchpoint__c == 'Post-Possession'){ // Added cs.Customer_Lifecycle_Touchpoint__c == 'Post-Possession' by Vinay 18-04-2025
                if(cs.Opportunity__c != null && cs.FM_Team_Assigned__c == false){
                    oppIds.add(cs.Opportunity__c);
                    caseWithOpportunity.add(cs);
                    caseIds.add(cs.Id);
                }
            }
            if(oppIds.size() > 0){
                //caseWithOpportunity = [SELECT Id, Opportunity__c FROM Case WHERE Id =: caseIds];
                Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Id,  Booking__c, Booking__r.RW_Key_handover_date__c, Booking__r.Primary_Applicant_Name__c, Booking__r.Primary_Applicant_Email__c, Booking__r.Project__r.FM_Team__c FROM Opportunity WHERE Id =: oppIds]);
                List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                String orgEmail = Utility.getOrgWideEmailAddress();
                //User usr = [SELECT Id, Name, Email FROM User WHERE Id =: System.label.Default_Facility_Management_User];
                Database.DMLOptions options = new Database.DMLOptions(); //Added by Vinay 16-04-2025
				options.assignmentRuleHeader.useDefaultRule = false; //Added by Vinay 16-04-2025
                for(Case cs : caseWithOpportunity){
                    if(oppMap.get(cs.Opportunity__c).Booking__c != null && oppMap.get(cs.Opportunity__c).Booking__r.RW_Key_handover_date__c != null){
                        cs.OwnerId = System.label.Default_Facility_Management_User;
                        cs.FM_Team_Assigned__c = true;
                        //cs.RW_RM_Name__c = 'Admin Stetig';
                        //cs.OwnerId = usr.Id;
                        //cs.RW_RM_Name__c = null;  //Commented to fix the RM Name null issue 17-04-2025 by Vinay
                        
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(new List<String>{oppMap.get(cs.Opportunity__c).Booking__r.Primary_Applicant_Email__c});
                        //mail.setToAddresses(new List<String>{'vinay.kumar.os@runwalgroup.in'});
                        mail.setOrgWideEmailAddressId(orgEmail);
                        String htmlBody = '<html> Dear Customer,<br/><br/>'; // + oppMap.get(cs.Opportunity__c).Booking__r.Primary_Applicant_Name__c + '<br/><br/>'; 
                        htmlBody += 'Thank you for reaching out. Your request has been forwarded to our Facility Management team. You can also contact the FM at ' + oppMap.get(cs.Opportunity__c).Booking__r.Project__r.FM_Team__c + '. They will get in touch with you shortly to assist with your concern. <br/><br/>';
                        htmlBody += 'Best Regards, <br/> Runwal</html>';
                        mail.subject = 'Case Created';
                        mail.setHtmlBody(htmlBody);
                        mails.add(mail);
                    }
                }
                Messaging.SendEmailResult[] result = Messaging.sendEmail(mails);
                //update caseWithOpportunity;
            }
        }
    }
    
    //Added by coServe 28-12-2023
    public void updateAccountId(list<Case> lstCase){
        
        Map<String, Case> emailVsCase = new Map<String, Case>();
        for(case cs : lstCase){
            if(cs.Origin == 'Email'){
                emailVsCase.put(cs.SuppliedEmail, cs);
            }
        }
        list<Account> lstAccount = [SELECT Id, RW_Email__c, IsPersonAccount, PersonEmail, PersonContactId, Stop_Case_Emails__c, (SELECT Id, AccountId, StageName, Booking__r.Booking_Date__c, CreatedDate, Booking__r.RW_Key_handover_date__c FROM Opportunities WHERE StageName = 'Unit Booked' ORDER BY Booking__r.Booking_Date__c DESC) FROM Account WHERE PersonEmail =: emailVsCase.keySet() AND IsPersonAccount = true];
        //Added by Prashant to tag Opportunity on case for CRN. 11-2-25 //START
        String OppId;
        Opportunity firstOpp; // Added by Vinay 09-01-2026
        if (!lstAccount.isEmpty()) {
    		Account acc = lstAccount[0];
    
    		if (!acc.Opportunities.isEmpty()) {
                //Opportunity firstOpp = acc.Opportunities[0]; // Commented by Vinay 09-01-2026
                firstOpp = acc.Opportunities[0]; // Added by Vinay 09-01-2026
        		System.debug('First Opportunity ID: ' + firstOpp.Id);
                OppId = firstOpp.Id;
            }
        }
        //Added by Prashant to tag Opportunity on case for CRN. 11-2-25 //END
        Map<String, List<Account>> emailVsAccounts = new Map<String, List<Account>>();
        Map<String, String> accIdVsContId = new Map<String, String>();
        Map<String, Boolean> accIdVsStopEmails = new Map<String, Boolean>(); //Added by Vinay 26-05-2025
        for(Account acc : lstAccount){
            accIdVsContId.put(acc.Id, acc.PersonContactId);
            accIdVsStopEmails.put(acc.Id, acc.Stop_Case_Emails__c); //Added by Vinay 26-05-2025
            if(emailVsAccounts.get(acc.PersonEmail) == null){
                emailVsAccounts.put(acc.PersonEmail, new List<Account>{acc});
            }else{
                emailVsAccounts.get(acc.PersonEmail).add(acc);
            }
        }
        for(String email : emailVsAccounts.keySet()){
            if(emailVsAccounts.get(email).size() > 1){
                Map<Datetime, String> bkgDtVsAccId = new Map<Datetime, String>();
                Map<Datetime, String>oppDtVsAccId = new Map<Datetime, String>();
                for(Account acc : emailVsAccounts.get(email)){
                    for(Opportunity opp : acc.Opportunities){
                        if(opp.Booking__r.Booking_Date__c != null){
                            bkgDtVsAccId.put(opp.Booking__r.Booking_Date__c, opp.AccountId);
                        }else{
                            oppDtVsAccId.put(opp.CreatedDate, opp.AccountId);
                        }
                    }
                }
                if(bkgDtVsAccId.keySet().size() > 0){
                    List<Datetime> bkgDates = new List<Datetime>(bkgDtVsAccId.keySet());
                    bkgDates.sort();
                    String accId  = bkgDtVsAccId.get(bkgDates[bkgDates.size()-1]);
                    emailVsCase.get(email).AccountId = accId;
                    emailVsCase.get(email).ContactId = accIdVsContId.get(accId);
                    emailVsCase.get(email).Opportunity__c = OppId;//Added by Prashant - 11-2-25.
                    emailVsCase.get(email).Stop_Emails__c = accIdVsStopEmails.get(accId); //Added by Vinay 26-05-2025
                }else if(oppDtVsAccId.keySet().size() > 0){
                    List<Datetime> oppDates = new List<Datetime>(oppDtVsAccId.keySet());
                    oppDates.sort();
                    String accId  = oppDtVsAccId.get(oppDates[oppDates.size()-1]);
                    emailVsCase.get(email).AccountId = accId;
                    emailVsCase.get(email).ContactId = accIdVsContId.get(accId);
                    emailVsCase.get(email).Opportunity__c = OppId;//Added by Prashant - 11-2-25.
                    emailVsCase.get(email).Stop_Emails__c = accIdVsStopEmails.get(accId); //Added by Vinay 26-05-2025
                }
            }else if(emailVsAccounts.get(email).size() == 1){
                emailVsCase.get(email).AccountId = emailVsAccounts.get(email)[0].Id;
                emailVsCase.get(email).ContactId = accIdVsContId.get(emailVsAccounts.get(email)[0].Id);
                emailVsCase.get(email).Opportunity__c = OppId;//Added by Prashant - 11-2-25.
                emailVsCase.get(email).Stop_Emails__c = accIdVsStopEmails.get(emailVsAccounts.get(email)[0].Id); //Added by Vinay 26-05-2025
            }
            /*if(firstOpp != null && firstOpp.Booking__r.RW_Key_handover_date__c != null){  // Added by Vinay 09-01-2026  //Commented by Vinay 07-02-2026 to stop the FM team assignment for post possession cases.
                emailVsCase.get(email).Post_Possession_Customer__c = true;
                emailVsCase.get(email).OwnerId = System.label.Default_Facility_Management_User;
                emailVsCase.get(email).FM_Team_Assigned__c = true;
            }*/
        }
        
        //Added by Vinay 15-01-2025 Start
        /*List<Opportunity> opps = [SELECT Id, Name, AccountId, Account.PersonEmail, Booking__r.RW_Key_handover_date__c, RW_RM_Name__c FROM Opportunity WHERE Account.PersonEmail =: emailVsCase.keySet()];
        Set<String> postPossCustomers = new Set<String>();
        Map<String, String> rmsMap = new Map<String, String>();
        for(Opportunity opp : opps){
            System.debug('postPossCustomers: ' + opp.Name);
            if(opp.Booking__r.RW_Key_handover_date__c != null){
                postPossCustomers.add(opp.Account.PersonEmail);
                rmsMap.put(opp.Account.PersonEmail, opp.RW_RM_Name__c);
            }
        }
        
        Database.DMLOptions options = new Database.DMLOptions(); //Added by Vinay 16-04-2025
		options.assignmentRuleHeader.useDefaultRule = false; //Added by Vinay 16-04-2025
        for(Case cs : emailVsCase.values()){
            //if(postPossCustomers.contains(cs.SuppliedEmail) && cs.Customer_Lifecycle_Touchpoint__c == 'Post-Possession'){ // Added cs.Customer_Lifecycle_Touchpoint__c == 'Post-Possession' by Vinay 18-04-2025
            if(postPossCustomers.contains(cs.SuppliedEmail)){ // Added cs.Customer_Lifecycle_Touchpoint__c == 'Post-Possession' by Vinay 18-04-2025
                cs.Post_Possession_Customer__c = true;
                cs.OwnerId = System.label.Default_Facility_Management_User;
                cs.FM_Team_Assigned__c = true;
                //cs.RW_RM_Name__c = null; //Commented to fix the RM Name null issue 17-04-2025 by Vinay
            }
        }*/
        //Added by Vinay 15-01-2025 End
    }
    
    // Added by Vinay 28-02-2025
    public void updateProjectUnit(list<Case> lstCase){
        Set<String> accIds = new Set<String>();
        List<String> caseIds = new List<String>();
        for(Case c : lstCase){
            if(string.isNotBlank(c.AccountId)){
                accIds.add(c.AccountId);
                caseIds.add(c.Id);
            }
        }
        if(accIds.size() > 0){
            Map<String, List<Opportunity>> accVsOppMap = new Map<String, List<Opportunity>>();
            List<Opportunity> bookedOppList = [SELECT Id, AccountId, RW_Project_Unit__c, RW_Project__c, RW_RM_Name__c, Booking__r.RW_Key_handover_date__c, RW_Project_Unit__r.Relationship_Manager__r.user__c FROM Opportunity WHERE AccountId =: accIds AND StageName = 'Unit Booked' AND RW_Project_Unit__c != null ORDER BY Booking__r.Booking_Date__c DESC];
            for(Opportunity opp : bookedOppList){
                if(accVsOppMap.get(opp.AccountId) != null){
                    accVsOppMap.get(opp.AccountId).add(opp);
                }else{
                    accVsOppMap.put(opp.AccountId, new List<Opportunity>{opp});
                }
            }
            
            List<Case> caseList = new List<Case>();
            for(Case c : [SELECT Id, AccountId, RW_Project__c, locobuzz__Locobuzz_ID__c, Post_Possession_Customer__c, RW_RM_Name__c, FM_Team_Assigned__c  FROM Case WHERE Id =: caseIds]){
                if(accVsOppMap.get(c.AccountId) != null && accVsOppMap.get(c.AccountId).size() > 0){
                    c.RW_Project_Unit__c = accVsOppMap.get(c.AccountId)[0].RW_Project_Unit__c;
                    c.RW_Project__c = accVsOppMap.get(c.AccountId)[0].RW_Project__c;
                    c.Opportunity__c = accVsOppMap.get(c.AccountId)[0].Id;
                    if(String.isBlank(c.locobuzz__Locobuzz_ID__c) && !c.Post_Possession_Customer__c && c.RW_RM_Name__c == null){  //Added c.RW_RM_Name__c == null by Vinay 19-01-2026
                        c.RW_RM_Name__c = accVsOppMap.get(c.AccountId)[0].RW_RM_Name__c;
                    }
                    if(accVsOppMap.get(c.AccountId)[0].Booking__r.RW_Key_handover_date__c == null && c.FM_Team_Assigned__c == true){  // Added by Vinay 12-01-2026
                        c.Post_Possession_Customer__c = false;
                        c.OwnerId = accVsOppMap.get(c.AccountId)[0].RW_Project_Unit__r.Relationship_Manager__r.user__c;
                        c.FM_Team_Assigned__c = false;
                    }
                    caseList.add(c);
                }
            }
            if(caseList.size() > 0)
            	update caseList;
        }
    }
    
    public void caseownerUpdateForsingleOppo(list<Case> lstCase, map<id, Case> mapTriggerOld){
        System.debug('### lstCase size  '+lstCase.size());
        list<Id> lstAccIds = new list<Id>();
        Id CustomerId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        for(Case objCase : lstCase){
            if(objCase.AccountId != null && objCase.RecordTypeId == CustomerId){
                lstAccIds.add(objCase.AccountId);
            }
        }
        
        System.debug('#### lstAccIds '+lstAccIds);
        // Added by Mounika - Complaint Module - FRD-4
        List<Account> listOfAccs = [Select Id,(Select Id,RW_Project_Unit__r.Relationship_Manager__r.user__c,RW_Project_Unit__r.Relationship_Manager__c,RW_Project_Unit__r.Relationship_Manager__r.RM_Email__c,StageName 
                                               From Opportunities where StageName = 'Unit Booked') FROM Account  Where Id IN: lstAccIds]; 
        System.debug('#### listOfAccs '+listOfAccs);
        /*List<Opportunity> listOpportunities = [Select Id,RW_Project_Unit__r.Relationship_Manager__c,StageName 
From Opportunities where AccountId IN: lstAccIds And StageName = 'Unit Booked' ];*/
        Map<Id, Integer> mapOfopposize = new Map<Id, Integer>();
        Map<Id, List<Opportunity>> mapOfoppoties = new Map<Id, List<Opportunity>>();
        for(Account acc: listOfAccs){
            System.debug('#### acc.Opportunities '+acc.Opportunities.size());
            if(acc.Opportunities.size()>0){
                
                mapOfopposize.put(acc.Id, acc.Opportunities.size());
                List<Opportunity> listOfOppo = new List<Opportunity>();
                for(Opportunity oppo: acc.Opportunities){
                    listOfOppo.add(oppo);
                    System.debug('#### acc.Opportunities '+acc.Opportunities.size());
                }
                System.debug('#### listOfOppo '+listOfOppo.size());
                mapOfoppoties.put(acc.Id, listOfOppo);
            }
        }
        system.debug('mapOfoppoties '+mapOfoppoties.size());
        
        for(Case objCase : lstCase)
        {
            system.debug('#### objCase '+objCase.Id);
            if(mapOfoppoties.containsKey(objCase.AccountId) && objCase.RecordTypeId == CustomerId && objCase.Origin != 'Walk-in' && !objCase.Post_Possession_Customer__c && (objCase.locobuzz__Locobuzz_ID__c == null || objCase.locobuzz__Locobuzz_ID__c == '')){
                List<Opportunity> listOfoppoties = mapOfoppoties.get(objCase.AccountId);
                system.debug('#### listOfoppoties '+listOfoppoties.size());
                if(listOfoppoties.size() == 1){//auto email wont go when rm is the case owner?
                    system.debug('listOfoppoties '+listOfoppoties[0].RW_Project_Unit__r.Relationship_Manager__c);
                    if(listOfoppoties[0].RW_Project_Unit__r.Relationship_Manager__c != null && objCase.FM_Team_Assigned__c == false){ //Added objCase.FM_Team_Assigned__c == false by Vinay 07-01-2026
                        system.debug('listOpportunities____Unit Blocked '+listOfoppoties[0].RW_Project_Unit__r.Relationship_Manager__c != null);
                        objCase.OwnerId = listOfoppoties[0].RW_Project_Unit__r.Relationship_Manager__r.user__c;
                    }
                }
            }
        }
    }
    public void onBeforeUpdate(list<Case> lstTriggerNew, map<id, Case> mapTriggerOld)
    { 
        checkForCancelledCustomer(lstTriggerNew); //Added by Vinay 29-05-2025
        updateOwnerAsRmOrQueue(lstTriggerNew, mapTriggerOld); //Added by Vinay 21-01-2025
        //updateOwnerByRMSelected(lstTriggerNew, mapTriggerOld); //Commneted by Vinay 21-01-2025
        updateManagerEmail(lstTriggerNew, mapTriggerOld);
        //updateOwnerToQueue(lstTriggerNew, mapTriggerOld); //Commneted by Vinay 21-01-2025
        updateEntitlementOnCase(lstTriggerNew, mapTriggerOld);
        showErrorforcontactedCase(lstTriggerNew, mapTriggerOld);
        updateOwnersfieldonCase(lstTriggerNew,mapTriggerOld);
        updateEscalationTAT(lstTriggerNew,mapTriggerOld); // Added by coServe 13-11-2024
        //LocobuzzCaseAssignment.assignToProjectSpoc(lstTriggerNew); // Added by Vinay 16-01-2025 //Commented by Vinay 23-04-2025
        updateUnitWhenProjectChanged(lstTriggerNew, mapTriggerOld); // Added by Vinay 03-03-2025
        //assigneOwnerPostPossession(lstTriggerNew,mapTriggerOld); //Added by Vinay 07-03-2025
        //assigneOwnerPostPossession(lstTriggerNew); //Commented by Vinay 07-02-2026 to stop the FM team assignment for post possession cases.
        ownerAssignment(lstTriggerNew); //Added by Vinay 10-02-2026
    }
    
    public void onAfterInsert(list<Case> lstTriggerNew, map<id, Case> mapTriggerOld)
    {
        
        updateProjectUnit(lstTriggerNew); // Added by Vinay 28-02-2025
        //AutoClosePostPossessionCases.closePostPossessionCase(lstTriggerNew); // Added by Vinay 10-01-2025
        //shareCaseToPortalUser(lstTriggerNew);
        CreateTask(lstTriggerNew, null);	
        NotificationToRMOnCaseCrea(lstTriggerNew, null);
        CPPortalMethod(lstTriggerNew);
        //LocobuzzCaseAssignment.assignToProjectSpoc(lstTriggerNew); // Added by Vinay 16-01-2025
        
    }
    public void onAfterUpdate(list<Case> lstTriggerNew, map<id, Case> mapTriggerOld)
    {
        
        //CreateTask(lstTriggerNew, mapTriggerOld);  //Commented by Vinay 04-05-2025 to stop multiple tasks creation
        updateTaskOwner(lstTriggerNew, mapTriggerOld);
        List<String> projectChangedCaseIds = new List<String>();
        List<Id> oppUpdatedCaseIds = new List<Id>(); //Added by Vinay 27-11-2025
        if(checkRecursion.isFirstRun()){ 
            for(Case objCase : lstTriggerNew){
                if(objCase.Status != 'Case Closed'){
                   CPPortalEmailToCaseMethod(lstTriggerNew,mapTriggerOld); 
                }
                if(objCase.RW_Project__c != mapTriggerOld.get(objCase.Id).RW_Project__c){
                    projectChangedCaseIds.add(objCase.Id);
                }
                if(objCase.Opportunity__c != null && mapTriggerOld.get(objCase.Id).Opportunity__c != objCase.Opportunity__c){ //Added by Vinay 27-11-2025
                    oppUpdatedCaseIds.add(objCase.Id);
                }
            }
            
            //Added by Vinay 27-11-2025 Start
			System.debug('oppUpdatedCaseIds: ' + oppUpdatedCaseIds);
            if(oppUpdatedCaseIds.size() > 0){
                //Commented by Vinay 07-02-2026 to stop the FM team assignment for post possession cases.
                /*List<Case> cases = [SELECT Id,Opportunity__c,Opportunity__r.Booking__c,Opportunity__r.Booking__r.RW_Key_handover_date__c FROM Case WHERE Id =: oppUpdatedCaseIds AND Opportunity__r.Booking__r.RW_Key_handover_date__c != null AND FM_Team_Assigned__c = false];
                for(Case cs : cases){
                    cs.OwnerId = System.label.Default_Facility_Management_User;
                    cs.FM_Team_Assigned__c = true;
                }
                update cases;*/
            }
            //Added by Vinay 27-11-2025 End
            
           // sendWhatsAppFeedbackLink(lstTriggerNew,mapTriggerOld); // Added by coServe 30-10-2023
        }
        //assigneOwnerPostPossession(lstTriggerNew);
        
        //if(projectChangedCaseIds.size() > 0)
        	//updateUnitWhenProjectChanged(lstTriggerNew); // Added by Vinay 03-03-2025
    }
    
    //Added by Vinay 03-03-2025
    public static void updateUnitWhenProjectChanged(List<Case> lstCase, Map<Id, Case> mapTriggerOld){
        Set<String> accIds = new Set<String>();
        List<String> caseIds = new List<String>();
        List<Case> caseList = new List<Case>();
        for(Case c : lstCase){
            if(string.isNotBlank(c.AccountId) && c.RW_Project__c != mapTriggerOld.get(c.Id).RW_Project__c){
                accIds.add(c.AccountId);
                caseIds.add(c.Id);
                caseList.add(c);
            }
        }
        if(accIds.size() > 0){
            Map<String, List<Opportunity>> accVsOppMap = new Map<String, List<Opportunity>>();
            List<Opportunity> bookedOppList = [SELECT Id, AccountId, RW_Project_Unit__c, RW_Project__c, RW_RM_Name__c FROM Opportunity WHERE AccountId =: accIds AND StageName = 'Unit Booked' AND RW_Project_Unit__c != null ORDER BY Booking__r.Booking_Date__c DESC];
            for(Opportunity opp : bookedOppList){
                if(accVsOppMap.get(opp.AccountId) != null){
                    accVsOppMap.get(opp.AccountId).add(opp);
                }else{
                    accVsOppMap.put(opp.AccountId, new List<Opportunity>{opp});
                }
            }
            System.debug('accVsOppMap: ' + accVsOppMap);
            //List<Case> caseList = new List<Case>();
            //for(Case c : [SELECT Id, AccountId, RW_Project__c FROM Case WHERE Id =: caseIds]){
            for(Case c : caseList){
                if(accVsOppMap.get(c.AccountId) != null && accVsOppMap.get(c.AccountId).size() > 0){
                    System.debug('accVsOppMap: ' + accVsOppMap.get(c.AccountId));
                    for(Opportunity opp : accVsOppMap.get(c.AccountId)){
                        System.debug('accVsOppMap: ' + accVsOppMap.get(c.AccountId));
                        System.debug('opp.RW_Project__c: ' + opp.RW_Project__c);
                        System.debug('c.RW_Project__c: ' + c.RW_Project__c);
                        if(c.RW_Project__c == opp.RW_Project__c){
                            System.debug('opp.Id: ' + opp.Id);
                            //c.RW_Project_Unit__c = accVsOppMap.get(c.AccountId)[0].RW_Project_Unit__c;
                            //c.Opportunity__c = accVsOppMap.get(c.AccountId)[0].Id;
                            c.RW_Project_Unit__c = opp.RW_Project_Unit__c;
                            c.Opportunity__c = opp.Id;
                            //if(!caseList.contains(c))
                            	//caseList.add(c);
                        }
                    }
                }
            }
            //if(caseList.size() > 0)
                //update caseList;
        }
    }
    
    // Added by coServe 30-10-2023 Start //commented by Prashant - 19-06-24
   /* public static void sendWhatsAppFeedbackLink(list<Case> lstTriggerNew, Map<Id,Case> mapTriggerOld){  
        if(lstTriggerNew != null && lstTriggerNew.size() > 0){
            List<Id> accIds = new List<Id>();
            Map<String, String> accIdVsCaseNum = new Map<String, String>();
            Map<String, String> accIdVsCaseId = new Map<String, String>();
            for(Case cs : lstTriggerNew){
                if(cs.Status == 'Case Closed' && cs.Remarks_by_RM__c == 'Closed Satisfactory' && 
                   (cs.Status != mapTriggerOld.get(cs.Id).Status || cs.Remarks_by_RM__c != mapTriggerOld.get(cs.Id).Remarks_by_RM__c)){
                    accIds.add(cs.AccountId);
                    accIdVsCaseNum.put(cs.AccountId, cs.CaseNumber);
                    accIdVsCaseId.put(cs.AccountId, cs.Id);
                }
            }
            if(accIds.size() > 0){
                List<Account> accs = [SELECT Id, Name, Country_Code__c, Mobile_No__c FROM Account WHERE Id =: accIds];
                for(Account acc : accs){
                    //SendWhatsAppMsg.methodToSendWhatsAppMsg(accIdVsCaseId.get(acc.Id), acc.Name, accIdVsCaseNum.get(acc.Id), null, null, null, null, null, null, acc.Country_Code__c, acc.Mobile_No__c, 'case_closure_new');
                }
                
            }
        }
        
    }*/
    // Added by coServe 30-10-2023 End
    
    public void updateProjectField(list<Case> lsttriggernew, map<id,Case> triggeroldmap)
    {
        Map<String, Project_Keywords__c> mapOfProjectKeyword = Project_Keywords__c.getall();
        map<string,id> mapProjectnameWRTID = new map<string,id>();
        Id CustomerId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        if(lsttriggernew != null && lsttriggernew.size() > 0)
        {
            list<Project__c> lstProject = [select id,Name from Project__c];	
            
            for(Project__c objProject : lstProject)
            {
                mapProjectnameWRTID.put(objProject.name,objProject.id);
            }  
            
            map<string, string> mapOfKeyWords = new map<string, string>();
            for(String EachKey : mapOfProjectKeyword.keySet())
            {
                list<string> lstKey = mapOfProjectKeyword.get(EachKey).RW_Keyword__c.split(';');
                for(string EachSubKey : lstKey)
                    mapOfKeyWords.put(EachSubKey.tolowerCase(), EachKey);
            }	
            
            for(Case objCase : lsttriggernew)
            {
                if(objCase.Origin == 'Email' && objCase.Subject != null && objCase.RecordTypeId == CustomerId)
                {
                    if(mapOfKeyWords != null && mapOfKeyWords.size() > 0)
                    {
                        for(String EachProj : mapOfKeyWords.keySet())
                        {
                            if(objCase.Subject.tolowerCase().contains(EachProj) && mapProjectnameWRTID != null && mapProjectnameWRTID.size() > 0 && 
                               mapProjectnameWRTID.containsKey(mapOfKeyWords.get(EachProj)))
                            {
                                objCase.RW_Project__c = mapProjectnameWRTID.get(mapOfKeyWords.get(EachProj));
                            }
                        }
                    }	
                }
            }	
        }
    }
    
    /*private void updateOwnerToQueue(list<Case> lstTriggerNew, map<id,Case> triggeroldmap) //Commneted by Vinay 21-01-2025
    {
        Id CustomerId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        if(lstTriggerNew != null && lstTriggerNew.size() > 0)
        {
            set<string> setOfProjectId = new set<string>();
            for(Case EachCase : lstTriggerNew)
            {
                system.debug('@@@@EachCase.RW_Is_Owner_changed__c'+EachCase.RW_Is_Owner_changed__c);
                system.debug('@@@@triggeroldmap.get(EachCase.id).RW_Is_Owner_changed__c'+triggeroldmap.get(EachCase.id).RW_Is_Owner_changed__c);
                system.debug('@@@@EachCase.EachCase.Origin '+EachCase.Origin );
                system.debug('@@@@EachCase.RW_RM_Name__c'+EachCase.RW_RM_Name__c );
                if(EachCase.RW_Is_Owner_changed__c && !triggeroldmap.get(EachCase.id).RW_Is_Owner_changed__c && (EachCase.Origin == 'Email' || EachCase.Origin == 'Website')
                   && EachCase.RW_RM_Name__c == null && EachCase.RecordTypeId == CustomerId)
                {
                    setOfProjectId.add(EachCase.RW_Project__c);
                }
            }
            
            if(setOfProjectId != null && setOfProjectId.size() > 0)
            {
                map<string, Project__c> mapOfProj = new map<string, Project__c>([select id, name from Project__c where id in : setOfProjectId]);
                
                list<group> lstQueue = [select id, name from group where Type = 'Queue'];
                map<string, string> mapOfQueue = new map<string, string>();
                
                for(group EachGrp : lstQueue)
                {
                    mapOfQueue.put(EachGrp.name, EachGrp.id);
                }
                
                list<Case> lstCase2Update = new list<Case>();	
                //Database.DMLOptions options = new Database.DMLOptions();
                //options.assignmentRuleHeader.useDefaultRule = false;
                
                for(Case EachCase : lstTriggerNew)
                {
                    if(EachCase.RW_Is_Owner_changed__c && !triggeroldmap.get(EachCase.id).RW_Is_Owner_changed__c && (EachCase.Origin == 'Email' 
                                                                                                                     || EachCase.Origin == 'Website') && EachCase.RW_RM_Name__c == null)
                    {
                        if(mapOfQueue != null && mapOfQueue.size() > 0) 
                        {
                            if(EachCase.RW_Project__c != null && mapOfQueue.containsKey(mapOfProj.get(EachCase.RW_Project__c).name+'-Queue'))
                            {
                                EachCase.ownerid = mapOfQueue.get(mapOfProj.get(EachCase.RW_Project__c).name+'-Queue');
                            }
                            ///added by Rishi on 23-11-16 for assigning case to General Queue if Queue for the project is not present in the sytstem
                            else //if(!mapOfQueue.containsKey(mapOfProj.get(EachCase.RW_Project__c).name+'-Queue'))
                            {
                                EachCase.ownerid = mapofQueue.get(label.Generic_Queue_Name);
                                System.debug('#### Project Name ==  '+ EachCase.RW_Project__c);
                                System.debug('#### owner Changed ==  '+ EachCase.RW_Is_Owner_changed__c);
                                System.debug('#### RM Name ==  '+ EachCase.RW_RM_Name__c);
                                
                                
                            }
                        }
                    }
                }
            }
        }
    }*/
    
    /*private void updateOwnerByRMSelected(list<Case> lstCase,map<id,Case> triggerOldMap) //Commneted by Vinay 21-01-2025
    {
        //map<String,RM_Usernames__c> mapofRMUsernames = RM_Usernames__c.getall();
        Id CustomerId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        if(lstCase != null && lstCase.size() > 0)
        {
            set<string> setOfUserName = new set<string>();
            Set<String> namesOfUsers = new Set<String>();
            for(Case objCase: lstCase)
            {
                //if(objCase.RW_RM_Name__c != null && mapofRMUsernames != null && mapofRMUsernames.containsKey(objCase.RW_RM_Name__c) && objCase.RecordTypeId == CustomerId)
                if(objCase.RW_RM_Name__c != null && objCase.RecordTypeId == CustomerId)
                {
                    if(triggerOldMap == null && (objCase.Origin == 'Walk-in' || objCase.Origin == 'Portal'))
                    {
                        //setOfUserName.add(mapofRMUsernames.get(objCase.RW_RM_Name__c).User_Name__c);
                        namesOfUsers.add(objCase.RW_RM_Name__c);
                    }
                    else if(triggerOldMap != null && (triggerOldMap.get(objCase.id).RW_RM_Name__c != objCase.RW_RM_Name__c || (objCase.RW_Is_Owner_changed__c && 
                                                                                                                               !triggeroldmap.get(objCase.id).RW_Is_Owner_changed__c && (objCase.Origin == 'Email' 
                                                                                                                                                                                         || objCase.Origin == 'Website') && objCase.RW_RM_Name__c != null)))
                    {
                        //setOfUserName.add(mapofRMUsernames.get(objCase.RW_RM_Name__c).User_Name__c);
                        namesOfUsers.add(objCase.RW_RM_Name__c);
                    }
                }
            }
            
            //if(setOfUserName != null && setOfUserName.size() > 0)
            //{
                //list<User> lstUser = [select id, Username from User where Username in : setOfUserName];
            	list<User> lstUser = [select id, Name, Username from User where Name in : namesOfUsers AND IsActive = true];
                map<string, User> mapOfUser = new map<string, User>();
                if(lstUser != null && lstUser.size() > 0)
                {
                    for(User EachUser : lstUser)
                    {
                        //mapOfUser.put(EachUser.Username, EachUser);
                        mapOfUser.put(EachUser.Name, EachUser);
                    }
                    
                    for(Case objCase: lstCase)
                    {
                        //if(objCase.RW_RM_Name__c != null && mapofRMUsernames != null && mapofRMUsernames.containsKey(objCase.RW_RM_Name__c))
                        if(objCase.RW_RM_Name__c != null)
                        {
                            if(triggerOldMap == null && (objCase.Origin == 'Walk-in' || objCase.Origin == 'Portal'))
                            {
                                //if(mapOfUser.containsKey(mapofRMUsernames.get(objCase.RW_RM_Name__c).User_Name__c))
                                if(mapOfUser.containsKey(objCase.RW_RM_Name__c))
                                {
                                    //objCase.ownerId = mapOfUser.get(mapofRMUsernames.get(objCase.RW_RM_Name__c).User_Name__c).id;
                                    objCase.ownerId = mapOfUser.get(objCase.RW_RM_Name__c).id;
                                }
                            }
                            else if(triggerOldMap != null && (triggerOldMap.get(objCase.id).RW_RM_Name__c != objCase.RW_RM_Name__c || (objCase.RW_Is_Owner_changed__c && 
                                                                                                                                       !triggeroldmap.get(objCase.id).RW_Is_Owner_changed__c && (objCase.Origin == 'Email' 
                                                                                                                                                                                                 || objCase.Origin == 'Website') && objCase.RW_RM_Name__c != null)))
                            {
                                //if(mapOfUser.containsKey(mapofRMUsernames.get(objCase.RW_RM_Name__c).User_Name__c))
                                if(mapOfUser.containsKey(objCase.RW_RM_Name__c))
                                {
                                    //objCase.ownerId = mapOfUser.get(mapofRMUsernames.get(objCase.RW_RM_Name__c).User_Name__c).id;
                                    objCase.ownerId = mapOfUser.get(objCase.RW_RM_Name__c).id;
                                }
                            }
                        }
                    }
                }
            //}
        }
    }*/
    
    //changes made on 30/12 for the change in the requirement
    private void updateManagerEmail(list<Case> lstCase, map<id,Case> triggerOldMap)
    {
        Id CustomerId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        if(lstCase != null && lstCase.size() > 0)
        {
            Map<String, RM_Usernames__c> mapOfCustomSetting = RM_Usernames__c.getall();
            for(Case objCase : lstCase)
            {
                if(objCase.RW_RM_Name__c != null && mapOfCustomSetting.containsKey(objCase.RW_RM_Name__c) && objCase.RecordTypeId == CustomerId)
                {
                    objCase.RW_Immediate_Manager_Email__c = mapOfCustomSetting.get(objCase.RW_RM_Name__c).RW_Reporting_1_Email__c;
                    objCase.RW_Reporting_2_Email__c = mapOfCustomSetting.get(objCase.RW_RM_Name__c).RW_Reporting_2_Email__c;
                    objCase.RW_Reporting_3_Email__c = mapOfCustomSetting.get(objCase.RW_RM_Name__c).RW_Reporting_3_Email__c;
                    objCase.RW_Reporting_4_Email__c = mapOfCustomSetting.get(objCase.RW_RM_Name__c).RW_Reporting_4_Email__c;
                }
            }
            
            /*if(setOfOwner != null && setOfOwner.size() > 0)
{
map<string, user> mapOfUser = new map<string, user>([select id, managerid, manager.email, manager.managerId, manager.manager.email, 
manager.manager.managerId, manager.manager.manager.email, manager.manager.manager.managerId, 
manager.manager.manager.manager.email from user where id in: setOfOwner]);

if(mapOfUser != null && mapOfUser.size() > 0)
{
for(Case objCase : lstCase)
{
if(triggerOldMap == null || (triggerOldMap != null && triggerOldMap.get(objCase.id).ownerId != objCase.ownerId))
{
if(string.valueOf(objCase.ownerId).startsWith('005') && mapOfUser.containsKey(objCase.ownerId))
{
if(mapOfUser.get(objCase.ownerId).managerid != null)
objCase.RW_Immediate_Manager_Email__c = mapOfUser.get(objCase.ownerId).manager.email;

if(mapOfUser.get(objCase.ownerId).manager.managerId != null)
objCase.RW_Reporting_2_Email__c = mapOfUser.get(objCase.ownerId).manager.manager.email;

if(mapOfUser.get(objCase.ownerId).manager.manager.managerId != null)
objCase.RW_Reporting_3_Email__c = mapOfUser.get(objCase.ownerId).manager.manager.manager.email;

if(mapOfUser.get(objCase.ownerId).manager.manager.manager.managerId != null)
objCase.RW_Reporting_4_Email__c = mapOfUser.get(objCase.ownerId).manager.manager.manager.manager.email;
}
}
}
}
}*/
        }
    }
    
    private void updateEntitlementOnCase(list<Case> lstCase, map<id,Case> triggerOldMap)
    {
        Id CustomerId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        if(lstCase != null && lstCase.size() > 0)
        {
            list<Entitlement> lstEntitlement = [select id, Name 
                                                from Entitlement 
                                                where Name =:Label.Entitlement_Name or name =: Label.Reopen_Entitlement_Name or name =: Label.Resolved_Entitlement_Name];
            system.debug('@@@@lstEntitlement'+lstEntitlement);
            if(lstEntitlement != null && lstEntitlement.size() > 0)
            {
                map<string, Entitlement> mapOfEntitlement = new map<string, Entitlement>();
                for(Entitlement EachEntitle : lstEntitlement)
                {
                    mapOfEntitlement.put(EachEntitle.name, EachEntitle);
                }
                for(Case EachCase : lstCase)
                {
                    if(String.isBlank(EachCase.locobuzz__Locobuzz_ID__c) && !EachCase.Post_Possession_Customer__c){ //Added if condition by Vinay 05-02-2025
                        if(EachCase.ownerId != null && string.valueOf(EachCase.ownerId).startsWith('005') && EachCase.RecordTypeId == CustomerId)
                        {
                            if(EachCase.Status != 'Resolved' && EachCase.RW_Case_Reopened_Date__c == null)
                            {
                                if(triggerOldMap == null)
                                {
                                    EachCase.RW_Escalated_Time__c = system.now();
                                    EachCase.EntitlementId = mapOfEntitlement.get(Label.Entitlement_Name).id;
                                }
                                
                                else if(triggerOldMap != null && triggerOldMap.get(EachCase.id).ownerId != EachCase.ownerId)
                                {
                                    EachCase.RW_Escalated_Time__c = system.now();
                                    EachCase.EntitlementId = mapOfEntitlement.get(Label.Entitlement_Name).id;
                                }
                            }
                            
                            else if(EachCase.Status == 'Resolved' && triggerOldMap != null && triggerOldMap.get(EachCase.id).Status != EachCase.Status)
                            {
                                EachCase.RW_Escalated_Time__c = system.now();
                                EachCase.EntitlementId = mapOfEntitlement.get(Label.Resolved_Entitlement_Name).id;
                            }
                            
                            else if(EachCase.Status == 'Reopened' && triggerOldMap != null && triggerOldMap.get(EachCase.id).Status != EachCase.Status)
                            {
                                //EachCase.RW_Case_Reopened_Date__c = system.now();
                                EachCase.EntitlementId = mapOfEntitlement.get(Label.Reopen_Entitlement_Name).id;
                            }
                        }
                        
                        else if(EachCase.ownerId != null && !string.valueOf(EachCase.ownerId).startsWith('005') && EachCase.RecordTypeId == CustomerId)
                        {
                            EachCase.RW_Escalated_Time__c = null;
                            EachCase.EntitlementId = null;
                        }
                    }
                    
                }
            }
        }
    }
    
    public void updateProjectWeb(list<Case> lstCase)
    {
        Id CustomerId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        if(lstCase != null && lstCase.size() > 0)
        {
            for(Case objCase : lstCase)  
            {
                if(objCase.Origin == 'Website' && objCase.RecordTypeId == CustomerId)
                {
                    if(objCase.RW_Project_Text__c != null)
                        objCase.RW_Project__c = objCase.RW_Project_Text__c;
                    
                    if(objCase.RW_Project_Unit_Text__c != null)
                        objCase.RW_Project_Unit__c = objCase.RW_Project_Unit_Text__c;
                }
            }
        }	
    }
    
	//Added by Prashant- 20/11/24 for updating RMName as owner just for walkin cases.
    public void updateRMNameasOwnerforWalkinCases(list<Case> lstCase)
    {
        system.debug('Inside updateRMNameasOwnerforWalkinCases');
        Id CustomerId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        if(lstCase != null && lstCase.size() > 0)
        {
            for(Case objCase : lstCase)  
            {
                if(objCase.Origin == 'Walk-in' && objCase.RecordTypeId == CustomerId)
                {
                  	objCase.RW_RM_Name__c = objCase.RW_Owner_Name__c;
                }
            }
        }
    }
    
    
    //This method is used to create Task "Call Customer" Task under a Case
    public void CreateTask(list<Case> lstCase, map<id,Case> triggeroldmap)
    {
        Id CustomerId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        list<Task> lstTask = new list<Task>();
        if(lstCase != null && lstCase.size() > 0 )
        {
            list<RecordType> lstRecodType = [select Id from RecordType where Name =: Label.Case_task_record_type_Name and SobjectType = 'Task']; // Commented by coServe 20-092024
            //Id taskRecType = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Service Task').getRecordTypeId(); // Added by coServe 20-092024
            list<Case> lstCase2Update = new list<Case>();
            for(Case objCase : lstCase)
            {
                if(!objCase.RW_Is_Task_Created__c && objCase.RecordTypeId == CustomerId && String.isBlank(objCase.locobuzz__Locobuzz_ID__c) && objCase.Stop_Emails__c == false) //Added String.isBlank(objCase.locobuzz__Locobuzz_ID__c) by Vinay 17-03-2025
                {
                    if(objCase.ownerId != null && string.valueOf(objCase.ownerId).startsWith('005') && objCase.RW_Project__c != null) //Commented by Vinay 14-01-2025
                    //if(objCase.ownerId != null && string.valueOf(objCase.ownerId).startsWith('005') && objCase.RW_Project__c != null && objCase.Remarks_by_RM__c != 'Post Possession Customer') //Added by Vinay 14-01-2025
                    {
                        Task objTask = new Task();
                        if(lstRecodType != null && lstRecodType.size() > 0) // Commented by coServe 20-092024
                        {
                            objTask.recordtypeid = lstRecodType[0].id;
                        }
                        /*if(taskRecType != null){ // Added by coServe 20-092024
                            objTask.recordtypeid = taskRecType;
                        }*/
                        objTask.Subject = 'Call Customer';
                        objTask.Status = 'Not Started';
                        objTask.OwnerId = objCase.ownerid;
                        objTask.Project__c = objCase.RW_Project__c;
                        objTask.WhatId = objCase.id;
                        objTask.ActivityDate = system.today().adddays(integer.valueof(system.label.Task_DueDate));
                        objTask.Priority = 'Normal'; 
                        objTask.RW_RM_Name__c = objCase.RW_RM_Name__c;
                        
                        lstTask.add(objTask);
                        
                        Case newCase = new Case(id= objCase.id);
                        newCase.RW_Is_Task_Created__c = true;
                        lstCase2Update.add(newCase);
                    }
                }
                
            }
            
            
            if(lstTask != null && lstTask.size() > 0)
            {
                insert lstTask;
            }
            
            if(lstCase2Update != null && lstCase2Update.size() > 0)
            {
                update lstCase2Update;
            }
        }		
    }
    
    public void updateOwnersfieldonCase(list<Case> lsttriggernew, map<id,Case> triggeroldmap)
    {
        Id CPRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Channel Partner Portal').getRecordTypeId();
        system.debug('Inside debug updateOwnersfieldonCase'+lsttriggernew);
        system.debug('Inside debug updateOwnersfieldonCase'+triggeroldmap);
        List<Case> casesToUpdate = new List<Case>();
        for(Case c: lsttriggernew){
            System.debug('inside case');
            if(c.OwnerId != triggeroldmap.get(c.Id).OwnerId && c.RecordTypeId == CPRecordTypeId ){
                if(c.RW_Owner_Name__c != null){
                    system.debug('Owner'+c.RW_Owner_Name__c);
                    if(c.Owners__c != null && c.RW_Is_Escalated__c == true){
                        c.owners__c = c.owners__c + ', ' + c.RW_Owner_Name__c; 
                    }else{
                          c.owners__c = c.RW_Owner_Name__c ;
                    }
                  
                }
            }else if(c.Status=='Case Closed' && c.RecordTypeId == CPRecordTypeId){
                if(c.RW_Owner_Name__c != null){
                    if(c.Owners__c != null){
                        c.owners__c = c.owners__c + ', ' + c.RW_Owner_Name__c; 
                    } else{
                        c.owners__c = c.RW_Owner_Name__c ;
                    }
                }
            } 
            
        }

            
    }
    
    
    public void NotificationToRMOnCaseCrea(list<Case> lstCase, map<id,Case> triggeroldmap){
        System.debug('### lstCase size  '+lstCase.size());
        Id CustomerId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        list<Id> lstAccIds = new list<Id>();
        for(Case objCase : lstCase){
            if(objCase.AccountId != null && objCase.RecordTypeId == CustomerId){
                lstAccIds.add(objCase.AccountId);
            }
        }
        
        System.debug('#### lstAccIds '+lstAccIds);
        // Added by Mounika - Complaint Module - FRD-4
        List<Account> listOfAccs = [Select Id, Stop_Case_Emails__c, (Select Id,RW_Project_Unit__r.Relationship_Manager__r.user__c,RW_Project_Unit__r.Relationship_Manager__c,RW_Project_Unit__r.Relationship_Manager__r.RM_Email__c,StageName, Account.Stop_Case_Emails__c
                                               From Opportunities where StageName = 'Unit Booked') FROM Account  Where Id IN: lstAccIds];
        System.debug('#### listOfAccs '+listOfAccs);
        /*List<Opportunity> listOpportunities = [Select Id,RW_Project_Unit__r.Relationship_Manager__c,StageName 
From Opportunities where AccountId IN: lstAccIds And StageName = 'Unit Booked' ];*/
        Map<Id, Integer> mapOfopposize = new Map<Id, Integer>();
        Map<Id, List<Opportunity>> mapOfoppoties = new Map<Id, List<Opportunity>>();
        for(Account acc: listOfAccs){
            System.debug('#### acc.Opportunities '+acc.Opportunities.size());
            if(acc.Opportunities.size()>0){
                
                mapOfopposize.put(acc.Id, acc.Opportunities.size());
                List<Opportunity> listOfOppo = new List<Opportunity>();
                for(Opportunity oppo: acc.Opportunities){
                    listOfOppo.add(oppo);
                    System.debug('#### acc.Opportunities '+acc.Opportunities.size());
                }
                System.debug('#### listOfOppo '+listOfOppo.size());
                mapOfoppoties.put(acc.Id, listOfOppo);
            }
        }
        system.debug('mapOfoppoties '+mapOfoppoties.size());
        
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        EmailTemplate emailTemplate = [SELECT Body,DeveloperName,Id,Subject FROM EmailTemplate WHERE Name =: 'Notification To RM'];
        EmailTemplate emailTemplate1 = [SELECT Body,DeveloperName,Id,Subject FROM EmailTemplate WHERE Name =: 'Notification To RMs'];
        // contact con=[Select id from contact Where AccountId IN:listOfAccs limit 1];
        
        
        //Ends here
        for(Case objCase : lstCase)
        {
            if(!objCase.Post_Possession_Customer__c){
                
                
                system.debug('#### objCase '+objCase.Id);
                if(mapOfoppoties.containsKey(objCase.AccountId) && objCase.RecordTypeId == CustomerId){ // Commented by Vinay 14-01-2025
                    //if(mapOfoppoties.containsKey(objCase.AccountId) && objCase.RecordTypeId == CustomerId && objCase.Remarks_by_RM__c != 'Post Possession Customer'){ // Added by Vinay 14-01-2025
                    List<Opportunity> listOfoppoties = mapOfoppoties.get(objCase.AccountId);
                    system.debug('#### listOfoppoties '+listOfoppoties.size());
                    if(listOfoppoties.size() == 1){//auto email wont go when rm is the case owner?
                        system.debug('listOfoppoties '+listOfoppoties[0].RW_Project_Unit__r.Relationship_Manager__c);
                        if(listOfoppoties[0].RW_Project_Unit__r.Relationship_Manager__c != null){
                            system.debug('listOpportunities____Unit Blocked '+listOfoppoties[0].RW_Project_Unit__r.Relationship_Manager__c != null);
                            //objCase.OwnerId = listOfoppoties[0].RW_Project_Unit__r.Relationship_Manager__c;
                            System.debug('oppoRM____If'+listOfoppoties[0].RW_Project_Unit__r.Relationship_Manager__r.RM_Email__c);
                            if(objCase.ContactId != null && listOfoppoties[0].Account.Stop_Case_Emails__c == false && objCase.Stop_Emails__c == false){ // Added listOfoppoties[0].Account.Stop_Case_Emails__c by Vinay 21-05-2025
                                Messaging.SingleEmailMessage message =new Messaging.SingleEmailMessage();
                                message.setTargetObjectId(objCase.ContactId);
                                message.setTreatTargetObjectAsRecipient(false);
                                message.setWhatId(objCase.Id); 
                                message.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
                                message.setTemplateId(emailTemplate.id);
                                message.setUseSignature(false);
                                message.setBccSender(false);
                                message.setSaveAsActivity(false);
                                message.toaddresses = new string[]{listOfoppoties[0].RW_Project_Unit__r.Relationship_Manager__r.RM_Email__c};
                                    messages.add(message);  
                            }
                        }
                    }else{
                        for(Opportunity oppo: listOfoppoties){//we need to send email to RM and his manager
                            System.debug('oppoRM____else'+oppo.RW_Project_Unit__r.Relationship_Manager__r.RM_Email__c);
                            //if(objCase.ContactId != null){ //Commented by Vinay 18-03-2025
                            if(objCase.ContactId != null && oppo.RW_Project_Unit__r.Relationship_Manager__c != null && oppo.RW_Project_Unit__r.Relationship_Manager__r.RM_Email__c != null && oppo.Account.Stop_Case_Emails__c == false && objCase.Stop_Emails__c == false){ //Added by Vinay 18-03-2025
                                Messaging.SingleEmailMessage message =new Messaging.SingleEmailMessage();
                                message.setTargetObjectId(objCase.ContactId);
                                message.setTreatTargetObjectAsRecipient(false);
                                message.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
                                message.setTemplateId(emailTemplate1.id);
                                message.setUseSignature(false);
                                message.setBccSender(false);
                                message.setSaveAsActivity(false);
                                message.setWhatId(objCase.Id); 
                                message.toaddresses = new string[]{oppo.RW_Project_Unit__r.Relationship_Manager__r.RM_Email__c};
                                    messages.add(message); 
                            }
                        }
                    }
                }
            }
            if(messages.size()>0){
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                system.debug('Messaging ' + results[0]);
                
                if (results[0].success) {
                    System.debug('The email was sent successfully.');
                    
                } else{
                    System.debug('The email failed to send: ' + results[0].errors[0].message);
                }
            }
        }
    }
    //This Method is used to show error whenever User tries to update case status to contacted 
    public void showErrorforcontactedCase(list<Case> lstCase,map<id,Case> triggeroldmap)
    {
        Id CustomerId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        if(lstCase != null && lstCase.size() > 0)
        {
            set<id> setWhatid = new set<id>();
            for(Case objCase : lstCase)
            {
                if(objCase.status != null && triggeroldmap.get(objCase.id).status != objCase.status && objCase.status == 'Contacted' && objCase.RecordTypeId == CustomerId)
                {
                    setWhatid.add(objCase.id);		
                }
            }
            
            if(setWhatid != null && setWhatid.size() > 0)
            {
                list<Task> lstTask = [select id, Status, Subject, WhatId from Task where WhatId in : setWhatid and Subject =: 'Call Customer'];
                map<string, Task> mapOfTask = new map<string, Task>();
                
                for(Task EachTask : lstTask)
                {
                    mapOfTask.put(EachTask.WhatId, EachTask);
                }
                
                if(lstTask != null && lstTask.size() > 0)
                {
                    for(Case objCase : lstCase)
                    {
                        if(setWhatid.contains(objCase.id) && mapOfTask != null && mapOfTask.size() > 0 && mapOfTask.containsKey(objCase.id))
                        {
                            if(mapOfTask.get(objCase.id).Status != 'Completed')
                            {
                                objCase.addError('For Contacted, the call customer task must be completed.');
                            }
                        }
                        else
                        {
                            objCase.addError('For Contacted, the call customer task must be completed.');
                        }
                    }
                }
            }
        } 
    }
   /* private void AssignOwnertoGenQueue(list<Case> lstTriggernew) //commented by Prashant - 19-06-24
    {
        set<id> setownerId = new set<id>();
        if(lstTriggernew != null && lstTriggernew.size() > 0) 
        {
            for(Case objCase : lstTriggernew)
            {
                setownerId.add(objCase.ownerid);
            }
            Map<Id, User> ownerMap = new Map<Id, User>([ Select Id, ProfileId, Profile.Name, AccountId From User where Id IN: setownerId ]);	
            list<group> lstQueue = [select id, name from group where Type = 'Queue' and name =: label.Generic_Queue_Name];
            for(Case objCase : lstTriggernew)
            {
                if(ownerMap.containsKey(objCase.OwnerId) && ownerMap.get(objCase.OwnerId).ProfileId != null && 
                   ownerMap.get(objCase.OwnerId).Profile.name == 'Community Login User Custm' )
                {
                    objCase.RW_Case_Type__c = 'Query';
                    if(ownerMap.get(objCase.OwnerId).AccountId != null)
                        objCase.AccountId = ownerMap.get(objCase.OwnerId).AccountId;
                    objCase.RW_Case_Comming_From_Portal__c = objCase.ownerId;
                    if(lstQueue != null && lstQueue.size() > 0)
                        objCase.ownerId = lstQueue[0].id;
                }
            }
        }
    }*/
    
    /*private void shareCaseToPortalUser(list<Case> lstTriggernew) //commented by Prashant - 19-06-24
    {
        set<id> setownerId = new set<id>();
        if(lstTriggernew != null && lstTriggernew.size() > 0)
        {
            list<CaseShare> lstCaseShare = new list<CaseShare>();
            for(Case objCase : lstTriggernew)
            {
                if(objCase.RW_Case_Comming_From_Portal__c != null)
                {
                    CaseShare CaseShareRecord = new CaseShare();
                    CaseShareRecord.CaseAccessLevel = 'Read';
                    CaseShareRecord.UserOrGroupId = objCase.RW_Case_Comming_From_Portal__c;
                    CaseShareRecord.CaseId = objCase.id;
                    lstCaseShare.add(CaseShareRecord);
                }
            }
            if(lstCaseShare != null && lstCaseShare.size() > 0)
            {
                Database.SaveResult[] lstInsertResult = Database.insert(lstCaseShare,false);
                system.debug('@lstInsertResult________'+lstInsertResult);
            }
        }
    }*/
    
    private void updateTaskOwner(list<Case> lstCase,map<id,Case> triggeroldmap)
    {
        Id CustomerId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        if(lstCase != null && lstCase.size() > 0)
        {
            map<string, case> mapOfCaseId = new map<string, case>();
            for(Case objCase : lstCase)
            {
                if(objCase.ownerId != null && string.valueOf(objCase.ownerId).startsWith('005') && (triggeroldmap == null || 
                                                                                                    (triggeroldmap.get(objCase.id).ownerId != objCase.ownerId)) && objCase.RecordTypeId == CustomerId)
                {
                    mapOfCaseId.put(objCase.id, objCase);
                }
            }
            
            if(mapOfCaseId != null && mapOfCaseId.size() > 0)
            {
                list<task> lstTask = [select id, Ownerid, whatId from Task where whatId in: mapOfCaseId.keySet()];
                
                if(lstTask != null && lstTask.size() > 0)
                {
                    for(Task EachTask : lstTask)
                    {
                        EachTask.Ownerid = mapOfCaseId.get(EachTask.whatId).ownerId;
                    }
                    
                    update lstTask;
                }
            }
        }
    }
    public void CPPortalMethod(list<Case> lstCase){
        system.debug('@lstCase::'+lstCase);
        List<Contact> contact = new List<Contact>();
        List<Account> AccList = new List<Account>();
        List<Opportunity> opp = new List<Opportunity>();
        List<Project__c> proj = new List<Project__c>();
        List<Case> CaseUpdate = new List<Case>();
        Id ChannelPartnerId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Channel Partner Portal').getRecordTypeId();
        String Username;
        Id loggeduserId = UserInfo.getUserId();
        List<User> user = [SELECT Id, ContactId FROM User WHERE Id ='0059I0000078nh3QAA'];
        system.debug('@user::'+user);
        if(!user.isEmpty()){
            contact =[select id,Name,Email,AccountId from Contact where id =: user[0].ContactId];
        }
        system.debug('@contact::'+contact);
        if(lstCase != null && lstCase.size() > 0){
            //Added by Vinay 13-02-2025 Start
            Set<String> oppIds = new Set<String>();
            Set<String> projIds = new Set<String>();
            Map<String, String> oppIdVsProjId = new Map<String, String>();
            for(Case objCase : lstCase){
                if(objCase.Opportunity__c != null){
                    oppIds.add(objCase.Opportunity__c);
                }
            }
            Map<Id, Project__c> projMap;
            if(oppIds.size() > 0){
                opp = [Select Id,Name,RW_Sourcing_Manager__c,Sourcing_Manager_User__c,Sourcing_Manager_User__r.Name,RW_Project__c from Opportunity where Id=: oppIds]; // Added Sourcing_Manager_User__c,Sourcing_Manager_User__r.Name  by Vinay 04-12-2025
                for(Opportunity op : opp){
                    projIds.add(op.RW_Project__c);
                    oppIdVsProjId.put(op.Id, op.RW_Project__c);
                }
                if(projIds.size() > 0){
                    projMap = new Map<Id, Project__c>([Select Id,Name,MIS_User__r.Email,
                            MIS_User__r.Name,MIS_User__c from Project__c where id=: projIds]);
                    
                    
                }
            }
            //Fetch Team Members 
            Map<Id, Map<String, Team_Members__c>> projToApproverMap = TeamMemberService.getProjectTeamMembers( projIds, 'CP Case Escalation Team',  new List<String>{ 'CP Case L1 Escalation',  'CP Case L2 Escalation', 'CP Case L3 Escalation', 'CP Case L4 Escalation', 'CP Case L5 Escalation', 'CP Case L6 Escalation'});
            for(Case objCase : lstCase){
                if(objCase.Origin == 'Channel Partner Portal' && objCase.RecordTypeId == ChannelPartnerId){
                    system.debug('objCase.Origin------->'+objCase.Origin);
                    system.debug('objCase.RecordTypeId------->'+objCase.RecordTypeId);
                    Case c = new Case();
                    if(!contact.isEmpty() && contact[0].Id != null){
                        c.ContactId = contact[0].Id;
                        c.Account_Channel_Partner__c = contact[0].AccountId;
                    }
                    c.Id = objCase.Id;
                    if(objCase.Opportunity__c != null){
                        if(oppIdVsProjId.get(objCase.Opportunity__c) != null && projMap.get(oppIdVsProjId.get(objCase.Opportunity__c)) != null){                        
                            if(projMap.get(oppIdVsProjId.get(objCase.Opportunity__c)).Id != null){
                                c.RW_Project__c = projMap.get(oppIdVsProjId.get(objCase.Opportunity__c)).Id;
                            }
                            if(projMap.get(oppIdVsProjId.get(objCase.Opportunity__c)).Name != null){
                                c.RW_Project_Text__c = projMap.get(oppIdVsProjId.get(objCase.Opportunity__c)).Name;
                            }
                            Id projId = oppIdVsProjId.get(objCase.Opportunity__c);
                            if(projId!=null){
                                Map<String, Team_Members__c> approverMap = projToApproverMap.get(projId);
                                if (approverMap != null) {
                                    c.RW_Immediate_Manager_Email__c = approverMap.get('CP Case L1 Escalation')?.User__r.Email;
                                    c.RW_Reporting_2_Email__c      = approverMap.get('CP Case L2 Escalation')?.User__r.Email;
                                    c.RW_Reporting_3_Email__c      = approverMap.get('CP Case L3 Escalation')?.User__r.Email;
                                    c.RW_Reporting_4_Email__c      = approverMap.get('CP Case L4 Escalation')?.User__r.Email;
                                    c.RW_Reporting_5_Email__c      = approverMap.get('CP Case L5 Escalation')?.User__r.Email;
                                    c.RW_Reporting_6_Email__c      = approverMap.get('CP Case L6 Escalation')?.User__r.Email;
                                    system.debug('case l1--->'+approverMap.get('CP Case L1 Escalation').User__r.Email);
                                    system.debug('case l1--->'+approverMap.get('CP Case L1 Escalation').User__r.Name);
                                    system.debug('case l2--->'+approverMap.get('CP Case L2 Escalation').User__r.Email);
                                    system.debug('case l2--->'+approverMap.get('CP Case L2 Escalation').User__r.Name);
                                    system.debug('case l3--->'+approverMap.get('CP Case L3 Escalation').User__r.Email);
                                    system.debug('case l3--->'+approverMap.get('CP Case L3 Escalation').User__r.Name);
                                    system.debug('case l4--->'+approverMap.get('CP Case L4 Escalation').User__r.Email);
                                    system.debug('case l4--->'+approverMap.get('CP Case L4 Escalation').User__r.Name);
                                    system.debug('case l5--->'+approverMap.get('CP Case L5 Escalation').User__r.Email);
                                    system.debug('case l5--->'+approverMap.get('CP Case L5 Escalation').User__r.Name);
                                    system.debug('case l6--->'+approverMap.get('CP Case L6 Escalation').User__r.Email);
                                    system.debug('case l6--->'+approverMap.get('CP Case L6 Escalation').User__r.Name);
                                }
                       
                            }
                            
                            // if(projMap.get(oppIdVsProjId.get(objCase.Opportunity__c)).CP_Case_L1_Escalation__r.Email != null){  // Commented by Vinay 07-11-2025
                            //     c.RW_Immediate_Manager_Email__c = projMap.get(oppIdVsProjId.get(objCase.Opportunity__c)).CP_Case_L1_Escalation__r.Email;
                            // }
                            // if(projMap.get(oppIdVsProjId.get(objCase.Opportunity__c)).CP_Case_L2_Escalation__r.Email != null){
                            //     c.RW_Reporting_2_Email__c = projMap.get(oppIdVsProjId.get(objCase.Opportunity__c)).CP_Case_L2_Escalation__r.Email;
                            // }
                            // if(projMap.get(oppIdVsProjId.get(objCase.Opportunity__c)).CP_Case_L3_Escalation__r.Email != null){
                            //     c.RW_Reporting_3_Email__c = projMap.get(oppIdVsProjId.get(objCase.Opportunity__c)).CP_Case_L3_Escalation__r.Email;
                            // }
                            // if(projMap.get(oppIdVsProjId.get(objCase.Opportunity__c)).CP_Case_L4_Escalation__r.Email != null){
                            //     c.RW_Reporting_4_Email__c = projMap.get(oppIdVsProjId.get(objCase.Opportunity__c)).CP_Case_L4_Escalation__r.Email;
                            // }
                            // if(projMap.get(oppIdVsProjId.get(objCase.Opportunity__c)).CP_Case_L5_Escalation__r.Email != null){
                            //     c.RW_Reporting_5_Email__c = projMap.get(oppIdVsProjId.get(objCase.Opportunity__c)).CP_Case_L5_Escalation__r.Email;
                            // }
                            // if(projMap.get(oppIdVsProjId.get(objCase.Opportunity__c)).CP_Case_L6_Escalation__r.Email != null){
                            //     c.RW_Reporting_6_Email__c = projMap.get(oppIdVsProjId.get(objCase.Opportunity__c)).CP_Case_L6_Escalation__r.Email;
                            // }
                            if(projMap.get(oppIdVsProjId.get(objCase.Opportunity__c)).MIS_User__c != null){
                                c.OwnerId = projMap.get(oppIdVsProjId.get(objCase.Opportunity__c)).MIS_User__c;
                            }
                        }
                    }
                    CaseUpdate.add(c);
                }
                
            }
            
            //Added by Vinay 13-02-2025 End
            //Commented by Vinay 13-02-2025 Start
            // for(Case objCase : lstCase)
            // {
            //     if(objCase.Origin == 'Channel Partner Portal' && objCase.RecordTypeId == ChannelPartnerId){
            //         Case c = new Case();
                    
            //         if(contact[0].Id != null){
            //             c.ContactId = contact[0].Id;
            //             c.Account_Channel_Partner__c = contact[0].AccountId;
            //         }
                    
            //         c.Id = objCase.Id;
                    
            //         if(objCase.Opportunity__c != null){
            //             opp = [Select Id,Name,RW_Sourcing_Manager__c,RW_Project__c from Opportunity where Id=:objCase.Opportunity__c];
            //             system.debug('@opp::'+opp); 
                    
                    
            //             if(opp[0].RW_Project__c != null){
            //             proj = [Select Id,Name,CP_Case_L1_Escalation__r.Email,CP_Case_L2_Escalation__r.Email,CP_Case_L3_Escalation__r.Email,
            //                     CP_Case_L4_Escalation__r.Email,CP_Case_L5_Escalation__r.Email,CP_Case_L6_Escalation__r.Email,
            //                     MIS_User__r.Email,MIS_User__r.Name,MIS_User__c from Project__c where id=:opp[0].RW_Project__c];
            //             //system.debug('@MIS_User__r.Name::'+proj[0].MIS_User__r.Name);
            //         }
                    
                    
                    
            //             if(proj != null && proj.size() > 0){                        
            //             if(proj[0].Id != null){
            //                 c.RW_Project__c = proj[0].Id;
            //             }
            //             if(proj[0].Name != null){
            //                 c.RW_Project_Text__c = proj[0].Name;
            //             }
            //             if(proj[0].CP_Case_L1_Escalation__r.Email != null){
            //                 c.RW_Immediate_Manager_Email__c = proj[0].CP_Case_L1_Escalation__r.Email;
            //             }
            //             if(proj[0].CP_Case_L2_Escalation__r.Email != null){
            //                 c.RW_Reporting_2_Email__c = proj[0].CP_Case_L2_Escalation__r.Email;
            //             }
            //             if(proj[0].CP_Case_L3_Escalation__r.Email != null){
            //                 c.RW_Reporting_3_Email__c = proj[0].CP_Case_L3_Escalation__r.Email;
            //             }
            //             if(proj[0].CP_Case_L4_Escalation__r.Email != null){
            //                 c.RW_Reporting_4_Email__c = proj[0].CP_Case_L4_Escalation__r.Email;
            //             }
            //             if(proj[0].CP_Case_L5_Escalation__r.Email != null){
            //                 c.RW_Reporting_5_Email__c = proj[0].CP_Case_L5_Escalation__r.Email;
            //             }
            //                 if(proj[0].CP_Case_L6_Escalation__r.Email != null){
            //                     c.RW_Reporting_6_Email__c = proj[0].CP_Case_L6_Escalation__r.Email;
            //                 }
            //             if(proj[0].MIS_User__c != null){
            //                 c.OwnerId = proj[0].MIS_User__c;
            //             }
            //         }
            //        /* if(c.RW_Case_Escalation__c == 'First Escalation' && c.IsEscalated == true){
            //             c.Current_Stage__c = 'CP-L3';
            //         }*/
            //         }
            //         CaseUpdate.add(c);
            //     }               
            // }
            //Commented by Vinay 13-02-2025 End
            system.debug('@CaseUpdate::'+CaseUpdate);
            update CaseUpdate;
        }
    }
    public void CPPortalEmailToCaseMethod(list<Case> lstCase,map<id,Case> triggeroldmap){
        List<Contact> contact = new List<Contact>();
        List<Account> AccList = new List<Account>();
        List<Opportunity> opp = new List<Opportunity>();
        List<Project__c> proj = new List<Project__c>();
        List<Case> CaseUpdate = new List<Case>();
        Id ChannelPartnerId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Channel Partner Portal').getRecordTypeId();
        String Username;
        Id loggeduserId = UserInfo.getUserId();
        List<User> user = [SELECT Id, ContactId FROM User WHERE Id =:loggeduserId];
        system.debug('@user::'+user);
        if(lstCase != null && lstCase.size() > 0){
            //Added by Vinay 13-02-2025 Start
            Set<String> emails = new Set<String>();
            Set<String> projectIds = new Set<String>();
            for(Case objCase : lstCase){
                emails.add(objCase.SuppliedEmail);
                if(objCase.RW_Project__c != null)
                    projectIds.add(objCase.RW_Project__c);
            }
            contact =[select id,Name,Email,AccountId from Contact where Email =: emails and Channel_Partner_Portal_Activated__c = true];
            Map<String, Contact> contactMap = new Map<String, Contact>();
            for(Contact c : contact){
                contactMap.put(c.Email, c);
            }
            Map<Id, Project__c> projMap;
            if(projectIds.size() > 0){
                projMap = new Map<Id, Project__c>([Select Id,Name,
                                   MIS_User__r.Email,MIS_User__r.Name,MIS_User__c from Project__c where id =: projectIds]);
            }
            //Fetch Team Members 
            Map<Id, Map<String, Team_Members__c>> projToApproverMap =
                TeamMemberService.getProjectTeamMembers(
                    projectIds,
                    'CP Case Escalation Team',
                    new List<String>{ 'CP Case L1 Escalation',  'CP Case L2 Escalation', 'CP Case L3 Escalation', 'CP Case L4 Escalation', 'CP Case L5 Escalation', 'CP Case L6 Escalation'}
                );

            for(Case objCase : lstCase){
                Case c = new Case();
                if(contactMap.get(objCase.SuppliedEmail) != null){
                    c.ContactId = contactMap.get(objCase.SuppliedEmail).Id;
                    c.Account_Channel_Partner__c = contactMap.get(objCase.SuppliedEmail).AccountId;
                }
                c.Id = objCase.Id;
                
                if((objCase.Origin == 'Email - Channel Partner' || objCase.Origin == 'Channel Partner Portal') && objCase.RecordTypeId == ChannelPartnerId && objCase.Case_Category__c != null && objCase.Case_Sub_Category__c != null && objCase.RW_Project__c != null){
                    if(projMap.get(objCase.RW_Project__c).Name != null){
                        c.RW_Project_Text__c = projMap.get(objCase.RW_Project__c).Name;
                    }
                    Id projId = objCase.RW_Project__c;
                    if(projId!=null){
                        system.debug('CPPortalEmailToCaseMethod----->projId----->'+projId);
                        Map<String, Team_Members__c> approverMap = projToApproverMap.get(projId);
                        if (approverMap != null) {
                            c.RW_Immediate_Manager_Email__c = approverMap.get('CP Case L1 Escalation')?.User__r.Email;
                            c.RW_Reporting_2_Email__c      = approverMap.get('CP Case L2 Escalation')?.User__r.Email;
                            c.RW_Reporting_3_Email__c      = approverMap.get('CP Case L3 Escalation')?.User__r.Email;
                            c.RW_Reporting_4_Email__c      = approverMap.get('CP Case L4 Escalation')?.User__r.Email;
                            c.RW_Reporting_5_Email__c      = approverMap.get('CP Case L5 Escalation')?.User__r.Email;
                            c.RW_Reporting_6_Email__c      = approverMap.get('CP Case L6 Escalation')?.User__r.Email;
                            system.debug('case l1--->'+approverMap.get('CP Case L1 Escalation').User__r.Email);
                            system.debug('case l1--->'+approverMap.get('CP Case L1 Escalation').User__r.Name);
                            system.debug('case l2--->'+approverMap.get('CP Case L2 Escalation').User__r.Email);
                            system.debug('case l2--->'+approverMap.get('CP Case L2 Escalation').User__r.Name);
                            system.debug('case l3--->'+approverMap.get('CP Case L3 Escalation').User__r.Email);
                            system.debug('case l3--->'+approverMap.get('CP Case L3 Escalation').User__r.Name);
                            system.debug('case l4--->'+approverMap.get('CP Case L4 Escalation').User__r.Email);
                            system.debug('case l4--->'+approverMap.get('CP Case L4 Escalation').User__r.Name);
                            system.debug('case l5--->'+approverMap.get('CP Case L5 Escalation').User__r.Email);
                            system.debug('case l5--->'+approverMap.get('CP Case L5 Escalation').User__r.Name);
                            system.debug('case l6--->'+approverMap.get('CP Case L6 Escalation').User__r.Email);
                            system.debug('case l6--->'+approverMap.get('CP Case L6 Escalation').User__r.Name);
                        }
                        // List<Team_Members__c> tmList = projIdToTeam.get(projId);
                        // if (tmList != null && !tmList.isEmpty()) {
                        //             for (Team_Members__c tm : tmList) {
                        //                 if (tm.User__r != null && tm.User__r.Email != null) {
                        //                     if (tm.Approver_Type__c == 'CP Case L1 Escalation') {
                        //                         system.debug('tm.User__r.Name-------->1'+tm.User__r.Name);
                        //                         system.debug('tm.User__r.Email-------->1'+tm.User__r.Email);
                        //                         c.RW_Immediate_Manager_Email__c = tm.User__r.Email;
                        //                     }
                        //                     if (tm.Approver_Type__c == 'CP Case L2 Escalation') {
                        //                         system.debug('tm.User__r.Name-------->2'+tm.User__r.Name);
                        //                         system.debug('tm.User__r.Email-------->2'+tm.User__r.Email);
                        //                         c.RW_Reporting_2_Email__c = tm.User__r.Email;
                        //                     }
                        //                     if (tm.Approver_Type__c == 'CP Case L3 Escalation') {
                        //                         system.debug('tm.User__r.Name-------->3'+tm.User__r.Name);
                        //                         system.debug('tm.User__r.Email-------->3'+tm.User__r.Email);
                        //                         c.RW_Reporting_3_Email__c = tm.User__r.Email;
                        //                     }
                        //                     if (tm.Approver_Type__c == 'CP Case L4 Escalation') {
                        //                         system.debug('tm.User__r.Name-------->4'+tm.User__r.Name);
                        //                         system.debug('tm.User__r.Email-------->4'+tm.User__r.Email);
                        //                         c.RW_Reporting_4_Email__c = tm.User__r.Email;
                        //                     }
                        //                     if (tm.Approver_Type__c == 'CP Case L5 Escalation') {
                        //                         system.debug('tm.User__r.Name-------->5'+tm.User__r.Name);
                        //                         system.debug('tm.User__r.Email-------->5'+tm.User__r.Email);
                        //                         c.RW_Reporting_5_Email__c = tm.User__r.Email;
                        //                     }
                        //                     if (tm.Approver_Type__c == 'CP Case L6 Escalation') {
                        //                         system.debug('tm.User__r.Name-------->6'+tm.User__r.Name);
                        //                         system.debug('tm.User__r.Email-------->6'+tm.User__r.Email);
                        //                         c.RW_Reporting_6_Email__c = tm.User__r.Email;
                        //                     }
                        //                 }
                        //             }
                        // }
                    }
                    // if(projMap.get(objCase.RW_Project__c).CP_Case_L1_Escalation__r.Email != null){
                    //     c.RW_Immediate_Manager_Email__c = projMap.get(objCase.RW_Project__c).CP_Case_L1_Escalation__r.Email;
                    // }
                    // if(projMap.get(objCase.RW_Project__c).CP_Case_L2_Escalation__r.Email != null){
                    //     c.RW_Reporting_2_Email__c = projMap.get(objCase.RW_Project__c).CP_Case_L2_Escalation__r.Email;
                    // }
                    // if(projMap.get(objCase.RW_Project__c).CP_Case_L3_Escalation__r.Email != null){
                    //     c.RW_Reporting_3_Email__c = projMap.get(objCase.RW_Project__c).CP_Case_L3_Escalation__r.Email;
                    // }
                    // if(projMap.get(objCase.RW_Project__c).CP_Case_L4_Escalation__r.Email != null){
                    //     c.RW_Reporting_4_Email__c = projMap.get(objCase.RW_Project__c).CP_Case_L4_Escalation__r.Email;
                    // }
                    // if(projMap.get(objCase.RW_Project__c).CP_Case_L5_Escalation__r.Email != null){
                    //     c.RW_Reporting_5_Email__c = projMap.get(objCase.RW_Project__c).CP_Case_L5_Escalation__r.Email;
                    // }
                    // if(projMap.get(objCase.RW_Project__c).CP_Case_L6_Escalation__r.Email != null){
                    //     c.RW_Reporting_6_Email__c = projMap.get(objCase.RW_Project__c).CP_Case_L6_Escalation__r.Email;
                    // }
                    if(projMap.get(objCase.RW_Project__c).MIS_User__c != null){
                        c.OwnerId = projMap.get(objCase.RW_Project__c).MIS_User__c;
                    }
                    
                    CaseUpdate.add(c);
                }
            }
            
            //Added by Vinay 13-02-2025 End
            //
            //Commented by Vinay 13-02-2025 Start
            // for(Case objCase : lstCase)
            // {
            //     contact =[select id,Name,Email,AccountId from Contact where Email =: objCase.SuppliedEmail and Channel_Partner_Portal_Activated__c = true];   
            //     Case c = new Case();
            //     if(contact.size() > 0){
            //         if(contact[0].Id != null){
            //             c.ContactId = contact[0].Id;
            //             c.Account_Channel_Partner__c = contact[0].AccountId;
            //         }
            //     }
                
            //     c.Id = objCase.Id;
            //     if((objCase.Origin == 'Email - Channel Partner' || objCase.Origin == 'Channel Partner Portal') && objCase.RecordTypeId == ChannelPartnerId/* && 
            //        objCase.Opportunity__c != null*/ && objCase.Case_Category__c != null && objCase.Case_Sub_Category__c != null && objCase.RW_Project__c != null){
            //            //opp = [Select Id,Name,RW_Sourcing_Manager__c,RW_Project__c from Opportunity where Id=:objCase.Opportunity__c];
            //             //system.debug('@opp::'+opp);
            //            if(objCase.RW_Project__c != null){
            //                proj = [Select Id,Name,CP_Case_L1_Escalation__r.Email,CP_Case_L2_Escalation__r.Email,CP_Case_L3_Escalation__r.Email,
            //                        CP_Case_L4_Escalation__r.Email,CP_Case_L5_Escalation__r.Email,CP_Case_L6_Escalation__r.Email,
            //                        MIS_User__r.Email,MIS_User__r.Name,MIS_User__c from Project__c where id=:objCase.RW_Project__c];
            //                //system.debug('@MIS_User__r.Name::'+proj[0].MIS_User__r.Name);
            //            }
                       
            //            /*if(proj[0].Id != null){
            //                c.RW_Project__c = proj[0].Id;
            //            }*/
            //            if(proj[0].Name != null){
            //                c.RW_Project_Text__c = proj[0].Name;
            //            }
            //            if(proj[0].CP_Case_L1_Escalation__r.Email != null){
            //                c.RW_Immediate_Manager_Email__c = proj[0].CP_Case_L1_Escalation__r.Email;
            //            }
            //            if(proj[0].CP_Case_L2_Escalation__r.Email != null){
            //                c.RW_Reporting_2_Email__c = proj[0].CP_Case_L2_Escalation__r.Email;
            //            }
            //            if(proj[0].CP_Case_L3_Escalation__r.Email != null){
            //                c.RW_Reporting_3_Email__c = proj[0].CP_Case_L3_Escalation__r.Email;
            //            }
            //            if(proj[0].CP_Case_L4_Escalation__r.Email != null){
            //                c.RW_Reporting_4_Email__c = proj[0].CP_Case_L4_Escalation__r.Email;
            //            }
            //            if(proj[0].CP_Case_L5_Escalation__r.Email != null){
            //                c.RW_Reporting_5_Email__c = proj[0].CP_Case_L5_Escalation__r.Email;
            //            }
            //            if(proj[0].CP_Case_L6_Escalation__r.Email != null){
            //                c.RW_Reporting_6_Email__c = proj[0].CP_Case_L6_Escalation__r.Email;
            //            }
            //            if(proj[0].MIS_User__c != null){
            //                c.OwnerId = proj[0].MIS_User__c;
            //            }
                       
            //            CaseUpdate.add(c);
            //        }               
            // }
            //Commented by Vinay 13-02-2025 End
            
            
            system.debug('@CaseUpdate::'+CaseUpdate);
            update CaseUpdate;
        }
    }
     public void updatecasestatus(list<Case> lstCase)
    {
        Id ChannelPartnerId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Channel Partner Portal').getRecordTypeId();
        if(lstCase != null && lstCase.size() > 0)
        {
            for(Case objCase : lstCase)  
            {
                if(objCase.RecordTypeId == ChannelPartnerId)
                {
                    objCase.Status = 'Open';
                }
                /*if(objCase.Subject != null && objCase.Subject.contains('Undeliverable:') || objCase.SuppliedName == 'microsoftexchange'){ //Added by Vinay 26-05-2025
                    objCase.Status = 'Case Closed';
                    objCase.Stop_Emails__c = true;
                    objCase.RW_RM_Remarks__c = 'Undeliverable';
                }*/
            }
        }	
    }
    
    //Added by Vinay 13-11-2024 Start
    public void updateEscalationTAT(List<Case> lstCase, Map<Id,Case> oldmap){
        
        //Map<String, Case_Escalation_Matrix_SLA__c> escalationSLA = Case_Escalation_Matrix_SLA__c.getall();
        List<Case_Escalation_Matrix_SLA__c> escalationSLA = [SELECT Id, Active__c, Case_Sub_Type__c, Case_Type__c, Customer_Lifecycle_Touchpoint__c, SLA__c FROM Case_Escalation_Matrix_SLA__c WHERE Active__c = true];
        if(escalationSLA.size() > 0){
            for(Case cs : lstCase){
                if(cs.Status == 'Reopened'){
                    cs.Escalation_Level__c = 'New';
                }
                if(String.isBlank(cs.locobuzz__Locobuzz_ID__c)){ //Added if condition by Vinay 05-02-2025
                    system.debug('oldmap'+oldmap);
                    if(oldmap != null && cs.RW_Case_Type__c == 'Complaint' && (cs.Status == 'Case Closed' && oldmap.get(cs.Id).Status != 'Case Closed') && (cs.Customer_Lifecycle_Touchpoint__c == null || cs.RW_Complaint_Type__c == null || cs.RW_Complaint_SubType__c == null) && cs.CreatedDate.date() >= Date.newInstance(2025, 3, 29)){
                        cs.addError('Please fill Customer Lifecycle Touchpoint, Complaint Type & Complaint Subtype');
                    }
                    if(oldmap == null && cs.Customer_Lifecycle_Touchpoint__c != null && cs.RW_Complaint_Type__c != null && cs.RW_Complaint_SubType__c != null){
                        for(Case_Escalation_Matrix_SLA__c mat : escalationSLA){
                            if(cs.Customer_Lifecycle_Touchpoint__c == mat.Customer_Lifecycle_Touchpoint__c && cs.RW_Complaint_Type__c == mat.Case_Type__c && cs.RW_Complaint_SubType__c == mat.Case_Sub_Type__c){
                                cs.Case_Escalation_TAT__c = mat.SLA__c;
                            }
                        }
                    }
                    else if(cs.Customer_Lifecycle_Touchpoint__c != null && cs.RW_Complaint_Type__c != null && cs.RW_Complaint_SubType__c != null){//null check added by Prashant on 18/11/24 4.23 pm to avoid getting null error while email to case creation
                        if(oldmap.get(cs.Id) != null && (cs.RW_Complaint_Type__c != oldmap.get(cs.Id).RW_Complaint_Type__c && cs.RW_Complaint_SubType__c != oldmap.get(cs.Id).RW_Complaint_SubType__c)){
                            for(Case_Escalation_Matrix_SLA__c mat : escalationSLA){
                                if(cs.Customer_Lifecycle_Touchpoint__c == mat.Customer_Lifecycle_Touchpoint__c && cs.RW_Complaint_Type__c == mat.Case_Type__c && cs.RW_Complaint_SubType__c == mat.Case_Sub_Type__c){
                                    cs.Case_Escalation_TAT__c = mat.SLA__c;
                                }
                            }
                        }                
                    }
                }
            } 
        }
    }
    //Added by Vinay 13-11-2024 End
    
    //Added by Vinay 20-01-2025 Start
    private void updateOwnerAsRmOrQueue(list<Case> lstTriggerNew, map<id,Case> triggeroldmap){
        Id CustomerId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        if(lstTriggerNew != null && lstTriggerNew.size() > 0){
            List<String> casesWithRmAsOwner = new List<String>();
            List<Case> casesToUpdate = new List<Case>();
            Set<String> namesOfUsers = new Set<String>();
            for(Case cs : lstTriggerNew){
                if(cs.locobuzz__Locobuzz_ID__c == null && cs.RW_RM_Name__c != null && cs.RecordTypeId == CustomerId && triggerOldMap.get(cs.id).RW_RM_Name__c != cs.RW_RM_Name__c || (cs.RW_Is_Owner_changed__c && !triggeroldmap.get(cs.id).RW_Is_Owner_changed__c && (cs.Origin == 'Email' || cs.Origin == 'Website' || cs.Origin == 'Portal')) && cs.FM_Team_Assigned__c == false){ //Added cs.FM_Team_Assigned__c == false by Vinay 21-04-2025
                    namesOfUsers.add(cs.RW_RM_Name__c);
                    casesToUpdate.add(cs);
                }
            }
            if(namesOfUsers.size() > 0){
                List<String> profiles = System.label.Case_Owner_Assignment_Profiles.split(',');
                List<User> lstUser = [SELECT Id, Name, Username FROM User WHERE Name In : namesOfUsers AND Profile.Name =: profiles AND IsActive = true];
                Map<String, User> mapOfUser = new Map<String, User>();
                if(lstUser != null && lstUser.size() > 0){
                    for(User EachUser : lstUser){
                        mapOfUser.put(EachUser.Name, EachUser);
                    }
                }
                
                for(Case objCase: casesToUpdate){
                    System.debug('objCase.Post_Possession_Customer__c: ' + objCase.Post_Possession_Customer__c);
                    if(mapOfUser.containsKey(objCase.RW_RM_Name__c) && !objCase.Post_Possession_Customer__c){
                        objCase.ownerId = mapOfUser.get(objCase.RW_RM_Name__c).id;
                        casesWithRmAsOwner.add(objCase.id);
                    }
                }
            }
            
            set<string> setOfProjectId = new set<string>();
            List<Case> cases = new List<Case>();
            for(Case cs : lstTriggerNew){
                if(cs.locobuzz__Locobuzz_ID__c == null && cs.RW_Is_Owner_changed__c && !triggeroldmap.get(cs.id).RW_Is_Owner_changed__c && (cs.Origin == 'Email' || cs.Origin == 'Website') && cs.RW_RM_Name__c == null && cs.RecordTypeId == CustomerId && cs.FM_Team_Assigned__c == false){ //Added cs.FM_Team_Assigned__c == false by Vinay 21-04-2025
                    setOfProjectId.add(cs.RW_Project__c);
                    if(!casesWithRmAsOwner.contains(cs.Id) && !cs.Post_Possession_Customer__c){
                        cases.add(cs);
                    }
                }
            }
            if(setOfProjectId != null && setOfProjectId.size() > 0){
                map<string, Project__c> mapOfProj = new map<string, Project__c>([select id, name from Project__c where id in : setOfProjectId]);
                list<group> lstQueue = [select id, name from group where Type = 'Queue'];
                map<string, string> mapOfQueue = new map<string, string>();
                
                for(group EachGrp : lstQueue){
                    mapOfQueue.put(EachGrp.name, EachGrp.id);
                }
                for(Case cs : cases){
                    if(cs.RW_Project__c != null && mapOfQueue.containsKey(mapOfProj.get(cs.RW_Project__c).name+'-Queue')){
                        cs.ownerid = mapOfQueue.get(mapOfProj.get(cs.RW_Project__c).name+'-Queue');
                    }
                    else{
                        cs.ownerid = mapofQueue.get(label.Generic_Queue_Name);  
                    }
                }
            }
        }
    }
    //Added by Vinay 20-01-2025 End
    
    public void createTask()
    {
        integer a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
         a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
         a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
        a = 0;
    }
}