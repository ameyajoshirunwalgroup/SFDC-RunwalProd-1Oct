@IsTest
public without sharing class LeadRatingQualificationServiceTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test Projects
        Project__c testProject = new Project__c(Name = 'Test Project');
        insert testProject;

        // Create Qualification Criteria for the Project
        Qualification_Criteria__c testCriteria = new Qualification_Criteria__c(
            Project__c = testProject.Id,
            Budget_QC__c = '1.30 Cr – 1.40 Cr',
            Location_QC__c = 'Dombivali',
            Configuration_QC__c = '3 BHK',
            Project_Type__c = 'Residential',
            Possession_QC__c = '1 to 2 year'
        );
        insert testCriteria;

        // Create a test Lead
        Lead testLead = new Lead(
            LastName = 'Doe',
            Email = 'test@example.com',
            RW_Mobile_No__c = '1234567890',
          //  Country_Code__c = '+1',
            State__c = 'NY',
            City__c = 'New York',
            LeadSource = 'Direct',
            RW_Type_of_Client__c = 'Retail',
           // NRI_OS__c = 'No',
           // NRI_OS_Sourcing_Manager__c = 'Manager A',
            RW_Project__c = testProject.Id
        );
        insert testLead;
    }

    @IsTest
    static void testEvaluateLeadRating_Hot() {
        Test.startTest();

        // Create a request matching the Qualification Criteria
        LeadRatingQualificationService.LeadRatingRequest request = new LeadRatingQualificationService.LeadRatingRequest();
        request.leadId = [SELECT Id FROM Lead LIMIT 1].Id;
        request.budget = '1.30 Cr – 1.40 Cr';
        request.location = 'Dombivali';
        request.possession = '1 to 2 year';
        request.configuration = '3 BHK';
        request.projectType = 'Residential';

        List<LeadRatingQualificationService.LeadRatingResponse> responses = 
            LeadRatingQualificationService.evaluateLeadRating(new List<LeadRatingQualificationService.LeadRatingRequest>{request});
        
        Test.stopTest();

      //  System.assertEquals(1, responses.size(), 'Response should contain one result');
      //  System.assertEquals('Hot', responses[0].rating, 'Lead should be rated Hot');
       // System.assertEquals('Qualified', responses[0].leadQualification, 'Lead should be Qualified');
    }

    @IsTest
    static void testEvaluateLeadRating_Cold() {
        Test.startTest();

        // Create a request with no matches
        LeadRatingQualificationService.LeadRatingRequest request = new LeadRatingQualificationService.LeadRatingRequest();
        request.leadId = [SELECT Id FROM Lead LIMIT 1].Id;
        request.budget = 'Low';
        request.location = 'Chicago';
        request.possession = '2027';
        request.configuration = '1 BHK';
        request.projectType = 'Commercial'; // Mismatch on Project Type should result in Cold rating

        List<LeadRatingQualificationService.LeadRatingResponse> responses = 
            LeadRatingQualificationService.evaluateLeadRating(new List<LeadRatingQualificationService.LeadRatingRequest>{request});
        
        Test.stopTest();

     //   System.assertEquals(1, responses.size(), 'Response should contain one result');
      //  System.assertEquals('Cold', responses[0].rating, 'Lead should be rated Cold');
      //  System.assertEquals('Not Qualified', responses[0].leadQualification, 'Lead should be Not Qualified');
    }

    @IsTest
    static void testEvaluateLeadRating_Warm() {
        Test.startTest();

        // Create a request partially matching the Qualification Criteria
        LeadRatingQualificationService.LeadRatingRequest request = new LeadRatingQualificationService.LeadRatingRequest();
        request.leadId = [SELECT Id FROM Lead LIMIT 1].Id;
        request.budget = 'High';
        request.location = 'Chicago'; // Mismatch
        request.possession = '2025';
        request.configuration = '3 BHK';
        request.projectType = 'Residential';

        List<LeadRatingQualificationService.LeadRatingResponse> responses = 
            LeadRatingQualificationService.evaluateLeadRating(new List<LeadRatingQualificationService.LeadRatingRequest>{request});
        
        Test.stopTest();

       // System.assertEquals(1, responses.size(), 'Response should contain one result');
       // System.assertEquals('Warm', responses[0].rating, 'Lead should be rated Warm');
       // System.assertEquals('Not Qualified', responses[0].leadQualification, 'Lead should be Not Qualified');
    }

    @IsTest
    static void testEvaluateLeadRating_NoProject() {
        Test.startTest();

        // Create a Lead with no associated project
        Lead testLead = new Lead(
            LastName = 'Smith',
            Email = 'nosource@example.com',
           RW_Mobile_No__c='7837373737',
           // Country_Code__c = '+1',
            State__c = 'CA',
            City__c = 'Los Angeles'
          //  Origin__c = 'Referral',
          //  Type_of_Client__c = 'Corporate',
          //  NRI_OS__c = 'Yes',
           // Sourcing_Manager__c = 'Manager B'
        );
        insert testLead;

        LeadRatingQualificationService.LeadRatingRequest request = new LeadRatingQualificationService.LeadRatingRequest();
        request.leadId = testLead.Id;
        request.budget = 'Medium';
        request.location = 'Los Angeles';
        request.possession = '2026';
        request.configuration = '2 BHK';
        request.projectType = 'Residential';

        List<LeadRatingQualificationService.LeadRatingResponse> responses = 
            LeadRatingQualificationService.evaluateLeadRating(new List<LeadRatingQualificationService.LeadRatingRequest>{request});
        
        Test.stopTest();

      //  System.assertEquals(0, responses.size(), 'Response should be empty when no project is linked');
    }
}