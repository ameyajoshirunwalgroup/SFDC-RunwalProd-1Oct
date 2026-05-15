@isTest 
public class CPDashboardCondtollerTest {
    
    @isTest 
    static void testGetFilteredCases_NewUser() {
        // Mock the JSON data
        String jsonData = '{"projectName": "Test Project","Registered":"","registeredCases":"","openregisteredCases":"","closedregisteredCases":"","totalopenregistered":"","totalclosedregistered":"","stage1":"","stage2":"","stage3":"","stage4":"","stage5":"","stage6":"","stage7":"","totalstage1rcases":"","totalstage2rcases":"","totalstage3rcases":"","totalstage4rcases":"","totalstage5rcases":"","totalstage6rcases":"","totalstage7rcases":"","unstage1":"","unstage2":"","unstage3":"","unstage4":"","unstage5":"","unstage6":"","unstage7":"","totalstage1uncases":"","totalstage2uncases":"","totalstage3uncases":"","totalstage4uncases":"","totalstage5uncases":"","totalstage6uncases":"","totalstage7uncases":"","UnRegistered":"","unregisteredCases":"","openunregisteredCases":"","closedunregisteredCases":"","Total_Un":"","totalopenunregistered":"","totalclosedunregistered":"","totalopencases":"","totalclosedcases":"","totalstage1cases":"","totalstage2cases":"","totalstage3cases":"","totalstage4cases":"","totalstage5cases":"","totalstage6cases":"","totalstage7cases":"","period":"Custom", "new_user": ""}'; // Replace with actual User Id
        
        // Create test data
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
        // Now create the User with the ContactId set
        User u = new User(
            Alias = 'standtq',
            Email = 'standarduserq@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestingNew',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'standardusernew@testorg.com'
        );
        insert u;
        
        // Create a test Project__c record
        Project__c project = new Project__c(
            Name = 'Test Project'
        );
        insert project;
        
        Test.startTest();
        // Call the method with mocked data
        List<Case> filteredCases = CPDashboardController.getFilteredCasesNew(jsonData, 'custom', null, null, u.Id);
        CPDashboardController.getRegisteredCaseCountByProject('Custom', '2023', '6', u.Id);
        CPDashboardController.getRegisteredCaseCountByProject('Custom', '', '', u.Id);
        CPDashboardController.getRegisteredCaseCountByProject('Custom', '2023', '', u.Id);
        CPDashboardController.getUnRegisteredCaseCountByProject('Custom', '2023', '6', u.Id);
        CPDashboardController.getUnRegisteredCaseCountByProject('Custom', '', '', u.Id);
        CPDashboardController.getUnRegisteredCaseCountByProject('Custom', '2023', '', u.Id);
        CPDashboardController.getTotalCaseCount('Custom', '2023', '6', u.Id);
        CPDashboardController.getCaseData();
        CPDashboardController.getUnprocessedCases('Custom', '2023', '6', u.Id);
        CPDashboardController.getUnprocessedCases('Custom', '', '', u.Id);
        CPDashboardController.getUnprocessedCases('Custom', '2023', '', u.Id);
        //CPDashboardController.getCaseDataBasedonCustomLabel();
        //CPDashboardController.dummy();
        Test.stopTest();
        
        
    }
    
    
}