@IsTest
public class Test_WhatsAppCustomerOnADFApproved {
    
    // Mock class to fake HTTP response
    private class WhatsAppMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"success":true,"message":"Message sent"}');
            res.setStatusCode(200);
            return res;
        }
    }

    @IsTest
    static void testWhatsAppQueueable() {
        // Create related Customer
        Account cust = new Account(
            Name = 'Test Customer',
            RW_Mobile_No__c = '9876543210'
        );
        insert cust;
        
        Opportunity objOpp = new Opportunity();
        objOpp.Name = 'Test Opp';
        objOpp.StageName = 'Unit Booked';
        objOpp.CloseDate = Date.today();
        objOpp.SAP_Customer_Number__c = '123456';
        objOpp.RW_Mobile_No__c = '8399209839';
        insert objOpp;
        
        // Create Booking record
        Booking__c objBooking = new Booking__c();
        objBooking.Opportunity__c = objOpp.Id;
        objBooking.Customer__c = objOpp.Id;
        insert objBooking;

        
        
        // Create Credit Note record (Approved status)
        Credit_Note__c cn = new Credit_Note__c(
            Interest_To_Be_Settled__c = 500,
            Booking__c = objBooking.Id,
            Approval_Status__c = 'Approved'
        );
        insert cn;

        // Set callout mock
        Test.setMock(HttpCalloutMock.class, new WhatsAppMock());

        Test.startTest();
        // Enqueue the Queueable
        System.enqueueJob(new WhatsAppCustomerOnADFApproved(new List<Id>{cn.Id}));
        Test.stopTest(); // ensures async job runs
    }

    @IsTest
    static void testWhenNoMobileNumber() {
        // Create related Customer without mobile
        Account cust = new Account(
            Name = 'Customer No Mobile'
        );
        insert cust;
         
        Opportunity objOpp = new Opportunity();
        objOpp.Name = 'Test Opp';
        objOpp.StageName = 'Unit Booked';
        objOpp.CloseDate = Date.today();
        objOpp.SAP_Customer_Number__c = '123456';
        insert objOpp;
        
        // Create Booking record
        Booking__c objBooking = new Booking__c();
        objBooking.Opportunity__c = objOpp.Id;
        insert objBooking;

        Credit_Note__c cn = new Credit_Note__c(
            Approval_Status__c = 'Approved',
            Booking__c = objBooking.Id
        );
        insert cn;
        cn.Sent_to_SAP__c = true;
        update cn;
        
        // Set mock
        Test.setMock(HttpCalloutMock.class, new WhatsAppMock());

        Test.startTest();
        System.enqueueJob(new WhatsAppCustomerOnADFApproved(new List<Id>{cn.Id}));
        Test.stopTest();
    }
}