@isTest
public class ProjectInfoServiceTest {
    @testSetup
    static void setup() {
        List<Project__c> projects = new List<Project__c>();
        projects.add(new Project__c(
            Name = 'Project Alpha',
            RW_Status__c = 'Active',
            CP_Helpdesk_1_Contact__c = '123-456-7890',
            CP_Helpdesk_2_Contact__c = '098-765-4321'
        ));
        projects.add(new Project__c(
            Name = 'Project Beta',
            RW_Status__c = 'Active',
            CP_Helpdesk_1_Contact__c = '555-555-5555'
        ));
        
        // Create an Inactive Project (should not be in response)
        projects.add(new Project__c(
            Name = 'Project Gamma',
            RW_Status__c = 'Completed'
        ));

        insert projects;
    }
    @isTest
    static void testGetActiveProjectsSuccess() {
        setupRestContext('Test');
        ProjectInfoService.getActiveProjects();
    }
    private static void setupRestContext(String body) {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/ActiveProjectDetails/';
        req.httpMethod = 'Get';
        req.requestBody = Blob.valueOf(body);
        
        RestContext.request = req;
        RestContext.response = res;
    }
}