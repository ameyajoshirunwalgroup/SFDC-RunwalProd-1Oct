public class SAPCPBrokerageCreationQueueable implements Queueable, Database.allowscallouts{
    Public set<Id> BI =new set<Id>();
    
    public SAPCPBrokerageCreationQueueable( set<Id> InvId){
        BI = InvId;
    }
    public void execute(QueueableContext context) {
        SAPCPBrokerageCreation.SendReq(BI,false,null);
    }
}