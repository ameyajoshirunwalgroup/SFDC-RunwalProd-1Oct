global class SAPCPBrkClearingAPIScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {
        System.enqueueJob(new SAPCPBrkClearingAPI());
    }
}