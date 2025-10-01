@isTest
public class TestBatchForBrokerageCalculation {
    @isTest
    public static void TestBatchForBrokerageCalculation() {
        
        Project__c objpr = new Project__c(
            RW_Project_Code__c = 'T31',
            Name = 'Runwal Bliss',
            RDS_Short_Name__c = 'T',
            Start_Date__c = System.today().addDays(-5),
            RDS_Interest_Rate__c = 12
        );
        insert objpr;
        
        Id CPRecordTypeId = Schema.SObjectType.Broker__c.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
        
        Broker__c cp = new Broker__c(
            Name = 'Test CP',
            RW_Email__c = 'test@test.com',
            Individual_CP__c = true,
            Place_of_Supply__c = 'Maharashtra',
            RecordTypeId = CPRecordTypeId,
            Registration_Complete__c = true,
            RW_Mobile_No__c = '1234567890',
            Broker_Type__c = 'Individual',
            Broker_Pan_No__c = 'ADRPI3525F',
            RW_RERA_Registration_Number__c = '123456789012',
            Company_Name_As_per_RERA__c = 'RERA Company',
            RERA_Valid_till__c = System.today().addDays(10),
            CC_Valid_till__c = System.today().addDays(10),
            Latest_RERA_Upload_Status__c = 'Approved',
            Latest_CC_Upload_Status__c = 'Approved'
        );
        insert cp;
        
        Account acc = new Account(Name = 'Test Acc');
        insert acc;
        
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Qualification',
            CloseDate = System.today(),
            AccountId = acc.Id
        );
        insert opp;
        
        Booking__c b = new Booking__c(
            //Name = 'Test Booking',
            Project__c = objpr.Id,
            Opportunity__c = opp.Id,
            Status__c = 'Booking Confirmed',
            RW_Registration_Done__c = 'No',
            BrokerIId__c = cp.Id,
            Exclude_From_Brokerage_Batch__c = false,
            Source_of_Booking__c = 'Channel Partner',
            RW_Registration_Date__c = Date.today(),
            Type_of_Client__c = 'Local',
            Booking_Date__c = Date.today(),
            Allotment_Premium__c = 10000000,
        	RW_Total_Receipt_Amount_Received__c = 5000000
            //X5_Received__c = true
        );
        insert b;
        
        RW_Demand__c dmd2 = new RW_Demand__c();
        dmd2.Booking__c =b.id;
        dmd2.name= '890890';
        dmd2.RW_Billing_Document_Number__c = '890890';
        dmd2.RW_Customer_Number__c = '12345678';
        insert dmd2;
        
        RW_Demand_Item__c dmid1= new RW_Demand_Item__c();
        dmid1.RW_Demand_Item_Amount__c =200000;
        dmid1.RW_Demand__c = dmd2.id;
        dmid1.RW_GST_Amount__c = 1000;
        dmid1.RW_Legacy_Amount_Paid__c = 5000;
        dmid1.RW_Legacy_Demand__c = true;
        dmid1.Total_Demand_Item_Amount_Paid__c = 200000;
        insert dmid1;
        
        Test.startTest();
        BatchForBrokerageCalculation bb = new BatchForBrokerageCalculation();
        Database.executeBatch(bb, 1);
        Test.stopTest();
    }
}