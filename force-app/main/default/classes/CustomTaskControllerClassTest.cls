@isTest
public class CustomTaskControllerClassTest {
    
    @isTest
    private static void TaskPageTest() {
        
        Test.startTest();
        
        Lead l = TestDataFactory.createLeadTemplate('BigLead', 'biglead@email.com', '1234567890', false);
        
        l.leadSource = 'Direct';
        l.lead_Sub_Source__c = 'Hoarding';
        l.RW_Budget__c = '< 1Cr';
        l.RW_Configuration__c = '1 BHK';
        l.RW_Time_line__c = 'Ready Possession';
        l.RW_Location__c = 'Airoli';
        update l;
        
        lead cLead = TestDataFactory.convertLead(l);
        
        task t = new Task();
        t.Subject = 'New Task';
        t.Task_Type__c = 'Site Visit';
        t.activityDate=System.Today();
        t.whatId = cLead.ConvertedOpportunityId;
        insert t;
        
        PageReference pRef1 = Page.VisitFormEditPage;
        Test.setCurrentPage(pRef1);
        ApexPages.currentPage().getParameters().put('retURL',cLead.ConvertedOpportunityId);
        ApexPages.currentPage().getParameters().put('cancelURL',cLead.ConvertedOpportunityId);
        ApexPages.currentPage().getParameters().put('origin','New Call Attempt');
        ApexPages.currentPage().getParameters().put('id',t.id);
        ApexPages.currentPage().getParameters().put('who_id',cLead.Id);
        ApexPages.currentPage().getParameters().put('what_id',cLead.ConvertedOpportunityId); 
        Task t1 = t;
        ApexPages.StandardController sc1 = new ApexPages.StandardController(t1);
        CustomTaskControllerClass tExtn1 = new CustomTaskControllerClass(sc1);
        tExtn1.save();
        tExtn1.cancel();
        tExtn1.Savedoc();
        tExtn1.dummyMethod();
        tExtn1.getUserOptions();
        tExtn1.dummyMethod566();
        List<SelectOption> resultOptions = tExtn1.hlrmNames;
        List<SelectOption> resultOptions1 = tExtn1.homeLoanCallStatus;
        List<SelectOption> resultOptions2 = tExtn1.homeLoanFollowupStatus;
        
        PageReference pRef = Page.CallAttemptEditPage2;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('retURL',cLead.ConvertedOpportunityId);
        ApexPages.currentPage().getParameters().put('cancelURL',cLead.ConvertedOpportunityId);
        ApexPages.currentPage().getParameters().put('origin','New Call Attempt');
        ApexPages.currentPage().getParameters().put('id',t.id);  
        ApexPages.StandardController sc2 = new ApexPages.StandardController(t1);
        CustomTaskControllerClass tExtn2 = new CustomTaskControllerClass(sc2);
        Test.stopTest();
    }
    
    @isTest
    private static void TaskPageTest2() {
        
        Test.startTest();

        
        Lead l = TestDataFactory.createLeadTemplate('BigLead', 'biglead@email.com', '1234567890', false);
        l.leadSource = 'Direct';
        l.lead_Sub_Source__c = 'Hoarding';
        l.RW_Budget__c = '< 1Cr';
        l.RW_Configuration__c = '1 BHK';
        l.RW_Time_line__c = 'Ready Possession';
        l.RW_Location__c = 'Airoli';
        update l;
        
        lead cLead = TestDataFactory.convertLead(l);
        
        //List<Task> tList1 = TestDataFactory.createTasksForOpp(cLead.ConvertedOpportunityId, 1, 'Site Visit');
        task t = new Task();
        t.Subject = 'New Task';
        t.Task_Type__c = 'Site Visit';
        t.activityDate=System.Today();
        t.whatId = cLead.ConvertedOpportunityId;
        insert t;
        
        PageReference pRef1 = Page.VisitFormEditPage;
        Test.setCurrentPage(pRef1);
        ApexPages.currentPage().getParameters().put('retURL',cLead.ConvertedOpportunityId);
        ApexPages.currentPage().getParameters().put('cancelURL',cLead.ConvertedOpportunityId);
        ApexPages.currentPage().getParameters().put('origin','New Call Attempt');
        ApexPages.currentPage().getParameters().put('id',t.id);
        ApexPages.currentPage().getParameters().put('who_id',cLead.Id);
        Task t1 = t;
        ApexPages.StandardController sc1 = new ApexPages.StandardController(t1);
        CustomTaskControllerClass tExtn1 = new CustomTaskControllerClass(sc1);
        tExtn1.save();
        tExtn1.cancel();
        tExtn1.Savedoc();
        tExtn1.dummyMethod();
        tExtn1.getUserOptions();
        tExtn1.dummyMethod566();
        List<SelectOption> resultOptions = tExtn1.hlrmNames;
        List<SelectOption> resultOptions1 = tExtn1.homeLoanCallStatus;
        List<SelectOption> resultOptions2 = tExtn1.homeLoanFollowupStatus;
        
        Test.stopTest();
    }
    
}