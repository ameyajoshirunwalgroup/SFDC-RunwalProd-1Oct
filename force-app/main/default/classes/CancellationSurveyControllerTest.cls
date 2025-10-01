@isTest
public class CancellationSurveyControllerTest {
    
    @isTest
    public static void surveyTest(){
        
        Cancellation_Survey__c csRec = new Cancellation_Survey__c();
        csRec.Applicant_Email__c = 'test@mail.com';
        csRec.Configuration_or_Project__c = '';
        csRec.CRM_Rep_Post_Sales_Process__c = '';
        //csRec.Opportunity__c = '';
        csRec.Other_Cancellation_Reason__c = '';
        //csRec.Booking__c = '';
        insert csRec;
        
        test.startTest();
        pageReference pagRef = page.CancellationSurvey;
        //System.currentPageReference().getParameters().put('objId', objBking.Id);
        test.setCurrentPage(pagRef);
        
        CancellationSurveyController cs = new CancellationSurveyController();
        cs.recId = csRec.Id;
        cs.recCS();
        cs.configRes();
        cs.getConfigList();
        cs.getCrmRepList();
        cs.getPaymentList();
        cs.getReasons();
        cs.getrecmList();
        cs.getSalesTeamList();
        cs.reasons();
        cs.addReasons();
        cs.payStrRes();
        test.stopTest();
    }

}