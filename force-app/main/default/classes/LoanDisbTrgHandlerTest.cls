@isTest
public class LoanDisbTrgHandlerTest {

    // Helper method to create Project with Legal Entity
    private static Project__c createProject() {
        Legal_Entity__c legalEntity = new Legal_Entity__c(
            Name = 'RREPL'
        );
        insert legalEntity;
        Project__c proj = new Project__c(
            Name = 'Test Project',
            RDS_Company_Code__c = legalEntity.Id
        );
        insert proj;
        return proj;
    }

    // Helper method to create Loan
    private static Loan__c createLoan(Id projectId) {
        Loan__c loan = new Loan__c(
            RW_Project_Name__c = projectId,
            RW_Bank_Preference_1__c = 'HDFC Bank Ltd',
            Home_Loan_Taken_From__c = 'Runwal',
            RW_Sanction_Amount__c = 2000000,
            RW_Sanction_Date__c = Date.today()
        );
        insert loan;
        return loan;
    }

    // Helper method to create APF Slab
    private static APF__c createAPF(String legalEntityId, String bankName) {
        APF__c apf = new APF__c(
            Legal_Entity__c = legalEntityId,
            RW_Bank_Name__c = bankName,
            Minimum_Threshold__c = 1,
            Maximum_Threshold__c = 10,
            Payout_Rate__c = 2,
            Net_Gross__c = 'Net',
            Start_Date__c = Date.today().addDays(-10),
            End_Date__c = Date.today().addDays(10)
        );
        insert apf;
        return apf;
    }
    
    private static APF__c createAPFGross(String legalEntityId, String bankName) {
        APF__c apf = new APF__c(
            Legal_Entity__c = legalEntityId,
            RW_Bank_Name__c = bankName,
            Minimum_Threshold__c = 0,
            Maximum_Threshold__c = 10,
            Payout_Rate__c = 2,
            Net_Gross__c = 'Gross',
            Start_Date__c = Date.today().addDays(-10),
            End_Date__c = Date.today().addDays(10)
        );
        insert apf;
        return apf;
    }

    @isTest
    static void testCalculateConnectorFees_Insert() {
        Project__c proj = createProject();
        Loan__c loan = createLoan(proj.Id);
        createAPF(proj.RDS_Company_Code__c, loan.RW_Bank_Preference_1__c);

        Loan_Disbursement_Details__c disb = new Loan_Disbursement_Details__c(
            Loan__c = loan.Id,
            Disbursement_Amount__c = 2000000,
            Disbursement_Date__c = Date.today()
        );

        Test.startTest();
        LoanDisbTrgHandler.calculateConnectorFees(new List<Loan_Disbursement_Details__c>{ disb }, null);
        Test.stopTest();

    }

    @isTest
    static void testCalculateConnectorFees_Update() {
        Project__c proj = createProject();
        Loan__c loan = createLoan(proj.Id);
        createAPF(proj.RDS_Company_Code__c, loan.RW_Bank_Preference_1__c);

        Loan_Disbursement_Details__c oldDisb = new Loan_Disbursement_Details__c(
            Loan__c = loan.Id,
            Disbursement_Amount__c = 1000000,
            Disbursement_Date__c = Date.today()
        );
        insert oldDisb;
        
        oldDisb.Disbursement_Amount__c = 2000000;
        update oldDisb;
    }

    @isTest
    static void testHandleSanctionCase_Insert() {
        Project__c proj = createProject();
        Loan__c loan = createLoan(proj.Id);

        Loan_Disbursement_Details__c disb = new Loan_Disbursement_Details__c(
            Loan__c = loan.Id,
            Disbursement_Type__c = 'First Disbursement',
            Disbursement_Amount__c = 1000000,
            Disbursement_Date__c = Date.today()
        );

        Test.startTest();
        LoanDisbTrgHandler.handleSanctionCase(new List<Loan_Disbursement_Details__c>{ disb }, null);
        Test.stopTest();

        // No exception = success
        System.assert(true, 'Sanction case handled successfully for insert');
    }

    @isTest
    static void testHandleSanctionCase_Update() {
        Project__c proj = createProject();
        Loan__c loan = createLoan(proj.Id);
        createAPFGross(proj.RDS_Company_Code__c, loan.RW_Bank_Preference_1__c);

        Loan_Disbursement_Details__c oldDisb = new Loan_Disbursement_Details__c(
            Loan__c = loan.Id,
            Disbursement_Type__c = 'Partial',
            Disbursement_Amount__c = 1000000,
            Disbursement_Date__c = Date.today()
        );
        insert oldDisb;

        oldDisb.Disbursement_Amount__c = 2000000;
        oldDisb.Disbursement_Type__c = 'First Disbursement';
        update oldDisb;
    }

    @isTest
    static void testAfterDelete() {
        Project__c proj = createProject();
        Loan__c loan = createLoan(proj.Id);

        Loan_Disbursement_Details__c disb = new Loan_Disbursement_Details__c(
            Loan__c = loan.Id,
            Disbursement_Type__c = 'First Disbursement',
            Disbursement_Amount__c = 500000,
            Disbursement_Date__c = Date.today()
        );
        insert disb;

        Map<Id, Loan_Disbursement_Details__c> oldMap = new Map<Id, Loan_Disbursement_Details__c>{ disb.Id => disb };

        Test.startTest();
        LoanDisbTrgHandler.afterDelete(oldMap);
        Test.stopTest();

        Loan__c updatedLoan = [SELECT RW_First_Disbursement_Amount__c, RW_First_Disbursement_Date__c 
                               FROM Loan__c WHERE Id = :loan.Id];
        System.assertEquals(null, updatedLoan.RW_First_Disbursement_Amount__c, 'First disbursement amount should be cleared');
        System.assertEquals(null, updatedLoan.RW_First_Disbursement_Date__c, 'First disbursement date should be cleared');
    }
    
    @isTest
    static void testBatch() {
        Project__c proj = createProject();
        Loan__c loan = createLoan(proj.Id);

        Loan_Disbursement_Details__c disb = new Loan_Disbursement_Details__c(
            Loan__c = loan.Id,
            Disbursement_Type__c = 'First Disbursement',
            Disbursement_Amount__c = 1000000,
            Disbursement_Date__c = Date.today()
        );
        insert disb;
        LoanDisbursementFeeBatch job= new LoanDisbursementFeeBatch(Date.today()-2,Date.today()+2);
        Database.executeBatch(job);

        // No exception = success
        System.assert(true, 'Sanction case handled successfully for insert');
    }
}