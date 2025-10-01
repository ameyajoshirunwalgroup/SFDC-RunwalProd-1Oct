global class SendRMDetailsBatchSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        SendRMDetailsBatch batchJob = new SendRMDetailsBatch();
        Database.executeBatch(batchJob, 1000);
    }
}