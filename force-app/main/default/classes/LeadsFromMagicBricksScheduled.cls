global class LeadsFromMagicBricksScheduled implements Schedulable {
    
   global void execute(SchedulableContext sc) {
        //Get Previous Fire Time of this Scheduled Job and Time when this Job started
        CronTrigger ct = [SELECT PreviousFireTime, startTime,NextFireTime
                            FROM CronTrigger WHERE Id = :sc.getTriggerId()];
        dateTime startTime;
        dateTime endTime;
        System.debug('Cron job:' + ct);
       
        if(ct != null) {
            if(ct.previousfireTime != null)
                startTime = ct.previousfireTime.addMinutes(-60);
            if(ct.NextFireTime != null)
                endTime = ct.NextFireTime.addMinutes(-60);    
            
        } else {
            startTime = DateTime.now().addMinutes(-60);
            endTime = DateTime.now();
        }
        System.debug('StartTime:' + startTime + ':EndTime:' + endTime);                    
       
     //Invoke the Batch Job
    //Database.executeBatch(new LeadsFromMagicBricksBatch(ct.PreviousFireTime, ct.StartTime),1);
    //Database.executeBatch(new LeadsFromMagicBricksBatch(ct.PreviousFireTime, ct.NextFireTime),1);
     Database.executeBatch(new LeadsFromMagicBricksBatch(startTime, endTime),1);
     }
}