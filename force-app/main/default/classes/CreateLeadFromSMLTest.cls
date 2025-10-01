@isTest
public class CreateLeadFromSMLTest {
    
    @testSetup
    static void setup() {
        // Create test data
        Social_Media_Lead__c sml = new Social_Media_Lead__c(
            Processed__c = false,
            Lead_ID__c = 'TestLeadID',
            Form_ID__c = '123456'
        );
        insert sml;
    }

    @isTest
    static void testCreateLeadFromSML() {
        
        Facebook_Leadobj__c fl = new Facebook_Leadobj__c();
        fl.Name__c = '123456';
        fl.Project_Name__c = 'Runwal Bliss';
        insert fl;
        
        Project__c proj = new Project__c();
        proj.Name = 'Runwal Bliss';
        insert proj;
        
        // Retrieve the test data
        Social_Media_Lead__c testSML = [SELECT Id, Lead_ID__c, Processed__c FROM Social_Media_Lead__c LIMIT 1];
        
        // Mock the callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Prepare input data
        List<String> smlIds = new List<String>{ testSML.Id };
        
        // Call the method
        Test.startTest();
        CreateLeadFromSML.createLead(smlIds);
        SocialMediaLeadServices.getFBLeads(new List<Social_Media_Lead__c>{testSML});
        Test.stopTest();
        
        // Verify the results
        Social_Media_Lead__c updatedSML = [SELECT Id, Lead_ID__c, Processed__c FROM Social_Media_Lead__c WHERE Id = :testSML.Id];
        System.assertEquals('TestLeadID', updatedSML.Lead_ID__c);
        System.assert(updatedSML.Processed__c, 'Processed__c should be set to true after the callout.');
    }
    
    // Mock HTTP Response Generator
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{ "status": "success" }');
            res.setStatusCode(200);
            return res;
        }
    }
}