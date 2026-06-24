@IsTest
public class NameConfirmationControllerTest {

    /* -----------------------------
       Test Data Setup
    ------------------------------*/
    @testSetup
    static void setupData() {
        Project__c proj= new Project__c(
            Name='5th Avenue - Runwal Avenue'
        );
        insert proj;

        // Unit
        Project_Unit__c unit = new Project_Unit__c(
            Name = 'A-101',
            RW_Project__c=proj.id,
            RW_Unit_Status__c='Available',
            RW_Param1__c='RUNWAL BLISS'
        );
        insert unit;

        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test 123';
        opp.RW_Project__c = proj.Id; 
        opp.StageName = 'Negotiation';
        opp.CloseDate = system.today();
        opp.Remark__c = 'Test 123';
        opp.LeadSource = 'Digital';
        insert opp;
        
        // Booking
        Booking__c booking = new Booking__c(
            Unit_No__c = unit.Id,
            Customer__c= opp.id
        );
        insert booking;

        // Applicants
        List<Applicant_Details__c> applicants = new List<Applicant_Details__c>();

        applicants.add(new Applicant_Details__c(
            Name = 'Primary User',
            Applicant_Number__c = 'Primary Applicant',
            PancardNo__c = 'AAAAA1111A',
            Permanent_Address__c = 'Primary Address',
            Email_Address__c = 'primary@test.com',
            Booking__c = booking.Id
        ));

        applicants.add(new Applicant_Details__c(
            Name = 'Second User',
            Applicant_Number__c = 'Second Applicant',
            PancardNo__c = 'BBBBB2222B',
            Booking__c = booking.Id
        ));

        applicants.add(new Applicant_Details__c(
            Name = 'Third User',
            Applicant_Number__c = 'Third Applicant',
            PancardNo__c = 'CCCCC3333C',
            Booking__c = booking.Id
        ));

        applicants.add(new Applicant_Details__c(
            Name = 'Fourth User',
            Applicant_Number__c = 'Fourth Applicant',
            PancardNo__c = 'DDDDD4444D',
            Booking__c = booking.Id
        ));

        insert applicants;
    }

    /* -----------------------------
       Test Constructor
    ------------------------------*/
    @IsTest
    static void testControllerConstructor() {

        Booking__c bkg = [SELECT Id FROM Booking__c LIMIT 1];

        // Simulate VF page parameter
        Test.setCurrentPage(Page.NameConfirmationPDF);
        ApexPages.currentPage().getParameters().put('id', bkg.Id);

        Test.startTest();
        NameConfirmationController ctrl = new NameConfirmationController();
        Test.stopTest();

    }

    /* -----------------------------
       Test generateAndSendForm()
    ------------------------------*/
    @IsTest
    static void testGenerateAndSendForm() {

        Booking__c bkg = [SELECT Id, NCF_Document_Id__c FROM Booking__c LIMIT 1];

        Test.startTest();
        String url = NameConfirmationController.generateAndSendForm(bkg.Id);
        Test.stopTest();

    }

    /* -----------------------------
       Test generateAndSendFormInvocable()
    ------------------------------*/
    @IsTest
    static void testGenerateAndSendFormInvocable() {

        Booking__c bkg = [SELECT Id FROM Booking__c LIMIT 1];

        List<Id> ids = new List<Id>{ bkg.Id };

        Test.startTest();
        List<String> urls = NameConfirmationController.generateAndSendFormInvocable(ids);
        Test.stopTest();

    }

    /* -----------------------------
       Test Existing Document Path
    ------------------------------*/
    @IsTest
    static void testExistingDocumentFlow() {

        Booking__c bkg = [SELECT Id FROM Booking__c LIMIT 1];

        // First call to create document
        
        String url1 = NameConfirmationController.generateAndSendForm(bkg.Id);
        

        // Second call should reuse existing document
        
        String url2 = NameConfirmationController.generateAndSendForm(bkg.Id);
        

    }
}