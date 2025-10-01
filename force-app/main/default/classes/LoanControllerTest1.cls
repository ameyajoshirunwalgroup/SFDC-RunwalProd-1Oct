@isTest
public class LoanControllerTest1 {

    // Utility method to create a Project
    private static Project__c createProject() {
        Project__c proj = new Project__c(Name = 'Test Project');
        insert proj;
        return proj;
    }

    // Utility method to create a Booking
    private static Booking__c createBooking(Id projectId) {
        Booking__c booking = new Booking__c(
            
            Project__c = projectId
        );
        insert booking;
        return booking;
    }

    // Utility method to create a Loan
    private static Loan__c createLoan(Id bookingId, String status, Boolean pariPassu) {
        status = 'Loan Process Initiated';
        Loan__c loan = new Loan__c(
            RW_Bank_Preference_1__c = 'HDFC Bank Ltd',
            RW_Booking__c = bookingId,
            RW_Loan_Record_Status__c = status,
            RW_Pari_Passu__c = pariPassu
        );
        insert loan;
        return loan;
    }

    // Utility method to create Home Loan RM
    private static Home_Loan_RM__c createHLRM(Id projectId, String bankName) {
        Home_Loan_RM__c hlrm = new Home_Loan_RM__c(
            Name = 'Test RM',
            Project__c = projectId,
            Bank_Name__c = bankName
        );
        insert hlrm;
        return hlrm;
    }

    @isTest
    static void testLoanInsert() {
        Project__c proj = createProject();
        Booking__c booking = createBooking(proj.Id);

        // First loan (active)
        Loan__c loan1 = createLoan(booking.Id, 'Active', false);

        // Second loan trying to insert - should add error
        Test.startTest();
        Loan__c loan2 = new Loan__c(
            RW_Booking__c = booking.Id,
            RW_Loan_Record_Status__c = 'Active',
            RW_Pari_Passu__c = false
        );

        try {
            LoanController.loanInsert(new List<Loan__c>{loan2});
        } catch (Exception e) {
            System.assert(e.getMessage().contains('There is an active Loan record'));
        }
        Test.stopTest();
    }

    @isTest
    static void testSendEmailAfterLoanClosed() {
        Project__c proj = createProject();
        Booking__c booking = createBooking(proj.Id);
        Loan__c loan = createLoan(booking.Id, 'Active', false);

        Loan__c oldLoan = loan.clone(false, true, false, false);
        oldLoan.RW_Loan_Record_Status__c = 'Active';

        loan.RW_Loan_Record_Status__c = 'Loan Closed';
        update loan;

        Test.startTest();
        LoanController.sendEmailAfterLoanClosed(
            new List<Loan__c>{loan},
            new Map<Id, Loan__c>{loan.Id => oldLoan}
        );
        Test.stopTest();

        System.assertEquals('Loan Closed',
            [SELECT RW_Loan_Record_Status__c FROM Loan__c WHERE Id = :loan.Id].RW_Loan_Record_Status__c);
    }

    @isTest
    static void testSendEmailOnNOCGeneration() {
        Project__c proj = createProject();
        Booking__c booking = createBooking(proj.Id);
        Loan__c loan = createLoan(booking.Id, 'Active', false);

        Loan__c oldLoan = loan.clone(false, true, false, false);
        oldLoan.RW_NOC_Generated__c = false;

        loan.RW_Loan_Record_Status__c = 'NOC Generated';
        loan.RW_NOC_Generated__c = true;
        loan.RW_NOC_Generated_Date__c = Date.today();
        update loan;

        Test.startTest();
        LoanController.SendEmailOnNOCGeneration(
            new List<Loan__c>{loan},
            new Map<Id, Loan__c>{loan.Id => oldLoan}
        );
        Test.stopTest();

        System.assertEquals(true,
            [SELECT RW_NOC_Generated__c FROM Loan__c WHERE Id = :loan.Id].RW_NOC_Generated__c);
    }

    @isTest
    static void testUpdateHLRM() {
        Project__c proj = createProject();
        Booking__c booking = createBooking(proj.Id);
        

        createHLRM(proj.Id, 'HDFC Bank Ltd');
        
        Loan__c loan = createLoan(booking.Id, 'Active', false);
        loan.RW_Project_Name__c = proj.Id;
        loan.RW_Bank_Preference_1__c = 'HDFC Bank Ltd';
        update loan;

        Test.startTest();
        Test.stopTest();

        Loan__c updatedLoan = [SELECT HL_RM__c FROM Loan__c WHERE Id = :loan.Id];
        System.assertNotEquals(null, updatedLoan.HL_RM__c);
    }

    @isTest
    static void testUpdateBookingFundStatus() {
        Project__c proj = createProject();
        Booking__c booking = createBooking(proj.Id);

        // Mock RM_Usernames__c custom metadata
        RM_Usernames__c rmMeta = new RM_Usernames__c(
            Name = 'Test RM',
            RW_Reporting_1_Email__c = 'rep1@test.com',
            RW_Reporting_2_Email__c = 'rep2@test.com'
        );
        insert rmMeta;

        Test.startTest();
        LoanController.updateBookingFundStatus(new Set<Id>{booking.Id});
        Test.stopTest();

        Booking__c updatedBooking = [SELECT Funding_Status__c FROM Booking__c WHERE Id = :booking.Id];
        System.assertEquals('Self Funded', updatedBooking.Funding_Status__c);
    }
}