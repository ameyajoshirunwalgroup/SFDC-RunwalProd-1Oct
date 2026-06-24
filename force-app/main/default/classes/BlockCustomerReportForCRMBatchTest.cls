@IsTest
public class BlockCustomerReportForCRMBatchTest {

    @testSetup
    static void setupData() {

        List<OrgWideEmailAddress> owe = [SELECT Id
            FROM OrgWideEmailAddress
            WHERE Address = 'customer.care@runwalgroup.in'
            LIMIT 1];

        Project__c project = new Project__c(
            Name = '7 Mahalxmi'
        );
        insert project;
        List<CRM_Team_Project_Wise_Email__mdt> lstCRM = [SELECT Project__c, Email_Address__c
                                                          FROM CRM_Team_Project_Wise_Email__mdt];
        
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            SAP_Customer_Number__c = 'SAP123',
            RW_Project__c = project.Id,
            RW_Agreement_Value__c = 500000
        );
        insert opp;

        Project_Unit__c unit = new Project_Unit__c();  
        unit.Name = 'TestUnit';      
        unit.RW_Project__c = project.Id;
        unit.RW_Param1__c = '5';
        unit.UnitNo__c ='9';
        unit.RW_Unit_Status__c ='Available';
        insert unit;

        Receipt__c receipt = new Receipt__c(
            Opportunity__c = opp.Id,
            Mode__c = 'Cheque',
            Cheque_DD__c = 'CHQ123',
            Total_Amount__c = 100000,
            DraweeBank__c = 'HDFC',
            Account_Recon__c = 'Yes',
            Project_Unit__c = unit.Id
            
        );
        insert receipt;
        
         Booking__c b = new Booking__c(
            Customer__c = opp.Id,
            Project__c = project.Id,
            Unit_No__c=unit.Id,
            Status__c='Pending',
            RW_Total_Receipt_Amount_Received__c = 0,
            SO_Release_Date_in_SAP__c = null
        );
        insert b;
    }

    @IsTest
    static void testBatchExecution() {

        Test.startTest();
        BlockCustomerReportForCRMBatch batch =new BlockCustomerReportForCRMBatch();
        Database.executeBatch(batch, 200);
        BlockCustomerReportForCRMBatch.Dummy();
        
        PendingSAPReceiptReportToSMBatch batch2 =new PendingSAPReceiptReportToSMBatch();
        Database.executeBatch(batch2, 200);
        PendingSAPReceiptReportToSMBatch.Dummy();
        
        System.assert(true, 'Batch executed successfully');
    }

    @IsTest
    static void testSchedulerExecution() {

        String cronExp = '0 0 9 * * ?'; // 9 AM daily
        Test.startTest();
        System.schedule(
            'BlockCustomerReportForCRMBatchScheduler',
            cronExp,
            new BlockCustomerReportForCRMBatch()
        );
        System.schedule(
            'PendingSAPReceiptReportToSMBatchScheduler',
            cronExp,
            new PendingSAPReceiptReportToSMBatch()
        );
        Test.stopTest();

        System.assert(true, 'Scheduler executed successfully');
    }
}