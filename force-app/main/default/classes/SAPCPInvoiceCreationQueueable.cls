public class SAPCPInvoiceCreationQueueable implements Queueable, Database.allowscallouts{
    Public set<Id> BI =new set<Id>();
    
    public SAPCPInvoiceCreationQueueable( set<Id> InvId){
        BI = InvId;
    }
    public void execute(QueueableContext context) {
        SAPCPInvoiceCreation.SendReq(BI,false,null);
    }
    
    
}