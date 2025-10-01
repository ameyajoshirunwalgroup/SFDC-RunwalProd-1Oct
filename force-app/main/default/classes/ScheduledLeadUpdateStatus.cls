global class ScheduledLeadUpdateStatus implements Schedulable
{
     global void execute(SchedulableContext sc) 
     {
        Batch_UpdateLeadStatus b = new Batch_UpdateLeadStatus(); 
        database.executebatch(b);
     }
      
}