@isTest
public class CaseFeedbackForControllerTest {

    @isTest
    static void testCaseFeedbackForController() {
        Test.startTest();
           // Create a test user to be the owner of the case
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        User testUser = new User(
            Alias = 'testuser', 
            Email = 'newcase@gmail.com', 
            EmailEncodingKey = 'UTF-8', 
            LastName = 'User', 
            LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', 
            ProfileId = p.Id, FirstName='test',
            TimeZoneSidKey = 'America/Los_Angeles', 
            UserName = 'newcase@gmail.com'
        );
        insert testUser;
        

        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create a test Case
        Case testCase = new Case(
            AccountId = testAccount.Id,
            Subject = 'Test Case',
            Status = 'Open',
            OwnerId = testUser.Id,
            CSAT_Feedback_Rating__c='',//RW_Case_Type__c='Complaint'
            //RW_Complaint_Type__c='Legal Related'
            SuppliedEmail='test@mail.com'
        );
        insert testCase;

        testCase.Subject = 'Updated Test Case';
        testCase.Status='Case closed';
        testCase.Remarks_by_RM__c='Closed Satisfactory';
        testCase.RW_Approval_Status__c='Approved';
        testcase.RW_RM_Remarks__c='test';
        update testCase;

        PageReference testPageRef = Page.CaseFeedbackForm;
        Test.setCurrentPage(testPageRef);
        ApexPages.currentPage().getParameters().put('id', testCase.Id);
        CaseFeedbackForController controller = new CaseFeedbackForController();

   
        ApexPages.currentPage().getParameters().put('remarkValue', 'New Remark');
        controller.updateRemark();
        ApexPages.currentPage().getParameters().put('ratingValue', '4');
        controller.updateRating1();
 
     
        controller.userInput = 'This is a test feedback';
        PageReference resultPage = controller.SubmitFeedback();

        Test.stopTest();
    }
}