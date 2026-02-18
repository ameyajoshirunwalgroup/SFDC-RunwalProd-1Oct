@isTest
public class BatchSendReportLinkTest {

  
    @isTest
    static void testBatchSendReportLink() {
          User u1 = TestDataFactory.createUserSysAdmin('One','Galvatron', 'galvatron456@radius.com', 'galvatron456@radius.com');
        Legal_Entity__c le=New Legal_Entity__c();
        le.Name='Testing';
        // le.SAP_ID__c='Test';
        //le.Project__c=objpr.id;
        insert le;
        Project__c objpr = new Project__c();
        objpr.Name = 'Runwal Avenue';
        objpr.RDS_Short_Name__c = 'T';
        objpr.RDS_Company_Code__c=le.id;
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        //  objpr.Project_Email_id__c = 'test@stetig.in';
        insert objpr;
        Cluster__c clusterObj=new Cluster__c();
        clusterObj.Name='Test';
        insert clusterObj;
        
       

        Tower__c towerObj = new Tower__c();
        towerObj.Name ='Test Tower';
        towerObj.ProjectName__c = objpr.Id;
        towerObj.Zone_Name__c = clusterObj.Id;
        insert towerObj;
        
        Project_Unit_Type__c objPUT = new Project_Unit_Type__c();
        objPUT.Name = 'TestUnit';
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.id;
        insert objPUT;
        
        Project_Unit__c objPUU = new Project_Unit__c();  
        objPUU.Project_Unit_Type__c = objPUT.id;  
        objPUU.Name = 'TestUnit1';      
        objPUU.RW_Project__c = objpr.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='10';
        objPUU.RW_Unit_Status__c ='Available';
        insert objPUU;
        
        
        Account a = new Account(lastName='portal account', personEmail = 'standarduser@testorg.com', personMobilePhone= '908089900', 
                                Mobile_No__c = '1212121212',RW_Customer_Type__c = 'NRI',
                                RW_Occupation__c = 'test',RW_Ethnicity__c = 'test' ,Birth_Date__c =date.valueOf(system.now().addDays(-10)),
                                Spouse_DOB__c = date.valueOf(system.now().addDays(-10)),Gender__c='male');
        insert a;
        
        Opportunity opp = new Opportunity();
        opp.StageName = 'Unit Booked';
        opp.AccountId = a.Id;
        opp.Name = 'Test';
        opp.CloseDate = System.today()+10;
        insert opp;
        
        Booking__c b = new Booking__c();
        b.Opportunity__c = opp.Id;
        b.Booking_Date__c=System.today().addDays(-5);
        b.RW_Registration_Done__c='No';
        b.Source_of_Booking__c='Referral';
        b.Unit_No__c = objPUU.Id;
        insert b;
        // Start the test context
        Test.startTest();

        // Execute the batch
        BatchSendReportLink batch = new BatchSendReportLink();
        Database.executeBatch(batch);
        

        Test.stopTest();

      
       
        
       
    }

    @isTest
    static void testFormatCustomDate() {
        // Test the formatCustomDate method
        BatchSendReportLink batch = new BatchSendReportLink();
        Date inputDate = Date.newInstance(2023, 9, 20);
    }
}