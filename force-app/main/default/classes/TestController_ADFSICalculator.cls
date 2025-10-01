@isTest
public class TestController_ADFSICalculator {

    @isTest
    static void testGetProjects() {
        // Step 1: Create test Project with required ADF fields
        Project__c proj = new Project__c(
            Name = 'Test Project',
            RW_Status__c = 'Active',
            ADF_Interest_Rate__c = 5.5,
            ADF_Threshold_Amount__c = 10000
        );
        insert proj;

        // Step 2: Create Booking with above Project
        Booking__c booking = new Booking__c(
            Project__c = proj.Id
        );
        insert booking;

        Test.startTest();
            // Step 3: Call the method with test booking Id
            List<Controller_ADFSICalculator.WrapperADF> result = Controller_ADFSICalculator.GetProjects(booking.Id, 3999.49);
        Test.stopTest();

        
    }

    @isTest
    static void testGetProjects_NoMatch() {
        // Create a project that does NOT match criteria (e.g., Inactive and NULL values)
        Project__c proj = new Project__c(
            Name = 'Inactive Project',
            RW_Status__c = 'Inactive', // Will fail the status filter
            ADF_Interest_Rate__c = null,
            ADF_Threshold_Amount__c = null
        );
        insert proj;

        Booking__c booking = new Booking__c(
            Project__c = proj.Id
        );
        insert booking;

        Test.startTest();
            // Call method with a Booking that does not satisfy the filter
            List<Controller_ADFSICalculator.WrapperADF> result = Controller_ADFSICalculator.GetProjects(booking.Id, 3999.49);
        Test.stopTest();

    }
}