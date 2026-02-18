public class DailyObjectCountScheduler implements Schedulable {
    public void execute(SchedulableContext SC) {
        // Batch size of 50 is safe. 
        // If you have massive data volume, reduce to 20 to avoid CPU timeouts.
        Database.executeBatch(new DailyObjectCountBatch(), 50);
    }
}