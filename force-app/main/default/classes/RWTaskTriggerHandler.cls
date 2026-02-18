public class RWTaskTriggerHandler 
{
    public void runTrigger()
    {
        // Method will be called to handle Before insert events
        if (Trigger.isBefore && Trigger.isInsert)
        {
            onBeforeInsert((list<Task>) trigger.new, (map<id, Task>) trigger.OldMap);
        }
        
        // Method will be called to handle Before Update events
        if (Trigger.isBefore && Trigger.isUpdate)
        {
            onBeforeUpdate((list<Task>) trigger.new, (map<id, Task>) trigger.OldMap);
        }
        
        // Method will be called to handle After Insert events
        if (Trigger.isAfter && Trigger.isInsert)
        {
            system.debug('in AfterInsert line20________');
            onAfterInsert((list<Task>) trigger.new, (map<id, Task>) trigger.OldMap);
        }
        
        // Method will be called to handle After Update eventssss
        
        if (Trigger.isAfter && Trigger.isUpdate)
        {
            onAfterUpdate((list<Task>) trigger.new, (map<id, Task>) trigger.OldMap);
        }
        
        if (Trigger.isBefore && Trigger.isDelete)
        {
            onBeforeDelete((list<Task>) trigger.new, (map<id, Task>) trigger.OldMap);
        }
        
    }
    public void onBeforeInsert(list<Task> lstTriggerNew, map<id, Task> mapTriggerOld)
    {
        reassignSysAdminTaskToRM(lstTriggerNew); //Added by coServe 09-05-2024
    }
    public void onBeforeUpdate(list<Task> lstTriggerNew, map<id, Task> mapTriggerOld)
    {
        List<Task> tasksForServiceCategory = new List<Task>(); //Added by Vinay 01-07-2025
        for(Task tsk : lstTriggerNew){ //Added by Vinay 01-07-2025
            if(tsk.Call_Status__c != null && mapTriggerOld.get(tsk.Id).Call_Status__c != tsk.Call_Status__c){
                tasksForServiceCategory.add(tsk);
            }
        }
        updateServiceCategory(tasksForServiceCategory, mapTriggerOld); //Added by Vinay 01-07-2025
        //updateServiceCategory(lstTriggerNew, mapTriggerOld); //Added by Vinay 31-03-2025 //Commented by Vinay 01-07-2025
    }
    private void onAfterInsert(list<Task> lstTriggerNew, map<id, Task> mapTriggerOld)
    {
        system.debug('in AfterInsert line47________');
        updateCaseStage(lstTriggerNew,mapTriggerOld);
        
        //for the phase 1 trigger
        sendEmailOnEsclatationHandler objHandler = new sendEmailOnEsclatationHandler();
        objHandler.afterInsert(lstTriggerNew);
        
        
        //Added by Mounika Ramagoni - E&Y (22/Nov/2020 Presales module - FRD-3)
        system.debug('in AfterInsert line55________');
        sendEmailAndSMSOnPresalesOutboundCall sendEmailAndSMS = new sendEmailAndSMSOnPresalesOutboundCall();
        sendEmailAndSMS.presalesOutboundCall(lstTriggerNew);
        //Ends Here 
        updateRemarksOnCase(lstTriggerNew); //Added by Vinay 07-03-2025
        updateRemarksOnOpportunity(lstTriggerNew, null); //Added by Vinay 13-06-2025
        //Added by Vinay 08-05-2025 Start
        Id serviceTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Service Task').getRecordTypeId(); 
        List<Id> serviceTaskIds = new List<Id>(); 
        for(Task tsk : lstTriggerNew){
            if(tsk.Subject != 'CRM Call' && tsk.RecordTypeId == serviceTaskRecordTypeId && tsk.WhatId != null && tsk.WhatId.getSObjectType().getDescribe().getName() == 'Opportunity'){ 
                serviceTaskIds.add(tsk.Id);
            }
        }
        if(!serviceTaskIds.isEmpty()){ 
            List<Task> serviceTskList = [SELECT Id, WhatId FROM Task WHERE Id =: serviceTaskIds];
            List<Id> oppIds = new List<Id>();
            for(Task tsk : serviceTskList){
                oppIds.add(tsk.WhatId);
            }
            Map<Id, Opportunity> bookedOppMap = new Map<Id, Opportunity>([SELECT Id, StageName FROM Opportunity WHERE Id =: oppIds AND StageName = 'Unit Booked']);
            List<Task> tasksToUpdate = new List<Task>();
            for(Task tsk : serviceTskList){
                if(bookedOppMap.containsKey(tsk.WhatId)){
                    tsk.Subject = 'CRM Call';
                    tasksToUpdate.add(tsk);
                }
            }
            if(!tasksToUpdate.isEmpty()){
                update tasksToUpdate;
            }
        }
        //Added by Vinay 08-05-2025 End
        
    }
    private void onAfterUpdate(list<Task> lstTriggerNew, map<id, Task> mapTriggerOld)
    {
        updateCaseStage(lstTriggerNew,mapTriggerOld);
        
        //for the phase 1 trigger
        sendEmailOnEsclatationHandler objHandler = new sendEmailOnEsclatationHandler();
        objHandler.sendEsclation(lstTriggerNew, mapTriggerOld);
        //notContactableEmailAlert(lstTriggerNew, mapTriggerOld); //Added by coServe 02-05-2024 //Commented by Vinay 30-06-2025
        //Added by Vinay 30-06-2025 Start
        List<String> statusValues = System.Label.Call_Status_value.split(',');
        Id presalesTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Presales Task').getRecordTypeId();
        List<Task> notContactableTasks = new List<Task>();
        for(Task tsk : lstTriggerNew){
            if(tsk.Communication_Type__c == 'Outbound Call' && tsk.WhatId != null && tsk.WhatId.getSObjectType().getDescribe().getName() == 'Opportunity' && statusValues.contains(tsk.Call_Status__c) && 
               mapTriggerOld.get(tsk.Id).Call_Status__c != tsk.Call_Status__c && tsk.RecordTypeId != presalesTaskRecordTypeId){
                   notContactableTasks.add(tsk);
               }
        }
        if(notContactableTasks.size() > 0){
            notContactableEmailAlert(lstTriggerNew, mapTriggerOld); 
        }
        //Added by Vinay 30-06-2025 End
        updateRemarksOnCase(lstTriggerNew); //Added by Vinay 07-03-2025
        cloneWelcomeCallTask(lstTriggerNew, mapTriggerOld); //Added by Vinay 18-03-2025
        updateRemarksOnOpportunity(lstTriggerNew, mapTriggerOld); //Added by Vinay 13-06-2025
    }
    
    public void onBeforeDelete(list<Task> lstTriggerNew, map<id, Task> mapTriggerOld)
    {
        validateDelete(lstTriggerNew, mapTriggerOld);
    }
    
    //Added by Vinay 13-06-2025
    /*public void updateRemarksOnOpportunity(List<Task> tskList, Map<Id, Task> oldMap){
        Id serviceRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Service Task').getRecordTypeId();
        Id salesRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Sales Task').getRecordTypeId();
        Set<Id> oppIds = new Set<Id>();
        List<Task> tasksToProcess = new List<Task>();
        for(Task tsk : tskList){
            if(oldMap == null && (tsk.RecordTypeId == serviceRecTypeId || tsk.RecordTypeId == salesRecTypeId) && tsk.Remarks__c != null && tsk.WhatId != null && tsk.WhatId.getSObjectType().getDescribe().getName() == 'Opportunity'){
                oppIds.add(tsk.WhatId);
                tasksToProcess.add(tsk);
            }else if(oldMap != null && (tsk.RecordTypeId == serviceRecTypeId || tsk.RecordTypeId == salesRecTypeId) && tsk.Remarks__c != null && tsk.Remarks__c != oldMap.get(tsk.Id).Remarks__c && tsk.WhatId != null && tsk.WhatId.getSObjectType().getDescribe().getName() == 'Opportunity'){
                oppIds.add(tsk.WhatId);
                tasksToProcess.add(tsk);
            }
            
        }
        if(oppIds.size() > 0){
            Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Id, CRM_Remarks__c, Sales_Remarks__c FROM Opportunity WHERE Id =: oppIds]);
            for(Task tsk : tasksToProcess){
                if(tsk.RecordTypeId == serviceRecTypeId){
                    if(oppMap.get(tsk.WhatId).CRM_Remarks__c == null){
                        oppMap.get(tsk.WhatId).CRM_Remarks__c = tsk.Remarks__c;
                    }else{
                        String str = tsk.Remarks__c + '; * ' + oppMap.get(tsk.WhatId).CRM_Remarks__c;
                        oppMap.get(tsk.WhatId).CRM_Remarks__c = (str.length() > 131072) ? str.substring(0, 131072) : str;
                    }
                }else if(tsk.RecordTypeId == salesRecTypeId){
                    if(oppMap.get(tsk.WhatId).Sales_Remarks__c == null){
                        oppMap.get(tsk.WhatId).Sales_Remarks__c = tsk.Remarks__c;
                    }else{
                        String str = tsk.Remarks__c + '; * ' + oppMap.get(tsk.WhatId).Sales_Remarks__c;
                        oppMap.get(tsk.WhatId).Sales_Remarks__c = (str.length() > 131072) ? str.substring(0, 131072) : str;
                    }
                }
            }
            update oppMap.values();
        }
    }*/
    
    
    //Added by Vinay 27-06-2025
    public void updateRemarksOnOpportunity(List<Task> tskList, Map<Id, Task> oldMap){
        Id serviceRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Service Task').getRecordTypeId();
        Id salesRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Sales Task').getRecordTypeId();
        Set<Id> oppIds = new Set<Id>();
        Set<Id> leadIds = new Set<Id>();
        List<Task> tasksToProcess = new List<Task>();
        for(Task tsk : tskList){
            if(oldMap == null && (tsk.RecordTypeId == serviceRecTypeId || tsk.RecordTypeId == salesRecTypeId) && tsk.Remarks__c != null ){
                if(tsk.WhatId != null && tsk.WhatId.getSObjectType().getDescribe().getName() == 'Opportunity'){
                    oppIds.add(tsk.WhatId);
                	tasksToProcess.add(tsk);
                }else if(tsk.WhoId != null && tsk.WhoId.getSObjectType().getDescribe().getName() == 'Lead'){
                    leadIds.add(tsk.WhoId);
                	tasksToProcess.add(tsk);
                }
                
            }else if(oldMap != null && (tsk.RecordTypeId == serviceRecTypeId || tsk.RecordTypeId == salesRecTypeId) && tsk.Remarks__c != null && tsk.Remarks__c != oldMap.get(tsk.Id).Remarks__c){
                if(tsk.WhatId != null && tsk.WhatId.getSObjectType().getDescribe().getName() == 'Opportunity'){
                    oppIds.add(tsk.WhatId);
                	tasksToProcess.add(tsk);
                }else if(tsk.WhoId != null && tsk.WhoId.getSObjectType().getDescribe().getName() == 'Lead'){
                    leadIds.add(tsk.WhoId);
                	tasksToProcess.add(tsk);
                }
            }
            
        }
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        Map<Id, Lead> leadMap = new Map<Id, Lead>();
        if(oppIds.size() > 0)
            oppMap = new Map<Id, Opportunity>([SELECT Id, CRM_Remarks__c, Sales_Remarks__c FROM Opportunity WHERE Id =: oppIds]);
        if(leadMap.size() > 0)
            leadMap = new Map<Id, Lead>([SELECT Id, CRM_Remarks__c, Sales_Remarks__c FROM Lead WHERE Id =: leadIds]);
        if(tasksToProcess.size() > 0){
            for(Task tsk : tasksToProcess){
                if(tsk.RecordTypeId == serviceRecTypeId){
                    if(oppMap.get(tsk.WhatId) != null){
                        if(oppMap.get(tsk.WhatId).CRM_Remarks__c == null){
                            oppMap.get(tsk.WhatId).CRM_Remarks__c = tsk.Remarks__c;
                        }else{
                            String str = tsk.Remarks__c + '; * ' + oppMap.get(tsk.WhatId).CRM_Remarks__c;
                            oppMap.get(tsk.WhatId).CRM_Remarks__c = (str.length() > 131072) ? str.substring(0, 131072) : str;
                        }
                    }else if(leadMap.get(tsk.WhoId) != null){
                        if(leadMap.get(tsk.WhoId).CRM_Remarks__c == null){
                            leadMap.get(tsk.WhoId).CRM_Remarks__c = tsk.Remarks__c;
                        }else{
                            String str = tsk.Remarks__c + '; * ' + leadMap.get(tsk.WhoId).CRM_Remarks__c;
                            leadMap.get(tsk.WhoId).CRM_Remarks__c = (str.length() > 131072) ? str.substring(0, 131072) : str;
                        }
                    }
                }else if(tsk.RecordTypeId == salesRecTypeId){
                    if(oppMap.get(tsk.WhatId) != null){
                        if(oppMap.get(tsk.WhatId).Sales_Remarks__c == null){
                            oppMap.get(tsk.WhatId).Sales_Remarks__c = tsk.Remarks__c;
                        }else{
                            String str = tsk.Remarks__c + '; * ' + oppMap.get(tsk.WhatId).Sales_Remarks__c;
                            oppMap.get(tsk.WhatId).Sales_Remarks__c = (str.length() > 131072) ? str.substring(0, 131072) : str;
                        }
                    }else if(leadMap.get(tsk.WhoId) != null){
                        if(leadMap.get(tsk.WhoId).Sales_Remarks__c == null){
                            leadMap.get(tsk.WhoId).Sales_Remarks__c = tsk.Remarks__c;
                        }else{
                            String str = tsk.Remarks__c + '; * ' + leadMap.get(tsk.WhoId).Sales_Remarks__c;
                            leadMap.get(tsk.WhoId).Sales_Remarks__c = (str.length() > 131072) ? str.substring(0, 131072) : str;
                        }
                    }
                }
            }
            update oppMap.values();
            update leadMap.values();
        }
    }
    
    //Added by coServe 07-03-2025
    public void updateRemarksOnCase(List<Task> tskList){
        Id recTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Customer Interaction').getRecordTypeId();
        Set<Id> caseIds = new Set<Id>();
        Set<Id> tskIds = new Set<Id>();
        for(Task tsk : tskList){
            if(tsk.RecordTypeId == recTypeId && tsk.WhatId != null && tsk.WhatId.getSObjectType().getDescribe().getName() == 'Case'){
                caseIds.add(tsk.WhatId);
                tskIds.add(tsk.Id);
            }
        }
        if(caseIds.size() > 0){
            List<Case> caseList = [SELECT Id, Description FROM Case WHERE Id =: caseIds AND locobuzz__Locobuzz_ID__c != null];
            List<Task> listTasks = [SELECT Id, WhatId, Description FROM Task WHERE WhatId =: caseIds AND RecordTypeId =: recTypeId Order by CreatedDate DESC];
            System.debug('listTasks: ' + listTasks.size());
            System.debug('listTasks: ' + listTasks);
            Map<String, List<Task>> caseTaskMap = new Map<String, List<Task>>();
            for(Task tsk: listTasks){
                if(caseTaskMap.get(tsk.WhatId) != null){
                    caseTaskMap.get(tsk.WhatId).add(tsk);
                }else{
                    caseTaskMap.put(tsk.WhatId, new List<Task>{tsk});
                }
            }
            System.debug('caseTaskMap: ' + caseTaskMap);
            for(Case cs : caseList){
                if(caseTaskMap.get(cs.Id).size() > 1){
                    if(tskIds.contains(caseTaskMap.get(cs.Id)[0].Id) || tskIds.contains(caseTaskMap.get(cs.Id)[1].id)){
                        cs.RW_RM_Remarks__c = '1. ' + caseTaskMap.get(cs.Id)[0].Description + '; 2. ' + caseTaskMap.get(cs.Id)[1].Description;
                    }
                }else if(caseTaskMap.get(cs.Id).size() == 1){
                    cs.RW_RM_Remarks__c = '1. ' + caseTaskMap.get(cs.Id)[0].Description;
                }
            }
            update caseList;
        }
    }
    //Added by coServe 09-05-2024 Start
    public void reassignSysAdminTaskToRM(List<Task> tskList){
        List<String> oppIds = new List<String>();
        List<Task> tskListToUpdate = new List<Task>();
        for(Task tsk : tskList){
            if(tsk.WhatId != null){
                String sObjName = tsk.WhatId.getSObjectType().getDescribe().getName();
                if(tsk.Task_Type__c == 'CRM Call' && tsk.Subject == 'Missed Call' && sObjName == 'Opportunity' &&
                   tsk.OwnerId == System.label.System_Administrator_User_Id){
                       oppIds.add(tsk.WhatId);
                       tskListToUpdate.add(tsk);
                   }
            }
            
        }
        if(oppIds.size() > 0){
            Map<Id,Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Id, RW_Project_Unit__r.Relationship_Manager__r.User__c FROM Opportunity WHERE Id =: oppIds]);
            for(Task t : tskListToUpdate){
                if(oppMap.get(t.WhatId).RW_Project_Unit__c != null && oppMap.get(t.WhatId).RW_Project_Unit__r.Relationship_Manager__r != null){
                    t.OwnerId = oppMap.get(t.WhatId).RW_Project_Unit__r.Relationship_Manager__r.User__c;
                }
            }
        }
        
        //update tsks;        
    }
    //Added by coServe 09-05-2024 End
    //Added by coServe 02-05-2024 Start
    public void notContactableEmailAlert(List<Task> tskList, Map<Id, Task> oldTskMap){
        System.debug('--notContactableEmailAlert--');
        List<String> statusValues = System.Label.Call_Status_value.split(',');
        List<Task> taskToSendEmails = new List<Task>();
        Set<String> oppIds = new Set<String>();
        Set<String> tskIds = new Set<String>();
        Map<String, Opportunity> oppMap = new Map<String, Opportunity>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>(); 
        Map<String, Not_Contactable_Email_Alerts__c> recTypeVsTemplate = Not_Contactable_Email_Alerts__c.getall();
        List<String> templateNames = new List<String>();
        for(Not_Contactable_Email_Alerts__c alert : recTypeVsTemplate.values()){
            templateNames.add(alert.Email_Template__c);
        }
        if(templateNames.size() > 0){
            List<EmailTemplate> templates = [Select Id,Name,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName =: templateNames];
            Map<String, EmailTemplate> templateMap = new Map<String,EmailTemplate>();
            for(EmailTemplate temp : templates){
                templateMap.put(temp.DeveloperName, temp);
            }
            
            String orgEmail = Utility.getOrgWideEmailAddress();
            for(Task tsk : tskList){
                if(tsk.WhatId != null){
                    String sObjName = tsk.WhatId.getSObjectType().getDescribe().getName();
                    String recType = Schema.SObjectType.Task.getRecordTypeInfosById().get(tsk.RecordTypeId).getName();
                    Id presalesTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Presales Task').getRecordTypeId();//Added by Vinay 24-04-2025
                    if(tsk.Communication_Type__c == 'Outbound Call' && sObjName == 'Opportunity' && statusValues.contains(tsk.Call_Status__c) && 
                       oldTskMap.get(tsk.Id).Call_Status__c != tsk.Call_Status__c && recTypeVsTemplate.get(recType) != null && tsk.RecordTypeId != presalesTaskRecordTypeId){
                           taskToSendEmails.add(tsk);
                           oppIds.add(tsk.WhatId);
                           tskIds.add(tsk.Id);
                       }
                }
            }
            if(oppIds.size() > 0){
            	List<Opportunity> oppList = [SELECT Id, Name, RW_Email__c, RW_Project__c, RW_Project__r.Name, Not_Contactable_Email_Sent_Date__c, RW_Project_Unit__r.Relationship_Manager__r.Contact_Number__c, RW_Project_Unit__c, RW_Project_Unit__r.Relationship_Manager__c FROM Opportunity WHERE Id =: oppIds AND StageName = 'Unit Booked'];
                Map<String, Project__c> projMap;
                List<String> projIds = new List<String>();
                for(Opportunity opp : oppList){
                    oppMap.put(opp.Id, opp);
                    projIds.add(opp.RW_Project__c);
                }
                if(projIds.size() > 0){
                    projMap = new Map<String, Project__c>([SELECT Id, Name, Contact_No__c FROM Project__c WHERE Id =: projIds]);
                }
                List<Task> tsks = [SELECT Id, WhatId, RecordTypeId, LastModifiedBy.Name, LastModifiedBy.MobilePhone  FROM Task WHERE Id =: tskIds];
                List<Opportunity> oppsToUpdate = new List<Opportunity>();
                for(Task tsk : tsks){
                    String recType = Schema.SObjectType.Task.getRecordTypeInfosById().get(tsk.RecordTypeId).getName();
                    
                    if(templateMap.get(recTypeVsTemplate.get(recType).Email_Template__c) != null && oppMap.get(tsk.WhatId).Not_Contactable_Email_Sent_Date__c != Date.today() && 
                       (recTypeVsTemplate.get(recType).Number_Field__c != null || recTypeVsTemplate.get(recType).User_Mobile_Number_Field__c != null)){
                           Messaging.SingleEmailMessage Message = new Messaging.SingleEmailMessage();
                           String htmlBody = templateMap.get(recTypeVsTemplate.get(recType).Email_Template__c).HtmlValue;
                           //htmlBody = htmlBody.replace('{customer}', oppMap.get(tsk.WhatId).Name);
                           //htmlBody = htmlBody.replace('{rm}', tsk.LastModifiedBy.Name);
                           //htmlBody = htmlBody.replace('{mobile}', tsk.LastModifiedBy.MobilePhone);
                           
                           String custCareNum = '';
                           
                           if(recTypeVsTemplate.get(recType).Number_Field__c != null && recTypeVsTemplate.get(recType).Number_Field__c != ''){
                               //custCareNum = (String) projMap.get(oppMap.get(tsk.WhatId).RW_Project__c).get(recTypeVsTemplate.get(recType).Number_Field__c); //Commented by Vinay 30-01-2025
                               if(oppMap.get(tsk.WhatId).RW_Project__r.Name == '7 Mahalaxmi' && oppMap.get(tsk.WhatId).RW_Project_Unit__c != null && oppMap.get(tsk.WhatId).RW_Project_Unit__r.Relationship_Manager__c != null){ //Added by Vinay 30-01-2025
                                    custCareNum = oppMap.get(tsk.WhatId).RW_Project_Unit__r.Relationship_Manager__r.Contact_Number__c;
                                }else{
                                    custCareNum = (String) projMap.get(oppMap.get(tsk.WhatId).RW_Project__c).get(recTypeVsTemplate.get(recType).Number_Field__c);
                                }
                           }else if(recTypeVsTemplate.get(recType).User_Mobile_Number_Field__c != null && recTypeVsTemplate.get(recType).User_Mobile_Number_Field__c != ''){
                               //custCareNum = tsk.LastModifiedBy.MobilePhone;
                               custCareNum = (String) tsk.LastModifiedBy.get(recTypeVsTemplate.get(recType).User_Mobile_Number_Field__c);
                           }
                           
                           System.debug('custCareNum: ' + custCareNum);
                           if(custCareNum != null){
                               htmlBody = htmlBody.replace('{custCareNum}', custCareNum);
                               htmlBody = htmlBody.replace('{SM Contact Number}', custCareNum);
                           }
                           htmlBody = htmlBody.replace('{SM Name}', tsk.LastModifiedBy.Name);
                           if(oppMap.get(tsk.WhatId).RW_Project__c != null && oppMap.get(tsk.WhatId).RW_Project__r.Name != null){
                               htmlBody = htmlBody.replace('{Project Name}', oppMap.get(tsk.WhatId).RW_Project__r.Name);
                           }
                           
                           
                           message.toAddresses = new List<String>{oppMap.get(tsk.WhatId).RW_Email__c};
                               message.subject = templateMap.get(recTypeVsTemplate.get(recType).Email_Template__c).Subject;
                           message.setTemplateId(templateMap.get(recTypeVsTemplate.get(recType).Email_Template__c).Id);
                           message.setHtmlBody(htmlBody);
                           message.setOrgWideEmailAddressId(orgEmail);
                           //Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
                           emailList.add(message);
                           oppMap.get(tsk.WhatId).Not_Contactable_Email_Sent_Date__c = Date.today();
                           oppsToUpdate.add(oppMap.get(tsk.WhatId));
                       }  
                } 
                Messaging.SendEmailResult[] results = Messaging.sendEmail(emailList);
                System.debug('results: ' + results);
                if(oppsToUpdate.size() > 0){
                    update oppsToUpdate;
                }
            }
            
        }
        
        //Added by coServe 15-07-2024 Start
        Set<String> opportunityIds = new Set<String>();
        for(Task tsk : tskList){
            if(tsk.WhatId != null){
                String sObjName = tsk.WhatId.getSObjectType().getDescribe().getName();
                Id presalesTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Presales Task').getRecordTypeId();//Added by Vinay 24-04-2025
                if(tsk.Communication_Type__c == 'Outbound Call' && sObjName == 'Opportunity' && statusValues.contains(tsk.Call_Status__c) && 
                   oldTskMap.get(tsk.Id).Call_Status__c != tsk.Call_Status__c && tsk.RecordTypeId != presalesTaskRecordTypeId){
                       //taskToSendEmails.add(tsk);
                       //oppIds.add(tsk.WhatId);
                       opportunityIds.add(tsk.WhatId);
                       //tskIds.add(tsk.Id);
                   }
            }
        }
        //List<Opportunity> oppList = [SELECT Id, Name, RW_Email__c, Primary_Name__c, RW_Project__c, RW_Project__r.Name, Account.Country_Code__c, RW_Mobile_No__c, RW_Project__r.Customer_Care_Email__c, RW_Project__r.Contact_No__c  FROM Opportunity WHERE Id =: oppIds];
        if(opportunityIds.size() > 0){
            List<Opportunity> oppList = [SELECT Id, Name, RW_Email__c, Primary_Name__c, RW_Project__c, RW_Project__r.Name, Account.Country_Code__c, RW_Mobile_No__c, RW_Project__r.Customer_Care_Email__c, RW_Project__r.Contact_No__c  FROM Opportunity WHERE Id =: opportunityIds AND StageName = 'Unit Booked'];
            for(Opportunity opp : oppList){
                if(!Test.isRunningTest()){
                    SendWhatsAppMsg.methodToSendWhatsAppMsg(null,opp.Primary_Name__c, opp.RW_Project__r.Contact_No__c, opp.RW_Project__r.Customer_Care_Email__c,null,null,null,null,null,opp.Account.Country_Code__c,opp.RW_Mobile_No__c,'Customer Non Contactable');
                }
            }
        }
        
        //Added by coServe 15-07-2024 End
        
    }
    //Added by coServe 02-05-2024 End
    
    //This method is used to update Case status to contacted if call customer task gets completed
    public void updateCaseStage(list<Task> lstTriggerNew, map<id, Task> mapTriggerOld)
    {
        set<id> setWhatid = new set<id>();
        if(lstTriggerNew != null && lstTriggerNew.size() > 0)
        {
            for(Task objTask : lstTriggerNew)
            {
                if(objTask.status  != null && (mapTriggerOld == null || (mapTriggerOld != null && 
                                                                         objTask.status != mapTriggerOld.get(objTask.id).status)))
                {
                    if(objTask.whatid != null && objTask.whatid.getsobjecttype() == Case.sobjecttype && 
                       objTask.subject != null && objTask.subject == 'Call Customer' && 
                       objTask.Status != null && objTask.Status == 'Completed')
                    {
                        setWhatid.add(objTask.whatid);
                        system.debug('@@@@@@@@@@@@@@setWhatid'+setWhatid);
                    }
                }
            }
            list<Case> lstCasetoupdate = new list<Case>();
            if(setWhatid != null && setWhatid.size()>0)
            {
                //list<Case> lstCase= [select id,Status from Case where id in:setWhatid] ;  
                
                for(id objCaseId : setWhatid)
                {
                    case objCase = new case(id = objCaseId);
                    objCase.Status = 'Contacted';
                    lstCasetoupdate.add(objCase);
                    
                }
            }
            update lstCasetoupdate;
            
        }
    }
    
    private void validateDelete(list<Task> lstTriggerNew, map<id, Task> mapTriggerOld)
    {
        User loggedinUser = [select Id, Profile.Name from User where Id = :UserInfo.getUserId()];
        for(Task EachTask : mapTriggerOld.values())
        {
            if(loggedinUser.Profile.Name != 'System Administrator' && loggedinUser.Profile.Name != 'Sales Strategy') //Sales Strategy added by Priya on 9th september 2018
            {
                EachTask.addError('You cannot delete the task, please contact your system admin.');
            }
        }
    }
    
    //Added by coServe 18-03-2025
    public void cloneWelcomeCallTask(List<Task> newList, map<Id, Task> oldMap){
        List<Id> oppIds = new List<Id>();
        List<Task> tskList = new List<Task>();
        for(Task tsk : newList){
            if(tsk.WhatId != null){
                String sobjectType = tsk.WhatId.getSObjectType().getDescribe().getName(); 
                if(sobjectType == 'Opportunity' && tsk.Call_Status__c == 'Welcome call' && oldMap.get(tsk.Id).Call_Status__c != tsk.Call_Status__c){
                    oppIds.add(tsk.WhatId);
                    tskList.add(tsk);
                }
            }
        }
        if(oppIds.size() > 0){
            Map<Id,Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Id, AccountId, RW_Project__r.Name FROM Opportunity WHERE Id =: oppIds AND RW_Project__r.Name = '7 Mahalaxmi']);
            List<Task> mahalaxmiTasks = new List<Task>();
            for(Task tsk : tskList){
                if(oppMap.containsKey(tsk.WhatId)){
                    mahalaxmiTasks.add(tsk);
                }
            }
            Map<Id, Id> oppIdvsAccId = new Map<Id, Id>();
            for(Opportunity opp : oppMap.values()){
                oppIdvsAccId.put(opp.Id, opp.AccountId);
            }
            List<Opportunity> oppList = [SELECT Id, AccountId FROM Opportunity WHERE AccountId =: oppIdvsAccId.values()];
            Map<Id, List<Id>> accIdVsOppIds = new Map<Id, List<Id>>();
            for(Opportunity op : oppList){
                if(accIdVsOppIds.get(op.AccountId) != null){
                    accIdVsOppIds.get(op.AccountId).add(op.Id);
                }else{
                    accIdVsOppIds.put(op.AccountId, new List<Id>{op.Id});
                }
            }
            List<Task> clonedTasks = new List<Task>();
            for(Task t : mahalaxmiTasks){
                if(accIdVsOppIds.get(oppIdvsAccId.get(t.WhatId)).size() > 1){
                    for(Integer i=0;i<accIdVsOppIds.get(oppIdvsAccId.get(t.WhatId)).size();i++){
                        if(accIdVsOppIds.get(oppIdvsAccId.get(t.WhatId))[i] != t.WhatId){
                            Task clnTsk = t.clone(false, true, false,false);
                            clnTsk.WhatId = accIdVsOppIds.get(oppIdvsAccId.get(t.WhatId))[i];
                            clonedTasks.add(clnTsk);
                        }
                    }
                }
            }
            if(clonedTasks.size() > 0){
                insert clonedTasks;
            }
        }
    }


    //Added by Vinay 31-03-2025
    public void updateServiceCategory(List<Task> newList, map<Id, Task> oldMap){
        List<Service_Category_Mapping__c> serviceCategoryList = [SELECT Id, Call_Status__c, Service_Category__c FROM Service_Category_Mapping__c];
        if(newList.size() > 0 && serviceCategoryList.size() > 0){
            Map<String, String> serviceCategoryMap = new Map<String, String>();
            for(Service_Category_Mapping__c sc : serviceCategoryList){
                serviceCategoryMap.put(sc.Call_Status__c, sc.Service_Category__c);
            }
            for(Task tsk : newList){
                if(tsk.Call_Status__c != null && oldMap.get(tsk.Id).Call_Status__c != tsk.Call_Status__c && serviceCategoryMap.get(tsk.Call_Status__c) != null){
                    tsk.Service_Category__c = serviceCategoryMap.get(tsk.Call_Status__c);
                }
            } 
        }
    }
}