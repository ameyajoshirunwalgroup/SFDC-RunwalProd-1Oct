public class RunBrokerageBatchQueueable implements Queueable {
    Set<Id> cpIds;
    Set<Id> schemeIds;
    
    public RunBrokerageBatchQueueable(Set<Id> cpIds, Set<Id> schemeIds) {
        this.cpIds = cpIds;
        this.schemeIds = schemeIds;
    }
 
    public void execute(QueueableContext qc) {
         system.debug('Inside Queueable method----'+cpIds+'  '+schemeIds); 
        
        Database.executeBatch(new BatchBrokerageLadderCreation(cpIds, schemeIds), 1);
    }
}