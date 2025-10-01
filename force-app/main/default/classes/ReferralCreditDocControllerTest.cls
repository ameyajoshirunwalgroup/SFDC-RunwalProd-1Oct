@isTest
public class ReferralCreditDocControllerTest {
    
    @isTest
    static void testGetCreateDocListAndContentTriggerHandler() {
        
        Project__c p = TestDataFactory.createProject('Xanadu_prj','111');
        list<Tower__c> t = TestDataFactory.createTowers(1,p.Id);
        Account acc = TestDataFactory.createPATemplate('TestPA1' , 'testleada@ozonetest.com', '9876544441', false);
        // List<Opportunity>  oList = New List<Opportunity>();
        List<Lead> llist = TestDataFactory.createLead(3);
        // List<Opportunity>  oList = TestDataFactory.createOpptyForAccount(acc.Id, p.Id, 2);
        Profile pr = [Select Id,Name from Profile where Name = 'NRI Sales Manager'];
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        List<User> lstUser = new List<User>();
        User u1 = new User(LastName = 'Test',
                           FirstName='Test1 User',
                           Alias = 'tstU1',
                           Email = 'testUsr1@stetig.in',
                           Username = 'testUsr1@stetig.in',
                           ProfileId = profileId.id,
                           CTI_Agent_ID__c = 'test.test1',
                           TimeZoneSidKey = 'America/Los_Angeles',
                           EmailEncodingKey = 'UTF-8',
                           LanguageLocaleKey = 'en_US',
                           LocaleSidKey = 'en_US');
        insert u1;
        
        User u = new User();
        u.Username = 'test123@stetig.in';
        u.LastName = 'Test';
        u.ManagerId = u1.Id;
        u.Email = 'test@stetig.in';
        u.Alias = 'Test';
        u.IsActive =true;
        u.EmailEncodingKey='UTF-8';
        u.LocaleSidKey='en_US';
        u.TimeZoneSidKey='America/Los_Angeles';
        u.LanguageLocaleKey='en_US';
        if(pr.Id != null){
            u.ProfileId = pr.Id;
        }
        insert u;
        Opportunity o = new Opportunity(Name = 'Opp-1',RW_CIF_form_number__c = '18787652',Date_Of_Visit__c = system.today().addDays(-2), RW_Sales_Associate__c = 'Test', StageName='Unit Booked', Amount=5000000, AccountId =acc.Id, Status__c ='Active', LeadSource = 'Direct', Lead_Sub_source__c = 'Cross Project',  RW_Project__c = P.Id,closeDate=System.today(),Call_Rating__c = 0);
        insert o;
        list<Opportunity> oList = new list<Opportunity>{o};
            system.debug(oList[0].Name);                
        System.debug('Oplist Size :: ' +oList.size());
        
        Task task = new Task(
            Subject = 'Visit Follow Up - Auto',
            Status = 'Not Started',
            Priority = 'Normal',
            ActivityDate = Date.today().addDays(-5)
        );
        insert task;
        
        Project__c p1 = new Project__c();
        p1.Id = p.Id;
        p1.CRM_MIS_Head__c = userinfo.getUserId();
        p1.CRMHead__c = userinfo.getUserId();
        p1.Home_Loan_Email__c = UserInfo.getUserEmail();
        update p1;
        
        
        Project_Unit_Type__c objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = p.id;
        insert objPUT;
        
        Relationship_Manager__c ObjRm = new Relationship_Manager__c();
        ObjRm.Tower__c = t[0].Id;
        ObjRm.Project__c = p.Id;
        // ObjRm.User__c = u.Id;
        ObjRm.User__c = UserInfo.getUserId();
        ObjRm.Contact_Number__c='9987654323';
        insert ObjRm;
        
        Project_Unit__c objPUU = new Project_Unit__c();  
        objPUU.Project_Unit_Type__c = objPUT.id;
        objPUU.TowerName__c = t[0].Id;
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c = p.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.Relationship_Manager__c=   ObjRm.id;
        objPUU.RW_Unit_Status__c ='Available';
        insert objPUU;
        
        Quotation__c q = new Quotation__c();
        q.Name = 'Q010101';
        q.Quote_Status__c = 'Valid';
        q.Prepared_Date__c = System.today();
        q.Project__c = p.Id;
        q.Project_Unit__c = objPUU.Id;
        q.FloorNo__c = 11;
        q.Opportunity__c = o.Id;
        q.Appartment_Configuration__c = '1 BHK';
        q.Carpet_Area_Sq_Ft__c = 1200;
        q.Token_Amount__c =110000;
        q.ST_Token_Amount__c = 1000;
        q.Allow_booking_without_full_token__c = TRUE;
        q.Agreement_Value__c = 10000000;
        q.Agreement_Value_ST__c = 2537761;
        q.Tandem_car_park_Additional__c = 0;
        q.Tandem_Open_Additional__c= 0;
        q.Single_car_park_Additional__c= 0;
        q.Single_Open_Additional__c = 0;
        q.Stack_Additional__c = 0;
        q.MLCP_Additional__c = null;
        q.Agreement_Value_for_brokers__c = 10000000;
        insert q;   
        
        Booking__c b1 = new Booking__c();
        b1.Customer__c = o.Id;
        b1.Project__c = p.Id;
        b1.Opportunity__c = o.Id;
        b1.Unit_No__c = objPUU.id;
        b1.Quotation__c = q.Id;
        b1.Booking_Date__c = Date.today();
        b1.Account__c = acc.Id;
        b1.Type_of_Client__c = 'Local';
        b1.Status__c = 'Booking Confirmed';
        b1.Source_of_Booking__c = 'Referral';
        b1.Sub_Source__c = 'Existing client reference';
        //b1.Registration_Status__c = 'Due';
        b1.Referral_Passback_Amount__c= 100000;
        //b1.Original_Agreement_Value__c = 1000000;
        b1.Referral_Discount_Amount__c = 100000;
        //b1.Referral_Passback__c = 1;
        b1.X20_Received_Date__c = system.today();
        b1.Customer_Reference_Opportunity__c = o.id;
        b1.RW_Registration_Done__c = 'Yes';
        b1.RW_Registration_Date__c = system.today()-10;
        b1.Exclude_From_Brokerage_Batch__c = false;
        //b.X5_Received__c = true;
        b1.RW_Total_Receipt_Amount_Received__c = 3000000;
        b1.Allotment_Premium__c = 10000000;
        //b1.RW_Registration_Status__c = 'Registration Completed';
        b1.RW_Registration_Type__c = 'Offline Registration';
        b1.RW_Expected_Registration_Date__c = system.today();
        b1.RW_Registration_Done__c = 'No';
        insert b1;
        
        Referral_Credits__c r = new Referral_Credits__c();
        r.Accounts_Head__c = null;//To be Assigned...
        r.Booking_RM__c = UserInfo.getUserId();
        r.Booking__c = b1.Id;
        r.CRN__c = b1.Customer__r.SAP_Customer_Number__c;
        r.Existing_Customer_CRN__c = b1.Customer_Reference_Opportunity__r.SAP_Customer_Number__c;
        r.Existing_Customer_Flat_no__c = b1.Customer_Reference_Flat_No__c;
        r.Flat_no__c = b1.Unit_Number__c;
        r.Name_of_Existing_Customer__c = b1.Customer_Reference_Primary_Applicant_Nam__c;
        r.Name_of_New_Customer__c = b1.Primary_Applicant_Name__c;
        r.Reference_Booking__c = b1.Id;
        r.Referral_Amount_Due__c = b1.Referral_Amount_to_be_Adjusted__c;
        r.Referral_Credit_Approver_L1__c = b1.Project__r.CRM_MIS_Head__c;
        r.Referral_Credit_Approver_L2__c = b1.Project__r.CRMHead__c;
        r.Referral_In_Rs__c = b1.Actual_Referral_Amount__c;
        r.TDS_5_to_be_deducted__c = b1.TDS_5_to_be_deducted__c;
        r.X1_of_Agreement_Value__c = b1.X1_of_Agreement_Value__c;        
        String longText = '';
        longText = 'Customer Referral' +' '+ '('+ b1.Primary_Applicant_Name__c +' )' +b1.Unit_Number__c +' - '+  b1.Referral__c +'%';
        r.long_text1__c = longText;
        r.OwnerId = UserInfo.getUserId();
        r.Vendor_Code__c = '36734824';
        r.SAP_Document_Date__c = system.today();
        r.SAP_Document_No__c = '63789389';
        r.Date_Error_Fixed__c = true;
        r.SAP_Posting_Date__c = system.today();
        insert r;
        
        // Step 2: Create a PDF ContentVersion (important: FileType should resolve to PDF)
        ContentVersion cv = new ContentVersion(
            Title = 'TestFile',
            PathOnClient = 'TestFile.pdf',
            VersionData = Blob.valueOf('Test PDF content')
        );
        insert cv;
        
        // Fetch back with ContentDocumentId
        cv = [
            SELECT Id, ContentDocumentId, FileType
            FROM ContentVersion
            WHERE Id = :cv.Id
            LIMIT 1
        ];
        
        // Step 3: Link ContentDocument to Referral_Credits__c
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = cv.ContentDocumentId,
            LinkedEntityId   = r.Id,
            ShareType        = 'V',
            Visibility       = 'AllUsers'
        );
        insert cdl;
        
        // Step 4: Call Controller (this will internally call ContentTriggerHandler.createPublicLinkForFile)
        Test.startTest();
        ReferralCreditDocController ctrl = new ReferralCreditDocController();
        ctrl.RDHId = r.Id; // setter calls getCreateDocList()
        Test.stopTest();
        
        // Step 5: Query ContentDistribution (should be created by ContentTriggerHandler)
        List<ContentDistribution> cdList = [
            SELECT Id, ContentVersionId, Name, PreferencesAllowViewInBrowser
            FROM ContentDistribution
            WHERE ContentVersionId = :cv.Id
        ];
        
    }
    
    @isTest
    static void testCreateContentDistributionDirectly() {
        // Step 1: Create dummy ContentVersion
        ContentVersion cv = new ContentVersion(
            Title = 'DummyFile',
            PathOnClient = 'DummyFile.pdf',
            VersionData = Blob.valueOf('Some content')
        );
        insert cv;
        
        // Step 2: Call createContentDistribution() directly
        ContentDistribution cd = ContentTriggerHandler.createContentDistribution(cv.Id);
        
    }
}