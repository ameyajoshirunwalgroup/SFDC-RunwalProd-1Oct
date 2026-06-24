@isTest
public class OpportunityCustomerCreationTest {

    // Mock class for callout
    public class MockCustomerCreation implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"Customerno":"CUST12345","Return_x":{"item":[]}}');
            res.setStatusCode(200);
            return res;
        }
    }

    @testSetup
    static void setupTestData() {
        // Create Account
        Account acc = new Account(
            FirstName = 'John',
            LastName = 'Doe',
            Middle_Name__c = 'M',
            Salutation = 'Mr.',
            Gender__c = 'Male',
            Marital_Status__c = 'Single',
            RW_Occupation__c = 'Engineer',
            RW_Designation__c = 'Manager',
            Organization_Name__c = 'TestOrg',
            Mobile_No__c = '9999999999',
            PersonEmail = 'john.doe@test.com',
            BillingCity = 'Mumbai',
            BillingState = 'MH',
            BillingPostalCode = '400001',
            Country__c = 'IN',
            BillingStreet = '123 Test Street'
        );
        insert acc;

        // Create Project
        Project__c proj = new Project__c(
            Name = 'Test Project',
            SAPMaterial_Code__c = 'MAT001'
        );
        insert proj;

        // Create Tower
        Tower__c tower = new Tower__c(
            Name = 'Tower A',
            ProjectName__c=proj.Id,
            SAP_Plant_Code__c = 'PLANT01',
            Property_Type__c = 'Residential'
        );
        insert tower;

        // Create Project Unit
        Project_Unit__c unit = new Project_Unit__c(
            Name = 'Test Project Unit',
            RW_Project__c = proj.Id,
            TowerName__c = tower.Id,
            RW_Unit_Status__c = 'Available',
            RW_Param1__c = 'Test',
            Unit_SAP_Code__c = 'UNIT001',
            Saleable_Area__c = 1000,
            Carpet_area__c = 900
        );
        insert unit;

        // Create Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id,
            RW_Project_Unit__c = unit.Id,
            RW_Project__c = proj.Id,
            Sourcing_Manager_User__c = UserInfo.getUserId(),
            Walkin_Source__c = 'Direct'
        );
        insert opp;

        // Create Blocking Unit Info
        Blocking_Unit_Information__c blockUnit = new Blocking_Unit_Information__c(
            Opportunity__c = opp.Id,
            Pan_Number__c = 'ABCDE1234F',
            Aadhar_Number__c = '123412341234',
            Active__c = true
        );
        insert blockUnit;
    }

    @isTest
    static void testCreateOppCustomer() {
        // Retrieve Opportunity Id
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Set<Id> oppIds = new Set<Id>{opp.Id};

        // Set the mock callout
        Test.setMock(HttpCalloutMock.class, new MockCustomerCreation());

        // Call future method
        Test.startTest();
        OpportunityCustomerCreation.createOppCustomer(oppIds);
        Test.stopTest();

        // Verify Opportunity updated with SAP Customer Number
        Opportunity updatedOpp = [SELECT SAP_Customer_Number__c FROM Opportunity WHERE Id = :opp.Id];
        // Verify ERP Integration Log created
        List<ERP_Integration_Log__c> logs = [SELECT Id, Status__c, API_name__c FROM ERP_Integration_Log__c WHERE Opportunity__c = :opp.Id];
        System.assert(logs.size() > 0);
    }

    @isTest
    static void testCreateOppCustomer_DataError() {
        // Create Opportunity with missing project unit to trigger data error
        Opportunity opp = new Opportunity(
            Name = 'Error Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert opp;

        Set<Id> oppIds = new Set<Id>{opp.Id};

        Test.startTest();
        OpportunityCustomerCreation.createOppCustomer(oppIds);
        Test.stopTest();

        // Verify Opportunity not updated
        Opportunity updatedOpp = [SELECT SAP_Customer_Number__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(null, updatedOpp.SAP_Customer_Number__c);

        // Verify ERP Integration Log with Failure created
        List<ERP_Integration_Log__c> logs = [SELECT Status__c, Error_Type__c FROM ERP_Integration_Log__c WHERE Opportunity__c = :opp.Id];
        System.assertEquals('Failure', logs[0].Status__c);
        System.assertEquals('Data Error', logs[0].Error_Type__c);
    }
}