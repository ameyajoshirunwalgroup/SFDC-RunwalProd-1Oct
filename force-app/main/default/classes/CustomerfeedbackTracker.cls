@isTest
public class CustomerfeedbackTracker {
    @isTest
    private static void feedbackTest () {
        
        test.startTest();
        pageReference pagRef = page.CustomerFeedbackPage;
        test.setCurrentPage(pagRef);
        CustomerFeedbackController cf = new CustomerFeedbackController();
        cf.submitFeedback();
        cf.cfObj.Customer_Mobile_Number__c = '9898989898';
        cf.cfObj.Customer_Experience__c = 'Good';
        cf.submitFeedback();
        cf.submitAnotherResponse();
        test.stopTest();
    }

}