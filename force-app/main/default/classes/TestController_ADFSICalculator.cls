@isTest
public class TestController_ADFSICalculator {

    @isTest
    static void testGetProjects() {
        
        // Create Active Project with required fields
        Project__c proj = new Project__c(
            Name = 'Test Project',
            RW_Status__c = 'Active',
            ADF_Threshold_Amount__c = 10000
        );
        insert proj;

        // Create booking
        Booking__c booking = new Booking__c(
            Project__c = proj.Id
        );
        insert booking;

        Test.startTest();
            Controller_ADFSICalculator.WrapperADF result =
                Controller_ADFSICalculator.GetProjects(booking.Id, 3999.49);
        Test.stopTest();

    }


    @isTest
    static void testGetProjects_NoMatch() {

        // Create project that does NOT satisfy the filter (Inactive)
        Project__c proj = new Project__c(
            Name = 'Inactive Project',
            RW_Status__c = 'Inactive',
            ADF_Threshold_Amount__c = null
        );
        insert proj;

        // Booking
        Booking__c booking = new Booking__c(
            Project__c = proj.Id
        );
        insert booking;

        Test.startTest();
            Controller_ADFSICalculator.WrapperADF result =
                Controller_ADFSICalculator.GetProjects(booking.Id, 5000);
        Test.stopTest();
    }
}