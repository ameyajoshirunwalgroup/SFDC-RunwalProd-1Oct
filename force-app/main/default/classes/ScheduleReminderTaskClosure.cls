global class ScheduleReminderTaskClosure implements Schedulable {
    global void execute(SchedulableContext sc) {
        ReminderTaskClosure.ReminderTaskClosure();
        
        BatchforReminderTaskCloseonCstPayment  bb = new BatchforReminderTaskCloseonCstPayment();
        Database.executeBatch(bb,50);
    }
}