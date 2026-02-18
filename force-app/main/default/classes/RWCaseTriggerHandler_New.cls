public class RWCaseTriggerHandler_New {

    public void runTrigger(){
        // Method will be called to handle Before insert events
        if (Trigger.isBefore && Trigger.isInsert){
            onBeforeInsert((list<Case>) trigger.new, (map<id, Case>) trigger.OldMap);
        }
        // Method will be called to handle Before Update events
        if (Trigger.isBefore && Trigger.isUpdate){
            onBeforeUpdate((list<Case>) trigger.new, (map<id, Case>) trigger.OldMap);
        }
        // Method will be called to handle After Insert events
        if (Trigger.isAfter && Trigger.isInsert){
            onAfterInsert((list<Case>) trigger.new, (map<id, Case>) trigger.OldMap);
        }
        
        // Method will be called to handle After Update eventssss
        if (Trigger.isAfter && Trigger.isUpdate){
            onAfterUpdate((list<Case>) trigger.new, (map<id, Case>) trigger.OldMap);
        }
        
    }
    
    public void onBeforeInsert(list<Case> lstTriggerNew, map<id, Case> mapTriggerOld){
        Id CustomerId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id ChannelPartnerId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Channel Partner Portal').getRecordTypeId();
        Map<String, RM_Usernames__c> mapOfCustomSetting = RM_Usernames__c.getall();
        Map<String, Project_Keywords__c> mapOfProjectKeyword = Project_Keywords__c.getall();
        map<string,id> mapProjectnameWRTID = new map<string,id>();
        map<string, Entitlement> mapOfEntitlement = new map<string, Entitlement>();
        list<group> lstQueue = [select id, name from group where Type = 'Queue'];
        map<string, string> mapOfQueue = new map<string, string>();
        for(group EachGrp : lstQueue){
            mapOfQueue.put(EachGrp.name, EachGrp.id);
        }
        list<Project__c> lstProject = [select id,Name from Project__c];
        for(Project__c objProject : lstProject){
            mapProjectnameWRTID.put(objProject.name,objProject.id);
        } 
        
        map<string, string> mapOfKeyWords = new map<string, string>();
        for(String EachKey : mapOfProjectKeyword.keySet()){
            list<string> lstKey = mapOfProjectKeyword.get(EachKey).RW_Keyword__c.split(';');
            for(string EachSubKey : lstKey)
                mapOfKeyWords.put(EachSubKey.tolowerCase(), EachKey);
        }	
        list<Entitlement> lstEntitlement = [select id, Name from Entitlement where Name =:Label.Entitlement_Name or name =: Label.Reopen_Entitlement_Name or name =: Label.Resolved_Entitlement_Name];
        if(lstEntitlement != null && lstEntitlement.size() > 0){
           
            for(Entitlement EachEntitle : lstEntitlement){
                mapOfEntitlement.put(EachEntitle.name, EachEntitle);
            }
        }
        for(Case objCase : lstTriggerNew){
            if(objCase.Origin == 'Website' && objCase.RecordTypeId == CustomerId){
                if(objCase.RW_Project_Text__c != null)
                    objCase.RW_Project__c = objCase.RW_Project_Text__c;
                
                if(objCase.RW_Project_Unit_Text__c != null)
                    objCase.RW_Project_Unit__c = objCase.RW_Project_Unit_Text__c;
            }
            
            if(objCase.Origin == 'Email' && objCase.Subject != null && objCase.RecordTypeId == CustomerId){
                if(mapOfKeyWords != null && mapOfKeyWords.size() > 0){
                    for(String EachProj : mapOfKeyWords.keySet()){
                        if(objCase.Subject.tolowerCase().contains(EachProj) && mapProjectnameWRTID != null && mapProjectnameWRTID.size() > 0 && 
                           mapProjectnameWRTID.containsKey(mapOfKeyWords.get(EachProj))){
                            objCase.RW_Project__c = mapProjectnameWRTID.get(mapOfKeyWords.get(EachProj));
                        }
                    }
                }	
            }
            
            if(objCase.RW_RM_Name__c != null && mapOfCustomSetting.containsKey(objCase.RW_RM_Name__c) && objCase.RecordTypeId == CustomerId){
                objCase.RW_Immediate_Manager_Email__c = mapOfCustomSetting.get(objCase.RW_RM_Name__c).RW_Reporting_1_Email__c;
                objCase.RW_Reporting_2_Email__c = mapOfCustomSetting.get(objCase.RW_RM_Name__c).RW_Reporting_2_Email__c;
                objCase.RW_Reporting_3_Email__c = mapOfCustomSetting.get(objCase.RW_RM_Name__c).RW_Reporting_3_Email__c;
                objCase.RW_Reporting_4_Email__c = mapOfCustomSetting.get(objCase.RW_RM_Name__c).RW_Reporting_4_Email__c;
            }
            
            if(String.isBlank(objCase.locobuzz__Locobuzz_ID__c) && !objCase.Post_Possession_Customer__c){ //Added if condition by Vinay 05-02-2025
                if(objCase.ownerId != null && string.valueOf(objCase.ownerId).startsWith('005') && objCase.RecordTypeId == CustomerId){
                    if(objCase.Status != 'Resolved' && objCase.RW_Case_Reopened_Date__c == null){
                        objCase.RW_Escalated_Time__c = system.now();
                        objCase.EntitlementId = mapOfEntitlement.get(Label.Entitlement_Name).id;
                    }
                }else if(objCase.ownerId != null && !string.valueOf(objCase.ownerId).startsWith('005') && objCase.RecordTypeId == CustomerId){
                    objCase.RW_Escalated_Time__c = null;
                    objCase.EntitlementId = null;
                }
            }
            if(objCase.RecordTypeId == ChannelPartnerId){
                objCase.Status = 'Open';
            }
            if(objCase.Origin == 'Walk-in' && objCase.RecordTypeId == CustomerId){
                objCase.RW_RM_Name__c = objCase.RW_Owner_Name__c;
            }
            
            
            // caseownerUpdateForsingleOppo() //
            // updateAccountId() //
            // updateEscalationTAT //
            // checkForCancelledCustomer //
            
        }
        addAccountAndOpportunity(lstTriggerNew);
        updateEscalationTAT(lstTriggerNew, null);
    }
    
    public static void addAccountAndOpportunity(list<Case> lstCase){
        Map<String, Case> emailVsCase = new Map<String, Case>();
        for(case cs : lstCase){
            if(cs.Origin == 'Email'){
                emailVsCase.put(cs.SuppliedEmail, cs);
            }
        }
        List<Id> accIds = new List<Id>();
        Map<String, List<String>> emailVsAccIds = new Map<String, List<String>>();
        Map<String, String> accIdVsContId = new Map<String, String>();
        Map<String, Boolean> accIdVsStopEmails = new Map<String, Boolean>();
        for(Account acc : [SELECT Id, RW_Email__c, IsPersonAccount, PersonEmail, PersonContactId, Stop_Case_Emails__c FROM Account WHERE PersonEmail =: emailVsCase.keySet() AND IsPersonAccount = true]){
            accIds.add(acc.Id);
            accIdVsContId.put(acc.Id, acc.PersonContactId);
            accIdVsStopEmails.put(acc.Id, acc.Stop_Case_Emails__c);
            if(emailVsAccIds.get(acc.PersonEmail) != null){
                emailVsAccIds.get(acc.PersonEmail).add(acc.Id);
            }else{
                emailVsAccIds.put(acc.PersonEmail, new List<String>{acc.Id});
            }
        }
        if(accIds.size() > 0){
            Map<Id, Opportunity> accIdvsOpp = latestOpportunity(accIds);
            for(case cs : lstCase){
                Opportunity opp;
                if(emailVsAccIds.get(cs.SuppliedEmail) != null && emailVsAccIds.get(cs.SuppliedEmail).size() == 1){
                    opp = accIdvsOpp.get(emailVsAccIds.get(cs.SuppliedEmail)[0]);
                    /*cs.AccountId = emailVsAccIds.get(cs.SuppliedEmail)[0];
                    cs.Opportunity__c = accIdvsOpp.get(emailVsAccIds.get(cs.SuppliedEmail)[0]).Id;
                    cs.RW_Project_Unit__c = accIdvsOpp.get(emailVsAccIds.get(cs.SuppliedEmail)[0]).RW_Project_Unit__c;
                    cs.RW_Project__c = accIdvsOpp.get(emailVsAccIds.get(cs.SuppliedEmail)[0]).RW_Project__c;
                    if(accIdvsOpp.get(emailVsAccIds.get(cs.SuppliedEmail)[0]).StageName == 'Cancelled'){
                        cs.Stop_Emails__c = true;
                    }*/
                }else if(emailVsAccIds.get(cs.SuppliedEmail) != null && emailVsAccIds.get(cs.SuppliedEmail).size() >= 1){
                    List<Opportunity> bookedOppList = new List<Opportunity>();
                    List<Opportunity> nonBookedOppList = new List<Opportunity>();
                    for(Id accId : emailVsAccIds.get(cs.SuppliedEmail)){
                        if(accIdvsOpp.get(accId).StageName == 'Unit Booked'){
                            bookedOppList.add(accIdvsOpp.get(accId));
                        }else{
                            nonBookedOppList.add(accIdvsOpp.get(accId));
                        }
                    }
                    if(bookedOppList.size() > 0){
                        opp = latestOpp(bookedOppList, true);
                        /*cs.AccountId = latestOpp(bookedOppList, true).AccountId;
                    	cs.Opportunity__c = latestOpp(bookedOppList, true).Id;
                        cs.RW_Project_Unit__c = latestOpp(bookedOppList, true).RW_Project_Unit__c;
                    	cs.RW_Project__c = latestOpp(bookedOppList, true).RW_Project__c;*/
                    }else if(nonBookedOppList.size() > 0){
                        opp = latestOpp(nonBookedOppList, true);
                        /*cs.AccountId = latestOpp(nonBookedOppList, false).AccountId;
                    	cs.Opportunity__c = latestOpp(nonBookedOppList, false).Id;
                        if(latestOpp(nonBookedOppList, false).StageName == 'Cancelled'){
                            cs.Stop_Emails__c = true;
                        }*/
                    }
                }
                cs.AccountId = opp.AccountId;
                cs.Opportunity__c = opp.Id;
                cs.RW_Project_Unit__c = opp.RW_Project_Unit__c;
                cs.RW_Project__c = opp.RW_Project__c;
                cs.ContactId = accIdVsContId.get(cs.AccountId);
                //cs.Stop_Emails__c = accIdVsStopEmails.get(cs.AccountId);
                if(opp.StageName == 'Cancelled' || accIdVsStopEmails.get(cs.AccountId) == true){
                    cs.Stop_Emails__c = true;
                }
                cs.RW_RM_Name__c = opp.RW_Project_Unit__r.Relationship_Manager__r.user__r.Name;
                
                ownerAssignment(opp, cs);
            }
        }
    }
    
    public static void ownerAssignment(Opportunity opp, Case cs){
        if(Date.today() > (opp.Booking__r.RW_Key_handover_date__c + 60)){
            cs.OwnerId = System.label.Default_Facility_Management_User;
            cs.FM_Team_Assigned__c = true; 
        }else{
            cs.OwnerId = opp.RW_Project_Unit__r.Relationship_Manager__r.user__c;
        }
    }
    
    public static Map<Id, Opportunity> latestOpportunity(List<Id> accountIds){
        Map<Id,List<Opportunity>> accIdVsBookedOpps = new Map<Id,List<Opportunity>>();
        Map<Id,List<Opportunity>> accIdVsNonBookedOpps = new Map<Id,List<Opportunity>>();
        for(Opportunity opp : [SELECT Id,AccountId,Booking__c,StageName,Booking__r.Booking_Date__c,RW_Project_Unit__c,RW_Project__c,RW_Project_Unit__r.Relationship_Manager__r.user__c,RW_Project_Unit__r.Relationship_Manager__r.user__r.Name FROM Opportunity WHERE AccountId =: accountIds]){
            if(opp.StageName == 'Unit Booked'){
                if(accIdVsBookedOpps.get(opp.AccountId) != null){
                    accIdVsBookedOpps.get(opp.AccountId).add(opp);
                }else{
                    accIdVsBookedOpps.put(opp.AccountId, new List<Opportunity>{opp});
                }
            }else{
                if(accIdVsNonBookedOpps.get(opp.AccountId) != null){
                    accIdVsNonBookedOpps.get(opp.AccountId).add(opp);
                }else{
                    accIdVsNonBookedOpps.put(opp.AccountId, new List<Opportunity>{opp});
                }
            }
        }
        Map<Id, Opportunity> accIdVsOpp = new Map<Id, Opportunity>();
        for(Id accId : accountIds){
            if(accIdVsBookedOpps.get(accId) == null){
                continue;
            }
            if(accIdVsNonBookedOpps.get(accId) == null){
                continue;
            }
            if(accIdVsBookedOpps.get(accId) != null && accIdVsBookedOpps.get(accId).size() == 1){
                accIdVsOpp.put(accId, accIdVsBookedOpps.get(accId)[0]);
            }else if(accIdVsNonBookedOpps.get(accId) != null && accIdVsNonBookedOpps.get(accId).size() == 1){
                accIdVsOpp.put(accId, accIdVsNonBookedOpps.get(accId)[0]);
            }else if(accIdVsBookedOpps.get(accId) != null && accIdVsBookedOpps.get(accId).size() > 1){
                accIdVsOpp.put(accId, latestOpp(accIdVsBookedOpps.get(accId), true));
            }else if(accIdVsNonBookedOpps.get(accId) != null && accIdVsNonBookedOpps.get(accId).size() > 1){
                accIdVsOpp.put(accId, latestOpp(accIdVsNonBookedOpps.get(accId), false));
            }
        }
        return accIdVsOpp;
    }
    
    public static Opportunity latestOpp(List<Opportunity> oppList, Boolean booked){
        if (oppList == null || oppList.isEmpty()) {
            return null;
        }
        
        Opportunity latestOpp = oppList[0];
        
        for (Opportunity opp : oppList) {
            if(booked){
                if (opp.Booking__r.Booking_Date__c > latestOpp.Booking__r.Booking_Date__c) {
                    latestOpp = opp;
                }
            }else{
                if (opp.CreatedDate > latestOpp.CreatedDate) {
                    latestOpp = opp;
                } 
            }
            
        }
        return latestOpp;
    }
    
    public void onAfterInsert(list<Case> lstTriggerNew, map<id, Case> mapTriggerOld){
        CreateTask(lstTriggerNew);
        NotificationToRMOnCaseCreation(lstTriggerNew);
        CPPortalMethod(lstTriggerNew);
    }
    
    public void CreateTask(list<Case> lstCase){
        Id CustomerId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Label.Case_task_record_type_Name').getRecordTypeId();
        if(lstCase != null && lstCase.size() > 0){
            list<Case> lstCase2Update = new list<Case>();
            list<Task> lstTask = new list<Task>();
            for(Case objCase : lstCase){
                if(!objCase.RW_Is_Task_Created__c && objCase.RecordTypeId == CustomerId && String.isBlank(objCase.locobuzz__Locobuzz_ID__c) && objCase.Stop_Emails__c == false){
                    if(objCase.ownerId != null && string.valueOf(objCase.ownerId).startsWith('005') && objCase.RW_Project__c != null){
                        Task objTask = new Task();
                        objTask.recordtypeid = taskRecordTypeId;
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
            
            if(lstTask != null && lstTask.size() > 0){
                insert lstTask;
            }
            
            if(lstCase2Update != null && lstCase2Update.size() > 0){
                update lstCase2Update;
            }
        }		
    }
    
    public void NotificationToRMOnCaseCreation(list<Case> lstCase){
        Id CustomerId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        EmailTemplate emailTemplate = [SELECT Body,DeveloperName,Id,Subject FROM EmailTemplate WHERE Name =: 'Notification To RM'];
        for(Case objCase : [SELECT Id,Opportunity__c,RecordTypeId,Opportunity__r.RW_Project_Unit__r.Relationship_Manager__c,ContactId,Opportunity__r.Account.Stop_Case_Emails__c,Opportunity__r.RW_Project_Unit__r.Relationship_Manager__r.RM_Email__c FROM Case WHERE Id =: lstCase]){
            if(objCase.Opportunity__c != null && objCase.RecordTypeId == CustomerId && objCase.Opportunity__r.RW_Project_Unit__r.Relationship_Manager__c != null && objCase.ContactId != null && objCase.Opportunity__r.Account.Stop_Case_Emails__c == false && objCase.Stop_Emails__c == false){
                Messaging.SingleEmailMessage message =new Messaging.SingleEmailMessage();
                message.setTargetObjectId(objCase.ContactId);
                message.setTreatTargetObjectAsRecipient(false);
                message.setWhatId(objCase.Id); 
                message.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
                message.setTemplateId(emailTemplate.id);
                message.setUseSignature(false);
                message.setBccSender(false);
                message.setSaveAsActivity(false);
                message.toaddresses = new string[]{objCase.Opportunity__r.RW_Project_Unit__r.Relationship_Manager__r.RM_Email__c};
                messages.add(message);  
            }
        }
        if(messages.size()>0){
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            system.debug('Messaging ' + results[0]);
        }
    }
    
    public void CPPortalMethod(list<Case> lstCase){
        List<Contact> contact = new List<Contact>();
        List<Account> AccList = new List<Account>();
        List<Opportunity> opp = new List<Opportunity>();
        List<Project__c> proj = new List<Project__c>();
        List<Case> CaseUpdate = new List<Case>();
        Id ChannelPartnerId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Channel Partner Portal').getRecordTypeId();
        String Username;
        Id loggeduserId = UserInfo.getUserId();
        List<User> user = [SELECT Id, ContactId FROM User WHERE Id ='0059I0000078nh3QAA'];
        if(!user.isEmpty()){
            contact =[select id,Name,Email,AccountId from Contact where id =: user[0].ContactId];
        }
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
                    projMap = new Map<Id, Project__c>([Select Id,Name,MIS_User__r.Email,MIS_User__r.Name,MIS_User__c from Project__c where id=: projIds]);
                }
            }
            //Fetch Team Members 
            Map<Id, Map<String, Team_Members__c>> projToApproverMap = TeamMemberService.getProjectTeamMembers( projIds, 'CP Case Escalation Team',  new List<String>{ 'CP Case L1 Escalation',  'CP Case L2 Escalation', 'CP Case L3 Escalation', 'CP Case L4 Escalation', 'CP Case L5 Escalation', 'CP Case L6 Escalation'});
            for(Case objCase : lstCase){
                if(objCase.Origin == 'Channel Partner Portal' && objCase.RecordTypeId == ChannelPartnerId){
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
                                }
                            }
                            if(projMap.get(oppIdVsProjId.get(objCase.Opportunity__c)).MIS_User__c != null){
                                c.OwnerId = projMap.get(oppIdVsProjId.get(objCase.Opportunity__c)).MIS_User__c;
                            }
                        }
                    }
                    CaseUpdate.add(c);
                }
            }
            update CaseUpdate;
        }
    }
    
    public void onBeforeUpdate(list<Case> lstTriggerNew, map<id, Case> mapTriggerOld){
        Id CustomerId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id CPRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Channel Partner Portal').getRecordTypeId();
        set<id> setWhatid = new set<id>();
        Map<String, RM_Usernames__c> mapOfCustomSetting = RM_Usernames__c.getall();
        list<Entitlement> lstEntitlement = [select id, Name  from Entitlement where Name =:Label.Entitlement_Name or name =: Label.Reopen_Entitlement_Name or name =: Label.Resolved_Entitlement_Name];
        map<string, Entitlement> mapOfEntitlement = new map<string, Entitlement>();
        if(lstEntitlement != null && lstEntitlement.size() > 0){
            for(Entitlement EachEntitle : lstEntitlement){
                mapOfEntitlement.put(EachEntitle.name, EachEntitle);
            }
        }
        for(Case cs : lstTriggerNew){
            if(cs.Opportunity__c != null && cs.Opportunity__c != mapTriggerOld.get(cs.Id).Opportunity__c){
                if(cs.Opportunity__r.StageName == 'Cancelled'){
                    cs.Stop_Emails__c = true;
                }
            }
            if(cs.RecordTypeId == CustomerId && cs.RW_RM_Name__c != null && cs.RW_RM_Name__c != mapTriggerOld.get(cs.Id).RW_RM_Name__c){
                if(mapOfCustomSetting.containsKey(cs.RW_RM_Name__c)){
                    cs.RW_Immediate_Manager_Email__c = mapOfCustomSetting.get(cs.RW_RM_Name__c).RW_Reporting_1_Email__c;
                    cs.RW_Reporting_2_Email__c = mapOfCustomSetting.get(cs.RW_RM_Name__c).RW_Reporting_2_Email__c;
                    cs.RW_Reporting_3_Email__c = mapOfCustomSetting.get(cs.RW_RM_Name__c).RW_Reporting_3_Email__c;
                    cs.RW_Reporting_4_Email__c = mapOfCustomSetting.get(cs.RW_RM_Name__c).RW_Reporting_4_Email__c;
                }
            }
            if(cs.ownerId != null && string.valueOf(cs.ownerId).startsWith('005') && cs.RecordTypeId == CustomerId){
                if(cs.Status != 'Resolved' && cs.RW_Case_Reopened_Date__c == null && mapTriggerOld.get(cs.id).OwnerId != cs.ownerId){
                    cs.RW_Escalated_Time__c = system.now();
                    cs.EntitlementId = mapOfEntitlement.get(Label.Entitlement_Name).id;
                }else if(cs.Status == 'Resolved' && mapTriggerOld.get(cs.Id).Status != cs.Status){
                    cs.RW_Escalated_Time__c = system.now();
                    cs.EntitlementId = mapOfEntitlement.get(Label.Resolved_Entitlement_Name).id;
                }else if(cs.Status == 'Reopened' && mapTriggerOld != null && mapTriggerOld.get(cs.id).Status != cs.Status){
                    cs.EntitlementId = mapOfEntitlement.get(Label.Reopen_Entitlement_Name).id;
                }
            }
            
            if(cs.status != null && mapTriggerOld.get(cs.id).status != cs.status && cs.status == 'Contacted' && cs.RecordTypeId == CustomerId){
                setWhatid.add(cs.Id);		
            }
            
            if(cs.OwnerId != mapTriggerOld.get(cs.Id).OwnerId && cs.RecordTypeId == CPRecordTypeId ){
                if(cs.RW_Owner_Name__c != null){
                    system.debug('Owner'+cs.RW_Owner_Name__c);
                    if(cs.Owners__c != null && cs.RW_Is_Escalated__c == true){
                        cs.owners__c = cs.owners__c + ', ' + cs.RW_Owner_Name__c; 
                    }else{
                        cs.owners__c = cs.RW_Owner_Name__c ;
                    }
                    
                }
            }else if(cs.Status=='Case Closed' && cs.RecordTypeId == CPRecordTypeId){
                if(cs.RW_Owner_Name__c != null){
                    if(cs.Owners__c != null){
                        cs.owners__c = cs.owners__c + ', ' + cs.RW_Owner_Name__c; 
                    } else{
                        cs.owners__c = cs.RW_Owner_Name__c ;
                    }
                }
            }
        }
        if(setWhatid != null && setWhatid.size() > 0){
            list<Task> lstTask = [select id, Status, Subject, WhatId from Task where WhatId in : setWhatid and Subject =: 'Call Customer'];
            map<string, Task> mapOfTask = new map<string, Task>();
            
            for(Task EachTask : lstTask){
                mapOfTask.put(EachTask.WhatId, EachTask);
            }
            if(lstTask != null && lstTask.size() > 0){
                for(Case objCase : lstTriggerNew){
                    if(setWhatid.contains(objCase.id) && mapOfTask != null && mapOfTask.size() > 0 && mapOfTask.containsKey(objCase.id)){
                        if(mapOfTask.get(objCase.id).Status != 'Completed'){
                            objCase.addError('For Contacted, the call customer task must be completed.');
                        }
                    }else{
                        objCase.addError('For Contacted, the call customer task must be completed.');
                    }
                }
            }
        }
        
        updateEscalationTAT(lstTriggerNew,mapTriggerOld);
    }
    
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
    
    public void onAfterUpdate(list<Case> lstTriggerNew, map<id, Case> mapTriggerOld){
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
        }
    }
    
    private void updateTaskOwner(list<Case> lstCase,map<id,Case> triggeroldmap){
        Id CustomerId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        if(lstCase != null && lstCase.size() > 0){
            map<string, case> mapOfCaseId = new map<string, case>();
            for(Case objCase : lstCase){
                if(objCase.ownerId != null && string.valueOf(objCase.ownerId).startsWith('005') && (triggeroldmap.get(objCase.id).ownerId != objCase.ownerId) && objCase.RecordTypeId == CustomerId){
                    mapOfCaseId.put(objCase.id, objCase);
                }
            }
            if(mapOfCaseId != null && mapOfCaseId.size() > 0){
                list<task> lstTask = [select id, Ownerid, whatId from Task where whatId in: mapOfCaseId.keySet()];
                if(lstTask != null && lstTask.size() > 0){
                    for(Task EachTask : lstTask){
                        EachTask.Ownerid = mapOfCaseId.get(EachTask.whatId).ownerId;
                    }
                    update lstTask;
                }
            }
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
                        }
                    }
                    if(projMap.get(objCase.RW_Project__c).MIS_User__c != null){
                        c.OwnerId = projMap.get(objCase.RW_Project__c).MIS_User__c;
                    }
                    
                    CaseUpdate.add(c);
                }
            }
            system.debug('@CaseUpdate::'+CaseUpdate);
            update CaseUpdate;
        }
    }
}