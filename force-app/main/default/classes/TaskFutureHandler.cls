public class TaskFutureHandler {
    @future
    public static void createDigitalTasks(Set<Id> leadIds) {
        // Query Leads again from Ids
        System.debug('insidefuture');
        List<Lead> leads = [SELECT Id, Name, Primary_Mobile_No_with_code__c, Development__c, Vertical__c, RW_Broker__c, LeadSource,lastName
                            FROM Lead 
                            WHERE Id IN :leadIds];

        Map<Id, Lead> leadMap = new Map<Id, Lead>();
        for (Lead l : leads) {
            leadMap.put(l.Id, l);
        }
       System.debug('Lead map'+leadMap);
        // Call your original method
        try {
            TaskManagementServices.createTaskforEnquiries(leadMap);
        } catch (Exception ex) {
            System.debug('Failed to create task in future method: ' + ex.getMessage());
        }
    }
}