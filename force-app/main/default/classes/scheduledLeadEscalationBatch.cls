global class scheduledLeadEscalationBatch implements Schedulable
{
     global void execute(SchedulableContext sc) 
     {
        Batch_SendEscallationMail b = new Batch_SendEscallationMail(); 
        database.executebatch(b);
     }
}