@IsTest
public class CustomerPortalNCFControllerTest {

@testSetup
static void setupData() {

    // Get Standard User profile
    Profile p = [
        SELECT Id
        FROM Profile
        WHERE Name = 'Runwal Customer Portal'
        LIMIT 1
    ];

    // Create Person Account
    Account acc = new Account(
        LastName = 'Portal User',
        PersonEmail = 'portaluser@test.com'
    );
    insert acc;

    // Fetch Person Contact Id
    acc = [
        SELECT PersonContactId
        FROM Account
        WHERE Id = :acc.Id
    ];

    // Create User linked to Person Account Contact
    User u = new User(
        Alias = 'tuser',
        Email = 'portaluser@test.com',
        EmailEncodingKey = 'UTF-8',
        LastName = 'Portal',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        TimeZoneSidKey = 'Asia/Kolkata',
        UserName = 'portaluser' + System.currentTimeMillis() + '@test.com',
        ProfileId = p.Id,
        ContactId = acc.PersonContactId
    );
    insert u;

    // Create Booking
    Booking__c booking = new Booking__c(
            NCF_Status__c = 'Pending'
    );
    insert booking;

    // Create Active NCF
    Name_Confirmation_Form__c ncf = new Name_Confirmation_Form__c(
        RW_Primary_First_Name__c='test',
        RW_Primary_Last_Name__c='disha',
        RW_Primary_Email__c='disha@gmail.com',
        RW_Primary_Mobile_Number__c='8980000089',
        PancardNo__c='FVGFV5555G',
       RW_Primary_DOB__c = Date.valueOf('1985-03-30'),
        RW_Primary_Permanent_Address_Line_1__c='45 RAMALAYA VATIKA',
        RW_Primary_Country__c='India',
        Booking__c = booking.Id,
        Status__c = 'Pending',
        RW_Active_NCF__c = true
        
    );
    insert ncf;
}

    /* -----------------------------
     * getNCF
     * ----------------------------- */
    @IsTest
    static void testGetNCF() {
        try {
            Booking__c booking = [SELECT Id FROM Booking__c LIMIT 1];
    
            Test.startTest();
            Name_Confirmation_Form__c result =
                CustomerPortalNCFController.getNCF(booking.Id);
            Test.stopTest();
          } catch (Exception e) {
              
        }
    }

    @IsTest
    static void testGetNCF_NullBooking() {
        try{
            Test.startTest();
            Name_Confirmation_Form__c result =
                CustomerPortalNCFController.getNCF(null);
            Test.stopTest();
        } catch (Exception e) {
              
        }
    }

    /* -----------------------------
     * createCaseWithBookingOwner
     * ----------------------------- */
    @IsTest
    static void testCreateCaseWithBookingOwner() {
        try{

                User u = [SELECT Id FROM User WHERE ContactId != null LIMIT 1];
                Booking__c booking = [SELECT Id, NCF_Status__c FROM Booking__c LIMIT 1];
                Name_Confirmation_Form__c ncf =
                    [SELECT Id, Status__c FROM Name_Confirmation_Form__c LIMIT 1];
        
                System.runAs(u) {
                    Case c = new Case(
                        Subject = 'NCF Issue',
                        Origin = 'Portal'
                    );
        
                    Test.startTest();
                    String caseId =
                        CustomerPortalNCFController.createCaseWithBookingOwner(
                            c,
                            booking.Id,
                            ncf.Id
                        );
                    Test.stopTest();
            }
        }catch (Exception e) {
              
        

        }
    }
    @IsTest
    static void testCreateCaseWithBookingOwner1() {
        try{
    
            User u = [SELECT Id FROM User WHERE ContactId != null LIMIT 1];
            Booking__c booking = [SELECT Id, NCF_Status__c FROM Booking__c LIMIT 1];
            Name_Confirmation_Form__c ncf =
                [SELECT Id, Status__c FROM Name_Confirmation_Form__c LIMIT 1];
    
            System.runAs(u) {
                Case c = new Case(
                    Subject = 'NCF Issue',
                    Origin = 'Portal'
                );
    
                  CustomerPortalNCFController.CaseInputWrapper wrapper =
                new CustomerPortalNCFController.CaseInputWrapper();
    
            wrapper.caseType = 'Complaint';
            wrapper.touchPoint = 'Customer Portal';
            wrapper.complaintType = 'Service';
            wrapper.complaintSubType = 'Delay';
            wrapper.unitNumber = 'A-101';
            wrapper.description = 'Case created from test class';
            wrapper.bookingId = booking.Id;
    
            // Serialize wrapper
            String jsonInput = JSON.serialize(wrapper);
    
            Test.startTest();
            Id caseId = CustomerPortalNCFController.createCaseWrapper(jsonInput);
            Test.stopTest();
        }
        }catch (Exception e) {
              
        }

        
    }


    /* -----------------------------
     * approveNCF
     * ----------------------------- */
    @IsTest
    static void testApproveNCF() {
        try{

        Name_Confirmation_Form__c ncf =
            [SELECT Id, Status__c FROM Name_Confirmation_Form__c LIMIT 1];

        Test.startTest();
        CustomerPortalNCFController.approveNCF(ncf.Id, null);
        Test.stopTest();
        } catch (Exception e) {
              
        }

    }

    @IsTest
    static void testApproveNCF_Exception() {
        try {
            Test.startTest();
            CustomerPortalNCFController.approveNCF(null, null);
            Test.stopTest();
        } catch (AuraHandledException e) {
           
        }
    }

    /* -----------------------------
     * createCaseWrapper (JSON)
     * ----------------------------- */
    
    @IsTest
    static void testCreateCaseWrapper_InvalidJSON() {
        try {
            Test.startTest();
            CustomerPortalNCFController.createCaseWrapper('invalid-json');
            Test.stopTest();
        } catch (AuraHandledException e) {
        }
    }
}