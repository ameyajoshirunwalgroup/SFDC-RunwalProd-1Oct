@isTest
public class CreateWelcomeCallForSoReleasedBkgsTest {
    @testSetup
    static void setupTestData() {
        
        // Create related data for Booking__c
        User testRM = new User(
            Alias = 'testRM',
            Email = 'testrm@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Manager',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testrmuser@example.com'
        );
        insert testRM;
        
        Account testAccount = new Account(
            Name = 'Test Account'
        );
        insert testAccount;
        
        // Create Opportunity with Booking reference
        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            SAP_Customer_Number__c = 'SAP123456',
            SalesOrder_Number__c = 'SO123456',
            RW_Mobile_No__c = '126454211',
        	RW_Email__c = 'test231176357431@gmail.com',
            AccountId = testAccount.Id
        );
        insert testOpp;
        
        // Create Project
        Project__c testProject = new Project__c(
            Name = 'Test Project',
            Sales_Order_Release_Intimation__c = 'team@example.com'
        );
        insert testProject;
        
        
        
        Tower__c t = new Tower__c(
            Name = 'TestTOwr',
            Welcome_Call_CC_Email_1__c = 'cc1@example.com',
            Welcome_Call_CC_Email_2__c = 'cc2@example.com',
            ProjectName__c = testProject.Id
        );
        insert t; 
        
        // Create Relationship Manager
        Relationship_Manager__c testRMObj = new Relationship_Manager__c(
            Name = 'Test RM',
            User__c = testRM.Id,
            Project__c = testProject.Id,
            Tower__c = t.Id
        );
        insert testRMObj;
        
        // Create Unit
        Project_Unit__c testUnit = new Project_Unit__c(
            Name = 'Test Unnt',
            Relationship_Manager__c = testRMObj.Id,
            TowerName__c= t.Id,
            RW_Project__c = testProject.Id,
            RW_Param1__c = '5',
        UnitNo__c ='10'

        );
        insert testUnit;
        
        // Create Booking
        Booking__c testBooking = new Booking__c(
            Unit_No__c = testUnit.Id,
            Wing__c = 'A',
            Flat_No__c = '101',
            Project__c = testProject.Id,
            Opportunity__c = testOpp.Id
        );
        insert testBooking;
    }
    
    @isTest
    static void testCreateWelcomeCall() {
        // Retrieve test data
        List<Booking__c> bookings = [SELECT Id, Name FROM Booking__c];
        
        // Execute the method
        Test.startTest();
        CreateWelcomeCallForSoReleasedBkgs.createWelcomeCall(bookings);
        Test.stopTest();
        
        // Assert Welcome Call records are created
        List<RW_Welcome_Call__c> welcomeCalls = [SELECT Id, Booking_Id__c FROM RW_Welcome_Call__c];
        System.assertEquals(bookings.size(), welcomeCalls.size(), 'Welcome calls should be created for all bookings.');
        
        // Assert Task records are created
        /*List<Task> tasks = [SELECT Id, Subject, RecordTypeId FROM Task];
        System.assert(tasks.size() > 0, 'Tasks should be created.');
        System.assertEquals('Welcome Call', tasks[0].Subject, 'Task subject should match the expected value.');*/
    }
    
    @isTest
    static void testCreateWelcomeCallTask() {
        // Retrieve booking IDs
        List<String> bookingIds = new List<String>();
        for (Booking__c booking : [SELECT Id FROM Booking__c]) {
            bookingIds.add(booking.Id);
        }
        
        // Execute the method
        Test.startTest();
        CreateWelcomeCallForSoReleasedBkgs.createWelcomeCallTask(bookingIds);
        Test.stopTest();
        
        // Assert Email and Task are sent/created
        /*List<Task> tasks = [SELECT Id, Subject, OwnerId FROM Task];
        System.assert(tasks.size() > 0, 'Tasks should have been created.');
        System.assertEquals('Welcome Call', tasks[0].Subject, 'The Task Subject should match.');*/
    }
    
}