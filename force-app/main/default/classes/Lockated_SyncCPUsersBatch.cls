public class Lockated_SyncCPUsersBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    // Query all CPs that need syncing
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Adjust the query to target the specific records you need to sync
        return Database.getQueryLocator([
            SELECT Id FROM Broker__c where NAME_FIRST__c!=null AND RW_Email__c!=null AND RW_Mobile_No__c!=null AND NAME_LAST__c!=null
            AND CP_APP_Registration__c = false
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Broker__c> scope) {
        for (Broker__c con : scope) {
            try {
                // Call the service class method created earlier
                Lockated_CreateCP.createCPUser(con.Id);
            } catch (Exception e) {
                System.debug('Batch Execution Error for Contact ' + con.Id + ': ' + e.getMessage());
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Sync process for Lockated CP Users completed.');
        // Optional: Send a mail to Shraddha or Divya once the sync is done
    }
}