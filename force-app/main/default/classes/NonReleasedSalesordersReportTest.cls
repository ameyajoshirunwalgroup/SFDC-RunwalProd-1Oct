@isTest
public class NonReleasedSalesordersReportTest {
    
    @isTest
    public static void soReporttest(){
        
        Project__c proj = new Project__c();
        proj.Name = 'Test Project';
        insert proj;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.StageName = 'Unit Booked';
        opp.CloseDate = Date.today() + 10;
        opp.SAP_Customer_Number__c = '1234';
        opp.SalesOrder_Number__c = '5678';
        opp.RW_Sales_Associate__c = 'Test';
        insert opp;
        
        Booking__c bkg = new Booking__c();
        bkg.Status__c = 'Booking Confirmed';
        bkg.Project__c = proj.Id;
        bkg.Opportunity__c = opp.Id;
        insert bkg;
        
        NonReleasedSalesordersReport sch = new NonReleasedSalesordersReport();
        Test.StartTest();
        NonReleasedSalesordersReport.nonReleasedSoReportProject();
        NonReleasedSalesordersReport.nonReleasedSoReportSM();
        /*String cronExp = '0 0 * * * ?';
        String jobID = System.schedule('NonReleasedSalesordersReport', cronExp, sch);*/
        Test.stopTest(); 
    }

}