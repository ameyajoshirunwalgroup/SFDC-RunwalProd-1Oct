@IsTest
public class Lockated_PaymentStatusAPITest {

    // --------------------------------------------
    // Helper to setup GET RestContext
    // --------------------------------------------
    private static void setupRestContext(String orderId) {

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/paymentStatus';
        req.httpMethod = 'GET';

        if(orderId != null){
            req.addParameter('orderId', orderId);
        }

        RestContext.request = req;
        RestContext.response = new RestResponse();
    }

    // --------------------------------------------
    // 1️⃣ Test Missing orderId
    // --------------------------------------------
    @IsTest
    static void testMissingOrderId() {

        setupRestContext(null);

        Test.startTest();
        Lockated_PaymentStatusAPI.getPaymentStatus();
        Test.stopTest();
    }


    // --------------------------------------------
    // 2️⃣ Test Order Not Found
    // --------------------------------------------
    @IsTest
    static void testOrderNotFound() {

        setupRestContext('ORDER_NOT_EXIST');

        Test.startTest();
        Lockated_PaymentStatusAPI.getPaymentStatus();
        Test.stopTest();

    }


    // --------------------------------------------
    // 3️⃣ Test Order Found
    // --------------------------------------------
    @IsTest
    static void testOrderFound() {

        // Insert Payment Transaction record
        Payment_Transaction__c payment = new Payment_Transaction__c(
            Order_Id__c = 'ORDER123',
            Status__c = 'SUCCESSFUL',
            Amount__c = 500,
            Transaction_Id__c = 'TXN123',
            Bank_Ref_No__c = 'BANK123'
        );
        insert payment;

        setupRestContext('ORDER123');

        Test.startTest();
        Lockated_PaymentStatusAPI.getPaymentStatus();
        Test.stopTest();

    }
    
        // --------------------------------------------
    // 3️⃣ Test Order Found
    // --------------------------------------------
    @IsTest
    static void testOrderFound1() {

        // Insert Payment Transaction record
        Payment_Transaction__c payment = new Payment_Transaction__c(
            Order_Id__c = 'ORDER123',
            Status__c = 'PENDING',
            Amount__c = 500,
            Transaction_Id__c = 'TXN123',
            Bank_Ref_No__c = 'BANK123'
        );
        insert payment;

        setupRestContext('ORDER123');

        Test.startTest();
        Lockated_PaymentStatusAPI.getPaymentStatus();
        Test.stopTest();

    }


    // --------------------------------------------
    // 4️⃣ Test Exception Flow
    // --------------------------------------------
    @IsTest
    static void testExceptionFlow() {

        // Force exception by inserting invalid data (null Order_Id__c)
        // Or simulate by passing extremely long value

        setupRestContext('');  // Will trigger validation

        Test.startTest();
        Lockated_PaymentStatusAPI.getPaymentStatus();
        Test.stopTest();

    }
    @IsTest
    static void testCatchBlock() {
    
        // Intentionally break RestContext
        RestContext.request = null;
        RestContext.response = new RestResponse();
    
        Boolean exceptionThrown = false;
    
        Test.startTest();
        try {
            Lockated_PaymentStatusAPI.getPaymentStatus();
        } catch (Exception e) {
            exceptionThrown = true;
        }
        Test.stopTest();
    
    }


    // ============================================
    // 🔹 Test getValue()
    // ============================================
    @IsTest
    static void testGetValue_AllCases() {

        Map<String,Object> testMap = new Map<String,Object>{
            'key1' => 'value1',
            'key2' => 'value2',
            'nullKey' => null
        };

        // Case 1: Primary key present
        String result1 = Lockated_PaymentStatusAPI.getValue(testMap, 'key1', 'key2');

        // Case 2: Primary null, fallback present
        String result2 = Lockated_PaymentStatusAPI.getValue(testMap, 'nullKey', 'key2');

        // Case 3: Both keys missing
        String result3 = Lockated_PaymentStatusAPI.getValue(testMap, 'x', 'y');

        // Case 4: Primary missing, fallback present
        String result4 = Lockated_PaymentStatusAPI.getValue(testMap, 'x', 'key2');
    }

    // ============================================
    // 🔹 Test resolveStatus()
    // ============================================
    @IsTest
    static void testResolveStatus_AllCases() {

        // Case 1: Null
       
            Lockated_PaymentStatusAPI.resolveStatus(null);

        // Case 2: Success
        
            Lockated_PaymentStatusAPI.resolveStatus('success');

        // Case 3: Failure
       
            Lockated_PaymentStatusAPI.resolveStatus('failure');
		  Lockated_PaymentStatusAPI.resolveStatus('pending');
          Lockated_PaymentStatusAPI.resolveStatus('cancel');
        
    }

}