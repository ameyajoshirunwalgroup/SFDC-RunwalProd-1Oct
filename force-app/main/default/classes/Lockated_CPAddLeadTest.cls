@IsTest
public class Lockated_CPAddLeadTest {

    private static Broker__c createBroker() {
        Account acc = new Account(Name = 'Test Broker Account');
        insert acc;

        User u = createUser();

        Broker__c br = new Broker__c(
            Name = 'Test Broker',
            Account__c = acc.Id,
            Sourcing_Manager__c = u.Id,
            RecordTypeId = Schema.SObjectType.Broker__c
                .getRecordTypeInfosByDeveloperName()
                .get('Channel_Partner')
                .getRecordTypeId()
        );
        insert br;
        return br;
    }
    private static Broker__c createBroker2() {
        Account acc = new Account(Name = 'Test Broker Account');
        insert acc;

        User u = createUser();

        Broker__c br = new Broker__c(
            Name = 'Test Broker',
            Account__c = acc.Id,
            RecordTypeId = Schema.SObjectType.Broker__c
                .getRecordTypeInfosByDeveloperName()
                .get('Channel_Partner')
                .getRecordTypeId()
        );
        insert br;
        return br;
    }

    private static User createUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            Alias = 'tuser',
            Email = 'testuser@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            Username = 'testuser' + System.currentTimeMillis() + '@test.com'
        );
        insert u;
        return u;
    }

    private static Project__c createProject() {
        Project__c p = new Project__c(Name = 'Test Project');
        insert p;
        return p;
    }

    @IsTest
    static void testAddLeadSuccess() {

        Broker__c br = createBroker();
        Project__c proj = createProject();

        String requestBody = JSON.serialize(new Map<String, Object>{
            'customerName' => 'Prashant',
            'mobileNumber' => '9999999999',
            'email' => 'test@test.com',
            'propertyType' => 'Residential',
            'projectInterested' => proj.Name
        });

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/cpAddLead/';
        req.httpMethod = 'POST';
        req.addParameter('cpId', br.Id);
        req.requestBody = Blob.valueOf(requestBody);

        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        Lockated_CPAddLead.doPost();
        Test.stopTest();

        System.assertEquals(200, res.statusCode);

        Map<String, Object> response =
            (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());

    }
    @IsTest
    static void testAddLeadSuccess2() {

        Broker__c br = createBroker2();
        Project__c proj = createProject();

        String requestBody = JSON.serialize(new Map<String, Object>{
            'customerName' => 'Prashant',
            'mobileNumber' => '9999999999',
            'email' => 'test@test.com',
            'propertyType' => 'Residential',
            'projectInterested' => proj.Name
        });

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/cpAddLead/';
        req.httpMethod = 'POST';
        req.addParameter('cpId', br.Id);
        req.requestBody = Blob.valueOf(requestBody);

        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        Lockated_CPAddLead.doPost();
        Test.stopTest();


        Map<String, Object> response =
            (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());

    }

    @IsTest
    static void testMissingCpId() {

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/cpAddLead/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{}');

        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        Lockated_CPAddLead.doPost();
        Test.stopTest();

    }

    @IsTest
    static void testMissingMandatoryFields() {

        Broker__c br = createBroker();

        String requestBody = JSON.serialize(new Map<String, Object>{
            'customerName' => '',
            'mobileNumber' => ''
        });

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/cpAddLead/';
        req.httpMethod = 'POST';
        req.addParameter('cpId', br.Id);
        req.requestBody = Blob.valueOf(requestBody);

        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        Lockated_CPAddLead.doPost();
        Test.stopTest();

    }

    @IsTest
    static void testInvalidProject() {

        Broker__c br = createBroker();

        String requestBody = JSON.serialize(new Map<String, Object>{
            'customerName' => 'Test',
            'mobileNumber' => '8888888888',
            'projectInterested' => 'Non Existing Project'
        });

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/cpAddLead/';
        req.httpMethod = 'POST';
        req.addParameter('cpId', br.Id);
        req.requestBody = Blob.valueOf(requestBody);

        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        Lockated_CPAddLead.doPost();
        Test.stopTest();
    }
    
    
        @isTest
    static void testLockated_CPGetMyLeads1() {
        // --- 1. Setup Test Data ---
                    
            Broker__c cp = new Broker__c();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            
            // Required Lookup/Configuration Records
            // Insert metadata record to prevent SOQL error in start() method, even if we rely on default query
            // The SOQL_Query__c field is left blank to force the batch to use the default query path.
            // Note: Since Batch_Query_Config__mdt is a Custom Metadata Type, we cannot use DML,
            // so we rely on the test execution environment handling the query correctly if the record is set up.
            // For simplicity and to avoid complex setup, we assume a test config record exists or the query gracefully proceeds.
            // If the metadata query is enforced and this fails, a mock or proper setup is needed.
            // For now, we rely on the default query being executed.
            
            Opportunity objcustomer;
            Opportunity objcustomer1;
            Opportunity objcustomer2;
            Booking__c objBooking;
            Project__c objpr;
            Project_Unit__c objPUU;
            Project_Unit__c objPUU1;
            Project_Unit_Type__c objPUT;
            
            Project_Location__c pl = new Project_Location__c();
            pl.Name = 'Mumbai';
            pl.Approver_L1__c = userinfo.getUserId();
            pl.Approver_L2__c = userinfo.getUserId();
            pl.Location__c = 'Mumbai';
            insert pl;

            cp.Name = 'Test CP';
            cp.RW_Email__c = 'teststetig43646@stetig.in';
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
            cp.RW_Mobile_No__c = '1234567890';
            cp.NAME_FIRST__c = 'tets';
            cp.NAME_MIDDLE__c = 'cp';
            cp.NAME_LAST__c = 'test';
            cp.TITLE__c = 'Mr.';
            cp.Account_Number__c = '465446';
            cp.Cheque_DD_Favouring_Name__c = 'test cp';
            cp.IFSC_Code__c = 'BHSHVD';
            cp.Is_NRI_CP__c = false;
            cp.RW_Is_GST_Applicable__c = true;
            cp.Channel_Partner_From_CP_Portal__c =true;
            insert cp;
            
            
			Legal_Entity__c le = new Legal_Entity__c();
            le.RDS_Company_Code__c = '1000';
            le.Name = 'Test Company';
            le.RDS_Company_Name__c = 'Testeee';
            insert le; 
            
            
            objpr = new Project__c();
            objpr.RW_Project_Code__c = 'T31';
            objpr.Name = 'Runwal Bliss';
            objpr.RDS_Short_Name__c = 'T';
            objpr.Start_Date__c = System.today().addDays(-5);
            objpr.RDS_Interest_Rate__c = 12;
            objpr.Project_Location__c = pl.id;
            objpr.RDS_Company_Code__c = le.Id;
            insert objpr;
            
             
            
            Tower__c t = new Tower__c();
            t.Name = 'Tower X';
            t.ProjectName__c = objpr.Id;
            t.Legal_Entity__c = le.id;
            insert t;
          
            
            objPUT = new Project_Unit_Type__c();
            objPUT.RDS_Code__c = '101';
            objPUT.RDS_Project__c = objpr.id;
            insert objPUT;
            
            objPUU = new Project_Unit__c();  
            objPUU.Project_Unit_Type__c = objPUT.id;  
            objPUU.Name = 'TestUnit';      
            objPUU.RW_Project__c = objpr.Id;
            objPUU.RW_Param1__c = '5';
            objPUU.UnitNo__c ='9';
            objPUU.RW_Unit_Status__c ='Available';
            insert objPUU;
            
            objPUU1 = new Project_Unit__c();  
            objPUU1.Project_Unit_Type__c = objPUT.id;  
            objPUU1.Name = 'TestUnit1';      
            objPUU1.RW_Project__c = objpr.Id;
            objPUU1.RW_Param1__c = '5';
            objPUU1.UnitNo__c ='10';
            objPUU1.RW_Unit_Status__c ='Available';
            insert objPUU1;
            
            
            list<lead> llist = new list<lead>();
            lead l = new lead();
            l.RW_Broker__c = cp.Id;
            l.LeadSource = 'Channel Partner';
            l.IsActive__c = true;
            l.Proposed_Visit_Date__c = system.today();
            l.RW_Mobile_No__c = '1122124443';
            l.LastName = 'Testttlast';
            l.RW_Project__c = objpr.Id;
            llist.add(l);
            
            lead l1 = new lead();
            l1.RW_Broker__c = cp.Id;
            l1.LeadSource = 'Channel Partner';
            l1.IsActive__c = false;
            l1.Proposed_Visit_Date__c = system.today();
            l1.RW_Mobile_No__c = '1122124443';
            l1.LastName = 'Testttlast';
            l1.RW_Project__c = objpr.Id;
            llist.add(l1);
            
            insert llist;
            
            
            Brokerage_Scheme__c bscheme = new Brokerage_Scheme__c();
            bscheme.Type__c = 'Both';
            bscheme.Approval_Status__c = 'Approved by Level 2';
            bscheme.Base_Brokerage_for_Local_Bookings__c = 2;
            bscheme.Base_Brokerage_for_OS_NRI__c = 3;
            bscheme.Slab_Type__c = 'Value';
            bscheme.Start_Date__c = system.today();
            bscheme.End_Date__c = system.today()+2;
            bscheme.Project_Location__c = pl.Id;
            insert bscheme;
            
            Kicker_Incentive__c ki = new Kicker_Incentive__c();
            ki.Name = 'Kicker Sep & Oct 2022';
            ki.Brokerage_Scheme__c = bscheme.Id;
            ki.Start_Date__c = system.today();
            ki.End_Date__c = system.today()+2;
            ki.Type__c = 'Cumulative';
            insert ki;
            
            Kicker_Incentive_Configuration__c kic = new Kicker_Incentive_Configuration__c();
            kic.Kicker_Incentive__c = ki.id;
            kic.Project__c = objpr.id;
            insert kic;
            
            Project_Charges__c prc = new Project_Charges__c();
            prc.Name = 'Basic';
            prc.Project__c = objpr.Id;
            insert prc;
            
           
            
            Account a = TestDataFactory.createPATemplate('WC Account', 'wc@stetig.in.com','9098777',false);
            a.Channel_Partner__c = cp.id;
            update a;
            Account cpaccount = [Select Id,Name,Channel_Partner__c from Account where Channel_Partner__c =: cp.Id];
            
            
            
            objcustomer= new Opportunity();
            objcustomer.RW_Project__c=objpr.id;
            objcustomer.name='Test 1';
            objcustomer.StageName='Site Visit';
            //objcustomer.RW_Project_Unit__c=objPUU1.id;  
            objcustomer.CloseDate=system.today();
            objcustomer.Status__c ='Active';
            objCustomer.AccountId = a.Id;
            objcustomer.Sales_Manager__c = 'SM2@g.com';
            objcustomer.RW_Type_of_Client__c = 'Local';
            objcustomer.Channel_Partner_Account__c = cpaccount.Id;
            objcustomer.RW_Walkin_Channel_Partner__c = cp.Id;
            objcustomer.Walkin_Source__c = 'Channel Partner';
            insert objcustomer;
            objcustomer2= new Opportunity();
            objcustomer2.RW_Project__c=objpr.id;
            objcustomer2.name='Test 1';
            objcustomer2.StageName='Qualification';
            //objcustomer2.RW_Project_Unit__c=objPUU1.id;  
            objcustomer2.CloseDate=system.today();
            objcustomer2.Status__c ='Active';
            objcustomer2.AccountId = a.Id;
            objcustomer2.RW_Type_of_Client__c = 'NRI';
            objcustomer2.Channel_Partner_Account__c = cpaccount.Id;
            objcustomer2.RW_Walkin_Channel_Partner__c =  cp.Id;
            objcustomer2.Walkin_Source__c = 'Channel Partner';
            //objcustomer2.Duplicate_Project_Unit_Request__c = false;
            //objcustomer2.Release_Unit__c = false;
            insert objcustomer2;
            list<OTP__c> otplist = new list<OTP__c>();
            OTP__c otp = new OTP__c();
            otp.Generated_OTP__c = '4522';
            otp.Account__c = cpaccount.Id;
            otp.Project__c = objpr.id;
            otp.Lead__c = l.Id;
            otplist.add(otp);
            
            OTP__c otp1 = new OTP__c();
            otp1.Generated_OTP__c = '4522';
            otp1.Account__c = cpaccount.Id;
            otp1.Project__c = objpr.id;
            otp1.Lead__c = l1.Id;
            otplist.add(otp1);
            
            Quotation__c q = new Quotation__c();
            q.Name = 'Q010101';
            q.Quote_Status__c = 'Valid';
            q.Prepared_Date__c = System.today();
            q.Project__c = objpr.Id;
            q.Project_Unit__c = objPUU.Id;
            q.FloorNo__c = 11;
            q.Opportunity__c = objcustomer.Id;
            q.Appartment_Configuration__c = '1 BHK';
            q.Carpet_Area_Sq_Ft__c = 1200;
            q.Token_Amount__c =110000;
            q.ST_Token_Amount__c = 1000;
            q.Allow_booking_without_full_token__c = TRUE;
            q.Agreement_Value__c = 60422880;
            q.Agreement_Value_ST__c = 2537761;
            q.Tandem_car_park_Additional__c = 0;
            q.Tandem_Open_Additional__c= 0;
            q.Single_car_park_Additional__c= 0;
            q.Single_Open_Additional__c = 0;
            q.Stack_Additional__c = 0;
            q.MLCP_Additional__c = null;
            q.Agreement_Value_for_brokers__c = 10000000;
            insert q;
            
            Quotation__c q2 = new Quotation__c();
            q2.Name = 'Q020202';
            q2.Quote_Status__c = 'Approval Pending';
            q2.Prepared_Date__c = System.today();
            q2.Project__c = objpr.Id;
            q2.Project_Unit__c = objPUU1.Id;
            q2.FloorNo__c = 11;
            q2.Opportunity__c = objcustomer2.Id;
            q2.Appartment_Configuration__c = '1 BHK';
            q2.Carpet_Area_Sq_Ft__c = 1200;
            q2.Token_Amount__c =110000;
            q2.ST_Token_Amount__c = 1000;
            q2.Allow_booking_without_full_token__c = TRUE;
            q2.Agreement_Value__c = 60422880;
            q2.Agreement_Value_ST__c = 2537761;
            q2.Tandem_car_park_Additional__c = 0;
            q2.Tandem_Open_Additional__c= 0;
            q2.Single_car_park_Additional__c= 0;
            q2.Single_Open_Additional__c = 0;
            q2.Stack_Additional__c = 0;
            q2.MLCP_Additional__c = null;
            q2.Agreement_Value_for_brokers__c = 10000000;
            //q2.Service_Tax_On_Token_Amount__c = true;
            insert q2;
            
            list<Booking__c> blist = new list<Booking__c>();
            Booking__c b = new Booking__c();
            b.Customer__c = objcustomer.Id;
            b.Project__c = objpr.Id;
            b.Tower__c = t.id;
            b.Opportunity__c = objcustomer.Id;
            b.Unit_No__c = objPUU.id;
            b.Quotation__c = q.Id;
            b.Booking_Date__c = Date.today();
            b.Account__c = cpaccount.Id;
            b.Type_of_Client__c = 'Local';
            b.Status__c = 'Booking Confirmed';
            b.RW_Registration_Done__c = 'No';
            b.BrokerIId__c = cp.Id;
            b.Exclude_From_Brokerage_Batch__c = false;
            b.Brokerage_Scheme__c = null;
            b.Source_of_Booking__c = 'Channel Partner';
            b.Allotment_Premium__c = 10000000;
            b.Brokerage_Scheme__c = bscheme.Id;
            b.Base_Brokerage__c = 2;
            b.Kicker_Incentive_lookup__c = ki.id;
            blist.add(b);
            
            Booking__c b2 = new Booking__c();
            b2.Customer__c = objcustomer2.Id;
            b2.Project__c = objpr.Id;
            b2.Opportunity__c = objcustomer2.Id;
            b2.Unit_No__c = objPUU1.id;
            b2.Quotation__c = q2.Id;
            b2.Booking_Date__c = Date.today();
            b2.Account__c = cpaccount.Id;
            b2.Type_of_Client__c = 'Local';
            b2.Status__c = 'Cancelled';
            b2.RW_Registration_Done__c = 'No';
            b2.BrokerIId__c = cp.Id;
            b2.Exclude_From_Brokerage_Batch__c = false;
            b2.Brokerage_Scheme__c = bscheme.Id;
            b2.Source_of_Booking__c = 'Channel Partner';
            b2.Allotment_Premium__c = 10000000;
            b2.Base_Brokerage__c = 2;
            b2.Kicker_Incentive_lookup__c = ki.Id;
            blist.add(b2);
            insert blist;
            
            Applicant_Details__c apt1 = new Applicant_Details__c();
            apt1.Name = 'Applicant 1';
            apt1.Permanent_Address__c = 'test address';
            apt1.Opportunity__c = objcustomer.Id;
            apt1.Applicant_Number__c = 'Primary Applicant';
            apt1.Subtype_Of_Applicant__c = 'Indian National';
            apt1.Type_Of_Applicant__c= 'Individual Buyer';
            apt1.Booking__c = b.Id;
            apt1.DOB__c = Date.today();
            apt1.Office_Address_Line_1__c = 'Office Address Line 1';
            apt1.Mobile_Number__c = '1234567890';
            apt1.Email_Address__c = 'test@test.com';
            apt1.PancardNo__c = 'ABC123456';
            apt1.Address_Proof__c = true;
            apt1.Address_Proof_Document__c = 'Passport';
            apt1.PancardNo__c = 'abc213456';
            insert apt1;
            
            Brokerage_Summary__c bs = new Brokerage_Summary__c();
            bs.Channel_Partner__c = cp.Id;
            bs.Opportunity__c = objcustomer2.Id;
            bs.CP_Account__c = cpaccount.Id;
            bs.Applied_Slab_Name__c = 'Slab 2';
            bs.Booking__c = b.Id;
            insert bs;
            
            Brokerage__c bro = new Brokerage__c();
            bro.Name = 'Base Brokerage';
            bro.Brokerage__c = 2;
            bro.Brokerage_Amount__c = 272059;
            bro.Channel_Partner__c = cp.Id;
            bro.Opportunity__c = objcustomer.Id;
            bro.Brokerage_Summary__c = bs.Id;
            bro.Opportunity_AV__c = 13602975;
            bro.Brokerage_Type__c = 'Additional Brokerage';
            bro.Booking__c = b.Id;
            insert bro;
            
            Brokerage_Invoice__c bi = new Brokerage_Invoice__c();
            bi.Brokerage_Summary__c = bs.id;
            bi.Brokerage_Lookup__c = bro.id;
            bi.Channel_Partner__c = cp.Id;
            bi.Booking__c = b.Id;
            bi.Invoice_Number__c = '35352';
            bi.If_GST_is_applicable__c = 'Yes';
            bi.Brokerage__c = 2;
            bi.Total_Agreement_Value__c = 13602975;
            bi.Invoice_Status__c = 'Not Submitted';
            bi.Opportunity__c = objcustomer.Id;
            bi.Invoice_Date__c = system.today();
            bi.Brokerage_In_Rs__c = 53633;
            insert bi;
            
            Brokerage_Invoice__c bi2 = new Brokerage_Invoice__c();
            bi2.Brokerage_Summary__c = bs.id;
            bi2.Brokerage_Lookup__c = bro.id;
            bi2.Channel_Partner__c = cp.Id;
            bi2.Booking__c = b.Id;
            bi2.Invoice_Number__c = '35352';
            bi2.If_GST_is_applicable__c = 'No';
            bi2.Brokerage__c = 2;
            bi2.Total_Agreement_Value__c = 13602975;
            bi2.Invoice_Status__c = 'Not Submitted';
            bi2.Opportunity__c = objcustomer.Id;
            bi2.Invoice_Date__c = system.today();
            bi2.Brokerage_In_Rs__c = 53633;
            insert bi2;
            
            Brokerage__c bro2 = new Brokerage__c();
            bro2.Name = 'Base Brokerage';
            bro2.Brokerage__c = 2;
            bro2.Brokerage_Amount__c = 272059;
            bro2.Channel_Partner__c = cp.Id;
            bro2.Opportunity__c = objcustomer.Id;
            bro2.Brokerage_Summary__c = bs.Id;
            bro2.Opportunity_AV__c = 13602975;
            bro2.Brokerage_Type__c = 'Additional Brokerage';
            bro2.Booking__c = b.Id;
            insert bro2;
            
            
            Brokerage_Invoice__c bi3 = new Brokerage_Invoice__c();
            bi3.Brokerage_Summary__c = bs.id;
            bi3.Brokerage_Lookup__c = bro2.id;
            bi3.Channel_Partner__c = cp.Id;
            bi3.Booking__c = b.Id;
            bi3.CP_Brokerage__c = null;
            bi3.Invoice_Number__c = '35352';
            bi3.If_GST_is_applicable__c = 'Yes';
            bi3.Brokerage__c = 2;
            bi3.Total_Agreement_Value__c = 13602975;
            bi3.Invoice_Status__c = 'Not Submitted';
            bi3.Opportunity__c = objcustomer.Id;
            bi3.Invoice_Date__c = system.today();
            bi3.Brokerage_In_Rs__c = 53633;
            bi3.SAP_Document_No__c = '678839';
            bi3.Invoice_Status__c = 'Invoice Uploaded';
            //bi3.Status__c = 'Paid';
            insert bi3;
            
            Brokerage_Receipt__c br1 = new Brokerage_Receipt__c(
                Brokerage_Invoice__c = bi3.Id,
                Invoice_Amount__c = 54000
            );
            //insert br1;  
            /*
            list<Brokerage_Invoice__c> invvv = [Select Id,Booking__c, Booking__r.Tower__r.Legal_Entity__c,Brokerage_Lookup__r.Brokerage_Type__c,
                Booking__r.Tower__r.Legal_Entity__r.RDS_Company_Name__c, CP_Brokerage__c,
                Channel_Partner__c, Invoice_Amount__c, CreatedDate, 
                Brokerage_Lookup__r.Name, Booking__r.Name, Channel_Partner__r.Name, 
                CP_Invoice_Clearing_L1__c, CP_Invoice_Clearing_L2__c, 
                CP_Invoice_Approver_L1__c, CP_Invoice_Approver_L2__c, CP_Invoice_Approver_L3__c,
                CP_Invoice_Approver_L4__c, CP_Invoice_Approver_L5__c  from Brokerage_Invoice__c];
            for(Brokerage_Invoice__c i : invvv){
                system.debug('invoices -> '+i);
                system.debug('invoices[0].Brokerage_Lookup__c -> '+i.Brokerage_Lookup__r.Brokerage_Type__c);
                system.debug('invoices[0].CreatedDate -> '+i.CreatedDate);
                system.debug('invoices[0].Booking__r.Tower__r.Legal_Entity__c -> '+i.Booking__r.Tower__r.Legal_Entity__c);
                system.debug('invoices[0].Booking__r.Tower__r.Legal_Entity__r.RDS_Company_Name__c -> '+i.Booking__r.Tower__r.Legal_Entity__r.RDS_Company_Name__c);
                system.debug('invoices[0].Channel_Partner__c -> '+i.Channel_Partner__c);
                system.debug('invoices[0].CP_Brokerage__c -> '+i.CP_Brokerage__c);
            }
            list<Brokerage_Invoice__c> invoices = [SELECT Id, Booking__c, Booking__r.Tower__r.Legal_Entity__c,Brokerage_Lookup__r.Brokerage_Type__c,
                Booking__r.Tower__r.Legal_Entity__r.RDS_Company_Name__c, CP_Brokerage__c,
                Channel_Partner__c, Invoice_Amount__c, CreatedDate, 
                Brokerage_Lookup__r.Name, Booking__r.Name, Channel_Partner__r.Name, 
                CP_Invoice_Clearing_L1__c, CP_Invoice_Clearing_L2__c, 
                CP_Invoice_Approver_L1__c, CP_Invoice_Approver_L2__c, CP_Invoice_Approver_L3__c,
                CP_Invoice_Approver_L4__c, CP_Invoice_Approver_L5__c 
                FROM Brokerage_Invoice__c 
                WHERE Brokerage_Lookup__r.Brokerage_Type__c = 'Additional Brokerage'
                AND CreatedDate = THIS_MONTH 
                AND Booking__r.Tower__r.Legal_Entity__c != null 
                AND Booking__r.Tower__r.Legal_Entity__r.RDS_Company_Name__c != null 
                AND Channel_Partner__c != null 
                AND CP_Brokerage__c = null];
            system.debug('invoices -> '+invoices);
            system.debug('invoices[0].Brokerage_Lookup__c -> '+invoices[0].Brokerage_Lookup__r.Brokerage_Type__c);
            system.debug('invoices[0].CreatedDate -> '+invoices[0].CreatedDate);
            system.debug('invoices[0].Booking__r.Tower__r.Legal_Entity__c -> '+invoices[0].Booking__r.Tower__r.Legal_Entity__c);
            system.debug('invoices[0].Booking__r.Tower__r.Legal_Entity__r.RDS_Company_Name__c -> '+invoices[0].Booking__r.Tower__r.Legal_Entity__r.RDS_Company_Name__c);
            system.debug('invoices[0].Channel_Partner__c -> '+invoices[0].Channel_Partner__c);
            system.debug('invoices[0].CP_Brokerage__c -> '+invoices[0].CP_Brokerage__c);
            */
        }

        // --- 2. Execute Batch ---
        // 
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'GET';
        req.requestURI = '/services/apexrest/cpGetDetails';
        req.addParameter('cpId', cp.Id);
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        
        Lockated_CPGetMyLeads.doGet();
        Test.stopTest();

    }
    
      @isTest
    static void testLockated_CPGetMyLeads2() {
        // --- 1. Setup Test Data ---
                    
            Broker__c cp = new Broker__c();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            
            // Required Lookup/Configuration Records
            // Insert metadata record to prevent SOQL error in start() method, even if we rely on default query
            // The SOQL_Query__c field is left blank to force the batch to use the default query path.
            // Note: Since Batch_Query_Config__mdt is a Custom Metadata Type, we cannot use DML,
            // so we rely on the test execution environment handling the query correctly if the record is set up.
            // For simplicity and to avoid complex setup, we assume a test config record exists or the query gracefully proceeds.
            // If the metadata query is enforced and this fails, a mock or proper setup is needed.
            // For now, we rely on the default query being executed.
            
            Opportunity objcustomer;
            Opportunity objcustomer1;
            Opportunity objcustomer2;
            Booking__c objBooking;
            Project__c objpr;
            Project_Unit__c objPUU;
            Project_Unit__c objPUU1;
            Project_Unit_Type__c objPUT;
            
            Project_Location__c pl = new Project_Location__c();
            pl.Name = 'Mumbai';
            pl.Approver_L1__c = userinfo.getUserId();
            pl.Approver_L2__c = userinfo.getUserId();
            pl.Location__c = 'Mumbai';
            insert pl;

            cp.Name = 'Test CP';
            cp.RW_Email__c = 'teststetig43646@stetig.in';
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
            cp.RW_Mobile_No__c = '1234567890';
            cp.NAME_FIRST__c = 'tets';
            cp.NAME_MIDDLE__c = 'cp';
            cp.NAME_LAST__c = 'test';
            cp.TITLE__c = 'Mr.';
            cp.Account_Number__c = '465446';
            cp.Cheque_DD_Favouring_Name__c = 'test cp';
            cp.IFSC_Code__c = 'BHSHVD';
            cp.Is_NRI_CP__c = false;
            cp.RW_Is_GST_Applicable__c = true;
            cp.Channel_Partner_From_CP_Portal__c =true;
            Id TempCPRecordTypeId = Schema.SObjectType.Broker__c.getRecordTypeInfosByName().get('Temp Channel Partner').getRecordTypeId();                   
            cp.RecordTypeId = TempCPRecordTypeId;
            insert cp;
            
            
			Legal_Entity__c le = new Legal_Entity__c();
            le.RDS_Company_Code__c = '1000';
            le.Name = 'Test Company';
            le.RDS_Company_Name__c = 'Testeee';
            insert le; 
            
            
            objpr = new Project__c();
            objpr.RW_Project_Code__c = 'T31';
            objpr.Name = 'Runwal Bliss';
            objpr.RDS_Short_Name__c = 'T';
            objpr.Start_Date__c = System.today().addDays(-5);
            objpr.RDS_Interest_Rate__c = 12;
            objpr.Project_Location__c = pl.id;
            objpr.RDS_Company_Code__c = le.Id;
            insert objpr;
            
             
            
            Tower__c t = new Tower__c();
            t.Name = 'Tower X';
            t.ProjectName__c = objpr.Id;
            t.Legal_Entity__c = le.id;
            insert t;
          
            
            objPUT = new Project_Unit_Type__c();
            objPUT.RDS_Code__c = '101';
            objPUT.RDS_Project__c = objpr.id;
            insert objPUT;
            
            objPUU = new Project_Unit__c();  
            objPUU.Project_Unit_Type__c = objPUT.id;  
            objPUU.Name = 'TestUnit';      
            objPUU.RW_Project__c = objpr.Id;
            objPUU.RW_Param1__c = '5';
            objPUU.UnitNo__c ='9';
            objPUU.RW_Unit_Status__c ='Available';
            insert objPUU;
            
            objPUU1 = new Project_Unit__c();  
            objPUU1.Project_Unit_Type__c = objPUT.id;  
            objPUU1.Name = 'TestUnit1';      
            objPUU1.RW_Project__c = objpr.Id;
            objPUU1.RW_Param1__c = '5';
            objPUU1.UnitNo__c ='10';
            objPUU1.RW_Unit_Status__c ='Available';
            insert objPUU1;
            
            list<lead> llist = new list<lead>();
            lead l = new lead();
            l.RW_Broker__c = cp.Id;
            l.LeadSource = 'Temp Channel Partner';
            l.IsActive__c = true;
            l.Proposed_Visit_Date__c = system.today();
            l.RW_Mobile_No__c = '1122124443';
            l.LastName = 'Testttlast';
            l.RW_Project__c = objpr.Id;
            llist.add(l);
            
            lead l1 = new lead();
            l1.RW_Broker__c = cp.Id;
            l1.LeadSource = 'Temp Channel Partner';
            l1.IsActive__c = false;
            l1.Proposed_Visit_Date__c = system.today();
            l1.RW_Mobile_No__c = '1122124443';
            l1.LastName = 'Testttlast';
            l1.RW_Project__c = objpr.Id;
            llist.add(l1);
            
            insert llist;
            
            
            Brokerage_Scheme__c bscheme = new Brokerage_Scheme__c();
            bscheme.Type__c = 'Both';
            bscheme.Approval_Status__c = 'Approved by Level 2';
            bscheme.Base_Brokerage_for_Local_Bookings__c = 2;
            bscheme.Base_Brokerage_for_OS_NRI__c = 3;
            bscheme.Slab_Type__c = 'Value';
            bscheme.Start_Date__c = system.today();
            bscheme.End_Date__c = system.today()+2;
            bscheme.Project_Location__c = pl.Id;
            insert bscheme;
            
            Kicker_Incentive__c ki = new Kicker_Incentive__c();
            ki.Name = 'Kicker Sep & Oct 2022';
            ki.Brokerage_Scheme__c = bscheme.Id;
            ki.Start_Date__c = system.today();
            ki.End_Date__c = system.today()+2;
            ki.Type__c = 'Cumulative';
            insert ki;
            
            Kicker_Incentive_Configuration__c kic = new Kicker_Incentive_Configuration__c();
            kic.Kicker_Incentive__c = ki.id;
            kic.Project__c = objpr.id;
            insert kic;
            
            Project_Charges__c prc = new Project_Charges__c();
            prc.Name = 'Basic';
            prc.Project__c = objpr.Id;
            insert prc;
            
           
            
            Account a = TestDataFactory.createPATemplate('WC Account', 'wc@stetig.in.com','9098777',false);
            a.Channel_Partner__c = cp.id;
            update a;
            Account cpaccount = [Select Id,Name,Channel_Partner__c from Account where Channel_Partner__c =: cp.Id];
            
            
            
            objcustomer= new Opportunity();
            objcustomer.RW_Project__c=objpr.id;
            objcustomer.name='Test 1';
            objcustomer.StageName='Site Visit';
            //objcustomer.RW_Project_Unit__c=objPUU1.id;  
            objcustomer.CloseDate=system.today();
            objcustomer.Status__c ='Active';
            objCustomer.AccountId = a.Id;
            objcustomer.Sales_Manager__c = 'SM2@g.com';
            objcustomer.RW_Type_of_Client__c = 'Local';
            objcustomer.Channel_Partner_Account__c = cpaccount.Id;
            objcustomer.RW_Walkin_Channel_Partner__c = cp.Id;
            objcustomer.Walkin_Source__c = 'Temp Channel Partner';
            insert objcustomer;
            objcustomer2= new Opportunity();
            objcustomer2.RW_Project__c=objpr.id;
            objcustomer2.name='Test 1';
            objcustomer2.StageName='Qualification';
            //objcustomer2.RW_Project_Unit__c=objPUU1.id;  
            objcustomer2.CloseDate=system.today();
            objcustomer2.Status__c ='Active';
            objcustomer2.AccountId = a.Id;
            objcustomer2.RW_Type_of_Client__c = 'NRI';
            objcustomer2.Channel_Partner_Account__c = cpaccount.Id;
            objcustomer2.RW_Walkin_Channel_Partner__c =  cp.Id;
            objcustomer2.Walkin_Source__c = 'Temp Channel Partner';
            //objcustomer2.Duplicate_Project_Unit_Request__c = false;
            //objcustomer2.Release_Unit__c = false;
            insert objcustomer2;
            list<OTP__c> otplist = new list<OTP__c>();
            OTP__c otp = new OTP__c();
            otp.Generated_OTP__c = '4522';
            otp.Account__c = cpaccount.Id;
            otp.Project__c = objpr.id;
            otp.Lead__c = l.Id;
            otplist.add(otp);
            
            OTP__c otp1 = new OTP__c();
            otp1.Generated_OTP__c = '4522';
            otp1.Account__c = cpaccount.Id;
            otp1.Project__c = objpr.id;
            otp1.Lead__c = l1.Id;
            otplist.add(otp1);
            
            insert otplist;
            
            Quotation__c q = new Quotation__c();
            q.Name = 'Q010101';
            q.Quote_Status__c = 'Valid';
            q.Prepared_Date__c = System.today();
            q.Project__c = objpr.Id;
            q.Project_Unit__c = objPUU.Id;
            q.FloorNo__c = 11;
            q.Opportunity__c = objcustomer.Id;
            q.Appartment_Configuration__c = '1 BHK';
            q.Carpet_Area_Sq_Ft__c = 1200;
            q.Token_Amount__c =110000;
            q.ST_Token_Amount__c = 1000;
            q.Allow_booking_without_full_token__c = TRUE;
            q.Agreement_Value__c = 60422880;
            q.Agreement_Value_ST__c = 2537761;
            q.Tandem_car_park_Additional__c = 0;
            q.Tandem_Open_Additional__c= 0;
            q.Single_car_park_Additional__c= 0;
            q.Single_Open_Additional__c = 0;
            q.Stack_Additional__c = 0;
            q.MLCP_Additional__c = null;
            q.Agreement_Value_for_brokers__c = 10000000;
            insert q;
            
            Quotation__c q2 = new Quotation__c();
            q2.Name = 'Q020202';
            q2.Quote_Status__c = 'Approval Pending';
            q2.Prepared_Date__c = System.today();
            q2.Project__c = objpr.Id;
            q2.Project_Unit__c = objPUU1.Id;
            q2.FloorNo__c = 11;
            q2.Opportunity__c = objcustomer2.Id;
            q2.Appartment_Configuration__c = '1 BHK';
            q2.Carpet_Area_Sq_Ft__c = 1200;
            q2.Token_Amount__c =110000;
            q2.ST_Token_Amount__c = 1000;
            q2.Allow_booking_without_full_token__c = TRUE;
            q2.Agreement_Value__c = 60422880;
            q2.Agreement_Value_ST__c = 2537761;
            q2.Tandem_car_park_Additional__c = 0;
            q2.Tandem_Open_Additional__c= 0;
            q2.Single_car_park_Additional__c= 0;
            q2.Single_Open_Additional__c = 0;
            q2.Stack_Additional__c = 0;
            q2.MLCP_Additional__c = null;
            q2.Agreement_Value_for_brokers__c = 10000000;
            //q2.Service_Tax_On_Token_Amount__c = true;
            insert q2;
            
            list<Booking__c> blist = new list<Booking__c>();
            Booking__c b = new Booking__c();
            b.Customer__c = objcustomer.Id;
            b.Project__c = objpr.Id;
            b.Tower__c = t.id;
            b.Opportunity__c = objcustomer.Id;
            b.Unit_No__c = objPUU.id;
            b.Quotation__c = q.Id;
            b.Booking_Date__c = Date.today();
            b.Account__c = cpaccount.Id;
            b.Type_of_Client__c = 'Local';
            b.Status__c = 'Booking Confirmed';
            b.RW_Registration_Done__c = 'No';
            b.BrokerIId__c = cp.Id;
            b.Exclude_From_Brokerage_Batch__c = false;
            b.Brokerage_Scheme__c = null;
            b.Source_of_Booking__c = 'Temp Channel Partner';
            b.Allotment_Premium__c = 10000000;
            b.Brokerage_Scheme__c = bscheme.Id;
            b.Base_Brokerage__c = 2;
            b.Kicker_Incentive_lookup__c = ki.id;
            blist.add(b);
            
            Booking__c b2 = new Booking__c();
            b2.Customer__c = objcustomer2.Id;
            b2.Project__c = objpr.Id;
            b2.Opportunity__c = objcustomer2.Id;
            b2.Unit_No__c = objPUU1.id;
            b2.Quotation__c = q2.Id;
            b2.Booking_Date__c = Date.today();
            b2.Account__c = cpaccount.Id;
            b2.Type_of_Client__c = 'Local';
            b2.Status__c = 'Cancelled';
            b2.RW_Registration_Done__c = 'No';
            b2.BrokerIId__c = cp.Id;
            b2.Exclude_From_Brokerage_Batch__c = false;
            b2.Brokerage_Scheme__c = bscheme.Id;
            b2.Source_of_Booking__c = 'Temp Channel Partner';
            b2.Allotment_Premium__c = 10000000;
            b2.Base_Brokerage__c = 2;
            b2.Kicker_Incentive_lookup__c = ki.Id;
            blist.add(b2);
            insert blist;
            
            Applicant_Details__c apt1 = new Applicant_Details__c();
            apt1.Name = 'Applicant 1';
            apt1.Permanent_Address__c = 'test address';
            apt1.Opportunity__c = objcustomer.Id;
            apt1.Applicant_Number__c = 'Primary Applicant';
            apt1.Subtype_Of_Applicant__c = 'Indian National';
            apt1.Type_Of_Applicant__c= 'Individual Buyer';
            apt1.Booking__c = b.Id;
            apt1.DOB__c = Date.today();
            apt1.Office_Address_Line_1__c = 'Office Address Line 1';
            apt1.Mobile_Number__c = '1234567890';
            apt1.Email_Address__c = 'test@test.com';
            apt1.PancardNo__c = 'ABC123456';
            apt1.Address_Proof__c = true;
            apt1.Address_Proof_Document__c = 'Passport';
            apt1.PancardNo__c = 'abc213456';
            insert apt1;
            
            Brokerage_Summary__c bs = new Brokerage_Summary__c();
            bs.Channel_Partner__c = cp.Id;
            bs.Opportunity__c = objcustomer2.Id;
            bs.CP_Account__c = cpaccount.Id;
            bs.Applied_Slab_Name__c = 'Slab 2';
            bs.Booking__c = b.Id;
            insert bs;
            
            Brokerage__c bro = new Brokerage__c();
            bro.Name = 'Base Brokerage';
            bro.Brokerage__c = 2;
            bro.Brokerage_Amount__c = 272059;
            bro.Channel_Partner__c = cp.Id;
            bro.Opportunity__c = objcustomer.Id;
            bro.Brokerage_Summary__c = bs.Id;
            bro.Opportunity_AV__c = 13602975;
            bro.Brokerage_Type__c = 'Additional Brokerage';
            bro.Booking__c = b.Id;
            insert bro;
            
            Brokerage_Invoice__c bi = new Brokerage_Invoice__c();
            bi.Brokerage_Summary__c = bs.id;
            bi.Brokerage_Lookup__c = bro.id;
            bi.Channel_Partner__c = cp.Id;
            bi.Booking__c = b.Id;
            bi.Invoice_Number__c = '35352';
            bi.If_GST_is_applicable__c = 'Yes';
            bi.Brokerage__c = 2;
            bi.Total_Agreement_Value__c = 13602975;
            bi.Invoice_Status__c = 'Not Submitted';
            bi.Opportunity__c = objcustomer.Id;
            bi.Invoice_Date__c = system.today();
            bi.Brokerage_In_Rs__c = 53633;
            insert bi;
            
            Brokerage_Invoice__c bi2 = new Brokerage_Invoice__c();
            bi2.Brokerage_Summary__c = bs.id;
            bi2.Brokerage_Lookup__c = bro.id;
            bi2.Channel_Partner__c = cp.Id;
            bi2.Booking__c = b.Id;
            bi2.Invoice_Number__c = '35352';
            bi2.If_GST_is_applicable__c = 'No';
            bi2.Brokerage__c = 2;
            bi2.Total_Agreement_Value__c = 13602975;
            bi2.Invoice_Status__c = 'Not Submitted';
            bi2.Opportunity__c = objcustomer.Id;
            bi2.Invoice_Date__c = system.today();
            bi2.Brokerage_In_Rs__c = 53633;
            insert bi2;
            
            Brokerage__c bro2 = new Brokerage__c();
            bro2.Name = 'Base Brokerage';
            bro2.Brokerage__c = 2;
            bro2.Brokerage_Amount__c = 272059;
            bro2.Channel_Partner__c = cp.Id;
            bro2.Opportunity__c = objcustomer.Id;
            bro2.Brokerage_Summary__c = bs.Id;
            bro2.Opportunity_AV__c = 13602975;
            bro2.Brokerage_Type__c = 'Additional Brokerage';
            bro2.Booking__c = b.Id;
            insert bro2;
            
            
            Brokerage_Invoice__c bi3 = new Brokerage_Invoice__c();
            bi3.Brokerage_Summary__c = bs.id;
            bi3.Brokerage_Lookup__c = bro2.id;
            bi3.Channel_Partner__c = cp.Id;
            bi3.Booking__c = b.Id;
            bi3.CP_Brokerage__c = null;
            bi3.Invoice_Number__c = '35352';
            bi3.If_GST_is_applicable__c = 'Yes';
            bi3.Brokerage__c = 2;
            bi3.Total_Agreement_Value__c = 13602975;
            bi3.Invoice_Status__c = 'Not Submitted';
            bi3.Opportunity__c = objcustomer.Id;
            bi3.Invoice_Date__c = system.today();
            bi3.Brokerage_In_Rs__c = 53633;
            bi3.SAP_Document_No__c = '678839';
            bi3.Invoice_Status__c = 'Invoice Uploaded';
            //bi3.Status__c = 'Paid';
            insert bi3;
            
            Brokerage_Receipt__c br1 = new Brokerage_Receipt__c(
                Brokerage_Invoice__c = bi3.Id,
                Invoice_Amount__c = 54000
            );
            //insert br1;  
            /*
            list<Brokerage_Invoice__c> invvv = [Select Id,Booking__c, Booking__r.Tower__r.Legal_Entity__c,Brokerage_Lookup__r.Brokerage_Type__c,
                Booking__r.Tower__r.Legal_Entity__r.RDS_Company_Name__c, CP_Brokerage__c,
                Channel_Partner__c, Invoice_Amount__c, CreatedDate, 
                Brokerage_Lookup__r.Name, Booking__r.Name, Channel_Partner__r.Name, 
                CP_Invoice_Clearing_L1__c, CP_Invoice_Clearing_L2__c, 
                CP_Invoice_Approver_L1__c, CP_Invoice_Approver_L2__c, CP_Invoice_Approver_L3__c,
                CP_Invoice_Approver_L4__c, CP_Invoice_Approver_L5__c  from Brokerage_Invoice__c];
            for(Brokerage_Invoice__c i : invvv){
                system.debug('invoices -> '+i);
                system.debug('invoices[0].Brokerage_Lookup__c -> '+i.Brokerage_Lookup__r.Brokerage_Type__c);
                system.debug('invoices[0].CreatedDate -> '+i.CreatedDate);
                system.debug('invoices[0].Booking__r.Tower__r.Legal_Entity__c -> '+i.Booking__r.Tower__r.Legal_Entity__c);
                system.debug('invoices[0].Booking__r.Tower__r.Legal_Entity__r.RDS_Company_Name__c -> '+i.Booking__r.Tower__r.Legal_Entity__r.RDS_Company_Name__c);
                system.debug('invoices[0].Channel_Partner__c -> '+i.Channel_Partner__c);
                system.debug('invoices[0].CP_Brokerage__c -> '+i.CP_Brokerage__c);
            }
            list<Brokerage_Invoice__c> invoices = [SELECT Id, Booking__c, Booking__r.Tower__r.Legal_Entity__c,Brokerage_Lookup__r.Brokerage_Type__c,
                Booking__r.Tower__r.Legal_Entity__r.RDS_Company_Name__c, CP_Brokerage__c,
                Channel_Partner__c, Invoice_Amount__c, CreatedDate, 
                Brokerage_Lookup__r.Name, Booking__r.Name, Channel_Partner__r.Name, 
                CP_Invoice_Clearing_L1__c, CP_Invoice_Clearing_L2__c, 
                CP_Invoice_Approver_L1__c, CP_Invoice_Approver_L2__c, CP_Invoice_Approver_L3__c,
                CP_Invoice_Approver_L4__c, CP_Invoice_Approver_L5__c 
                FROM Brokerage_Invoice__c 
                WHERE Brokerage_Lookup__r.Brokerage_Type__c = 'Additional Brokerage'
                AND CreatedDate = THIS_MONTH 
                AND Booking__r.Tower__r.Legal_Entity__c != null 
                AND Booking__r.Tower__r.Legal_Entity__r.RDS_Company_Name__c != null 
                AND Channel_Partner__c != null 
                AND CP_Brokerage__c = null];
            system.debug('invoices -> '+invoices);
            system.debug('invoices[0].Brokerage_Lookup__c -> '+invoices[0].Brokerage_Lookup__r.Brokerage_Type__c);
            system.debug('invoices[0].CreatedDate -> '+invoices[0].CreatedDate);
            system.debug('invoices[0].Booking__r.Tower__r.Legal_Entity__c -> '+invoices[0].Booking__r.Tower__r.Legal_Entity__c);
            system.debug('invoices[0].Booking__r.Tower__r.Legal_Entity__r.RDS_Company_Name__c -> '+invoices[0].Booking__r.Tower__r.Legal_Entity__r.RDS_Company_Name__c);
            system.debug('invoices[0].Channel_Partner__c -> '+invoices[0].Channel_Partner__c);
            system.debug('invoices[0].CP_Brokerage__c -> '+invoices[0].CP_Brokerage__c);
            */
        }

        // --- 2. Execute Batch ---
        // 
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'GET';
        req.requestURI = '/services/apexrest/cpGetDetails';
        req.addParameter('cpId', cp.Id);
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        
        Lockated_CPGetMyLeads.doGet();
        Test.stopTest();

    }
    
    
     @IsTest
    static void testDoPost_CPLead() {
        
        // --- 1. Setup Test Data ---
                    
            Broker__c cp = new Broker__c();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            
            // Required Lookup/Configuration Records
            // Insert metadata record to prevent SOQL error in start() method, even if we rely on default query
            // The SOQL_Query__c field is left blank to force the batch to use the default query path.
            // Note: Since Batch_Query_Config__mdt is a Custom Metadata Type, we cannot use DML,
            // so we rely on the test execution environment handling the query correctly if the record is set up.
            // For simplicity and to avoid complex setup, we assume a test config record exists or the query gracefully proceeds.
            // If the metadata query is enforced and this fails, a mock or proper setup is needed.
            // For now, we rely on the default query being executed.
            
            Opportunity objcustomer;
            Opportunity objcustomer1;
            Opportunity objcustomer2;
            Booking__c objBooking;
            Project_Unit__c objPUU;
            Project_Unit__c objPUU1;
            Project_Unit_Type__c objPUT;
            
            Project_Location__c pl = new Project_Location__c();
            pl.Name = 'Mumbai';
            pl.Approver_L1__c = userinfo.getUserId();
            pl.Approver_L2__c = userinfo.getUserId();
            pl.Location__c = 'Mumbai';
            insert pl;
            
			Legal_Entity__c le = new Legal_Entity__c();
            le.RDS_Company_Code__c = '1000';
            le.Name = 'Test Company';
            le.RDS_Company_Name__c = 'Testeee';
            insert le; 
            
            Project__c objpr = new Project__c();
            objpr.RW_Project_Code__c = 'T31';
            objpr.Name = 'Runwal Bliss';
            objpr.RDS_Short_Name__c = 'T';
            objpr.Start_Date__c = System.today().addDays(-5);
            objpr.RDS_Interest_Rate__c = 12;
            objpr.Project_Location__c = pl.id;
            objpr.RDS_Company_Code__c = le.Id;
            insert objpr;
            

            cp.Name = 'Test CP';
            cp.RW_Email__c = 'teststetig43646@stetig.in';
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
            cp.RW_Mobile_No__c = '1234567890';
            cp.NAME_FIRST__c = 'tets';
            cp.NAME_MIDDLE__c = 'cp';
            cp.NAME_LAST__c = 'test';
            cp.TITLE__c = 'Mr.';
            cp.Account_Number__c = '465446';
            cp.Cheque_DD_Favouring_Name__c = 'test cp';
            cp.IFSC_Code__c = 'BHSHVD';
            cp.Is_NRI_CP__c = false;
            cp.RW_Is_GST_Applicable__c = true;
            cp.Channel_Partner_From_CP_Portal__c =true;
            Id TempCPRecordTypeId = Schema.SObjectType.Broker__c.getRecordTypeInfosByName().get('Temp Channel Partner').getRecordTypeId();                   
            cp.RecordTypeId = TempCPRecordTypeId;
            insert cp;
            
            lead l = new lead();
            l.RW_Broker__c = cp.Id;
            l.LeadSource = 'Temp Channel Partner';
            l.IsActive__c = true;
            l.Proposed_Visit_Date__c = system.today();
            l.RW_Mobile_No__c = '1122124443';
            l.LastName = 'Testttlast';
            l.RW_Project__c = objpr.Id;
            insert l;
            
            
            
            Account a = TestDataFactory.createPATemplate('WC Account', 'wc@stetig.in.com','9098777',false);
            a.Channel_Partner__c = cp.id;
            update a;
            Account cpaccount = [Select Id,Name,Channel_Partner__c from Account where Channel_Partner__c =: cp.Id];            
              
            
            OTP__c otp = new OTP__c();
            otp.Generated_OTP__c = '4522';
            otp.Account__c = cpaccount.Id;
            otp.Project__c = objpr.id;
            otp.Lead__c = l.Id;
            //otp.OTP_Expired__c = true;
            //insert otp;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
            RestContext.request = req;
RestContext.response = res;


        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/cpAddLead/updateLeadSiteVisit';
        req.addParameter('cpId', cp.Id);
            
            
         String requestBody = JSON.serialize(new Map<String, Object>{
            'recordId' => l.Id,
            'proposedVisitDate' => String.valueof(system.today())
        });

        req.requestBody = Blob.valueOf(requestBody);
        
            Test.startTest();
            Lockated_CPGetMyLeads.updateLeadSiteVisit();
            Test.stopTest();               
    }
    
}
    
    @IsTest
    static void testDoPost_CP2Opp() {
        
        // --- 1. Setup Test Data ---
                    
            Broker__c cp = new Broker__c();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            
            // Required Lookup/Configuration Records
            // Insert metadata record to prevent SOQL error in start() method, even if we rely on default query
            // The SOQL_Query__c field is left blank to force the batch to use the default query path.
            // Note: Since Batch_Query_Config__mdt is a Custom Metadata Type, we cannot use DML,
            // so we rely on the test execution environment handling the query correctly if the record is set up.
            // For simplicity and to avoid complex setup, we assume a test config record exists or the query gracefully proceeds.
            // If the metadata query is enforced and this fails, a mock or proper setup is needed.
            // For now, we rely on the default query being executed.
            
            Opportunity objcustomer;
            Opportunity objcustomer1;
            Opportunity objcustomer2;
            Booking__c objBooking;
            Project_Unit__c objPUU;
            Project_Unit__c objPUU1;
            Project_Unit_Type__c objPUT;
            
            Project_Location__c pl = new Project_Location__c();
            pl.Name = 'Mumbai';
            pl.Approver_L1__c = userinfo.getUserId();
            pl.Approver_L2__c = userinfo.getUserId();
            pl.Location__c = 'Mumbai';
            insert pl;
            
			Legal_Entity__c le = new Legal_Entity__c();
            le.RDS_Company_Code__c = '1000';
            le.Name = 'Test Company';
            le.RDS_Company_Name__c = 'Testeee';
            insert le; 
            
            Project__c objpr = new Project__c();
            objpr.RW_Project_Code__c = 'T31';
            objpr.Name = 'Runwal Bliss';
            objpr.RDS_Short_Name__c = 'T';
            objpr.Start_Date__c = System.today().addDays(-5);
            objpr.RDS_Interest_Rate__c = 12;
            objpr.Project_Location__c = pl.id;
            objpr.RDS_Company_Code__c = le.Id;
            insert objpr;
            

            cp.Name = 'Test CP';
            cp.RW_Email__c = 'teststetig43646@stetig.in';
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
            cp.RW_Mobile_No__c = '1234567890';
            cp.NAME_FIRST__c = 'tets';
            cp.NAME_MIDDLE__c = 'cp';
            cp.NAME_LAST__c = 'test';
            cp.TITLE__c = 'Mr.';
            cp.Account_Number__c = '465446';
            cp.Cheque_DD_Favouring_Name__c = 'test cp';
            cp.IFSC_Code__c = 'BHSHVD';
            cp.Is_NRI_CP__c = false;
            cp.RW_Is_GST_Applicable__c = true;
            cp.Channel_Partner_From_CP_Portal__c =true;
            Id TempCPRecordTypeId = Schema.SObjectType.Broker__c.getRecordTypeInfosByName().get('Temp Channel Partner').getRecordTypeId();                   
            cp.RecordTypeId = TempCPRecordTypeId;
            insert cp;
             
            Account a = TestDataFactory.createPATemplate('WC Account', 'wc@stetig.in.com','9098777',false);
            a.Channel_Partner__c = cp.id;
            update a;
            Account cpaccount = [Select Id,Name,Channel_Partner__c from Account where Channel_Partner__c =: cp.Id];            
              
                       
            objcustomer= new Opportunity();
            objcustomer.RW_Project__c=objpr.id;
            objcustomer.name='Test 1';
            objcustomer.StageName='Site Visit';
            //objcustomer.RW_Project_Unit__c=objPUU1.id;  
            objcustomer.CloseDate=system.today();
            objcustomer.Status__c ='Active';
            objCustomer.AccountId = a.Id;
            objcustomer.Sales_Manager__c = 'SM2@g.com';
            objcustomer.RW_Type_of_Client__c = 'Local';
            objcustomer.Channel_Partner_Account__c = cpaccount.Id;
            objcustomer.RW_Walkin_Channel_Partner__c = cp.Id;
            objcustomer.Walkin_Source__c = 'Temp Channel Partner';
            insert objcustomer;
            objcustomer2= new Opportunity();
            objcustomer2.RW_Project__c=objpr.id;
            objcustomer2.name='Test 1';
            objcustomer2.StageName='Qualification';
            //objcustomer2.RW_Project_Unit__c=objPUU1.id;  
            objcustomer2.CloseDate=system.today();
            objcustomer2.Status__c ='Active';
            objcustomer2.AccountId = a.Id;
            objcustomer2.RW_Type_of_Client__c = 'NRI';
            objcustomer2.Channel_Partner_Account__c = cpaccount.Id;
            objcustomer2.RW_Walkin_Channel_Partner__c =  cp.Id;
            objcustomer2.Walkin_Source__c = 'Temp Channel Partner';
            //objcustomer2.Duplicate_Project_Unit_Request__c = false;
            //objcustomer2.Release_Unit__c = false;
            insert objcustomer2;
            
           
            OTP__c otp = new OTP__c();
            otp.Generated_OTP__c = '4522';
            otp.Account__c = cpaccount.Id;
            otp.Project__c = objpr.id;
            //otp.Lead__c = l.Id;
            insert otp;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
            RestContext.request = req;
RestContext.response = res;


        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/cpAddLead/updateLeadSiteVisit';
        req.addParameter('cpId', cp.Id);
            
            
         String requestBody = JSON.serialize(new Map<String, Object>{
            'recordId' => objcustomer2.Id,
            'proposedVisitDate' => String.valueof(system.today())
        });

        req.requestBody = Blob.valueOf(requestBody);
        
            Test.startTest();
            Lockated_CPGetMyLeads.updateLeadSiteVisit();
            Test.stopTest();               
    }
    
}
}