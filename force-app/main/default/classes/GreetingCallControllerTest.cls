@isTest
private class GreetingCallControllerTest {

    @testSetup
    static void setup() {
        // --- Reuse your existing setup logic ---
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        User testUser = new User(
            Alias = 'stuser', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='testrmuser' + DateTime.now().getTime() + '@test.com'
        );
        insert testUser;

        Project__c proj = new Project__c(
            RW_Project_Code__c = 'T31', 
            Name = 'Runwal Bliss', 
            RDS_Short_Name__c = 'T', 
            Start_Date__c = System.today().addDays(-5), 
            RDS_Interest_Rate__c = 12
        );
        insert proj;
        
        Tower__c objTower = new Tower__c(
            ProjectName__c = proj.id, 
            Name = 'A', 
            SAP_Plant_Code__c = '111', 
            Property_Type__c = 'Commercial'
        );
        insert objTower;
        
        Relationship_Manager__c ObjRm = new Relationship_Manager__c(
            Tower__c = objTower.Id, 
            Project__c = proj.Id, 
            User__c = testUser.Id, 
            Contact_Number__c='2154789622'
        );
        insert ObjRm; 
        
        Project_Unit_Type__c objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = proj.id;
        insert objPUT;

        Project_Unit__c unit = new Project_Unit__c(
            Project_Unit_Type__c = objPUT.id,
            Name = 'TestUnit', 
            TowerName__c = objTower.Id, 
            RW_Project__c = proj.Id, 
            Relationship_Manager__c = ObjRm.Id,
            RW_Param1__c = '5',
        	UnitNo__c = '9',
            RW_Unit_Status__c = 'Available'
        );
        insert unit;
        
        // Note: Assuming TestDataFactory exists as per your previous snippet
        Account a = new Account(Name = 'Test Account'); // Fallback if TestDataFactory is unavailable
        insert a;

        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Site Visit',
            CloseDate = System.today().addDays(10),
            RW_Project__c = proj.Id,
            RW_Project_Unit__c = unit.Id,
            AccountId = a.Id,
            Sales_Manager__c = 'SM2@g.com'
        );
        insert opp;

        // Create a Loan record for testing the wrapper logic
        Loan__c testLoan = new Loan__c(
            RW_Opportunity__c = opp.Id,
            Mode_of_funding__c = 'Bank Loan',
            RW_Bank_Preference_1__c = 'State Bank of India'
        );
        insert testLoan;
    }

    @isTest
    static void testGetGreetingInitialData() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
        GreetingCallController.InitialDataWrapper result = GreetingCallController.getGreetingInitialData(opp.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Wrapper should not be null');
        System.assertEquals(1, result.opportunityData.size(), 'Should return 1 opportunity');
        System.assertNotEquals(null, result.fundingOptions, 'Picklist options should be populated');
        System.assertEquals(1, result.loanRecordData.size(), 'Should have retrieved the loan record');
    }

    @isTest
    static void testProcessGreetingCall() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        // Prepare the fieldValues map to simulate LWC input
        Map<String, String> fieldValues = new Map<String, String>{
            'FundingType' => 'Self Funded',
            'ApplicantName1' => 'John Doe',
            'AgreementValue' => '5000000',
            'BlockDate' => String.valueOf(Date.today()),
            'EmailAddresses1' => 'john@test.com'
        };
        
        String remarksJson = '{"remark":"Customer is happy"}';

        Test.startTest();
        GreetingCallController.processGreetingCall(opp.Id, 'Hold', 'CUSTOMER NOT CONNECTED', remarksJson, fieldValues);
        Test.stopTest();

        // Verify Greeting Call record
        Greeting_Call__c gc = [SELECT Status__c, Mode_of_funding__c, Primary_Applicant_Name__c 
                               FROM Greeting_Call__c WHERE Opportunity__c = :opp.Id LIMIT 1];

        // Verify Remarks record
        RW_Welcome_Call_Remarks__c remarkRec = [SELECT RW_Remarks__c FROM RW_Welcome_Call_Remarks__c WHERE Greeting_Call__c = :gc.Id];
        
    }

    @isTest
    static void testGetLatestRemarks() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        // Manually create a Greeting Call and Remark
        Greeting_Call__c gc = new Greeting_Call__c(Opportunity__c = opp.Id, Status__c = 'Due');
        insert gc;
        
        RW_Welcome_Call_Remarks__c remark = new RW_Welcome_Call_Remarks__c(
            Greeting_Call__c = gc.Id,
            RW_Remarks__c = 'Latest Remark'
        );
        insert remark;

        Test.startTest();
        String result = GreetingCallController.getLatestRemarks(gc.Id);
        Test.stopTest();
    }
}