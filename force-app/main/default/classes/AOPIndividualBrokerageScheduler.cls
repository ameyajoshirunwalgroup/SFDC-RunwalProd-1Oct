/**
 * @description Schedulable class to run the AOPIndividualBrokerageBatch automatically.
 * It is configured to run after the financial year has ended (e.g., April 10th) 
 * and processes the *Previous* Financial Year (FY) to finalize commission calculations.
 */
public class AOPIndividualBrokerageScheduler implements Schedulable {

    // Default batch size to 200 for good performance
    private static final Integer BATCH_SCOPE_SIZE = 200;

    /**
     * @description Executes the scheduler job. It determines the Financial Year that 
     * just concluded and passes it to the batch class constructor.
     * @param sc The SchedulableContext.
     */
    public void execute(SchedulableContext sc) {
        // 1. Determine the target Financial Year to process (The one that just ended)
        Date myDate = Date.newInstance(2026, 04, 10);
        String targetFY = getPreviousFinancialYearString(myDate);
        
        System.debug('Scheduling AOP Individual Brokerage Batch for PREVIOUS Financial Year: ' + targetFY);

        // 2. Instantiate and execute the batch class
        // The batch will process AOPs whose period overlaps with this target FY.
        AOPIndividualBrokerageBatch batchJob = new AOPIndividualBrokerageBatch(targetFY);
        
        Id jobId = Database.executeBatch(batchJob, BATCH_SCOPE_SIZE);
        
        System.debug('AOP Individual Brokerage Batch started with Job Id: ' + jobId);
    }
    
    /**
     * @description Calculates the Financial Year string (e.g., 'FY25-26') that 
     * concluded on the previous March 31st.
     * * Example: If called on 2026-04-10, it returns 'FY25-26'.
     * @param executionDate The date the scheduler is run.
     * @return The financial year string in 'FYXX-YY' format.
     */
    public static String getPreviousFinancialYearString(Date executionDate) {
        Integer currentYear = executionDate.year();
        Integer targetEndYear;

        // Financial Year (FY) runs from April 1st to March 31st.
        
        // If the execution is on or after April (month >= 4) of the current year (e.g., 2026-04-10), 
        // the FY we want to process is the one that ended on March 31st of this year (2026).
        if (executionDate.month() >= 4) {
            targetEndYear = currentYear; 
        } else {
            // If the execution is Jan-Mar, the FY we want to process ended on 
            // March 31st of the previous calendar year.
            targetEndYear = currentYear - 1; 
        }
        
        Integer targetStartYear = targetEndYear - 1;
        
        String startYearShort = String.valueOf(targetStartYear).right(2);
        String endYearShort = String.valueOf(targetEndYear).right(2);
        
        return 'FY' + startYearShort + '-' + endYearShort;
    }
}