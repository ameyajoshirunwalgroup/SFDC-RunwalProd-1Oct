@isTest
public class MarketingDashboardControllerTest {

    @isTest
    public static void marketingDashboardTest1() {

        Integer currentYear = Date.today().year();
        Integer currentMonth = Date.today().month();

        Project__c proj = new Project__c();
        proj.Name = 'Test Project';
        proj.RW_Status__c = 'Active';
        insert proj;

        Company_Target__c target = new Company_Target__c();
        target.Projects__c = proj.Id;
        target.Year__c = String.valueOf(currentYear);
        target.Month__c = String.valueOf(currentMonth);
        target.of_Leads__c = 10;
        target.Walkins_Target__c = 10;
        target.Booking_count_target__c = 10;
        target.Target_in_Cr__c = 10;
        insert target;

        Lead l = new Lead();
        l.LastName = 'Test Lead';
        l.LeadSource = 'Digital';
        l.RW_Project__c = proj.Id;
        l.Email = 'test@mail.com';
        l.RW_Mobile_No__c = '1235698745';
        insert l;

        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.LeadSource = 'Digital';
        opp.RW_Project__c = proj.Id;
        opp.StageName = 'Qualification';
        opp.CloseDate = Date.today() + 10;
        insert opp;

        Booking__c bkg = new Booking__c();
        bkg.Opportunity__c = opp.Id;
        bkg.Customer__c = opp.Id;
        bkg.Project__c = proj.Id;
        bkg.Allotment_Premium__c = 1000000;
        insert bkg;

        MarketingDashboardController.getProjects();
        MarketingDashboardController.getTableData('table1', String.valueOf(currentYear), String.valueOf(currentMonth), 'Digital', 'Custom', 'All');
        MarketingDashboardController.getTableData('table2', String.valueOf(currentYear), String.valueOf(currentMonth), 'Digital', 'Custom', 'All');
        MarketingDashboardController.getTableData('table3', String.valueOf(currentYear), String.valueOf(currentMonth), 'Digital', '', 'All');
        MarketingDashboardController.getTableData('table4', String.valueOf(currentYear), String.valueOf(currentMonth), 'Digital', 'Custom', 'All');
        MarketingDashboardController.getTableData('table4', String.valueOf(currentYear), String.valueOf(currentMonth), 'Digital', '', 'All');
        MarketingDashboardController.getTableData('table6', String.valueOf(currentYear), String.valueOf(currentMonth), 'Digital', 'Custom', 'All');
        MarketingDashboardController.getTableData('table7', String.valueOf(currentYear), String.valueOf(currentMonth), 'Digital', 'Custom', 'All');
    }

    @isTest
    public static void marketingDashboardTest2() {
        Integer currentYear = Date.today().year();
        Integer currentMonth = Date.today().month();
        
        Project__c proj = new Project__c();
        proj.Name = 'Test Project';
        proj.RW_Status__c = 'Active';
        insert proj;

        Target__c target = new Target__c();
        target.Project__c = proj.Id;
        target.Target_Year__c = String.valueOf(currentYear);
        target.Target_Month__c = String.valueOf(currentMonth);
        target.New_Digital_Leads__c = 10;
        target.New_Digital_Walkins__c = 10;
        target.New_Digital_Bookings__c = 10;
        target.New_Digital_Booking_Revenue_in_CR__c = 10;
        insert target;

        Budget_vs_Expenses__c be = new Budget_vs_Expenses__c();
        be.Project__c = proj.Id;
        be.Year__c = String.valueOf(currentYear);
        insert be;

        MarketingDashboardController.getTableData('table1', String.valueOf(currentYear), String.valueOf(currentMonth), 'Digital', 'THIS_MONTH', 'All');
        MarketingDashboardController.getTableData('table2', String.valueOf(currentYear), String.valueOf(currentMonth), 'Digital', 'THIS_MONTH', 'All');
        MarketingDashboardController.getTableData('table3', String.valueOf(currentYear), String.valueOf(currentMonth), 'Digital', 'THIS_MONTH', 'All');
        MarketingDashboardController.getTableData('table4', String.valueOf(currentYear), String.valueOf(currentMonth), 'Digital', 'THIS_MONTH', 'All');
        MarketingDashboardController.getTableData('table5', String.valueOf(currentYear), '', 'Digital', '', 'All');
        MarketingDashboardController.getTableData('table6', String.valueOf(currentYear), String.valueOf(currentMonth), 'Digital', 'THIS_MONTH', 'All');
        MarketingDashboardController.getTableData('table7', String.valueOf(currentYear), String.valueOf(currentMonth), 'Digital', 'THIS_MONTH', 'All');
        MarketingDashboardController.getTableData('table8', String.valueOf(currentYear), String.valueOf(currentMonth), 'Digital', 'THIS_MONTH', 'All');
        MarketingDashboardController.generateCSV('table1', String.valueOf(currentYear), String.valueOf(currentMonth), 'Digital', 'THIS_MONTH', 'All');
    }

    @isTest
    public static void marketingDashboardTest3() {
        Integer currentYear = Date.today().year();
        Integer currentMonth = Date.today().month();

        Project__c proj = new Project__c();
        proj.Name = 'Test Project';
        proj.RW_Status__c = 'Active';
        insert proj;

        Company_Target__c target = new Company_Target__c();
        target.Projects__c = proj.Id;
        target.Year__c = String.valueOf(currentYear);
        target.Month__c = String.valueOf(currentMonth);
        target.of_Leads__c = 10;
        target.Walkins_Target__c = 10;
        target.Booking_count_target__c = 10;
        target.Target_in_Cr__c = 10;
        insert target;

        Lead l = new Lead();
        l.LastName = 'Test Lead';
        l.LeadSource = 'Digital';
        l.RW_Project__c = proj.Id;
        l.Email = 'test@mail.com';
        l.RW_Mobile_No__c = '1235698745';
        insert l;

        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.LeadSource = 'Digital';
        opp.RW_Project__c = proj.Id;
        opp.StageName = 'Qualification';
        opp.CloseDate = Date.today() + 10;
        insert opp;

        Booking__c bkg = new Booking__c();
        bkg.Opportunity__c = opp.Id;
        bkg.Customer__c = opp.Id;
        bkg.Project__c = proj.Id;
        bkg.Allotment_Premium__c = 1000000;
        insert bkg;

        Budget_vs_Expenses__c be = new Budget_vs_Expenses__c();
        be.Project__c = proj.Id;
        be.Year__c = String.valueOf(currentYear);
        insert be;

        MarketingDashboardController.generateCSV('table1', String.valueOf(currentYear), String.valueOf(currentMonth), 'Digital', 'THIS_MONTH', 'All');
        MarketingDashboardController.generateCSV('table2', String.valueOf(currentYear), String.valueOf(currentMonth), 'Digital', 'THIS_MONTH', 'All');
        MarketingDashboardController.generateCSV('table3', String.valueOf(currentYear), String.valueOf(currentMonth), 'Digital', 'THIS_MONTH', 'All');
        MarketingDashboardController.generateCSV('table4', String.valueOf(currentYear), String.valueOf(currentMonth), 'Digital', 'THIS_MONTH', 'All');
        MarketingDashboardController.generateCSV('table5', String.valueOf(currentYear), '', 'Digital', '', 'All');
        MarketingDashboardController.generateCSV('table6', String.valueOf(currentYear), String.valueOf(currentMonth), 'Digital', 'THIS_MONTH', 'All');
    }

    @isTest
    public static void marketingDashboardTest4(){

        Integer currentYear = Date.today().year();
        Integer currentMonth = Date.today().month();

        Project__c proj = new Project__c();
        proj.Name = 'Test Project';
        proj.RW_Status__c = 'Active';
        insert proj;

        Lead l = new Lead();
        l.LastName = 'Test Lead';
        l.LeadSource = 'Digital';
        l.RW_Project__c = proj.Id;
        l.Email = 'test@mail.com';
        l.RW_Mobile_No__c = '1235698745';
        insert l;

        l.Status = 'Junk';
        update l;

        MarketingDashboardController.getTableData('table3', String.valueOf(currentYear), String.valueOf(currentMonth), '', '', 'All');
        MarketingDashboardController.getTableData('table3', String.valueOf(currentYear), String.valueOf(currentMonth), 'Digital', 'THIS_MONTH', 'All');
        MarketingDashboardController.getTableData('table6', String.valueOf(currentYear), String.valueOf(currentMonth), 'Digital', 'LAST_N_DAYS:7', 'All');
        MarketingDashboardController.getTableData('table6', String.valueOf(currentYear), String.valueOf(currentMonth), 'Digital', 'LAST_N_DAYS:15', 'All');
        MarketingDashboardController.getTableData('table6', String.valueOf(currentYear), String.valueOf(currentMonth), 'Digital', 'LAST_N_DAYS:30', 'All');
        MarketingDashboardController.getTableData('table6', String.valueOf(currentYear), String.valueOf(currentMonth), 'Digital', 'LAST_N_MONTHS:3', 'All');
        MarketingDashboardController.getTableData('table6', String.valueOf(currentYear), String.valueOf(currentMonth), 'Digital', 'LAST_N_MONTHS:6', 'All');
        MarketingDashboardController.getTableData('table6', String.valueOf(currentYear), String.valueOf(currentMonth), 'Digital', 'THIS_FISCAL_YEAR', 'All');
        MarketingDashboardController.getTableData('table6', String.valueOf(currentYear), String.valueOf(currentMonth), 'Digital', 'LAST_FISCAL_YEAR', 'All');
    }
}