@IsTest
public class Test_TriggerHandlerDemand {
    
    @IsTest
    static void setupData() {
        // Create a test user
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User rmUser = new User(
            Alias = 'rmuser',
            Email = 'rmuser@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Manager',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            Username = 'rmuser' + System.currentTimeMillis() + '@test.com'
        );
        insert rmUser;
        
        // Create Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        // Create Opportunity (Customer)
        Opportunity cust = new Opportunity(
            Name = 'Test Customer',
            AccountId = acc.Id,
            StageName = 'Unit Booked',
            CloseDate = System.today()
        );
        insert cust;
        
        // Create Relationship Manager
        Relationship_Manager__c relMgr = new Relationship_Manager__c(
            Name = 'Test RM',
            User__c = rmUser.Id
        );
        insert relMgr;
        
        // Create Project
        Project__c project = new Project__c(
            Name = 'Runwal Forest',
            RW_Status__c = 'Active',
            SAPMaterial_Code__c = '6001'
        );
        insert project;
        
        Tower__c tower = new Tower__c(
            Name = 'Tower 11',
            SAP_Plant_Code__c = '6214',
            ProjectName__c = project.Id
        );
        insert tower;
        
        Project_Unit_Type__c objPUT = new Project_Unit_Type__c(
            RDS_Code__c = '101',
            RDS_Project__c = project.Id
        );
        insert objPUT;
        
        Project_Unit__c objPUU = new Project_Unit__c(
            Project_Unit_Type__c = objPUT.Id,
            Name = 'TestUnit',
            RW_Project__c = project.Id,
            RW_Param1__c = '5',
            UnitNo__c = '9',
            Relationship_Manager__c = relMgr.Id,
            RW_Unit_Status__c = 'Available'
        );
        insert objPUU;
        
        // Create Booking
        Booking__c booking = new Booking__c(
            Customer__c = cust.Id,
            Unit_No__c = objPUU.Id
        );
        insert booking;
        
        // Create Demand
       List<RW_Demand__c> lstDemand = new List<RW_Demand__c>();
        RW_Demand__c demand = new RW_Demand__c(
            Name = 'Test Demand',
            Booking__c = booking.Id
        );
        lstDemand.add(demand);
        insert lstDemand;
        
         Test.startTest();
        TriggerHandlerDemand.createTask(lstDemand);
        Test.stopTest();
        
    }
    
   /* @IsTest
    static void testCreateTask() {
        // Fetch test demand
        RW_Demand__c demand = [
            SELECT Id, Booking__c, Booking__r.Customer__c 
            FROM RW_Demand__c LIMIT 1
        ];
        
        // Call handler
        Test.startTest();
        TriggerHandlerDemand.createTask(new List<RW_Demand__c>{ demand });
        Test.stopTest();
        
        // Validate task
        Task t = [
            SELECT Id, RecordTypeId, Subject, WhatId, Task_Type__c, Collection_Status__c, 
                   Demand__c, Booking__c, OwnerId
            FROM Task 
            WHERE Demand__c = :demand.Id 
            LIMIT 1
        ];
        
        System.assertNotEquals(null, t, 'Task should have been created');
        System.assertEquals('Collection Call', t.Task_Type__c, 'Task type should match');
        System.assertEquals('Collection Call Task', t.Subject, 'Task subject should match');
        System.assertEquals('Due (default)', t.Collection_Status__c, 'Collection status should match');
        System.assertEquals(demand.Id, t.Demand__c, 'Demand should be linked');
        //System.assertEquals(demand.Booking__c, t.Booking__c, 'Booking should be linked');
      //  System.assertEquals(demand.Booking__r.Customer__c, t.WhatId, 'WhatId should map to the Opportunity (Customer)');
    }*/
}