@isTest
public class EOIProjectUnitTriggerTest 
{
    @testSetup
    private static void EOITest() 
    {
     Account a1 = new Account();
        a1.FirstName ='TestAccount11';
        a1.LastName ='TestAccount22';
        a1.PersonEmail = 'wc@email.com';
        a1.City__c='TestCity';
        a1.RW_Zip_Code__c = '9999999';
        a1.State__c ='Karnataka';
        a1.Country__c ='India';
        a1.Mobile_No__c = '9876543212';
        a1.Alternate_Email__c = 'wc1@email.com';
        a1.Gender__c='Male';
        a1.Salutation = 'Mr.';
        a1.Birth_Date__c = System.today().addYears(-20);   
        insert a1;
        
        Project__c objpr1 = new Project__c();
        objpr1.RW_Project_Code__c = 'T32';
        objpr1.Name = 'Runwal Bliss1';
        objpr1.RDS_Short_Name__c = 'T';
        objpr1.Start_Date__c = System.today().addDays(-5);
        objpr1.RDS_Interest_Rate__c = 12;
        //objpr.Sales_Site_Head__c = tuser.Id;
        objpr1.SAPMaterial_Code__c = '12111';
        insert objpr1;
        
        Tower__c towerRec = new Tower__c();
        towerRec.ProjectName__c = objpr1.id;
        towerRec.Name = 'A';
        towerRec.SAP_Plant_Code__c = '111';
        towerRec.RW_Terms_And_Conditions__c ='TC';
        insert towerRec;
        
        Opportunity oppRec1= new Opportunity();
        oppRec1.RW_Project__c=objpr1.id;
        oppRec1.name='Test 2';
        oppRec1.RW_Email__c=a1.PersonEmail;
        oppRec1.StageName='Qualification';
        oppRec1.CloseDate=system.today();
        oppRec1.Status__c ='Active';
        oppRec1.AccountId = a1.Id;
        oppRec1.Sales_Manager__c = 'SM21@g.com';
        oppRec1.Sourcing_Manager__c='Aniket Sapre';
        oppRec1.RW_Sourcing_Head__c='Adrian Dsouza';
        oppRec1.RW_Sales_Associate__c='Karthik Chettiar';
        oppRec1.RW_Closing_Head__c='Karthik Chettiar';
        oppRec1.Walkin_Source__c='Direct';
        insert oppRec1;
        RW_EOI__c eoiRecord1 = new RW_EOI__c();
        eoiRecord1.RW_Status__c = 'EOI Blocked';
        eoiRecord1.Opportunity__c= oppRec1.id;
        insert eoiRecord1;
        
        Project_Unit_Type__c objPUT1 = new Project_Unit_Type__c();
        objPUT1.RDS_Code__c = '102';
        objPUT1.RDS_Project__c = objpr1.Id;
        insert objPUT1;
        system.debug('*before*');
		 Project_Unit__c objPUU1 = new Project_Unit__c();  
        objPUU1.Project_Unit_Type__c = objPUT1.id;  
        //objPUU1.Name = 'TestUnit1';      
        objPUU1.RW_Project__c =objpr1.Id;
        objPUU1.RW_Param1__c = '6';
        objPUU1.UnitNo__c ='10';
        objPUU1.RW_Unit_Status__c ='Available';
        objPUU1.TowerName__c = towerRec.Id;
        //objPUU1.RW_Customer__c=oppRec1.id;
        objPUU1.EOI__c=eoiRecord1.Id;     
        
        insert objPUU1;
        
        
        oppRec1.RW_Project_Unit__c=objPUU1.Id;
        update oppRec1;
         system.debug('*after*');
       
        
    }
    
    @isTest
    private static void testtrgToUpdateOppStageHandler()
    {
        List<Opportunity> oppRecords = [Select id from Opportunity];
         List<Project_Unit__c> punit = [Select id from Project_Unit__c];
        checkRecursion.resetFirstRun();
        //system.debug('*check*'+checkRecursion.isFirstRun()+'$$'+punit[0]);
        //Test.startTest();
        Test.startTest();
        Test.setMock(WebServiceMock.class, new CustomerCreationWebServiceMockImpl());
        Project_Unit__c objPUU1 = new Project_Unit__c();
        objPUU1.Id = punit[0].Id;
        objPUU1.RW_Unit_Status__c ='Booked';
        objPUU1.RW_Booking_Date__c = SYstem.today();
        objPUU1.RW_Customer__c=oppRecords[0].Id;
        update objPUU1;
        Test.stopTest();
    }
    
    @isTest
    private static void testtrgToUpdateOppStageHandlerSecond()
    {
        List<Opportunity> oppRecords = [Select id from Opportunity];
         List<Project_Unit__c> punit = [Select id from Project_Unit__c];
        checkRecursion.resetFirstRun();
        //system.debug('*check*'+checkRecursion.isFirstRun()+'$$'+punit[0]);
        //Test.startTest();
        Test.startTest();
        Test.setMock(WebServiceMock.class, new CustomerCreationWebServiceMockImpl());
        Project_Unit__c objPUU1 = new Project_Unit__c();
        objPUU1.Id = punit[0].Id;
        objPUU1.RW_Unit_Status__c ='Blocked';
        objPUU1.RW_Booking_Date__c = SYstem.today();
        objPUU1.RW_Customer__c=oppRecords[0].Id;
        update objPUU1;
        Test.stopTest();
    }
    
    @isTest
    private static void testtrgToUpdateOppStageHandlerthird()
    {
        List<Opportunity> oppRecords = [Select id from Opportunity];
         List<Project_Unit__c> punit = [Select id from Project_Unit__c];
        checkRecursion.resetFirstRun();
        //system.debug('*check*'+checkRecursion.isFirstRun()+'$$'+punit[0]);
        //Test.startTest();
        Test.startTest();
        Test.setMock(WebServiceMock.class, new CustomerCreationWebServiceMockImpl());
        Project_Unit__c objPUU1 = new Project_Unit__c();
        objPUU1.Id = punit[0].Id;
        objPUU1.RW_Unit_Status__c ='Documentation Complete';
        objPUU1.RW_Booking_Date__c = SYstem.today();
        objPUU1.RW_Customer__c=oppRecords[0].Id;
        update objPUU1;
        Test.stopTest();
    }
    
    @isTest
    private static void testtrgToUpdateOppStageHandlerfourth()
    {
        List<Opportunity> oppRecords = [Select id from Opportunity];
         List<Project_Unit__c> punit = [Select id from Project_Unit__c];
        checkRecursion.resetFirstRun();
        //system.debug('*check*'+checkRecursion.isFirstRun()+'$$'+punit[0]);
        //Test.startTest();
        Test.startTest();
        Test.setMock(WebServiceMock.class, new CustomerCreationWebServiceMockImpl());
        Project_Unit__c objPUU1 = new Project_Unit__c();
        objPUU1.Id = punit[0].Id;
        objPUU1.RW_Seventh_Day__c = true;
        //objPUU1.RW_Unit_Status__c ='Documentation Complete';
        objPUU1.RW_Booking_Date__c = SYstem.today();
        objPUU1.RW_Customer__c=oppRecords[0].Id;
        update objPUU1;
        Test.stopTest();
    }
    
   }