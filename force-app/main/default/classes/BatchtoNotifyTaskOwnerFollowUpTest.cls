@isTest
public  Class BatchtoNotifyTaskOwnerFollowUpTest {
    @isTest  
    static void TaskTest() {
    Project__c p = TestDataFactory.createProject('Xanadu_prj','111');
        Account acc = TestDataFactory.createPATemplate('TestPA1' , 'testleada@ozonetest.com', '9876544441', false);
       // List<Opportunity>  oList = New List<Opportunity>();
        List<Lead> llist = TestDataFactory.createLead(3);
        // List<Opportunity>  oList = TestDataFactory.createOpptyForAccount(acc.Id, p.Id, 2);
        Id SalesTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Sales Task').getRecordTypeId();
        Task task = new Task(
            Subject = 'Visit Follow Up - Auto',
            Status = 'Not Started',
            Priority = 'Normal',
            ActivityDate = Date.today().addDays(-5),
            Next_Action_Date__c = Date.today(),
            RecordTypeId = SalesTaskRecordTypeId
        );
        insert task;
        
        
        Test.startTest(); 
        BatchtoNotifyTaskOwnerFollowUp  bb = new BatchtoNotifyTaskOwnerFollowUp();
        Database.executeBatch(bb,50);
        BatchtoNotifyTaskOwnerFollowUp.callBatchtoNotifyTaskOwnerFollowUp();
        Test.stopTest();
 
  }
}