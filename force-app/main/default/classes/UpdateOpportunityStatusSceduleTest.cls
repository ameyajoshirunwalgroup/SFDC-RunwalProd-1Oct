@isTest
public class UpdateOpportunityStatusSceduleTest {
	@isTest
    public static void updateOppStatusTest(){
        Account acc = new Account();
        acc.Name = 'Test Acc';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.AccountId = acc.Id;
        opp.StageName = 'Qualification';
        opp.CloseDate = Date.today() + 10;
        insert opp;
        
        opp.Opportunity_Status__c = '';
        update opp;
        
        Test.startTest();
        UpdateOpportunityStatusScedule b = new UpdateOpportunityStatusScedule();
        b.execute(null);
        Test.stopTest();
    }
}