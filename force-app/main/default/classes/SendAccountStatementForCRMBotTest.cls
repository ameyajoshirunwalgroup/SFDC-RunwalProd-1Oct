@isTest
public class SendAccountStatementForCRMBotTest {

    public class MockPDFController implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type','application/json');
            res.setBody(EncodingUtil.base64Encode(Blob.valueOf('Test PDF Content')));
            res.setStatusCode(200);
            return res;
        }
    }
    @isTest
    static void testSendAccountStatementForCRMBot(){
        profile p = [SELECT Id FROM Profile Where Name = 'Standard User'];       
        User testUser = new User(Alias ='test', Email='testuser1@example.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
            UserName='testuser00117@example.com');
        insert testUser;
        
        // Create a test Account and Opportunity
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity',RW_Mobile_No__c = '1222112211', RW_Email__c = 'customer@example.com', StageName = 'Prospecting', CloseDate = System.today(), AccountId = testAccount.Id);
        insert testOpportunity;
        
        Project__c testProject= new Project__c(Name= 'Test Project', RW_Project_Code__c='12');
        insert testProject; 

        Relationship_Manager__c testRmanager= new Relationship_Manager__c(Name = 'Testuser',OwnerId = testUser.Id );
        insert testRmanager;

         Project_Unit__c testUnit = new Project_Unit__c(Name = 'Test Unit',RW_Unit_Status__c='Available',RW_Param1__c= 'test param', Relationship_Manager__c = testRmanager.Id, RW_Project__c = testProject.id);
        insert testUnit;
         System.debug('Project Unit Log:' +testUnit);

        // Create a Booking record
        Booking__c testBooking = new Booking__c(Opportunity__c = testOpportunity.Id, Project__c = testProject.id,Unit_No__c = testUnit.Id, OwnerId = testUser.Id);
        insert testBooking;
        
        // Mock the HTTp Callout
        Test.setMock(HttpCalloutMock.class, new MockPDFController());
        
        // Start Test
        Test.startTest();
        
        // Pass the test Booking Id to the Queueable class
        SendAccountStatementForCRMBot queueableJob = new SendAccountStatementForCRMBot(new List<String>{testBooking.Id});
        
        // Queue the job
        System.enqueueJob(queueableJob);

        // End the test context to simulate the execution of the queued job
        Test.stopTest();
        
        // Assertions: Verify that the Task record is created with the correct details
        List<Task> tasks = [SELECT Subject, Status, WhatId, OwnerId FROM Task WHERE WhatId = :testBooking.Id];
        System.assertEquals(1, tasks.size(), 'One task should have been created');
        System.assertEquals('Account Statement', tasks[0].Subject, 'Task subject should be Account Statement');
        System.assertEquals('Completed', tasks[0].Status, 'Task status should be Completed');
    }
}