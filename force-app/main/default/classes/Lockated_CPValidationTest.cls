@isTest
public class Lockated_CPValidationTest {
    @testSetup
    static void setup() {
        // Create a sample Broker record to trigger duplicate logic
        Broker__c testBroker = new Broker__c(
            RW_Email__c = 'test@example.com',
            Broker_Pan_No__c = 'ABCDE1234F',
            RW_Mobile_No__c = '9876543210'
        );
        insert testBroker;
    }
    @isTest
    static void testDuplicateFound() {
        String jsonInput = '{"email":"duplicate@test.com", "phone":"9876543210", "panNo":"ABCDE1234F"}';
        setupRestContext(jsonInput);
        Lockated_CPValidation.doPost();
        
    }
    @isTest
    static void testEmptyFieldsScenario() {
        String jsonInput = '{"email":"", "phone":"", "panNo":""}';
        setupRestContext(jsonInput);
        Test.startTest();
        Lockated_CPValidation.doPost();
        Test.stopTest();
    }
    @isTest
    static void testSuccessScenario() {
        String jsonInput = '{"email":"unique@test.com", "phone":"1111111111", "panNo":"PAN999"}';
        setupRestContext(jsonInput);
        Lockated_CPValidation.doPost();
    }
    @isTest
    static void testNullBodyScenario() {
        try{
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestBody = null; 
            RestContext.request = req;
            RestContext.response = res;
            Lockated_CPValidation.doPost();
        }catch(Exception ex){
            
        }
    }
    private static void setupRestContext(String body) {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/cpValidation/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(body);
        
        RestContext.request = req;
        RestContext.response = res;
    }
}