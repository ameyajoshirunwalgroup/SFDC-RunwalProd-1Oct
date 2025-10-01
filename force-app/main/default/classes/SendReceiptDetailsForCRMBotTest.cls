@isTest
public class SendReceiptDetailsForCRMBotTest {
	@testSetup
    static void setup(){
        profile p = [SELECT Id FROM Profile Where Name = 'Standard User'];   
        User testUser = new User(Alias ='test', Email='testuser1@example.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
            UserName='testuser00117@example.com');
        insert testUser;
        Opportunity opp = new Opportunity(
        	Name = 'Test Opportunity',
        	CloseDate = Date.today().addDays(30),
        	StageName = 'Prospecting',
        	RW_Email__c ='test@example.com',
            RW_Mobile_No__c = '5544332212'
        	);
            insert opp;
        Project__c testProject= new Project__c(
            Name= 'Test Project', 
            RW_Project_Code__c='12');
        insert testProject; 
        Relationship_Manager__c testRmanager= new Relationship_Manager__c(Name = 'Testuser',OwnerId = testUser.Id );
        insert testRmanager;
        //Create a record
        Project_Unit__c testUnit = new Project_Unit__c(
            Name = 'Test Unit',
            RW_Unit_Status__c='Available',
            RW_Param1__c= 'test param',
            Relationship_Manager__c = testRmanager.Id,
            RW_Project__c = testProject.id);
        insert testUnit;
        // Create a Booking__c record
        Booking__c booking = new Booking__c(
        Opportunity__c = opp.Id,
        Project__c = testProject.Id,
        Unit_No__c = testUnit.Id,
         OwnerId = testUser.Id);
        insert booking;
        
        // Create a RW_Payment_Details__c record
        RW_Payment_Details__c payment1 = new RW_Payment_Details__c(
            RW_Booking__c = booking.Id,
            Send_Receipt_Letter__c = true
        );
        insert payment1;

        // Create additional RW_Payment_Details__c records for testing last 3 receipts
        RW_Payment_Details__c payment2 = new RW_Payment_Details__c(
          RW_Booking__c = booking.Id,
            Send_Receipt_Letter__c = true
        );
        insert payment2;

        RW_Payment_Details__c payment3 = new RW_Payment_Details__c(
           RW_Booking__c = booking.Id,
            Send_Receipt_Letter__c = true
        );
        insert payment3;
    }

    @isTest
    static void testLast3ReceiptLetter() {
        // Retrieve the RW_Payment_Details__c records
        List<RW_Payment_Details__c> payments = [SELECT Id FROM RW_Payment_Details__c LIMIT 3];
        
        // Create a list of receipt IDs for testing
        List<String> receiptIds = new List<String>();
        for (RW_Payment_Details__c payment : payments) {
            receiptIds.add(payment.Id);
        }
        
        // Create instance of SendReceiptDetailsForCRMBot and enqueue it
        SendReceiptDetailsForCRMBot sendReceiptBot = new SendReceiptDetailsForCRMBot(receiptIds);
        
        Test.startTest();
        System.enqueueJob(sendReceiptBot);
        Test.stopTest();

        // Verify Task creation
        /*List<Task> tasks = [SELECT Subject, Status FROM Task WHERE Subject = 'Last 3 Payment Receipts'];
        System.assert(tasks.size() > 0, 'Expected task for last 3 receipts');
        System.assertEquals('Completed', tasks[0].Status, 'Task should be completed');*/
        
        // Verify updated RW_Payment_Details__c records
        /*List<RW_Payment_Details__c> updatedPayments = [SELECT Send_Receipt_Letter__c FROM RW_Payment_Details__c];
        for (RW_Payment_Details__c payment : updatedPayments) {
            System.assertEquals(false, payment.Send_Receipt_Letter__c, 'Receipt letters should be marked as sent');
        }*/
    }

    @isTest
    static void testLatestReceiptLetter() {
        // Retrieve a single RW_Payment_Details__c record
        RW_Payment_Details__c payment = [SELECT Id FROM RW_Payment_Details__c LIMIT 1];
        
        // Create a list with only one receipt ID for testing the latest receipt scenario
        List<String> receiptIds = new List<String>{ payment.Id };
        
        // Create instance of SendReceiptDetailsForCRMBot and enqueue it
        SendReceiptDetailsForCRMBot sendReceiptBot = new SendReceiptDetailsForCRMBot(receiptIds);
        
        Test.startTest();
        System.enqueueJob(sendReceiptBot);
        Test.stopTest();
        
        // Verify Task creation
        List<Task> tasks = [SELECT Subject, Status FROM Task WHERE Subject = 'Latest Payment Receipt'];
        System.assert(tasks.size() > 0, 'Expected task for latest receipt');
        System.assertEquals('Completed', tasks[0].Status, 'Task should be completed');
        
        // Verify updated RW_Payment_Details__c record
        RW_Payment_Details__c updatedPayment = [SELECT Send_Receipt_Letter__c FROM RW_Payment_Details__c WHERE Id = :payment.Id];
        System.assertEquals(false, updatedPayment.Send_Receipt_Letter__c, 'Receipt letter should be marked as sent');
    }          
}