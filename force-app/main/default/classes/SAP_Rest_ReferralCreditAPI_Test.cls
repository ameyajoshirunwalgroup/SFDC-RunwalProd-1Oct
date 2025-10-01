@isTest
public class SAP_Rest_ReferralCreditAPI_Test {	
    
    private class SAPReferralMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{"LIFNR":"12345","DOCUMENT_NO":"DOC123","DOCUMENT_DT":"2025-09-24","STATUS":"Success"}');
            
            return res;
        }
    }
    
    @isTest
    static void test_sendReferrallist_success() {
       
        
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
        
        Booking__c b = new Booking__c();
        b.Customer__c = o.Id;
        b.Project__c = p.Id;
        b.Opportunity__c = o.Id;
        b.Unit_No__c = objPUU.id;
        b.Quotation__c = q.Id;
        b.Booking_Date__c = Date.today();
        b.Account__c = acc.Id;
        b.Type_of_Client__c = 'Local';
        b.Status__c = 'Booking Confirmed';
        b.RW_Registration_Done__c = 'No';
        b.Exclude_From_Brokerage_Batch__c = false;
        b.Source_of_Booking__c = 'Direct';
        //b.X5_Received__c = true;
        b.RW_Total_Receipt_Amount_Received__c = 600000;
        b.Allotment_Premium__c = 10000000;
        //b.RW_Registration_Status__c = 'Registration Completed';
        b.RW_Registration_Type__c = 'Offline Registration';
        b.RW_Expected_Registration_Date__c = system.today();
        b.RW_Registration_Done__c = 'No';
        insert b;
        
        RW_Demand__c dmd2 = new RW_Demand__c();
        dmd2.Booking__c =b.id;
        dmd2.name= '890890';
        dmd2.RW_Billing_Document_Number__c = '890890';
        dmd2.RW_Customer_Number__c = '12345678';
        insert dmd2;
        
        RW_Demand_Item__c dmid2= new RW_Demand_Item__c();
        dmid2.RW_Demand_Item_Amount__c =1000000;
        dmid2.RW_Demand__c = dmd2.id;
        dmid2.RW_GST_Amount__c = 5000;
        dmid2.RW_Legacy_Amount_Paid__c = 5000;
        dmid2.RW_Legacy_Demand__c = true;
        dmid2.Total_Demand_Item_Amount_Paid__c = 1000000;
        insert dmid2;
        
        RW_Demand_Item__c dmid1= new RW_Demand_Item__c();
        dmid1.RW_Demand_Item_Amount__c =1000000;
        dmid1.RW_Demand__c = dmd2.id;
        dmid1.RW_GST_Amount__c = 5000;
        dmid1.RW_Legacy_Amount_Paid__c = 5000;
        dmid1.RW_Legacy_Demand__c = true;
        dmid1.Total_Demand_Item_Amount_Paid__c = 1000000;
        insert dmid1;
        update b;
        
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
        
        List<Applicant_Details__c> apps = new List<Applicant_Details__c>();
        Applicant_Details__c apt1 = new Applicant_Details__c();
        apt1.Name = 'Applicant 1';
        apt1.Permanent_Address__c = 'test address';
        apt1.Opportunity__c = o.Id;
        apt1.Applicant_Number__c = 'Primary Applicant';
        apt1.Subtype_Of_Applicant__c = 'Indian National';
        apt1.Type_Of_Applicant__c= 'Individual Buyer';
        apt1.Booking__c = b1.Id;
        apt1.DOB__c = Date.today();
        apt1.Office_Address_Line_1__c = 'Office Address Line 1';
        apt1.Mobile_Number__c = '1234567890';
        apt1.Email_Address__c = 'test@test.com';
        apt1.PancardNo__c = 'ABC123456';
        apt1.Address_Proof__c = true;
        apt1.Address_Proof_Document__c = 'Passport';
        //apt1.PancardNo__c = 'abc213456';
        //insert apt1;
        apps.add(apt1);
        
        Applicant_Details__c apt2 = new Applicant_Details__c();
        apt2.Name = 'Applicant 2';
        apt2.Permanent_Address__c = 'test address1';
        apt2.Opportunity__c = o.Id;
        apt2.Applicant_Number__c = 'Second Applicant';
        apt2.Subtype_Of_Applicant__c = 'Indian National';
        apt2.Type_Of_Applicant__c= 'Individual Buyer';
        apt2.Booking__c = b1.Id;
        apt2.DOB__c = Date.today();
        apt2.Office_Address_Line_1__c = 'Office Address Line 2';
        apt2.Mobile_Number__c = '1234567899';
        apt2.Email_Address__c = 'test1@test1.com';
        apt2.Address_Proof__c = true;
        apt2.Address_Proof_Document__c = 'Passport';
        apt2.gender__c = 'Female';
        apt2.Designation_picklist__c = 'Accounting';
        apt2.Occupation__c = 'Admin';
        apt2.PancardNo__c = 'ABC123456';
        //insert apt2;
        apps.add(apt2);
        
        Applicant_Details__c apt3 = new Applicant_Details__c();
        apt3.Name = 'Applicant 3';
        apt3.Permanent_Address__c = 'test address1';
        apt3.Opportunity__c = o.Id;
        apt3.Applicant_Number__c = 'Third Applicant';
        apt3.Subtype_Of_Applicant__c = 'Indian National';
        apt3.Type_Of_Applicant__c= 'Individual Buyer';
        apt3.Booking__c = b1.Id;
        apt3.DOB__c = Date.today();
        apt3.Office_Address_Line_1__c = 'Office Address Line 2';
        apt3.Mobile_Number__c = '1234567899';
        apt3.Email_Address__c = 'test1@test1.com';
        apt3.Address_Proof__c = true;
        apt3.Address_Proof_Document__c = 'Passport';
        apt3.gender__c = 'Male';
        apt3.Designation_picklist__c = 'Accounting';
        apt3.Occupation__c = 'Admin';
        apt3.PancardNo__c = 'ABC123456';
        //insert apt3;
        apps.add(apt3);
        
        Applicant_Details__c apt4 = new Applicant_Details__c();
        apt4.Name = 'Applicant 4';
        apt4.Permanent_Address__c = 'test address1';
        apt4.Opportunity__c = o.Id;
        apt4.Applicant_Number__c = 'Fourth Applicant';
        apt4.Subtype_Of_Applicant__c = 'Indian National';
        apt4.Type_Of_Applicant__c= 'Individual Buyer';
        apt4.Booking__c = b1.Id;
        apt4.DOB__c = Date.today();
        apt4.Office_Address_Line_1__c = 'Office Address Line 2';
        apt4.Mobile_Number__c = '1234567899';
        apt4.Email_Address__c = 'test1@test1.com';
        apt4.Address_Proof__c = true;
        apt4.Address_Proof_Document__c = 'Passport';
        apt4.PancardNo__c = 'ABC123456';
        //insert apt4;
        apps.add(apt4);
        
        Applicant_Details__c apt5 = new Applicant_Details__c();
        apt5.Name = 'Applicant 5';
        apt5.Permanent_Address__c = 'test address1';
        apt5.Opportunity__c = o.Id;
        apt5.Applicant_Number__c = 'Fifth Applicant';
        apt5.Subtype_Of_Applicant__c = 'Indian National';
        apt5.Type_Of_Applicant__c= 'Individual Buyer';
        apt5.Booking__c = b1.Id;
        apt5.DOB__c = Date.today();
        apt5.Office_Address_Line_1__c = 'Office Address Line 2';
        apt5.Mobile_Number__c = '1234567899';
        apt5.Email_Address__c = 'test1@test1.com';
        apt5.Address_Proof__c = true;
        apt5.Address_Proof_Document__c = 'Passport';
        apt5.PancardNo__c = 'ABC123456';
        //insert apt5;
        apps.add(apt5);
        insert apps;
        
        Opportunity o1 = new Opportunity();
        o1.id = o.id;
        o1.Booking__c = b1.Id;
        update o1;
        
        RW_Demand__c dmd21 = new RW_Demand__c();
        dmd21.Booking__c =b1.id;
        dmd21.name= '890890';
        dmd21.RW_Billing_Document_Number__c = '890890';
        dmd21.RW_Customer_Number__c = '12345678';
        insert dmd21;
        
        RW_Demand_Item__c dmid21= new RW_Demand_Item__c();
        dmid21.RW_Demand_Item_Amount__c =1200000;
        dmid21.RW_Demand__c = dmd21.id;
        dmid21.RW_GST_Amount__c = 5000;
        dmid21.RW_Legacy_Amount_Paid__c = 5000;
        dmid21.RW_Legacy_Demand__c = true;
        dmid21.Total_Demand_Item_Amount_Paid__c = 1200000;
        insert dmid21;
        
        RW_Demand_Item__c dmid11 = new RW_Demand_Item__c();
        dmid11.RW_Demand_Item_Amount__c =1200000;
        dmid11.RW_Demand__c = dmd21.id;
        dmid11.RW_GST_Amount__c = 5000;
        dmid11.RW_Legacy_Amount_Paid__c = 5000;
        dmid11.RW_Legacy_Demand__c = true;
        dmid11.Total_Demand_Item_Amount_Paid__c = 1200000;
        insert dmid11;
        update b1;
        
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
        r.Vendor_Code__c = '36734824';
        r.SAP_Document_Date__c = system.today();
        r.SAP_Document_No__c = '63789389';
        r.Date_Error_Fixed__c = true;
        r.SAP_Posting_Date__c = system.today();
        update r;
        
        
        Test.setMock(HttpCalloutMock.class, new SAPReferralMock());
        
        
        Test.startTest();
        SAP_Rest_ReferralCreditAPI.sendReferrallist(new List<Id>{r.Id});
        SAP_Rest_ReferralCreditAPI req = new SAP_Rest_ReferralCreditAPI();
        req.LIFNR = '12345';
        req.ref_to_cust = 'CUST001';
        req.PARTN_CAT = 'ZM';
        req.KTOKK = 'ZC01';
        req.TITLE = 'Mr';
        req.NAME_FIRST = 'John';
        req.NAME_MIDDLE = 'middle';
        req.NAME_LAST = 'Doe';
        req.NAME_ORG1 = 'Test';
        req.STREET = 'one';
        req.STR_SUPPL1 = 'tesyt1';
        req.STR_SUPPL2 = 'tesyt2';
        req.STR_SUPPL3 = 'tesyt3';
        req.CITY = 'Mumbai';
        req.COUNTRY = 'IN';
        req.REGION = 'test';
        req.SMTP_ADDR = 'test';
        req.MOB_NUMBER = 'test';
        req.SORT1 = 'test';
        req.CONTACT_PERSON = 'tst';
        req.PAN = 'ABCDE1234F';
        req.ref_text = 'Referral Test';
        String mockJson = '{"LIFNR":"12345","DOCUMENT_NO":"DOC123","DOCUMENT_DT":"2025-09-24","status":"Success"}';
        ReferralCreditCreationParser parsed = ReferralCreditCreationParser.parse(mockJson);
        
        SAPReferralCreditAPICallOut.sendReferrallist(b1.id); 
        
        Test.stopTest(); // future + callout runs here
        

    }
    
    @isTest
    static void coverBAPIRET2() {
        SAPReferralCreditAPI.BAPIRET2 bapi = new SAPReferralCreditAPI.BAPIRET2();
        bapi.TYPE_x     = 'E';
        bapi.ID         = 'MSG_ID';
        bapi.NUMBER_x   = '100';
        bapi.MESSAGE    = 'Test SAP message';
        bapi.LOG_NO     = 'L001';
        bapi.LOG_MSG_NO = '10';
        bapi.MESSAGE_V1 = 'Param1';
        bapi.MESSAGE_V2 = 'Param2';
        bapi.MESSAGE_V3 = 'Param3';
        bapi.MESSAGE_V4 = 'Param4';
        bapi.PARAMETER  = 'Booking';
        bapi.ROW        = 1;
        bapi.FIELD      = 'FieldName';
        bapi.SYSTEM_x   = 'SAP';
        
    }


    public class ReferralCreditRequest {
        public String LIFNR;
        public String ref_to_cust;
        public String PARTN_CAT;
        public String KTOKK;
        public String TITLE;
        public String NAME_FIRST;
        public String NAME_LAST;
        public String CITY;
        public String COUNTRY;
        public String PAN;
        public String ref_text;
    }
    
    
    // Optional: Test Failure Case
    private class SAPReferralFailureMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('{"STATUS":"Failure","ERR_TEXT":"Invalid Data"}');
            return res;
        }
    }
    
    @isTest
    static void test_sendReferrallist_failure() {
       
          
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
        
        Booking__c b = new Booking__c();
        b.Customer__c = o.Id;
        b.Project__c = p.Id;
        b.Opportunity__c = o.Id;
        b.Unit_No__c = objPUU.id;
        b.Quotation__c = q.Id;
        b.Booking_Date__c = Date.today();
        b.Account__c = acc.Id;
        b.Type_of_Client__c = 'Local';
        b.Status__c = 'Booking Confirmed';
        b.RW_Registration_Done__c = 'No';
        b.Exclude_From_Brokerage_Batch__c = false;
        b.Source_of_Booking__c = 'Direct';
        //b.X5_Received__c = true;
        b.RW_Total_Receipt_Amount_Received__c = 600000;
        b.Allotment_Premium__c = 10000000;
        //b.RW_Registration_Status__c = 'Registration Completed';
        b.RW_Registration_Type__c = 'Offline Registration';
        b.RW_Expected_Registration_Date__c = system.today();
        b.RW_Registration_Done__c = 'No';
        insert b;
        
        
        
        
        
        RW_Demand__c dmd2 = new RW_Demand__c();
        dmd2.Booking__c =b.id;
        dmd2.name= '890890';
        dmd2.RW_Billing_Document_Number__c = '890890';
        dmd2.RW_Customer_Number__c = '12345678';
        insert dmd2;
        
        RW_Demand_Item__c dmid2= new RW_Demand_Item__c();
        dmid2.RW_Demand_Item_Amount__c =1000000;
        dmid2.RW_Demand__c = dmd2.id;
        dmid2.RW_GST_Amount__c = 5000;
        dmid2.RW_Legacy_Amount_Paid__c = 5000;
        dmid2.RW_Legacy_Demand__c = true;
        dmid2.Total_Demand_Item_Amount_Paid__c = 1000000;
        insert dmid2;
        
        RW_Demand_Item__c dmid1= new RW_Demand_Item__c();
        dmid1.RW_Demand_Item_Amount__c =1000000;
        dmid1.RW_Demand__c = dmd2.id;
        dmid1.RW_GST_Amount__c = 5000;
        dmid1.RW_Legacy_Amount_Paid__c = 5000;
        dmid1.RW_Legacy_Demand__c = true;
        dmid1.Total_Demand_Item_Amount_Paid__c = 1000000;
        insert dmid1;
        update b;
        
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
        
        List<Applicant_Details__c> apps = new List<Applicant_Details__c>();
        Applicant_Details__c apt1 = new Applicant_Details__c();
        apt1.Name = 'Applicant 1';
        apt1.First_Name__c = 'Applicant ';
        apt1.Last_Name__c = '1';
        apt1.Permanent_Address__c = 'test address';
        apt1.Opportunity__c = o.Id;
        apt1.Applicant_Number__c = 'Primary Applicant';
        apt1.Subtype_Of_Applicant__c = 'Indian National';
        apt1.Type_Of_Applicant__c= 'Individual Buyer';
        apt1.Booking__c = b1.Id;
        apt1.DOB__c = Date.today();
        apt1.Office_Address_Line_1__c = 'Office Address Line 1';
        apt1.Mobile_Number__c = '1234567890';
        apt1.Email_Address__c = 'test@test.com';
        apt1.PancardNo__c = 'ABC123456';
        apt1.Address_Proof__c = true;
        apt1.Address_Proof_Document__c = 'Passport';
        //apt1.PancardNo__c = 'abc213456';
        //insert apt1;
        apps.add(apt1);
        
        Applicant_Details__c apt2 = new Applicant_Details__c();
        apt2.Name = 'Applicant 2';
        apt2.Permanent_Address__c = 'test address1';
        apt2.Opportunity__c = o.Id;
        apt2.Applicant_Number__c = 'Second Applicant';
        apt2.Subtype_Of_Applicant__c = 'Indian National';
        apt2.Type_Of_Applicant__c= 'Individual Buyer';
        apt2.Booking__c = b1.Id;
        apt2.DOB__c = Date.today();
        apt2.Office_Address_Line_1__c = 'Office Address Line 2';
        apt2.Mobile_Number__c = '1234567899';
        apt2.Email_Address__c = 'test1@test1.com';
        apt2.Address_Proof__c = true;
        apt2.Address_Proof_Document__c = 'Passport';
        apt2.gender__c = 'Female';
        apt2.Designation_picklist__c = 'Accounting';
        apt2.Occupation__c = 'Admin';
        apt2.PancardNo__c = 'ABC123456';
        //insert apt2;
        apps.add(apt2);
        
        Applicant_Details__c apt3 = new Applicant_Details__c();
        apt3.Name = 'Applicant 3';
        apt3.Permanent_Address__c = 'test address1';
        apt3.Opportunity__c = o.Id;
        apt3.Applicant_Number__c = 'Third Applicant';
        apt3.Subtype_Of_Applicant__c = 'Indian National';
        apt3.Type_Of_Applicant__c= 'Individual Buyer';
        apt3.Booking__c = b1.Id;
        apt3.DOB__c = Date.today();
        apt3.Office_Address_Line_1__c = 'Office Address Line 2';
        apt3.Mobile_Number__c = '1234567899';
        apt3.Email_Address__c = 'test1@test1.com';
        apt3.Address_Proof__c = true;
        apt3.Address_Proof_Document__c = 'Passport';
        apt3.gender__c = 'Male';
        apt3.Designation_picklist__c = 'Accounting';
        apt3.Occupation__c = 'Admin';
        apt3.PancardNo__c = 'ABC123456';
        //insert apt3;
        apps.add(apt3);
        
        Applicant_Details__c apt4 = new Applicant_Details__c();
        apt4.Name = 'Applicant 4';
        apt4.Permanent_Address__c = 'test address1';
        apt4.Opportunity__c = o.Id;
        apt4.Applicant_Number__c = 'Fourth Applicant';
        apt4.Subtype_Of_Applicant__c = 'Indian National';
        apt4.Type_Of_Applicant__c= 'Individual Buyer';
        apt4.Booking__c = b1.Id;
        apt4.DOB__c = Date.today();
        apt4.Office_Address_Line_1__c = 'Office Address Line 2';
        apt4.Mobile_Number__c = '1234567899';
        apt4.Email_Address__c = 'test1@test1.com';
        apt4.Address_Proof__c = true;
        apt4.Address_Proof_Document__c = 'Passport';
        apt4.PancardNo__c = 'ABC123456';
        //insert apt4;
        apps.add(apt4);
        
        Applicant_Details__c apt5 = new Applicant_Details__c();
        apt5.Name = 'Applicant 5';
        apt5.Permanent_Address__c = 'test address1';
        apt5.Opportunity__c = o.Id;
        apt5.Applicant_Number__c = 'Fifth Applicant';
        apt5.Subtype_Of_Applicant__c = 'Indian National';
        apt5.Type_Of_Applicant__c= 'Corporate Buyer';
        apt5.Booking__c = b1.Id;
        apt5.DOB__c = Date.today();
        apt5.Office_Address_Line_1__c = 'Office Address Line 2';
        apt5.Mobile_Number__c = '1234567899';
        apt5.Email_Address__c = 'test1@test1.com';
        apt5.Address_Proof__c = true;
        apt5.Address_Proof_Document__c = 'Passport';
        apt5.PancardNo__c = 'ABC123456';
        //insert apt5;
        apps.add(apt5);
        insert apps;
        
        Opportunity o1 = new Opportunity();
        o1.id = o.id;
        o1.Booking__c = b1.Id;
        update o1;
        
        RW_Demand__c dmd21 = new RW_Demand__c();
        dmd21.Booking__c =b1.id;
        dmd21.name= '890890';
        dmd21.RW_Billing_Document_Number__c = '890890';
        dmd21.RW_Customer_Number__c = '12345678';
        insert dmd21;
        
        RW_Demand_Item__c dmid21= new RW_Demand_Item__c();
        dmid21.RW_Demand_Item_Amount__c =1200000;
        dmid21.RW_Demand__c = dmd21.id;
        dmid21.RW_GST_Amount__c = 5000;
        dmid21.RW_Legacy_Amount_Paid__c = 5000;
        dmid21.RW_Legacy_Demand__c = true;
        dmid21.Total_Demand_Item_Amount_Paid__c = 1200000;
        insert dmid21;
        
        RW_Demand_Item__c dmid11 = new RW_Demand_Item__c();
        dmid11.RW_Demand_Item_Amount__c =1200000;
        dmid11.RW_Demand__c = dmd21.id;
        dmid11.RW_GST_Amount__c = 5000;
        dmid11.RW_Legacy_Amount_Paid__c = 5000;
        dmid11.RW_Legacy_Demand__c = true;
        dmid11.Total_Demand_Item_Amount_Paid__c = 1200000;
        insert dmid11;
        update b1;
        
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
        r.Vendor_Code__c = '36734824';
        r.SAP_Document_Date__c = system.today();
        r.SAP_Document_No__c = '63789389';
                r.Date_Error_Fixed__c = true;
        r.SAP_Posting_Date__c = system.today();
        update r;
        
        
        Test.setMock(HttpCalloutMock.class, new SAPReferralFailureMock());
        
        Test.startTest();
        SAP_Rest_ReferralCreditAPI.sendReferrallist(new List<Id>{r.Id});
        //SAPReferralCreditAPICallOut.sendReferrallist(null); 
        SAPReferralCreditAPICallOut.sendReferrallist(b1.Id); 
        Test.stopTest();

    }
}