@isTest
public class TaskAssignmentToPresalesTest {
    @isTest
    public static  void test1(){
        
        Lead ld = new Lead();
        ld.LastName = 'Test';
        ld.Email = 'test@mail.com';
        ld.RW_Mobile_No__c = '5555555555';
        ld.LeadSource = 'Digital';
        insert ld;
        
        Task t = new Task();
        t.Status = 'Open';
        t.Task_Type__c = 'Enquiry Received';
        t.Subject = 'New Enquiry Received';
        t.WhoId = ld.Id;
        insert t;
        
        TaskAssignmentToPresales.dummyMethod();
        TaskAssignmentToPresales.assign(new List<Task>{t});
    }

}