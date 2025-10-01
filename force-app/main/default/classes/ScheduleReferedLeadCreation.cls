global class ScheduleReferedLeadCreation implements Schedulable {
    
     global void execute(SchedulableContext sc)
    {
        //ReferedLeadCreation refLC = new ReferedLeadCreation();
        ReferralLeadCreation refLC = new ReferralLeadCreation(new List<String>{});
        database.executeBatch(refLC,1);
        
    }

}