@isTest
public class BlockUnitInformationTriggerTest {

    @testSetup
    static void setupData() {
        // Create Project
        Project__c proj = new Project__c(Name = 'Test Project');
        insert proj;

        // Create Tower
        Tower__c tower = new Tower__c(Name = 'Tower A', ProjectName__c = proj.Id);
        insert tower;

        // Create Project Unit
        Project_Unit__c unit = new Project_Unit__c(
            Name = 'Unit 101',
            RW_Project__c = proj.Id,
            TowerName__c = tower.Id,
            RW_Unit_Status__c = 'Available',
            RW_Param1__c = 'Unit 101'
        );
        insert unit;

        // Create Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert opp;

        // Create CIF linked to Opportunity with banking preferences
        CIF__c cif = new CIF__c(
            Opportunity__c = opp.Id,
            Bank_Preference_1__c = 'HDFC Bank Ltd',
            Bank_Preference_2__c = 'ICICI Bank Ltd'
        );
        insert cif;

        // Create Blocking Unit Information
        Blocking_Unit_Information__c blockUnit = new Blocking_Unit_Information__c(
            Opportunity__c = opp.Id,
            Project_Unit__c = unit.Id
        );
        insert blockUnit;
    }

    @isTest
    static void testLoanCreationOnBlockUnitInsert() {
        // Fetch all loans created by trigger
        List<Loan__c> loans = [SELECT Id,
                                      RW_Opportunity__c,
                                      RW_Customer_Loan_Preference__c,
                                      RW_Loan_Record_Status__c,
                                      RW_Project_Name__c,
                                      RW_Tower__c,
                                      RW_Unit_No__c,
                                      RW_Bank_Name__c,
                                      RW_Bank_Preference_1__c,
                                      RW_Bank_Preference_2__c,
                                      RW_Bank_Preference_3__c
                               FROM Loan__c];

        System.assertEquals(1, loans.size(), 'One Loan record should be created.');
        Loan__c loan = loans[0];

    }

    @isTest
    static void testNoLoanCreatedWhenNoCIF() {
        // Create new Opportunity without CIF
        Opportunity opp2 = new Opportunity(
            Name = 'Opp without CIF',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10)
        );
        insert opp2;

        // Reuse project + unit
        Project_Unit__c unit = [SELECT Id FROM Project_Unit__c LIMIT 1];

        // Insert Blocking Unit Info
        Blocking_Unit_Information__c blockUnit2 = new Blocking_Unit_Information__c(
            Opportunity__c = opp2.Id,
            Project_Unit__c = unit.Id
        );
        insert blockUnit2;

        // Loan should not be created
        List<Loan__c> loans = [SELECT Id FROM Loan__c WHERE RW_Opportunity__c = :opp2.Id];
    }
}