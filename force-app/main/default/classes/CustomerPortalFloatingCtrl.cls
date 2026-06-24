public class CustomerPortalFloatingCtrl{
     @AuraEnabled
    public static list<RW_Runwal_Event__c> lstFetchRunwalEvnts(){
        return [SELECT Id,RW_Event_Details__c,RW_Scroller_Subject__c,RW_Start_Date__c,RW_End_Date__c FROM RW_Runwal_Event__c];     
        
    } 

}