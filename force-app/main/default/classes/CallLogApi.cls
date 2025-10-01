Public class CallLogApi {
    public String strMobile {get;set;}
   public boolean isError {get;set;}
    public String strLeadStatus{get;set;}
    public String streventType{get;set;}
    public String strStatusReason{get;set;}
    public String strProjectName {get;set;}
    public String strLeadSource {get;set;}
    public String strCallComments {get;set;}
    public List<Project__c> lstProject {get;set;}
    public String strAttemptedBy {get;set;}
    public String strStartTime {get;set;}
    public String strEmail {get;set;}
    public String strName {get;set;}
    
    public CallLogApi () {
        lstProject = new List<Project__c>();
        if(ApexPages.currentPage().getParameters().get('mobile') != '' && ApexPages.currentPage().getParameters().get('mobile') != null)
            strMobile = ApexPages.currentPage().getParameters().get('mobile');
       
        if(ApexPages.currentPage().getParameters().get('LeadStatus') != '' && ApexPages.currentPage().getParameters().get('LeadStatus') != null)
            strLeadStatus = ApexPages.currentPage().getParameters().get('LeadStatus');
        if(ApexPages.currentPage().getParameters().get('eventType') != '' && ApexPages.currentPage().getParameters().get('eventType') != null)
            streventType = ApexPages.currentPage().getParameters().get('eventType');
        if(ApexPages.currentPage().getParameters().get('statusReason') != '' && ApexPages.currentPage().getParameters().get('statusReason') != null)
            strStatusReason = ApexPages.currentPage().getParameters().get('statusReason');
        if(ApexPages.currentPage().getParameters().get('Remarks') != '' && ApexPages.currentPage().getParameters().get('Remarks') != null)
            strCallComments = ApexPages.currentPage().getParameters().get('Remarks');    
        if(ApexPages.currentPage().getParameters().get('agent') != '' && ApexPages.currentPage().getParameters().get('agent') != null)
            strAttemptedBy = ApexPages.currentPage().getParameters().get('agent'); 
        if(ApexPages.currentPage().getParameters().get('eventstartime') != '' && ApexPages.currentPage().getParameters().get('eventstartime') != null)
            strStartTime = ApexPages.currentPage().getParameters().get('eventstartime'); 
        if(ApexPages.currentPage().getParameters().get('emailId') != '' && ApexPages.currentPage().getParameters().get('emailId') != null)
            strEmail = ApexPages.currentPage().getParameters().get('emailId');     
        if(ApexPages.currentPage().getParameters().get('Name') != '' && ApexPages.currentPage().getParameters().get('Name') != null)
            strName = ApexPages.currentPage().getParameters().get('Name');             
            
    }
    public void createCallLog () {
        isError = false;
        if(String.isBlank(strMobile) || String.isBlank(strAttemptedBy) ||String.isBlank(strLeadStatus)) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning,'Required parameters are missing.'));
            isError = true;
        }
        else {
            List<lead> existingleadList = [Select Id, Name, MobilePhone from Lead where (RW_Mobile_No__c = : strMobile OR RW_Secondary_Mobile_No__c = : strMobile) and isconverted = false];
            list<Account> existingAccount = [select Id,lastname,firstname,personMobilePhone from Account where (Mobile_No__c = : strMobile OR Alternate_Mobile_No__c = : strMobile) and isPersonAccount = true];
            RecordType taskRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Anarock Call' and SObjectType = 'Task'];

            
            Task t = new Task();
                t.activityDate = System.today();
                t.status = 'Completed';
                t.Subject = 'Anarock Call';
                t.Task_Type__c = 'Anarock Call';
                t.Type = 'Anarock Call';
                t.Call_Status__c = strLeadStatus;
                t.Attempted_By__c = strAttemptedBy;
                t.Communication_Type__c = 'Inbound Call';
                t.Call_Attempt_Status__c = streventType;
                t.priority = 'Normal';
                t.recordTypeId = taskRecordType.Id;
                if(String.isNotBlank(strCallComments))
                    t.description = strCallComments;
                if(string.isNotBlank(strStartTime))
                    t.ActivityDate__c = 'StartTime :'+strStartTime;
                t.Reason_For_Lost__c = strStatusReason;
                t.Mobile_Number_Webform__c = strMobile;
                t.emailAddress__c = strEmail;
                t.FullName__c = strName;
            
            if(!existingleadList.isEmpty() && existingleadList.size() == 1) {
                t.whoid = existingleadList[0].Id;
            }
            if(!existingAccount.isEmpty() && existingAccount.size() == 1) {
                t.whatid = existingAccount[0].Id;
            }
            System.Debug('mobile :'+strMobile);
            System.Debug('Lead List :'+existingleadList);
            System.Debug('Account List :'+existingAccount);
            if (t.whoid == null && t.whatid == null)
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'SOMETHING WENT WRONG'));
            }
            else
            {
            
                try {
                    insert t;
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.confirm,'Call has been logged successfully'));
                }
                catch(exception ex) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Unexpected Error Occurred' + ex.getMessage()));
                    Task te = new Task();
                    te.activityDate = System.today();
                    //t.whoid = leadID;
                    te.description = ex.getMessage();
                    te.status = 'Done';
                    te.Subject = 'Debug CTI Error';
                    insert te; 
                }
            }
            
            }
            
        }
        
    
    
}