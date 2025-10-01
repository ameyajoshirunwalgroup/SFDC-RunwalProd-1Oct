public class PossessionReconciliationController {

    public static void afterInsert(List<Possession_Reconciliation__c> prs){
        Possession_Reconciliation__c pr = prs[0];
        List<String> towers = pr.Towers__c.split(',');
        String days = prs[0].Scheduling_Days__c.replace(';',',');
		List<String> times = pr.Scheduling_Time__c.split(':');
        //PossessionReconciliationEmail apexSch = new PossessionReconciliationEmail(pr.Project__c, towers, pr.Start_Date1__c, pr.End_Date__c, pr.Booking_Status__c, pr.Email_Template__c); 
        PossessionReconciliationEmail apexSch = new PossessionReconciliationEmail(pr);
        //Seconds, Minutes, Hours, Day of month, Month, Day of week, Optional year 
        String CRON_EXP = '0 ' + ' ' + times[1] + ' ' + times[0] + ' ? * ' + days;
        if(!Test.isRunningTest()){
            String jobID = System.schedule('PossessionReconciliationEmail- ' + pr.Project__c, CRON_EXP, apexSch); 
        }else{
            String jobID = System.schedule('PossessionReconciliationEmail- ' + pr.Project__c, CRON_EXP, apexSch); 
        }
        
    }
    
    public static void afterUpdate(List<Possession_Reconciliation__c> prs){
        Possession_Reconciliation__c pr = prs[0];
        List<String> towers = pr.Towers__c.split(',');
        String days = prs[0].Scheduling_Days__c.replace(';',',');
		List<String> times = pr.Scheduling_Time__c.split(':');
        String jobName = 'PossessionReconciliationEmail- ' + pr.Project__c;
        List<CronTrigger> jobRecord = [SELECT  Id FROM CronTrigger  where CronJobDetail.Name =: jobName];
        if(jobRecord.size()>0){
            System.abortJob(jobRecord[0].Id);
        }
        String project = pr.Project__c;
        String bookingStatus = pr.Booking_Status__c;
        //PossessionReconciliationEmail apexSch = new PossessionReconciliationEmail(pr.Project__c, towers, pr.Start_Date1__c, pr.End_Date__c, pr.Booking_Status__c, pr.Email_Template__c); 
        PossessionReconciliationEmail apexSch = new PossessionReconciliationEmail(pr); 
        //Seconds, Minutes, Hours, Day of month, Month, Day of week, Optional year 
        String CRON_EXP = '0 ' + ' ' + times[1] + ' ' + times[0] + ' ? * ' + days;
        if(!Test.isRunningTest()){
            String jobID = System.schedule('PossessionReconciliationEmail- ' + pr.Project__c, CRON_EXP, apexSch);
        }else{
            String jobID = System.schedule('PossessionReconciliationEmail- ' + pr.Project__c, CRON_EXP, apexSch);
        }
         
    }
    
    public static void afterDelete(String name){
        List<CronTrigger> jobRecord = [SELECT  Id FROM CronTrigger  where CronJobDetail.Name =: name];
        if(jobRecord.size()>0){
            System.abortJob(jobRecord[0].Id);
        }
    }
     

}