@isTest
public class ScheduleCallsTriggerTest {
    
    @isTest
    public static void scheduleTest(){
        Scheduled_Call__c sc = new Scheduled_Call__c();
        sc.Schedule_Date__c = Date.today() + 2;
        insert sc;
        
        sc.Schedule_Date__c = Date.today() + 1;
        update sc;
    }

}