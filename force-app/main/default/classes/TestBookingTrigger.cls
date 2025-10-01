@isTest
public class TestBookingTrigger {
	@isTest
    public static void BrokerageModuleTest(){
        Test.startTest();
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
        cp.Company_Name_As_per_RERA__c = cp.NAME_FIRST__c + ' ' + cp.NAME_MIDDLE__c + ' ' + cp.NAME_LAST__c;
        insert cp;
        
        Account ac = new Account();                        
        ac.Name = cp.Company_Name_As_per_RERA__c;
        ac.CP_Email__c = cp.RW_Email__c;
        ac.Mobile_No__c = cp.RW_Mobile_No__c;
        ac.Channel_Partner__c = cp.id;
        Id AccCPRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();                
        ac.RecordTypeId = AccCPRecordTypeId;
        insert ac;
        
        objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.Project_Location__c = pl.id;
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
        
        
        Brokerage_Scheme__c bscheme = new Brokerage_Scheme__c();
        bscheme.Type__c = 'Both';
        bscheme.Approval_Status__c = 'Approved by Level 2';
        bscheme.Base_Brokerage_for_Local_Bookings__c = 2;
      //  bscheme.Base_Brokerage_for_OS_NRI__c = 3;
        bscheme.Slab_Type__c = 'Value';
        bscheme.Start_Date__c = system.today();
        bscheme.End_Date__c = system.today()+2;
        bscheme.Project_Location__c = pl.Id;
        bscheme.AOP_CP__c = 1;
        insert bscheme;
        
        Brokerage_Scheme__c bscheme1 = new Brokerage_Scheme__c();
        bscheme1.Type__c = 'Both';
        bscheme1.Approval_Status__c = 'Approved by Level 2';
        bscheme1.Base_Brokerage_for_Local_Bookings__c = 2;
     //   bscheme1.Base_Brokerage_for_OS_NRI__c = 3;
        bscheme1.Slab_Type__c = 'Value';
        bscheme1.Start_Date__c = system.today();
        bscheme1.End_Date__c = system.today()+2;
        bscheme1.Project_Location__c = pl.Id;
        bscheme1.AOP_CP__c = 1;
        insert bscheme1;
        
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
        
        Account cpaccount = [Select Id,Name,Channel_Partner__c from Account where Channel_Partner__c =: cp.Id];
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@stetig.in.com','9098777',false);
        
        
        
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
        b.Brokerage_Scheme__c = bscheme.Id;
        b.Base_Brokerage__c = 2;
        b.Kicker_Incentive_lookup__c = ki.id;
        b.RW_BRL_Number__c = '35363';
        b.RW_Registration_Status__c = 'Registration Completed';
        b.RW_Registration_Type__c = 'Offline Registration';
        b.RW_Expected_Registration_Date__c = system.today();
        b.RW_Registration_Date__c = system.today();
        b.RW_Total_Receipt_Amount_Received__c = 2000000;
        b.RW_Registration_Done__c = 'No';
        b.Passback_Amount__c = 10000;
        insert b;
        
        Brokerage_Summary__c bs = new Brokerage_Summary__c();
        bs.Channel_Partner__c = cp.Id;
        bs.Opportunity__c = objcustomer.Id;
        bs.CP_Account__c = cpaccount.Id;
        bs.Applied_Slab_Name__c = 'Slab 2';
        bs.Show_Invoice__c = true;
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
        bro.Brokerage_Type__c = 'Base Brokerage';
        bro.Booking__c = b.Id;
        insert bro;
        
        b.Brokerage_Summary__c = bs.Id;
        b.CP_Invoice_Approval_Status__c = 'Approved By L2';
        b.RW_Registration_Done__c = 'Yes';
        b.Brokerage_Scheme__c = bscheme1.id;
        update b;
		
        BookingTriggerHandler.updateBrokerageSummaryStatus(new Set<Id>{b.Id});  
        BookingTriggerHandler.updateexcludebatch(new Set<Id>{b.Id});
        BookingTriggerHandler.updateBrokerageonSchemeChange(new List<Id>{b.Id});
        
        test.stopTest();
    }
    @isTest
    public static void BrokerageModuleTest2(){
        Test.startTest();
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
        cp.Company_Name_As_per_RERA__c = cp.NAME_FIRST__c + ' ' + cp.NAME_MIDDLE__c + ' ' + cp.NAME_LAST__c;
        insert cp;
        
        Account ac = new Account();                        
        ac.Name = cp.Company_Name_As_per_RERA__c;
        ac.CP_Email__c = cp.RW_Email__c;
        ac.Mobile_No__c = cp.RW_Mobile_No__c;
        ac.Channel_Partner__c = cp.id;
        Id AccCPRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();                
        ac.RecordTypeId = AccCPRecordTypeId;
        insert ac;
        
        objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.Project_Location__c = pl.id;
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
        
        
        
        Brokerage_Scheme__c bscheme = new Brokerage_Scheme__c();
        bscheme.Type__c = 'Both';
        bscheme.Approval_Status__c = 'Approved by Level 2';
        bscheme.Base_Brokerage_for_Local_Bookings__c = 2;
       // bscheme.Base_Brokerage_for_OS_NRI__c = 3;
        bscheme.Slab_Type__c = 'Value';
        bscheme.AOP_CP__c=7;
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
        
        Account cpaccount = [Select Id,Name,Channel_Partner__c from Account where Channel_Partner__c =: cp.Id];
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@stetig.in.com','9098777',false);
        
        
        
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
        b.Brokerage_Scheme__c = bscheme.Id;
        b.Base_Brokerage__c = 2;
        b.Kicker_Incentive_lookup__c = ki.id;
        b.RW_BRL_Number__c = '35363';
        b.RW_Registration_Status__c = 'Registration Completed';
        b.RW_Registration_Type__c = 'Offline Registration';
        b.RW_Expected_Registration_Date__c = system.today();
        b.RW_Registration_Date__c = system.today();
        b.RW_Total_Receipt_Amount_Received__c = 2000000;
        insert b;
        
        Brokerage_Summary__c bs = new Brokerage_Summary__c();
        bs.Channel_Partner__c = cp.Id;
        bs.Opportunity__c = objcustomer.Id;
        bs.CP_Account__c = cpaccount.Id;
        bs.Applied_Slab_Name__c = 'Slab 2';
        bs.Show_Invoice__c = true;
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
        bro.Brokerage_Type__c = 'Base Brokerage';
        bro.Booking__c = b.Id;
        insert bro;
        try{
        b.Source_of_Booking__c = 'Direct';
        b.Calculate_Brokerage__c = true;
        b.Brokerage_Summary__c = bs.Id;
        update b;
        }catch(Exception ex){
            
        }
		// Added by UBSDigicloud 
        Booking__c insertedBooking = [SELECT Id, Quotation__c FROM Booking__c LIMIT 1];
        BookingTriggerHandler.processQuoteAndRelatedUpdates(new List<Booking__c>{insertedBooking});    
        
        test.stopTest();
    }
    
  /* @isTest
    public static void BrokerageModuleTest3(){
        Test.startTest();
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
        insert cp;
        
        objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.Project_Location__c = pl.id;
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
        
        List<Project_Unit__c> units = new List<Project_Unit__c>();
        objPUU = new Project_Unit__c();  
        objPUU.Project_Unit_Type__c = objPUT.id;  
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c = objpr.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.RW_Unit_Status__c ='Available';
        //insert objPUU;
        units.add(objPUU);
        
        objPUU1 = new Project_Unit__c();  
        objPUU1.Project_Unit_Type__c = objPUT.id;  
        objPUU1.Name = 'TestUnit1';      
        objPUU1.RW_Project__c = objpr.Id;
        objPUU1.RW_Param1__c = '5';
        objPUU1.UnitNo__c ='10';
        objPUU1.RW_Unit_Status__c ='Available';
        //insert objPUU1;
        units.add(objPUU1);
        insert units;
        
        Brokerage_Scheme__c bscheme = new Brokerage_Scheme__c();
        bscheme.Type__c = 'Both';
        bscheme.Approval_Status__c = 'Approved by Level 2';
        bscheme.Base_Brokerage_for_Local_Bookings__c = 2;
        //bscheme.Base_Brokerage_for_OS_NRI__c = 3;
        bscheme.Slab_Type__c = 'Value';
        bscheme.Start_Date__c = system.today();
        bscheme.End_Date__c = system.today()+2;
        bscheme.Project_Location__c = pl.Id;
        bscheme.AOP_CP__c = 1;
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
        
        Account cpaccount = [Select Id,Name,Channel_Partner__c from Account where Channel_Partner__c =: cp.Id];
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@stetig.in.com','9098777',false);
        
        
        List<Opportunity> opps = new List<Opportunity>();
        objcustomer= new Opportunity();
        objcustomer.RW_Project__c=objpr.id;
        objcustomer.RW_Project_Unit__c = objPUU.id;
        objcustomer.name='Test 1';
        objcustomer.StageName='Site Visit';
        objcustomer.RW_Project_Unit__c=objPUU1.id;  
        objcustomer.CloseDate=system.today();
        objcustomer.Status__c ='Active';
        objCustomer.AccountId = a.Id;
        objcustomer.Sales_Manager__c = 'SM2@g.com';
        objcustomer.RW_Type_of_Client__c = 'Local';
        objcustomer.Channel_Partner_Account__c = cpaccount.Id;
        objcustomer.RW_Walkin_Channel_Partner__c = cp.Id;
        objcustomer.Walkin_Source__c = 'Channel Partner';
        //insert objcustomer;
        opps.add(objcustomer);
        objcustomer2= new Opportunity();
        objcustomer2.RW_Project__c=objpr.id;
        objcustomer2.name='Test 1';
        objcustomer2.StageName='Site Visit';
        objcustomer2.RW_Project_Unit__c=objPUU1.id;  
        objcustomer2.CloseDate=system.today();
        objcustomer2.Status__c ='Active';
        objcustomer2.AccountId = a.Id;
        objcustomer2.RW_Type_of_Client__c = 'NRI';
        objcustomer2.Channel_Partner_Account__c = cpaccount.Id;
        objcustomer2.RW_Walkin_Channel_Partner__c =  cp.Id;
        objcustomer2.Walkin_Source__c = 'Channel Partner';
        //objcustomer2.Duplicate_Project_Unit_Request__c = false;
        //objcustomer2.Release_Unit__c = false;
        //insert objcustomer2;
        opps.add(objcustomer2);
        insert opps;
        
        OTP__c otp = new OTP__c();
        otp.Generated_OTP__c = '4522';
        otp.Account__c = cpaccount.Id;
        otp.Project__c = objpr.id;
        insert otp;
        
        List<Quotation__c> quotations = new List<Quotation__c>();
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
        //insert q;
        quotations.add(q);
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
        //insert q2;
        quotations.add(q2);
        Booking__c b = new Booking__c();
        b.Customer__c = objcustomer.Id;
        b.Project__c = objpr.Id;
        b.Opportunity__c = objcustomer.Id;
        b.Unit_No__c = objPUU.id;
        b.Quotation__c = q.Id;
        b.Booking_Date__c = Date.today();
        b.Account__c = cpaccount.Id;
        b.Type_of_Client__c = 'Local';
        b.Status__c = 'UnProcessed';
        b.RW_Registration_Done__c = 'Yes';
        b.BrokerIId__c = cp.Id;
        b.Exclude_From_Brokerage_Batch__c = false;
        b.Source_of_Booking__c = 'Channel Partner';
        b.Allotment_Premium__c = 10000000;
        b.Brokerage_Scheme__c = bscheme.Id;
        b.Base_Brokerage__c = 2;
        b.Kicker_Incentive_lookup__c = ki.id;
        b.RW_BRL_Number__c = '35363';
        b.RW_Registration_Status__c = 'Registration Completed';
        b.RW_Registration_Type__c = 'Offline Registration';
        b.RW_Expected_Registration_Date__c = system.today();
        b.RW_Registration_Date__c = system.today();
        b.Cancellation_Reason__c = 'Unit transfer';
        b.Invoice_Submitted_by_CP__c = true;
        b.RW_Total_Receipt_Amount_Received__c = 2000000;
        insert b;
        
        Receipt__c r1 = new Receipt__c();
        r1.Cheque_DD_Amount_Rs__c = 10000000;
        r1.Cheque_DD__c = '908888';
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
        r1.Total_Amount__c = 10000000;
        r1.Currency__c = 'Indian Rupee';
        r1.Booking__c = b.Id;
        insert r1;
        
        Brokerage_Summary__c bs = new Brokerage_Summary__c();
        bs.Channel_Partner__c = cp.Id;
        bs.Opportunity__c = objcustomer.Id;
        bs.CP_Account__c = cpaccount.Id;
        bs.Applied_Slab_Name__c = 'Slab 2';
        bs.Show_Invoice__c = true;
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
        bro.Brokerage_Type__c = 'Base Brokerage';
        bro.Booking__c = b.Id;
        insert bro;
        
        b.Source_of_Booking__c = 'Direct';
        b.Calculate_Brokerage__c = true;
        b.Status__c = 'Cancelled';
        update b;
		
		        
        test.stopTest();
    }*/
        @isTest
    public static void BrokerageModuleTest4(){
        Test.startTest();
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
        cp.Company_Name_As_per_RERA__c = cp.NAME_FIRST__c + ' ' + cp.NAME_MIDDLE__c + ' ' + cp.NAME_LAST__c;        
        insert cp;
        
        Account ac = new Account();                        
        ac.Name = cp.Company_Name_As_per_RERA__c;
        ac.CP_Email__c = cp.RW_Email__c;
        ac.Mobile_No__c = cp.RW_Mobile_No__c;
        ac.Channel_Partner__c = cp.id;
        Id AccCPRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();                
        ac.RecordTypeId = AccCPRecordTypeId;
        insert ac;
        
        objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.Project_Location__c = pl.id;
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
        
        List<Project_Unit__c> units = new List<Project_Unit__c>();
        objPUU = new Project_Unit__c();  
        objPUU.Project_Unit_Type__c = objPUT.id;  
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c = objpr.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.RW_Unit_Status__c ='Available';
        //insert objPUU;
        units.add(objPUU);
        objPUU1 = new Project_Unit__c();  
        objPUU1.Project_Unit_Type__c = objPUT.id;  
        objPUU1.Name = 'TestUnit1';      
        objPUU1.RW_Project__c = objpr.Id;
        objPUU1.RW_Param1__c = '5';
        objPUU1.UnitNo__c ='10';
        objPUU1.RW_Unit_Status__c ='Available';
        //insert objPUU1;
        units.add(objPUU1);
        insert units;
        
        Brokerage_Scheme__c bscheme = new Brokerage_Scheme__c();
        bscheme.Type__c = 'Both';
        bscheme.Approval_Status__c = 'Approved by Level 2';
        bscheme.Base_Brokerage_for_Local_Bookings__c = 2;
       // bscheme.Base_Brokerage_for_OS_NRI__c = 3;
        bscheme.Slab_Type__c = 'Value';
        bscheme.Start_Date__c = system.today();
        bscheme.End_Date__c = system.today()+2;
        bscheme.Project_Location__c = pl.Id;
        bscheme.AOP_CP__c = 1;
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
        
        Account cpaccount = [Select Id,Name,Channel_Partner__c from Account where Channel_Partner__c =: cp.Id];
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@stetig.in.com','9098777',false);
        
        
        List<Opportunity> opps = new List<Opportunity>();
        objcustomer= new Opportunity();
        objcustomer.RW_Project__c=objpr.id;
        objcustomer.RW_Project_Unit__c = objPUU.id;
        objcustomer.name='Test 1';
        objcustomer.StageName='Qualification';
        //objcustomer.RW_Project_Unit__c=objPUU1.id;  
        objcustomer.CloseDate=system.today();
        objcustomer.Status__c ='Active';
        objCustomer.AccountId = a.Id;
        objcustomer.Sales_Manager__c = 'SM2@g.com';
        objcustomer.RW_Type_of_Client__c = 'Local';
        objcustomer.Channel_Partner_Account__c = cpaccount.Id;
        objcustomer.RW_Walkin_Channel_Partner__c = cp.Id;
        objcustomer.Walkin_Source__c = 'Channel Partner';
        //insert objcustomer;
        opps.add(objcustomer);
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
        //insert objcustomer2;
        opps.add(objcustomer2);
        insert opps;
        OTP__c otp = new OTP__c();
        otp.Generated_OTP__c = '4522';
        otp.Account__c = cpaccount.Id;
        otp.Project__c = objpr.id;
        insert otp;
        
        List<Quotation__c> quotations = new List<Quotation__c>();
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
        //insert q;
        quotations.add(q);
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
        //insert q2;
        quotations.add(q2);
        insert quotations;
        
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
        b.RW_Registration_Done__c = 'Yes';
        b.BrokerIId__c = cp.Id;
        b.Exclude_From_Brokerage_Batch__c = false;
        b.Source_of_Booking__c = 'Channel Partner';
        b.Allotment_Premium__c = 10000000;
        b.Brokerage_Scheme__c = bscheme.Id;
        b.Base_Brokerage__c = 2;
        b.Kicker_Incentive_lookup__c = ki.id;
        b.RW_BRL_Number__c = '35363';
        b.RW_Registration_Status__c = 'Registration Completed';
        b.RW_Registration_Type__c = 'Offline Registration';
        b.RW_Expected_Registration_Date__c = system.today();
        b.RW_Registration_Date__c = system.today();
        b.Cancellation_Reason__c = 'Unit transfer';
        b.Invoice_Submitted_by_CP__c = true;
        b.RW_Total_Receipt_Amount_Received__c = 2000000;
        b.RW_Registration_Done__c = 'No';
        insert b;
        
        Receipt__c r1 = new Receipt__c();
        r1.Cheque_DD_Amount_Rs__c = 10000000;
        r1.Cheque_DD__c = '908888';
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
        r1.Total_Amount__c = 10000000;
        r1.Currency__c = 'Indian Rupee';
        r1.Booking__c = b.Id;
        insert r1;
        
        Brokerage_Summary__c bs = new Brokerage_Summary__c();
        bs.Channel_Partner__c = cp.Id;
        bs.Opportunity__c = objcustomer.Id;
        bs.CP_Account__c = cpaccount.Id;
        bs.Applied_Slab_Name__c = 'Slab 2';
        bs.Show_Invoice__c = true;
        bs.Booking__c = b.Id;
        bs.Status__c = 'Due';
        insert bs;
        
        Brokerage__c bro = new Brokerage__c();
        bro.Name = 'Base Brokerage';
        bro.Brokerage__c = 2;
        bro.Brokerage_Amount__c = 272059;
        bro.Channel_Partner__c = cp.Id;
        bro.Opportunity__c = objcustomer.Id;
        bro.Brokerage_Summary__c = bs.Id;
        bro.Opportunity_AV__c = 13602975;
        bro.Brokerage_Type__c = 'Base Brokerage';
        bro.Booking__c = b.Id;
        insert bro;
        try{
        b.RW_Registration_Done__c = 'Yes';
        b.Source_of_Booking__c = 'Direct';
        b.Calculate_Brokerage__c = true;
        update b;
        }catch(Exception ex){
            
        }
		
		        
        test.stopTest();
    }
    
    @isTest
    public static void bookingTriggerTest(){
        String RecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc = new Account();
        acc.Mobile_No__c = '2222332211';
        acc.LastName = 'Test Acc';
        acc.PersonEmail = 'test@mail.com';
        acc.RecordTypeId = RecTypeId;
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test opp';
        opp.StageName = 'Qualification';
        opp.AccountId = acc.Id;
        opp.CloseDate = Date.today() + 10;
        opp.RW_Mobile_No__c = '122112211';
        opp.RW_Email__c = 'test23111@gmail.com';
        insert opp;
        
        Project_Shortforms__c ps = new Project_Shortforms__c();
        ps.Name = 'Runwal Bliss';
        ps.Short_Name__c = 'R Bliss';
        insert ps;
        
        Booking__c bkg = new Booking__c();
        bkg.Opportunity__c = opp.Id;
        bkg.Customer__c = opp.Id;
        //bkg.Loan_Bank__c = 'HDFC Bank Ltd';
        bkg.Allotment_Premium__c = 100000;
        bkg.Primary_Applicant_Email__c = 'test@mail.com';
        insert bkg;
        
        Booking__c bkgOld = new Booking__c();
        bkgOld.Opportunity__c = opp.Id;
        bkgOld.Interest_to_be_Applied__c = 'No';
        bkgOld.Status__c= 'Booking Confirmed';
        insert bkgOld;
        
        Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.SAPMaterial_Code__c = '1211';
        objpr.RW_Project_Location_Videos_Link__c='test';
        objpr.RW_Project_Brochure_PublicUrl__c='test1';
        insert objpr;

        list<User> usr = [Select Id from User where Id =: userinfo.getUserId()];
        Relationship_Manager__c ObjRm = new Relationship_Manager__c();
        //ObjRm.Tower__c = objTower.Id;
        ObjRm.Project__c = objpr.Id;
        ObjRm.User__c = usr[0].Id;
        ObjRm.Contact_Number__c='1287654323';
        insert ObjRm; 
        
        Project_Unit__c objPUU1 = new Project_Unit__c();  
        //objPUU1.Project_Unit_Type__c = objPUT.id;  
        objPUU1.Name = 'TestUnit173'; 
        objPUU1.Relationship_Manager__c = ObjRm.Id;
        objPUU1.RW_Project__c = objpr.Id;
        objPUU1.RW_Param1__c = '5';
        objPUU1.UnitNo__c ='10';
        objPUU1.RW_Unit_Status__c ='Available';
        insert objPUU1;
        
        Receipt__c rec = new Receipt__c();
        rec.Booking__c = bkg.Id;
        rec.Total_Amount__c = 1000;
        insert rec;
        
        bkg.RW_Key_handover_date__c = Date.today();
        //bkg.RW_Registration_Date__c = Date.today();
        bkg.Booking_Date__c = Date.today();
        bkg.Unit_No__c = objPUU1.Id;
        bkg.Interest_to_be_Applied__c = 'Yes';
        bkg.Status__c= 'Booking Confirmed';
        bkg.Allotment_Premium__c = 200000;
        //update bkg;
        
        
        
        Home_Loan_RM__c hlrm = new Home_Loan_RM__c();
        hlrm.Name = 'Kunal Kate';
        hlrm.Project__c = objpr.Id;
        //hlrm.User__c = '0051e000002B3lvAAC';
        hlrm.User__c = '0055j000003mmhYAAQ';
        hlrm.Reporting_1_Email__c = 'rep1@mail.com';
        hlrm.Reporting_2_Email__c = 'rep2@mail.com';
        hlrm.TL_Name__c = 'Apeksha Sathe';
        hlrm.TL_Email__c = 'apeksha@mail.com';
        insert hlrm;
        
        Home_Loan_RM__c hlrm1 = new Home_Loan_RM__c();
        hlrm1.Name = 'Apeksha Sathe';
        hlrm1.Project__c = objpr.Id;
        hlrm.Reporting_1_Email__c = 'rep1@mail.com';
        hlrm.Reporting_2_Email__c = 'rep2@mail.com';
        hlrm1.TL_Name__c = 'Apeksha Sathe';
        hlrm1.TL_Email__c = 'apeksha@mail.com';
        insert hlrm1;
        
        Bank_with_RM__c bankRM = new Bank_with_RM__c();
        bankRM.Name = 'Axis Bank Ltd-R Bliss';
        bankRM.RM_Name__c = 'Kunal Kate';
        bankRM.RM_Email__c = 'kunal@mail.com';
        bankRM.TL_Name__c = 'Apeksha Sathe';
        bankRM.TL_Email__c = 'apeksha@mail.com';
        insert bankRM;
        
      
        
        RM_Usernames__c rm = new RM_Usernames__c();
        rm.RW_Email__c = 'testrm@mail.com';
        rm.Name = 'Bliss RM';
        rm.RW_Reporting_1_Email__c = 'rep1@mail.com';
        rm.RW_Reporting_2_Email__c = 'rep2@mail.com';
        insert rm;
        
        RM_Usernames__c rm1 = new RM_Usernames__c();
        rm1.RW_Email__c = 'testrm@mail.com';
        rm1.Name = 'Apeksha Sathe';
        rm1.RW_Reporting_1_Email__c = 'rep1@mail.com';
        rm1.RW_Reporting_2_Email__c = 'rep2@mail.com';
        insert rm1;
        
        
        BookingTriggerHandler handler = new BookingTriggerHandler();
        handler.createLoanRecords(new List<Booking__c>{bkg});
        handler.dummyMethod();
        
       
        
        /*UpdateSOReleasedDateFromSAP b = new UpdateSOReleasedDateFromSAP();
b.updateSOReleased();*/
        
        SchedulableContext sc;
        ReminderFor5PercentPayment rem = new ReminderFor5PercentPayment();
        rem.execute(sc);
        
        
    }
}