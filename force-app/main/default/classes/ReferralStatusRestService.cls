@RestResource(urlMapping='/ReferralStatus/*')
global with sharing class ReferralStatusRestService {
	@HttpGet
    global static ReferralWithProjNames doGet(){
        List<CustomerPortalReferral> referralDetails = new List<CustomerPortalReferral>();
        ReferralWithProjNames refDetailsWithProjNames = new ReferralWithProjNames();
        List<String> prjNames = new List<String>();
        List<Project__c> projects = [Select Id,Name,RW_Status__c from Project__c WHERE RW_Status__c = 'Active'];
        for(Project__c projRec : projects){
            prjNames.add(projRec.Name);
        }
        RestRequest req = RestContext.request;
        String accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        List<RW_Referral__c> referralRecords = [SELECT id,Name,RW_First_Name__c,RW_Last_Name__c,RW_Project__c,RW_Status__c 
                                                FROM RW_Referral__c WHERE Account__c=:accountId];
        for(RW_Referral__c referral : referralRecords){
            CustomerPortalReferral refDetails = new CustomerPortalReferral();
            refDetails.firstName = referral.RW_First_Name__c;
            refDetails.lastName = referral.RW_Last_Name__c;
            refDetails.project = referral.RW_Project__c;
            refDetails.leadStatus = referral.RW_Status__c;
            
            referralDetails.add(refDetails);
            
        }
        refDetailsWithProjNames.referrals = referralDetails;
        refDetailsWithProjNames.projectNames = prjNames;
        return refDetailsWithProjNames;
    }
    
    @HttpPost
    global static void doPost(String firstName, String lastName, String phone, String email, String project, String accountId, String description){
        System.debug('project: ' + project);
        System.debug('phone: ' + phone);
        System.debug('accountId: ' + accountId);
        System.debug('firstName: ' + firstName);
        System.debug('lastName: ' + lastName);
        System.debug('email: ' + email);
        System.debug('description: ' + description);
        RW_Referral__c ref = new RW_Referral__c();
        List<RW_Referral__c> refRecord = [SELECT id,RW_Contact_Phone__c,RW_Project__c FROM RW_Referral__c 
                                          WHERE RW_Project__c =: project AND 
                                          RW_Contact_Phone__c =: phone];
       if(refRecord != null && refRecord.size() > 0){
           //throw new AurahandledException(Label.Referral_Error_Message);
           RestResponse res = RestContext.response;
       	   res.statusCode = 500;
           res.responseBody = Blob.valueOf(Label.Referral_Error_Message);
           //return Label.Referral_Error_Message;
       }else{
           ref.RW_First_Name__c = firstName;
           ref.RW_Last_Name__c = lastName;
           ref.RW_Project__c = project;
           ref.Account__c = accountId;
           ref.RW_Email_Address__c = email;
           ref.RW_Contact_Phone__c = phone;
           ref.RW_Mode__c ='Customer portal';
           List<Opportunity> oppRecs = [SELECT id,Name,RW_Project_Unit__c FROM Opportunity WHERE 
                                        AccountId = :accountId AND StageName = 'Unit Booked'];
           if(oppRecs != null && oppRecs.size() >0){
               if( oppRecs[0].RW_Project_Unit__c != null)
               {
                   ref.Project_Unit__c = oppRecs[0].RW_Project_Unit__c;
               }
           }
           insert ref;
       }
    }
    
    global class CustomerPortalReferral{
        public String firstName;
        public String lastName;
        public String project;
        public String leadStatus;
        
    }
    global class ReferralWithProjNames{
        public List<String> projectNames;
        public List<CustomerPortalReferral> referrals;
    }
}