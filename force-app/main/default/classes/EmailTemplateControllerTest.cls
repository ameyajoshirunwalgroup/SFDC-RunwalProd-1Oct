@isTest
public class EmailTemplateControllerTest {

    @testSetup
    static void setupTestData() {
           // Create a test user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        User testUser = new User(
            Alias = 'testusr',
            Email = 'asstweq@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'asstweq@example.com'
        );
        insert testUser;
      System.runAs(testUser) {
            EmailTemplate emailTemplate = new EmailTemplate(
                Name = 'Test 360',
                HtmlValue = '<p>Hello {!Opportunity.Name},</p>',
                Subject = 'Subject for {!Opportunity.Name}',
                DeveloperName = 'Test_360',
                FolderId = UserInfo.getUserId(),
                IsActive = true,
                TemplateType='custom'
            );
            insert emailTemplate;
        }

        User u1 = TestDataFactory.createUserSysAdmin('One','Galvatron', 'galvatron456@radius.com', 'galvatron456@radius.com');
        Legal_Entity__c le=New Legal_Entity__c();
        le.Name='Testing';
        // le.SAP_ID__c='Test';
        //le.Project__c=objpr.id;
        insert le;
        Project__c objpr = new Project__c();
        objpr.Name = 'TestProject';
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
        
        Opportunity objcustomer= new Opportunity();
        objcustomer.RW_Project__c =objpr.id;
        objcustomer.name='Test 1';
        objcustomer.StageName='Open';
        //objcustomer.Tower__c = towerObj.id;
        objcustomer.RW_Project_Unit__c=objPUU.id;  
        objcustomer.CloseDate=system.today()+90;
        objcustomer.Status__c ='Active';
        //objcustomer.Booking__c=
        objCustomer.AccountId = a.Id;
        objcustomer.Sales_Manager__c = 'SM2@g.com';
        insert objcustomer;
        
        Project_Construction_Stages__c pStage = new  Project_Construction_Stages__c();
        pStage.Planned_date_of_completion__c = System.today()+80;
        pStage.Actual_date_of_completion__c = System.today()+90;
        pStage.Project__c = objpr.id;
        pStage.Tower__c = towerObj.Id;
        pStage.Sequence_No__c=1;
        insert pStage;
        
        
        
        
        
        
        List<Quotation__c> qList=new List<Quotation__c>();
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
        q.Token_Amount__c=32552;
        q.Stack_Additional__c = 0;
        q.Allotment_Premium_Agreement_Value__c=35662;
        
        insert q;
        qList.add(q);
        
        Global_Charges__c gc=new Global_Charges__c();
        gc.Name='Basic';
        gc.Code__c='101';
        insert gc;
        Global_Charges__c gc1=new Global_Charges__c();
        gc1.Name='Stamp Duty';
        gc1.Code__c='102';
        insert gc1;
        Global_Charges__c gc2=new Global_Charges__c();
        gc2.Name='Registration Charges';
        gc2.Code__c='103';
        insert gc2;
        
        
        
        
        
        
        
        
        
        Booking__c bookObj = new Booking__c();
        bookObj.Booking_Date__c = System.today();
        bookObj.Quotation__c = q.Id;
        bookObj.Customer__c=objCustomer.Id;
        // bookObj.Loan_Amount__c=100;
        // bookObj.Total_Amount_Paid_TillNow__c=1000;
        // bookObj.Consideration_Value_Including_Tax__c=15;
        bookObj.Status__c='Processed';
        bookObj.Opportunity__c = objCustomer.Id;
        bookObj.Project__c = objpr.Id;
        bookObj.Unit_No__c = objPUU.Id;
        bookObj.Token_Amount__c=1000;                    
        bookObj.Call_Disposition__c = 'Welcome call accepted';
        bookObj.Future_Correspondence_Contact_Email__c = 'abc@g.com';      
        insert bookObj;
        // Create test Car_Parking_Charge__c record
        Car_Parking_Charge__c testCarParkingCharge = new Car_Parking_Charge__c(
            Project__c=objpr.Id
        );
        insert testCarParkingCharge;
        Booked_Car_Parking__c testBookedCarParking = new Booked_Car_Parking__c(
            Booking__c = bookObj.Id,
            Car_Parking_Charge__c = testCarParkingCharge.Id
            
        );
        insert testBookedCarParking;
        system.debug('bookObj'+bookObj);
        system.debug('bookObj.Status__c'+bookObj.Status__c);
        objcustomer.Booking__c=bookObj.Id;
        update objcustomer;
        
       RW_Payment_Details__c rw=new RW_Payment_Details__c();
        rw.RW_Accounting_Document_Number__c='10000001';
        rw.RW_Booking__c=bookObj.id;
        rw.RW_Payment_Date__c=system.today();
        rw.RW_Demand_Number__c='1233456';
        insert rw;
        
        RW_Demand__c dd=new RW_Demand__c();
        dd.Name='1233456';
        dd.Booking__c=bookObj.Id;
        dd.Demand_Date__c=system.today();
        insert dd;
       
        Receipt__c r1 = new Receipt__c();
        r1.Cheque_DD_Amount_Rs__c = 200000;
        r1.Cheque_DD__c = '908888';
        r1.Booking__c=bookObj.Id;
        r1.Cheque_DD_Date__c = system.today();
        r1.Project__c = objpr.Id;
        r1.Project_Unit__c = objPUU.Id;
        r1.Opportunity__c = objcustomer.Id;
        r1.CheckReceipt__c = true;
        r1.Token_Amount_Receipt__c = true;
        r1.Physically_Cheque_Received__c = true;
        r1.Approval_Status__c = 'Approved';
        r1.Receipt_Date__c = system.today();
        r1.DraweeBank__c = 'Axis Bank';
        r1.Total_Amount__c = 200000;
        r1.Currency__c = 'Indian Rupee';
        insert r1;
        
        List<Applicant_Details__c> aplist = new List<Applicant_Details__c>();
        Applicant_Details__c ap = new Applicant_Details__c();
        ap.Booking__C = bookObj.id;
        ap.Applicant_Number__c = 'Primary Applicant';
        ap.Opportunity__c = objcustomer.id;
        ap.Type_Of_Applicant__c = 'Individual Buyer';
        ap.PancardNo__c = 'ABCDE1234E';
        ap.Email_Address__c='abc@g.com';
        ap.Salutation__c = 'Capt.';
        //ap.Rel_Salutation__c='Mr';
        //ap.Applicant_Type__c = 'Primary';
        ap.Name = 'Primary Applicant';
        //  ap.Name_of_Relation__c = 'test';
        ap.Permanent_Address__c = 'abcd';
        ap.Mobile_Number__c = '1234567890';
        ap.Nationality__c = 'Indian';
        ap.Mailing_Address__c='abc';
        ap.Mailing_Pincode__c= 345678;
        ap.Mailing_State__c='up';
        ap.Mailing_City__c='pune';
        ap.Mailing_Country__c='India';
        
        // ap.Locality__c='indian';        
        ap.Subtype_Of_Applicant__c = 'Indian National';
        ap.Mailing_Address_same_as_PermanentAddress__c = true;
        //ap.House_No__c = 'House';
        //ap.Street_1__c = 'Street1';
        //ap.Street_2__c = 'Street2';
        ap.City__c = 'Mumbai';
        ap.State__c='Uttar Pradesh';
        ap.Country__c='India';
        ap.Pincode__c=247001;
        insert ap;
        aplist.add(ap);          
       
        Task task = new Task(
            WhatId = objcustomer.Id,
            Subject = 'Test Task',
            Status = 'Not Started'
        );
        insert task;
    }

    @isTest
    static void testGetEmailTemplates() {
        Test.startTest();
        List<EmailTemplateController.EmailTemplateWrapper> emailTemplates = EmailTemplateController.getEmailTemplates();
        Test.stopTest();

    }

    @isTest
    static void testShareEmailTemplateWithCustomer() {
        EmailTemplate emailTemplate = [SELECT Id FROM EmailTemplate WHERE Name = 'Test 360' LIMIT 1];
        Opportunity opportunity = [SELECT Id FROM Opportunity LIMIT 1];
        
        List<String> recieptId = new List<String>();
        List<String> demandId = new List<String>();
        
        List<Receipt__c> receipts = [SELECT Id FROM Receipt__c];
        for (Receipt__c receipt : receipts) {
            recieptId.add(receipt.Id);
        }
        
        List<RW_Demand__c> demands = [SELECT Id FROM RW_Demand__c];
        for (RW_Demand__c demand : demands) {
            demandId.add(demand.Id);
        }

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        EmailTemplateController.shareEmailTemplateWithCustomer(emailTemplate.Id, opportunity.Id);
        EmailTemplateController.shareEmailTemplateWithRMOnly(emailTemplate.Id, opportunity.Id);
        EmailTemplateController.shareEmailTemplateWithRMCustomer(emailTemplate.Id, opportunity.Id);
        //EmailTemplateController.dummyMethod();
        EmailTemplateController.sendReceiptEmail(recieptId);
        EmailTemplateController.sendDemandEmail(demandId);
        Test.stopTest();

    }
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"ok"}');
            res.setStatusCode(200);
            return res;
        }
    }
}