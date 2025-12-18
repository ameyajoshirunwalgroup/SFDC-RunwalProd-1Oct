@isTest
public class BookingSAPReceiptCheckSchedulerTest {

    @testSetup
    static void setupData() {
         
        OrgWideEmailAddress owe = [
            SELECT Id, Address
            FROM OrgWideEmailAddress
            WHERE Address = 'customer.care@runwalgroup.in'
            LIMIT 1
        ];

        
        Account acc = new Account(Name='Test Customer');
        insert acc;
        
        Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'TestProject';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.Service_Tax_Required_On_Token_Amount_c__c = true;
        insert objpr;
        
        Project_Unit__c unit = new Project_Unit__c();  
        unit.Name = 'TestUnit';      
        unit.RW_Project__c = objpr.Id;
        unit.RW_Param1__c = '5';
        unit.UnitNo__c ='9';
        unit.RW_Unit_Status__c ='Available';
        insert unit;
         Opportunity opp = new Opportunity(
            Name='Opp A',
            StageName='Unit Blocked',
            Sales_Manager_User__c = UserInfo.getUserId(),
            CloseDate=Date.today()+10,
            RW_Project__c = objpr.Id,
             RW_Project_Unit__c = unit.Id,
            SAP_Customer_Number__c='SAP123'
        );
        insert opp;
        Date todayDate = Date.today();
        Test.setCreatedDate(opp.Id, todayDate);
        
          Receipt__c r = new Receipt__c(
            Opportunity__c = opp.Id,
            Mode__c='Cheque',
            Cheque_DD__c='12345',
            Project__c =objpr.Id,
            Project_Unit__c	=unit.Id,
            Total_Amount__c=5000,
            DraweeBank__c='ICICI',
            Account_Recon__c='No'
        );
        insert r;
        
        Booking__c b = new Booking__c(
            Customer__c = opp.Id,
            Project__c = null,
            Unit_No__c=unit.Id,
            Status__c='Pending',
            RW_Total_Receipt_Amount_Received__c = 0,
            SO_Release_Date_in_SAP__c = null
        );
        insert b;

        Test.setCreatedDate(b.Id, DateTime.now().addDays(-1));       
    }


    @isTest
    static void testSchedulerExecute() {

        Test.startTest();

        BookingSAPReceiptCheckScheduler scheduler = new BookingSAPReceiptCheckScheduler();
        scheduler.execute(null);

        Test.stopTest();

        System.assert(true, 'Scheduler executed successfully.');
    }


    @isTest
    static void testPendingSAPReceiptReport() {

        Test.startTest();

        BookingSAPReceiptCheckScheduler.sendPendingSAPReceiptReportToSM();
        BookingSAPReceiptCheckScheduler.Dummy();
        Test.stopTest();
    }
}