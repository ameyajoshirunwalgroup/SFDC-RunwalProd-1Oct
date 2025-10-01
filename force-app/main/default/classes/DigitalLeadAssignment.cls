public class DigitalLeadAssignment implements Queueable, Database.allowscallouts{

    public List<Id> leadIds;
    public DigitalLeadAssignment(List<Id> leadIds){
        system.debug('leadIds>>>' +leadIds);
        this.leadIds = leadIds;
        
    }
    public void execute(QueueableContext context){
        GetCurrentLoggedInAgents.getAgentsDetailsForBatch(leadIds);
    }
}