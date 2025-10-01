public class SAPReceiptsSchedulable  implements Schedulable{
   Integer batchsize;
    public  SAPReceiptsSchedulable(integer batch){
        this.batchsize=batch;
    }
    
    public void execute(SchedulableContext SC) {
        
 //       SAPReceiptAPICallOut.getReceipts('20210109101010');// System.now().format('yyyyMMddHHmmss'));
 Datetime d = system.now()-1;
        
SAPReceiptAPICallOutBatch cb = new SAPReceiptAPICallOutBatch(d.format('yyyyMMddHHmmss'));
database.executeBatch(cb,batchsize);

    }
}