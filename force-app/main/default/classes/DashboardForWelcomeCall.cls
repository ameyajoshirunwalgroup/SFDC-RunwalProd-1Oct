public class DashboardForWelcomeCall{
    @AuraEnabled
    public static List <Booking__c> fetchBookingData(){
        
        List<Booking__c> bkList = [SELECT Id,Name,Opportunity__r.Name,Project__r.Name,Primary_Applicant_Email__c,Status__c,Primary_Applicant_Name__c,Unit_No__r.Relationship_Manager__r.RM_Name__c,(SELECT Id,Name,RW_Welcome_Call_Status__c,Welcome_Call_Pending__c,CreatedDate From Welcome_Calls__r) 
                                   FROM Booking__c WHERE Status__c ='Booking Confirmed' AND Unit_No__r.Relationship_Manager__r.User__c =:UserInfo.getUserId()];
        // AND Unit_No__r.Relationship_Manager__r.User__r.id =:UserInfo.getUserId()
        //system.debug('bkList '+bkList[0].Welcome_Calls__r.size());  // WHERE RW_Welcome_Call_Status__c != 'Accept' ORDER BY CreatedDate DESC limit 1
        
        return bkList;
        
    }
    
}