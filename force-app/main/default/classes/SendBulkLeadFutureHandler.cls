public class SendBulkLeadFutureHandler implements Queueable, Database.AllowsCallouts
{
    public set<id> cmIdSet{get;set;}
    //public String template;

    public SendBulkLeadFutureHandler(set<id> cmIds) // string templateName
    {
        cmIdSet = new set<id>();
        cmIdSet.addAll(cmIds);
        //template = templateName;
    }
    public void execute(QueueableContext queCont)
    {
        SendBulkLeadManagementServices.insertTask(cmIdSet); //template
        SendBulkLeadManagementServices.sendMail(cmIdSet);  //template
    }
    
}