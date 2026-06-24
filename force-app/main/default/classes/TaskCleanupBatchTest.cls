@isTest
public class TaskCleanupBatchTest {
    @isTest
    public static void testBatch(){
        Lead leadObj = new Lead(
            LastName ='Agrawal',
            Email = 'ad@gm.com',
            RW_Mobile_No__c ='7876454552'
        );
        insert leadObj;
        Task taskObj = new Task(
            Subject = 'Target Task',
            whoId = leadObj.Id,
            Communication_Type__c = 'Outbound Call',
            Task_Type__c = 'Presales Call',
            Status = 'Completed'
            
        );
        insert taskObj;
        Test.setCreatedDate(taskObj.Id, System.now().addMonths(-4));
        Task taskObj1 = [SELECT Id, CreatedDate, LastModifiedDate, Communication_Type__c, Task_Type__c, whoId, who.Type FROM Task WHERE Id = :taskObj.Id];
        System.debug('After Time Travel - Created: ' + taskObj1.CreatedDate + ', Modified: ' + taskObj1.LastModifiedDate);
        TaskCleanupBatch newJob = new TaskCleanupBatch();
        Database.executeBatch(newJob);
        try{
            String cronExp = '0 0 0 15 3 ? 2099';
            System.schedule('Test Task Cleanup', cronExp, new TaskCleanupBatch());
        }catch(Exception ex){
            
        }
        TaskCleanupBatch.dummyData();
    }
}