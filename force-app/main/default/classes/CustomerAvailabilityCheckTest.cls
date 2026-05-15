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
            AccountId = acc.Id,
            SAP_Customer_Number__c = '12314'
        );
        insert testOpp;
        
        Booking__c bkg = new Booking__c();
        bkg.Opportunity__c = testOpp.Id;
        bkg.Customer__c = testOpp.Id;
        insert bkg;
        
        Country_Codes__c code = new Country_Codes__c();
        code.Name = 'India';
        code.Code__c = 'IN';
        insert code;
        
        Applicant_Details__c app = new Applicant_Details__c();
        app.Applicant_Number__c = 'Primary Applicant';
        app.Mobile_Number__c = '1234567890';
        app.Email_Address__c = 'test@example.com';
        app.First_Name__c = 'Vinay';
        app.Last_Name__c = 'Test';
        app.Booking__c = bkg.Id;
        insert app;
                

        // Call the REST service
        RestRequest request = new RestRequest();
        request.requestURI = 'https://runwal--uat.my.salesforce.com/services/apexrest/checkCustomer';
        request.addParameter('mobile', '1234567890');
        request.addParameter('email', 'test@example.com');
        RestContext.request = request;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CreateUserWhenUnitBookedMock()); 
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
    
     @isTest
    public static void checkTest1() {
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
            AccountId = acc.Id,
            SAP_Customer_Number__c = '12314'
        );
        insert testOpp;
        
        Booking__c bkg = new Booking__c();
        bkg.Opportunity__c = testOpp.Id;
        bkg.Customer__c = testOpp.Id;
        insert bkg;
        
        Country_Codes__c code = new Country_Codes__c();
        code.Name = 'India';
        code.Code__c = 'IN';
        insert code;
        
        Applicant_Details__c app = new Applicant_Details__c();
        app.Applicant_Number__c = 'Primary Applicant';
        app.Mobile_Number__c = '1234567892';
        app.Email_Address__c = 'test2@example.com';
        app.First_Name__c = 'Vinay';
        app.Last_Name__c = 'Test';
        app.Booking__c = bkg.Id;
        insert app;
        
        app.Mobile_Number__c = '1234567891';
        app.Email_Address__c = 'test1@example.com';
        update app;
  
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CreateUserWhenUnitBookedMock()); 
        Test.stopTest();
    }
}