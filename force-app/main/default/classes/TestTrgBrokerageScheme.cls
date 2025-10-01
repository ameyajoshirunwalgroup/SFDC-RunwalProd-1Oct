@isTest
public class TestTrgBrokerageScheme 
{
    @isTest
    public static void TestTBS()
    {
		Project_Location__c pl = new Project_Location__c();
        pl.Name = 'Mumbai';
        pl.Approver_L1__c = userinfo.getUserId();
        pl.Approver_L2__c = userinfo.getUserId();
        pl.Location__c = 'Mumbai';
        insert pl;
        
        Brokerage_Scheme__c bs = new Brokerage_Scheme__c();
        bs.Type__c = 'Both';
        bs.Approval_Status__c = 'Approved by Level 2';
        bs.Base_Brokerage_for_Local_Bookings__c = 2;
        bs.Base_Brokerage_for_OS_NRI__c = 3;
        bs.Slab_Type__c = 'Count';
        bs.Start_Date__c = system.today();
        bs.End_Date__c = system.today()+2;
        bs.Project_Location__c = pl.Id;
        insert bs;
        
        bs.Name = 'Test1';
        update bs;
        
        /*Test.StartTest();
        TestTrgBrokerageScheme.TestTBS();
        //TestTrgBrokerageScheme b = new TestTrgBrokerageScheme();
        //bst.SchemeId = bs.Id;
        //bst.getSchemeList();
        Test.StopTest();*/
    }
    
}