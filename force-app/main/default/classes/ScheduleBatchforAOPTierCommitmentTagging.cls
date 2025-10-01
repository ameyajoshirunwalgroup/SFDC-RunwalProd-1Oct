global class ScheduleBatchforAOPTierCommitmentTagging implements Schedulable {
    global void execute(SchedulableContext sc) {
        Integer currentYear = Date.today().year();
        System.debug('Executing batch for financial year: ' + currentYear);        

        BatchforAOPTierCommitmentTagging batchJob = new BatchforAOPTierCommitmentTagging(currentYear);
        Database.executeBatch(batchJob, 20);
    }
}