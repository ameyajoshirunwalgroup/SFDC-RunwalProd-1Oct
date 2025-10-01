global class ScheduleBatchforReminderTaskCreation implements Schedulable {
    global void execute(SchedulableContext sc) {
        BatchforReminderTaskCreation b1 = new BatchforReminderTaskCreation();
        Database.executeBatch(b1, 50); 
    }
}