@isTest
public class SiteVisitSurveyControllerTest {
    
    @isTest
    private static void siteVisitSurveyTest(){
        Account acc = new Account();
        acc.FirstName = 'Test First Name';
        acc.LastName = 'Test Last Name';
        acc.Birth_Date__c = Date.today() - 500;
        acc.Gender__c = 'Male';
        acc.RW_Occupation__c = 'Salaried';
        acc.Locality__c = 'Airoli';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Test Opportunity';
        opp.StageName = 'Qualification';
        opp.CloseDate = Date.today() + 10;
        
        insert opp;
        
        test.startTest();
        ApexPages.currentPage().getParameters().put('optyId',opp.Id);
        ApexPages.StandardController controller = new ApexPages.StandardController(opp);
        SiteVisitSurveyController vistFrm = new SiteVisitSurveyController(controller);
        vistFrm.backToOpp();
        vistFrm.opp.Other_Details_First_Name__c = '';
        vistFrm.opp.Other_Details_Last_Name__c = 'Test Last Name1';
        vistFrm.opp.Other_Details_DOB__c = Date.today() - 200;
        vistFrm.opp.Other_Details_Gender__c = 'Female';
        vistFrm.opp.Other_Details_Occupation__c = 'Self Employed';
        vistFrm.opp.Other_Details_Home_Location__c = 'Bandra';
        vistFrm.save();
        test.stopTest();
    }

}