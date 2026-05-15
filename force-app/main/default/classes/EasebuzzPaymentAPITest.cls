@IsTest
public class EasebuzzPaymentAPITest {

    @IsTest
    static void testHandlePaymentCallback_Success() {
        // Setup test data
        Account acc = new Account(
            LastName = 'Test Account',
            PersonEmail = 'test@example.com',
            Mobile_No__c = '9999999999'
        );
        insert acc;

        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Hash__c = '123456',
            Amount = 5000
        );
        insert opp;

        RW_EOI__c eoi = new RW_EOI__c(
            Opportunity__c = opp.Id,
            RW_Status__c = 'EOI Sent to Customer'
        );
        insert eoi;
        
        RW_Digital_Link_Status__c digitalLink = new RW_Digital_Link_Status__c(
            RW_Opportunity__c = opp.Id,
            RW_Link_Status__c = 'Active'
        );
        insert digitalLink;

        RestRequest req = new RestRequest();
        req.addParameter('phone', '9999999999');
        req.addParameter('email', 'test@example.com');
        req.addParameter('hash', '123456');
        req.addParameter('status', 'success');
        req.addParameter('txnid', opp.Id);
        req.addParameter('amount', '5000');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        EasebuzzPaymentAPI.handlePaymentCallback();
        //EasebuzzPaymentAPI.dummyMethod();
        Test.stopTest();

        
     
    }

    @IsTest
    static void testHandlePaymentCallback_OpportunityNotFound() {
        RestRequest req = new RestRequest();
        req.addParameter('phone', '8888888888');
        req.addParameter('email', 'unknown@example.com');
        req.addParameter('hash', '123456');
        req.addParameter('status', 'success');
        req.addParameter('txnid', '999999');
        req.addParameter('amount', '5000');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        EasebuzzPaymentAPI.handlePaymentCallback();
        Test.stopTest();
    }

    @IsTest
    static void testHandlePaymentCallback_HashMismatch() {
        // Setup test data
        Account acc = new Account(
            LastName = 'Test Account',
            PersonEmail = 'test@example.com',
            Mobile_No__c = '9999999999'
        );
        insert acc;

        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Hash__c = '123456',
            Amount = 5000
        );
        insert opp;

        RW_EOI__c eoi = new RW_EOI__c(
            Opportunity__c = opp.Id,
            RW_Status__c = 'EOI Sent to Customer'
        );
        insert eoi;

        RestRequest req = new RestRequest();
        req.addParameter('phone', '9999999999');
        req.addParameter('email', 'test@example.com');
        req.addParameter('hash', '654321'); // Mismatching hash
        req.addParameter('status', 'success');
        req.addParameter('txnid', opp.Id);
        req.addParameter('amount', '5000');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        EasebuzzPaymentAPI.handlePaymentCallback();
        Test.stopTest();

    }

    @IsTest
    static void testHandlePaymentCallback_EOInotFound() {
        // Setup test data
        Account acc = new Account(
            LastName = 'Test Account',
            PersonEmail = 'test@example.com',
            Mobile_No__c = '9999999999'
        );
        insert acc;

        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Hash__c = '123456',
            Amount = 5000
        );
        insert opp;

      

        RestRequest req = new RestRequest();
        req.addParameter('phone', '9999999999');
        req.addParameter('email', 'test@example.com');
        req.addParameter('hash', '123456');
        req.addParameter('status', 'success');
        req.addParameter('txnid', opp.Id);
        req.addParameter('amount', '5000');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        EasebuzzPaymentAPI.handlePaymentCallback();
        Test.stopTest();

      
    }
}