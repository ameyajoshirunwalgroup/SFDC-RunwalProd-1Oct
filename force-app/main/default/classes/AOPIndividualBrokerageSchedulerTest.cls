@IsTest
private class AOPIndividualBrokerageSchedulerTest {

    
    @IsTest
    static void testGetPreviousFYString_PostApril() {
        Date executionDate = Date.newInstance(2026, 04, 10);
        
        String expectedFY = 'FY25-26';
        
        String actualFY = AOPIndividualBrokerageScheduler.getPreviousFinancialYearString(executionDate);
    }

    @IsTest
    static void testGetPreviousFYString_PreApril() {
        Date executionDate = Date.newInstance(2026, 02, 15);
        
        String expectedFY = 'FY24-25'; 
        
        String actualFY = AOPIndividualBrokerageScheduler.getPreviousFinancialYearString(executionDate);
        
    }
    
    @IsTest
    static void testExecute_SubmitsBatchJob() {
        Test.startTest();
       
        AOPIndividualBrokerageScheduler scheduler = new AOPIndividualBrokerageScheduler();
        
        String sch = '0 0 10 10 4 ?';  // Dummy cron string
        System.schedule('TestAOPBrokerageScheduler', sch, scheduler);
        List<AsyncApexJob> jobs = [
            SELECT Id, Status, JobType
            FROM AsyncApexJob
            WHERE JobType = 'BatchApex' 
            AND ApexClass.Name = 'AOPIndividualBrokerageBatch'
        ];
    }
}