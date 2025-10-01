global class SAPCancellationScheduled implements Schedulable {
   
   global void execute(SchedulableContext sc) {
        //Get Previous Fire Time of this Scheduled Job and Time when this Job started
      /*  CronTrigger ct = [SELECT PreviousFireTime, startTime,NextFireTime
                           FROM CronTrigger WHERE Id = :sc.getTriggerId()];
        
        dateTime endTime;
        System.debug('Cron job:' + ct);
       
        if(ct != null) {
            if(ct.NextFireTime != null)
                endTime = ct.NextFireTime.addMinutes(-60);    
            
        } else {
            endTime = DateTime.now();
        }
        Database.executeBatch(new SAPCancellationBatch (endTime),1);*/
   }
    
}