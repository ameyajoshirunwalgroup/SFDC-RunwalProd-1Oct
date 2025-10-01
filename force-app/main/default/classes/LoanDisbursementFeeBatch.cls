// Batch class to calculate Connector Fees for Disbursements between StartDate & EndDate
global class LoanDisbursementFeeBatch implements Database.Batchable<SObject>, Database.Stateful {

    Date startDate;
    Date endDate;

    // Constructor to pass StartDate and EndDate
    global LoanDisbursementFeeBatch(Date startDate, Date endDate) {
        this.startDate = startDate;
        this.endDate   = endDate;
    }

    // Query all disbursement details in date range
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Loan__c, Disbursement_Amount__c, Disbursement_Date__c,Disbursement_Type__c
            FROM Loan_Disbursement_Details__c
            WHERE Disbursement_Date__c >= :startDate 
              AND Disbursement_Date__c <= :endDate
              AND Loan__c != null
              AND Disbursement_Amount__c != null
        ]);
    }

    global void execute(Database.BatchableContext bc, List<Loan_Disbursement_Details__c> scope) {
        // Reuse your logic
        LoanDisbTrgHandler.calculateConnectorFees(scope, null);
        LoanDisbTrgHandler.handleSanctionCase(scope, null);
        update scope;
    }

    global void finish(Database.BatchableContext bc) {
        // Optional: Send email / log / chain another batch
        System.debug('Batch Completed for Connector Fee Calculation');
    }
}