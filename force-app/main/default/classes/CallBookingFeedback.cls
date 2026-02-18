public class CallBookingFeedback{
    
    @InvocableMethod
    public static void createTaskFromPB (List<ID> ids){
        // system.debug('called from Reject==>'+ids);
        Booking__c bk = [SELECT Id,Wing__c,Flat_No__c,Primary_Applicant_Name__c,Name,Opportunity__c,Unit_No__r.Relationship_Manager__r.RM_Name__c,Unit_No__r.Relationship_Manager__r.User__r.id,Unit_No__r.Relationship_Manager__r.RM_Email__c,Customer__c FROM Booking__c WHERE Id in :ids LIMIT 1];
        
        createBookingFeedback cp = new createBookingFeedback();
        cp.create(bk.Customer__c);
    }
}