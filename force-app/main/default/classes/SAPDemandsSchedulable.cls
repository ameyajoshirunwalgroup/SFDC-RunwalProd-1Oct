public class SAPDemandsSchedulable implements schedulable{
   integer batchsize;
    public SAPDemandsSchedulable(integer b){
        this.batchsize=b;
    }
   public void execute(SchedulableContext SC) {
       Datetime d = system.now()-1;
        SAPDemandAPICallOutBatchable bc =new SAPDemandAPICallOutBatchable(d.format('yyyyMMddHHmmss'), null);
Database.executeBatch(bc,batchsize);
        //SAPDemandAPICallOut.getDemands( System.now().format('yyyyMMddHHmmss'));
    }
}