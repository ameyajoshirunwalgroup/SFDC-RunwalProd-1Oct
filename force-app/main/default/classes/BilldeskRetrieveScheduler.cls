global with sharing class BilldeskRetrieveScheduler 
implements Schedulable {

    global void execute(SchedulableContext sc) {

        // Run batch with safe batch size
        Database.executeBatch(
            new BilldeskRetrieveTransactionAPI(), 
            20
        );
    }
}