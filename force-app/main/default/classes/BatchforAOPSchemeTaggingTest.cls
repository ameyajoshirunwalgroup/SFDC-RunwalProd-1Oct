@isTest
public class BatchforAOPSchemeTaggingTest {
@isTest
    public static void BrokerageModuleTest(){
        
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
        
        Broker__c cp = new Broker__c();
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
        cp.SAP_CP_Code__c = '678989';
        insert cp;
         Broker__c cp1 = new Broker__c();
        cp1.Name = 'Broker Cp';
        cp1.RW_Email__c = 'teststetig43646@stetig.in';
        cp1.Individual_CP__c = true;
        cp1.RW_CreateFromIRIS__c = true;
        cp1.RW_IRIS_Sync__c = true;
        cp1.Place_of_Supply__c = 'Maharashtra';
        cp1.Channel_Partner_From_CP_Portal__c = true;
        cp1.Project__c = 'Runwal Bliss';
        cp1.Approver_L1__c = userinfo.getUserId();
        cp1.Approver_L2__c = userinfo.getUserId();
        cp1.Registration_Complete__c = true;
        cp1.RW_Mobile_No__c = '1234567890';
        cp1.Broker_Type__c = 'Individual';
        cp1.Broker_Pan_No__c = 'ADRPI3525F';
        cp1.RW_Mobile_No__c = '1234567890';
        cp1.NAME_FIRST__c = 'tets';
        cp1.NAME_MIDDLE__c = 'cp';
        cp1.NAME_LAST__c = 'test';
        cp1.TITLE__c = 'Mr.';
        cp1.Account_Number__c = '465446';
        cp1.Cheque_DD_Favouring_Name__c = 'test cp';
        cp1.IFSC_Code__c = 'BHSHVD';
        cp1.Is_NRI_CP__c = false;
        cp1.RW_Is_GST_Applicable__c = true;
        cp1.Channel_Partner_From_CP_Portal__c =true;
        cp1.SAP_CP_Code__c = '732989';
        insert cp1;
        
        
        objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.Project_Location__c = pl.id;
        objpr.CP_Invoice_Approver_L1__c = userinfo.getUserId();
        objpr.CP_Invoice_Approver_L2__c = userinfo.getUserId();
        insert objpr;
        
        Opp_Close_Date__c cls = new Opp_Close_Date__c();
        cls.Project_Name__c = 'Test Proj';
        cls.Name = objpr.Id;
        cls.No_of_Days__c = 45;
        insert cls;
        
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
        
       
        
        Project_Charges__c prc = new Project_Charges__c();
        prc.Name = 'Basic';
        prc.Project__c = objpr.Id;
        insert prc;
        
        Account cpaccount = [Select Id,Name,Channel_Partner__c,PersonEmail,Mobile_No__c from Account where Channel_Partner__c =: cp.Id];
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@stetig.in.com','9098777',false);
        
        
        Broker__c objBroker = new Broker__c();
            objBroker.Broker_Pan_No__c = 'ABCDF34526';
            objBroker.Name = 'Testcp2';
            objBroker.RW_Email__c = 'testcp4@stetig.in';
            objBroker.Dialing_Country1__c = 'India';
            objBroker.Dialing_Country_Code1__c = '+91';
            objBroker.RW_Mobile_No__c = '1112288888';
            objBroker.Unregistered_Channel_Partner__c = true;
        objBroker.SAP_CP_Code__c = 'Test';
        Insert objBroker;
        objcustomer= new Opportunity();
        objcustomer.RW_Project__c=objpr.id;
        objcustomer.name='Test 1';
        objcustomer.StageName='Qualification';
        //objcustomer.RW_Project_Unit__c=objPUU1.id;  
        objcustomer.CloseDate=system.today();
        objcustomer.Status__c ='Active';
        objCustomer.AccountId = a.Id;
        objcustomer.Sales_Manager__c = 'SM2@g.com';
        objcustomer.RW_Type_of_Client__c = 'Local';
        objcustomer.Channel_Partner_Account__c = cpaccount.Id;
        objcustomer.RW_Walkin_Channel_Partner__c = objBroker.Id;
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
        OTP__c otp = new OTP__c();
        otp.Generated_OTP__c = '4522';
        otp.Account__c = cpaccount.Id;
        otp.Project__c = objpr.id;
        insert otp;
        
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
         
        /*Id recordTypeId = [SELECT Id FROM RecordType WHERE Name = 'AOP' AND SObjectType = 'AOP__c' LIMIT 1].Id;
        AOP__c ao=new AOP__c();
       // ao.Name='Scheme 1';
        ao.RecordTypeId=recordTypeId;
        ao.CreatedDate=
           // ao.Start_Date__c = Date.today().addDays(-10);
           // ao.End_Date__c=Date.today().addDays(10);
        ao.Legacy_booking_treated__c=false;
        ao.CreatedDate=Date.today().addDays(-12);
       // ao.Channel_Partner__c=cpaccount.Id;
        insert ao;*/
         Id AopRecordTypeId = Schema.SObjectType.AOP__c.getRecordTypeInfosByName().get('AOP').getRecordTypeId();

 Profile profileId = [SELECT Id FROM Profile WHERE Name = 'CP Access' LIMIT 1];
        List<User> lstUser = new List<User>();
        lstUser.add(new User(LastName = 'Test',
            FirstName='Test1 User',
            Alias = 'tstU1',
            Email = 'testUsr1@stetig.in',
            Username = 'testUsr1@stetig.in',
            ProfileId = profileId.id,
            ManagerId = userinfo.getUserId(),
            CTI_Agent_ID__c = 'test.test1',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'));
            lstUser.add(new User(LastName = 'Test2',
            FirstName='Test User2',
            Alias = 'tstU2',
            Email = 'testUsr2@stetig.in',
            Username = 'testUsr2@stetig.in',
            ProfileId = profileId.id,
            department='presales',
            CTI_Agent_ID__c = 'test.test2',
            ManagerId = userinfo.getUserId(),
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'));
        insert lstUser;
        
        AOP__c aop = new AOP__c();
        aop.Start_Date__c = Date.today().addDays(-10);
        aop.End_Date__c=Date.today().addDays(10);
        aop.Category__c = 'Diamond';
        aop.Channel_Partner__c = objBroker.Id;
        aop.RecordTypeId = AopRecordTypeId;
        insert aop;
        Test.setCreatedDate(aop.Id, DateTime.now().addDays(-5)); // Example: 5 days in the past

        
        AOP__c aop1 = new AOP__c();
        aop1.Start_Date__c = system.today()-900;
        aop1.End_Date__c = system.today()+900;
        aop1.Category__c = 'Silver';
        aop1.Channel_Partner__c = cp.Id;        
        aop1.RecordTypeId = AopRecordTypeId;
        aop1.Legacy_booking_treated__c = false;
        insert aop1; 
        Test.setCreatedDate(aop1.Id, DateTime.now().addDays(-5)); // Example: 5 days in the past

        
        Booking__c b = new Booking__c();
        b.Customer__c = objcustomer.Id;
        b.Project__c = objpr.Id;
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
        b.Source_of_Booking__c = 'Channel Partner';
        b.Allotment_Premium__c = 10000000;
         b.CreatedDate=Date.today().addDays(-5);
       // b.Brokerage_Scheme__c = bscheme.Id;
       // b.Base_Brokerage__c = 2;
      //  b.Kicker_Incentive_lookup__c = ki.id;
        b.RW_BRL_Number__c = '35363';
        b.RW_Registration_Status__c = 'Registration Completed';
        b.RW_Registration_Type__c = 'Offline Registration';
        b.RW_Expected_Registration_Date__c = system.today();
        b.RW_Registration_Date__c = system.today();
        b.RW_Total_Receipt_Amount_Received__c = 2000000;
        b.RW_Registration_Done__c = 'No';
        insert b;
        
        Booking__c b1 = new Booking__c();
        b1.Customer__c = objcustomer.Id;
        b1.Project__c = objpr.Id;
        b1.Opportunity__c = objcustomer.Id;
        b1.Unit_No__c = objPUU.id;
        b1.Quotation__c = q.Id;
        b1.Booking_Date__c = Date.today();
        b1.Account__c = cpaccount.Id;
        b1.Type_of_Client__c = 'Local';
        b1.Status__c = 'Booking Confirmed';
        b1.RW_Registration_Done__c = 'No';
        b1.BrokerIId__c = objBroker.Id;
        b1.Exclude_From_Brokerage_Batch__c = false;
        b1.Source_of_Booking__c = 'Channel Partner';
        b1.Allotment_Premium__c = 10000000;
         b1.CreatedDate=Date.today().addDays(-5);
       // b.Brokerage_Scheme__c = bscheme.Id;
       // b.Base_Brokerage__c = 2;
      //  b.Kicker_Incentive_lookup__c = ki.id;
        b1.RW_BRL_Number__c = '35363';
        b1.RW_Registration_Status__c = 'Registration Completed';
        b1.RW_Registration_Type__c = 'Offline Registration';
        b1.RW_Expected_Registration_Date__c = system.today();
        b1.RW_Registration_Date__c = system.today();
        b1.RW_Total_Receipt_Amount_Received__c = 2000000;
        b1.RW_Registration_Done__c = 'No';
        insert b1;
        
        Booking__c b2 = new Booking__c();
        b2.Customer__c = objcustomer.Id;
        b2.Project__c = objpr.Id;
        b2.Opportunity__c = objcustomer.Id;
        b2.Unit_No__c = objPUU.id;
        b2.Quotation__c = q.Id;
        b2.Booking_Date__c = Date.today();
        b2.Account__c = cpaccount.Id;
        b2.Type_of_Client__c = 'Local';
        b2.Status__c = 'Booking Confirmed';
        b2.RW_Registration_Done__c = 'No';
        b2.BrokerIId__c = objBroker.Id;
        b2.Exclude_From_Brokerage_Batch__c = false;
        b2.Source_of_Booking__c = 'Channel Partner';
        b2.Allotment_Premium__c = 10000000;
         b2.CreatedDate=Date.today().addDays(-5);
       // b.Brokerage_Scheme__c = bscheme.Id;
       // b.Base_Brokerage__c = 2;
      //  b.Kicker_Incentive_lookup__c = ki.id;
        b2.RW_BRL_Number__c = '35363';
        b2.RW_Registration_Status__c = 'Registration Completed';
        b2.RW_Registration_Type__c = 'Offline Registration';
        b2.RW_Expected_Registration_Date__c = system.today();
        b2.RW_Registration_Date__c = system.today();
        b2.RW_Total_Receipt_Amount_Received__c = 2000000;
        b2.RW_Registration_Done__c = 'No';
        insert b2;
       
        Test.startTest();
        BatchforAOPSchemeTagging  bb = new BatchforAOPSchemeTagging();
        Database.executeBatch(bb,50);
      
                String jobId = System.schedule('Test AOP Scheduler', '0 0 0 * * ?', new ScheduleBatchforAOPSchemeTagging());

     
    }
}