@isTest
public class TestCustomerPortalWelcomeService {

    @isTest
    static void testSendPortalWelcomeEmail_UserCreation() {

        Id personRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account') != null
            ? Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId()
            : null;
        System.assertNotEquals(null, personRtId, 'Person Account RecordType not found');


        Account acc = new Account(
            RecordTypeId = personRtId,
            FirstName = 'John',
            LastName = 'Doe',
            PersonEmail = 'john.doe@example.com'

        );
        insert acc;


        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id
        );
        insert opp;

     
        Booking__c booking = new Booking__c(
 
            Customer__c = opp.Id
        );
        insert booking;

        // Prepare input for InvocableMethod
        CustomerPortalWelcomeService.BookingInput input = new CustomerPortalWelcomeService.BookingInput();
        input.bookingId = booking.Id;

        Test.startTest();
            CustomerPortalWelcomeService.sendPortalWelcomeEmail(new List<CustomerPortalWelcomeService.BookingInput>{ input });
        Test.stopTest();

      
    }
}