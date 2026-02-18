/*public class SAPReferralCreditQueueable {
    public Id BI{get;set;}
    public SAPReferralCreditQueueable(Id InvId){
         BI = InvId;
    }
    public void execute(QueueableContext context) {
        
    SAP_Rest_ReferralCreditAPI.sendReferrallist(BI);
        
    }
}*/
public class SAPReferralCreditQueueable implements Queueable {
    public Id BI { get; set; }
    public SAPReferralCreditQueueable(Id invId) {
        BI = invId;
    }

    public void execute(QueueableContext context) {
        // Wrap the single Id in a List<Id>
        SAP_Rest_ReferralCreditAPI.sendReferrallist(new List<Id>{BI});
    }
}