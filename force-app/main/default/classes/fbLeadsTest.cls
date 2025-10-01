/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class fbLeadsTest {

    static testMethod void VerifyEndPoint() {
        RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    req.httpMethod = 'GET';
    req.addParameter('hub.challenge','challengemeFB');
    req.addParameter('hub.verify_token','secret007');
    RestContext.request = req;
    RestContext.response = res;
    
    fbLeads.fbVerifyEndPoint();
        
    }
    
    static testMethod void leadCapture() {
   
        RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
        
        
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf('{\"entry\": [{\"changes\": [{\"field\": \"leadgen\", \"value\": {\"created_time\": 1497980807, \"page_id\": \"701696013318418\", \"form_id\": \"685046341703539\", \"leadgen_id\": \"437370333311120\"}}], \"id\": \"701696013318418\", \"time\": 1497980808}], \"object\": \"page\"}');
    RestContext.request = req;
    RestContext.response = res;
    
    fbLeads.fbLeadCapture();
    List<Social_media_lead__c> smlList = new List<Social_media_lead__c>();
    smlList = [Select Id, Name from Social_media_lead__c];
    System.assertEquals(1, smlList.size());
    FBGetLeadsBatch b = new FBGetLeadsBatch(); 
       database.executebatch(b); 
       
       req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf('{\"entry\": [{\"changes\": [{\"field\": \"leadgen\", \"value\": {\"created_time\": 1497980807, \"page_id\": \"701696013318418\", \"form_id\": \"685046341703539\", \"leadgen_id\": \"437370333311121\"}}], \"id\": \"701696013318418\", \"time\": 1497980808}], \"object\": \"page\"}');
    RestContext.request = req;
    RestContext.response = res;
    
    fbLeads.fbLeadCapture();
    smlList = [Select Id, Name from Social_media_lead__c];
    System.assertEquals(2, smlList.size());
    smlList[1].form_data__c = '{"created_time":"2017-07-03T13:44:30+0000","id":"717723901769116","field_data":[{"name":"what_type_of_home_are_you_looking_for?_","values":["3bhk"]},{"name":"what_is_your_budget?","values":["3cr._-_4cr."]},{"name":"full_name","values":["TODAY IS THE DAY"]},{"name":"email","values":["singpore.today\u0040rmail.com"]},{"name":"phone_number","values":["+9669617810511"]}]}';
    update smlList[1];
    }
}