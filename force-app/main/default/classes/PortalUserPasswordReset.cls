public class PortalUserPasswordReset {
    
    
   /* @AuraEnabled
    public static void resetPassword(String oppId){

        List<Opportunity> oppList = [SELECT Id, AccountId FROM Opportunity WHERE Id =: oppId];
        if(oppList[0].AccountId != null){
            User usr = [SELECT Id FROM User WHERE AccountId =: oppList[0].AccountId];
            if(usr != null){
                //resetPassword(Id userId, Boolean sendUserEmail);
                System.resetPassword(usr.Id, true);
            }
        }
    }*/
    
    @AuraEnabled
    public static void resetPassword(String oppId){

        List<Opportunity> oppList = [SELECT Id, AccountId, Account.Portal_User__c FROM Opportunity WHERE Id =: oppId];
        if(oppList[0].Account.Portal_User__c != null){
            User usr = [SELECT Id FROM User WHERE Id =: oppList[0].Account.Portal_User__c];
            if(usr != null){
                //resetPassword(Id userId, Boolean sendUserEmail);
                System.resetPassword(usr.Id, true);
            }
        }
    }

}