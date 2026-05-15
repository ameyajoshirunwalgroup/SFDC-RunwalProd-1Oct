// Helper Queueable class to continue processing remaining objects
public class ObjectRecordCountContinuation implements Queueable, Database.Stateful {
    private Map<String, Integer> allCounts;
    private List<String> allObjects;
    private Integer startIndex;
    private static final Integer BATCH_SIZE = 90;

    public ObjectRecordCountContinuation(List<String> objs, Map<String, Integer> counts, Integer startIdx) {
        this.allObjects = objs;
        this.allCounts = counts;
        this.startIndex = startIdx;
    }

    public void execute(QueueableContext qc) {
        Integer endIndex = Math.min(startIndex + BATCH_SIZE, allObjects.size());
        for (Integer i = startIndex; i < endIndex; i++) {
            String objName = allObjects[i];
            try {
                Integer count = Database.countQuery('SELECT COUNT() FROM ' + objName);
                allCounts.put(objName, count);
            } catch (Exception e) {}
        }

        if (endIndex < allObjects.size()) {
            System.enqueueJob(new ObjectRecordCountContinuation(allObjects, allCounts, endIndex));
        } else {
            // Final step — write CSV
            String csvData = 'Object API Name,Record Count\n';
            for (String name : allCounts.keySet()) {
                csvData += name + ',' + allCounts.get(name) + '\n';
            }
            ContentVersion cv = new ContentVersion();
            cv.Title = 'All_Object_Record_Counts';
            cv.PathOnClient = 'All_Object_Record_Counts.csv';
            cv.VersionData = Blob.valueOf(csvData);
            cv.IsMajorVersion = true;
            insert cv;

            System.debug('✅ CSV created as Attachment: ' + cv.Id);
        }
    }
}