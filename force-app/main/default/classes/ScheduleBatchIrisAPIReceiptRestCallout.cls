public class ScheduleBatchIrisAPIReceiptRestCallout implements Schedulable 
{
 	Integer batchsize;
    public  ScheduleBatchIrisAPIReceiptRestCallout(integer batch)
    {
        this.batchsize=batch;
    }
    
    public void execute(SchedulableContext sch)
    {
        BatchIrisAPIReceiptRestCallout batch = new BatchIrisAPIReceiptRestCallout();
        Database.executeBatch(batch,batchsize);
    }
}