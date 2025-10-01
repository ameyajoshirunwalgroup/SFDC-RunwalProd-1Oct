global class ScheduleBatchforP1toP4CategoryCreation implements Schedulable {
    global void execute(SchedulableContext sc) {
        Integer currentYear = Date.today().year();
        System.debug('Executing batch for financial year: ' + currentYear);        

        BatchforP1toP4CategoryCreation batchJob = new BatchforP1toP4CategoryCreation(currentYear);
        Database.executeBatch(batchJob, 100);
    }
}