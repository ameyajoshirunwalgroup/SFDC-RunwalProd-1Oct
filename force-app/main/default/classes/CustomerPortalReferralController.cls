public without sharing class CustomerPortalReferralController{
    @AuraEnabled
    public static CustomerPortalReferralWrapper getReferralRecords(){
		system.debug('Inside getReferralRecords for referral and loyalty__'); 
        List<String> ProjectNames = new List<String>();
        CustomerPortalReferralWrapper refWrap = new CustomerPortalReferralWrapper();
        List<Project__c> projects = [Select Id,Name from Project__c];
        for(Project__c projRec : projects){
            CustomerPortalReferralWrapper.projects projDetails = new CustomerPortalReferralWrapper.projects();
            projDetails.projId=projRec.Id;
            projDetails.projName=projRec.Name;
            refWrap.projectNames.add(projDetails);
        }
        List<User> u = [SELECT Name,AccountId FROM User WHERE Id = :UserInfo.getUserId()];
        if(!u.isEmpty()){
            Id accountId = u[0].AccountId; 
            List<RW_Referral__c> referralRecords = [Select id,Name,RW_First_Name__c,RW_Last_Name__c,RW_Project__c,RW_Status__c from RW_Referral__c Where Account__c=:accountId Order by CreatedDate Desc];
            for(RW_Referral__c referrals : referralRecords){
                CustomerPortalReferralWrapper.referralWrapper refwrapDetails = new CustomerPortalReferralWrapper.referralWrapper();
                refwrapDetails.firstName = referrals.RW_First_Name__c;
                refwrapDetails.lastName = referrals.RW_Last_Name__c;
                refwrapDetails.project = referrals.RW_Project__c;
                refwrapDetails.leadStatus = referrals.RW_Status__c;
                refWrap.referralRecords.add(refwrapDetails);
            }
        }
        return refWrap;
    }
    
    @AuraEnabled
    public static void insertReferral(RW_Referral__c newReferral){
        List<RW_Referral__c> refRecord = [Select id,RW_Contact_Phone__c,RW_Project__c from RW_Referral__c Where  RW_Project__c =:newReferral.RW_Project__c and RW_Contact_Phone__c =:newReferral.RW_Contact_Phone__c];
        if(refRecord != null && refRecord.size() > 0){
            throw new AurahandledException(Label.Referral_Error_Message);
        }else{
            List<User> u = [SELECT Name,AccountId FROM User WHERE Id = :UserInfo.getUserId()]; 
            if(!u.isEmpty()){
                Id accountId = u[0].AccountId; 
                newReferral.Account__c =  accountId;  
                List<Opportunity> oppRecs = [Select id,Name,RW_Project_Unit__c from Opportunity Where AccountId = :accountId and StageName = 'Unit Booked'];
                if(oppRecs != null && oppRecs.size() >0){
                    newReferral.Opportunity__c = oppRecs[0].Id;
                    if( oppRecs[0].RW_Project_Unit__c != null){
                        newReferral.Project_Unit__c = oppRecs[0].RW_Project_Unit__c;
                    }
                }
            }
            newReferral.RW_Mode__c ='Customer portal';
            insert newReferral;
        }
    }
}