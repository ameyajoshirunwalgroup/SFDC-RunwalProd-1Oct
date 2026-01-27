@isTest
public class Lockated_CPAuthTest {    
    @IsTest
    static void testDoGet_WithCpId_Permanent() {
        
        Id cpRtId = Schema.SObjectType.Broker__c
            .getRecordTypeInfosByName()
            .get('Channel Partner')
            .getRecordTypeId();
        
        // 2️⃣ Create Broker
        Broker__c cp = new Broker__c();
        cp.Name = 'Test CP';
        cp.RecordTypeId = cpRtId;
        cp.RW_Email__c = 'teststetig@stetig.in';
        cp.Individual_CP__c = true;
        cp.RW_CreateFromIRIS__c = true;
        cp.RW_IRIS_Sync__c = true;
        cp.Place_of_Supply__c = 'Maharashtra';
        cp.Channel_Partner_From_CP_Portal__c = true;
        cp.Project__c = 'Runwal Bliss';
        cp.Experience__c = '0-1 yrs';
        cp.Team_Size__c = '30';
        cp.NAME_FIRST__c = 'Test 1';
        cp.NAME_MIDDLE__c = 'Test 2';
        cp.NAME_LAST__c = 'Test 3';
        cp.RERA_Valid_till__c = system.today()+199;
        cp.Approver_L1__c = userinfo.getUserId();
        cp.Approver_L2__c = userinfo.getUserId();
        cp.Registration_Complete__c = true;
        cp.RW_Mobile_No__c = '1234567890';
        cp.Broker_Type__c = 'Individual';
        cp.Broker_Pan_No__c = 'ADRPI3525F';
        cp.RW_RERA_Registration_Number__c = '123256789012';
        cp.RW_Mobile_No__c = '1234567890';
        cp.Approval_Status_Update__c = 'Approval Pending';
        cp.Sourcing_Manager__c = UserInfo.getUserId();
        cp.Latest_RERA_Upload_Status__c = 'Approved';
        cp.RERA_Valid_till__c = system.today()+199;
        insert cp;
            
         Project__c  objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        insert objpr;
        
        List<Tower__c> t = TestDataFactory.createTowers(1, objpr.Id);
        
        Project_Location__c pl = new Project_Location__c();
        pl.Name = 'Mumbai';
        pl.Approver_L1__c = userinfo.getUserId();
        pl.Approver_L2__c = userinfo.getUserId();
        pl.Location__c = 'Mumbai';
        insert pl;
        	
        Project_Unit_Type__c objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.id;
        insert objPUT;
        
        Project_Unit__c objPUU = new Project_Unit__c();
        objPUU.Project_Unit_Type__c = objPUT.id;
        objPUU.Name = 'TestUnit';
        objPUU.RW_Project__c = objpr.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c = '9';
        objPUU.RW_Unit_Status__c = 'Available';
        
        Project_Unit__c objPUU1 = new Project_Unit__c();
        objPUU1.Project_Unit_Type__c = objPUT.id;
        objPUU1.Name = 'TestUnit1';
        objPUU1.RW_Project__c = objpr.Id;
        objPUU1.RW_Param1__c = '5';
        objPUU1.UnitNo__c = '10';
        objPUU1.RW_Unit_Status__c = 'Available';
        
        insert new List<Project_Unit__c>{ objPUU, objPUU1 };
        Account ac = new Account();
        ac.Name = cp.Company_Name_As_per_RERA__c;
        ac.CP_Email__c = cp.RW_Email__c;
        ac.Mobile_No__c = cp.RW_Mobile_No__c;
        ac.Channel_Partner__c = cp.id;
        ac.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
        ac.Name = 'Test Acc';
        insert ac;
        
        Account cpaccount = [SELECT Id, Name, Channel_Partner__c FROM Account WHERE Channel_Partner__c = :cp.Id];
        
        Opportunity objcustomer = new Opportunity();
        objcustomer.RW_Project__c = objpr.id;
        objcustomer.Name = 'Test 1';
        objcustomer.StageName = 'Qualification';
        objcustomer.CloseDate = system.today();
        objcustomer.Status__c = 'Active';
        objCustomer.AccountId = ac.Id;
        objcustomer.Sales_Manager__c = 'SM2@g.com';
        objcustomer.RW_Type_of_Client__c = 'Local';
        objcustomer.Channel_Partner_Account__c = cpaccount.Id;
        objcustomer.RW_Walkin_Channel_Partner__c = cp.Id;
        objcustomer.Walkin_Source__c = 'Channel Partner';
        
        Opportunity objcustomer1 = new Opportunity();
        objcustomer1.RW_Project__c = objpr.id;
        objcustomer1.Name = 'Test 1';
        objcustomer1.StageName = 'Qualification';
        objcustomer1.CloseDate = system.today();
        objcustomer1.Status__c = 'Active';
        objcustomer1.AccountId = ac.Id;
        objcustomer1.RW_Type_of_Client__c = 'Local';
        objcustomer1.Channel_Partner_Account__c = cpaccount.Id;
        objcustomer1.RW_Walkin_Channel_Partner__c = cp.Id;
        objcustomer1.Walkin_Source__c = 'Channel Partner';
        
        insert new List<Opportunity>{ objcustomer, objcustomer1 };
            
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
        q.Token_Amount__c = 110000;
        q.Agreement_Value_for_brokers__c = 10000000;
        
        Quotation__c q2 = new Quotation__c();
        q2.Name = 'Q020202';
        q2.Quote_Status__c = 'Approval Pending';
        q2.Prepared_Date__c = System.today();
        q2.Project__c = objpr.Id;
        q2.Project_Unit__c = objPUU1.Id;
        q2.FloorNo__c = 11;
        q2.Opportunity__c = objcustomer1.Id;
        q2.Appartment_Configuration__c = '1 BHK';
        q2.Carpet_Area_Sq_Ft__c = 1200;
        q2.Token_Amount__c = 110000;
        q2.Agreement_Value_for_brokers__c = 10000000;
        
        insert new List<Quotation__c>{ q, q2 };
            
            Receipt__c r1 = new Receipt__c();
        r1.Cheque_DD_Amount_Rs__c = 6000000;
        r1.Cheque_DD__c = '908888';
        r1.Project__c = objpr.Id;
        r1.Project_Unit__c = objPUU.Id;
        r1.Opportunity__c = objcustomer.Id;
        r1.Approval_Status__c = 'Approved';
        r1.Total_Amount__c = 6000000;
        r1.Currency__c = 'Indian Rupee';
        
        Receipt__c r2 = new Receipt__c();
        r2.Cheque_DD_Amount_Rs__c = 8400;
        r2.Cheque_DD__c = '9088881';
        r2.Project__c = objpr.Id;
        r2.Project_Unit__c = objPUU.Id;
        r2.Opportunity__c = objcustomer.Id;
        r2.Approval_Status__c = 'Approved';
        r2.Total_Amount__c = 8400;
        r2.Currency__c = 'Indian Rupee';
        
        insert new List<Receipt__c>{ r1, r2 };
            
            List<Brokerage_Scheme__c> schemes = new List<Brokerage_Scheme__c>();
        Brokerage_Scheme__c bscheme = new Brokerage_Scheme__c();
        bscheme.Type__c = 'Local';
        bscheme.Approval_Status__c = 'Approved by Level 2';
        //bscheme.Base_Brokerage_for_OS_NRI__c = 3;
        bscheme.Slab_Type__c = 'Count';
        bscheme.Start_Date__c = system.today();
        bscheme.End_Date__c = system.today()+2;
        //bscheme.Project_Location__c = pl.Id;
        bscheme.Base_Brokerage_for_Local_Bookings__c = 1;
        schemes.add(bscheme);
        
        Brokerage_Scheme__c bscheme2 = new Brokerage_Scheme__c();
        bscheme2.Type__c = 'NRI';
        bscheme2.Approval_Status__c = 'Approved by Level 2';
        bscheme2.Base_Brokerage_for_OS_NRI__c = 2;
        bscheme2.Slab_Type__c = 'Count';
        bscheme2.Start_Date__c = Date.newInstance(2023, 4, 1);
        bscheme2.End_Date__c = system.today()+2;
        schemes.add(bscheme2);
        
         Brokerage_Scheme__c bscheme3 = new Brokerage_Scheme__c();
        bscheme3.Type__c = 'Both';
        bscheme3.Approval_Status__c = 'Approved by Level 2';
        bscheme3.Base_Brokerage_for_OS_NRI__c = 2;
        bscheme3.Base_Brokerage_for_Local_Bookings__c = 2;
        bscheme3.Slab_Type__c = 'Count';
        bscheme3.Start_Date__c = Date.newInstance(2023, 4, 1);
        bscheme3.End_Date__c = system.today()+2;
        schemes.add(bscheme3);
        insert schemes;
           
            // --- Combined Booking Inserts ---
            Booking__c b = new Booking__c();
        b.Customer__c = objcustomer1.Id;
        b.Project__c = objpr.Id;
        b.Tower__c = t[0].Id;
        b.Opportunity__c = objcustomer1.Id;
        b.Unit_No__c = objPUU1.id;
        b.Quotation__c = q2.Id;
        b.Receipts__c = r2.Id;
        b.Booking_Date__c = system.today()-15;
        b.Account__c = cpaccount.Id;
        b.Type_of_Client__c = 'NRI';
        b.Status__c = 'Booking Confirmed';
        b.RW_Registration_Done__c = 'Yes';
        b.BrokerIId__c = cp.Id;
        b.Exclude_From_Brokerage_Batch__c = false;
        b.Source_of_Booking__c = 'Channel Partner';
        b.RW_Registration_Date__c = Date.today();
        b.RW_Total_Receipt_Amount_Received__c = 5000000;
        b.Brokerage_Scheme__c = bscheme.Id;
        b.Allotment_Premium__c = 50000000;
        b.Custom_Base_Brokerage__c = 1;
        b.Checklist_Approved__c = true;
        

        
        Booking__c b2 = b.clone(false, true, false, false);
        Booking__c b3 = b.clone(false, true, false, false);
        
        List<Booking__c> bookingsToInsert = new List<Booking__c>{ b, b2, b3 };
       	insert bookingsToInsert;
        
         Profile p = [SELECT Id FROM Profile WHERE Name='Partner Community User' LIMIT 1];
        Account objAcc = new Account();
        objAcc.Name = 'Test';
        objAcc.Channel_Partner__c = cp.Id;
        insert objAcc;
        
        Contact c = new Contact(
            AccountId = objAcc.Id,
            LastName = 'Test Contact'
        );
        insert c;

        User u = new User(
            FirstName = 'Test',
            LastName  = 'User',
            Alias     = 'tuser',
            Email     = 'testuser@example.com',
            Username  = 'testuser' + System.currentTimeMillis() + '@example.com',
            ProfileId = p.Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey   = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ContactId = c.Id
        );
        insert u;
         Id CP_MEET_RECORDTYPE_ID =Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('CP_Meets').getRecordTypeId();
        
        Campaign futureCampaign = new Campaign(
            Name = 'Future CP Meet',
            Type__c = System.Label.CPMeetsCampaign,
            StartDate = Date.today(),
            EndDate   = Date.today().addDays(1),
            Tollfree_Number__c  = '9389289290',
            Event_Date_Time__c = DateTime.now().addDays(1),
            RecordtypeId = CP_MEET_RECORDTYPE_ID
        );
        insert futureCampaign;

        CampaignMember cm = new CampaignMember(
            CampaignId = futureCampaign.Id,
            ContactId  = u.ContactId,
            RSVP__c    = true,
            Status     = 'Sent',
            Additional_Attendees__c = 2,
            Total_Attendees__c = 3,
            Is_Attended__c = false
        );
        insert cm;
        
        
        Lead objLead = new Lead();
        objLead.LastName = 'test';
        objLead.RW_Broker__c = cp.id;
        objLead.Status = 'Not Sure';
        objLead.Email = 'test@gmail.com';
        objLead.Rating = 'Hot';
        objLead.MobilePhone = '1212121212';
        objLead.RW_Mobile_No__c = '1212121212';
        //objLead.LeadSource = 'Corporate Company';
        objLead.LeadSource = 'Channel Partner';
        objLead.Remark__c = 'test remark';
        objLead.RW_Project__c = objpr.id; 
        objLead.Country__c = 'India';
        objLead.State__c = 'Odisha';
        objLead.City__c = 'Bhubaneshwar';
        objLead.RW_Budget__c = '< 1Cr';
        objLead.RW_Configuration__c = '1.5 BHK';
        objLead.RW_Location__c = 'MANGLAUR';
        objLead.RW_Time_line__c = 'Ready Possession';
        objLead.RW_Agent_ID__c = u.Email;
        objLead.Retention_RM_Name__c = u.Id;
        objLead.Retention_Closing_Head_Name__c = u.Id;
        objLead.Retention_Presales_User__c = u.Id;
        objLead.Retention_Sales_Manager__c = u.Id;
        objLead.Retention_Customer_SAP_Code__c = '12345';
        objLead.LeadSource = 'Channel Partner';
        list<Lead> llist = new list<Lead>();
        llist.add(objLead);
        
        Lead ld = new Lead();
        ld.LastName = 'Test';
        ld.LeadSource = 'Channel Partner';
        ld.Email = 'test@mail.com';
        ld.RW_Mobile_No__c = '1254698547';
        ld.RW_Project__c = objpr.Id;
        ld.Retention_RM_Name__c = u.Id;
        ld.Retention_Closing_Head_Name__c = u.Id;
        ld.RW_Broker__c = cp.id;
        ld.Retention_Presales_User__c = u.Id;
        ld.Retention_Sales_Manager__c = u.Id;
        ld.Retention_Customer_SAP_Code__c = '12345';
        ld.IsConverted = true;
        ld.ConvertedAccountId = ac.Id;
        llist.add(ld);
        insert llist;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'GET';
        req.requestURI = '/services/apexrest/cpGetDetails';
        req.addParameter('id', cp.Id);
        
        RestContext.request = req;
        RestContext.response = res;
        
        // 4️⃣ Call REST method
        Test.startTest();
        Lockated_CPAuth.doGet();
        Test.stopTest();
        
    }
    
    @IsTest
    static void testDoGet_WithCpId_Temporary() {
        
        Id cpRtId = Schema.SObjectType.Broker__c
            .getRecordTypeInfosByName()
            .get('Temp Channel Partner')
            .getRecordTypeId();
        
        Contact contact = new Contact();
        contact.FirstName = 'Test' + DateTime.now();
        contact.LastName = 'Test Last';
        contact.phone = '1277772666';
        insert contact;
        
        // 2️⃣ Create Broker
        Broker__c cp = new Broker__c();
        cp.Name = 'Test CP';
        cp.RecordTypeId = cpRtId;
        cp.NAME_FIRST__c = 'Test First';
        cp.NAME_MIDDLE__c = 'Test Middle';
        cp.NAME_LAST__c = 'Test Last';
        cp.RW_Email__c = 'temporary@gmail.com';
        cp.Broker_Pan_No__c = 'ASZXC6767Y';
        cp.Company_Name__c = 'Testt';
        cp.RW_Mobile_No__c = '4545434323';
        insert cp;
        
        // 3️⃣ Prepare REST request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'GET';
        req.requestURI = '/services/apexrest/cpGetDetails';
        req.addParameter('id', cp.Id);
        
        RestContext.request = req;
        RestContext.response = res;
        
        // 4️⃣ Call REST method
        Test.startTest();
        Lockated_CPAuth.doGet();
        Test.stopTest();
        
    }
    
    @IsTest
    static void testDoGet_NoParams_Error() {
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'GET';
        req.requestURI = '/services/apexrest/cpGetDetails';
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        Lockated_CPAuth.doGet();
        Test.stopTest();
        
    }
    
    
    @IsTest
    static void testDoPost_CP() {
		
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/cpCreate';
        req.addParameter('cptype', 'CP');
		
        Lockated_CPAuth.cpRegistrationWrapper w = new Lockated_CPAuth.cpRegistrationWrapper();
        
        Project__c  objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        insert objpr;
        
        w.partnerType = 'Company';
        w.projectId = objpr.Id;
        w.fullName = 'Test';
        w.email = 'test78394@gmail.com';
        w.phone = '2893888777';
        w.panNo = 'AVBVG6765T';
        w.countryCode = '+91';
        w.companyName = 'TEST COMPANY';
        w.reraRegistrationNumber = 'A51700004935';
        w.reraValidTill = String.valueof(system.today()+199);
        
        w.isNri = false;
        w.isGstApplicable = true;
        w.gstNumber = '24GHSUU5478F2Z89';
        w.experience = '0-1 yrs';
        w.operationPlace = 'Maharashtra';
        w.teamSize = '30';
        
        // ===== ADDRESS =====
        w.address = new Lockated_CPAuth.Address();
        w.address.houseFlatCompany = 'Test 1';
        w.address.streetAddress1 = 'Test 1';
        w.address.stateRegion = 'Maharashtra';
        w.address.zipPinCode = '177726';
        w.address.country = 'India';
        
        // ===== BANK DETAILS =====
        w.bankDetails = new Lockated_CPAuth.BankDetails();
        w.bankDetails.chequeDdFavouringName = 'Test';
        w.bankDetails.bankName = 'Bank of Baroda';
        w.bankDetails.branchCode = '6378378239';
        w.bankDetails.bankAccountNumber = '6378378239';
        w.bankDetails.bankAccountIfscCode = '26789238920';
        w.bankDetails.branchName = 'Test';
        
        // ===== DOCUMENTS (OPTIONAL) =====
        w.documents = new List<Lockated_CPAuth.Documents>();
        Lockated_CPAuth.Documents doc = new Lockated_CPAuth.Documents();
        doc.filetype = 'PAN';
        doc.filename = 'GGBGH76798I';
        doc.attachment = 'Test';
        w.documents.add(doc);
        
        //w.recordId = b.Id;
        String jsonBody = JSON.serialize(w);
        req.requestBody = Blob.valueOf(jsonBody);

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        Lockated_CPAuth.doPost();
        Test.stopTest();

    }

    @IsTest
    static void testDoPost_TempCP() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/cpCreate';
        req.addParameter('cptype', 'TempCP');
        Profile p = [SELECT Id FROM Profile WHERE Name='Partner Community User' LIMIT 1];
        Account objAcc = new Account();
        objAcc.Name = 'Test';
        insert objAcc;
        
        Contact c = new Contact(
            AccountId = objAcc.Id,
            LastName = 'Test Contact'
        );
        insert c;
        req.requestBody = Blob.valueOf(
            '{"name":"Temp CP","email":"tempcp@test.com","mobile":"8888888888"}'
        );

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        Lockated_CPAuth.doPost();
        Test.stopTest();

    }

    @IsTest
    static void testDoPost_InvalidCPType() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/cpCreate';
        req.addParameter('cptype', 'InvalidType');

        req.requestBody = Blob.valueOf('{}');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        Lockated_CPAuth.doPost();
        Test.stopTest();

    }
}