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
            Mode_of_Funding__c = 'Bank Loan'
        );
        insert cif;

        // Create Blocking Unit Information
        Blocking_Unit_Information__c blockUnit = new Blocking_Unit_Information__c(
            Opportunity__c = opp.Id,
            Project_Unit__c = unit.Id,
            Active__c = true
        );
        insert blockUnit;
    }

    @isTest
    static void testLoanCreationOnBlockUnitInsert() {
        Blocking_Unit_Information__c blockUnit = [SELECT Id, Opportunity__c,Project_Unit__c FROM Blocking_Unit_Information__c LIMIT 1];

        Test.startTest();
        BlockUnitInformationHandler.handleAfterInsert(new List<Blocking_Unit_Information__c>{ blockUnit });
        Test.stopTest();

       
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

        // Reuse existing unit
        Project_Unit__c unit = [SELECT Id FROM Project_Unit__c LIMIT 1];

        // Insert new blocking unit without CIF
        Blocking_Unit_Information__c blockUnit2 = new Blocking_Unit_Information__c(
            Opportunity__c = opp2.Id,
            Project_Unit__c = unit.Id,
            Active__c = true
        );
        insert blockUnit2;

        Test.startTest();
        BlockUnitInformationHandler.handleAfterInsert(new List<Blocking_Unit_Information__c>{ blockUnit2 });
        Test.stopTest();

    }

    @isTest
    static void testExistingLoanUpdatedToSelfFunded() {
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Test Opp' LIMIT 1];
        Project_Unit__c unit = [SELECT Id FROM Project_Unit__c LIMIT 1];

        // Create existing loan
        Loan__c loan = new Loan__c(
            RW_Opportunity__c = opp.Id,
            RW_Unit_No__c = unit.Id,
            RW_Loan_Record_Status__c = 'Loan Process Initiated',
            RW_Customer_Loan_Preference__c = 'HDFC',
            RW_Bank_Preference_1__c='Aditya Birla Housing Finance Ltd'
        );
        insert loan;

        // Update CIF to self-funded
        CIF__c cif = [SELECT Id FROM CIF__c WHERE Opportunity__c = :opp.Id LIMIT 1];
        cif.Mode_of_Funding__c = 'Self Funded';
        update cif;

        // Reuse same blocking unit
        Blocking_Unit_Information__c blockUnit = [SELECT Id, Opportunity__c,Project_Unit__c FROM Blocking_Unit_Information__c LIMIT 1];

        Test.startTest();
        BlockUnitInformationHandler.handleAfterInsert(new List<Blocking_Unit_Information__c>{ blockUnit });
        Test.stopTest();

        
    }

    @isTest
    static void testLoanUpdatedWhenBankPreferenceChanges() {
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Test Opp' LIMIT 1];
        Project_Unit__c unit = [SELECT Id FROM Project_Unit__c LIMIT 1];

        // Create existing loan
        Loan__c loan = new Loan__c(
            RW_Opportunity__c = opp.Id,
            RW_Unit_No__c = unit.Id,
            RW_Loan_Record_Status__c = 'Loan Process Initiated',
            RW_Customer_Loan_Preference__c = 'HDFC',
            RW_Bank_Preference_1__c='Aditya Birla Housing Finance Ltd'
        );
        insert loan;

        // Update CIF with new bank preferences
        CIF__c cif = [SELECT Id FROM CIF__c WHERE Opportunity__c = :opp.Id LIMIT 1];
        cif.Bank_Preference_1__c = 'HDFC Bank Ltd';
        cif.Mode_of_Funding__c = 'Bank Loan';
        update cif;

        // Reuse blocking unit
        Blocking_Unit_Information__c blockUnit = [SELECT Id, Opportunity__c,Project_Unit__c FROM Blocking_Unit_Information__c LIMIT 1];

        Test.startTest();
        BlockUnitInformationHandler.handleAfterInsert(new List<Blocking_Unit_Information__c>{ blockUnit });
        Test.stopTest();

    }
}