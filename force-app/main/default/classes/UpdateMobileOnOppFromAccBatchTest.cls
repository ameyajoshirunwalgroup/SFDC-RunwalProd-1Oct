@isTest
public class UpdateMobileOnOppFromAccBatchTest {
    
    @isTest
    public static void mobileNumTest(){
        
        Account acc = new Account();
        acc.Name = 'Test Acc';
        acc.Mobile_No__c = '1236547896';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.AccountId = acc.Id;
        opp.StageName = 'Qualification';
        opp.CloseDate = Date.today() + 10;
        opp.RW_Email__c = 'test@mail.com';
        opp.RW_Mobile_No__c = '1236547856';
        insert opp;
        
        opp.RW_Mobile_No__c = null;
        update opp;
        
        UpdateMobileOnOppFromAccBatch b = new UpdateMobileOnOppFromAccBatch();
        b.execute(null);
    }

}