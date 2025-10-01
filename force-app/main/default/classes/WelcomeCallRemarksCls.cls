public with sharing class WelcomeCallRemarksCls {

    @AuraEnabled
     public static List<RW_Welcome_Call_Remarks__c> wcCallRemarks(string wcObjID){
     
        List<RW_Welcome_Call_Remarks__c> prevCallRemarksList =  [SELECT Id,Name,RW_Welcome_Call__c,RW_Remarks__c, OwnerId,Owner.Name, CreatedDate,
                                                                 CreatedById,CreatedBy.Name, LastModifiedDate, LastModifiedById,LastModifiedBy.Name FROM 
                                                                RW_Welcome_Call_Remarks__c WHERE RW_Welcome_Call__c =: wcObjID ORDER BY CreatedDate DESC];
      system.debug('prevCallRemarksList!!!'+prevCallRemarksList);

  
       return prevCallRemarksList;
      
    }

  
  

}