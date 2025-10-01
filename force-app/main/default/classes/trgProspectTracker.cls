@isTest
public class trgProspectTracker {
    @isTest
    private static void ProspectTest1() {
        Project__c p2 = TestDataFactory.createProject('Xanadu_prj2','111');
        Account acc2 = TestDataFactory.createPATemplate('TestPA2' , 'testleada@ozonetest.com', '9876544441', false);
        
        List<Lead> llist2 = TestDataFactory.createLead(3);
        List<Opportunity>  oList2 = TestDataFactory.createOpptyForAccount(acc2.Id, p2.Id, 3);
        
        //system.debug(oList2[0].Name);           
        
        Team__c tm = new Team__c();
        tm.name = 'Prospect Team';
        tm.Project__c = p2.id;
        tm.Team_Type__c = 'Prospect Team';
        insert tm;
        
        Team_Members__c tmm = new Team_Members__c(); 
        tmm.Team__c = tm.id;
        tmm.User_Active__c = true;
        tmm.User__c = UserInfo.getUserId();
        insert tmm;
        
        //List<Task> tList1 = TestDataFactory.createTasksForOpp(oList[0].Id, 2, 'Presales Call');
        //List<Task> tList2 = TestDataFactory.createTasksForOpp(oList[1].Id, 2, 'Site Visit');
        
        
        
        
        Broker__c b = new Broker__c();
        b.Name = 'Test';
        b.Unregistered_Channel_Partner__c = true;
        b.AOP_Type__c = 'AOP';
        b.Broker_Pan_No__c = 'AASSZ3456T';
        insert b;        
        
        Broker__c b1 = new Broker__c();
        b1.Name = 'Test 2';
        b1.Unregistered_Channel_Partner__c = true;
        b1.AOP_Type__c = 'AOP';
        b1.Broker_Pan_No__c = 'AASSZ3456T';
        insert b1;
        
        CP_Category__c pl = new CP_Category__c();
        pl.Project__c = p2.Id;
        pl.Category__c = 'P1';
        pl.Channel_Partner__c = b.Id;
        insert pl;
        
        Prospect__c ps = new Prospect__c();
        ps.Account__c = acc2.id;
        ps.Project__c = p2.id;
        ps.Active__c = true;
        ps.Channel_Partner__c = b.id;
        ps.Lead_Source__c = 'Channel Partner';
        insert ps;
        
        Project__c objProj1 = new Project__c();
        objProj1.name = 'test3';
        insert objProj1;
        
        ps.Project__c = objProj1.id;
        ps.Channel_Partner__c = b1.id;
        update ps;
        
        Prospect__c ps3 = new Prospect__c();
        ps3.Account__c = acc2.id;
        ps3.Project__c = p2.id;
        ps3.Active__c = true;
        ps.Lead_Source__c = 'Channel Partner';
        
        try{
            insert ps3;
        }catch(Exception e){
            
        }
        Prospect__c ps2 = new Prospect__c();
        ps2.Lead__c = llist2[0].id;
        ps2.Project__c = p2.id;
        ps2.Active__c = true;
        ps.Lead_Source__c = 'Channel Partner';
        insert ps2;
        
        Prospect__c ps4 = new Prospect__c();
        ps4.Lead__c = llist2[0].id;
        ps4.Project__c = p2.id;
        ps4.Active__c = true;
        ps.Lead_Source__c = 'Channel Partner';
        try{
            insert ps4;
        }catch(Exception e){
            
        }  
        
        PageReference pRef = Page.SMAssignToProspect;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('id',ps.Id);
        SMAssignToProspect smp = new SMAssignToProspect();
        smp.assignSM();
        smp.BackToPage();
        
    }
}