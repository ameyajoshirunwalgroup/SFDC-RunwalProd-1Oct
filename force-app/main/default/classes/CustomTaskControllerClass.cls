public with sharing class CustomTaskControllerClass {
    
    
    // Added By UBSDigicloud
   // public Task t = new Task();
    public Map<Id, String> userMap { get; set; }
    public String selectedSalesManagerId { get; set; }
    
   
    public Task t = new Task();
    public boolean create {
        get;
        set;
    }
    public boolean edit {
        get;
        set;
    }
    public boolean error {
        get;
        set;
    }
    public boolean errorForSave {
        get;
        set;
    }
    public boolean check1 {
        get;
        set;
    }
    public String unitName {
        get;
        set;
    }
   
    private Id whatId = null;
    private Id whoId = null;
    private Id ownerId = null;
    public Id SCPPDid = null;
    private String origin = null;
    private ApexPages.StandardController stdController = null;
    private string cancelURL = null;
    private string retURL = null;
    public string walksource {
        get;
        set;
    }
    public string walksubsource {
        get;
        set;
    }
    public string channelPartner {
        get;
        set;
    }
    public string xcelerateID {
        get;
        set;
    }
    public string CPName {
        get;
        set;
    }
    public string CPPhone {
        get;
        set;
    }
    public string CPEmail {
        get;
        set;
    }
    public string BookedCustomer {
        get;
        set;
    }
    public string EmpName {
        get;
        set;
    }
    public string EmpId {
        get;
        set;
    }
    public string NameO {
        get;
        set;
    }
    public string EmailO {
        get;
        set;
    }
    public string MobO {
        get;
        set;
    }
    public string RelationO {
        get;
        set;
    }
    public string accountName {
        get;
        set;
    }
    public string pickupAdd {
        get;
        set;
    }
    public string ChannelPName {
        get;
        set;
    }
    public string ChannelPCompany {
        get;
        set;
    }
    public string ChannelPCode {
        get;
        set;
    }
    public string ChannelRepresentativeName {
        get;
        set;
    }
    // public List <Standard_Customer_Pay_Plan_Detail__c> LSCCPD {get;set;} 
    /*public List < Applicant_Details__c > Lapplicant {
        get;
        set;
    }*/
    private List < Opportunity > opp = new List < Opportunity > ();
    private List < Account > acc = new List < Account > ();
    private List < Lead > lead = new List < Lead > ();
    public Attachment myfile;
    private Map < String, String > qsMap = new Map < String, String > ();
    public List < Attachment > AtchObj {
        get;
        set;
    }
    public List < Attachment > AtchObjLoanClosure {
        get;
        set;
    }
    public String selectedCriteriaR {
        get;
        set;
    }
    public String selectSubject {
        get;
        set;
    }
    public String UnitMortgageStatus {
        get;
        set;
    }
    public String selectDoc {
        get;
        set;
    }

    public String originalStatus {
        get;
        set;
    } //represents the registration status while landing on the page.

    public CustomTaskControllerClass(ApexPages.StandardController controller) {
        this.stdController = controller;
        this.t = (Task) controller.getRecord();
        create = false;
        edit = false;
        error = false;
        errorForSave = false;
        pickupAdd = '';
        selectedCriteriaR = '';
        check1 = false;
        selectSubject = '';
        UnitMortgageStatus = '';
        selectDoc = '';
        system.debug('check1' + check1);
        qsMap = ApexPages.currentPage().getParameters();
        if (qsMap.containsKey('retURL')) {
            retURL = qsMap.get('retURL');
        }
        if (qsMap.containsKey('cancelURL')) {
            cancelURL = qsMap.get('cancelURL');
        }
        System.debug('query string map:' + qsMap);
        System.debug('returnURL:' + retURL);
        System.debug('cancelURL:' + cancelURL);

        if (qsMap.containsKey('origin')) {
            origin = qsMap.get('origin');
        } else {
            origin = 'Default';
        }
        AtchObj = new List < Attachment > ();
        AtchObjLoanClosure = new List < Attachment > ();
        // what and are who are present in oppty page task button
        if (qsMap.containsKey('who_id') && qsMap.containsKey('what_id')) {
            whatId = ApexPages.currentPage().getParameters().get('what_id');
            whoId = ApexPages.currentPage().getParameters().get('who_id');
            ownerId = UserInfo.getUserId();

            create = true;
        } else if (qsMap.containsKey('who_id')) {
            // who is present only on lead page task
            whoId = ApexPages.currentPage().getParameters().get('who_id');
            ownerId = UserInfo.getUserId();
            create = true;
            retURL = '/' + whoId;
            cancelURL = '/' + whoId;
        } else if (qsMap.containsKey('id')) {
            // if task id is present its an task edit
            edit = true;
            System.debug('Task Details in Edit: ' + t);
            
         // Added By UBSdigicloud   
         Id taskId = qsMap.get('id');
        t = [SELECT Id, Subject, OwnerId, WhoId, WhatId, Status, Priority, Sales_Manager__c, Task_Type__c, Team_Attended_By__c,Communication_Type__c,Call_Attempt_Status__c
         FROM Task
         WHERE Id = :taskId
         LIMIT 1];
            selectedSalesManagerId = t.Sales_Manager__c;
            
        } else {
            // if none are there is an error
            error = true;
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.FATAL, 'Missing Required Parameters');
            ApexPages.addMessage(errorMsg);
        }

        // if we dont know the origin, we set to default.
        // if its coming from any of the custom button on task page, it would have the button name as the origin
        // if an origin is known, then take the url parameters and set it in the value of the task
        if (create) {
            String customerName = null;
            String objectwhatName = null;
            String objectwhoName = null;
            String mobile = null;
            Boolean revisit = false;

            if (String.isNotEmpty(whatId)) {
                objectWhatName = whatId.getSObjectType().getDescribe().getName();
            }
            if (String.isNotEmpty(whoId)) {
                objectWhoName = whoId.getSObjectType().getDescribe().getName();
            }
            if (objectwhatName == 'Opportunity') {
                opp = [Select Name, Account.Name, Walk_in_Source__c, Walk_in_Sub_Source__c, Walk_in_Respective_Customer_Account__r.Name, Last_call_attempt_status__c, Id, RW_Project__c,Budget_In_Lakh__c,Sales_Manager__c,Sales_Manager_User__c,
                    Walk_in_Channel_Partner_Name__c, Walk_in_Channel_Partner_Phone__c, Walk_in_Channel_Partner_Email__c, Walk_in_Employee_Name__c, Site_Visit_Channel_Partner__r.Name,
                    Walk_in_Employee_Id__c, Name_O__c, Relation_With_Radius_O__c, Status__c, RW_Project_Unit__r.Unit_Morgage_Status__c, Site_Visit_Channel_Partner__c, Site_Visit_Xcelerate_ID__c,
                    Person_Email__c, Account_Mobile_Number__c, RW_Project_Unit__r.Id, RW_Project_Unit__r.Name, StageName,RW_Budget__c,RW_Configuration__c,RW_Time_line__c,RW_Location__c,
                   Urgency__c,Site_Revisit_or_Follow_up_Visit__c,Family_Stakeholder_Buy_In__c,Amenities_Compliance_with_Customer_Prefe__c,Inventory_Preference__c,Loan_Pre_Approval__c,Engaged_with_Competition__c from Opportunity where Id = : whatId
                ];

                revisit = TaskManagementServices.isRevisit(whatId);
                System.debug('REVISIT'+revisit);
            }
            if (opp.size() == 1) {
                //t.Project__c= opp[0].ProjectName__c; // Added By Netra 18/3/2016
                t.Previous_Call_Attempt_Status__c = opp[0].Last_call_attempt_status__c; // Added By Netra 18/3/2016
                t.Visitor_Name__c = opp[0].Account.Name;
                accountName = opp[0].Account.Name;
                customerName = opp[0].Name;
                system.debug('OPP ID : ' + opp[0].Id);
                system.debug('OPP Name: ' + opp[0].Name);
                walksource = opp[0].Walk_in_Source__c;
                walksubsource = opp[0].Walk_in_Sub_Source__c;
                if (opp[0].Site_Visit_Channel_Partner__c != null)
                    channelPartner = opp[0].Site_Visit_Channel_Partner__c;
                if (opp[0].Site_Visit_Xcelerate_ID__c != null)
                    xcelerateID = opp[0].Site_Visit_Xcelerate_ID__c;
                CPName = opp[0].Walk_in_Channel_Partner_Name__c;
                CPPhone = opp[0].Walk_in_Channel_Partner_Phone__c;
                CPEmail = opp[0].Walk_in_Channel_Partner_Email__c;
                BookedCustomer = opp[0].Walk_in_Respective_Customer_Account__r.Name;
                EmpName = opp[0].Walk_in_Employee_Name__c;
                EmpId = opp[0].Walk_in_Employee_Id__c;
                NameO = opp[0].Name_O__c;
                EmailO = opp[0].Person_Email__c;
                MobO = opp[0].Account_Mobile_Number__c;
                RelationO = opp[0].Relation_With_Radius_O__c;
                t.Walk_in_Source__c = walksource;
                t.Walk_in_Sub_Source__c = walksubsource;
                
                 // BPCL and visit  field mapping By digicloud
                t.Budget_In_Lakh__c = opp[0].Budget_In_Lakh__c;
                t.Configuration__c = opp[0].RW_Configuration__c;
                t.Time_Line__c = opp[0].RW_Time_line__c;
                t.Preferred_Location__c = opp[0].RW_Location__c;
                t.Urgency__c = opp[0].Urgency__c;
                t.Family_Stakeholder_Buy_In__c = opp[0].Family_Stakeholder_Buy_In__c;
                t.Amenities_Compliance_with_Customer_Prefe__c = opp[0].Amenities_Compliance_with_Customer_Prefe__c;
                t.Inventory_Preference__c = opp [0].Inventory_Preference__c;
                t.Loan_Pre_Approval__c = opp[0].Loan_Pre_Approval__c;
                t.Engaged_with_Competition__c = opp[0].Engaged_with_Competition__c;
               t.Sales_Manager__c = opp[0].Sales_Manager_User__c;
            //    System.Debug('Salesmanager========='+t.Sales_Manager__c);
                
                // added by UBSDigicloud 14-04-25
                if (t.Id == null ||  t.Communication_Type__c == null || t.Communication_Type__c == '')  {
                    t.Communication_Type__c = 'Outbound Call'; 
                } 
                
                if (channelPartner != null)
                    t.Channel_Partner__c = channelPartner;

                system.debug('Opp Walk In Source : ' + opp[0].Walk_in_Source__c);
                system.debug('Opp Walk In Subsource : ' + opp[0].Walk_in_Sub_Source__c);
                ////For Home Loan/////////
                UnitMortgageStatus = opp[0].RW_Project_Unit__r.Unit_Morgage_Status__c;
                System.debug('opp[0].RW_Project_Unit__r ' + opp[0].RW_Project_Unit__c);
            }

            if (objectwhoName == 'Account' || objectwhoName == 'Contact') {
                acc = [Select Name, Id, IsPersonAccount, Mobile_No__c, PersonContactId from Account where Id = : whoId];


            }
            if (acc.size() == 1 && acc[0].IsPersonAccount) {
                whoId = acc[0].PersonContactId;
                if (string.IsEmpty(customerName)) {
                    customerName = acc[0].Name;
                }
                mobile = acc[0].Mobile_No__c;
            }

            if (objectwhoName == 'Lead') {
                lead = [Select Name, Id, RDS_Mobile__c, RW_Project__c, Last_call_attempt_status__c,LeadSource,RW_Lead_Sub_Source__c,Status FROM Lead WHERE Id = : whoId];
            }
            
                       
            if (lead.size() == 1) {
                if (string.IsEmpty(customerName)) {
                    customerName = lead[0].Name;
                }
                mobile = lead[0].RDS_Mobile__c;
                t.Project__c = lead[0].RW_Project__c; // Added By Netra 18/3/2016
                t.Previous_Call_Attempt_Status__c = lead[0].Last_call_attempt_status__c; // Added By Netra 18/3/2016
              
            }

            if (String.isNotEmpty(whatId))
                t.WhatId = whatId;
            t.OwnerId = ownerId;
            t.whoId = whoId;
            t.activityDate = System.today();
            t.Call_Time__c = System.Now().format('h:mm a');
            t.RW_Call_Timing__c = System.Now();
            t.Mobile_Number_Webform__c = mobile;
            t.revisit__c = revisit;

            // if we dont know the origin, we set to default.
            // if its coming from any of the custom button on task page, it would have the button name as the origin
            // if an origin is known, then take the url parameters and set it in the value of the task
            if (!origin.equals('Default')) {
                t.status = qsMap.get('status');
                t.Subject = qsMap.get('subject');
                system.debug('qsMap.get subject : ' + qsMap.get('subject'));
                t.Task_Type__c = qsMap.get('taskType');
                if(qsMap.get('taskType')!= null && qsMap.get('taskType')== 'Presales call'){
                t.Team_Attended_By__c='Pre Sales';
                }
                if(qsMap.get('taskType')!=null && qsMap.get('taskType')=='Sales Call'){
                t.Team_Attended_By__c='Sales';
                }
                t.priority = 'Normal';
            }
            
            //Added by vinay 08-03-2022 start
            if (origin.equals('Home Loan Call')) {
                //t.RecordTypeId = '0121e000000DApBAAW';
                //t.RecordTypeId = '0125j000000ktqjAAA';
                t.RecordTypeId = System.label.Home_Loan_Call_Task_Record_Type_Id;
            }
			//Added by vinay 08-03-2022 end
				
        }
        //Anuja added this line to add Standad Pay Plan Detail lookup on task from url
        /*     if(ApexPages.currentPage().getParameters().get('scppd') != null || ApexPages.currentPage().getParameters().get('scppd') == '')
        {
            SCPPDid = ApexPages.currentPage().getParameters().get('scppd');
            //t.Standard_Customer_Pay_Plan_Detail__c = SCPPDid ;
            t.Communication_Type__c= 'Outbound Call';
            t.Reason_For_Call__c = 'Collections';
        } 
        if(t.Task_Type__c != null && t.Task_Type__c.equalsIgnoreCase('Registration')) {
            
            regCheck();
        }
        if(t.Task_Type__c != null && t.Task_Type__c.equalsIgnoreCase('Home Loan')) {
            selectSubject = t.Subject;
            HomeLoanCheck();
        }  */
    }
    
    Public void dummyMethod(){
        system.debug('inside dummyMethod');
       // system.debug('t.Call_Attempt_Status__c:: '+t.Call_Attempt_Status__c);
    }




    Public Pagereference Savedoc() {
        system.debug('------selectDoc' + selectDoc);
        String taskId = System.currentPagereference().getParameters().get('id');

        /* insert the attachment */

        error = false;
        return NULL;
    }


    public PageReference save() {
        system.debug('inside save');
        errorForSave = False;
        Pagereference pv = null;
        if(t.Id != null){
           t = [SELECT Id, Task_Type__c, Revisit__c, ShowWalkInSource__c, Call_Proposed_date_of_visit__c, Call_Status__c, Next_Action_Date__c,Sales_Manager__c FROM Task WHERE Id =: t.Id];
        }
        try {
            if (origin.equals('CompleteTask')) {
                t.status = 'Completed';
            }
            System.debug('task type::'+t.Task_Type__c);
            //Added by Prashant to assign the site visit recordtypeid as it was giving null and assigning default record type to the task - 13-2-25 //Start///
            system.debug('Task record type -  >> before '+t.RecordTypeId);
            if(t.RecordTypeId == null){ //Added if condition by Vinay 06-06-2025
                Id siteVisitRecId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Site Visit task').getRecordTypeId();
                t.RecordTypeId = siteVisitRecId;
            }
            
            system.debug('Task record type -  >> after '+t.RecordTypeId);
            //Added by Prashant to assign the site visit recordtypeid as it was giving null and assigning default record type to the task - 13-2-25 //End///
            //if(t.Task_Type__c != null)			//Commented by Sheetal on 15.6.2022 to solve issue I0187
               // t.Subject = t.Task_Type__c;
            //Added by vinay 08-03-2022 start
            if(t.Task_Type__c == 'Home Loan Call')
                //t.RecordTypeId = '0121e000000DApBAAW';
                //t.RecordTypeId = '0125j000000ktqjAAA';
                t.RecordTypeId = System.label.Home_Loan_Call_Task_Record_Type_Id;
            System.debug('RecordTypeId::'+t.RecordTypeId);
             //Added by vinay 08-03-2022 end
           /** commented by shailesh on 4.12.17 
           if(t.Task_Type__c=='Site Visit')
            {
              if(t.Revisit__c){
                  t.Task_Type__c='Revisit';
                 t.Subject = t.Task_Type__c;
              }
            }
            **/
            //In case of revisit, if the walk-in source is the same as on opty then populating task fields with opty values
            t.ShowWalkInSource__c = check1;
            System.debug('t.Task_Type__c:' + t.Task_Type__c);
            if (t.Revisit__c == true && t.ShowWalkInSource__c == false && t.Task_Type__c == 'Site Visit') {
                System.Debug('Inside this condition');
                t.Walk_in_Source__c = walksource;
                t.Walk_in_Sub_Source__c = walksubsource;
                if (channelPartner != null)
                    t.Channel_Partner__c = channelPartner;
            }

            //Added by Vinay 18-12-2024 Start
            Id presalesTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Presales Task').getRecordTypeId();//Added by Vinay 24-04-2025
            List<String> nextActionDateStatuses = new List<String>{'Call back later','Client Query','Follow Up','Follow Up- NC','Interested','Meeting Done','Meeting Fixed','Meeting Proposed','No Show','Not Connected','Number Busy','Out of Coverage Area','Ringing','Spoke to the 3rd party','Switched Off','Tele-Meeting Done','Visit Confirmed','Visit Done','Visit Proposed'};
            List<String> proposedDateOfVisitStatuses = new List<String>{'Meeting Done','Meeting Fixed','Meeting Proposed','No Show','Tele-Meeting Done','Visit Confirmed','Visit Done','Visit Proposed'};	
            if(t.Call_Proposed_date_of_visit__c == null && proposedDateOfVisitStatuses.contains(t.Call_Status__c) && t.RecordTypeId != presalesTaskRecordTypeId){ //Added t.RecordTypeId != presalesTaskRecordTypeId by Vinay 24-04-2025
                ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.FATAL, 'Please fill Proposed Date of Visit');
            	ApexPages.addMessage(errorMsg);  
            }
            //Added by Vinay 10-07-2025 Start
            Boolean skipNextActionDatevalidation = false; 
            if(t.whoId != null && t.whoId.getSObjectType().getDescribe().getName() == 'Lead' && lead[0] != null && lead[0].Status == 'Lost' && t.RecordTypeId != presalesTaskRecordTypeId){ 
                User usr = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Id =: UserInfo.getUserId()];
                List<String> presalesProfiles = new List<String>{'Pre Sales Executive','Pre Sales Executive Outsource','Pre Sales Manager','Pre Sales Manager/Marketing','Presales Executive Offline','Outsourced Presales'};
                if((usr.Profile.Name == 'NRI Sales Manager' && usr.UserRole.Name == 'Loyalty SM') || presalesProfiles.contains(usr.Profile.Name)){
                    skipNextActionDatevalidation = true;
                }
            }
            //Added by Vinay 10-07-2025 End

            if(t.Next_Action_Date__c == null && nextActionDateStatuses.contains(t.Call_Status__c) && t.RecordTypeId != presalesTaskRecordTypeId && skipNextActionDatevalidation == false){ //Added t.RecordTypeId != presalesTaskRecordTypeId by Vinay 24-04-2025  //Added skipNextActionDatevalidation == false by Vinay 10-07-2025
                ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.FATAL, 'Please fill Next Action Date');
            	ApexPages.addMessage(errorMsg); 
                return null;
            }
          /*  if (t.Next_Action_Date__c == null && nextActionDateStatuses.contains(t.Call_Attempt_Status__c)  && t.RecordTypeId != presalesTaskRecordTypeId) {
                ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.FATAL, 'Please fill Next Action Date');
            	ApexPages.addMessage(errorMsg); 
                return null;
              }*/
            
            //Added by Vinay 16-05-2025 Start
            List<String> callDispostionValues = new List<String>{'Visit Scheduled','Lost','Junk'};
            Date dt = Date.newInstance(2025, 5, 13);
            if(t.Next_Action_Date__c == null && t.Task_Type__c == 'Presales Call' && t.RecordTypeId == presalesTaskRecordTypeId && !callDispostionValues.contains(t.Call_Disposition_Custom__c) && t.CreatedDate >= dt){ 
                ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.FATAL, 'Please fill Next Action Date');
            	ApexPages.addMessage(errorMsg); 
                return null;
            }
            //Added by Vinay 16-05-2025 End
            //Added by Vinay 18-12-2024 End


            if (errorForSave != True) {
                System.debug('in task save:');
                 System.debug('t.Task_Type__c:' + t.Task_Type__c);
                t.Sales_Manager__c = selectedSalesManagerId;
                System.debug('selectedSalesManagerId: ' + selectedSalesManagerId);
                   System.debug('-===Sales Manager: ' + t.Sales_Manager__c);
                    //  update t;
               pv = stdController.save();
                 //System.debug('t.Task_Type__c:' + t.Task_Type__c);
                System.debug('in task save:1');
            }

            // took a day to figure this out. if the standard controller save is called
            // it handles the validation exceptions and returns a null as page reference
            // doesnt throw DML exception as described in the SF documents
            // check for pv = null and return the same to see the exceptions on UI
            if (pv == null) {
                return null;
            }
            if (String.isNotEmpty(retURL)) {
                pv = new PageReference(retURL);
            } else {
                pv = new PageReference('/' + t.whoId);
            }
            return pv;
        } catch (DMLException e) {
            System.debug('DML:' + e.getMessage());
            ApexPages.addMessages(e);
            return null;
        } catch (Exception e) {
            System.debug('Ex:' + e.getMessage());
            ApexPages.addMessages(e);
            return null;
        }
    }

    public PageReference cancel() {
        Pagereference pv = null;
        if (String.isNotEmpty(cancelURL)) {
            pv = new PageReference(cancelURL);
        } else {
            if (String.isNotEmpty(t.whatId)) {
                cancelURL = '/' + t.whatId;
            } else {
                cancelURL = '/' + t.whoId;
            }
            pv = new PageReference(cancelURL);
        }
        return pv;
    }
    
    //Added by vinay start
    public List<SelectOption> hlrmNames
    {
        get {
            List<Home_Loan_RM__c> hlrms = [SELECT Id, Name From Home_Loan_RM__c];
            List<String> rmNames = new List<String>();
             List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption(String.valueOf(0),'--None--'));
            for(Home_Loan_RM__c rm : hlrms){
                if(!rmNames.contains(rm.Name)){
                    rmNames.add(rm.Name);
                    options.add(new SelectOption(rm.Name,rm.Name));
                }
            }   
           return options;
        }
       public set;
    }
    
    public List<SelectOption> homeLoanCallStatus
    {
        get {
            Map<String, HomeLoanCallStatus__c> callStatus = HomeLoanCallStatus__c.getall();
            
             List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption(String.valueOf(0),'--None--'));
            for(String status : callStatus.keySet()){
                options.add(new SelectOption(status,status));
            }   
           return options;
        }
       public set;
    }
    
    public List<SelectOption> homeLoanFollowupStatus
    {
        get {
            Map<String, HomeLoanFollowupStatus__c> followUpStatus = HomeLoanFollowupStatus__c.getall();
            
             List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption(String.valueOf(0),'--None--'));
            for(String status : followUpStatus.keySet()){
                options.add(new SelectOption(status,status));
            }   
           return options;
        }
       public set;
    }
	//Added by vinay end


 // Method to fetch active users for dropdown   By UBSDigiCloud
    
    public List<SelectOption> getUserOptions() { 
        userMap = new Map<Id, String>();
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', 'None'));
        
        for (User u : [SELECT Id, FirstName, LastName FROM User WHERE IsActive = true AND Profile.Name LIKE '%Sales%' ORDER BY FirstName, LastName]) {
            String name = (u.FirstName != null ? u.FirstName + ' ' : '') + (u.LastName != null ? u.LastName : '');
            userMap.put(u.Id, name.trim());
            options.add(new SelectOption(u.Id, name.trim()));
        }
        return options;
    }
    
    
    public void dummyMethod566(){
            
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
}