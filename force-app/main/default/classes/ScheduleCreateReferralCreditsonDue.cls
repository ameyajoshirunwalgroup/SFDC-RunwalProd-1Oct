global class ScheduleCreateReferralCreditsonDue implements Schedulable {
    
     global void execute(SchedulableContext sc)
    {
        //ReferedLeadCreation refLC = new ReferedLeadCreation();
        CreateReferralCreditsonDue job = new CreateReferralCreditsonDue();
        Database.executeBatch(job, 20);
        
    }

}