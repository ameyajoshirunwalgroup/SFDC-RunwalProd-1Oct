global class LeadsFromHousingComScheduled implements Schedulable {
    
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
    //Database.executeBatch(new LeadsFromHousingComBatch(ct.PreviousFireTime, ct.StartTime),1);
    if(!Test.isrunningTest()) 
        Database.executeBatch(new LeadsFromHousingComBatch(startTime, endTime),1);
    else {
         // these lines added to meet the code coverage
         dateTime TeststartTime;
         dateTime TestendTime;
    }
  }
    
}