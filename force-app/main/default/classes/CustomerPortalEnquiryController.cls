public class CustomerPortalEnquiryController {
    
    @AuraEnabled
    public static CustomerPortalEnquiryWrapper getEnquiryRecords(){
        
        List<String> ProjectNames = new List<String>();
        CustomerPortalEnquiryWrapper enquiryWrap = new CustomerPortalEnquiryWrapper();
        List<Project__c> projects = [Select Id,Name from Project__c];
        for(Project__c projRec : projects){
            CustomerPortalEnquiryWrapper.projects projDetails = new CustomerPortalEnquiryWrapper.projects();
            projDetails.projId=projRec.Id;
            projDetails.projName=projRec.Name;
            enquiryWrap.projectNames.add(projDetails);
        }
        
        List<User> u = [SELECT Name,AccountId FROM User WHERE Id = :UserInfo.getUserId()];
        if(!u.isEmpty()){
            Id accountId = u[0].AccountId; 
            Account accrecord = [Select Id,Name,FirstName,LastName,Mobile_No__c,PersonEmail from Account Where id=:accountId];
            enquiryWrap.firstName = accrecord.FirstName;
            enquiryWrap.lastName = accrecord.LastName;
            enquiryWrap.phone = accrecord.Mobile_No__c;
            enquiryWrap.emailId = accrecord.PersonEmail;
            
            //enqwrapDetails.leadStatus = referrals.RW_Status__c;
            
            
        }
        return enquiryWrap;
    }
    @AuraEnabled
    public static void insertReferral(RW_Referral__c newReferral){
        // RW_Referral__c newRef = new RW_Referral__c();
        //newRef = newReferral;
        List<User> u = [SELECT Name, AccountId FROM User WHERE Id = :UserInfo.getUserId()];
        if(!u.isEmpty()) {
            Id accountId = u[0].AccountId; 
            newReferral.RW_Mode__c = 'Customer portal';
            newReferral.Account__c =  accountId;              
        }
        insert newReferral;
    }
    
}