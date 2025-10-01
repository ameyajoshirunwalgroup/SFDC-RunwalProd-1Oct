public class ScheduleLedgerAPI implements schedulable
{
    public void execute(SchedulableContext sc)
    {
         //SAPInterestLedgerAPICallOut.getLedger(System.now().format('yyyyMMddHHmmss'));
         /*SAPInterestLedgerAPICallOutBatch cb = new SAPInterestLedgerAPICallOutBatch(System.now().format('yyyyMMddHHmmss')); // Commented by Vinay 10-01-2025
		 database.executeBatch(cb,50);*/
        
         // Added by Vinay 10-01-2025 Start
        SAPInterestLedgerAPICallOutBatch cb1 = new SAPInterestLedgerAPICallOutBatch(System.now().format('yyyyMMddHHmmss'), '6000');
		 database.executeBatch(cb1,25);
        
        SAPInterestLedgerAPICallOutBatch cb2 = new SAPInterestLedgerAPICallOutBatch(System.now().format('yyyyMMddHHmmss'), '1000');
		 database.executeBatch(cb2,25);
        
        SAPInterestLedgerAPICallOutBatch cb3 = new SAPInterestLedgerAPICallOutBatch(System.now().format('yyyyMMddHHmmss'), '3000');
		 database.executeBatch(cb3,25);
        
        SAPInterestLedgerAPICallOutBatch cb4 = new SAPInterestLedgerAPICallOutBatch(System.now().format('yyyyMMddHHmmss'), '1200');
		 database.executeBatch(cb4,25);
        
        SAPInterestLedgerAPICallOutBatch cb5 = new SAPInterestLedgerAPICallOutBatch(System.now().format('yyyyMMddHHmmss'), '8100');
		 database.executeBatch(cb5,25);
        
        SAPInterestLedgerAPICallOutBatch cb6 = new SAPInterestLedgerAPICallOutBatch(System.now().format('yyyyMMddHHmmss'), '2000');
		 database.executeBatch(cb6,25);
        
        SAPInterestLedgerAPICallOutBatch cb7 = new SAPInterestLedgerAPICallOutBatch(System.now().format('yyyyMMddHHmmss'), '8000');
		 database.executeBatch(cb7,25);
         // Added by Vinay 10-01-2025 End

    }
}