public class SendBulkLeadClass {

    //public List<CampaignMember> LeadList {get;set;}
    //public List<CampaignMember> accList{get;set;}
    //public Transient  Date From_date{get;set;}
    //public Transient  Date Till_date{get;set;}
    public String CampName{get;set;}
    public Transient  String templateName {get;set;}
    public List<CampaignMember> lstSendMailLead{get;set;}
    //public List<CampaignMember> lstSendMailAccount{get;set;}
    //public List<CampaignMember> lstSendSMS {get;set;}
    //public List<SMS_Template_Master__c>SMStempList{get;set;}
    //Public String SMStempName {get; set;}
    public Transient  Integer LeadCount {get;set;}
    public Transient  Integer AccCount {get;set;}
    public Transient  Integer OppCount {get;set;}
    public Boolean batchStatusBool {get;set;}
    public String batchStatus {get;set;}
    public Boolean pollerBool {get;set;}
    Public Boolean showsavepopup {get;set;}
    Public List<ID> smsaccountid{get;set;}
    public String strError {get;set;}
    Id batchId;
    
    public List<SelectOption> getCampList() {
        List<SelectOption> options = new List<SelectOption>();
        List <campaign> queryResult = new List <campaign> ();
        
        queryResult = [Select Id, Name,CBSL_Data__c from campaign Where CBSL_Data__c =: true];
        System.debug('queryResult:::::::::'+queryResult);
        options.add(new SelectOption('','--Select Campaign--'));
        for (campaign obj: queryResult) {
            options.add(new SelectOption(obj.Id, obj.Name));
        }
        return options;
    }
    
    public void getMembers(){
    System.debug('In get member'+CampName);
    //lstSendMailLead = [SELECT Id,Lead.id,Lead.Name,Contact.AccountId ,Contact.name, Email,FirstName ,LastName, Type FROM CampaignMember WHERE  email != '' AND Campaignid = :CampName ];
    //LeadList = [SELECT Id, Lead.Name, Email,FirstName ,LastName, Type FROM CampaignMember WHERE Type = 'Lead' AND email != '' AND Campaignid = :CampName ];
    LeadCount = [SELECT count() FROM CampaignMember WHERE Type = 'Lead' AND Campaignid = :CampName ]; //AND email != ''
    //accList = [SELECT Id, Lead.Name, Email,FirstName ,LastName, Type FROM CampaignMember WHERE Type = 'Contact' AND email != '' AND Campaignid = :CampName ]; 
    AccCount = [SELECT count() FROM CampaignMember WHERE Type = 'Contact' AND Campaignid = :CampName ]; //AND email != ''
   // System.debug(lstSendMailLead.size());
    OppCount = [SELECT count() FROM CampaignMember WHERE Type = 'Contact' AND email != '' AND Campaignid = :CampName ];
              
    }
    
    public PageReference sendMassEmailLead(){ 
        System.debug('Inside sendMassEmailLead:::::::');
        batchStatusBool = false;
        try{
            System.debug(' CampName:::::::::::' + CampName);
            batchId = SendBulkLeadManagementServices.SendBulkLeadBatch(CampName);   //templateName   
            batchStatusBool = true;
            checkBatchStatus();
        }catch(Exception ex){
            system.debug('Failed: exception'+ex.getMessage());
        } 
        return null;
    }
    /*
    public PageReference sendMassSMS(){ 
        System.debug('inside sendMassSMS method:::::::::::::');
        System.debug(' CampName:::::::::::' + CampName);
        strError = '';
       // if(!test.isRunningTest()){}
       if (campName == null || campName == '') {
                strError = 'Please select Campaign.';
                return null;
            } 
        System.debug('inside sendMassSMS method:::::::::::::111111');
         if (SMStempName == null || SMStempName == '') {
                strError = 'Please select SMS Template.';
                return null;
            }
        System.debug('inside sendMassSMS method:::::::::::::2222222');
        if(SMStempName == null || SMStempName == ''){
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Please select SMS Template.'));
        } 
        smsaccountid=new List<Id>();
        batchStatusBool = false;
        lstSendSMS = [Select Id, Name, Contact.Account.PersonMobilePhone  From CampaignMember Where Campaignid = :CampName ];
        System.debug('PersonMobilePhone:::::::::::::'+lstSendSMS[0].Contact.Account.PersonMobilePhone );
        System.debug('lstSendSMS:::::::::::::'+lstSendSMS);
        for(CampaignMember cm : lstSendSMS){
            If(cm.Contact.Account.PersonMobilePhone != null){
                smsaccountid.add(cm.Id);  
           }
            System.debug('smsaccountid:::::::::::::'+smsaccountid);
        }
        try{
            if(SMStempName != 'null'){
                if(smsaccountid.size() >0){
                    SendSMSbatch obj=new SendSMSbatch(smsaccountid, SMStempName);
                    System.debug('smsaccountid:::::::::::::'+smsaccountid);
                    System.debug('SMStempName:::::::::::::::'+SMStempName);
                    Database.executeBatch(obj,5);
                    ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'SMS Sent Successfully.Thank you!'));
                }
            }
        }catch(Exception ex){
            system.debug('Failed: exception'+ex.getMessage());
        } 
        return null;
    }
    */
    public void checkBatchStatus() {
        pollerBool = false;
        AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE Id =: batchId];
        batchStatus = job.Status;
        if(batchStatus == 'Completed') {
            pollerBool = false;
            batchStatusBool = false;
            showsavepopup = true;
        } else {
            pollerBool = true;
        }
    }
}