@isTest
public class TestTrgSchemeConfig 
{
	public static testmethod void TestSchemeConfig(){
        Project__c p = new Project__c();
        p.RW_Project_Code__c = 'T31';
        p.Name = 'Runwal Bliss';
        p.RDS_Short_Name__c = 'T';
        p.Start_Date__c = System.today().addDays(-5);
        p.RDS_Interest_Rate__c = 12;
        insert p;
        
        Tower__c t = new Tower__c();
        t.ProjectName__c= p.Id;
        t.Name = 'A';
        insert t;
        
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
            
        /*Scheme_Configuration__c sc = new Scheme_Configuration__c();     
        sc.Name = 'Test1';
        sc.Project__c = p.Id;
        sc.Tower__c = t.Id;
        sc.Brokerage_Scheme__c = bs.Id;
        insert sc;*/
        
        
        
        Scheme_Configuration__c sc = new Scheme_Configuration__c();
        sc.Name = 'Feb';
        sc.Brokerage_Scheme__c = bs.Id;
        sc.Project__c = p.id;
        
        insert sc;
        
        
        //New Instance
        Project__c p2 = new Project__c();
        p2.RW_Project_Code__c = 'T32';
        p2.Name = 'Runwal Greens';
        p2.RDS_Short_Name__c = 'T2';
        p2.Start_Date__c = System.today().addDays(-5);
        p2.RDS_Interest_Rate__c = 12;
        insert p2;
        
        Tower__c t2 = new Tower__c();
        t2.ProjectName__c= p2.Id;
        t2.Name = 'B';
        insert t2;
        
        Project_Location__c pl2 = new Project_Location__c();
        pl2.Name = 'Mumbai';
        pl2.Approver_L1__c = userinfo.getUserId();
        pl2.Approver_L2__c = userinfo.getUserId();
        pl2.Location__c = 'Mumbai';
        insert pl2;
        
        Brokerage_Scheme__c bs2 = new Brokerage_Scheme__c();
        bs2.Type__c = 'Both';
        bs2.Approval_Status__c = 'Approved by Level 2';
        bs2.Base_Brokerage_for_Local_Bookings__c = 2;
        bs2.Base_Brokerage_for_OS_NRI__c = 3;
        bs2.Slab_Type__c = 'Count';
        bs2.Start_Date__c = system.today();
        bs2.End_Date__c = system.today()+2;
        bs2.Project_Location__c = pl2.Id;
        insert bs2;
        
        Scheme_Configuration__c sc2 = new Scheme_Configuration__c();
        sc2.Name = 'Jan';
        sc2.Brokerage_Scheme__c = bs2.Id;
        sc2.Project__c = p2.id;
        sc2.Tower__c = t2.Id;
        insert sc2;
        
    }
}