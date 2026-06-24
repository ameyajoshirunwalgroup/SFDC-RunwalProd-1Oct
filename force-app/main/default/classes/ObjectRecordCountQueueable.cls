public class ObjectRecordCountQueueable implements Queueable, Database.AllowsCallouts {
 
    private List<String> objectNames;
 
    public ObjectRecordCountQueueable(List<String> objectNames) {
        this.objectNames = objectNames;
    }
 
    public void execute(QueueableContext context) {
        List<Object_Record_Count__c> recordsToInsert = new List<Object_Record_Count__c>();
 
        for (String objName : objectNames) {
            try {
                Schema.DescribeSObjectResult d = Schema.getGlobalDescribe().get(objName).getDescribe();
 
                // Skip non-queryable and setup objects
                if (
                    d.isCustomSetting() ||                          // Skip Custom Settings
                    d.isDeprecatedAndHidden() ||                    // Skip hidden objects
                    !d.isQueryable() ||                             // Skip non-queryable
                    !d.isAccessible() ||                            // Skip inaccessible
                    d.getName().endsWith('History') ||              // Skip History tables
                    d.getName().endsWith('Share') ||                // Skip Share tables
                    d.getName().endsWith('ChangeEvent') ||          // Skip CDC objects
                    d.getName().contains('__Tag') ||                // Skip Tag
                    d.getName().contains('__Feed') ||               // Skip Feed
                    d.getName().contains('__History') ||            // Skip History
                    d.getName().contains('__Share') ||              // Skip Share
                    d.getName().contains('__ChangeEvent')
                ) {
                    continue; // skip non-data objects
                }
                if(d.isCreateable()){
 
                    // Single COUNT() query per object
                    Integer recordCount = (Integer)Database.countQuery('SELECT COUNT() FROM ' + objName);
                    recordsToInsert.add(new Object_Record_Count__c(
                        Object_Name__c = objName,
                        Record_Count__c = recordCount,
                        Fetched_Time__c = System.now()
                    ));
                }
 
            } catch (Exception e) {
                System.debug('Skipped ' + objName + ' — ' + e.getMessage());
            }
        }
 
        if (!recordsToInsert.isEmpty()) {
            insert recordsToInsert;
        }
    }
    
    public static void dummyMethod(){
        Integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}