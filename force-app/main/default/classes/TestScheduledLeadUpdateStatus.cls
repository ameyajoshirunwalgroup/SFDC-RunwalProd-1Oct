@isTest
public class TestScheduledLeadUpdateStatus
{
    static testMethod void UpdateLeadStatus() 
    {
        SchedulableContext sc;
        ScheduledLeadUpdateStatus objClass = new ScheduledLeadUpdateStatus();
        objClass.execute(sc);
    }
}