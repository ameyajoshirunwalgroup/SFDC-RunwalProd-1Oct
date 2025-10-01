@isTest
public class TestBrokerageSchemeTemplateController {
    @isTest
    public Static void BrokerageScheme(){
        Brokerage_Scheme__c bs = New Brokerage_Scheme__c();
        bs.name = 'test scheme';
        bs.Slab_Type__c = 'count';
        bs.Start_Date__c = system.today();
        bs.End_Date__c = system.today();
        insert bs;
                
        Test.StartTest();
        BrokerageSchemeTemplateController bst = new BrokerageSchemeTemplateController();
        bst.SchemeId = bs.Id;
        bst.getSchemeList();
        Test.StopTest();
        
    }
}