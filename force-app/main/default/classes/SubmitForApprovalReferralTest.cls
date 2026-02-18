@isTest
private class SubmitForApprovalReferralTest {
    @isTest
    static void testCheckAttachmentinReferralCredit() {
        // Setup test data
       user sitehead = UniversalTestClassSetup.createusers('System Administrator', 'site','headpriject','site.head@runwal.com.uat','site.headtest@runwal.com.uat');
        system.runas(sitehead){
            Legal_Entity__c objlglentity = new Legal_Entity__c();
            objlglentity.Name = 'RS';
            objlglentity.RDS_Company_Code__c='rs';
            objlglentity.RDS_Service_Tax_No__c= '123456789012345';
            objlglentity.RDS_Company_Name__c='111';
            objlglentity.RDS_Address1__c='123';
            objlglentity.RDS_Address2__c='234';
            objlglentity.RDS_City__c='delhi';
            objlglentity.RDS_Pin_Code__c='201301';
            objlglentity.RDS_Phone__c='9953528045';
            objlglentity=RDSCommon.CreateLegalEntity(objlglentity);
            
            Project__c objpr = new Project__c();
            objpr.RW_Project_Code__c = 'T35';
            objpr.Name = 'Runwal Bliss';
            objpr.Start_Date__c = System.today().addDays(-5);
            objpr.RDS_Company_Code__c = objlglentity.Id;
            objpr.RDS_Interest_Rate__c = 12;
           // objpr.Project_Stage__c='Launch';
            objpr.RW_Address__c = '1403, Fantasy Land, Utopia, Planet Mars, OUTERWORLD CODE -11011';
            objpr.Project_Property_Type__c = 'Residential';
            objpr.S_Floor_Rise_Rate__c = 150;
            objpr.S_Applicable_From_Floor__c = 5;
            objpr.S_View1_PLC__c = 10;
            objpr.S_View2_PLC__c = 20;
            objpr.S_View3_PLC__c = 30;
            objpr.NPV__c = 12;
            objpr.S_Ready_Reckoner_Rate__c = 24000;
            objpr.Token_Amount__c = 200000;
            objpr.Service_Tax_Required_On_Token_Amount__c = true;
            objpr.Total_Max_Discount_Allowed__c = 100;
            objpr.Discount1_Type__c = 'General';
            //objpr.Discount1_Effective_Till__c = system.today().addDays(100);
            objpr.Discount1_Per_Sq_Ft__c = 100;
            objpr.Discount2_Type__c = 'Armed Forces';
           // objpr.Discount2_Per_Sq_Ft__c = 150;
            objpr.Discount3_Type__c = 'Corporate';
            objpr.Discount3_Per_Sq_Ft__c = 200;
            objpr.Discount4_Type__c = 'Employee';
            objpr.Discount4_Per_Sq_Ft__c = 250;
            objpr.Discount5_Type__c = 'NRI';
            objpr.Discount5_Per_Sq_Ft__c = 300;
            objpr.Discount6_Type__c = 'Physically Challenged';
            objpr.Discount6_Per_Sq_Ft__c = 350;
            objpr.Discount8_Description__c = 'summer offer';
            objpr.Discount8_Type__c = 'Special Offer';
            objpr.Discount8_Per_Sq_Ft__c = 1000;
            objpr.Discount9_Description__c = 'DAM';
            objpr.Discount9_Type__c = 'DAM';
            objpr.Discount9_Per_Sq_Ft__c = 2000;
            //objpr.Discount2_Effective_Till__c = system.today().addDays(100);
            objpr.Discount2_Lumpsum__c = 100000;
            objpr.Allotment_Charges_1__c = 10000;
            objpr.Allotment_Charges_2__c = 10000;
            objpr.Allotment_Charges_3__c = 10000;
            objpr.Allotment_Charges_4__c = 10000;
            objpr.Allotment_Charges_5__c = 10000;
            objpr.Allotment_Charges_6__c = 10000;
            objpr=RDSCommon.CreateProject(objpr);
            
            String RecTypeId= [select Id from RecordType where (Name='Person Account') and (SobjectType='Account')].Id;
            
            Account Accnt = new Account(              
                RecordTypeID=RecTypeId,                
                FirstName='TestFName',                
                LastName='TestLName',                
                PersonMailingStreet='test@yahoo.com',                
                PersonMailingPostalCode='12345',                
                PersonMailingCity='SFO',                
                PersonEmail='test@yahoo.com',                
                PersonHomePhone='1234567',                
                PersonMobilePhone='12345678'                 
            );          
            
            insert Accnt;
            
            
            
            Opportunity objOpportunity = new Opportunity();
            objOpportunity.Name = 'Test';
            objOpportunity.Sales_Manager__c = 'Deepak Arya';
            objOpportunity.Sourcing_Manager__c = 'Deepak Arya';
            objOpportunity.CloseDate = System.today();
            objOpportunity.AccountId = Accnt.Id; 
            objOpportunity.Status__c = 'Active'; 
            objOpportunity.StageName = 'Unit Booked'; 
            objOpportunity.SAP_Customer_Number__c ='12345678';
            
            objOpportunity.RW_Project__c = objpr.id; 
            objOpportunity=RDSCommon.CreateOpportunity(objOpportunity);
            Project_Unit__c objPUU = new Project_Unit__c();  
        //objPUU.Project_Unit_Type__c = objPUT.id;  
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c = objpr.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.RW_Unit_Status__c ='Available';
        insert objPUU;
         Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
         String uniqueUsername = 'testuser_' + DateTime.now().getTime() + '@example.com';
        User testUser = new User(
            FirstName = 'Test1',
            LastName = 'User1',
            Email = 'Test@g.com',
            Username = uniqueUsername,
            Alias = 'tuser',
            ProfileId = profile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            CompanyName = 'Test Company',
            Title = 'Test User',
            IsActive = true
        );
            insert testUser;
            Booking__c bk = new booking__c();
            bk.Customer__c = objOpportunity.id;
            bk.Opportunity__c = objOpportunity.id;
       // bk.RW_Project_Name__c=objpr.id;
            insert bk;
            objOpportunity.Booking__c = bk.Id;
            update objOpportunity;
            Applicant_Details__c apt1 = new Applicant_Details__c();
        apt1.Name = 'Applicant 1';
        apt1.Permanent_Address__c = 'test address';
        apt1.Opportunity__c = objOpportunity.Id;
        apt1.Applicant_Number__c = 'Primary Applicant';
        apt1.Subtype_Of_Applicant__c = 'Indian National';
        apt1.Type_Of_Applicant__c= 'Individual Buyer';
        apt1.Booking__c = bk.Id;
        apt1.DOB__c = Date.today();
        apt1.Office_Address_Line_1__c = 'Office Address Line 1';
        apt1.Mobile_Number__c = '1234567890';
        apt1.Email_Address__c = 'test@test.com';
        apt1.PancardNo__c = 'ABC123456';
        apt1.Address_Proof__c = true;
        apt1.Address_Proof_Document__c = 'Passport';
        apt1.PancardNo__c = 'abc213456';
        insert apt1;
        List<Referral_Credits__c> rcList = new List<Referral_Credits__c> ();
        Referral_Credits__c rc1=new Referral_Credits__c();
        rc1.Referral_In_Rs__c=10000;
        rc1.Reference_Booking__c = bk.id;
        rc1.Booking_RM__c=testUser.id;
        rc1.Name_of_Existing_Customer__c='Testing1';
        rc1.Referral_Credit_Approver_L1__c=testUser.id;
         rc1.Referral_Credit_Approver_L2__c=testUser.id;
        rc1.Existing_Customer_Flat_no__c='20';
       // rc1.Existing_Customer_Flat_no__c='20';
        rc1.Name_of_New_Customer__c ='test';
        rc1.long_text1__c='tets';
        rc1.Flat_no__c='2';
        
        insert rc1;
        rcList.add(rc1);
        Referral_Credits__c rc2=new Referral_Credits__c();
        rc2.Referral_In_Rs__c=100001;
        rc2.Reference_Booking__c = bk.id;
      rc2.Booking_RM__c=testUser.id;
        rc2.Name_of_Existing_Customer__c='Testing1';
        rc2.Existing_Customer_Flat_no__c='20';
       // rc1.Existing_Customer_Flat_no__c='20';
        rc2.Name_of_New_Customer__c ='test';
         rc2.Referral_Credit_Approver_L1__c=testUser.id;
        rc2.Referral_Credit_Approver_L2__c=testUser.id;
       // rc2.Accounts_Team_Email__c='a@g.com';
        
       
        rc2.Flat_no__c='2';
        rc2.long_text1__c='tets';
        insert rc2;
         rcList.add(rc2);
        List<Id> referralCreditIds = new List<Id>{rc1.Id};
           Referral_Credits__c rc3=[Select id,name from Referral_Credits__c where id =: rc1.Id];
     
        Boolean hasAttachment = SubmitForApprovalReferral.CheckAttachmentinReferralCredit(rc3.Id);
        
     Boolean isUploadShown = SubmitForApprovalReferral.CheckUploadAttachmenttobeShown(rc1.Id);
        // Assert results
       // System.assert(hasAttachment, 'Expected attachment to be found.');
    }
    }
  
    @isTest
    static void testCreateContentLink() {
        // Setup test data
        user sitehead = UniversalTestClassSetup.createusers('System Administrator', 'site','headpriject','site.head@runwal.com.uat','site.headtest@runwal.com.uat');
      //  system.runas(sitehead){
            Legal_Entity__c objlglentity = new Legal_Entity__c();
            objlglentity.Name = 'RS';
            objlglentity.RDS_Company_Code__c='rs';
            objlglentity.RDS_Service_Tax_No__c= '123456789012345';
            objlglentity.RDS_Company_Name__c='111';
            objlglentity.RDS_Address1__c='123';
            objlglentity.RDS_Address2__c='234';
            objlglentity.RDS_City__c='delhi';
            objlglentity.RDS_Pin_Code__c='201301';
            objlglentity.RDS_Phone__c='9953528045';
            objlglentity=RDSCommon.CreateLegalEntity(objlglentity);
            
            Project__c objpr = new Project__c();
            objpr.RW_Project_Code__c = 'T35';
            objpr.Name = 'Runwal Bliss';
            objpr.Start_Date__c = System.today().addDays(-5);
            objpr.RDS_Company_Code__c = objlglentity.Id;
            objpr.RDS_Interest_Rate__c = 12;
           // objpr.Project_Stage__c='Launch';
            objpr.RW_Address__c = '1403, Fantasy Land, Utopia, Planet Mars, OUTERWORLD CODE -11011';
            objpr.Project_Property_Type__c = 'Residential';
            objpr.S_Floor_Rise_Rate__c = 150;
            objpr.S_Applicable_From_Floor__c = 5;
            objpr.S_View1_PLC__c = 10;
            objpr.S_View2_PLC__c = 20;
            objpr.S_View3_PLC__c = 30;
            objpr.NPV__c = 12;
            objpr.S_Ready_Reckoner_Rate__c = 24000;
            objpr.Token_Amount__c = 200000;
            objpr.Service_Tax_Required_On_Token_Amount__c = true;
            objpr.Total_Max_Discount_Allowed__c = 100;
            objpr.Discount1_Type__c = 'General';
            //objpr.Discount1_Effective_Till__c = system.today().addDays(100);
            objpr.Discount1_Per_Sq_Ft__c = 100;
            objpr.Discount2_Type__c = 'Armed Forces';
           // objpr.Discount2_Per_Sq_Ft__c = 150;
            objpr.Discount3_Type__c = 'Corporate';
            objpr.Discount3_Per_Sq_Ft__c = 200;
            objpr.Discount4_Type__c = 'Employee';
            objpr.Discount4_Per_Sq_Ft__c = 250;
            objpr.Discount5_Type__c = 'NRI';
            objpr.Discount5_Per_Sq_Ft__c = 300;
            objpr.Discount6_Type__c = 'Physically Challenged';
            objpr.Discount6_Per_Sq_Ft__c = 350;
            objpr.Discount8_Description__c = 'summer offer';
            objpr.Discount8_Type__c = 'Special Offer';
            objpr.Discount8_Per_Sq_Ft__c = 1000;
            objpr.Discount9_Description__c = 'DAM';
            objpr.Discount9_Type__c = 'DAM';
            objpr.Discount9_Per_Sq_Ft__c = 2000;
            //objpr.Discount2_Effective_Till__c = system.today().addDays(100);
            objpr.Discount2_Lumpsum__c = 100000;
            objpr.Allotment_Charges_1__c = 10000;
            objpr.Allotment_Charges_2__c = 10000;
            objpr.Allotment_Charges_3__c = 10000;
            objpr.Allotment_Charges_4__c = 10000;
            objpr.Allotment_Charges_5__c = 10000;
            objpr.Allotment_Charges_6__c = 10000;
            objpr=RDSCommon.CreateProject(objpr);
            
            String RecTypeId= [select Id from RecordType where (Name='Person Account') and (SobjectType='Account')].Id;
            
            Account Accnt = new Account(              
                RecordTypeID=RecTypeId,                
                FirstName='TestFName',                
                LastName='TestLName',                
                PersonMailingStreet='test@yahoo.com',                
                PersonMailingPostalCode='12345',                
                PersonMailingCity='SFO',                
                PersonEmail='test@yahoo.com',                
                PersonHomePhone='1234567',                
                PersonMobilePhone='12345678'                 
            );          
            
            insert Accnt;
            
            
            
            Opportunity objOpportunity = new Opportunity();
            objOpportunity.Name = 'Test';
            objOpportunity.Sales_Manager__c = 'Deepak Arya';
            objOpportunity.Sourcing_Manager__c = 'Deepak Arya';
            objOpportunity.CloseDate = System.today();
            objOpportunity.AccountId = Accnt.Id; 
            objOpportunity.Status__c = 'Active'; 
            objOpportunity.StageName = 'Unit Booked'; 
            objOpportunity.SAP_Customer_Number__c ='12345678';
            
            objOpportunity.RW_Project__c = objpr.id; 
            objOpportunity=RDSCommon.CreateOpportunity(objOpportunity);
            Project_Unit__c objPUU = new Project_Unit__c();  
        //objPUU.Project_Unit_Type__c = objPUT.id;  
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c = objpr.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.RW_Unit_Status__c ='Available';
        insert objPUU;
         Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
         String uniqueUsername = 'testuser_' + DateTime.now().getTime() + '@example.com';
        User testUser = new User(
            FirstName = 'Test1',
            LastName = 'User1',
            Email = 'Test@g.com',
            Username = uniqueUsername,
            Alias = 'tuser',
            ProfileId = profile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            CompanyName = 'Test Company',
            Title = 'Test User',
            IsActive = true
        );
            insert testUser;
            Booking__c bk = new booking__c();
            bk.Customer__c = objOpportunity.id;
            bk.Opportunity__c = objOpportunity.id;
       // bk.RW_Project_Name__c=objpr.id;
            insert bk;
            objOpportunity.Booking__c = bk.Id;
            update objOpportunity;
            Applicant_Details__c apt1 = new Applicant_Details__c();
        apt1.Name = 'Applicant 1';
        apt1.Permanent_Address__c = 'test address';
        apt1.Opportunity__c = objOpportunity.Id;
        apt1.Applicant_Number__c = 'Primary Applicant';
        apt1.Subtype_Of_Applicant__c = 'Indian National';
        apt1.Type_Of_Applicant__c= 'Individual Buyer';
        apt1.Booking__c = bk.Id;
        apt1.DOB__c = Date.today();
        apt1.Office_Address_Line_1__c = 'Office Address Line 1';
        apt1.Mobile_Number__c = '1234567890';
        apt1.Email_Address__c = 'test@test.com';
        apt1.PancardNo__c = 'ABC123456';
        apt1.Address_Proof__c = true;
        apt1.Address_Proof_Document__c = 'Passport';
        apt1.PancardNo__c = 'abc213456';
        insert apt1;
        List<Referral_Credits__c> rcList = new List<Referral_Credits__c> ();
        Referral_Credits__c rc1=new Referral_Credits__c();
        rc1.Referral_In_Rs__c=10000;
        rc1.Reference_Booking__c = bk.id;
        rc1.Booking_RM__c=testUser.id;
        rc1.Name_of_Existing_Customer__c='Testing1';
        rc1.Referral_Credit_Approver_L1__c=testUser.id;
         rc1.Referral_Credit_Approver_L2__c=testUser.id;
        rc1.Existing_Customer_Flat_no__c='20';
       // rc1.Existing_Customer_Flat_no__c='20';
        rc1.Name_of_New_Customer__c ='test';
        rc1.long_text1__c='tets';
        rc1.Flat_no__c='2';
        
        insert rc1;
        rcList.add(rc1);
        Referral_Credits__c rc2=new Referral_Credits__c();
        rc2.Referral_In_Rs__c=100001;
        rc2.Reference_Booking__c = bk.id;
      rc2.Booking_RM__c=testUser.id;
        rc2.Name_of_Existing_Customer__c='Testing1';
        rc2.Existing_Customer_Flat_no__c='20';
       // rc1.Existing_Customer_Flat_no__c='20';
        rc2.Name_of_New_Customer__c ='test';
         rc2.Referral_Credit_Approver_L1__c=testUser.id;
        rc2.Referral_Credit_Approver_L2__c=testUser.id;
       // rc2.Accounts_Team_Email__c='a@g.com';
        
       
        rc2.Flat_no__c='2';
        rc2.long_text1__c='tets';
        insert rc2;
        // rcList.add(rc2);
         rcList.add(rc2);
        List<Id> referralCreditIds = new List<Id>{rc1.Id};
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test File',
            VersionData = Blob.valueOf('Test Content'),
            PathOnClient = 'testfile.txt'
        );
        insert contentVersion;

        List<Object> uploadedFiles = new List<Object>{
            new Map<String, Object>{
                'contentVersionId' => contentVersion.Id
            }
        };

        // Test method
        Test.startTest();
        List<Id> contentLinks = SubmitForApprovalReferral.createContentLink(uploadedFiles, rc1.Id);
        Test.stopTest();

        // Assert results
        System.assertEquals(1, contentLinks.size(), 'Expected one content link to be created.');
    }

    @isTest
    static void testReturnFiles() {
        // Setup test data
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test File',
            VersionData = Blob.valueOf('Test Content'),
            PathOnClient = 'testfile.txt'
        );
        insert contentVersion;

        List<Object> fileIds = new List<Object>{ '(' + contentVersion.Id + ')' };

        // Test method
        Test.startTest();
        List<ContentVersion> files = SubmitForApprovalReferral.returnFiles(fileIds);
        Test.stopTest();

        // Assert results
        System.assertEquals(1, files.size(), 'Expected one file to be returned.');
        System.assertEquals(contentVersion.Id, files[0].Id, 'Expected the correct file to be returned.');
    }

    @isTest
    static void testSendForReferralApproval() {
        user sitehead = UniversalTestClassSetup.createusers('System Administrator', 'site','headpriject','site.head@runwal.com.uat','site.headtest@runwal.com.uat');
      //  system.runas(sitehead){
           Legal_Entity__c objlglentity = new Legal_Entity__c();
            objlglentity.Name = 'RS';
            objlglentity.RDS_Company_Code__c='rs';
            objlglentity.RDS_Service_Tax_No__c= '123456789012345';
            objlglentity.RDS_Company_Name__c='111';
            objlglentity.RDS_Address1__c='123';
            objlglentity.RDS_Address2__c='234';
            objlglentity.RDS_City__c='delhi';
            objlglentity.RDS_Pin_Code__c='201301';
            objlglentity.RDS_Phone__c='9953528045';
            objlglentity=RDSCommon.CreateLegalEntity(objlglentity);
            
            Project__c objpr = new Project__c();
            objpr.RW_Project_Code__c = 'T35';
            objpr.Name = 'Runwal Bliss';
            objpr.Start_Date__c = System.today().addDays(-5);
            objpr.RDS_Company_Code__c = objlglentity.Id;
            objpr.RDS_Interest_Rate__c = 12;
           // objpr.Project_Stage__c='Launch';
            objpr.RW_Address__c = '1403, Fantasy Land, Utopia, Planet Mars, OUTERWORLD CODE -11011';
            objpr.Project_Property_Type__c = 'Residential';
            objpr.S_Floor_Rise_Rate__c = 150;
            objpr.S_Applicable_From_Floor__c = 5;
            objpr.S_View1_PLC__c = 10;
            objpr.S_View2_PLC__c = 20;
            objpr.S_View3_PLC__c = 30;
            objpr.NPV__c = 12;
            objpr.S_Ready_Reckoner_Rate__c = 24000;
            objpr.Token_Amount__c = 200000;
            objpr.Service_Tax_Required_On_Token_Amount__c = true;
            objpr.Total_Max_Discount_Allowed__c = 100;
            objpr.Discount1_Type__c = 'General';
            //objpr.Discount1_Effective_Till__c = system.today().addDays(100);
            objpr.Discount1_Per_Sq_Ft__c = 100;
            objpr.Discount2_Type__c = 'Armed Forces';
           // objpr.Discount2_Per_Sq_Ft__c = 150;
            objpr.Discount3_Type__c = 'Corporate';
            objpr.Discount3_Per_Sq_Ft__c = 200;
            objpr.Discount4_Type__c = 'Employee';
            objpr.Discount4_Per_Sq_Ft__c = 250;
            objpr.Discount5_Type__c = 'NRI';
            objpr.Discount5_Per_Sq_Ft__c = 300;
            objpr.Discount6_Type__c = 'Physically Challenged';
            objpr.Discount6_Per_Sq_Ft__c = 350;
            objpr.Discount8_Description__c = 'summer offer';
            objpr.Discount8_Type__c = 'Special Offer';
            objpr.Discount8_Per_Sq_Ft__c = 1000;
            objpr.Discount9_Description__c = 'DAM';
            objpr.Discount9_Type__c = 'DAM';
            objpr.Discount9_Per_Sq_Ft__c = 2000;
            //objpr.Discount2_Effective_Till__c = system.today().addDays(100);
            objpr.Discount2_Lumpsum__c = 100000;
            objpr.Allotment_Charges_1__c = 10000;
            objpr.Allotment_Charges_2__c = 10000;
            objpr.Allotment_Charges_3__c = 10000;
            objpr.Allotment_Charges_4__c = 10000;
            objpr.Allotment_Charges_5__c = 10000;
            objpr.Allotment_Charges_6__c = 10000;
            objpr=RDSCommon.CreateProject(objpr);
            
            String RecTypeId= [select Id from RecordType where (Name='Person Account') and (SobjectType='Account')].Id;
            
            Account Accnt = new Account(              
                RecordTypeID=RecTypeId,                
                FirstName='TestFName',                
                LastName='TestLName',                
                PersonMailingStreet='test@yahoo.com',                
                PersonMailingPostalCode='12345',                
                PersonMailingCity='SFO',                
                PersonEmail='test@yahoo.com',                
                PersonHomePhone='1234567',                
                PersonMobilePhone='12345678'                 
            );          
            
            insert Accnt;
            
            
            
            Opportunity objOpportunity = new Opportunity();
            objOpportunity.Name = 'Test';
            objOpportunity.Sales_Manager__c = 'Deepak Arya';
            objOpportunity.Sourcing_Manager__c = 'Deepak Arya';
            objOpportunity.CloseDate = System.today();
            objOpportunity.AccountId = Accnt.Id; 
            objOpportunity.Status__c = 'Active'; 
            objOpportunity.StageName = 'Unit Booked'; 
            objOpportunity.SAP_Customer_Number__c ='12345678';
            
            objOpportunity.RW_Project__c = objpr.id; 
            objOpportunity=RDSCommon.CreateOpportunity(objOpportunity);
            Project_Unit__c objPUU = new Project_Unit__c();  
        //objPUU.Project_Unit_Type__c = objPUT.id;  
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c = objpr.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.RW_Unit_Status__c ='Available';
        insert objPUU;
         Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
         String uniqueUsername = 'testuser_' + DateTime.now().getTime() + '@example.com';
        User testUser = new User(
            FirstName = 'Test1',
            LastName = 'User1',
            Email = 'Test@g.com',
            Username = uniqueUsername,
            Alias = 'tuser',
            ProfileId = profile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            CompanyName = 'Test Company',
            Title = 'Test User',
            IsActive = true
        );
            insert testUser;
            Booking__c bk = new booking__c();
            bk.Customer__c = objOpportunity.id;
            bk.Opportunity__c = objOpportunity.id;
       // bk.RW_Project_Name__c=objpr.id;
            insert bk;
            objOpportunity.Booking__c = bk.Id;
            update objOpportunity;
            Applicant_Details__c apt1 = new Applicant_Details__c();
        apt1.Name = 'Applicant 1';
        apt1.Permanent_Address__c = 'test address';
        apt1.Opportunity__c = objOpportunity.Id;
        apt1.Applicant_Number__c = 'Primary Applicant';
        apt1.Subtype_Of_Applicant__c = 'Indian National';
        apt1.Type_Of_Applicant__c= 'Individual Buyer';
        apt1.Booking__c = bk.Id;
        apt1.DOB__c = Date.today();
        apt1.Office_Address_Line_1__c = 'Office Address Line 1';
        apt1.Mobile_Number__c = '1234567890';
        apt1.Email_Address__c = 'test@test.com';
        apt1.PancardNo__c = 'ABC123456';
        apt1.Address_Proof__c = true;
        apt1.Address_Proof_Document__c = 'Passport';
        apt1.PancardNo__c = 'abc213456';
        insert apt1;
        List<Referral_Credits__c> rcList = new List<Referral_Credits__c> ();
        Referral_Credits__c rc1=new Referral_Credits__c();
        rc1.Referral_In_Rs__c=10000;
        rc1.Reference_Booking__c = bk.id;
        rc1.Booking_RM__c=testUser.id;
        rc1.Name_of_Existing_Customer__c='Testing1';
        rc1.Referral_Credit_Approver_L1__c=testUser.id;
         rc1.Referral_Credit_Approver_L2__c=testUser.id;
        rc1.Existing_Customer_Flat_no__c='20';
       // rc1.Existing_Customer_Flat_no__c='20';
        rc1.Name_of_New_Customer__c ='test';
        rc1.long_text1__c='tets';
        rc1.Flat_no__c='2';
        
        insert rc1;
        rcList.add(rc1);
        Referral_Credits__c rc2=new Referral_Credits__c();
        rc2.Referral_In_Rs__c=100001;
        rc2.Reference_Booking__c = bk.id;
      rc2.Booking_RM__c=testUser.id;
        rc2.Name_of_Existing_Customer__c='Testing1';
        rc2.Existing_Customer_Flat_no__c='20';
       // rc1.Existing_Customer_Flat_no__c='20';
        rc2.Name_of_New_Customer__c ='test';
         rc2.Referral_Credit_Approver_L1__c=testUser.id;
        rc2.Referral_Credit_Approver_L2__c=testUser.id;
       // rc2.Accounts_Team_Email__c='a@g.com';
        
       
        rc2.Flat_no__c='2';
        rc2.long_text1__c='teattayas';
        insert rc2;
         rcList.add(rc2);
      
        List<Id> referralCreditIds = new List<Id>{rc1.Id};

        // Test method
        Test.startTest();
        Boolean approvalSent = SubmitForApprovalReferral.SendForReferralApproval('Test Comment', rc1.Id);
        Test.stopTest();

    }
}