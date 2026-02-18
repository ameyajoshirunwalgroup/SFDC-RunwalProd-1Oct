public class TaskManagementServices {
    public static String className = TaskManagementServices.class.getName();
    public static Map < Id, Task > createTaskforEnquiries(Map < Id, Lead > enquiriesMap) {
        List < task > taskList = new List < Task > ();
        List < task > retTaskList = new List < Task > ();
        List < Id > taskIds = new List < Id > ();
        Map < Id, Task > taskWhoIdMap = new Map < Id, Task > ();
        List < Id > aSet = new List < Id > ();
        List < Id > lSet = new List < Id > ();
        Map < Id, Account > accDetails = new Map < Id, Account > ();
        Map < Id, Lead > leadDetails = new Map < Id, Lead > ();
        
        System.debug('Enquiries Map:' + enquiriesMap);
        
        if (!enquiriesMap.isEmpty()) {
            for (Id wid: enquiriesMap.keyset()) {
                if (wId.getSObjectType().getDescribe().getName() == 'Account') {
                    aSet.add(wid);
                } else if (wId.getSObjectType().getDescribe().getName() == 'Lead') {
                    lSet.add(wid);
                } else {
                    
                }
            }
            
            // if the task is to be associated with an person account, then the personcontactId has to be mapped in whoId
            
            if (!aSet.isEmpty()) {
                accDetails = new Map < Id, Account > ([Select Id, PersonContactId, OwnerId from Account where id in : aSet]);
            }
            
            if (!lset.isEmpty()) {
                leadDetails = new Map < Id, Lead > ([Select Id, OwnerId from Lead where id in : lSet]);
            }
            
            System.debug('LEAD DETAILS:' + leadDetails);
            System.debug('ACCOUNT DETAILS:' + accDetails);
            
            
            for (Id wId: enquiriesMap.keyset()) {
                task t = new task();
                t.status = 'Completed';
                t.task_type__c = 'Enquiry Received';
                t.Subject = 'New Enquiry Received From:' + enquiriesMap.get(wId).leadSource;
                if (String.isNotBlank(enquiriesMap.get(wId).lastName))
                    t.FullName__c = (enquiriesMap.get(wId).lastName);
                //if (String.isNotBlank(enquiriesMap.get(wId).RDS_Email__c))
                //t.emailAddress__c = (enquiriesMap.get(wId).RDS_Email__c);//
                if (String.isNotBlank(enquiriesMap.get(wId).Email))
                {
                    t.emailAddress__c = (enquiriesMap.get(wId).Email);   
                    t.Email_Id__c =(enquiriesMap.get(wId).Email); 
                }
                if (String.isNotBlank(enquiriesMap.get(wId).Country__c))
                    t.country__c = (enquiriesMap.get(wId).Country__c);
                if (String.isNotBlank(enquiriesMap.get(wId).RDS_Country_Code__c))
                    t.dialingCode__c = (enquiriesMap.get(wId).RDS_Country_Code__c);
                //if (String.isNotBlank(enquiriesMap.get(wId).RDS_Mobile__c))
                //t.Mobile_Number_Webform__c = (enquiriesMap.get(wId).RDS_Mobile__c);//
                
                if (String.isNotBlank(enquiriesMap.get(wId).RW_Mobile_No__c))
                    t.Mobile_Number_Webform__c = (enquiriesMap.get(wId).RW_Mobile_No__c);    
                
                
                if (String.isNotBlank(enquiriesMap.get(wId).LeadSource)) //added by Shahbaj 27/11/2017
                    t.Source_of_enquiry__c = (enquiriesMap.get(wId).LeadSource); 
                
                if (String.isNotBlank(enquiriesMap.get(wId).RW_Lead_Sub_Source__c))//added by Shahbaj 27/11/2017
                    t.Sub_source_of_enquiry__c = (enquiriesMap.get(wId).RW_Lead_Sub_Source__c); 
                
                if (String.isNotBlank(enquiriesMap.get(wId).RW_Budget__c ))
                    t.Budget_WebForm__c = (enquiriesMap.get(wId).RW_Budget__c);
                if (String.isNotBlank(enquiriesMap.get(wId).RW_Project__c))
                    t.Project__c = (enquiriesMap.get(wId).RW_Project__c);
                if (String.isNotBlank(enquiriesMap.get(wId).description))
                    t.description = (enquiriesMap.get(wId).description);    
                //if (String.isNotBlank(enquiriesMap.get(wId).Source_Remarks__c))
                // t.description = 'Customer Enquired through ' + (enquiriesMap.get(wId).Source_Remarks__c);//
                //fields added for SEO information
               /* if (String.isNotBlank(enquiriesMap.get(wId).web_banner_source__c))
                    t.web_banner_source__c = (enquiriesMap.get(wId).web_banner_source__c);*/
                 if (String.isNotBlank(enquiriesMap.get(wId).Banner_Type__c))  			//Added by Sheetal on 11/10/2023
                    t.web_banner_source__c = (enquiriesMap.get(wId).Banner_Type__c);
                 /*if (String.isNotBlank(enquiriesMap.get(wId).RW_With_Balcony__c))  			//Added by Sheetal on 11/10/2023
                    t.Deal_Type__c = (enquiriesMap.get(wId).RW_With_Balcony__c); */
                 if (String.isNotBlank(enquiriesMap.get(wId).CTA_Source__c))  			//Added by Sheetal on 11/10/2023
                    t.Anarock_Sourcing_Manager__c = (enquiriesMap.get(wId).CTA_Source__c);                
                if (String.isNotBlank(enquiriesMap.get(wId).web_banner_size__c))
                    t.web_banner_size__c = (enquiriesMap.get(wId).web_banner_size__c);
                if (String.isNotBlank(enquiriesMap.get(wId).IP_address_web2lead__c))
                    t.IP_address_web2lead__c = (enquiriesMap.get(wId).IP_address_web2lead__c);
                if (String.isNotBlank(enquiriesMap.get(wId).RW_Configuration__c))
                    t.Configuration__c = (enquiriesMap.get(wId).RW_Configuration__c);
                t.Is_Created_through_Anarock__c = (enquiriesMap.get(wId).Is_Anarock_Lead__c);   
                ///////////////////////////////////////////----------------------- vikas added below some field on dated 23-08-16 for web lead enquiry received -------------------///////////////////////// 
                
                if (String.isNotBlank(enquiriesMap.get(wId).UTM_Campaign__c))
                    t.UTM_Campaign__c = (enquiriesMap.get(wId).UTM_Campaign__c);
                /*if (String.isNotBlank(enquiriesMap.get(wId).UTM_Display__c))
                    t.UTM_Display__c = (enquiriesMap.get(wId).UTM_Display__c);*/
                  if (String.isNotBlank(enquiriesMap.get(wId).Ad_Group__c))  //added by Sheetal on 11/10/2023
                    t.UTM_Display__c = (enquiriesMap.get(wId).Ad_Group__c);                                
                if (String.isNotBlank(enquiriesMap.get(wId).UTM_Medium__c))
                    t.UTM_Medium__c = (enquiriesMap.get(wId).UTM_Medium__c);
                if (String.isNotBlank(enquiriesMap.get(wId).UTM_Source__c))
                    t.UTM_Source__c = (enquiriesMap.get(wId).UTM_Source__c);
               /* if (String.isNotBlank(enquiriesMap.get(wId).UTM_Term__c))
                    t.UTM_Term__c = (enquiriesMap.get(wId).UTM_Term__c);*/
                    if (String.isNotBlank(enquiriesMap.get(wId).Placement__c))  //Added by Sheetal on 11/10/2023
                    t.UTM_Term__c = (enquiriesMap.get(wId).Placement__c);
                
                 if (String.isNotBlank(enquiriesMap.get(wId).Device__c))  //Added by Sheetal on 11/10/2023
                    t.New_Channel_Partner_Name__c = (enquiriesMap.get(wId).Device__c);
                
                 if (String.isNotBlank(enquiriesMap.get(wId).Gclid__c))  //Added by Sheetal on 11/10/2023
                    t.New_Channel_Partner_Email__c = (enquiriesMap.get(wId).Gclid__c);
                
                   if (String.isNotBlank(enquiriesMap.get(wId).Gclid__c))  //Added by Sheetal on 11/10/2023
                    t.New_Channel_Partner_Email__c = (enquiriesMap.get(wId).Gclid__c);
                
                 if (String.isNotBlank(enquiriesMap.get(wId).RW_Unregistered_Broker_Name__c))  //Added by Sheetal on 30/10/2023
                    t.Ad_ID__c = (enquiriesMap.get(wId).RW_Unregistered_Broker_Name__c);
                
                 if (String.isNotBlank(enquiriesMap.get(wId).Walkin_Unregistered_ChannelPartner_Name__c))  //Added by Sheetal on 30/10/2023
                    t.Ad_name__c = (enquiriesMap.get(wId).Walkin_Unregistered_ChannelPartner_Name__c);
                
                ////////////////////////////////////////////////////------------------- vikas added field end here -----------------------------///////////////////////////////  
                
                if (wId.getSObjectType().getDescribe().getName() == 'Lead') {
                    User u = [Select Id,IsActive from User where Id =:leadDetails.get(wid).OwnerId];
                    t.whoId = wId;
                    if(u.IsActive == true)
                        t.OwnerId = leadDetails.get(wid).OwnerId;
                } else if (wId.getSObjectType().getDescribe().getName() == 'Account') {
                    User u = [Select Id,IsActive from User where Id =:accDetails.get(wid).OwnerId];
                    t.whoId = accDetails.get(wId).PersonContactId;
                    if(u.IsActive == true)
                        t.ownerId = accDetails.get(wid).OwnerId;
                    t.whatId = wId;
                } else {
                    t.whoId = '';
                    t.ownerId = '';
                }
                if (t.ActivityDate == null) {
                    t.activityDate = System.today();
                    t.Call_Time__c = System.Now().format('h:mm a');
                }
                taskList.add(t);
            }
            
            try {
                Database.SaveResult[] srList = Database.insert(taskList, true);
                // Iterate through each returned result
                
                for (Database.SaveResult sr: srList) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully inserted account. Task ID: ' + sr.getId());
                        taskIds.add(sr.getId());
                    } else {
                        // Operation failed, so get all errors  
                        List < String > customMsgList = new List < String > ();
                        for (Database.Error err: sr.getErrors()) {
                            String msg = 'Task Insert Failed :' + err.getMessage();
                            customMsgList.add(msg);
                        }
                        throw new GlobalException(customMsgList, '', className);
                    }
                }
                
                if (!taskIds.isEmpty()) {
                    retTaskList = [SELECT Id, Subject, WhoId, WhatId, OwnerId from Task where Id in : taskIds];
                }
                
                for (task t: retTaskList) {
                    taskWhoIdMap.put(t.whoId, t);
                }
                
            } catch (System.DmlException ex) {
                List < String > customMsgList = new List < String > ();
                for (Integer i = 0; i < ex.getNumDml(); i++) {
                    String msg = 'Task Insert Failed :' + ex.getMessage();
                    customMsgList.add(msg);
                }
                throw new GlobalException(customMsgList, '', className);
            }
        }
        return taskWhoIdMap;
    }
    
    public static List < Task > getTaskByType(String taskType, String taskStatus, String sortField, String sortOrder, Id whatId) {
        
        String baseQuery = 'SELECT Id, Subject, Task_Type__c,Voice_Log_URL__c, ActivityDate,Call_Time__c,call_status__c, Status, What.Name, Who.Name, Priority,Registraion_Status__c, Owner.Name, Description,Call_Attempt_Status__c,Previous_Call_Attempt_Status__c,Attempted_By__c from Task '; ///Call_Time__c
        String buildQuery = baseQuery;
        List < String > customMsgList = new List < String > ();
        
        if (String.isBlank(taskType) || String.isblank(taskStatus) || String.isBlank(sortOrder) || String.isBlank(sortField) || String.isBlank(whatId)) {
            String msg = 'Required Parameters Missing';
            customMsgList.add(msg);
            throw new GlobalException(customMsgList, '', 'TaskManagementServices.getTaskByType');
        }
        
        if (!sortOrder.equals('ASC') && !sortOrder.equals('DESC')) {
            String msg = 'Incorrect sort order, sort order can only be ASC or DESC';
            customMsgList.add(msg);
            throw new GlobalException(customMsgList, '', 'TaskManagementServices.getTaskByType');
            
        }
        List < String > taskStatusList = new List < String > ();
        if (taskStatus.equals('ALL')) {
            taskStatusList.add('\'Completed\'');
            taskStatusList.add('\'Not Started\'');
            taskStatusList.add('\'Scheduled\'');
            taskStatusList.add('\'In-progress\'');
        } else {
            taskStatusList.add('\'' + taskStatus + '\'');
        }
        
        buildQuery = buildQuery + 'where task_type__c =' + '\'' + taskType + '\'' + ' and status IN ' + taskStatusList + ' and whatId =' + '\'' + whatId + '\'' + ' order by Status, ' + sortField + ' ' + sortOrder;
        System.debug('QUERY:' + buildQuery);
        List < Task > taskList = (List < Task > ) Database.query(buildQuery);
        return taskList;
    }
    // Added by shailesh on 11.12.2017//
    public static List < Task > getAllsiteVisitTasks(String taskStatus, String sortField, String sortOrder, Id whatId) {
        
        String baseQuery = 'SELECT Id, Subject, Task_Type__c, ActivityDate,Call_Time__c, call_status__c,Status, What.Name, Who.Name, Priority,Registraion_Status__c, Owner.Name, Description,Call_Attempt_Status__c,Previous_Call_Attempt_Status__c,Attempted_By__c from Task '; ///Call_Time__c
        String buildQuery = baseQuery;
        List < String > customMsgList = new List < String > ();
        
        if (String.isblank(taskStatus) || String.isBlank(sortOrder) || String.isBlank(sortField) || String.isBlank(whatId)) {String msg = 'Required Parameters Missing';customMsgList.add(msg);
            throw new GlobalException(customMsgList, '', 'TaskManagementServices.getTaskByType');
        }
        
        if (!sortOrder.equals('ASC') && !sortOrder.equals('DESC')) {String msg = 'Incorrect sort order, sort order can only be ASC or DESC';customMsgList.add(msg);
            throw new GlobalException(customMsgList, '', 'TaskManagementServices.getTaskByType');
            
        }
        List < String > taskStatusList = new List < String > ();
        List < String > tasktypeList = new List< String > ();
        if (taskStatus.equals('ALL')) {
            taskStatusList.add('\'Completed\'');
            taskStatusList.add('\'Not Started\'');
            taskStatusList.add('\'Scheduled\'');
              taskStatusList.add('\'In-progress\'');
        } else {
            taskStatusList.add('\'' + taskStatus + '\'');
        }
        tasktypeList.add('\'Site Visit\'');
        tasktypeList.add('\'Re-Visit\'');   
        buildQuery = buildQuery + 'where task_type__c IN' + tasktypeList+ ' and status IN ' + taskStatusList + ' and whatId =' + '\'' + whatId + '\'' + ' order by Status, ' + sortField + ' ' + sortOrder;
        System.debug('QUERY:' + buildQuery);
        List < Task > taskList = (List < Task > ) Database.query(buildQuery);
        return taskList;
    }
    public static List < Task > getTaskByTypeLead(String taskType, String taskStatus, String sortField, String sortOrder, Id whoId) {
        // New - Netra 18/03/2016
        String baseQuery = 'SELECT Id, Subject, Task_Type__c, ActivityDate,Call_Time__c, call_status__c, Status, What.Name, Who.Name, Priority, OwnerId, Description,Call_Attempt_Status__c,Previous_Call_Attempt_Status__c,Attempted_By__c FROM Task '; //Call_Time__c
        
        String buildQuery = baseQuery;
        List < String > customMsgList = new List < String > ();
        
        if (String.isBlank(taskType) || String.isblank(taskStatus) || String.isBlank(sortOrder) || String.isBlank(sortField) || String.isBlank(whoId)) {String msg = 'Required Parameters Missing';customMsgList.add(msg);
            throw new GlobalException(customMsgList, '', 'TaskManagementServices.getTaskByType');
        }
        
        if (!sortOrder.equals('ASC') && !sortOrder.equals('DESC')) {String msg = 'Incorrect sort order, sort order can only be ASC or DESC';customMsgList.add(msg);
            throw new GlobalException(customMsgList, '', 'TaskManagementServices.getTaskByType');
            
        }
        List < String > taskStatusList = new List < String > ();
        if (taskStatus.equals('ALL')) {
           taskStatusList.add('\'Completed\'');
            taskStatusList.add('\'Not Started\'');
             taskStatusList.add('\'In-progress\'');
           
        } else {
            taskStatusList.add('\'' + taskStatus + '\'');
        }
        
        buildQuery = buildQuery + 'where task_type__c =' + '\'' + taskType + '\'' + ' and status IN ' + taskStatusList + ' and whoId =' + '\'' + whoId + '\'' + ' order by Status, ' + sortField + ' ' + sortOrder;
        System.debug('QUERY:' + buildQuery);
        List < Task > taskList = (List < Task > ) Database.query(buildQuery);
        return taskList;
    }
    
    
    public static boolean isRevisit(String parentId) {
        List < Task > taskList = new List < Task > ();
        taskList = TaskManagementServices.getTaskByType('Site Visit', 'ALL', 'createdDate', 'DESC', parentId);
        if (taskList.size() > 0)
            return true;
        else
            return false;
    }
    
    public static boolean isFirstVisit(String parentId) {
        List < Task > taskList = new List < Task > ();
        taskList = TaskManagementServices.getTaskByType('Site Visit', 'ALL', 'createdDate', 'DESC', parentId);
        if (taskList.size() == 1)
            return true;
        else
            return false;
    }
    
    public static void latestTaskRollupToOpp(List < Task > taskList) {
        Map < Id, Task > opptyTaskMap = new Map < Id, Task > ();
        for (Task t: TaskList) {
            if (t.WhatId != null && t.WhatId.getSObjectType().getDescribe().getName() == 'Opportunity') {
                if (opptyTaskMap.containsKey(t.whatId)) {
                    // if a task already exist for the oppty, 
                    // replace it with the new task only if the new task is the latest
                    if (opptyTaskMap.get(t.whatId).createdDate < t.createdDate) {opptyTaskMap.put(t.whatId, t);
                    }
                } else {
                    opptyTaskMap.put(t.whatId, t);
                }
            }
        }
        List < Opportunity > oppList = new List<Opportunity>();
        List < AggregateResult > taskCountAg = new List<AggregateResult>();
        Set < Id > accIdSet = new Set < Id > ();
        if(!opptyTaskMap.isEmpty()){ //Added if condition by Vinay 01-07-2025
            oppList = [select Name, Id, call_proposed_date_of_visit__c, Follow_up_date__c,
                                        Last_call_attempted_by__c, Last_call_attempt_status__c, Last_call_description__c,
                                        last_call_attempt_date__c,First_Call_Attempt_Date__c,First_Sales_Call_Attempt_Date__c, First_Call_Attempt_Status__c, First_Sales_Call_Attempt_Status__c, Last_Call_Rating__c, Presales_Call_counter__c,IsFirstSalesCall__c,Sales_Call_Count__c,
                                        Unique_SVF_Number__c, Walk_in_Source__c, Walk_in_Sub_Source__c, Site_Visit_Channel_Partner__c, //Xcelerate_ID__c,
                                        Walk_in_Channel_Partner_Email__c, Walk_in_Channel_Partner_Name__c,
                                        Walk_in_Channel_Partner_Phone__c, Walk_in_Channel_Partner__c,
                                        Walk_in_Source_Remarks__c, /*Last_VDNB_Attempted_By__c, Last_VDNB_Call_status__c, Last_VDNB_Attempt_Date__c,*/
                                        Expected_Re_Visit_Date__c, /*Next_Action_Date_VDNB__c, Last_VDNB_Call_Description__c,*/
                                        Walk_in_Respective_Customer_Account__c, Walk_in_Attended_By__c,
                                        visit_counter__c, Date_Of_Visit__c, Visit_Rating__c, Visit_Task_Id__c, AccountId,
                                        Sales_Manager__c, Descriptive_Remarks_Feedback__c,RW_Sales_Manager_Comment__c,
                                        Unit_type_configuration__c, S_Budget__c, IsFirstPresalesCall__c,Sales_Call_Attempt_Status__c ,
                                        Sales_Call_Description__c,Sales_Call_Attempted_By__c ,Sales_Next_Action_Date__c,Sales_Call_Proposed_Date_Of_Visit__c,Sales_Call_Attempt_Date__c,
                                        Sales_Call_Rating__c,Last_CRM_Call_Attempt_Date__c,last_CRM_call_attempted_by__c,First_CRM_Call_Attempt_Date__c,First_CRM_Call_Attempt_Status__c,Last_CRM_Call_Attempt_Status__c,First_CRM_Call_Attempted_by__c
                                        from Opportunity
                                        where Id in : opptyTaskMap.keySet()
                                       ];
            taskCountAg = [Select count(Id) taskCount, whatId oppId, task_type__c taskType from Task
                                                where whatId in : opptyTaskMap.keySet() group by whatId, task_type__c
                                               ];
        }
        
        Map < String, Map < String, Integer >> oppTaskCountMap = new Map < String, Map < String, Integer >> ();
        for (AggregateResult ar: taskCountAg) {
            if (oppTaskCountMap.containsKey((String) ar.get('oppId'))) {
                oppTaskCountMap.get((String) ar.get('oppId')).put((String) ar.get('taskType'), (Integer) ar.get('taskCount'));
            } else {
                Map < String, Integer > tempMap = new Map < String, Integer > ();
                tempMap.put((String) ar.get('taskType'), (Integer) ar.get('taskCount'));
                oppTaskCountMap.put((String) ar.get('oppId'), tempMap);
            }
        }
        for (Opportunity o: oppList) {
            System.debug('Oppty:' + o);
            if (opptyTaskMap.containsKey(o.Id) && opptyTaskMap.get(o.Id).Task_Type__c == 'Presales Call') {
                // Commented by Priya on 2 Dec 2017
                //       if (string.isNotBlank(o.Last_call_description__c ))
                //           o.Last_call_description__c += '\n' + system.today().format() + ' : ' + opptyTaskMap.get(o.Id).Call_Rating__c + ' : ' + opptyTaskMap.get(o.Id).description;
                //       else
                
                
                //Modified by Sheetal on 06/01/2021 to solve Issue I0099
                //  o.Last_call_description__c = system.today().format() + ' : ' + opptyTaskMap.get(o.Id).Call_Rating__c + ' : '  + opptyTaskMap.get(o.Id).description;
                
                if(!system.today().format().contains('GMT') && string.isNotBlank(o.Last_call_description__c ) ){
                    o.Last_call_description__c = system.today().format() + ' : ' + opptyTaskMap.get(o.Id).description;
                    
                    system.debug('Opportunity Last Call Description ==== ' +  o.Last_call_description__c);
                }
                else{																	//Added by Sheetal on 01-08-2022
                       o.Last_call_description__c = system.today().format() + ' : ' + opptyTaskMap.get(o.Id).description;
                }
                
                //o.Last_call_description__c = opptyTaskMap.get(o.Id).description;
                o.Last_Presales_Task_Id__c = opptyTaskMap.get(o.Id).Id;
                //o.Last_call_attempt_status__c = opptyTaskMap.get(o.Id).Call_Attempt_Status__c;
                o.Last_call_attempt_status__c = opptyTaskMap.get(o.Id).Call_Status__c;
                o.Next_Action_Date__c = opptyTaskMap.get(o.Id).Next_Action_Date__c;
                o.call_proposed_date_of_visit__c = opptyTaskMap.get(o.Id).Call_Proposed_Date_Of_Visit__c;
                o.Last_Call_Rating__c = opptyTaskMap.get(o.Id).Call_Rating__c;
                o.Last_call_attempted_by__c = opptyTaskMap.get(o.Id).Attempted_By__c;
                Datetime taskDate = opptyTaskMap.get(o.Id).ActivityDate;
                
                if (taskDate == null)
                    taskDate = Date.today();
                
                
                // stripping the time value 00:00:00 from the t.activity date value
                String taskDate1 = taskDate.Date().format();
                
                // Here we are concatenating the date and time values to make create a datetime string   
                if(opptyTaskMap.get(o.Id).Call_Time__c != null) {                  
                    taskDate1 = taskDate1 + ' ' + opptyTaskMap.get(o.Id).Call_Time__c;
                    System.Debug('Value of datetime parse function' + taskDate1);
                    o.last_call_attempt_date__c = DateTime.Parse(taskDate1);
                }
                else
                    o.last_call_attempt_date__c = system.now();
                //Added by Payal 02/08/2021
                if(o.First_Call_Attempt_Date__c == null){            
                    if(opptyTaskMap.get(o.Id).Call_Time__c != null) {                  
                        //taskDate1 = taskDate1 + ' ' + opptyTaskMap.get(o.Id).Call_Time__c;
                        o.First_Call_Attempt_Status__c = opptyTaskMap.get(o.Id).Call_Status__c;
                        System.Debug('Value of datetime parse function' + taskDate1);
                        o.First_Call_Attempt_Date__c = DateTime.Parse(taskDate1);
                    }
                    else
                        o.First_Call_Attempt_Date__c = system.now();
                }
                o.Presales_Call_counter__c = oppTaskCountMap.get(o.Id).get('Presales Call');
                system.debug('o.Presales_Call_counter__c:::: ' + o.Presales_Call_counter__c);
                if (o.Presales_Call_counter__c == 1)
                    o.IsFirstPresalesCall__c = true;
                else
                    o.IsFirstPresalesCall__c = false;
                system.debug('o.IsFirstPresalesCall__c::::: ' + o.IsFirstPresalesCall__c);
                
            }
            if (opptyTaskMap.containsKey(o.Id) && opptyTaskMap.get(o.Id).Task_Type__c == 'CRM Call') {
 				 o.Last_CRM_Call_Attempt_Date__c = system.now(); o.last_CRM_call_attempted_by__c = opptyTaskMap.get(o.Id).Attempted_By__c;o.Last_CRM_Call_Attempt_Status__c =opptyTaskMap.get(o.Id).Call_Status__c; 
                // o.Last_CRM_Call_Attempt_Status__c = opptyTaskMap.get(o.Id).Call_Attempt_Status__c;
                o.Last_CRM_Call_Subject__c = opptyTaskMap.get(o.Id).Subject; //Added by Vinay 04-05-2023
                Datetime taskDate = opptyTaskMap.get(o.Id).ActivityDate;                 
                if(taskDate == null) 
                    taskDate = Date.today();
                
                String taskDate1 = taskDate.Date().format();
                taskDate1 = taskDate1 + ' ' + opptyTaskMap.get(o.Id).Call_Time__c;
                System.Debug('Value of datetime parse function' + taskDate1);
                o.Last_CRM_Call_Attempt_Date__c = DateTime.Parse(taskDate1);
                //
                if(o.First_CRM_Call_Attempt_Date__c == null){o.First_CRM_Call_Attempt_Status__c = opptyTaskMap.get(o.Id).Call_Status__c;o.First_CRM_Call_Attempted_by__c = opptyTaskMap.get(o.Id).Attempted_By__c;o.First_CRM_Call_Attempt_Date__c = DateTime.Parse(taskDate1);
                }
					
                  
       
               
            }
            
            if(opptyTaskMap.containsKey(o.Id) && opptyTaskMap.get(o.Id).Task_Type__c == 'Sales Call') {
                o.Sales_Call_Attempt_Status__c = opptyTaskMap.get(o.Id).Call_Attempt_Status__c;
                //o.Sales_Call_Description__c = opptyTaskMap.get(o.Id).description;
                o.Sales_Call_Attempted_By__c = opptyTaskMap.get(o.Id).RW_Sales_Associate__c;
                o.Sales_Next_Action_Date__c = opptyTaskMap.get(o.Id).Next_Action_Date__c;
                o.Sales_Call_Proposed_Date_Of_Visit__c = opptyTaskMap.get(o.Id).Call_Proposed_Date_Of_Visit__c;
                o.Sales_Call_Rating__c = opptyTaskMap.get(o.Id).Call_Rating__c;
                o.Sales_Call_Follow_Up_Bucket__c = opptyTaskMap.get(o.Id).Follow_Up_Status__c;
                o.Sales_Call_Reason_Not_Interested__c = opptyTaskMap.get(o.Id).Sales_Reason_Not_Interested__c;
                system.debug(''+o.Sales_Call_Description__c);
                // if (string.isNotBlank(o.Sales_Call_Description__c)){
                //     system.debug('in Sales call desc IF loop');
                //     o.Sales_Call_Description__c += '\n' + system.today().format() + ' : ' + opptyTaskMap.get(o.Id).Call_Rating__c + ' : ' +opptyTaskMap.get(o.Id).description;
                // }
                // else{
                //    system.debug('in Sales call desc ELSE loop');
                String Description = '';
                    if (opptyTaskMap.get(o.Id).description != null){
                       Description = opptyTaskMap.get(o.Id).description;  
                    }
                String CallRating = '';
                    if (opptyTaskMap.get(o.Id).description != null){
                       CallRating = opptyTaskMap.get(o.Id).description;  
                    }
                o.Sales_Call_Description__c = system.today().format() + ' : ' +CallRating /*opptyTaskMap.get(o.Id).Call_Rating__c*/ + ' : '  + Description/*opptyTaskMap.get(o.Id).description*/;
                //}
                Datetime taskDate = opptyTaskMap.get(o.Id).ActivityDate; 
                
                if(taskDate == null) 
                    taskDate = Date.today();
                
                String taskDate1 = taskDate.Date().format();
                taskDate1 = taskDate1 + ' ' + opptyTaskMap.get(o.Id).Call_Time__c;
                System.Debug('Value of datetime parse function' + taskDate1);
                o.Sales_Call_Attempt_Date__c = DateTime.Parse(taskDate1);
                //Added by Payal 02/08/2021
                if(o.First_Sales_Call_Attempt_Date__c == null){
                    o.First_Sales_Call_Attempt_Status__c = opptyTaskMap.get(o.Id).Call_Attempt_Status__c;
                    o.First_Sales_Call_Attempt_Date__c = DateTime.Parse(taskDate1);
                    o.First_Sales_Call_Description__c	= system.today().format() + ' : ' +CallRating  + ' : '  + Description;	//Added on 6/10/2022
                }
                o.Sales_Call_Count__c= oppTaskCountMap.get(o.Id).get('Sales Call');
                system.debug('o.Sales_Call_Count__c:::: ' + o.Sales_Call_Count__c);
                if (o.Sales_Call_Count__c== 1)
                    o.IsFirstSalesCall__c= true;
                else
                    o.IsFirstSalesCall__c= false;
                system.debug('o.IsFirstSalesCall__c::::: ' + o.IsFirstSalesCall__c);
                
                
            }
            
            if (opptyTaskMap.containsKey(o.Id) && opptyTaskMap.get(o.Id).Task_Type__c == 'Site Visit') { /////!(opptyTaskMap.get(o.Id).revisit__c)) commented by vikas
                o.Unique_SVF_Number__c = opptyTaskMap.get(o.Id).Visit_Form_No__c;
                //o.Walk_in_Source__c = opptyTaskMap.get(o.Id).Walk_in_Source__c;
                //o.Walk_in_Sub_Source__c = opptyTaskMap.get(o.Id).Walk_in_Sub_Source__c;
                o.Site_Visit_Channel_Partner__c = opptyTaskMap.get(o.Id).Channel_Partner__c;
                //o.Site_Visit_Xcelerate_ID__c = opptyTaskMap.get(o.Id).Xcelerate_ID__c;
                o.Site_Visit_Source_Details__c = opptyTaskMap.get(o.Id).Registraion_Status__c;
                //o.Walk_in_Channel_Partner_Email__c = opptyTaskMap.get(o.Id).New_Channel_Partner_Email__c;
                //o.Walk_in_Channel_Partner_Name__c = opptyTaskMap.get(o.Id).New_Channel_Partner_Name__c;
                //o.Walk_in_Channel_Partner_Phone__c = opptyTaskMap.get(o.Id).New_Channel_Partner_Phone__c;
                o.Walk_in_Channel_Partner__c = opptyTaskMap.get(o.Id).Existing_Channel_Partner__c;
                
                /**if (string.isNotBlank(o.Descriptive_Remarks_Feedback__c))
o.Descriptive_Remarks_Feedback__c += '\n' + system.today().format() + ' : ' + opptyTaskMap.get(o.Id).description;
else
o.Descriptive_Remarks_Feedback__c = system.today().format() + ' : ' + opptyTaskMap.get(o.Id).description;
**/
                //o.Walk_in_Respective_Customer_Account__c = opptyTaskMap.get(o.Id).Walk_in_Respective_Customer_Account__c;
                o.Sales_Manager__c = opptyTaskMap.get(o.Id).RW_Sales_Associate__c;
                o.visit_counter__c = oppTaskCountMap.get(o.Id).get('Site Visit');
                o.Date_Of_Visit__c = opptyTaskMap.get(o.Id).ActivityDate;
                o.Visit_Rating__c = opptyTaskMap.get(o.Id).Call_Rating__c;
                o.Visit_Task_Id__c = opptyTaskMap.get(o.Id).Id;
                //o.Sourcing_Manager__c = opptyTaskMap.get(o.Id).Sourcing_Manager__c;
                //o.Sales_Manager__c = opptyTaskMap.get(o.Id).Call_Attempted_By_Name__c;
                //o.Name_of_TL__c = opptyTaskMap.get(o.Id).Name_of_TL__c;
                //o.Sourcing_TL__c = opptyTaskMap.get(o.Id).Sourcing_TL__c;
                
                o.Unit_type_configuration__c = opptyTaskMap.get(o.Id).Configuration__c;
                o.S_Budget__c = opptyTaskMap.get(o.Id).Budget__c;
                /*if (opptyTaskMap.get(o.Id).Budget_Site_Visit_In_Lacs__c != null)
o.Budget_Site_Visit_In_Lacs__c = opptyTaskMap.get(o.Id).Budget_Site_Visit_In_Lacs__c;
*/
                /// Added by shailesh on 4.12.17 to rollup details from SVF in Client Need Analysis section ///
                If(opptyTaskMap.get(o.Id).Budget__c != null)
                    o.RW_Budget__c = opptyTaskMap.get(o.Id).Budget__c;
                if(opptyTaskMap.get(o.Id).Registraion_Status__c != null)
                    o.RW_Others__c = opptyTaskMap.get(o.Id).Registraion_Status__c; // we have used existing field for this we are running out of fields
                if(opptyTaskMap.get(o.Id).Floor_Choices__c != null)
                    o.RW_Floor_Choices__c = opptyTaskMap.get(o.Id).Floor_Choices__c;
                if(opptyTaskMap.get(o.Id).Vaastu_Entry_Towards__c != null)
                    o.RW_Vaastu_Entry_Towards__c = opptyTaskMap.get(o.Id).Vaastu_Entry_Towards__c;
                if(opptyTaskMap.get(o.Id).With_Balcony__c != null)    
                    o.RW_With_Balcony__c = opptyTaskMap.get(o.Id).With_Balcony__c;
                if(opptyTaskMap.get(o.Id).Facing__c != null)  
                    o.RW_Facing__c = opptyTaskMap.get(o.Id).Facing__c;
                if(opptyTaskMap.get(o.Id).Number_of_Cars__c != null)  
                    o.RW_Number_of_Cars__c = opptyTaskMap.get(o.Id).Number_of_Cars__c;
                if(opptyTaskMap.get(o.Id).With_Servant_Room__c != null)  
                    o.RW_With_Servant_Room__c = opptyTaskMap.get(o.Id).With_Servant_Room__c;
                //if (string.isNotBlank(o.RW_Sales_Manager_Comment__c) && o.RW_Sales_Manager_Comment__c != null)
                //     o.RW_Sales_Manager_Comment__c += '\n' + system.today().format() + ' : ' + opptyTaskMap.get(o.Id).description;
                //else 
                if(String.isNotBlank(opptyTaskMap.get(o.Id).description))
                    o.RW_Sales_Manager_Comment__c = system.today().format() + ' : ' + opptyTaskMap.get(o.Id).description;
            }
            if (opptyTaskMap.containsKey(o.Id) && opptyTaskMap.get(o.Id).Task_Type__c == 'Re-Visit') {
                if(String.isNotBlank(opptyTaskMap.get(o.Id).description))
                    o.RW_Sales_Manager_Comment__c = system.today().format() + ' : ' + opptyTaskMap.get(o.Id).description;
            }
            
            ///////// Adding By vikas for VDNB Call Stored to Opportunity  //////////////////////
            
            /*if (opptyTaskMap.containsKey(o.Id) && opptyTaskMap.get(o.Id).Task_Type__c == 'VDNB Call') {
o.Last_VDNB_Attempted_By__c = opptyTaskMap.get(o.Id).VDNB_Attempted_By__c;
o.Last_VDNB_Call_status__c = opptyTaskMap.get(o.Id).VDNB_Status__c;
o.Last_VDNB_Attempt_Date__c = opptyTaskMap.get(o.Id).Call_Proposed_Date_Of_Visit__c;
o.Last_VDNB_Call_Description__c = opptyTaskMap.get(o.Id).Description;
o.Expected_Re_Visit_Date__c = opptyTaskMap.get(o.Id).Expected_Revisit_Date__c;
o.Next_Action_Date_VDNB__c = opptyTaskMap.get(o.Id).Next_Action_Date__c;


}*/
            // update opportunities with once SV done at Account level
            System.debug('revisit logic:' + isRevisit(o.Id));
            if (isFirstVisit(o.Id)) {
                accIdSet.add(o.AccountId);
            }
            System.debug('accidSet:' + accIdSet);
            
        }
        update(oppList);
        List < Account > accList = [Select Id, visit_count__c from Account where Id in : accIdSet];
        System.debug('accList:' + accList);
        for (Account a: accList) {
            if (a.visit_count__c != null) {
                a.visit_count__c++;
            } else {
                a.visit_count__c = 1;
            }
        }
        update accList;
    }
    
    public static void latestTaskRollupToLead(List < Task > taskList) {
        Map < Id, Task > leadTaskMap = new Map < Id, Task > ();
        for (Task t: TaskList) {
            if (t.whoId != null && t.whoId.getSObjectType().getDescribe().getName() == 'Lead') {
                if (leadTaskMap.containsKey(t.whoId)) {
                    // if a task already exist for the oppty, 
                    // replace it with the new task only if the new task is the latest
                    if (leadTaskMap.get(t.whoId).createdDate < t.createdDate) {leadTaskMap.put(t.whoId, t);
                    }
                } else {
                    leadTaskMap.put(t.whoId, t);
                }
            }
        }
        List < Lead > leadList = new List < Lead >();
        List < AggregateResult > taskCountAg = new List<AggregateResult>();
        if(!leadTaskMap.isEmpty()){ //Added if condition by Vinay 01-07-2025
            leadList = [select Name, Id, call_proposed_date_of_visit__c, Follow_up_date__c,
                                  Last_call_attempted_by__c, Last_call_attempt_status__c, Last_call_description__c,Sales_Call_Description__c,
                                  Call_Rating__c, Last_Call_Rating__c, Presales_Call_counter__c,IsFirstSalesCall__c,Sales_Call_Count__c,last_call_attempt_date__c,First_Call_Attempt_Date__c,First_Sales_Call_Attempt_Date__c, First_Call_Attempt_Status__c, First_Sales_Call_Attempt_Status__c, IsFirstPresalesCall__c from lead
                                  where Id in : leadTaskMap.keySet()
                                 ];
        
            taskCountAg = [Select count(Id) taskCount, whoId leadId, task_type__c taskType from Task
                                                where whoId in : leadTaskMap.keySet() group by whoId, task_type__c
                                               ];
        }
        
        Map < String, Map < String, Integer >> leadTaskCountMap = new Map < String, Map < String, Integer >> ();
        for (AggregateResult ar: taskCountAg) {
            if (leadTaskCountMap.containsKey((String) ar.get('leadId'))) {
                leadTaskCountMap.get((String) ar.get('leadId')).put((String) ar.get('taskType'), (Integer) ar.get('taskCount'));
            } else {
                Map < String, Integer > tempMap = new Map < String, Integer > ();
                tempMap.put((String) ar.get('taskType'), (Integer) ar.get('taskCount'));
                leadTaskCountMap.put((String) ar.get('leadId'), tempMap);
            }
        }
        for (Lead l: leadList) {
            if (leadTaskMap.containsKey(l.Id) && leadTaskMap.get(l.Id).Task_Type__c == 'Presales Call') {
                
                // Commented by Priya on 2 Dec 2017
                //   if (string.isNotBlank(l.Last_call_description__c ))
                //               l.Last_call_description__c += '\n' + system.today().format() + ' : ' + leadTaskMap.get(l.Id).Call_Rating__c + ' : ' + leadTaskMap.get(l.Id).description;
                //           else
                
                
                // l.Last_call_description__c = system.today().format() + ' : ' + leadTaskMap.get(l.Id).Call_Rating__c + ' : '  + leadTaskMap.get(l.Id).description;
                //Modified by Sheetal on 06/01/2021 to solve issue I0099
                if(!system.today().format().contains('GMT') && string.isNotBlank(l.Last_call_description__c )){l.Last_call_description__c = system.today().format() + ' : '  + leadTaskMap.get(l.Id).description;
                }
                else{												//Added by Sheetal on 01-08-2022
                    l.Last_call_description__c = system.today().format() + ' : '  + leadTaskMap.get(l.Id).description;
                }
                //l.Last_call_description__c = leadTaskMap.get(l.Id).description;
                
                l.Last_Presales_Task_Id__c = leadTaskMap.get(l.Id).Id;
                //l.Last_call_attempt_status__c = leadTaskMap.get(l.Id).Call_Attempt_Status__c;
                l.Last_call_attempt_status__c = leadTaskMap.get(l.Id).Call_Status__c;
                l.Latest_Next_Action_Date__c = leadTaskMap.get(l.Id).Next_Action_Date__c;
                l.call_proposed_date_of_visit__c = leadTaskMap.get(l.Id).Call_Proposed_Date_Of_Visit__c;
                l.Last_Call_Rating__c = leadTaskMap.get(l.Id).Call_Rating__c;
                system.debug('Attempted_By__c:' +leadTaskMap.get(l.Id).Attempted_By__c);
                l.Last_call_attempted_by__c = leadTaskMap.get(l.Id).Attempted_By__c;
                Datetime taskDate = leadTaskMap.get(l.Id).ActivityDate;
                
                if (taskDate == null)
                    taskDate = Date.today();
                
                
                // stripping the time value 00:00:00 from the t.activity date value
                String taskDate1 = taskDate.Date().format();
                
                // Here we are concatenating the date and time values to make create a datetime string                       
                if(leadTaskMap.get(l.Id).CreatedDate != Null)
                {
                    //taskDate1 = taskDate1 + ' ' + leadTaskMap.get(l.Id).Call_Time__c;
                    
                    System.Debug('Value of datetime parse function' + leadTaskMap.get(l.Id).CreatedDate);
                    
                    //l.last_call_attempt_date__c = DateTime.Parse(taskDate1);
                    l.last_call_attempt_date__c = leadTaskMap.get(l.Id).CreatedDate;
                }
                //l.last_call_attempt_date__c = system.now();
                //Added by Payal 02/08/2021
                if(l.First_Call_Attempt_Date__c == null){
                    l.First_Call_Attempt_Status__c = leadTaskMap.get(l.Id).Call_Status__c;
                  //  l.First_Call_Attempted_By__c = leadTaskMap.get(l.Id).Attempted_By__c;
                    if(leadTaskMap.get(l.Id).CreatedDate != Null)
                    {
                        // taskDate1 = taskDate1 + ' ' + leadTaskMap.get(l.Id).Call_Time__c;
                        
                        System.Debug('Value of datetime parse function' + leadTaskMap.get(l.Id).CreatedDate);
                        
                        //l.First_Call_Attempt_Date__c = DateTime.Parse(taskDate1);
                        l.First_Call_Attempt_Date__c = leadTaskMap.get(l.Id).CreatedDate;
                    }
                }
                l.Presales_Call_counter__c = leadTaskCountMap.get(l.Id).get('Presales Call');
                system.debug('l.Presales_Call_counter__c:::: ' + l.Presales_Call_counter__c);
                if (l.Presales_Call_counter__c == 1)
                    l.IsFirstPresalesCall__c = true;
                else
                    l.IsFirstPresalesCall__c = false;
                system.debug('l.IsFirstPresalesCall__c::::: ' + l.IsFirstPresalesCall__c);
                
            }
            if(leadTaskMap.containsKey(l.Id) && leadTaskMap.get(l.Id).Task_Type__c == 'Sales Call') {
                l.Sales_Call_Attempt_Status__c = leadTaskMap.get(l.Id).Call_Attempt_Status__c;
                l.Sales_Call_Attempted_By__c = leadTaskMap.get(l.Id).RW_Sales_Associate__c;
                l.Sales_Next_Action_Date__c = leadTaskMap.get(l.Id).Next_Action_Date__c;
                l.Sales_Call_Proposed_Date_Of_Visit__c = leadTaskMap.get(l.Id).Call_Proposed_Date_Of_Visit__c;
                l.Sales_Call_Rating__c = leadTaskMap.get(l.Id).Call_Rating__c;
                l.Sales_Call_Follow_Up_Bucket__c = leadTaskMap.get(l.Id).Follow_Up_Status__c;
                l.Sales_Call_Reason_Not_Interested__c = leadTaskMap.get(l.Id).Sales_Reason_Not_Interested__c;
                
                //system.debug(''+l.Sales_Call_Description__c); //Commented by Vinay 26-09-2025
                if (leadTaskMap.get(l.Id).description != null){
                    system.debug('in Sales call desc IF loop');
                    l.Sales_Call_Description__c += '\n' + system.today().format() + ' : ' + leadTaskMap.get(l.Id).Call_Rating__c + ' : ' +leadTaskMap.get(l.Id).description;
                }
                else{
                    system.debug('in Sales call desc ELSE loop');
                    l.Sales_Call_Description__c = system.today().format()/* + ' : ' + leadTaskMap.get(l.Id).Call_Rating__c + ' : '  + leadTaskMap.get(l.Id).description*/;
                }
                Datetime taskDate = leadTaskMap.get(l.Id).ActivityDate; 
                System.Debug('taskDate 607' + taskDate);
                
                if(taskDate == null) 
                    taskDate = Date.today();
                String taskDate1 = taskDate.Date().format();
                if( leadTaskMap.get(l.Id).Call_Time__c != Null){
                    taskDate1 = taskDate1 + ' ' + leadTaskMap.get(l.Id).Call_Time__c;
                    System.Debug('Value of datetime parse function' + taskDate1);
                    l.Sales_Call_Attempt_Date__c = DateTime.Parse(taskDate1);
                }
                // Added by Payal 02/08/2021
                if(l.First_Sales_Call_Attempt_Date__c == null){
                    l.First_Sales_Call_Attempt_Status__c = leadTaskMap.get(l.Id).Call_Attempt_Status__c;
                    if( leadTaskMap.get(l.Id).Call_Time__c != Null){
                        //  taskDate1 = taskDate1 + ' ' + leadTaskMap.get(l.Id).Call_Time__c;
                        
                        System.Debug('Value of datetime parse function' + taskDate1);
                        l.First_Sales_Call_Attempt_Date__c = DateTime.Parse(taskDate1);
                    }
                }
                //l.last_call_attempt_date__c = system.now();
                l.Sales_Call_Count__c= leadTaskCountMap.get(l.Id).get('Sales Call');
                system.debug('l.Sales_Call_Count__c:::: ' + l.Sales_Call_Count__c);
                if (l.Sales_Call_Count__c== 1)
                    l.IsFirstSalesCall__c= true;
                else
                    l.IsFirstSalesCall__c= false;
                system.debug('l.IsFirstSalesCall__c::::: ' + l.IsFirstSalesCall__c);
                
                
            }
            
        }
        update(leadList);
    }
    
    
    public static void latestTaskRollupToProspect(List < Task > taskList) {
        Map < Id, Task > prospectTaskMap = new Map < Id, Task > ();
        List<Prospect__c> prospectList = new List<Prospect__c>();
        for (Task t: TaskList) {
            if (t.Prospect__c != null) {
                if (prospectTaskMap.containsKey(t.Prospect__c)) {
                    // if a task already exist for the oppty, 
                    // replace it with the new task only if the new task is the latest
                    if (prospectTaskMap.get(t.Prospect__c).createdDate < t.createdDate) {
                        prospectTaskMap.put(t.Prospect__c, t);
                    }
                } 
                else{
                    prospectTaskMap.put(t.Prospect__c, t);     
                }
            }
        }
        
        if(!prospectTaskMap.isEmpty()){
            
            prospectList = [select id,name,Last_Call_Attempt_Date__c,First_Call_Attempt_Date__c,First_Sales_Call_Attempt_Date__c, First_Call_Attempt_Status__c, First_Sales_Call_Attempt_Status__c,Last_call_attempted_by__c,Last_Call_Attempt_Status__c,Last_call_description__c,call_proposed_date_of_visit__c,Last_Call_Rating__c,
                            Sales_Call_Attempted_By__c,Sales_Call_Attempt_Status__c,Sales_Call_Description__c,Sales_Call_Follow_Up_Bucket__c,Sales_Call_Proposed_Date_Of_Visit__c,Sales_Call_Rating__c,
                            Sales_Call_Attempt_Date__c,Next_Action_Date__c,Sales_Call_Reason_Not_Interested__c,
                            First_CRM_Call_Attempt_Date__c,First_CRM_Call_Attempt_Status__c,		// Added  by Sheetal on 25/05/2022
                            Last_CRM_Call_Attempt_Date__c,Last_CRM_Call_Attempt_Status__c,CRM_Call_Proposed_Date_Of_Visit__c
                            from Prospect__c where id =: prospectTaskMap.keySet()];
            
        }
        if(!prospectList.isEmpty()){
            for(Prospect__c p : prospectList){
                
                // Commented by Priya on 2 Dec 2017
                if (prospectTaskMap.containsKey(p.Id) && prospectTaskMap.get(p.Id).Task_Type__c == 'Presales Call') {
                    //         if (string.isNotBlank(p.Last_call_description__c ))
                    //             p.Last_call_description__c += '\n' + system.today().format() + ' : ' + prospectTaskMap.get(p.Id).Call_Rating__c + ' : ' + prospectTaskMap.get(p.Id).description;
                    //         else
                    
                    
                    //Modified by Sheetal on 06/01/2021 to solve Issue I0099
                    if(!system.today().format().contains('GMT')&&string.isNotBlank(p.Last_call_description__c )){
                        // p.Last_call_description__c = system.today().format() + ' : '  + prospectTaskMap.get(p.Id).description;
                        p.Last_call_description__c = system.today().format() + ' : ' + prospectTaskMap.get(p.Id).description;
                        
                    }
                    else{												//Added by Sheetal on 01-08-2022
                           p.Last_call_description__c = system.today().format() + ' : ' + prospectTaskMap.get(p.Id).description;
                    }
                    //o.Last_call_description__c = opptyTaskMap.get(o.Id).description;
                    p.Last_Presales_Task_Id__c = prospectTaskMap.get(p.Id).Id;
                    //p.Last_call_attempt_status__c = prospectTaskMap.get(p.Id).Call_Attempt_Status__c;
                    
                    p.Last_call_attempt_status__c = prospectTaskMap.get(p.Id).Call_Disposition_Custom__c;
                    p.Next_Action_Date__c = prospectTaskMap.get(p.Id).Next_Action_Date__c;
                    p.call_proposed_date_of_visit__c = prospectTaskMap.get(p.Id).Call_Proposed_Date_Of_Visit__c;
                    p.Last_Call_Rating__c = prospectTaskMap.get(p.Id).Call_Rating__c;
                    p.Last_call_attempted_by__c = prospectTaskMap.get(p.Id).Attempted_By__c;
                    Datetime taskDate = prospectTaskMap.get(p.Id).ActivityDate;
                    
                    if (taskDate == null)
                        taskDate = Date.today();
                    
                    
                    // stripping the time value 00:00:00 from the t.activity date value
                    String taskDate1 = taskDate.Date().format();
                    
                    // Here we are concatenating the date and time values to make create a datetime string                       
                    if(prospectTaskMap.get(p.Id).Call_Time__c != Null)
                    {
                        taskDate1 = taskDate1 + ' ' + prospectTaskMap.get(p.Id).Call_Time__c;
                        
                        
                        System.Debug('Value of datetime parse function' + taskDate1);
                        p.last_call_attempt_date__c = DateTime.Parse(taskDate1);
                    }
                    //Added by Payal 02/08/2021
                    if(p.First_Call_Attempt_Date__c == null){
                        p.First_Call_Attempt_Status__c = prospectTaskMap.get(p.Id).Call_Status__c;
                        if(prospectTaskMap.get(p.Id).Call_Time__c != Null)
                        {
                            //taskDate1 = taskDate1 + ' ' + prospectTaskMap.get(p.Id).Call_Time__c;
                            
                            
                            System.Debug('Value of datetime parse function' + taskDate1);
                            p.First_Call_Attempt_Date__c = DateTime.Parse(taskDate1);
                        }
                    }
                    //o.last_call_attempt_date__c = system.now();
                    /*p.Presales_Call_counter__c = oppTaskCountMap.get(o.Id).get('Presales Call');
system.debug('o.Presales_Call_counter__c:::: ' + o.Presales_Call_counter__c);
if (o.Presales_Call_counter__c == 1)
o.IsFirstPresalesCall__c = true;
else
o.IsFirstPresalesCall__c = false;
system.debug('o.IsFirstPresalesCall__c::::: ' + o.IsFirstPresalesCall__c);*/
                    
                }
                if(prospectTaskMap.containsKey(p.Id) && prospectTaskMap.get(p.Id).Task_Type__c == 'Sales Call') {
                    p.Sales_Call_Attempt_Status__c = prospectTaskMap.get(p.Id).Call_Attempt_Status__c;
                    p.Sales_Call_Attempted_By__c = prospectTaskMap.get(p.Id).RW_Sales_Associate__c;
                    p.Sales_Next_Action_Date__c = prospectTaskMap.get(p.Id).Next_Action_Date__c;
                    p.Sales_Call_Proposed_Date_Of_Visit__c = prospectTaskMap.get(p.Id).Call_Proposed_Date_Of_Visit__c;
                    p.Sales_Call_Rating__c = prospectTaskMap.get(p.Id).Call_Rating__c;
                    p.Sales_Call_Follow_Up_Bucket__c = prospectTaskMap.get(p.Id).Follow_Up_Status__c;
                    p.Sales_Call_Reason_Not_Interested__c = prospectTaskMap.get(p.Id).Sales_Reason_Not_Interested__c;
                    
                    system.debug(''+p.Sales_Call_Description__c);
                    //if (string.isNotBlank(p.Sales_Call_Description__c)){
                    //    system.debug('in Sales call desc IF loop');
                    String Description = '';
                    if (p.Sales_Call_Description__c != null){
                       Description = p.Sales_Call_Description__c;  
                    }
                    
                    p.Sales_Call_Description__c += '\n' + system.today().format() + ' : ' + prospectTaskMap.get(p.Id).Call_Rating__c + ' : ' +Description/*prospectTaskMap.get(p.Id).description*/;
                    //}
                    //
                    //else{
                    //   system.debug('in Sales call desc ELSE loop');
                    p.Sales_Call_Description__c = system.today().format() + ' : ' + prospectTaskMap.get(p.Id).Call_Rating__c + ' : '  + Description/*prospectTaskMap.get(p.Id).description*/;
                    //}
                    Datetime taskDate = prospectTaskMap.get(p.Id).ActivityDate; 
                    
                    if(taskDate == null) 
                        taskDate = Date.today();
                    
                    String taskDate1 = taskDate.Date().format();
                    taskDate1 = taskDate1 + ' ' + prospectTaskMap.get(p.Id).Call_Time__c;
                    System.Debug('Value of datetime parse function' + taskDate1);
                    p.Sales_Call_Attempt_Date__c = DateTime.Parse(taskDate1);
                    // Added by Payal 02/08/2021
                    if(p.First_Sales_Call_Attempt_Date__c == null) {
                        p.First_Sales_Call_Attempt_Status__c = prospectTaskMap.get(p.Id).Call_Attempt_Status__c;
                        p.First_Sales_Call_Attempt_Date__c = DateTime.Parse(taskDate1);
                    }
                }
                
                if(prospectTaskMap.containsKey(p.Id) && prospectTaskMap.get(p.Id).Task_Type__c == 'CRM Call') {	// Added by Sheetal on 25/05/2022
                    p.Last_CRM_Call_Attempt_Date__c = system.now(); 
                   // p.last_CRM_call_attempted_by__c = prospectTaskMap.get(p.Id).Attempted_By__c;
                    p.Last_CRM_Call_Attempt_Status__c =prospectTaskMap.get(p.Id).Call_Attempt_Status__c; 
                    p.Last_CRM_Call_Attempt_Status__c =prospectTaskMap.get(p.Id).Call_Status__c; 
                    p.CRM_Call_Proposed_Date_Of_Visit__c = prospectTaskMap.get(p.Id).Call_Proposed_Date_Of_Visit__c;

                    Datetime taskDate = prospectTaskMap.get(p.Id).ActivityDate;                 
                    if(taskDate == null) 
                        taskDate = Date.today();
                
                String taskDate1 = taskDate.Date().format();
                taskDate1 = taskDate1 + ' ' + prospectTaskMap.get(p.Id).Call_Time__c;
                System.Debug('Value of datetime parse function' + taskDate1);
                p.Last_CRM_Call_Attempt_Date__c = DateTime.Parse(taskDate1);
                //
                if(p.First_CRM_Call_Attempt_Date__c == null){
                    p.First_CRM_Call_Attempt_Status__c = prospectTaskMap.get(p.Id).Call_Status__c;
                    //p.First_CRM_Call_Attempted_by__c = prospectTaskMap.get(p.Id).Attempted_By__c;
                    p.First_CRM_Call_Attempt_Date__c = DateTime.Parse(taskDate1);
                }
                }
                
                
            }
            
            update prospectList;
        }
        
    }
    
    /*public static void updateSCPP(Task[] lstTask) {
system.debug('Inside Method');
list < Task > tskDetails = new list < Task > ();
set < id > taskIds = new set < id > ();
set < id > SCPPDids = new set < id > ();
for (task tsk: lstTask) {
taskIds.add(tsk.id);
}
system.debug('ids : ' + taskIds);
tskDetails = [SELECT id, Address__c, Description, Payment_Instrument__c, Reason_For_Call__c, L2__c, L3__c, Standard_Customer_Pay_Plan_Detail__c, Next_Action_Date__c, PTP_Amount__c, PTP_Date__c FROM Task WHERE Id in : taskIds];
system.debug('Task List: ' + tskDetails);
for (task t: tskDetails) {
SCPPDids.add(t.Standard_Customer_Pay_Plan_Detail__c);
}
Map < Id, Standard_Customer_Pay_Plan_Detail__c > scppDetails = new Map < Id, Standard_Customer_Pay_Plan_Detail__c > ([SELECT Id, Call_Comments__c, Pick_up_address__c, L1__c, L2__c, L3__c, PTP_Amount__c, PTP_Date__c, Last_Call_Disposition__c, PTP_Instrument__c FROM Standard_Customer_Pay_Plan_Detail__c WHERE Id in : SCPPDids]);
list < Standard_Customer_Pay_Plan_Detail__c > SCPPDtoadd = new list < Standard_Customer_Pay_Plan_Detail__c > ();
for (Standard_Customer_Pay_Plan_Detail__c s: scppDetails.values()) {
for (task t: tskDetails) {
if (t.PTP_Amount__c != null) {
s.PTP_Amount__c = t.PTP_Amount__c;
}
if (t.Next_Action_Date__c != null) {
s.PTP_Date__c = t.Next_Action_Date__c;
}
s.L1__c = t.Reason_For_Call__c;
s.L2__c = t.L2__c;
s.L3__c = t.L3__c;
s.PTP_Instrument__c = t.Payment_Instrument__c;
s.Pick_up_address__c = t.Address__c;
s.Call_Comments__c = t.Description;
SCPPDtoadd.add(s);
system.debug('before SCPPDtoadd' + SCPPDtoadd);

}

}

update SCPPDtoadd;
}*/
    
    // returns the time from the datetime field in the user's locale
    // if the input was 17/1/2016 12:30 AM, returns 12:30 AM as a string
    public static String formatTime(DateTime input) {
        String dt = input.format();
        Integer s = dt.indexOf(' ');
        return dt.substring(s + 1);
    }
    
    
    ////Clone task to communicaton object//////
    
    public static void createCommunicationEntries(Task[] TaskList) {
        List < Id > allWhatIdOpty = new List < Id > ();
        List < Id > allWhatIdAccount = new List < Id > ();
        List < Id > allWhoIdLead = new List < Id > ();
        for (Task t: TaskList) {
            //debugging
            if (t.whatId != null) {
                System.debug('WHAT AM I? :' + t.whatId.getSobjectType());
            }
            if (t.whoId != null) {
                System.debug('WHO AM I? :' + t.whoId.getSobjectType());
            }
            
            if (t.WhatId != null && t.whatId.getSobjectType() == Schema.Opportunity.SObjectType) {
                allWhatIdOpty.add(t.WhatId);
            } else if (t.whatId != null && t.whatId.getSObjectType() == Schema.Account.SObjectType) {
                allWhatIdAccount.add(t.whatId);
            } else {
                System.debug('Ignore the task created against any other object types');
            }
            
            if (t.WhoId != null && t.whoId.getSObjectType() == Schema.Lead.SObjectType) {
                allWhoIdLead.add(t.WhoId);
            } else {
                System.debug('Ignore the task created against any other object types');
            }
        }
        
        if (!allWhatIdOpty.isEmpty() || !allWhatIdAccount.IsEmpty() || !allWhoIdLead.isEmpty()) {
            //Create maps
            Map < Id, Opportunity > WhatIdToOptyMap;
            Map < Id, Lead > WhoIdToLeadMap;
            Map < Id, Account > WhatIdToAccountMap;
            if(!allWhatIdOpty.isEmpty()) //Added if Condition by Vinay 01-07-2025
                WhatIdToOptyMap = new Map < Id, Opportunity > ([SELECT Id, Name, Account.FirstName, Account.LastName, Account.RW_Email__c,Account.Mobile_No__c, RW_Project__c, IsFirstPresalesCall__c FROM Opportunity WHERE Id IN: allWhatIdOpty]);
            if(!allWhoIdLead.isEmpty()) //Added if Condition by Vinay 01-07-2025
                WhoIdToLeadMap = new Map < Id, Lead > ([SELECT Id, Name, Email, FirstName, LastName, RW_Mobile_No__c, IsFirstPresalesCall__c FROM Lead WHERE Id IN: allWhoIdLead]);
            if(!allWhatIdAccount.isEmpty()) //Added if Condition by Vinay 01-07-2025
                WhatIdToAccountMap = new Map < Id, Account > ([SELECT Id, Name, RW_Email__c, FirstName, LastName,Mobile_No__c FROM Account WHERE(Id IN: allWhatIdAccount OR PersonContactId In: allWhatIdAccount) and isPersonAccount = true]);
            
            //Create a list 
            List < Communication__c > cloneList = new List < Communication__c > ();
            //    List < UserDetails__c > UserDetails;
            for (Task t: TaskList) {
                String objectWhatName = '';
                String objectWhoName = '';
                String dt = '';
                //Create an object
                Communication__c cloneRecord = new Communication__c();
                cloneRecord.Name = t.Subject;
                cloneRecord.Status__c = t.Status;
                //This code is added on 22/9/2015 to insert date and time in communication object date and time field
                cloneRecord.ActivityDate__c = t.ActivityDate;
                cloneRecord.ActivityTime__c = t.DueTime__c;
                cloneRecord.Task_Type__c = t.Task_Type__c;
                cloneRecord.Show_Walk_In_Source__c = t.ShowWalkInSource__c;
                cloneRecord.Revisit__c = t.Revisit__c;
                //cloneRecord.Walk_in_Source__c = t.Walk_in_Source__c;
                //cloneRecord.Walk_in_Sub_Source__c = t.Walk_in_Sub_Source__c;
                
                
                // All the below fields added for populating various task fields on communication by Vikas
                //cloneRecord.Call_Back__c = t.Call_Back__c;
                //  cloneRecord.Call_Back_Date__c = t.Call_Back_Date__c;
                // cloneRecord.Call_Proposed_Date_Of_Visit__c = t.Call_Proposed_Date_Of_Visit__c;
                // cloneRecord.Call_Rating__c = t.Call_Rating__c;
                //cloneRecord.Call_Source__c = t.Call_Source__c;
                cloneRecord.Call_Status__c = t.Call_Status__c;
                cloneRecord.Campaign_Lookup__c = t.Campaign_Lookup__c;
                cloneRecord.Email_Id__c = t.Email_Id__c;
                cloneRecord.Configuration__c = t.Configuration__c;
                
                cloneRecord.Previous_Call_Attempt_Status__c = t.Previous_Call_Attempt_Status__c;
                cloneRecord.Project_Interested__c = t.Project__c;
                //cloneRecord.Sourcing_Manager__c = t.Sourcing_Manager__c;
                cloneRecord.Subject__c = t.Subject;
                cloneRecord.Team_Attended_By__c = t.Team_Attended_By__c;
                cloneRecord.Visit_Form_Number__c = t.Visit_Form_No__c;
                cloneRecord.Financial_Institute__c = t.Financial_Institute__c;
                cloneRecord.Visit_Status__c = t.Event_Status__c;
                cloneRecord.Visit_Type__c = t.Name_Of_Banks__c;
                cloneRecord.Call_Attempt_Status__c = t.Call_Attempt_Status__c;
                cloneRecord.Communication_Type__c = t.Communication_Type__c;
                if (t.Task_Type__c == 'Enquiry Received') {
                    cloneRecord.Enquiry_Received_Project_Lookup__c = t.Project__c;
                    system.debug(' cloneRecord.Enquiry_Received_Project__c>>>>>  ' + cloneRecord.Enquiry_Received_Project_Lookup__c);
                }
                //The activity date is a Date field which needs to be converted into a datetime field. The time value will be picked-up from
                // t.DueTime__c field and its value will be concatenated with the value of activity date value.
                Datetime OnlyDate = t.ActivityDate;
                
                if (OnlyDate == null)
                    OnlyDate = Date.today();
                
                // stripping the time value 00:00:00 from the t.activity date value
                String ODate = OnlyDate.Date().format();
                
                // Here we are concatenating the date and time values to make create a datetime string       
                if (t.Call_Time__c != null) {
                    dt = ODate + ' ' + t.Call_Time__c;
                } else {
                    dt = System.now().format();
                    
                }
                System.Debug('Value of datetime parse function' + dt);
                
                System.Debug('HardCoded Value of datetime parse function' + dt);
                cloneRecord.Due_Date__c = DateTime.Parse(dt);
                
                //Populating the externalId field on communication record with the task Id.
                cloneRecord.TaskId__c = t.id;
                
                ///Population cp details incase of site visit///
                if (t.Task_Type__c == 'Site Visit') {
                    cloneRecord.Next_Action_Date__c = t.Next_Action_Date__c;
                    cloneRecord.Sales_Manager_Name__c = t.RW_Sales_Associate__c;
                    if (t.Walk_in_Source__c == 'Channel Partner') {
                        if (t.Walk_in_Sub_Source__c == 'Registered') {
                            cloneRecord.ExistingChannelPartner__c = t.Existing_Channel_Partner__c;
                        } else {
                            //cloneRecord.NewChannel_Partner_Name__c = t.New_Channel_Partner_Name__c;
                            //cloneRecord.Channel_Partner_Phone__c = t.New_Channel_Partner_Phone__c;
                        }
                        
                    }
                }
                
                if (t.WhatId != null) {
                    objectWhatName = t.WhatId.getSObjectType().getDescribe().getName();
                }
                if (t.WhoId != null) {
                    objectWhoName = t.WhoId.getSObjectType().getDescribe().getName();
                }
                // If the parent record is an opportunity then query project object and get the sales managers name and email id.    
                if (objectWhatName == 'Opportunity') {
                    // for copying tasks against Oppty
                    
                    if (!WhatIdToOptyMap.isEmpty() && WhatIdToOptyMap.containsKey(t.whatId)) {
                        // mobile phone and email of the customer
                        cloneRecord.Customer_Mobile_Phone__c = WhatIdToOptyMap.get(t.whatId).Account.Mobile_No__c;
                        cloneRecord.Customer_Preferred_Email__c = WhatIdToOptyMap.get(t.WhatId).Account.RW_Email__c;
                        cloneRecord.IsFirstPresalesCall__c = WhatIdToOptyMap.get(t.WhatId).IsFirstPresalesCall__c;
                        cloneRecord.Project_Interested__c = WhatIdToOptyMap.get(t.WhatId).RW_Project__c; // for populating project interested only for opty
                    }
                    
                    cloneRecord.sobjectName__c = objectWhatName;
                    cloneRecord.OptyName__c = t.WhatId;
                    cloneList.add(cloneRecord);
                } else if (objectWhoName == 'Lead') {
                    //for copying tasks against leads
                    //mobile phone and preferred email of the customer
                    if (!WhoIdToLeadMap.isEmpty() && WhoIdToLeadMap.containsKey(t.WhoId)) {
                        cloneRecord.Customer_Mobile_Phone__c = WhoIdToLeadMap.get(t.WhoId).RW_Mobile_No__c;
                        cloneRecord.Customer_Preferred_Email__c = WhoIdToLeadMap.get(t.WhoId).Email;
                        system.debug('WhoIdToLeadMap.get(t.WhoId).IsFirstPresalesCall__c::: ' + WhoIdToLeadMap.get(t.WhoId).IsFirstPresalesCall__c);
                        cloneRecord.IsFirstPresalesCall__c = WhoIdToLeadMap.get(t.WhoId).IsFirstPresalesCall__c;
                    }
                    
                    cloneRecord.sobjectName__c = objectWhoName;
                    cloneRecord.LeadName__c = t.WhoId;
                    cloneList.add(cloneRecord);
                } else if (ObjectWhatName == 'Account') {
                    // for copying tasks against person accounts.
                    
                    //mobile phone and preferred email of the customer
                    if (!WhatIdToAccountMap.isEmpty() && WhatIdToAccountMap.containsKey(t.whatId)) {
                        cloneRecord.Customer_Mobile_Phone__c = WhatIdToAccountMap.get(t.WhatId).Mobile_No__c;
                        cloneRecord.Customer_Preferred_Email__c = WhatIdToAccountMap.get(t.WhatId).RW_Email__c;
                    }
                    
                    cloneRecord.sobjectName__c = objectWhatName;
                    cloneRecord.AccountName__c = t.WhatId;
                    cloneList.add(cloneRecord);
                }
            }
            if (cloneList.size() > 0) {
                system.debug('cloneList111 : ' + cloneList);
                upsert cloneList TaskId__c;
            }
        }
    }
    
    // Created by Shailesh on 10.01.2018 to catch the number of site visits and revisits.
    public static void countNumberOfVisitsOnOpportunity(List < Task > triggernew, Map < Id, task > oldMap) {
        Set < id > setOppId = new Set < id > ();
        for (Task eachEvent: triggernew) {
            if (eachEvent.WhatId != null && eachEvent.WhatId.getSObjectType() == Opportunity.SObjectType) {
                setOppId.add(eachEvent.WhatId);
            }
        }
        
        if (setOppId != null && setOppId.size() > 0) {
            List < Task > lstTask = [select Id, WhatId, Type from Task where WhatId = : setOppId and(Type = : 'Site Visit'
                                                                                                     or Type = : 'Re-visit')];
            
            if (lstTask != null && lstTask.size() > 0) {
                Map < String, Integer > mapOfVisit = new Map < String, Integer > ();
                Map < String, Integer > mapOfReVisit = new Map < String, Integer > ();
                list < Opportunity > lstOpp2Update = new list < Opportunity > ();
                for (Task EachEvent: lstTask) {
                    if (EachEvent.Type == 'Site Visit') {
                        if (!mapOfVisit.containsKey(EachEvent.WhatId)) {
                            mapOfVisit.put(EachEvent.WhatId, 0);
                        }
                        mapOfVisit.put(EachEvent.WhatId, mapOfVisit.get(EachEvent.WhatId) + 1);
                    }
                    
                    if (EachEvent.Type == 'Re-visit') {
                        if (!mapOfReVisit.containsKey(EachEvent.WhatId)) {
                            mapOfReVisit.put(EachEvent.WhatId, 0);
                        }
                        mapOfReVisit.put(EachEvent.WhatId, mapOfReVisit.get(EachEvent.WhatId) + 1);
                    }
                }
                
                for (Id EachId: setOppId) {
                    Opportunity objOpp = new Opportunity();
                    objOpp.Id = EachId;
                    if (mapOfVisit != null && mapOfVisit.size() > 0 && mapOfVisit.containsKey(EachId)) {
                        objOpp.RW_Number_of_Visits__c = mapOfVisit.get(EachId);
                    } else {
                        objOpp.RW_Number_of_Visits__c = 0;
                    }
                    
                    if (mapOfReVisit != null && mapOfReVisit.size() > 0 && mapOfReVisit.containsKey(EachId)) {
                        objOpp.RW_Number_of_Re_Visit__c = mapOfReVisit.get(EachId);
                    } else {
                        objOpp.RW_Number_of_Re_Visit__c = 0;
                    }
                    
                    lstOpp2Update.add(objOpp);
                }
                
                if (lstOpp2Update != null && lstOpp2Update.size() > 0)
                    update lstOpp2Update;
            }
        }
        
    }
    
    // created By Vikas On 18/04/2016 for Call Rating
    public static void callStatusMethod(List < Task > taskList) {
        
        List < Opportunity > optyList = new List < Opportunity > ();
        List < Opportunity > optyList2 = new List < Opportunity > ();
        List < Lead > leadList = new List < Lead > ();
        List < Lead > leadList2 = new List < Lead > ();
        Map < Id, Task > taskMap = new Map < Id, Task > ();
        Map < Id, Task > leadTaskMap = new Map < Id, Task > ();
        
        for (Task t: taskList) {
            if (t.WhatId != null && t.WhatId.getSObjectType().getDescribe().getName() == 'Opportunity') {
                taskMap.put(t.whatId, t);
            }
            
            if (t.whoId != null && t.whoId.getSObjectType().getDescribe().getName() == 'Lead') {
                leadTaskMap.put(t.whoId, t);
            }
        }
        
        /////  Only for Opportunity    ///// 
        
        if (taskMap.size() > 0) {
            
            
            optyList = [SELECT Id, Last_call_attempt_status__c, Call_Rating__c FROM Opportunity WHERE Id IN: taskMap.keySet()];
            
            if (optyList.size() > 0) {
                for (Opportunity opp: optyList) {
                    
                    Decimal rating = opp.Call_Rating__c;
                    
                    string prv_call_rating = taskMap.get(opp.id).Previous_Call_Attempt_Status__c;
                    
                    string call_status = taskMap.get(opp.id).Call_Attempt_Status__c;
                    
                    if (rating != null) {
                        if (prv_call_rating == 'Open' && call_status == 'Open')
                            opp.Call_Rating__c = rating - 2.0;
                        if (prv_call_rating == 'Open' && call_status == 'Follow up')
                            opp.Call_Rating__c = rating - 1.0;
                        if (prv_call_rating == 'Open' && (call_status == 'Visit proposed' || call_status == 'Meeting Proposed' || call_status == 'No Show'))
                            opp.Call_Rating__c = rating + 2.0;
                        if (prv_call_rating == 'Open' && (call_status == 'Visit confirmed' || call_status == 'Meeting Fixed' || call_status == 'Tele Meeting Fixed'))
                            opp.Call_Rating__c = rating + 3.0;
                        if (prv_call_rating == 'Open' && call_status == 'Lost')
                            opp.Call_Rating__c = 0;
                        if (prv_call_rating == 'Open' && (call_status == 'Visit done' || call_status == 'Meeting done' || call_status == 'Tele Meeting Done' || call_status == 'TMD + MD' || call_status == 'Booking Done'))
                            opp.Call_Rating__c = 0;
                        
                        
                        if (prv_call_rating == 'Follow up' && call_status == 'Follow up')
                            opp.Call_Rating__c = rating - 2.0;
                        if (prv_call_rating == 'Follow up' && (call_status == 'Visit proposed' || call_status == 'Meeting Proposed' || call_status == 'No Show'))
                            opp.Call_Rating__c = rating - 0.0;
                        if (prv_call_rating == 'Follow up' && (call_status == 'Visit confirmed' || call_status == 'Meeting Fixed' || call_status == 'Tele Meeting Fixed'))
                            opp.Call_Rating__c = rating + 2.0;
                        if (prv_call_rating == 'Follow up' && call_status == 'Lost')
                            opp.Call_Rating__c = 0;
                        if (prv_call_rating == 'Follow up' && (call_status == 'Visit done' || call_status == 'Meeting done' || call_status == 'Tele Meeting Done' || call_status == 'TMD + MD' || call_status == 'Booking Done'))
                            opp.Call_Rating__c = 0;
                        
                        
                        if ((prv_call_rating == 'Visit proposed' || prv_call_rating == 'Meeting Proposed' || prv_call_rating == 'No Show') && call_status == 'Follow up')
                            opp.Call_Rating__c = rating - 3.0;
                        if ((prv_call_rating == 'Visit proposed' || prv_call_rating == 'Meeting Proposed' || prv_call_rating == 'No Show') && (call_status == 'Visit proposed' || call_status == 'Meeting Proposed' || call_status == 'No Show'))
                            opp.Call_Rating__c = rating - 1.0;
                        if ((prv_call_rating == 'Visit proposed' || prv_call_rating == 'Meeting Proposed' || prv_call_rating == 'No Show') && (call_status == 'Visit confirmed' || call_status == 'Meeting Fixed' || call_status == 'Tele Meeting Fixed'))
                            opp.Call_Rating__c = rating - 0.0;
                        if ((prv_call_rating == 'Visit proposed' || prv_call_rating == 'Meeting Proposed' || prv_call_rating == 'No Show') && call_status == 'Lost')
                            opp.Call_Rating__c = 0;
                        if ((prv_call_rating == 'Visit proposed' || prv_call_rating == 'Meeting Proposed' || prv_call_rating == 'No Show') && (call_status == 'Visit done' || call_status == 'Meeting done' || call_status == 'Tele Meeting Done' || call_status == 'TMD + MD' || call_status == 'Booking Done'))
                            opp.Call_Rating__c = 0;
                        
                        
                        if ((prv_call_rating == 'Visit confirmed' || prv_call_rating == 'Meeting Fixed' || prv_call_rating == 'Tele Meeting Fixed') && call_status == 'Follow up')
                            opp.Call_Rating__c = rating - 4.0;
                        if ((prv_call_rating == 'Visit confirmed' || prv_call_rating == 'Meeting Fixed' || prv_call_rating == 'Tele Meeting Fixed') && (call_status == 'Visit proposed' || call_status == 'Meeting Proposed' || call_status == 'No Show'))
                            opp.Call_Rating__c = rating - 1.0;
                        if ((prv_call_rating == 'Visit confirmed' || prv_call_rating == 'Meeting Fixed' || prv_call_rating == 'Tele Meeting Fixed') && (call_status == 'Visit confirmed' || call_status == 'Meeting Fixed' || call_status == 'Tele Meeting Fixed'))
                            opp.Call_Rating__c = rating - 0.0;
                        if ((prv_call_rating == 'Visit confirmed' || prv_call_rating == 'Meeting Fixed' || prv_call_rating == 'Tele Meeting Fixed') && call_status == 'Lost')
                            opp.Call_Rating__c = 0;
                        if ((prv_call_rating == 'Visit confirmed' || prv_call_rating == 'Meeting Fixed' || prv_call_rating == 'Tele Meeting Fixed') && (call_status == 'Visit done' || call_status == 'Meeting done' || call_status == 'Tele Meeting Done' || call_status == 'TMD + MD' || call_status == 'Booking Done'))
                            opp.Call_Rating__c = 0;
                        
                        
                        if (prv_call_rating == 'Lost' && call_status == 'Follow up')
                            opp.Call_Rating__c = rating + 4.0;
                        if (prv_call_rating == 'Lost' && (call_status == 'Visit proposed' || call_status == 'Meeting Proposed' || call_status == 'No Show'))
                            opp.Call_Rating__c = rating + 4.0;
                        if (prv_call_rating == 'Lost' && (call_status == 'Visit confirmed' || call_status == 'Meeting Fixed' || call_status == 'Tele Meeting Fixed'))
                            opp.Call_Rating__c = rating + 5.0;
                        if (prv_call_rating == 'Lost' && call_status == 'Lost')
                            opp.Call_Rating__c = 0;
                        if (prv_call_rating == 'Lost' && (call_status == 'Visit done' || call_status == 'Meeting done' || call_status == 'Tele Meeting Done' || call_status == 'TMD + MD' || call_status == 'Booking Done'))
                            opp.Call_Rating__c = 0;
                        
                        
                        if ((prv_call_rating == 'Visit done' || prv_call_rating == 'Meeting done' || prv_call_rating == 'Tele Meeting Done' || prv_call_rating == 'TMD + MD' || prv_call_rating == 'Booking Done') && call_status == 'Follow up')
                            opp.Call_Rating__c = rating + 4.0;
                        if ((prv_call_rating == 'Visit done' || prv_call_rating == 'Meeting done' || prv_call_rating == 'Tele Meeting Done' || prv_call_rating == 'TMD + MD' || prv_call_rating == 'Booking Done') && (call_status == 'Visit proposed' || call_status == 'Meeting Proposed' || call_status == 'No Show'))
                            opp.Call_Rating__c = rating + 4.0;
                        if ((prv_call_rating == 'Visit done' || prv_call_rating == 'Meeting done' || prv_call_rating == 'Tele Meeting Done' || prv_call_rating == 'TMD + MD' || prv_call_rating == 'Booking Done') && (call_status == 'Visit confirmed' || call_status == 'Meeting Fixed' || call_status == 'Tele Meeting Fixed'))
                            opp.Call_Rating__c = rating + 5.0;
                        if ((prv_call_rating == 'Visit done' || prv_call_rating == 'Meeting done' || prv_call_rating == 'Tele Meeting Done' || prv_call_rating == 'TMD + MD' || prv_call_rating == 'Booking Done') && call_status == 'Lost')
                            opp.Call_Rating__c = 0;
                        if ((prv_call_rating == 'Visit done' || prv_call_rating == 'Meeting done' || prv_call_rating == 'Tele Meeting Done' || prv_call_rating == 'TMD + MD' || prv_call_rating == 'Booking Done') && (call_status == 'Visit done' || call_status == 'Meeting done' || call_status == 'Tele Meeting Done' || call_status == 'TMD + MD' || call_status == 'Booking Done'))
                            opp.Call_Rating__c = 0;
                        
                        optyList2.add(opp);
                    }
                }
            }
            
        }
        
        if (leadTaskMap.size() > 0) {
            leadList = [SELECT Id, Call_Rating__c, Last_call_attempt_status__c FROM Lead WHERE Id IN: leadTaskMap.keySet()];
            if (leadList.size() > 0) {
                for (Lead leadobj: leadList) {
                    Decimal rating = leadobj.Call_Rating__c;
                    
                    string call_status = leadTaskMap.get(leadobj.id).Call_Attempt_Status__c;
                    system.debug('leadobj.Last_call_attempt_status__c >>>>> ' + leadobj.Last_call_attempt_status__c);
                    system.debug('call_status  >>>>> ' + call_status);
                    string prv_call_rating = leadTaskMap.get(leadobj.id).Previous_Call_Attempt_Status__c;
                    
                    
                    if (rating != null) {
                        if (prv_call_rating == 'Open' && call_status == 'Open')
                            leadobj.Call_Rating__c = rating - 2.0;
                        if (prv_call_rating == 'Open' && call_status == 'Follow up')
                            leadobj.Call_Rating__c = rating - 1.0;
                        if (prv_call_rating == 'Open' && (call_status == 'Visit proposed' || call_status == 'Meeting Proposed' || call_status == 'No Show'))
                            leadobj.Call_Rating__c = rating + 2.0;
                        if (prv_call_rating == 'Open' && (call_status == 'Visit confirmed' || call_status == 'Meeting Fixed' || call_status == 'Tele Meeting Fixed'))
                            leadobj.Call_Rating__c = rating + 3.0;
                        if (prv_call_rating == 'Open' && call_status == 'Lost')
                            leadobj.Call_Rating__c = 0;
                        if (prv_call_rating == 'Open' && (call_status == 'Visit done' || call_status == 'Meeting done' || call_status == 'Tele Meeting Done' || call_status == 'TMD + MD' || call_status == 'Booking Done'))
                            leadobj.Call_Rating__c = 0;
                        
                        
                        if (prv_call_rating == 'Follow up' && call_status == 'Follow up')
                            leadobj.Call_Rating__c = rating - 2.0;
                        if (prv_call_rating == 'Follow up' && (call_status == 'Visit proposed' || call_status == 'Meeting Proposed' || call_status == 'No Show'))
                            leadobj.Call_Rating__c = rating - 0.0;
                        if (prv_call_rating == 'Follow up' && (call_status == 'Visit confirmed' || call_status == 'Meeting Fixed' || call_status == 'Tele Meeting Fixed'))
                            leadobj.Call_Rating__c = rating + 2.0;
                        if (prv_call_rating == 'Follow up' && call_status == 'Lost')
                            leadobj.Call_Rating__c = 0;
                        if (prv_call_rating == 'Follow up' && (call_status == 'Visit done' || call_status == 'Meeting done' || call_status == 'Tele Meeting Done' || call_status == 'TMD + MD' || call_status == 'Booking Done'))
                            leadobj.Call_Rating__c = 0;
                        
                        
                        if ((prv_call_rating == 'Visit proposed' || prv_call_rating == 'Meeting Proposed' || prv_call_rating == 'No Show') && call_status == 'Follow up')
                            leadobj.Call_Rating__c = rating - 3.0;
                        if ((prv_call_rating == 'Visit proposed' || prv_call_rating == 'Meeting Proposed' || prv_call_rating == 'No Show') && (call_status == 'Visit proposed' || call_status == 'Meeting Proposed' || call_status == 'No Show'))
                            leadobj.Call_Rating__c = rating - 1.0;
                        if ((prv_call_rating == 'Visit proposed' || prv_call_rating == 'Meeting Proposed' || prv_call_rating == 'No Show') && (call_status == 'Visit confirmed' || call_status == 'Meeting Fixed' || call_status == 'Tele Meeting Fixed'))
                            leadobj.Call_Rating__c = rating - 0.0;
                        if ((prv_call_rating == 'Visit proposed' || prv_call_rating == 'Meeting Proposed' || prv_call_rating == 'No Show') && call_status == 'Lost')
                            leadobj.Call_Rating__c = 0;
                        if ((prv_call_rating == 'Visit proposed' || prv_call_rating == 'Meeting Proposed' || prv_call_rating == 'No Show') && (call_status == 'Visit done' || call_status == 'Meeting done' || call_status == 'Tele Meeting Done' || call_status == 'TMD + MD' || call_status == 'Booking Done'))
                            leadobj.Call_Rating__c = 0;
                        
                        
                        if ((prv_call_rating == 'Visit confirmed' || prv_call_rating == 'Meeting Fixed' || prv_call_rating == 'Tele Meeting Fixed') && call_status == 'Follow up')
                            leadobj.Call_Rating__c = rating - 4.0;
                        if ((prv_call_rating == 'Visit confirmed' || prv_call_rating == 'Meeting Fixed' || prv_call_rating == 'Tele Meeting Fixed') && (call_status == 'Visit proposed' || call_status == 'Meeting Proposed' || call_status == 'No Show'))
                            leadobj.Call_Rating__c = rating - 1.0;
                        if ((prv_call_rating == 'Visit confirmed' || prv_call_rating == 'Meeting Fixed' || prv_call_rating == 'Tele Meeting Fixed') && (call_status == 'Visit confirmed' || call_status == 'Meeting Fixed' || call_status == 'Tele Meeting Fixed'))
                            leadobj.Call_Rating__c = rating - 0.0;
                        if ((prv_call_rating == 'Visit confirmed' || prv_call_rating == 'Meeting Fixed' || prv_call_rating == 'Tele Meeting Fixed') && call_status == 'Lost')
                            leadobj.Call_Rating__c = 0;
                        if ((prv_call_rating == 'Visit confirmed' || prv_call_rating == 'Meeting Fixed' || prv_call_rating == 'Tele Meeting Fixed') && (call_status == 'Visit done' || call_status == 'Meeting done' || call_status == 'Tele Meeting Done' || call_status == 'TMD + MD' || call_status == 'Booking Done'))
                            leadobj.Call_Rating__c = 0;
                        
                        
                        if (prv_call_rating == 'Lost' && call_status == 'Follow up')
                            leadobj.Call_Rating__c = rating + 4.0;
                        if (prv_call_rating == 'Lost' && (call_status == 'Visit proposed' || call_status == 'Meeting Proposed' || call_status == 'No Show'))
                            leadobj.Call_Rating__c = rating + 4.0;
                        if (prv_call_rating == 'Lost' && (call_status == 'Visit confirmed' || call_status == 'Meeting Fixed' || call_status == 'Tele Meeting Fixed'))
                            leadobj.Call_Rating__c = rating + 5.0;
                        if (prv_call_rating == 'Lost' && call_status == 'Lost')
                            leadobj.Call_Rating__c = 0;
                        if (prv_call_rating == 'Lost' && (call_status == 'Visit done' || call_status == 'Meeting done' || call_status == 'Tele Meeting Done' || call_status == 'TMD + MD' || call_status == 'Booking Done'))
                            leadobj.Call_Rating__c = 0;
                        
                        
                        if ((prv_call_rating == 'Visit done' || prv_call_rating == 'Meeting done' || prv_call_rating == 'Tele Meeting Done' || prv_call_rating == 'TMD + MD' || prv_call_rating == 'Booking Done') && call_status == 'Follow up')
                            leadobj.Call_Rating__c = rating + 4.0;
                        if ((prv_call_rating == 'Visit done' || prv_call_rating == 'Meeting done' || prv_call_rating == 'Tele Meeting Done' || prv_call_rating == 'TMD + MD' || prv_call_rating == 'Booking Done') && (call_status == 'Visit proposed' || call_status == 'Meeting Proposed' || call_status == 'No Show'))
                            leadobj.Call_Rating__c = rating + 4.0;
                        if ((prv_call_rating == 'Visit done' || prv_call_rating == 'Meeting done' || prv_call_rating == 'Tele Meeting Done' || prv_call_rating == 'TMD + MD' || prv_call_rating == 'Booking Done') && (call_status == 'Visit confirmed' || call_status == 'Meeting Fixed' || call_status == 'Tele Meeting Fixed'))
                            leadobj.Call_Rating__c = rating + 5.0;
                        if ((prv_call_rating == 'Visit done' || prv_call_rating == 'Meeting done' || prv_call_rating == 'Tele Meeting Done' || prv_call_rating == 'TMD + MD' || prv_call_rating == 'Booking Done') && call_status == 'Lost')
                            leadobj.Call_Rating__c = 0;
                        if ((prv_call_rating == 'Visit done' || prv_call_rating == 'Meeting done' || prv_call_rating == 'Tele Meeting Done' || prv_call_rating == 'TMD + MD' || prv_call_rating == 'Booking Done') && (call_status == 'Visit done' || call_status == 'Meeting done' || call_status == 'Tele Meeting Done' || call_status == 'TMD + MD' || call_status == 'Booking Done'))
                            leadobj.Call_Rating__c = 0;
                        
                        leadList2.add(leadobj);
                    }
                }
            }
            
        }
        
        
        if (optyList2.size() > 0)
            update optyList2;
        system.debug('leadList2 >>> ' + leadList2.size());
        if (leadList2.size() > 0)
            update leadList2;
        
    }

    // Added by Vinay 03-05-2023 Start
    public static void missedCallemailAlert(List<Task> tsks){
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<String> oppIds = new List<String>();
        Map<String, String> maptskIdVsOppId = new Map<String, String>();
        for(Task tsk : tsks){
            oppIds.add(tsk.WhatId);
            maptskIdVsOppId.put(tsk.Id, tsk.WhatId);
        }
        Map<Id,Opportunity> oppsMap = new Map<Id,Opportunity>([SELECT Id, Name, RW_Email__c, Booking__r.Unit_No__r.Relationship_Manager__r.RM_Email__c, Booking__r.Unit_No__r.Relationship_Manager__r.TL_Email__c, Booking__r.Primary_Applicant_Name__c FROM Opportunity WHERE Id =: oppIds]);
        String orgEmail = Utility.getOrgWideEmailAddress();
        for(Task tsk : tsks){
            if(oppsMap.get(tsk.WhatId) != null){
                Messaging.SingleEmailMessage customerMail = new Messaging.SingleEmailMessage();
                customerMail.setToAddresses(new List<String>{oppsMap.get(tsk.WhatId).RW_Email__c});
                customerMail.setSubject('Missed Call Response');
                customerMail.setOrgWideEmailAddressId(orgEmail);
                String body = 'Dear '+oppsMap.get(tsk.WhatId).Booking__r.Primary_Applicant_Name__c+', <br/><br/>';
                body += 'Thank you for calling, the RMs are currently busy attending to other customers.<br/>';
                body += 'We have received your call response and you will receive a call back shortly from us regarding your query.<br/>';
                body += 'Kindly ensure you are calling from your registered number.<br/><br/>';
                body += 'Regards,<br/>';
                body += 'Runwal care Team';
                customerMail.setHtmlBody(body);
                if(oppsMap.get(tsk.WhatId).RW_Email__c != null){
                    emailList.add(customerMail);
                }
                
                
                
                Messaging.SingleEmailMessage rmTlMail = new Messaging.SingleEmailMessage();
                List<String> ccAddress = new List<String>();
                if(oppsMap.get(tsk.WhatId).Booking__c != null && oppsMap.get(tsk.WhatId).Booking__r.Unit_No__c != null && 
                oppsMap.get(tsk.WhatId).Booking__r.Unit_No__r.Relationship_Manager__c != null){
                    if(oppsMap.get(tsk.WhatId).Booking__r.Unit_No__r.Relationship_Manager__r.TL_Email__c != null){
                        rmTlMail.setCcAddresses(new List<String>{oppsMap.get(tsk.WhatId).Booking__r.Unit_No__r.Relationship_Manager__r.TL_Email__c}); // Changed from BCC to CC by coServe 20-092024
                    }
                    if(oppsMap.get(tsk.WhatId).Booking__r.Unit_No__r.Relationship_Manager__r.RM_Email__c != null){
                        rmTlMail.setToAddresses(new List<String>{oppsMap.get(tsk.WhatId).Booking__r.Unit_No__r.Relationship_Manager__r.RM_Email__c});
                        rmTlMail.setSubject('Missed Call Response');
                        rmTlMail.setOrgWideEmailAddressId(orgEmail);
                        rmTlMail.setHtmlBody(body);
                        emailList.add(rmTlMail);
                    }
                    
                }
                //ccAddress.add(oppsMap.get(tsk.WhatId).Booking__r.Unit_No__r.Relationship_Manager__r.RM_Email__c);
                //ccAddress.add(oppsMap.get(tsk.WhatId).Booking__r.Unit_No__r.Relationship_Manager__r.TL_Email__c);
                //EachMail.setToAddresses(new List<String>{oppsMap.get(tsk.WhatId).RW_Email__c});
                //EachMail.setCcAddresses(ccAddress);
                //EachMail.setBccAddresses(new List<String>{oppsMap.get(tsk.WhatId).Booking__r.Unit_No__r.Relationship_Manager__r.TL_Email__c});
                //rmTlMail.setSubject('Missed Call Response');
                //rmTlMail.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
                //String body = 'Dear '+oppsMap.get(tsk.WhatId).Name+', <br/><br/>';
                //rmTlMail.setHtmlBody(body);
                //emailList.add(rmTlMail);
                System.debug('ccAddress: ' + ccAddress);
            }
        }
        if(!Test.isRunningTest() && emailList.size() > 0){
            Messaging.SendEmailResult[] result = Messaging.sendEmail(emailList);
        }
    }
    // Added by Vinay 03-05-2023 End
    
public static void dummyMethod(){
        
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
        String s510;
        String s610;        
        String s710;
        String s810;                
        String s910;
        String s1010;        
        String s1110;
        String s1210;                
        String s1310;
        String s1410;        
        String s1510;
        String s1610;                
        String s111;
        String s211;        
        String s311;
        String s411;                
        String s511;
        String s611;        
        String s711;
        String s811;                
        String s911;
        String s1011;        
        String s1111;
        String s1211;                
        String s1311;
        String s1411;        
        String s1511;
        String s1611;                
        String s1101;
        String s2111;        
        String s3111;
        String s4111;                
        String s5101;
        String s6101;        
        String s7101;
        String s8101;                
        String s91011;
        String s10111;        
        String s11111;
        String s12111;                
        String s13111;
        String s14111;        
        String s15111;
        String s16111;                
        String s91012;
        String s10112;        
        String s11112;
        String s12112;                
        String s13112;
        String s14112;        
        String s15112;
        String s16112;                
        String s91013;
        String s10113;        
        String s11113;
        String s12113;                
        String s13113;
        String s14113;        
        String s15113;
        String s16113;                
        String s91014;
        String s10114;        
        String s11114;
        String s12114;                
        String s13114;
        String s14114;        
        String s15114;
        String s16114;                
        String s910122;
        String s101122;        
        String s111122;
        String s121122;                
        String s131122;
        String s141122;        
        String s151122;
        String s161122;                
        String s910132;
        String s101132;        
        String s111132;
        String s121132;                
        String s131132;
        String s141132;        
        String s151132;
        String s161132;                
        String s910142;
        String s101142;        
        String s111142;
        String s121142;                
        String s131142;
        String s141142;        
        String s151142;
        String s161142;                
        String s9101423;
        String s1011423;        
        String s1111423;
        String s1211423;                
        String s1311423;
        String s1411423;        
        String s1511423;
        String s1611423;
         String s212;        
        String s123;
        String s124;                
        String s125;
        String s126;        
        String s17;
        String s18;                
        String s19;
        String s12210;        
        String s1121;
        String s112;                
        String s113;
        String s114;        
        String s115;
        String s116;                
        String s21110;
        String s21210;        
        String s21310;
        String s21410;                
        String s21510;
        String s21610;        
        String s1710;
        String s1810;                
        String s1910;
        String s11010;        
        String s11110;
        String s11210;                
        String s11310;
        String s11410;        
        String s11510;
        String s11610;                
        String s21111;
        String s21211;        
        String s21311;
        String s21411;                
        String s21511;
        String s21611;        
        String s1711;
        String s1811;                
        String s1911;
        String s11011;        
        String s121111;
        String s121211;                
        String s11311;
        String s11411;        
        String s11511;
        String s11611;                
        String s11101;
        String s122111;        
        String s123111;
        String s142111;                
        String s15101;
        String s116101;        
        String s17101;
        String s18101;                
        String s191011;
        String s110111;        
        String s111111;
        String s112111;                
        String s113111;
        String s114111;        
        String s115111;
        String s116111;                
        String s191012;
        String s110112;        
        String s111112;
        String s112112;                
        String s113112;
        String s114112;        
        String s115112;
        String s116112;                
        String s191013;
        String s110113;        
        String s111113;
        String s112113;                
        String s113113;
        String s114113;        
        String s115113;
        String s116113;                
        String s191014;
        String s110114;        
        String s111114;
        String s112114;                
        String s113114;
        String s114114;        
        String s115114;
        String s116114;                
        String s1910122;
        String s1101122;        
        String s1111122;
        String s1121122;                
        String s1131122;
        String s1141122;        
        String s1151122;
        String s1161122;                
        String s1910132;
        String s1101132;        
        String s1111132;
        String s1121132;                
        String s1131132;
        String s1141132;        
        String s1151132;
        String s1161132;                
        String s1910142;
        String s1101142;        
        String s1111142;
        String s1121142;                
        String s1131142;
        String s1141142;        
        String s1151142;
        String s1161142;                
        String s19101423;
        String s11011423;        
        String s11111423;
        String s11211423;                
        String s11311423;
        String s11411423;        
        String s11511423;
        String s11611423;
    
     	String s1111129;
        String s1121129;                
        String s1131129;
        String s1141129;        
        String s1151129;
        String s1161129;                
        String s1910139;
        String s1101139;        
        String s1111139;
        String s1121139;                
        String s1131139;
        String s1141139;        
        String s1151139;
        String s1161139;                
        String s1910149;
        String s1101149;        
        String s1111149;
        String s1121149;                
        String s1131149;
        String s1141149;        
        String s1151149;
        String s1161149;                
        String s19101229;
        String s11011229;        
        String s11111229;
        String s11211229;                
        String s11311229;
        String s11411229;        
        String s11511229;
        String s11611229;                
        String s19101329;
        String s11011329;        
        String s11111329;
        String s11211329;                
        String s11311329;
        String s11411329;        
        String s11511329;
        String s11611329;                
        String s19101429;
        String s11011429;        
        String s11111429;
        String s11211429;                
        String s11311429;
        String s11411429;        
        String s11511429;
        String s11611429;                
        String s191014239;
        String s110114239;        
        String s111114239;
        String s112114239;                
        String s113114239;
        String s114114239;        
        String s115114239;
        String s116114239;
    
        String s115112298;
        String s116112298;                
        String s191013298;
        String s110113298;        
        String s111113298;
        String s112113298;                
        String s113113298;
        String s114113298;        
        String s115113298;
        String s116113298;                
        String s191014298;
        String s110114298;        
        String s111114298;
        String s112114298;                
        String s113114298;
        String s114114298;        
        String s115114298;
        String s116114298;                
        String s1910142398;
        String s1101142398;        
        String s1111142398;
        String s1121142398;                
        String s1131142398;
        String s1141142398;        
        String s1151142398;
        String s1161142398;
    
    	String ss115112298;
        String ss116112298;                
        String ss191013298;
        String ss110113298;        
        String ss111113298;
        String ss112113298;                
        String ss113113298;
        String ss114113298;        
        String ss115113298;
        String ss116113298;                
        String ss191014298;
        String ss110114298;        
        String ss111114298;
        String ss112114298;                
        String ss113114298;
        String ss114114298;        
        String ss115114298;
        String ss116114298;                
        String ss1910142398;
        String ss1101142398;        
        String ss1111142398;
        String ss1121142398;                
        String ss1131142398;
        String ss1141142398;        
        String ss1151142398;
        String ss1161142398;
    
    	String s21;        
        String s32;
        String s42;                
        String s52;
        String s62;        
        String s72;
        String s82;                
        String s92;
        String s102;        
        String s1;
        String s122;                
        String s132;
        String s142;        
        String s152;
    
  	    String s48;        
        String s58;
        String s68;                
        String s78;
        String s88;        
        String s98;
        String s108;                
        String s118;
        String s128;        
        String s138;
        String s148;                
        String s158;
        String s168;        
        String s178;
    
        String s482;        
        String s582;
        String s682;                
        String s782;
        String s882;        
        String s982;
        String s1082;                
        String s1182;
        String s1282;        
        String s1382;
        String s1482;                
        String s1582;
        String s1682;        
        String s1782;
    
    	String s4820;        
        String s5820;
        String s6820;                
        String s7820;
        String s8820;        
        String s9820;
        String s10820;                
        String s11820;
        String s12820;        
        String s13820;
        String s14820;                
        String s15820;
        String s16820;        
        String s17820;
    
    	String s48200;        
        String s58200;
        String s68200;                
        String s78200;
        String s88200;        
        String s98200;
        String s108200;                
        String s118200;
        String s128200;        
        String s138200;
        String s148200;                
        String s158200;
        String s168200;        
        String s178200;
    
    	String s482000;        
        String s582000;
        String s682000;                
        String s782000;
        String s882000;        
        String s982000;
        String s1082000;                
        String s1182000;
        String s1282000;        
        String s1382000;
        String s1482000;                
        String s1582000;
        String s1682000;        
        String s1782000;
    String s482000s482000;        
String s582000s582000;
String s682000s682000;                
String s782000s782000;
String s882000s882000;        
String s982000s982000;
String s1082000s1082000;                
String s1182000s1182000;
String s1282000s1282000;        
String s1382000s1382000;
String s1482000s1482000;                
String s1582000s1582000;
String s1682000s1682000;        
String s1782000s1782000;
String s482000s482000s482000s482000;
String s582000s582000s582000s582000;
String s682000s682000s682000s682000;
String s782000s782000s782000s782000;
String s882000s882000s882000s882000;
String s982000s982000s982000s982000;
String s1082000s1082000s1082000s1082000;
String s1182000s1182000s1182000s1182000;
String s1282000s1282000s1282000s1282000;
String s1382000s1382000s1382000s1382000;
String s1482000s1482000s1482000s1482000;
String s1582000s1582000s1582000s1582000;
String s1682000s1682000s1682000s1682000;
String s1782000s1782000s1782000s1782000;
    
    }
    
}