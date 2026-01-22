public class DailyObjectCountBatch implements Database.Batchable<String>, Database.Stateful {

    public Iterable<String> start(Database.BatchableContext BC) {
        List<String> objectsToProcess = new List<String>();
        
        // 1. Get all records from the Custom Setting
        // We use .values() to get the list of records
        List<Daily_Object_Config__c> configList = Daily_Object_Config__c.getAll().values();
        
        // 2. Get the Org's Schema to validate that the objects actually exist
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();

        // 3. Loop through the Custom Setting records
        for (Daily_Object_Config__c config : configList) {
            
            // GET THE OBJECT NAME FROM YOUR CUSTOM FIELD
            String objName = config.API_Names__c;

            // Validation: Check if field is not empty AND object exists in Salesforce
            if (String.isNotBlank(objName)) {
                // Trim whitespace just in case (e.g., 'Account ')
                objName = objName.trim(); 
                
                if (globalDescribe.containsKey(objName)) {
                    objectsToProcess.add(objName);
                } else {
                    System.debug('Warning: Object defined in API_Names__c not found in Org: ' + objName);
                }
            }
        }
        
        return objectsToProcess;
    }

    public void execute(Database.BatchableContext BC, List<String> scope) {
        List<Object_Record_Count__c> logsToInsert = new List<Object_Record_Count__c>();
        
        for (String objName : scope) {
            try {
                // Dynamic SOQL to get count
                String query = 'SELECT Count() FROM ' + String.escapeSingleQuotes(objName);
                Integer countVal = Database.countQuery(query);
                
                Object_Record_Count__c log = new Object_Record_Count__c();
                log.Object_Name__c = objName;
                log.Record_Count__c = countVal;
                log.Fetched_Time__c = System.now();
                
                logsToInsert.add(log);
            } catch (Exception e) {
                // Some special objects might throw errors even if queryable.
                // It is best to catch them so the batch doesn't fail.
                System.debug('Error counting ' + objName + ': ' + e.getMessage());
            }
        }
        
        if (!logsToInsert.isEmpty()) {
            insert logsToInsert;
        }
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('Daily Count Batch Finished');
    }
}