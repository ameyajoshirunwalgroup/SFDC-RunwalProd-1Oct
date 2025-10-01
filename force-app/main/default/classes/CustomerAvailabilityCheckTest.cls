@isTest
private class CustomerAvailabilityCheckTest {
	
    @isTest
    public static void checkTest() {
        // test data insert
        Account acc = new Account(
            FirstName = 'Test',
            LastName = 'Account',
            PersonEmail = 'test@example.com',
            Mobile_No__c = '1234567890',
            Country_Code__c = '+91',
            RW_Country__c = 'India'
        );
        insert acc;

        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Unit Booked',
            RW_Mobile_No__c = '1234567890',
            RW_Email__c = 'test@example.com',
            CloseDate = Date.today(),
            AccountId = acc.Id
        );
        insert testOpp;
        
        Country_Codes__c code = new Country_Codes__c();
        code.Name = 'India';
        code.Code__c = 'IN';
        insert code;

        // Call the REST service
        RestRequest request = new RestRequest();
        request.requestURI = 'https://runwal--uat.my.salesforce.com/services/apexrest/checkCustomer';
        request.addParameter('mobile', '1234567890');
        request.addParameter('email', 'test@example.com');
        RestContext.request = request;

        Test.startTest();
        CustomerAvailabilityCheck.Details result = CustomerAvailabilityCheck.checkCustomerAvailability();
        Test.stopTest();

        // Verify the result
        System.assertNotEquals(null, result);
        
    }

    /*@isTest
     public static void checkTest1() {
        // Call the REST service with invalid parameters
        RestRequest request = new RestRequest();
        request.requestURI = 'https://runwal--uat.my.salesforce.com/services/apexrest/whatsappFb';
        request.addParameter('mobile', '1234567890');
        request.addParameter('email', 'invalid@example.com');
        RestContext.request = request;

        Test.startTest();
        CustomerAvailabilityCheck.Details result = CustomerAvailabilityCheck.checkCustomerAvailability();
        Test.stopTest();

        // Verify the result
        System.assertNotEquals(null, result);
       
    }*/
}