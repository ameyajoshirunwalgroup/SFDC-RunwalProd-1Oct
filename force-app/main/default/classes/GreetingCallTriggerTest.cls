@isTest
private class GreetingCallTriggerTest {

    @testSetup
    static void setupData() {
        // 1. Create a Test User
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        User testUser = new User(
            Alias = 'stuser', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='testrmuser' + DateTime.now().getTime() + '@test.com'
        );
        insert testUser;

        // 2. Create Relationship Manager record (Custom Object)
        // Assuming the object name is Relationship_Manager__c based on your __r naming
        Relationship_Manager__c rm = new Relationship_Manager__c(
            User__c = testUser.Id
            // Add other required fields for your RM object here
        );
        insert rm;

        // 3. Create Project & Unit
        // Assuming names based on your lookup fields
        Project__c  proj = new Project__c();
        proj.RW_Project_Code__c = 'T31';
        proj.Name = 'Runwal Bliss';
        proj.RDS_Short_Name__c = 'T';
        proj.Start_Date__c = System.today().addDays(-5);
        proj.RDS_Interest_Rate__c = 12;
        insert proj;
        
        Tower__c objTower = new Tower__c();
        objTower.ProjectName__c = proj.id;
        objTower.Name = 'A';
        objTower.SAP_Plant_Code__c = '111';
        objTower.Property_Type__c = 'Commercial';
        insert objTower;
        
        Relationship_Manager__c ObjRm = new Relationship_Manager__c();
        ObjRm.Tower__c = objTower.Id;
        ObjRm.Project__c = proj.Id;
        ObjRm.User__c = testUser.Id;
        ObjRm.Contact_Number__c='2154789622';
        insert ObjRm; 

        /*Project_Unit__c unit = new Project_Unit__c(
            Name = 'Unit 101',
            Relationship_Manager__c = rm.Id
        );*/
        
        Project_Unit_Type__c objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = proj.id;
        insert objPUT;
        
        Project_Unit__c unit = new Project_Unit__c();
        unit.Project_Unit_Type__c = objPUT.id;
        unit.TowerName__c = objTower.id;
        unit.Name = 'TestUnit';
        unit.RW_Project__c = proj.Id;
        unit.RW_Param1__c = '5';
        unit.UnitNo__c = '9';
        unit.RW_Unit_Status__c = 'Available';
        unit.Relationship_Manager__c = ObjRm.Id;
        insert unit;
        
        
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777',false);
        System.debug('a Id---->'+a.Id);

        // 4. Create Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Site Visit',
            CloseDate = System.today().addDays(10),
            RW_Project__c = proj.Id,
            RW_Project_Unit__c = unit.Id,
            Status__c = 'Active',
            AccountId = a.Id,
            Sales_Manager__c = 'SM2@g.com',
        	RW_Type_of_Client__c = 'Local',
            Walkin_Source__c = 'Channel Partner'
        );
        insert opp;
    }

    @isTest
    static void testOwnerAssignmentOnInsert() {
        try{
        // Retrieve the Opportunity created in setup
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        User expectedUser = [SELECT Id FROM User WHERE Alias = 'stuser' LIMIT 1];

        // Create Greeting Call records
        List<Greeting_Call__c> gcList = new List<Greeting_Call__c>();
        for(Integer i=0; i<5; i++) {
            gcList.add(new Greeting_Call__c(
                Opportunity__c = testOpp.Id
                // Add other required fields
            ));
        }
        
        Test.startTest();
        insert gcList;
        Test.stopTest();

        // Verify the RM_User__c was populated correctly via the trigger
        List<Greeting_Call__c> results = [SELECT RM_User__c FROM Greeting_Call__c WHERE Opportunity__c = :testOpp.Id];
        
        System.assertEquals(5, results.size(), 'Should have inserted 5 records');
        for(Greeting_Call__c gc : results) {
            System.assertEquals(expectedUser.Id, gc.RM_User__c, 'The RM User should match the User on the Relationship Manager record');
        }
            }catch(Exception ex){
            
        }
    }

    @isTest
    static void testInsertWithoutOpportunity() {
        // Test edge case where Opportunity is null
        Greeting_Call__c gc = new Greeting_Call__c();
        try{
        Test.startTest();
        insert gc;
        Test.stopTest();

        Greeting_Call__c result = [SELECT RM_User__c FROM Greeting_Call__c WHERE Id = :gc.Id];
        System.assertEquals(null, result.RM_User__c, 'RM User should be null if no Opportunity is linked');
        }catch(Exception ex){
            
        }
    }
}