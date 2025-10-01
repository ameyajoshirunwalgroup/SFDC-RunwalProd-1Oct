global class ScheduleBatchforAOPSchemeTagging implements Schedulable {
    global void execute(SchedulableContext sc) {
        BatchforAOPSchemeTagging  bb = new BatchforAOPSchemeTagging();
        Database.executeBatch(bb,50);
    }
}