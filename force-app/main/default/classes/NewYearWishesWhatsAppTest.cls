@isTest
public class NewYearWishesWhatsAppTest {
    
    @isTest
    public static void newYearWishTest(){
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Mobile_No__c = '1234569875';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.AccountId = acc.Id;
        opp.StageName = 'Unit Booked';
        opp.CloseDate = date.today() - 10;
        insert opp;
        
        Test.startTest();
        NewYearWishesWhatsApp b = new NewYearWishesWhatsApp();
        Database.executeBatch(b,2);
        Test.stopTest();
    }

}