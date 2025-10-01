@isTest
public class TestTrgBrokerageSummary 
{
	public static testmethod void TrgBS()
    {
    	Brokerage_Summary__c bs = new Brokerage_Summary__c();
        bs.Applied_Slab_Name__c = 'Slab 2';
        bs.Show_Invoice__c = false;
        insert bs;
        
        bs.Show_Invoice__c = true;
        update bs;
    }
    public static testmethod void TrgBS2()
    {
    	Brokerage_Summary__c bs = new Brokerage_Summary__c();
        bs.Applied_Slab_Name__c = 'Slab 1';
        bs.Status__c = 'Due';
        bs.Show_Invoice__c = false;
        insert bs;
        
        Brokerage__c b = new Brokerage__c();
        b.Status__c = '';
        b.Brokerage_Summary__c = bs.Id;
        insert b;
    }
}