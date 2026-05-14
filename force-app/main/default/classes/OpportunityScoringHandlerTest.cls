@isTest
public class OpportunityScoringHandlerTest {

    @testSetup
    static void setupData() {
       
        List<OpportunityCriteriaScores__c> settings = new List<OpportunityCriteriaScores__c>();

    
        settings.add(new OpportunityCriteriaScores__c(
            Name='BudgetHigh',
            Sub_Criteria__c = 'Budget',
            Description__c = 'High',
            Score__c = 10,
            Matching_Type__c = 'Static',
            Opportunity_Field__c = 'RW_Budget__c'
        ));

     
        settings.add(new OpportunityCriteriaScores__c(
            Name='Budget',
            Sub_Criteria__c = 'Budget',
            Description__c = 'Match',
            Score__c = 20,
            Matching_Type__c = 'Dynamic',
            Opportunity_Field__c = 'RW_Budget__c'
        ));

        insert settings;

        
        Project__c project = new Project__c(Name = 'Test Project');
        insert project;

        
        Qualification_Criteria__c qc = new Qualification_Criteria__c(
            Project__c = project.Id,
            Budget_QC__c = '1.30 Cr – 1.40 Cr',
            Possession_QC__c = '1 to 2 year',
            Configuration_QC__c = '2 BHK',
            Location_QC__c = 'Airoli'
        );
        insert qc;
    }

    static Opportunity createTestOpportunity(Id projectId, String budget, String timeline, String config, String location) {
        return new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = System.today().addDays(30),
            RW_Project__c = projectId,
            RW_Budget__c = budget,
            RW_Time_line__c = timeline,
            RW_Configuration__c = config,
            RW_Location__c = location
        );
    }

    @isTest
    static void testCalculateOpportunityScores_StaticAndDynamic() {
        
        Id projectId = [SELECT Id FROM Project__c LIMIT 1].Id;

    
        Opportunity opp = createTestOpportunity(
            projectId,
            '1.30 Cr – 1.40 Cr',   
            '1 to 2 year',  
            '2 BHK',    
            'Airoli'   
        );
        insert opp;

        Test.startTest();
        OpportunityScoringHandler.calculateOpportunityScores(new List<Opportunity>{ opp });
        Test.stopTest();


    }

    @isTest
    static void testFindBestMatchHandlesNullsGracefully() {
        Opportunity opp = new Opportunity(
            Name = 'Opportunity No Project',
            StageName = 'Qualification',
            CloseDate = System.today().addDays(15)
          
        );
        insert opp;

        
        Test.startTest();
        OpportunityScoringHandler.calculateOpportunityScores(new List<Opportunity>{ opp });
        Test.stopTest();

     
    }
}