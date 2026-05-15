@isTest
public class S_InventoryMatrixTest {

    @testSetup
    private static void EOITest() 
    {
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
        oppRec.Sales_Manager_User__c= UserInfo.getUserId(); //Added by Vinay 09-12-2025
        oppRec.RW_Closing_Head__c='Karthik Chettiar';
        oppRec.Walkin_Source__c='Direct';
        insert oppRec;
    }
    
    @isTest
    private static void testupdateEOIBlockStatus()
    {
      List<Opportunity> oppRecords = [Select id,StageName from Opportunity];
        List<Tower__c> towerRecords = [Select id from Tower__c];

       List<Project__c> projectrecord= [Select id from Project__c];
        
        RW_EOI__c eoiRecord = new RW_EOI__c();
        eoiRecord.Opportunity__c = oppRecords[0].id;
        eoiRecord.Tower__c = towerRecords[0].id;
        eoiRecord.RW_Primary_First_Name__c = 'Test1';
        eoiRecord.RW_Primary_Last_Name__c='Test2';
        eoiRecord.RW_EOI_Acknowledgement_Sent_Date_Time__c = SYstem.now();
        eoiRecord.RW_Primary_Email__c = 'test@gmail.com';
        eoiRecord.RW_Status__c = 'EOI Blocked'; 
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
        
        RW_EOI__c eoiRecord1 = new RW_EOI__c();
        eoiRecord1.Opportunity__c = oppRecords[0].id;
        eoiRecord1.Tower__c = towerRecords[0].id;
        eoiRecord1.RW_Primary_First_Name__c = 'Test1';
        eoiRecord1.RW_Primary_Last_Name__c='Test2';
        eoiRecord1.RW_EOI_Acknowledgement_Sent_Date_Time__c = SYstem.now();
        eoiRecord1.RW_Primary_Email__c = 'test@gmail.com';
        eoiRecord1.RW_Status__c = 'EOI Confirmed'; 
        eoiRecord1.RW_Mailing_Address_Line_1__c='Addr1';
        eoiRecord1.RW_Mailing_Address_Line_2__c='Addr2';
        eoiRecord1.RW_Mailing_Address_Line_3__c='Addr3';
        eoiRecord1.RW_Mailing_Pin__c='675432';
        eoiRecord1.RW_Mailing_City__c='Mumbai';
        eoiRecord1.RW_Mailing_Country__c='India';
        eoiRecord1.RW_Mailing_State__c='Maharashtra';
        eoiRecord1.RW_Gender__c='Male';
        eoiRecord1.RW_Type_Of_Applicant__c = 'Individual Buyer';
        eoiRecord1.RW_Residential_Status__c='Indian National';
        eoiRecord1.RW_Date_of_Birth__c = System.today().addDays(-40);
        eoiRecord1.RW_Primary_PAN_Details__c = 'BHYTR5678H';
        eoiRecord1.RW_Document_Proof__c = 'Aadhar Card';
        eoiRecord1.RW_Document_Number__c = '187654356789876';
        insert eoiRecord1;
        
        
        Project_Unit_Type__c objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = projectrecord[0].Id;
        insert objPUT;
        
        Project_Unit__c objPUU = new Project_Unit__c();  
        objPUU.Project_Unit_Type__c = objPUT.id;  
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c =projectrecord[0].Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.RW_Unit_Status__c ='Available';
        objPUU.EOI__c = eoiRecord.Id;
        objPUU.RW_EOI_Blocked_By__c = Userinfo.getUserId();
        //objPUU.EOI__c =eoiRecord.Id;
        //objPUU.RW_EOI_Block_Status__c = 'EOI Blocked';
        insert objPUU;
        
       
        
        S_InventoryMatrix sinv = new S_InventoryMatrix();
        oppRecords[0].StageName='Cancelled';
        sinv.oppId = oppRecords[0].id;
        sinv.projectUnitRecordId = objPUU.Id;
        sinv.checkOpportunityStatus();
        sinv.updateEOIAvailableStatus();
        sinv.updateEOIBlockStatus();
        sinv.checkEOIBeforeBooking();
        S_InventoryMatrix.dummy();
        
        
        sinv.getUserRoleName(Userinfo.getUserRoleId());
        
    }
    
    @isTest
    private static void testupdateEOIBlockStatus1()
    {
      List<Opportunity> oppRecords = [Select id,StageName from Opportunity];
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
        
        List<Tower__c> towerRecords = [Select id from Tower__c];

       List<Project__c> projectrecord= [Select id from Project__c];
        
        
        Opportunity oppRec= new Opportunity();
        oppRec.RW_Project__c=projectrecord[0].id;
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
        oppRec.Sales_Manager_User__c= UserInfo.getUserId(); //Added by Vinay 09-12-2025
        oppRec.RW_Closing_Head__c='Karthik Chettiar';
        oppRec.Walkin_Source__c='Direct';
        insert oppRec;
        
        RW_EOI__c eoiRecord = new RW_EOI__c();
        eoiRecord.Opportunity__c = oppRecords[0].id;
        eoiRecord.Tower__c = towerRecords[0].id;
        eoiRecord.RW_Primary_First_Name__c = 'Test1';
        eoiRecord.RW_Primary_Last_Name__c='Test2';
        eoiRecord.RW_EOI_Acknowledgement_Sent_Date_Time__c = SYstem.now();
        eoiRecord.RW_Primary_Email__c = 'test@gmail.com';
        eoiRecord.RW_Status__c = 'EOI Blocked'; 
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
        
        RW_EOI__c eoiRecord1 = new RW_EOI__c();
        eoiRecord1.Opportunity__c = oppRec.id;
        eoiRecord1.Tower__c = towerRecords[0].id;
        eoiRecord1.RW_Primary_First_Name__c = 'Test1';
        eoiRecord1.RW_Primary_Last_Name__c='Test2';
        eoiRecord1.RW_EOI_Acknowledgement_Sent_Date_Time__c = SYstem.now();
        eoiRecord1.RW_Primary_Email__c = 'test@gmail.com';
        eoiRecord1.RW_Status__c = 'EOI Blocked'; 
        eoiRecord1.RW_Mailing_Address_Line_1__c='Addr1';
        eoiRecord1.RW_Mailing_Address_Line_2__c='Addr2';
        eoiRecord1.RW_Mailing_Address_Line_3__c='Addr3';
        eoiRecord1.RW_Mailing_Pin__c='675432';
        eoiRecord1.RW_Mailing_City__c='Mumbai';
        eoiRecord1.RW_Mailing_Country__c='India';
        eoiRecord1.RW_Mailing_State__c='Maharashtra';
        eoiRecord1.RW_Gender__c='Male';
        eoiRecord1.RW_Type_Of_Applicant__c = 'Individual Buyer';
        eoiRecord1.RW_Residential_Status__c='Indian National';
        eoiRecord1.RW_Date_of_Birth__c = System.today().addDays(-40);
        eoiRecord1.RW_Primary_PAN_Details__c = 'BHYTR5678H';
        eoiRecord1.RW_Document_Proof__c = 'Aadhar Card';
        eoiRecord1.RW_Document_Number__c = '187654356789876';
        insert eoiRecord1;
        
        
        Project_Unit_Type__c objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = projectrecord[0].Id;
        insert objPUT;
        
        Project_Unit__c objPUU = new Project_Unit__c();  
        objPUU.Project_Unit_Type__c = objPUT.id;  
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c =projectrecord[0].Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.RW_Unit_Status__c ='Available';
        objPUU.EOI__c = eoiRecord.Id;
        objPUU.RW_EOI_Blocked_By__c = Userinfo.getUserId();
        //objPUU.EOI__c =eoiRecord.Id;
        //objPUU.RW_EOI_Block_Status__c = 'EOI Blocked';
        insert objPUU;
        
       
        
        S_InventoryMatrix sinv = new S_InventoryMatrix();
        oppRecords[0].StageName='Cancelled';
        sinv.oppId = oppRec.id;
        sinv.projectUnitRecordId = objPUU.Id;
        //sinv.checkOpportunityStatus();
        sinv.updateEOIAvailableStatus();
        //sinv.updateEOIBlockStatus();
        //sinv.checkEOIBeforeBooking();
        
        sinv.getUserRoleName(Userinfo.getUserRoleId());
        
    }
    
    @isTest
    public static void testExceptionCoverage() {
        Test.startTest();
        List<Opportunity> oppRecords = [Select id,StageName from Opportunity];      
        delete oppRecords;
        
        List<Tower__c> towerRecords = [Select id from Tower__c];

       List<Project__c> projectrecord= [Select id from Project__c];
        
        
        Project_Unit_Type__c objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = projectrecord[0].Id;
        insert objPUT;
        
        Project_Unit__c objPUU = new Project_Unit__c();  
        objPUU.Project_Unit_Type__c = objPUT.id;  
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c =projectrecord[0].Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.RW_Unit_Status__c ='Available';
        //objPUU.EOI__c = eoiRecord.Id;
        objPUU.RW_EOI_Blocked_By__c = Userinfo.getUserId();
        //objPUU.EOI__c =eoiRecord.Id;
        //objPUU.RW_EOI_Block_Status__c = 'EOI Blocked';
        //insert objPUU;
        
        
        S_InventoryMatrix ctrl = new S_InventoryMatrix();
        ctrl.projectUnitRecordId = objPUU.Id;
        ctrl.oppId = oppRecords[0].Id; 
        
        ctrl.updateEOIBlockStatus();
        ctrl.checkOpportunityStatus();
        ctrl.updateEOIAvailableStatus();
        ctrl.updateEOIBlockStatus();
        ctrl.checkEOIBeforeBooking();
        
        Test.stopTest();
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
        PageReference pRef = Page.S_InventoryMatrixview;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('projectsent',p[0].Id);
        ApexPages.currentPage().getParameters().put('towersent',tList[0].Id);
        
        S_InventoryMatrix invController = new S_InventoryMatrix();
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
        
        //List<SelectOption> cli = invController.getClients;
        List<SelectOption> pl = invController.getProjects;
        List<SelectOption> cul = invController.getClusterNames;
        List<SelectOption> tl = invController.getTowers;
        //List<SelectOption> pu = invController.getProjectunittype;
        List<Decimal> floorSeq = invController.floorDescSeqList;
        Map<Decimal, List<Project_Unit__c>> UnitMap = invController.JMap;
        //verify towers, projects, units in one floor 
        // System.assertEquals(2,pl.size());
        // System.assertEquals(3,tl.size());
        // System.assertEquals(5, UnitMap.get(1).size());
        
        Test.stopTest();
    }
    
    
    /*
    @isTest
    public static void testEOIBlockUnblockLogic() {
        // 1. Setup Base Data
        // 
        Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        //objpr.Sales_Site_Head__c = tuser.Id;
        objpr.SAPMaterial_Code__c = '1211';
        insert objpr;
        
        Tower__c towerRec = new Tower__c();
        towerRec.ProjectName__c = objpr.id;
        towerRec.Name = 'A';
        towerRec.RW_Terms_And_Conditions__c ='TC';
        insert towerRec;
        
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
        Opportunity opp = new Opportunity(Name = 'Test Opp', StageName = 'Qualification', CloseDate = System.today(), AccountId = a.Id);
        insert opp;
        
        Project_Unit__c unit = new Project_Unit__c(RW_Project__c = objpr.Id,Name = 'Unit 101', RW_Unit_Status__c = 'Available');
        insert unit;
        
        // Create an EOI record (Ensure the object name matches your RW_EOI__c)
        RW_EOI__c eoi = new RW_EOI__c(Opportunity__c = opp.Id, RW_Status__c = 'EOI Confirmed');
        insert eoi;
        
        // 2. Initialize Controller
        S_InventoryMatrix ctrl = new S_InventoryMatrix();
        ctrl.oppId = opp.Id;
        ctrl.projectUnitRecordId = unit.Id;
        
        Test.startTest();
        
        // Scenario A: Successful Block
        ctrl.updateEOIBlockStatus();
        
        // Verify Block
        Project_Unit__c unitCheck = [SELECT RW_EOI_Block_Status__c FROM Project_Unit__c WHERE Id = :unit.Id];
        System.assertEquals('EOI Blocked', unitCheck.RW_EOI_Block_Status__c);
        
        // Scenario B: Try to block an already blocked unit (Hits the 'else' branch)
        ctrl.updateEOIBlockStatus();
        
        // Scenario C: Successful Unblock
        // Note: The code checks UserRole for 'Site Head'. To cover that, you might need a RunAs() block, 
        // but usually, blocking user unblocking their own unit is enough for coverage.
        ctrl.updateEOIAvailableStatus();
        
        // Verify Unblock
        unitCheck = [SELECT RW_EOI_Block_Status__c FROM Project_Unit__c WHERE Id = :unit.Id];
        System.assertEquals('EOI Available', unitCheck.RW_EOI_Block_Status__c);
        
        Test.stopTest();
    }
    
    @isTest
    public static void testEOIBookingValidation() {
        
                Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
       // objpr.Sales_Site_Head__c = tuser.Id;
        objpr.SAPMaterial_Code__c = '1211';
        insert objpr;
        
        Tower__c towerRec = new Tower__c();
        towerRec.ProjectName__c = objpr.id;
        towerRec.Name = 'A';
        towerRec.RW_Terms_And_Conditions__c ='TC';
        insert towerRec;
        
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
        Opportunity opp = new Opportunity(Name = 'Test Opp 2', StageName = 'Qualification', CloseDate = System.today(), AccountId = a.Id);
        insert opp;
        
        // Create two units
        Project_Unit__c unitCorrect = new Project_Unit__c(RW_Project__c = objpr.Id,Name = 'Correct Unit');
        Project_Unit__c unitWrong = new Project_Unit__c(RW_Project__c = objpr.Id,Name = 'Wrong Unit');
        insert new List<Project_Unit__c>{unitCorrect, unitWrong};
            
            // Create an EOI that is already blocked on the 'Correct Unit'
            RW_EOI__c eoi = new RW_EOI__c(Opportunity__c = opp.Id, RW_Status__c = 'EOI Blocked');
        insert eoi;
        
        unitCorrect.EOI__c = eoi.Id;
        unitCorrect.RW_EOI_Block_Status__c = 'EOI Blocked';
        update unitCorrect;
        
        S_InventoryMatrix ctrl = new S_InventoryMatrix();
        ctrl.oppId = opp.Id;
        
        Test.startTest();
        
        // Scenario D: User tries to book the WRONG unit
        ctrl.projectUnitRecordId = unitWrong.Id;
        ctrl.checkEOIBeforeBooking(); // Hits the 'Please book only the unit which is EOI blocked' error branch
        
        // Scenario E: User tries to book the CORRECT unit
        ctrl.projectUnitRecordId = unitCorrect.Id;
        ctrl.checkEOIBeforeBooking(); // Returns null (Success)
        
        Test.stopTest();
    }
    
    
    @isTest
    public static void testExceptionCoverage() {
        S_InventoryMatrix ctrl = new S_InventoryMatrix();
        ctrl.oppId = 'InvalidID'; // This will cause the SOQL to fail
        ctrl.updateEOIBlockStatus();
        
        // Check that a message was added to ApexPages
        System.assert(ApexPages.hasMessages());
    }*/
}