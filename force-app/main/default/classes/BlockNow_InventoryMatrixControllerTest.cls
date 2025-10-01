@isTest
public class BlockNow_InventoryMatrixControllerTest {

    @isTest
    private static void EOITest(){
        Profile p = [Select Id, Name from Profile where Name = 'System Administrator'];

    	/*User u = new User(firstName = 'TestUser1', lastName = 'TestUser2', email='test@gmail.com',Username= 'username1@gmail.com', ProfileId = p.Id, alias= 'alias',EmailEncodingKey='UTF-8', 
                    LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles', LanguageLocaleKey='en_US', Phone='9874561230');
    	insert u;*/
        
        String orgId = UserInfo.getOrganizationId();
    String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
    Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
    String uniqueName = orgId + dateString + randomInt;
    User tuser = new User(  firstname = 'TestUser1',
                            lastName = 'TestUser2',
                            email = uniqueName + orgId+ '@gmail' +'.com',
                            Username = uniqueName + '@test' + orgId + '.org',
                            EmailEncodingKey = 'ISO-8859-1',
                            Alias = uniqueName.substring(18, 23),
                            TimeZoneSidKey = 'America/Los_Angeles',
                            LocaleSidKey = 'en_US',
                            LanguageLocaleKey = 'en_US',
                            ProfileId = p.id
                            );
         insert tuser;
        
        
        
        Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.Sales_Site_Head__c = tuser.Id;
        objpr.SAPMaterial_Code__c = '1211';
        insert objpr;
        
        Project_Unit_Type__c objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.Id;
        insert objPUT;
        
        Project_Unit__c objPUU = new Project_Unit__c();  
        objPUU.Project_Unit_Type__c = objPUT.id;  
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c = objpr.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.RW_Unit_Status__c ='Available';
        //objPUU.EOI__c =eoiRecord.Id;
        //objPUU.RW_EOI_Block_Status__c = 'EOI Blocked';
        insert objPUU;
        
        Tower__c towerRec = new Tower__c();
        towerRec.ProjectName__c = objpr.id;
        towerRec.Name = 'A';
        towerRec.RW_Terms_And_Conditions__c ='TC';
        insert towerRec;
        
        Offer__c offers = new Offer__c();
        offers.Name='TestOffer';
        insert offers;
        
        RW_Sub_Offer__c subOffers = new RW_Sub_Offer__c();
        subOffers.Name= 'TestSubOffer';
        subOffers.RW_Start_Date__c =  System.today();
        subOffers.RW_End_Date__c = System.today().addDays(10);
        subOffers.Project__c = objpr.Id;
        subOffers.Tower__c = towerRec.Id;
        subOffers.Offer__c = offers.id;
        subOffers.RW_Offer_Type__c = 'EOI';
        subOffers.RW_Approval_Status__c = 'Approved';
        insert subOffers;
        
        //Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777',false);
        Account a = new Account();
        a.FirstName ='TestAccount1';
        a.LastName ='TestAccount2';
        a.PersonEmail = 'wc@email.com';
        a.City__c='TestCity';
        a.RW_Zip_Code__c = '999999';
        a.State__c ='Karnataka';
        a.Country__c ='India';
        a.Mobile_No__c = '9876543212';
        a.Alternate_Email__c = 'wc1@email.com';
        a.Gender__c='Male';
        a.Salutation = 'Mr.';
        a.Birth_Date__c = System.today().addYears(-20);   
        insert a;
        
        
        
        Opportunity oppRec= new Opportunity();
        oppRec.RW_Project__c=objpr.id;
        oppRec.name='Test 1';
        oppRec.RW_Email__c=a.PersonEmail;
        oppRec.StageName='Qualification';
        oppRec.CloseDate=system.today();
        oppRec.Status__c ='Active';
        oppRec.AccountId = a.Id;
        oppRec.Sales_Manager__c = 'SM2@g.com';
        oppRec.Sourcing_Manager__c='Aniket Sapre';
        oppRec.RW_Sourcing_Head__c='Adrian Dsouza';
        oppRec.RW_Sales_Associate__c='Karthik Chettiar';
        oppRec.RW_Closing_Head__c='Karthik Chettiar';
        oppRec.Walkin_Source__c='Direct';
        insert oppRec;
             
        PageReference testPage = Page.BlockNow_InventoryMatrix; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('oppId', String.valueOf(oppRec.Id));
        BlockNow_InventoryMatrixController sinv = new BlockNow_InventoryMatrixController();
        sinv.checkOpportunityStatus();
        sinv.getUserRoleName(Userinfo.getUserRoleId());
    }
    
    @isTest
    private static void testupdateEOIBlockStatus()
    {

       Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.SAPMaterial_Code__c = '1211';
        insert objpr;
        
        
        
        
        Project_Unit_Type__c objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.Id;
        insert objPUT;
        
        
        
        
        Project_Unit__c objPUU = new Project_Unit__c();  
        objPUU.Project_Unit_Type__c = objPUT.id;  
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c =objpr.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.RW_Unit_Status__c ='Available';
        //objPUU.EOI__c =eoiRecord.Id;
        //objPUU.RW_EOI_Block_Status__c = 'EOI Blocked';
        insert objPUU;
        
        
        Tower__c towerRec = new Tower__c();
        towerRec.ProjectName__c = objpr.id;
        towerRec.Name = 'A';
        towerRec.RW_Terms_And_Conditions__c ='TC';
        insert towerRec;
        
        Opportunity oppRec= new Opportunity();
        oppRec.RW_Project__c=objpr.id;
        oppRec.name='Test 1';
        oppRec.RW_Email__c= 'test@mail.com';
        oppRec.StageName='Qualification';
        oppRec.CloseDate=system.today();
        oppRec.Status__c ='Active';
        oppRec.Sales_Manager__c = 'SM2@g.com';
        oppRec.Sourcing_Manager__c='Aniket Sapre';
        oppRec.RW_Sourcing_Head__c='Adrian Dsouza';
        oppRec.RW_Sales_Associate__c='Karthik Chettiar';
        oppRec.RW_Closing_Head__c='Karthik Chettiar';
        oppRec.Walkin_Source__c='Direct';
        insert oppRec;
        
        RW_EOI__c eoiRecord = new RW_EOI__c();
        eoiRecord.Opportunity__c=oppRec.id;
        eoiRecord.Tower__c = towerRec.id;
        eoiRecord.RW_Primary_First_Name__c = 'Test1';
        eoiRecord.RW_Primary_Last_Name__c='Test2';
        eoiRecord.RW_EOI_Acknowledgement_Sent_Date_Time__c = SYstem.now();
        eoiRecord.RW_Primary_Email__c = 'test@gmail.com';
        eoiRecord.RW_Status__c = 'EOI Sent to Customer';
        eoiRecord.RW_Mailing_Address_Line_1__c='Addr1';
        eoiRecord.RW_Mailing_Address_Line_2__c='Addr2';
        eoiRecord.RW_Mailing_Address_Line_3__c='Addr3';
        eoiRecord.RW_Mailing_Pin__c='675432';
        eoiRecord.RW_Mailing_City__c='Mumbai';
        eoiRecord.RW_Mailing_Country__c='India';
        eoiRecord.RW_Mailing_State__c='Maharashtra';
        eoiRecord.RW_Gender__c='Male';
        eoiRecord.RW_Type_Of_Applicant__c = 'Individual Buyer';
        eoiRecord.RW_Residential_Status__c='Indian National';
        eoiRecord.RW_Date_of_Birth__c = System.today().addDays(-40);
        eoiRecord.RW_Primary_PAN_Details__c = 'BHYTR5678H';
        eoiRecord.RW_Document_Proof__c = 'Aadhar Card';
        eoiRecord.RW_Document_Number__c = '187654356789876';
        insert eoiRecord;
        
        
        
        BlockNow_InventoryMatrixController sinv = new BlockNow_InventoryMatrixController();
        sinv.oppId = oppRec.id;
        sinv.projectUnitRecordId = objPUU.Id;
        sinv.updateEOIBlockStatus();
        
        sinv.checkEOIBeforeBooking();
        
        eoiRecord.RW_Status__c = 'EOI Confirmed';
        update eoiRecord;
        
        sinv.updateEOIBlockStatus();
		sinv.updateEOIBlockStatus();
        
        sinv.checkEOIBeforeBooking();
        sinv.updateEOIBlockStatus();
        sinv.updateEOIAvailableStatus();
        
        
        Project__c objpr1 = new Project__c();
        objpr1.RW_Project_Code__c = 'T32';
        objpr1.Name = 'Runwal Bliss1';
        objpr1.RDS_Short_Name__c = 'T';
        objpr1.Start_Date__c = System.today().addDays(-5);
        objpr1.RDS_Interest_Rate__c = 12;
        //objpr.Sales_Site_Head__c = tuser.Id;
        objpr1.SAPMaterial_Code__c = '12111';
        insert objpr1;
        
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
        
        sinv.oppId =oppRec1.id;
        sinv.updateEOIBlockStatus();

        
        
        RW_EOI__c eoiRecord1 = new RW_EOI__c();
        eoiRecord1.RW_Status__c = 'EOI Blocked';
        eoiRecord1.Opportunity__c= oppRec.id;
        insert eoiRecord1;
        
         RW_EOI__c eoiRecord2 = new RW_EOI__c();
        eoiRecord2.RW_Status__c = 'EOI Blocked';
        eoiRecord2.Opportunity__c= oppRec1.id;
        insert eoiRecord2;
        
        Project_Unit_Type__c objPUT1 = new Project_Unit_Type__c();
        objPUT1.RDS_Code__c = '102';
        objPUT1.RDS_Project__c = objpr.Id;
        insert objPUT1;
        
        Project_Unit__c objPUU1 = new Project_Unit__c();  
        objPUU1.Project_Unit_Type__c = objPUT1.id;  
        objPUU1.Name = 'TestUnit1';      
        objPUU1.RW_Project__c =objpr.Id;
        objPUU1.RW_Param1__c = '6';
        objPUU1.UnitNo__c ='10';
        objPUU1.RW_Unit_Status__c ='Available';
        objPUU1.EOI__c=eoiRecord1.Id;
        
        insert objPUU1;

        sinv.projectUnitRecordId = objPUU1.Id;
        sinv.oppId =oppRec1.id;
        sinv.updateEOIAvailableStatus();

        eoiRecord2.Opportunity__c= null;
        update eoiRecord2;
        sinv.updateEOIAvailableStatus();
        
        
        objPUU1.RW_Unit_Status__c =null;
        objPUU1.EOI__c=null;
        update objPUU1;
        eoiRecord2.Opportunity__c= oppRec1.id;
        update eoiRecord2;
        sinv.checkEOIBeforeBooking();
        
        sinv.projectUnitRecordId =null;
        sinv.oppId =null;
        sinv.updateEOIBlockStatus();
        sinv.checkEOIBeforeBooking();
        sinv.updateEOIAvailableStatus();
    }
    
    @isTest
   private static void InventoryViewTest() {
      Client__c cl = TestDataFactory.createClients('Client1');
     
      List<Project__c> p = TestDataFactory.createProjectWithClient(1,'888',cl.Id);
     
      //create Clusters
       List<Cluster__c> cList = TestDataFactory.createClusters(2, p[0].Id);
       
      //create Towers
      List<Tower__c> tList = TestDataFactory.createTowers(2, p[0].Id);
      
     //create Units
      List<Project_Unit__c> uList = TestDataFactory.createUnits(tList[0].Id, p[0].Id);
      
      Test.startTest();
      PageReference pRef = Page.BlockNow_InventoryMatrix;
      Test.setCurrentPage(pRef);
      ApexPages.currentPage().getParameters().put('projectsent',p[0].Id);
      ApexPages.currentPage().getParameters().put('towersent',tList[0].Id);

      BlockNow_InventoryMatrixController invController = new BlockNow_InventoryMatrixController();
      invController.selectedVal = p[0].Id;
      invController.SelectedClusterId = cList[0].Id;
      invController.selectedTower = tList[0].Id;
      invController.selectedstatus = '';
      invController.selectedConf = uList[0].Id ;
      invController.sold = true;
      invController.open = true;
      invController.booked = true;
      invController.reserved = true;
      invController.blocked = true;
      
      invController.onebhk = true;
      invController.twobhk = true;
      invController.threebhk = true;
      invController.fourbhk = true;
      invController.fivebhk = true;

      List<SelectOption> pl = invController.getProjects;
      List<SelectOption> tl = invController.getTowers;
       List<SelectOption> clstr = invController.getClusterNames;
      List<Decimal> floorSeq = invController.floorDescSeqList;
      Map<Decimal, List<Project_Unit__c>> UnitMap = invController.JMap;
      
      Test.stopTest();
    }
    
    @isTest
    public static void blkUnitTest(){
        Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.SAPMaterial_Code__c = '1211';
        objpr.Sales_Site_Head__c = UserInfo.getUserId();
        insert objpr;
        
        Project_Unit_Type__c objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.Id;
        insert objPUT;
        
        Project_Unit__c objPUU = new Project_Unit__c();  
        objPUU.Project_Unit_Type__c = objPUT.id;  
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c = objpr.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.RW_Unit_Status__c ='Available';
        objPUU.Token_Amount__c = 10000;
        insert objPUU;
        
        Tower__c towerRec = new Tower__c();
        towerRec.ProjectName__c = objpr.id;
        towerRec.Name = 'A';
        towerRec.RW_Terms_And_Conditions__c ='TC';
        insert towerRec;
        
        Offer__c offers = new Offer__c();
        offers.Name='TestOffer';
        insert offers;
        
        RW_Sub_Offer__c subOffers = new RW_Sub_Offer__c();
        subOffers.Name= 'TestSubOffer';
        subOffers.RW_Start_Date__c =  System.today();
        subOffers.RW_End_Date__c = System.today().addDays(10);
        subOffers.Project__c = objpr.Id;
        subOffers.Tower__c = towerRec.Id;
        subOffers.Offer__c = offers.id;
        subOffers.RW_Offer_Type__c = 'EOI';
        subOffers.RW_Approval_Status__c = 'Approved';
        insert subOffers;
        
        //Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777',false);
        Account a = new Account();
        a.FirstName ='TestAccount1';
        a.LastName ='TestAccount2';
        a.PersonEmail = 'wc@email.com';
        a.City__c='TestCity';
        a.RW_Zip_Code__c = '999999';
        a.State__c ='Karnataka';
        a.Country__c ='India';
        a.Mobile_No__c = '9876543212';
        a.Alternate_Email__c = 'wc1@email.com';
        a.Gender__c='Male';
        a.Salutation = 'Mr.';
        a.Birth_Date__c = System.today().addYears(-20);   
        insert a;
        
        
        
        Opportunity oppRec= new Opportunity();
        oppRec.RW_Project__c=objpr.id;
        oppRec.name='Test 1';
        oppRec.RW_Email__c=a.PersonEmail;
        oppRec.StageName='Unit Blocked';
        oppRec.CloseDate=system.today();
        oppRec.Status__c ='Active';
        oppRec.AccountId = a.Id;
        oppRec.Sales_Manager__c = 'SM2@g.com';
        oppRec.Sourcing_Manager__c='Aniket Sapre';
        oppRec.RW_Sourcing_Head__c='Adrian Dsouza';
        oppRec.RW_Sales_Associate__c='Karthik Chettiar';
        oppRec.RW_Closing_Head__c='Karthik Chettiar';
        oppRec.Walkin_Source__c='Direct';
        oppRec.Reason_for_Release_Inventory__c = 'Test';
        oppRec.Blocked_Date__c = Date.Today();
        insert oppRec;
        
        Blocking_Unit_Information__c blk = new Blocking_Unit_Information__c();
        blk.Opportunity__c = oppRec.Id;
        blk.Approval_Status__c = 'Approved';
        blk.Active__c = true;
        blk.Approver__c = UserInfo.getUserId();
        insert blk;
        
             
        PageReference testPage = Page.BlockUnit; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('oppId', String.valueOf(oppRec.Id));
        testPage.getParameters().put('unitId', String.valueOf(objPUU.Id));
        BlockUnitController blkUnit = new BlockUnitController();
        blkUnit.saveDetails();
        //blkUnit.continueToApproval();
        
        String infoId = BlockedUnitRelease.releaseUnit(oppRec.Id);
        BlockedUnitRelease.sendApproval(infoId);
        
        BlockUnitReleaseSchedule b = new BlockUnitReleaseSchedule();
        b.execute(null);
    }
    
    @isTest
    public static void blkUnitTest2(){
        Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.SAPMaterial_Code__c = '1211';
        objpr.Sales_Site_Head__c = UserInfo.getUserId();
        insert objpr;
        
        Project_Unit_Type__c objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.Id;
        insert objPUT;
        
        Project_Unit__c objPUU = new Project_Unit__c();  
        objPUU.Project_Unit_Type__c = objPUT.id;  
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c = objpr.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.RW_Unit_Status__c ='Available';
        objPUU.Token_Amount__c = 10000;
        insert objPUU;
        
        Tower__c towerRec = new Tower__c();
        towerRec.ProjectName__c = objpr.id;
        towerRec.Name = 'A';
        towerRec.RW_Terms_And_Conditions__c ='TC';
        insert towerRec;
        
        Offer__c offers = new Offer__c();
        offers.Name='TestOffer';
        insert offers;
        
        RW_Sub_Offer__c subOffers = new RW_Sub_Offer__c();
        subOffers.Name= 'TestSubOffer';
        subOffers.RW_Start_Date__c =  System.today();
        subOffers.RW_End_Date__c = System.today().addDays(10);
        subOffers.Project__c = objpr.Id;
        subOffers.Tower__c = towerRec.Id;
        subOffers.Offer__c = offers.id;
        subOffers.RW_Offer_Type__c = 'EOI';
        subOffers.RW_Approval_Status__c = 'Approved';
        insert subOffers;
        
        //Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777',false);
        Account a = new Account();
        a.FirstName ='TestAccount1';
        a.LastName ='TestAccount2';
        a.PersonEmail = 'wc@email.com';
        a.City__c='TestCity';
        a.RW_Zip_Code__c = '999999';
        a.State__c ='Karnataka';
        a.Country__c ='India';
        a.Mobile_No__c = '9876543212';
        a.Alternate_Email__c = 'wc1@email.com';
        a.Gender__c='Male';
        a.Salutation = 'Mr.';
        a.Birth_Date__c = System.today().addYears(-20);   
        insert a;
        
        
        
        Opportunity oppRec= new Opportunity();
        oppRec.RW_Project__c=objpr.id;
        oppRec.name='Test 1';
        oppRec.RW_Email__c=a.PersonEmail;
        oppRec.StageName='Unit Blocked';
        oppRec.CloseDate=system.today();
        oppRec.Status__c ='Active';
        oppRec.AccountId = a.Id;
        oppRec.Sales_Manager__c = 'SM2@g.com';
        oppRec.Sourcing_Manager__c='Aniket Sapre';
        oppRec.RW_Sourcing_Head__c='Adrian Dsouza';
        oppRec.RW_Sales_Associate__c='Karthik Chettiar';
        oppRec.RW_Closing_Head__c='Karthik Chettiar';
        oppRec.Walkin_Source__c='Direct';
        oppRec.Reason_for_Release_Inventory__c = 'Test';
        oppRec.Blocked_Date__c = Date.Today();
        insert oppRec;
        
        Blocking_Unit_Information__c blk = new Blocking_Unit_Information__c();
        blk.Opportunity__c = oppRec.Id;
        blk.Approval_Status__c = 'Approved';
        blk.Active__c = true;
        blk.Approver__c = UserInfo.getUserId();
        insert blk;
        
             
                
        BlockUnitReleaseSchedule b = new BlockUnitReleaseSchedule();
        b.execute(null);
    }
}