trigger trgTaskHandler on Task (after update, after insert, before update, before insert) {
    //Added by Prashant to bypass trigger in prod. /////// 19-05-25.
    ByPassTriggers__mdt[] byPasstrigMappings = [SELECT Id,Label, ByPassTrigger__c,Object_Name__c FROM ByPassTriggers__mdt];
    Boolean byPassTriggerExceution = false;
    for(ByPassTriggers__mdt bypass : byPasstrigMappings)
    {
        if(bypass.Object_Name__c == 'Task' && bypass.ByPassTrigger__c)
        {
            byPassTriggerExceution = true;
        }
    }
    
    Id preSalesRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Presales Task').getRecordTypeId(); //Added by Vinay 10-09-2025
    public list<Lead> lstLead{get; set;}
    
    if(!byPassTriggerExceution)
    {
        Set<id> setOfIds = new set<id>();
        if(Trigger.isBefore){
            if(Trigger.isInsert){
                List<lead> leadtoUpdate = new list<lead>();
                //Added by Vinay 31-01-2025 Start
                Set<String> ownerIds = new Set<String>();
                for(Task t : trigger.new){
                    if(t.OwnerId != null)
                        ownerIds.add(t.OwnerId);
                }
                Map<Id, User> userMap = new Map<Id, User>();
                if(ownerIds.size() > 0){
                    userMap = new Map<Id, User>([SELECT Id,FirstName,Name,Profile.Name,DID__c FROM User Where id =: ownerIds]);
                }
                //Added by Vinay 31-01-2025 End
                Id serviceTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Service Task').getRecordTypeId(); //Added by Vinay 07-01-2026
                for(Task t : trigger.new){
                    if(t.RecordTypeId == serviceTaskRecordTypeId && t.Task_Type__c == 'CRM Call' && t.Communication_Type__c == 'Inbound Call' && t.Subject == 'CRM Call'){ //Added by Vinay 07-01-2026
                        t.Status = 'Completed';
                    }
                    if(t.OwnerId != null){
                        //User usr = [SELECT Id,FirstName,Name,Profile.Name,DID__c FROM User Where id =: t.OwnerId]; //Commented by Vinay 31-01-2025
                        //t.Attempted_By__c = usr.Name; //Commented by Vinay 31-01-2025
                        t.Attempted_By__c = userMap.get(t.OwnerId).Name; //Added by Vinay 31-01-2025
                    }
                    
                    //Added by Prashant for Truncating the phone number getting stored on remarks field.
                    if(t.Description != null && t.Description.contains('phone_number') && t.Subject == 'New Enquiry Received From:Digital'){
                        String UUIOld = t.Description;
                        String UUI = '';
                        
                        List<String> lines = UUIOld.split('\n');
                        system.debug('lines'+lines);
                        String trimmedResult = '';
                        
                        for (String line : lines) {    
                            if (!line.trim().contains('phone_number')) {
                                trimmedResult += line + '\n';
                            }
                        }
                        system.debug('trimmedResult'+trimmedResult);
                        UUI = trimmedResult.trim();
                        
                        if (String.isBlank(UUI)) {
                            system.debug('Inside Blank UUI');
                            UUI = UUIOld;
                        }
                        
                        system.debug('Old text'+UUIOld);
                        system.debug('New text'+UUI);
                        t.Description = UUI;
                        
                        if(t.WhoId != null && String.valueOf(t.WhoId).startsWith('00Q')){
                            lead l = new lead();
                            l.Description = UUI;
                            l.Id = t.WhoId;
                            leadtoUpdate.add(l);
                        }
                    }
                }
                
                if(!leadtoUpdate.isEmpty()){
                    try{
                        update leadtoUpdate;
                    }catch(Exception e){
                        system.debug('Error while updating lead'+e.getMessage());
                    }
                }
            }
        }
        
        if(Trigger.isBefore){
            if(Trigger.isInsert || Trigger.isUpdate){
                Id PresalesRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Presales Task').getRecordTypeId();
                Id salesRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Sales Task').getRecordTypeId();
                Id CRMRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Service Task').getRecordTypeId();
                Id CPRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Channel Partner/Corporate').getRecordTypeId();
                Id HomeLoanRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Home Loan Call').getRecordTypeId();
                Set<String> UcId =new Set<String>();
                // Added by coServe 12-05-2022 Start
                List<Id> conIds = new List<Id>();
                List<Id> leadIds = new List<Id>();
                Map<Id, Contact> conMap;
                Map<Id, Lead> leadMap;
                for(Task tsk : trigger.New){
                    if(tsk.whoId != null){
                        if(tsk.whoId.getSObjectType().getDescribe().getName() == 'Contact'){
                            conIds.add(tsk.WhoId);
                        }else if(tsk.whoId.getSObjectType().getDescribe().getName() == 'Lead'){
                            leadIds.add(tsk.WhoId);
                        }
                    }
                    if(tsk.RecordTypeId == CRMRecordTypeId && tsk.Task_Type__c == 'CRM Call' && tsk.Communication_Type__c == 'Inbound Call' && tsk.Subject == 'CRM Call'){ //Added by Vinay 12-01-2026
                        tsk.Status = 'Completed';
                    }
                    
                }
                if(conIds.size() > 0){
                    conMap = new Map<Id,Contact>([select id,firstName,lastName from Contact where id =: conIds]);
                }
                if(leadIds.size() > 0){
                    leadMap = new Map<Id,Lead>([select id,name from Lead where id =: leadIds]);
                }
                // Added by coServe 12-05-2022 End
                
                for(Task objTaskNew : trigger.New)
                {
                    if(objTaskNew.whoId != null){
                        if (objTaskNew.whoId.getSObjectType().getDescribe().getName() == 'Contact') {
                            // Commented by coServe 12-05-2022
                            /*for(Contact ac : [select id,firstName,lastName from Contact where id =: objTaskNew.whoId]){
objTaskNew.Lead_Account_Name__c = ac.firstName + ' ' + ac.lastName;
}*/
                            objTaskNew.Lead_Account_Name__c = conMap.get(objTaskNew.whoId).firstName + ' ' + conMap.get(objTaskNew.whoId).lastName;  // Added by coServe 12-05-2022
                        } else if (objTaskNew.whoId.getSObjectType().getDescribe().getName() == 'Lead') {
                            // Commented by coServe 12-05-2022
                            /*for(Lead le : [select id,name from Lead where id =: objTaskNew.whoId]){
objTaskNew.Lead_Account_Name__c = le.name;
}*/
                            objTaskNew.Lead_Account_Name__c = leadMap.get(objTaskNew.whoId).name;  // Added by coServe 12-05-2022
                        }
                    }
                }
                For(Task t: trigger.new){
                    if(t.CallObject!=null)
                    {
                        UcId.add(t.CallObject); 
                    }
                }
                //List<Task> DuplicateTask= [Select Id,CallObject from Task where CallObject IN: UcId ];  //Commented by Vinay 01-07-2025 Start
                 //Added by Vinay 01-07-2025 Start
                 List<Task> DuplicateTask= new List<Task>();
                 if(UcId.size() > 0)
                     DuplicateTask= [Select Id,CallObject from Task where CallObject IN: UcId ];
                 //Added by Vinay 01-07-2025 End
                Map<String,List<Task>> UcidTask=new Map<String,List<Task>>();
                for (Task uc : DuplicateTask) {
                    if (UcidTask.containsKey(uc.CallObject)) {
                        UcidTask.get(uc.CallObject).add(uc);
                    } else {
                        
                        UcidTask.put(uc.CallObject, new List<Task>{uc});
                    }
                }
                
                for(Task t : trigger.new){
                    if(t.activityDate == NULL){
                        t.activityDate = System.today();
                    }
                    if(t.Call_Time__c == null){
                        t.Call_Time__c = System.Now().format('h:mm a');
                        t.DueTime__c = System.Now().format('h:mm a');
                    }
                    //String Calltype = t.Subject;
                    //t.CallType__c = Calltype;
                    if(t.RecordTypeId == PresalesRecordTypeId && t.Task_Type__c != 'Enquiry Received'){
                        t.Task_Type__c = 'Presales Call';
                        if(t.Disposition_Type__c != 'NotAnswered' && t.Visit_Form_No__c != Null ){t.Subject = 'Presales Call';}
                    }
                    else if(t.RecordTypeId == salesRecordTypeId){
                        t.Task_Type__c = 'Sales Call';
                        if(t.Disposition_Type__c != 'NotAnswered' && t.Visit_Form_No__c != Null){t.Subject = 'Sales Call';}
                    }
                    else if(t.RecordTypeId == CRMRecordTypeId){
                        t.Task_Type__c = 'CRM Call';
                        if(UcidTask.size()>1) 
                        {
                            if(t.CallObject != null && UcidTask.get(t.CallObject) != null && UcidTask.get(t.CallObject).size()>1) 
                            {
                                t.Subject = 'Duplicate CRM Call'; 
                                t.Status = 'Completed';
                            }
                        }
                        if(t.Disposition_Type__c != 'NotAnswered' && t.Visit_Form_No__c != Null ){t.Subject = 'CRM Call';}
                    }
                    else if(t.RecordTypeId == CPRecordTypeId ){				
                        //t.Subject = 'CP Call';
                        t.Task_Type__c = 'CP Call';
                        if(t.Disposition_Type__c != 'NotAnswered' && t.Visit_Form_No__c != Null ){t.Subject = 'CP Call';}
                        
                    }
                    else if(t.RecordTypeId == HomeLoanRecordTypeId){		//Added by Sheetal 
                        t.Task_Type__c = 'Home Loan Call';
                        if(t.Disposition_Type__c != 'NotAnswered' && t.Visit_Form_No__c != Null ){t.Subject = 'Home Loan Call';}
                    }
                    if(t.CallType == 'Inbound'){
                        t.Communication_Type__c = 'Inbound Call';
                    }
                    if(t.CallType == 'Outbound'){
                        t.Communication_Type__c = 'Outbound Call';
                    }
                }
                /*for(Task t: trigger.new)
{
User Usr = [Select id,Name,Profile.Name from User where id=: UserInfo.getUserId()];
if(usr.Profile.Name == 'Sales Manager' || usr.Profile.Name == 'NRI Sales Manager' ){
t.RecordTypeId = '01228000000nR1AAAU';
t.Task_Type__c = 'Sales Call';
}
if(usr.Profile.Name == 'Relationship Manager'){
t.RecordTypeId = '01228000000nR1BAAU';
t.Task_Type__c = 'CRM Call';
}
if(usr.Profile.Name == 'Pre Sales Manager'){
t.RecordTypeId = '0120I000000ycfhQAA';
t.Task_Type__c = 'Presales Call';
}
}*/
            }    
        }
        
        
        
        
        if(Trigger.isInsert) 
        {   
            Id CRMRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Service Task').getRecordTypeId();
            if(Trigger.isAfter) 
            {        List <task> cifcreatecase = new List<task> ();
             TaskManagementServices.latestTaskRollupToOpp(Trigger.new);
             TaskManagementServices.latestTaskRollupToLead(Trigger.new);
             TaskManagementServices.latestTaskRollupToProspect(Trigger.new);
             //    TaskManagementServices.updateSCPP(trigger.new);
             //    TaskManagementServices.HomeLoanTaskRollupToOpp(trigger.new);
             //    TaskManagementServices.RegTaskRollupToOpp(trigger.new);
             TaskManagementServices.createCommunicationEntries(trigger.new);
             
             // Added by Shailesh //
             TaskManagementServices.countNumberOfVisitsOnOpportunity(trigger.new, trigger.oldMap);
             List<Task> callsToSchedule = new List<Task>(); //Added by Vinay 10-09-2025
             List <Task> TaskLst2 = new List <Task> ();
             List <task> cifTasklist = new List<task> ();
             Set < Id > enquiryIds = new Set < Id > ();
             Set < Id > enquiryLeads = new Set < Id > ();
             List<Lead> LeadList = new List<Lead>();
             ID LeadaccId ;
             List<Task> missedCallTasks = new List<Task>();
             for(Task t: trigger.new)
             {
                 if(t.RecordTypeId==CRMRecordTypeId && t.Task_Type__c=='CRM Call' && t.Communication_Type__c=='Inbound Call' && t.Subject=='CRM Call')
                 {
                    System.debug('t.WhatId: ' + t.WhatId);
                    System.debug('t.WhoId: ' + t.WhoId);
                     cifcreatecase.add(t);
                 }
                 if(t.Task_Type__c=='Presales Call')
                 {
                     TaskLst2.add(t);
                 }
                 //Added by Shailesh//
                 if(t.Task_Type__c=='Site Visit' && t.CI_Form__c != null)
                     cifTasklist.add(t);
                 /***** Added by Shailesh for sending enquiries to Anarock *****/
                 if(t.task_type__c == 'Enquiry Received' && t.Is_Created_through_Anarock__c == false) {
                     enquiryIds.add(t.Id);
                 }
                 /***** Added by Payal for sending enquiries to Ameyo on 8/9/21 *****/
                 if(t.task_type__c == 'Enquiry Received') {
                     enquiryLeads.add(t.Id);
                 }
                 // Added by Vinay 03-05-2023 Start
                 if(t.Task_Type__c == 'CRM Call' && t.Communication_Type__c == 'Inbound Call' && t.Subject == 'Missed Call') {
                     missedCallTasks.add(t);
                 }
                 if(t.WhoId != null){
                     LeadaccId = t.WhoId;
                     if(LeadaccId.getSObjectType().getDescribe().getName() == 'Lead'){
                         Lead l = new Lead();
                         l.id = t.WhoId;
                         l.Is_DND__c = false;
                         LeadList.add(l);
                     }
                 }
                 if(t.Next_Action_Date__c != null && System.label.Allow_Auto_Callback == 'Yes' && (t.RecordTypeId == preSalesRecordTypeId || t.Task_Type__c == 'Presales Call')){ //Added by Vinay 10-09-2025
                    callsToSchedule.add(t); 
                }
                 
                 // Added by Vinay 01-11-2023 Start
                 /*if(t.Disposition_Type__c == 'Success' || t.Disposition_Type__c == 'Answered'){
System.debug('Disposition_Type__c: ');
String sObjName;
if(t.WhatId != null){
sObjName = t.WhatId.getSObjectType().getDescribe().getName();
}else if(t.WhoId != null){
sObjName = t.WhoId.getSObjectType().getDescribe().getName();
}
String customerName;
String mobile;
String countryCode;
String objId;
if(sObjName == 'Opportunity'){
Opportunity opp = [SELECT Id, Name, Account.Name, Account.Mobile_No__c, Account.Country_Code__c  FROM Opportunity WHERE Id =: t.WhatId];
System.debug('opp.Account.Name: ' + opp.Account.Name);
customerName = opp.Account.Name;
mobile = opp.Account.Mobile_No__c;
countryCode = opp.Account.Country_Code__c;
objId = opp.Id;
}else if(sObjName == 'Account'){
Account acc = [SELECT Id, Name, Mobile_No__c, Country_Code__c  FROM Account WHERE Id =: t.WhatId];
customerName = acc.Name;
mobile = acc.Mobile_No__c;
countryCode = acc.Country_Code__c;
objId = acc.Id;
}else if(sObjName == 'Lead'){
Lead ld = [SELECT Id, Name, RW_Mobile_No__c, RDS_Country_Code__c  FROM Lead WHERE Id =: t.WhoId];
customerName = ld.Name;
mobile = ld.RW_Mobile_No__c;
countryCode = ld.RDS_Country_Code__c;
objId = ld.Id;
}
if(!Test.isRunningTest()){
SendWhatsAppMsg.methodToSendWhatsAppMsg(objId, customerName, null, null, null, null, null, null, null, countryCode, mobile, 'call_disposition');
}

}*/
                 // Added by Vinay 01-11-2023 End
                 
                 
                 
             }
             
             if(!cifcreatecase.isEmpty())
                 CIFManagementServices.createcase(cifcreatecase);   
             TaskManagementServices.callStatusMethod(TaskLst2);
             if(!cifTasklist.isEmpty())
                 CIFManagementServices.updateFeedbackOnCif(cifTasklist);    
             if(!enquiryIds.isEmpty())
                 PushDigitalEnquiriesToAnarock.checkPrerequisiteforCallout(enquiryIds); 
             if(!enquiryLeads.isEmpty())
                 PushDigitalEnquiries.checkPrerequisiteforCallout(enquiryLeads);
             if(!LeadList.isEmpty()){
                 Update LeadList;
             }
             // Added by Vinay 03-05-2023 
             if(!missedCallTasks.isEmpty())
                 TaskManagementServices.missedCallemailAlert(missedCallTasks);
             if(callsToSchedule.size() > 0){ //Added by Vinay 10-09-2025
                ScheduleOzonetelCalls.callSchedule(callsToSchedule);
             }
            }
            
        }
        List<Id> TaskIddisp = new List<Id>();
        Set<Id> TaskIdsche = new Set<Id>();
        if(Trigger.isUpdate) 
        {
            if(Trigger.isAfter) 
            {
                List <task> cifTasklist = new List<task> ();
                List<Task> nodChangedTasks = new List<Task>(); //Added by Vinay 10-09-2025
                if(checkRecursion.isFirstRun()) 
                {
                    Id CRMRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Service Task').getRecordTypeId(); // Added by Vinay 13-01-2026
                    ///------------------added by vikas for edit option on customer interaction to rollup on opp &lead------------////
                    TaskManagementServices.latestTaskRollupToOpp(Trigger.new); 
                    TaskManagementServices.latestTaskRollupToLead(Trigger.new);
                    TaskManagementServices.latestTaskRollupToProspect(Trigger.new);
                    /////// ------------------------------ vikas added end here ------------------------/////////////////////////
                    
                    //  TaskManagementServices.HomeLoanTaskRollupToOpp(trigger.new);
                    TaskManagementServices.createCommunicationEntries(trigger.new);
                    //  TaskManagementServices.RegTaskRollupToOpp(trigger.new);
                    List<Lead> LeadList = new List<Lead>();
                    List <task> cifcreatecase = new List<task> (); //Added by Vinay 13-01-2026
                    ID LeadaccId ;
                    for(Task t: trigger.new)
                    {
                        if(t.Visit_Form_No__c != null){
                            if(t.WhoId != null){
                                LeadaccId = t.WhoId;
                                if(LeadaccId.getSObjectType().getDescribe().getName() == 'Lead'){
                                    Lead l = new Lead();
                                    l.id = t.WhoId;
                                    l.Campaign_Code__c = t.Visit_Form_No__c;
                                    LeadList.add(l);
                                }
                                
                            }
                        }
                        //Added by Shailesh//
                        if(t.Task_Type__c=='Site Visit' && t.CI_Form__c != null)
                            cifTasklist.add(t);
                        if(trigger.oldMap.get(t.id).Description != trigger.newMap.get(t.id).Description){
                            TaskIddisp.add(t.id);  
                        }
                        System.debug('Next Action old :: '+trigger.oldMap.get(t.id).Next_Action_Date__c);
                        System.debug('Next Action New:: '+trigger.newMap.get(t.id).Next_Action_Date__c);
                        if((trigger.oldMap.get(t.id).Next_Action_Date__c != trigger.newMap.get(t.id).Next_Action_Date__c) && t.Next_Action_Date__c != null && t.Next_Action_Date__c >= system.today()){
                            TaskIdsche.add(t.id);
                        }
                        if(t.Next_Action_Date__c != trigger.oldMap.get(t.id).Next_Action_Date__c && System.label.Allow_Auto_Callback == 'Yes' && (t.RecordTypeId == preSalesRecordTypeId  || t.Task_Type__c == 'Presales Call')){ //Added by Vinay 10-09-2025
                            nodChangedTasks.add(t);
                        }

                        if(t.RecordTypeId==CRMRecordTypeId && t.Task_Type__c=='CRM Call' && t.Communication_Type__c=='Inbound Call' && t.Subject=='CRM Call'){ //Added by Vinay 13-01-2026
                            cifcreatecase.add(t);
                        }
                    }   
                    if(!LeadList.isEmpty()){
                        Update LeadList;
                    }
                    if(!cifTasklist.isEmpty())
                        CIFManagementServices.updateFeedbackOnCif(cifTasklist);
                    if(nodChangedTasks.size() > 0){ //Added by Vinay 10-09-2025
                        ScheduleOzonetelCalls.callSchedule(nodChangedTasks);
                    }   
                    
                    //if(!cifcreatecase.isEmpty())   //Added by Vinay 13-01-2026 //Commented by Vinay 09-02-2026
                        //CIFManagementServices.createcase(cifcreatecase);  //Commented by Vinay 09-02-2026
                    }
                
            }
            
        }
        
        
        system.debug('TaskIdsche::'+TaskIdsche.size());
        system.debug('TaskIddisp::'+TaskIddisp.size());
        
        if(!TaskIdsche.isEmpty()){
            System.debug('Inside call scheduleCall');
            CallOzonetelSchedulerAPI.scheduleCall(TaskIdsche);
        }
        if(!TaskIddisp.isEmpty()){
            System.debug('Inside call sendDisposition');
            OzonetelCallDisposition.sendDisposition(TaskIddisp);
        }
        if(Trigger.isUpdate) 
        {
            Id WelcomeRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Welcome Call').getRecordTypeId();	//Added by Sheetal on 16/6/2022 to solve issue I0189
            Id CPMeeting = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Channel Partner/Corporate').getRecordTypeId(); //Added by Prashant on 5//11/24 to solve CP Meeting task being closed on creation
            Id ReminderLetterRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Reminder letter').getRecordTypeId();//Added by Prashant on 28-03-25 to solve Reminder letter task being closed on creation
            if(Trigger.isBefore) 
            {
                for(Task t: trigger.new)
                {
                    if(t.Description != null && t.Description != '' && t.RecordTypeId != WelcomeRecordTypeId && t.RecordTypeId != CPMeeting && t.RecordTypeId != ReminderLetterRecTypeId){
                        t.Status = 'Completed';
                        
                    }
                }
            }
        }
    }
}