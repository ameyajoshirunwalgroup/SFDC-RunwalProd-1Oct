global with sharing class TaskRelatedListLoanClass {
	public Map<String,List<task>> taskMap {get; set;}
    public Map<String,String> commandButtonMap{get; set;}
    private final Opportunity opp;
    private final Lead lead;
    private String objName;
    private final Account acc;
    private final Loan__c loan;
   
    public TaskRelatedListLoanClass(ApexPages.StandardController stdController) {
     
        objName = stdController.getRecord().getSObjectType().getDescribe().getName();
        if(objName == 'Opportunity') {
            this.opp = (Opportunity)stdController.getRecord();
        } else if(objName == 'Lead') {
            this.lead = (lead)stdController.getRecord();
        } else if(objName == 'Account'){
            this.acc = (Account)stdController.getRecord();
        } else if(objName == 'Loan__c'){
            this.loan = (Loan__c)stdController.getRecord();
        }
        else{
        
        }
        getButtonMap();
       
       
    }
    
    
    public Map<String,String> getButtonMap() {

        //Instantiate variables
        commandButtonMap = new Map<String,String>();

        Integer counter = 0;
        
        for(string t : taskType) {
            if(objName == 'Loan__c' ){
                commandButtonMap.put(t,'New ' +t);
            }
        }
        system.debug('commandButtonMap====== '+commandButtonMap);
        return commandButtonMap;
    }
    
    @RemoteAction
    global static List<Task>  getTasksByType(String taskType, Id parentId) {
        //Instantiate variables
        List<Task> taskList = new List<Task>();
        if (parentId.getSObjectType().getDescribe().getName() == 'Loan__c' ){
            //taskList = TaskManagementServices.getTaskByTypeLead(taskType, 'ALL' , 'createdDate' , 'DESC', parentId);
            String baseQuery = 'SELECT Id, Subject, Task_Type__c, ActivityDate,Call_Time__c, call_status__c, Status, What.Name, Who.Name, Priority, OwnerId, Description,Call_Attempt_Status__c,Previous_Call_Attempt_Status__c,Attempted_By__c FROM Task '; //Call_Time__c
        	String taskStatus = 'Completed';
            String sortField = 'createdDate';
            String sortOrder = 'DESC';
            String WhatId = parentId;
            String buildQuery = baseQuery;
            List < String > customMsgList = new List < String > ();
            
            /*if (String.isBlank(taskType) || String.isblank(taskStatus) || String.isBlank(sortOrder) || String.isBlank(sortField) || String.isBlank(whoId)) {
                String msg = 'Required Parameters Missing';
                customMsgList.add(msg);
                throw new GlobalException(customMsgList, '', 'TaskManagementServices.getTaskByType');
            }*/
            
            if (!sortOrder.equals('ASC') && !sortOrder.equals('DESC')) {
                String msg = 'Incorrect sort order, sort order can only be ASC or DESC';
                customMsgList.add(msg);
                throw new GlobalException(customMsgList, '', 'TaskManagementServices.getTaskByType');
                
            }
            List < String > taskStatusList = new List < String > ();
            taskStatusList.add('\'Completed\'');
            taskStatusList.add('\'Open\'');
            
            System.debug('taskStatusList:' + taskStatusList);
            System.debug('taskType:' + taskType);
            System.debug('WhatId:' + WhatId);
            buildQuery = buildQuery + 'where task_type__c =' + '\'' + taskType + '\'' + ' and status IN ' + taskStatusList + ' and WhatId =' + '\'' + WhatId + '\'' + ' order by Status, ' + sortField + ' ' + sortOrder;
            System.debug('QUERY:' + buildQuery);
            taskList = (List < Task > ) Database.query(buildQuery);
            System.debug('taskList:' + taskList);
            System.debug('taskList.size():' + taskList.size());
            //return taskList;
        }
        system.debug('taskList'+taskList);
        return taskList;
    }
    
    // this controls the list of tabs we see on related list    
    public List<String> taskType
    {
        get {
          List<String> taskTypeValues = new List<String>();
                
           Schema.DescribeFieldResult fieldResult = Task.Task_Type__c.getDescribe();
           List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
           taskTypeValues.add('Home Loan Call');
            
          /* for( Schema.PicklistEntry f : ple)
           {
                if(objName == 'Lead') {
                    if(f.getValue() == 'Site Visit' || f.getValue() == 'CRM Call') {
                        
                    } else {
                        taskTypeValues.add(f.getValue());
                    }
                }else if(objName == 'Account') {
                    if(f.getValue() == 'Site Visit') {
                        
                    } else {
                        taskTypeValues.add(f.getValue());
                    }
                }else if(objName == 'Loan__c') {
                    if(f.getValue() == 'Home Loan') {
                        taskTypeValues.add(f.getValue());
                    } else {
                        taskTypeValues.add(f.getValue());
                    }
                }
               else {
                    taskTypeValues.add(f.getValue());
    
                }                
           }*/
           System.debug('tasktypes:===== ' + taskTypeValues);
        // System.debug('taskType:===== ' + taskType);      
           return taskTypeValues;
        }
       private set;
    }
    
 @RemoteAction
    global static boolean getButtonAccess(String buttonName){
        system.debug('buttonName'+buttonName);
        return(ProfileFeatureAccessServices.hasAccess(UserInfo.getUserId(),buttonName));    
    }
    
    @RemoteAction
    global static boolean isRevisit(String parentId){
        return (TaskManagementServices.isRevisit(parentId));
    }
    
    /////---------------- added by vikas for Edit options on customer interaction ----------------------/////////
    @RemoteAction
    global static Integer isSystemAdmin(String buttonName){
       string id;
       Integer res = 0;
       id = UserInfo.getUserId();
       //id = id.subString(0,15);
      
       /*if(id == '00e36000000z4fh') ///// for system admin
       return 1;
       else if(id == '00e36000001C7uD') //// for sales strategy operation profile
       return 2;
       else 
       return 0;*/
       //system.debug('buttonName:::' + buttonName);
       List<User> u = [Select Id, profile.Name from user where Id = :id];
       if(!u.isEmpty() && string.isNotBlank(buttonName)){
          res = ProfileFeatureAccessServices.getEditAccess(u[0].profile.Name,buttonName);
       }
       //system.debug('res::: '+res);
       return res;
    }
    
    public static void latestTaskRollupToLoan(List < Task > taskList) {
        Map < Id, Task > loanTaskMap = new Map < Id, Task > ();
        for (Task t: TaskList) {
            if (t.WhatId != null && t.WhatId.getSObjectType().getDescribe().getName() == 'Loan__c') {
                if (loanTaskMap.containsKey(t.whatId)) {
                    // if a task already exist for the oppty, 
                    // replace it with the new task only if the new task is the latest
                    if (loanTaskMap.get(t.whatId).createdDate < t.createdDate) {
                        loanTaskMap.put(t.whatId, t);
                    }
                } else {
                    loanTaskMap.put(t.whatId, t);
                }
            }
        }
        List < Loan__c > loanList = [select Id, Name, Call_Comments__c, Call_Count__c, CreatedById, CreatedDate, 
                                     First_Call_Attempt_Date__c, First_Call_Attempt_Status__c, Last_Call_Date__c,
                                     First_Disbursement_sub_status__c, HL_RM_Name__c, HL_Status__c, HL_Sub_Status__c, 
                                     Last_Call_Description__c, Next_Call_Date__c, Last_Call_Attempt_Date__c  from Loan__c where Id in : loanTaskMap.keySet()];
        Set < Id > accIdSet = new Set < Id > ();
        List < AggregateResult > taskCountAg = [Select count(Id) taskCount, whatId loanId, task_type__c taskType from Task
                                                where whatId in : loanTaskMap.keySet() group by whatId, task_type__c
                                               ];
        Map < String, Map < String, Integer >> loanTaskCountMap = new Map < String, Map < String, Integer >> ();
        for (AggregateResult ar: taskCountAg) {
            if (loanTaskCountMap.containsKey((String) ar.get('loanId'))) {
                loanTaskCountMap.get((String) ar.get('loanId')).put((String) ar.get('taskType'), (Integer) ar.get('taskCount'));
            } else {
                Map < String, Integer > tempMap = new Map < String, Integer > ();
                tempMap.put((String) ar.get('taskType'), (Integer) ar.get('taskCount'));
                loanTaskCountMap.put((String) ar.get('loanId'), tempMap);
            }
        }
        for (Loan__c ln : loanList) {
            System.debug('loan:' + ln);
            if (loanTaskMap.containsKey(ln.Id) && loanTaskMap.get(ln.Id).Task_Type__c == 'Home Loan Call') {
                if(!system.today().format().contains('GMT') && string.isNotBlank(ln.Last_call_description__c ) ){
                    ln.Last_call_description__c = system.today().format() + ' : ' + loanTaskMap.get(ln.Id).Description;
                    
                    system.debug('Loan Last Call Description ==== ' +  ln.Last_call_description__c);
                }
                
                ln.Last_call_attempt_status__c = loanTaskMap.get(ln.Id).Call_Status__c;
                ln.Next_Call_Date__c = loanTaskMap.get(ln.Id).Next_Action_Date__c;
                ln.Last_call_attempted_by__c = loanTaskMap.get(ln.Id).RW_Sales_Associate__c;
                ln.Call_Comments__c = loanTaskMap.get(ln.Id).ActivityDate.format() + '-' + loanTaskMap.get(ln.Id).Description;
                Datetime taskDate = loanTaskMap.get(ln.Id).ActivityDate;
                
                if (taskDate == null)
                    taskDate = Date.today();
                
                
                // stripping the time value 00:00:00 from the t.activity date value
                String taskDate1 = taskDate.Date().format();
                
                // Here we are concatenating the date and time values to make create a datetime string   
                if(loanTaskMap.get(ln.Id).Call_Time__c != null) {                  
                    taskDate1 = taskDate1 + ' ' + loanTaskMap.get(ln.Id).Call_Time__c;
                    System.Debug('Value of datetime parse function' + taskDate1);
                    ln.last_call_attempt_date__c = DateTime.Parse(taskDate1);
                }
                else
                    ln.last_call_attempt_date__c = system.now();
                if(ln.First_Call_Attempt_Date__c == null){            
                    if(loanTaskMap.get(ln.Id).Call_Time__c != null) {                  
                        //taskDate1 = taskDate1 + ' ' + loanTaskMap.get(ln.Id).Call_Time__c;
                        ln.First_Call_Attempt_Status__c = loanTaskMap.get(ln.Id).Call_Status__c;
                        System.Debug('Value of datetime parse function' + taskDate1);
                        ln.First_Call_Attempt_Date__c = DateTime.Parse(taskDate1);
                    }
                    else
                        ln.First_Call_Attempt_Date__c = system.now();
                }
                ln.Call_Count__c = loanTaskCountMap.get(ln.Id).get('Home Loan Call');
                system.debug('ln.Call_Count__c:::: ' + ln.Call_Count__c);  
            }
            
        }
        update(loanList);
        
    }
    
    
    
}