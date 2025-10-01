@isTest
public class BatchforP1toP4CategoryCreationTest {
    @isTest
    static void testBatchforP1toP4CategoryCreation() {
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
        objpr.Segment__c = 'Runwal City Center';
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
        
        Broker__c cp = new Broker__c();
        cp.Name = 'Test CP';
        cp.RW_Email__c = 'teststetig@stetig.in';
        cp.Individual_CP__c = true;
        cp.RW_CreateFromIRIS__c = true;
        cp.RW_IRIS_Sync__c = true;
        cp.Place_of_Supply__c = 'Maharashtra';
        cp.Channel_Partner_From_CP_Portal__c = true;
        cp.Project__c = 'Runwal Bliss';
        cp.Approver_L1__c = userinfo.getUserId();
        cp.Approver_L2__c = userinfo.getUserId();
        cp.Registration_Complete__c = true;
        cp.RW_Mobile_No__c = '1234567890';
        cp.Broker_Type__c = 'Individual';
        cp.Broker_Pan_No__c = 'ADRPI3525F';
        cp.RW_RERA_Registration_Number__c = '123256789012';
        cp.RW_Mobile_No__c = '1234567890';
        insert cp;
        
        CP_Category__c pl = new CP_Category__c();
        pl.Segment__c = 'Runwal City Center';
        pl.Category__c = 'P1';
        pl.Channel_Partner__c = cp.Id;
        pl.Start_Date__c = System.today().addDays(-100);
        pl.End_Date__c = System.today().addDays(-20);
        String currentYr = String.valueOf(System.today().year());	
        pl.Relevant_FY__c = currentYr;
        insert pl;
        
        
        
        Account a = new Account(lastName='portal account', personEmail = 'standarduser@testorg.com', personMobilePhone= '908089900', 
                                Mobile_No__c = '1212121212',RW_Customer_Type__c = 'NRI',
                                RW_Occupation__c = 'test',RW_Ethnicity__c = 'test' ,Birth_Date__c =date.valueOf(system.now().addDays(-10)),
                                Spouse_DOB__c = date.valueOf(system.now().addDays(-10)),Gender__c='male');
        insert a;
        
        Opportunity opp = new Opportunity();
        opp.StageName = 'Unit Booked';
        opp.RW_Project__c = objpr.Id;
        opp.AccountId = a.Id;
        opp.Name = 'Test';
        opp.CloseDate = System.today()+10;
        opp.RW_Walkin_Channel_Partner__c = cp.id;
        opp.First_Site_Visit_Date__c = System.today().addDays(-50);
        insert opp;
        
        Booking__c b = new Booking__c();
        b.Opportunity__c = opp.Id;
        b.Project__c = objpr.Id;
        b.Status__c = 'Booking Confirmed';
        b.BrokerIId__c = cp.Id;
        b.Booking_Date__c= System.today().addDays(-50);
        b.RW_Registration_Done__c='No';
        b.Source_of_Booking__c='Referral';
        b.Unit_No__c = objPUU.Id;
        insert b;
        
        
        // Start the test context
        Test.startTest();
        ScheduleBatchforP1toP4CategoryCreation j = new ScheduleBatchforP1toP4CategoryCreation();
        j.execute(null);
        Test.stopTest();
    }
    
}