public with sharing class CustomerPortalWelcomeService {

    public class BookingInput {
        @InvocableVariable(required=true)
        public Id bookingId;
    }

    @InvocableMethod(label='Create Portal User')
    public static void sendPortalWelcomeEmail(List<BookingInput> inputList) {
        for (BookingInput input : inputList) {
            Id bookingId = input.bookingId;

            Booking__c booking = [
                SELECT Id, Name, Customer__r.AccountId, Customer__r.Account.PersonEmail, Customer__r.Account.FirstName, 
                       Customer__r.Account.LastName, Customer__r.Account.PersonContactId, Customer__r.Account.IsCustomerPortal
                FROM Booking__c
                WHERE Id = :bookingId
                LIMIT 1
            ];

            Account acct = [
                SELECT Id, Name, PersonContactId, OwnerId, IsCustomerPortal
                FROM Account
                WHERE Id = :booking.Customer__r.AccountId
                LIMIT 1
            ];

            // Check if user already exists
            List<User> existingUsers = [SELECT Id FROM User WHERE Username = :booking.Customer__r.Account.PersonEmail LIMIT 1];

            if (existingUsers.isEmpty()) {
                // Create portal user
                Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'Runwal Customer Portal' LIMIT 1];

                User portalUser = new User(
                    ProfileId = portalProfile.Id,
                    Username = booking.Customer__r.Account.PersonEmail,
                    Alias = 'runwalc',
                    Email = booking.Customer__r.Account.PersonEmail,
                    EmailEncodingKey = 'UTF-8',
                    FirstName = booking.Customer__r.Account.FirstName,
                    LastName = booking.Customer__r.Account.LastName,
                    LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'en_IN',
                    TimeZoneSidKey = 'Asia/Kolkata',
                    ContactId = acct.PersonContactId
                );

                insert portalUser;
            }

            
        }
    }
}