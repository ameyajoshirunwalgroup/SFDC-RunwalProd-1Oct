public class GreetingCallTriggerHandler {
    public static void ownerChanges(List<Greeting_Call__c> greetingCallList) {
        // 1. Collect all Opportunity IDs from the incoming records
        Set<Id> oppIds = new Set<Id>();
        for (Greeting_Call__c gc : greetingCallList) {
            if (gc.Opportunity__c != null) {
                oppIds.add(gc.Opportunity__c);
            }
        }

        if (oppIds.isEmpty()) return;

        // 2. Query the Opportunities and their related Unit/RM data
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([
            SELECT Id, RW_Project__c, RW_Project_Unit__c,
                   RW_Project_Unit__r.Relationship_Manager__r.User__c 
            FROM Opportunity 
            WHERE Id IN :oppIds
        ]);

        // 3. Loop through the trigger records and assign the OwnerId
        for (Greeting_Call__c gc : greetingCallList) {
            if (gc.Opportunity__c != null && oppMap.containsKey(gc.Opportunity__c)) {
                Opportunity parentOpp = oppMap.get(gc.Opportunity__c);
                
                // Check if all levels of the relationship exist
                if (parentOpp.RW_Project__c != null && 
                    parentOpp.RW_Project_Unit__c != null && 
                    parentOpp.RW_Project_Unit__r.Relationship_Manager__r.User__c != null) {
                    
                    // Assign the owner directly (No "update" DML needed in BEFORE trigger)
                    gc.RM_User__c = parentOpp.RW_Project_Unit__r.Relationship_Manager__r.User__c;
                }
            }
        }
    }
}