@isTest
private class BrokerageSchemeTriggerHandlerTest {
    @testSetup
    static void setupData() {
        Project__c project = new Project__c(Name = 'Test Project');
        insert project;
        
         Project__c p = TestDataFactory.createProject('Xanadu_prj','111');
        Account acc = TestDataFactory.createPATemplate('TestPA1' , 'testleada@ozonetest.com', '9876544441', false);
        
        
        Project_Location__c pl = new Project_Location__c();
        pl.Name = 'Mumbai';
        pl.Approver_L1__c = userinfo.getUserId();
        pl.Approver_L2__c = userinfo.getUserId();
        pl.Location__c = 'Mumbai';
        insert pl;
        
        Brokerage_Scheme__c bscheme = new Brokerage_Scheme__c();
        bscheme.Type__c = 'Both';
        bscheme.Approval_Status__c = 'Approved by Level 2';
        bscheme.Base_Brokerage_for_Local_Bookings__c = 2;
      //  bscheme.Base_Brokerage_for_OS_NRI__c = 3;
        bscheme.Slab_Type__c = 'Count';
        bscheme.Start_Date__c = system.today();
        bscheme.End_Date__c = system.today()+2;
        bscheme.Project_Location__c = pl.Id;
        bscheme.AOP_CP__c = 5;
        insert bscheme;
        
        Brokerage_Slab__c bslab = new Brokerage_Slab__c();
        bslab.Name = 'Slab 1';
        bslab.From__c = 0;
        bslab.To__c = 1;
        bslab.Additional_Brokerage_for_Local_Bookings__c = 0;
        bslab.Additional_Brokerage_for_OS_NRI__c = 0;
        bslab.Brokerage_Scheme__c = bscheme.Id;
        insert bslab;
        
        Brokerage_Slab__c bslab2 = new Brokerage_Slab__c();
        bslab2.Name = 'Slab 1';
        bslab2.From__c = 2;
        bslab2.To__c = null;
        bslab2.Additional_Brokerage_for_Local_Bookings__c = 0.25;
        bslab2.Additional_Brokerage_for_OS_NRI__c = 0.25;
        bslab2.Brokerage_Scheme__c = bscheme.Id;
        insert bslab2;
        
        Scheme_Configuration__c sc = new Scheme_Configuration__c();
        sc.Name = 'Oct';
        sc.Brokerage_Scheme__c = bscheme.Id;
        sc.Project__c = p.id;
        insert sc;
          
        
        Booking__c booking = new Booking__c(
            
            Status__c = 'Booking Confirmed',
            Booking_Date__c = Date.today(),
            Type_of_Client__c = 'Local',
            Passback_Amount__c = 1000,
            Brokerage_scheme__c = bscheme.id 
        );
        insert booking;
    }

    @isTest
    static void testBrokerageSchemeTagging() {
        List<Brokerage_Scheme__c> schemes = [SELECT Id FROM Brokerage_Scheme__c];
        Test.startTest();
        BrokerageSchemeTriggerHandler.BrokerageSchemeTagging(new List<Id>{schemes[0].Id});
        BrokerageSchemeTriggerHandler.Dummy();
        Test.stopTest();
        
    }
    
    @isTest
    static void testInvalidSchemeId() {
        Test.startTest();
        //BrokerageSchemeTriggerHandler.BrokerageSchemeTagging(new List<Id>{'InvalidId'});
        Test.stopTest();
        
       
    }
}