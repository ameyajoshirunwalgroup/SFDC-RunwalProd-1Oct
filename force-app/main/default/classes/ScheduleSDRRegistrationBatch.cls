global class ScheduleSDRRegistrationBatch implements Schedulable
{
     global void execute(SchedulableContext sc) 
    {
        SendSDRNotificationBatch sdr = new SendSDRNotificationBatch();
        Database.executeBatch(sdr);
        
       // SendRegistrationNotificationBatch rg = new SendRegistrationNotificationBatch();
       // Database.executeBatch(new SendRegistrationNotificationBatch());
       // Database.executeBatch(rg);
    }
    
}