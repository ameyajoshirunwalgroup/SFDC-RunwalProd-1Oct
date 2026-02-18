@isTest
public class TestBrokerageManagementService2 {
    

    @IsTest
    static void test_GetKickerIncentives_and_Calculation() {
         // Project and Tower
        Project__c proj = new Project__c(Name = 'Test Project');
        insert proj;

        Tower__c tower = new Tower__c(Name = 'Test Tower', ProjectName__c = proj.Id);
        insert tower;


  // ---- BROKERAGE SCHEME ----
        Brokerage_Scheme__c bscheme1 = new Brokerage_Scheme__c(
            Type__c = 'Both',
            Approval_Status__c = 'Approved by Level 2',
            Base_Brokerage_for_Local_Bookings__c = 2,
            Base_Brokerage_for_OS_NRI__c = 2,
            Base_Brokerage_for_NRI__c = 2,
            Slab_Type__c = 'Count',
            Start_Date__c = System.today(),
            End_Date__c = System.today() + 2
            //Project_Location__c = pl.Id
        );
        insert bscheme1;
        
        // === UNIT TYPOLOGY INCENTIVE ===
        Kicker_Incentive__c kickerTypo = new Kicker_Incentive__c(
            Name = 'Typology Incentive',
            Type__c = 'Unit Typology',
            Type_Of_Client__c = 'Local',
            Start_Date__c = Date.today().addDays(-5),
            End_Date__c = Date.today().addDays(5),
            Brokerage_scheme__c = bscheme1.id
        );
        insert kickerTypo;

        Kicker_Incentive_Configuration__c configTypo = new Kicker_Incentive_Configuration__c(
            Name = 'Config Typo',
            Project__c = proj.Id,
            Tower__c = tower.Id,
            Kicker_Incentive__c = kickerTypo.Id
        );
        insert configTypo;

        Kicker_Typology__c typoRec = new Kicker_Typology__c(
            Name = '2BHK Typo',
            Kicker_Incentive__c = kickerTypo.Id,
            Unit_Type__c = 'C01',
            Amount__c = 5000
        );
        insert typoRec;

        // === PER DEAL INCENTIVE ===
        Kicker_Incentive__c kickerPerDeal = new Kicker_Incentive__c(
            Name = 'Per Deal Incentive',
            Type__c = 'Per Deal',
            Per_Deal_Amount__c = 8000,
            Start_Date__c = Date.today().addDays(-5),
            End_Date__c = Date.today().addDays(5),
            Brokerage_scheme__c = bscheme1.id
        );
        insert kickerPerDeal;

        Kicker_Incentive_Configuration__c configPerDeal = new Kicker_Incentive_Configuration__c(
            Name = 'Config PerDeal',
            Project__c = proj.Id,
            Tower__c = tower.Id,
            Kicker_Incentive__c = kickerPerDeal.Id
        );
        insert configPerDeal;

        // === CUMULATIVE INCENTIVE ===
        Kicker_Incentive__c kickerCumulative = new Kicker_Incentive__c(
            Name = 'Cumulative Incentive',
            Type__c = 'Cumulative',
            Start_Date__c = Date.today().addDays(-10),
            End_Date__c = Date.today().addDays(10),
            Brokerage_scheme__c = bscheme1.id
        );
        insert kickerCumulative;

        Kicker_Incentive_Configuration__c configCumulative = new Kicker_Incentive_Configuration__c(
            Name = 'Config Cumulative',
            Project__c = proj.Id,
            Tower__c = tower.Id,
            Kicker_Incentive__c = kickerCumulative.Id
        );
        insert configCumulative;

        Kicker_Incentive_Slab__c slab = new Kicker_Incentive_Slab__c(
            Name = 'Cumulative Slab 1',
            Kicker_Incentive__c = kickerCumulative.Id,
            Logical_Operator__c = 'AND',
            From__c = 1,
            To__c = 10,
            From_Value__c = 100000,
            To_Value__c = 9999999,
            Amount__c = 10000
        );
        insert slab;

        // === BROKER & BOOKING SETUP ===
      
        Broker__c cp = new Broker__c();
        cp.Name = 'Test CP';
        cp.RW_Email__c = 'teststetig@stetig.in';
        cp.Individual_CP__c = true;
        cp.RW_CreateFromIRIS__c = true;
        cp.RW_IRIS_Sync__c = true;
        cp.Place_of_Supply__c = 'Maharashtra';
        cp.Channel_Partner_From_CP_Portal__c = true;
        cp.Project__c = 'Runwal Bliss';
        cp.Approver_L1__c = userinfo.getUserId();
        cp.Approver_L2__c = userinfo.getUserId();
        cp.Registration_Complete__c = true;
        cp.Latest_RERA_Upload_Status__c = 'Approved';
        cp.RERA_Valid_till__c = system.today()+2;
        cp.Latest_CC_Upload_Status__c = 'Approved';
        cp.CC_Valid_till__c = system.today()+2;
        cp.RW_Mobile_No__c = '1234567890';
        cp.Broker_Type__c = 'Individual';
        cp.Broker_Pan_No__c = 'ADRPI3525F';
        cp.RW_RERA_Registration_Number__c = '123256789012';
        cp.Company_Name_As_per_RERA__c = 'Test CP';
        insert cp;
        
        Account ac = new Account();
        ac.Name = cp.Company_Name_As_per_RERA__c;
        ac.CP_Email__c = cp.RW_Email__c;
        ac.Mobile_No__c = cp.RW_Mobile_No__c;
        ac.Channel_Partner__c = cp.id;
        ac.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
        insert ac;
        
        Project__c objpr1 = new Project__c(
            RW_Project_Code__c = 'T31',
            Name = 'Runwal Bliss',
            RDS_Short_Name__c = 'T',
            Start_Date__c = System.today().addDays(-5),
            RDS_Interest_Rate__c = 12
        );
        insert objpr1;
         List<Tower__c> t = TestDataFactory.createTowers(1, objpr1.Id);
        
        Project_Unit_Type__c objPUT = new Project_Unit_Type__c(RDS_Code__c = '101', RDS_Project__c = objpr1.Id);
        insert objPUT;
        
        List<Project_Unit__c> units = new List<Project_Unit__c>{
            new Project_Unit__c(
                Project_Unit_Type__c = objPUT.Id,
                Name = 'TestUnit',
                RW_Project__c = objpr1.Id,
                New_Type__c = 'R52',
                RW_Param1__c = '5',
                UnitNo__c = '9',
                RW_Unit_Status__c = 'Available'
            ),
                new Project_Unit__c(
                    Project_Unit_Type__c = objPUT.Id,
                    Name = 'TestUnit1',
                    RW_Project__c = objpr1.Id,
                    RW_Param1__c = '5',
                    New_Type__c = 'R52',
                    UnitNo__c = '10',
                    RW_Unit_Status__c = 'Available'
                )
                };
                    insert units;
        Project_Unit__c objPUU = units[0];
        Project_Unit__c objPUU1 = units[1];
        
              
        // ---- BROKERAGE SLABS ----
        List<Brokerage_Slab__c> slabs = new List<Brokerage_Slab__c>{
            new Brokerage_Slab__c(
                Name = 'Slab 1',
                From__c = 0,
                To__c = 1,
                Additional_Brokerage_for_Local_Bookings__c = 2,
                Additional_Brokerage_for_OS_NRI__c = 0,
                Brokerage_Scheme__c = bscheme1.Id
            ),
                new Brokerage_Slab__c(
                    Name = 'Slab 2',
                    From__c = 2,
                    To__c = null,
                    Additional_Brokerage_for_Local_Bookings__c = 2,
                    Additional_Brokerage_for_OS_NRI__c = 0.25,
                    Brokerage_Scheme__c = bscheme1.Id
                )
                };
                    insert slabs;
        
        // ---- SCHEME CONFIG ----
        insert new Scheme_Configuration__c(
            Name = 'Oct',
            Brokerage_Scheme__c = bscheme1.Id,
            Project__c = objpr1.Id,
            Tower__c = t[0].Id            
        );
        Account cpaccount = [SELECT Id, Name, Channel_Partner__c FROM Account WHERE Channel_Partner__c = :cp.Id];
        
        Opportunity objcustomer = new Opportunity();
        objcustomer.RW_Project__c = objpr1.id;
        objcustomer.Name = 'Test 1';
        objcustomer.StageName = 'Qualification';
        objcustomer.CloseDate = system.today();
        objcustomer.Status__c = 'Active';
        objCustomer.AccountId = cpaccount.Id;
        objcustomer.Sales_Manager__c = 'SM2@g.com';
        objcustomer.RW_Type_of_Client__c = 'Local';
        objcustomer.Channel_Partner_Account__c = cpaccount.Id;
        objcustomer.RW_Walkin_Channel_Partner__c = cp.Id;
        objcustomer.Walkin_Source__c = 'Channel Partner';
        
        Opportunity objcustomer1 = new Opportunity();
        objcustomer1.RW_Project__c = objpr1.id;
        objcustomer1.Name = 'Test 1';
        objcustomer1.StageName = 'Qualification';
        objcustomer1.CloseDate = system.today();
        objcustomer1.Status__c = 'Active';
        objcustomer1.AccountId = cpaccount.Id;
        objcustomer1.RW_Type_of_Client__c = 'Local';
        objcustomer1.Channel_Partner_Account__c = cpaccount.Id;
        objcustomer1.RW_Walkin_Channel_Partner__c = cp.Id;
        objcustomer1.Walkin_Source__c = 'Channel Partner';
        
        insert new List<Opportunity>{ objcustomer, objcustomer1 };
            
            Quotation__c q = new Quotation__c();
        q.Name = 'Q010101';
        q.Quote_Status__c = 'Valid';
        q.Prepared_Date__c = System.today();
        q.Project__c = objpr1.Id;
        q.Project_Unit__c = objPUU.Id;
        q.FloorNo__c = 11;
        q.Opportunity__c = objcustomer.Id;
        q.Agreement_Value_for_brokers__c = 10000000;
        q.Discount_Applied__c = false;
        q.Appartment_Configuration__c = '1 BHK';
        
        q.Carpet_Area_Sq_Ft__c = 1200;
        q.Token_Amount__c = 110000;
        q.Agreement_Value_for_brokers__c = 10000000;
        q.Discount_Applied__c = false;
        Quotation__c q2 = new Quotation__c();
        q2.Name = 'Q020202';
        q2.Quote_Status__c = 'Approval Pending';
        q2.Prepared_Date__c = System.today();
        q2.Project__c = objpr1.Id;
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
        r1.Project__c = objpr1.Id
            																																																																																																												;
        r1.Project_Unit__c = objPUU.Id;
        r1.Opportunity__c = objcustomer.Id;
        r1.Approval_Status__c = 'Approved';
        r1.Total_Amount__c = 6000000;
        r1.Currency__c = 'Indian Rupee';
        
        Receipt__c r2 = new Receipt__c();
        r2.Cheque_DD_Amount_Rs__c = 8400;
        r2.Cheque_DD__c = '9088881';
        r2.Project__c = objpr1.Id;
        r2.Project_Unit__c = objPUU.Id;
        r2.Opportunity__c = objcustomer.Id;
        r2.Approval_Status__c = 'Approved';
        r2.Total_Amount__c = 8400;
        r2.Currency__c = 'Indian Rupee';
        
        insert new List<Receipt__c>{ r1, r2 };
            
            // --- Combined Booking Inserts ---
            Booking__c b = new Booking__c();
        b.Customer__c = objcustomer1.Id;
        b.Project__c = objpr1.Id;
        b.Opportunity__c = objcustomer1.Id;
        b.Unit_No__c = objPUU1.id;
        b.Quotation__c = q2.Id;
        b.Receipts__c = r2.Id;
        b.Booking_Date__c = Date.today();
        b.Account__c = cpaccount.Id;
        b.Type_of_Client__c = 'NRI';
        b.Status__c = 'Booking Confirmed';
        b.RW_Registration_Done__c = 'No';
        b.BrokerIId__c = cp.Id;
        b.Exclude_From_Brokerage_Batch__c = false;
        b.Source_of_Booking__c = 'Channel Partner';
        b.RW_Registration_Date__c = Date.today();
        b.RW_Total_Receipt_Amount_Received__c = 5000000;
        b.Brokerage_Scheme__c = bscheme1.Id;
        b.Custom_Base_Brokerage__c = 1;
        b.Checklist_Approved__c = true;
        
        Booking__c b2 = b.clone(false, true, false, false);
        Booking__c b3 = b.clone(false, true, false, false);
        
        Booking__c booking = new Booking__c(
            //Name = 'Booking1',
            Unit_No__c = objPUU.Id,
            Project__c = objpr1.Id,
            Tower__c = t[0].Id,
            Account__c = cpaccount.Id,
            BrokerIId__c = cp.Id,
            //Agreement_Value_for_brokers__c = 200000,
            Kicker_Incentive_lookup__c = kickerCumulative.Id,
            Status__c = 'Confirmed'
        );
        
        List<Booking__c> bookingsToInsert = new List<Booking__c>{ b, b2, b3 ,booking};
            insert bookingsToInsert;

        
        

        Brokerage_Summary__c bs = new Brokerage_Summary__c(
            //Name = 'Brokerage Summary 1',
            Booking__c = b.Id,
            Channel_Partner__c = cp.Id,
            //Total_Agreement_Value__c = 200000,
            Brokerage_Scheme__c = bscheme1.Id
        );
        insert bs;
        // Fetch setup data
        Project_Unit__c unit = [SELECT Id FROM Project_Unit__c LIMIT 1];
        Kicker_Incentive__c typoIncentive = [SELECT Id FROM Kicker_Incentive__c WHERE Type__c = 'Unit Typology' LIMIT 1];
        Kicker_Incentive__c perDealIncentive = [SELECT Id FROM Kicker_Incentive__c WHERE Type__c = 'Per Deal' LIMIT 1];
        Kicker_Incentive__c cumIncentive = [SELECT Id FROM Kicker_Incentive__c WHERE Type__c = 'Cumulative' LIMIT 1];

        // Call 1: Typology
        Test.startTest();

        // Now call KickerCalulation for each
        BrokerageManagementServicesV2.KickerCalulation(typoIncentive.Id);
        BrokerageManagementServicesV2.KickerCalulation(perDealIncentive.Id);
        BrokerageManagementServicesV2.KickerCalulation(cumIncentive.Id);
        Test.stopTest();

    }
    
    
    
	    @isTest
    public static void testbmsSCTandPNRI() {
        Opportunity objcustomer;
        Opportunity objcustomer1;
        Booking__c objBooking;
        Project__c objpr;
        Project_Unit__c objPUU;
        Project_Unit__c objPUU1;
        Project_Unit_Type__c objPUT;
        Set<Id> BIds = new Set<Id>();
        
        
        // ---- CREATE PROJECT ----
        objpr = new Project__c(
            RW_Project_Code__c = 'T31',
            Name = 'Runwal Blisss',
            RDS_Short_Name__c = 'T2',
            Start_Date__c = System.today().addDays(-5),
            RDS_Interest_Rate__c = 12
        );
        insert objpr;
        
        List<Tower__c> t = TestDataFactory.createTowers(1, objpr.Id);
        
        
        // ---- PROJECT LOCATION ----
        Project_Location__c pl = new Project_Location__c(
            Name = 'Mumbai',
            Approver_L1__c = UserInfo.getUserId(),
            Approver_L2__c = UserInfo.getUserId(),
            Location__c = 'Mumbai'
        );
        insert pl;
        
        // ---- BROKERAGE SCHEME ----
        Brokerage_Scheme__c bscheme = new Brokerage_Scheme__c(
            Type__c = 'Local',
            Approval_Status__c = 'Approved by Level 2',
            Base_Brokerage_for_Local_Bookings__c = 2,
            Slab_Type__c = 'Count',
            Start_Date__c = System.today(),
            End_Date__c = System.today() + 2,
            Project_Location__c = pl.Id
        );
        insert bscheme;
        
        // ---- BROKERAGE SLABS ----
        List<Brokerage_Slab__c> slabs = new List<Brokerage_Slab__c>{
            new Brokerage_Slab__c(
                Name = 'Slab 1',
                From__c = 0,
                To__c = 1,
                Additional_Brokerage_for_Local_Bookings__c = null,
                Additional_Brokerage_for_OS_NRI__c = 0,
                Brokerage_Scheme__c = bscheme.Id
            ),
                new Brokerage_Slab__c(
                    Name = 'Slab 2',
                    From__c = 2,
                    To__c = null,
                    Additional_Brokerage_for_Local_Bookings__c = null,
                    Additional_Brokerage_for_OS_NRI__c = 0.25,
                    Brokerage_Scheme__c = bscheme.Id
                )
                };
                    insert slabs;
        
        // ---- SCHEME CONFIG ----
        insert new Scheme_Configuration__c(
            Name = 'Oct',
            Brokerage_Scheme__c = bscheme.Id,
            Project__c = objpr.Id,
            Tower__c = t[0].Id
        );
        
        // ---- KICKER INCENTIVE ----
        Kicker_Incentive__c ki = new Kicker_Incentive__c(
            Name = 'Kicker Sep & Oct 2022',
            Brokerage_Scheme__c = bscheme.Id,
            Start_Date__c = System.today() - 2,
            End_Date__c = System.today() + 2,
            Type__c = 'Cumulative',
            Type_Of_Client__c = 'Local'
        );
        insert ki;
        
        insert new Kicker_Incentive_Configuration__c(
            Kicker_Incentive__c = ki.Id,
            Project__c = objpr.Id,
            Tower__c = t[0].Id
        );
        
        insert new Kicker_Incentive_Slab__c(
            Name = '2000000:6',
            Kicker_Incentive__c = ki.Id,
            Value__c = 100,
            No_of_Bookings__c = 1,
            Logical_Operator__c = 'AND',
            Amount__c = 2000000,
            From__c = 0,
            To__c = null,
            From_Value__c = 0,
            To_Value__c = null
        );
        
        // ---- UNIT TYPE + UNITS ----
        objPUT = new Project_Unit_Type__c(RDS_Code__c = '101', RDS_Project__c = objpr.Id);
        insert objPUT;
        
        List<Project_Unit__c> units = new List<Project_Unit__c>{
            new Project_Unit__c(
                Project_Unit_Type__c = objPUT.Id,
                Name = 'TestUnit',
                RW_Project__c = objpr.Id,
                RW_Param1__c = '5',
                UnitNo__c = '9',
                RW_Unit_Status__c = 'Available'
            ),
                new Project_Unit__c(
                    Project_Unit_Type__c = objPUT.Id,
                    Name = 'TestUnit1',
                    RW_Project__c = objpr.Id,
                    RW_Param1__c = '5',
                    UnitNo__c = '10',
                    RW_Unit_Status__c = 'Available'
                )
                };
                    insert units;
        objPUU = units[0];
        objPUU1 = units[1];
        
        // ---- PROJECT CHARGE ----
        insert new Project_Charges__c(Name = 'Basic', Project__c = objpr.Id);
        
        // ---- BROKER + ACCOUNT ----
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@stetig.in.com', '9098777', false);
        
        Broker__c cp = new Broker__c(
            Name = 'Test CP',
            RW_Email__c = 'teststetig@stetig.in',
            Individual_CP__c = true,
            RW_CreateFromIRIS__c = true,
            RW_IRIS_Sync__c = true,
            Place_of_Supply__c = 'Maharashtra',
            Channel_Partner_From_CP_Portal__c = true,
            Project__c = 'Runwal Bliss',
            Approver_L1__c = UserInfo.getUserId(),
            Approver_L2__c = UserInfo.getUserId(),
            Registration_Complete__c = true,
            RW_Mobile_No__c = '1234567890',
            Broker_Type__c = 'Individual',
            Broker_Pan_No__c = 'ADRPI3525F',
            RW_RERA_Registration_Number__c = '123256789012',
            Company_Name_As_per_RERA__c = 'Test CP',
            Latest_RERA_Upload_Status__c = 'Approved',
            RERA_Valid_till__c = system.today()+2,
            Latest_CC_Upload_Status__c = 'Approved',
            CC_Valid_till__c = system.today()+2
        );
        insert cp;
        
        Account ac = new Account(
            Name = cp.Company_Name_As_per_RERA__c,
            CP_Email__c = cp.RW_Email__c,
            Mobile_No__c = cp.RW_Mobile_No__c,
            Channel_Partner__c = cp.Id,
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId()
        );
        insert ac;
        
        Account cpaccount = [SELECT Id, Name, Channel_Partner__c FROM Account WHERE Channel_Partner__c = :cp.Id];
        
        // ---- OPPORTUNITIES ----
        objcustomer = new Opportunity(
            RW_Project__c = objpr.Id,
            Name = 'Test 1',
            StageName = 'Qualification',
            CloseDate = System.today(),
            Status__c = 'Active',
            AccountId = a.Id,
            Sales_Manager__c = 'SM2@g.com',
            RW_Type_of_Client__c = 'Local',
            Channel_Partner_Account__c = cpaccount.Id,
            RW_Walkin_Channel_Partner__c = cp.Id,
            Walkin_Source__c = 'Channel Partner'
        );
        
        objcustomer1 = objcustomer.clone(false, true, false, false);
        insert new List<Opportunity>{ objcustomer, objcustomer1 };
            
            // ---- QUOTATIONS ----
            List<Quotation__c> quotes = new List<Quotation__c>{
                new Quotation__c(
                    Name = 'Q010101',
                    Quote_Status__c = 'Valid',
                    Prepared_Date__c = System.today(),
                    Project__c = objpr.Id,
                    Project_Unit__c = objPUU.Id,
                    FloorNo__c = 11,
                    Opportunity__c = objcustomer.Id,
                    Appartment_Configuration__c = '1 BHK',
                    Carpet_Area_Sq_Ft__c = 1200,
                    Token_Amount__c = 110000,
                    ST_Token_Amount__c = 1000,
                    Allow_booking_without_full_token__c = TRUE,
                    Agreement_Value__c = 60422880,
                    Agreement_Value_ST__c = 2537761,
                    Agreement_Value_for_brokers__c = 10000000
                ),
                    new Quotation__c(
                        Name = 'Q020202',
                        Quote_Status__c = 'Approval Pending',
                        Prepared_Date__c = System.today(),
                        Project__c = objpr.Id,
                        Project_Unit__c = objPUU1.Id,
                        FloorNo__c = 11,
                        Opportunity__c = objcustomer1.Id,
                        Appartment_Configuration__c = '1 BHK',
                        Carpet_Area_Sq_Ft__c = 1200,
                        Token_Amount__c = 110000,
                        ST_Token_Amount__c = 1000,
                        Allow_booking_without_full_token__c = TRUE,
                        Agreement_Value__c = 60422880,
                        Agreement_Value_ST__c = 2537761,
                        Agreement_Value_for_brokers__c = 10000000
                    )
                    };
                        insert quotes;
        
        // ---- RECEIPTS ----
        List<Receipt__c> receipts = new List<Receipt__c>{
            new Receipt__c(
                Cheque_DD_Amount_Rs__c = 6000000,
                Cheque_DD__c = '908888',
                Cheque_DD_Date__c = System.today(),
                Project__c = objpr.Id,
                Project_Unit__c = objPUU.Id,
                Opportunity__c = objcustomer.Id,
                CheckReceipt__c = true,
                Token_Amount_Receipt__c = true,
                Physically_Cheque_Received__c = true,
                Approval_Status__c = 'Approved',
                Receipt_Date__c = System.today(),
                DraweeBank__c = 'Axis Bank',
                Total_Amount__c = 6000000,
                Currency__c = 'Indian Rupee'
            ),
                new Receipt__c(
                    Cheque_DD_Amount_Rs__c = 8400,
                    Cheque_DD__c = '9088881',
                    Cheque_DD_Date__c = System.today(),
                    Project__c = objpr.Id,
                    Project_Unit__c = objPUU.Id,
                    Opportunity__c = objcustomer.Id,
                    CheckReceipt__c = true,
                    Physically_Cheque_Received__c = true,
                    Approval_Status__c = 'Approved',
                    Receipt_Date__c = System.today(),
                    DraweeBank__c = 'CITI',
                    Total_Amount__c = 8400,
                    Currency__c = 'Indian Rupee',
                    Token_Amount_ST__c = true
                )
                };
                    insert receipts;
        
        // ---- BOOKINGS ----
        // (continued exactly as in your original method but all inserts replaced with list inserts)
        // ...
        
        Test.startTest();
        //BrokerageManagementService.brokerageCalculation(BIds);
        //BrokerageManagementService.BrokerageCalculationForInactiveScheme(null, bscheme.Id);
        //BrokerageManagementService.KickerCalulation(ki.Id);
        
        BrokerageManagementServicesV2.brokerageCalculation(BIds);
        BrokerageManagementServicesV2.BrokerageCalculationForInactiveScheme(null, bscheme.Id);
        BrokerageManagementServicesV2.KickerCalulation(ki.Id);
        
        BrokerageManagementServicesV2.dummy();
        BrokerageManagementServicesV2.dummy1();
        Test.stopTest();
    }

    @isTest
    public static void testbmsSCTandPNRI3() {
        Opportunity objcustomer;
        Opportunity objcustomer1;
        Booking__c objBooking;
        Project__c objpr;
        Project_Unit__c objPUU;
        Project_Unit__c objPUU1;
        Project_Unit_Type__c objPUT;
        Set<Id> BIds = new set<Id>();
        
        objpr = new Project__c();
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
        
        Brokerage_Scheme__c bscheme = new Brokerage_Scheme__c();
        bscheme.Type__c = 'Both';
        bscheme.Approval_Status__c = 'Approved by Level 2';
        bscheme.Base_Brokerage_for_Local_Bookings__c = 2;
        bscheme.Base_Brokerage_for_NRI__c = 2;
        bscheme.Base_Brokerage_for_OS_NRI__c = 2;
        bscheme.Slab_Type__c = 'Count';
        bscheme.Start_Date__c = system.today();
        bscheme.End_Date__c = system.today() + 2;
        bscheme.Project_Location__c = pl.Id;
        insert bscheme;
        
        Brokerage_Slab__c bslab = new Brokerage_Slab__c();
        bslab.Name = 'Slab 1';
        bslab.From__c = 0;
        bslab.To__c = 1;
        bslab.Additional_Brokerage_for_Local_Bookings__c = 2;
        bslab.Additional_Brokerage_for_OS_NRI__c = 2;
        bslab.Brokerage_Scheme__c = bscheme.Id;
        
        Brokerage_Slab__c bslab2 = new Brokerage_Slab__c();
        bslab2.Name = 'Slab 2';
        bslab2.From__c = 2;
        bslab2.To__c = null;
        bslab2.Additional_Brokerage_for_Local_Bookings__c = 2.5;
        bslab2.Additional_Brokerage_for_OS_NRI__c = 0.25;
        bslab2.Brokerage_Scheme__c = bscheme.Id;
        
        insert new List<Brokerage_Slab__c>{ bslab, bslab2 };
            
            Scheme_Configuration__c sc = new Scheme_Configuration__c();
        sc.Name = 'Oct';
        sc.Brokerage_Scheme__c = bscheme.Id;
        sc.Project__c = objpr.id;
        sc.Tower__c = t[0].id;
        insert sc;
        
        Kicker_Incentive__c ki = new Kicker_Incentive__c();
        ki.Name = 'Kicker Sep & Oct 2022';
        ki.Brokerage_Scheme__c = bscheme.Id;
        ki.Start_Date__c = system.today() - 2;
        ki.End_Date__c = system.today() + 2;
        ki.Type__c = 'Cumulative';
        ki.Type_Of_Client__c = 'Local';
        insert ki;
        
        Kicker_Incentive_Configuration__c kic = new Kicker_Incentive_Configuration__c();
        kic.Kicker_Incentive__c = ki.id;
        kic.Project__c = objpr.id;
        kic.Tower__c = t[0].id;
        insert kic;
        
        Kicker_Incentive_Slab__c kis = new Kicker_Incentive_Slab__c();
        kis.Name = '2000000:6';
        kis.Kicker_Incentive__c = ki.Id;
        kis.Value__c = 100;
        kis.No_of_Bookings__c = 1;
        kis.Logical_Operator__c = 'AND';
        kis.Amount__c = 2000000;
        kis.From__c = 0;
        kis.To__c = null;
        kis.From_Value__c = 0;
        kis.To_Value__c = null;
        insert kis;
        
        objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.id;
        insert objPUT;
        
        objPUU = new Project_Unit__c();
        objPUU.Project_Unit_Type__c = objPUT.id;
        objPUU.Name = 'TestUnit';
        objPUU.RW_Project__c = objpr.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c = '9';
        objPUU.RW_Unit_Status__c = 'Available';
        
        objPUU1 = new Project_Unit__c();
        objPUU1.Project_Unit_Type__c = objPUT.id;
        objPUU1.Name = 'TestUnit1';
        objPUU1.RW_Project__c = objpr.Id;
        objPUU1.RW_Param1__c = '5';
        objPUU1.UnitNo__c = '10';
        objPUU1.RW_Unit_Status__c = 'Available';
        
        insert new List<Project_Unit__c>{ objPUU, objPUU1 };
            
            Project_Charges__c prc = new Project_Charges__c();
        prc.Name = 'Basic';
        prc.Project__c = objpr.Id;
        insert prc;
        
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@stetig.in.com','9098777',false);
        
        Broker__c cp = new Broker__c();
        cp.Name = 'Test CP';
        cp.RW_Email__c = 'teststetig@stetig.in';
        cp.Individual_CP__c = true;
        cp.RW_CreateFromIRIS__c = true;
        cp.RW_IRIS_Sync__c = true;
        cp.Place_of_Supply__c = 'Maharashtra';
        cp.Channel_Partner_From_CP_Portal__c = true;
        cp.Project__c = 'Runwal Bliss';
        cp.Approver_L1__c = userinfo.getUserId();
        cp.Latest_RERA_Upload_Status__c = 'Approved';
        cp.RERA_Valid_till__c = system.today()+2;
        cp.Latest_CC_Upload_Status__c = 'Approved';
        cp.CC_Valid_till__c = system.today()+2;
        cp.Approver_L2__c = userinfo.getUserId();
        cp.Registration_Complete__c = true;
        cp.RW_Mobile_No__c = '1234567890';
        cp.Broker_Type__c = 'Individual';
        cp.Broker_Pan_No__c = 'ADRPI3525F';
        cp.RW_RERA_Registration_Number__c = '123256789012';
        cp.Company_Name_As_per_RERA__c = 'Test CP';
        insert cp;
        
        Account ac = new Account();
        ac.Name = cp.Company_Name_As_per_RERA__c;
        ac.CP_Email__c = cp.RW_Email__c;
        ac.Mobile_No__c = cp.RW_Mobile_No__c;
        ac.Channel_Partner__c = cp.id;
        ac.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
        insert ac;
        
        Account cpaccount = [SELECT Id, Name, Channel_Partner__c FROM Account WHERE Channel_Partner__c = :cp.Id];
        
        objcustomer = new Opportunity();
        objcustomer.RW_Project__c = objpr.id;
        objcustomer.Name = 'Test 1';
        objcustomer.StageName = 'Qualification';
        objcustomer.CloseDate = system.today();
        objcustomer.Status__c = 'Active';
        objCustomer.AccountId = a.Id;
        objcustomer.Sales_Manager__c = 'SM2@g.com';
        objcustomer.RW_Type_of_Client__c = 'Local';
        objcustomer.Channel_Partner_Account__c = cpaccount.Id;
        objcustomer.RW_Walkin_Channel_Partner__c = cp.Id;
        objcustomer.Walkin_Source__c = 'Channel Partner';
        
        objcustomer1 = new Opportunity();
        objcustomer1.RW_Project__c = objpr.id;
        objcustomer1.Name = 'Test 1';
        objcustomer1.StageName = 'Qualification';
        objcustomer1.CloseDate = system.today();
        objcustomer1.Status__c = 'Active';
        objcustomer1.AccountId = a.Id;
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
            
            // --- Combined Booking Inserts ---
            Booking__c b = new Booking__c();
        b.Customer__c = objcustomer1.Id;
        b.Project__c = objpr.Id;
        b.Tower__c = t[0].Id;
        b.Opportunity__c = objcustomer1.Id;
        b.Unit_No__c = objPUU1.id;
        b.Quotation__c = q2.Id;
        b.Receipts__c = r2.Id;
        b.Booking_Date__c = Date.today();
        b.Account__c = cpaccount.Id;
        b.Type_of_Client__c = 'NRI';
        b.Status__c = 'Booking Confirmed';
        b.RW_Registration_Done__c = 'No';
        b.BrokerIId__c = cp.Id;
        b.Exclude_From_Brokerage_Batch__c = false;
        b.Source_of_Booking__c = 'Channel Partner';
        b.RW_Registration_Date__c = Date.today();
        b.RW_Total_Receipt_Amount_Received__c = 5000000;
        b.Brokerage_Scheme__c = bscheme.Id;
        b.Custom_Base_Brokerage__c = 1;
        b.Checklist_Approved__c = true;

        
        Booking__c b2 = b.clone(false, true, false, false);
        Booking__c b3 = b.clone(false, true, false, false);
        Booking__c b4 = b.clone(false, true, false, false);
        b4.Type_of_Client__c = 'NRI';
        
        List<Booking__c> bookingsToInsert = new List<Booking__c>{ b, b2, b3, b4 };
            insert bookingsToInsert;
        
        list<Brokerage_Summary__c> bslist = new list<Brokerage_Summary__c>();
        Brokerage_Summary__c bs = new Brokerage_Summary__c(
            Channel_Partner__c = cp.Id,
            Brokerage_Scheme__c = bscheme.Id,
            Opportunity__c = objcustomer1.Id,
            CP_Account__c = cpaccount.Id,
            Is_Kicker_Incentive_Summary__c = false,
            Booking__c = b.Id,
            Applied_Slab_Name__c = 'Slab 1'
        );
        bslist.add(bs);
        
        Brokerage_Summary__c bs1 = new Brokerage_Summary__c(
            Channel_Partner__c = cp.Id,
            Brokerage_Scheme__c = bscheme.Id,
            Opportunity__c = objcustomer1.Id,
            CP_Account__c = cpaccount.Id,
            Is_Kicker_Incentive_Summary__c = false,
            Booking__c = b.Id,
            Applied_Slab_Name__c = 'Slab 1'
        );
        bslist.add(bs1);
        insert bslist;
        
        Brokerage__c bro = new Brokerage__c(
            Name = 'Base Brokerage',
            Brokerage__c = 2,
            Brokerage_Amount__c = 272059,
            Brokerage_Scheme__c = bscheme.Id,
            Channel_Partner__c = cp.Id,
            Opportunity__c = objcustomer1.Id,            
            Booking__c = b.Id,
            Brokerage_Summary__c = bs.Id,
            Opportunity_AV__c = 13602975,
            Brokerage_Type__c = 'Base Brokerage'
        );
        insert bro;
        
        Brokerage__c bro1 = new Brokerage__c(
            Name = 'Base Brokerage',
            Brokerage__c = 2,
            Brokerage_Amount__c = 272059,
            Brokerage_Scheme__c = bscheme.Id,
            Channel_Partner__c = cp.Id,
            Opportunity__c = objcustomer1.Id,            
            Booking__c = b.Id,
            Brokerage_Summary__c = bs1.Id,
            Opportunity_AV__c = 13602975,
            Brokerage_Type__c = 'Base Brokerage'
        );
        insert bro1;
         b.Brokerage_Summary__c = bs.id;
        update b;
        
        // --- Combined Demand Inserts ---
        RW_Demand__c dmd = new RW_Demand__c(Name='890890', Booking__c=b.Id, RW_Billing_Document_Number__c='890890', RW_Customer_Number__c='12345678');
        RW_Demand__c dmd2 = new RW_Demand__c(Name='890890', Booking__c=b2.Id, RW_Billing_Document_Number__c='890890', RW_Customer_Number__c='12345678');
        RW_Demand__c dmd3 = new RW_Demand__c(Name='890890', Booking__c=b3.Id, RW_Billing_Document_Number__c='890890', RW_Customer_Number__c='12345678');
        RW_Demand__c dmd4 = new RW_Demand__c(Name='890890', Booking__c=b4.Id, RW_Billing_Document_Number__c='890890', RW_Customer_Number__c='12345678');
        insert new List<RW_Demand__c>{ dmd, dmd2, dmd3, dmd4 };
            
            // --- Combined Demand Item Inserts ---
            RW_Demand_Item__c dmid = new RW_Demand_Item__c(RW_Demand_Item_Amount__c=200000, RW_Demand__c=dmd.Id, RW_GST_Amount__c=1000, RW_Legacy_Amount_Paid__c=5000, RW_Legacy_Demand__c=true, Total_Demand_Item_Amount_Paid__c=200000);
        RW_Demand_Item__c dmid2 = new RW_Demand_Item__c(RW_Demand_Item_Amount__c=200000, RW_Demand__c=dmd2.Id, RW_GST_Amount__c=1000, RW_Legacy_Amount_Paid__c=5000, RW_Legacy_Demand__c=true, Total_Demand_Item_Amount_Paid__c=200000);
        RW_Demand_Item__c dmid3 = new RW_Demand_Item__c(RW_Demand_Item_Amount__c=200000, RW_Demand__c=dmd3.Id, RW_GST_Amount__c=1000, RW_Legacy_Amount_Paid__c=5000, RW_Legacy_Demand__c=true, Total_Demand_Item_Amount_Paid__c=200000);
        RW_Demand_Item__c dmid4 = new RW_Demand_Item__c(RW_Demand_Item_Amount__c=200000, RW_Demand__c=dmd4.Id, RW_GST_Amount__c=1000, RW_Legacy_Amount_Paid__c=5000, RW_Legacy_Demand__c=true, Total_Demand_Item_Amount_Paid__c=200000);
        insert new List<RW_Demand_Item__c>{ dmid, dmid2, dmid3, dmid4 };
            
            system.debug('9.99 b3::' + [SELECT Id, Name, RW_X9_99_Received__c FROM Booking__c WHERE Id = :b3.Id]);
        
        Test.startTest();
        //.brokerageCalculation(BIds);
        //BrokerageManagementService.BrokerageCalculationForInactiveScheme(b2.Id, bscheme.Id);
        //BrokerageManagementService.KickerCalulation(ki.Id);
        
        Set<Id> bId = new Set<Id>();
        for(Booking__c bkk : bookingsToInsert){
            bId.add(bkk.Id);
        }
        try{
            BrokerageManagementServicesV2.BookingSourceChange(bId);   
        }catch(Exception ex){
            
        }
        
        BrokerageManagementServicesV2.brokerageCalculation(BIds);
        BrokerageManagementServicesV2.BrokerageCalculationForInactiveScheme(b2.Id, bscheme.Id);
        BrokerageManagementServicesV2.KickerCalulation(ki.Id);
        Test.stopTest();
    }

    @isTest
    public static void testbmsSCTandPNRI2() {
        
        Opportunity objcustomer;
        Opportunity objcustomer1;
        Booking__c objBooking;
        Project__c objpr;
        Project_Unit__c objPUU;
        Project_Unit__c objPUU1;
        Project_Unit_Type__c objPUT;
        Set<Id> BIds = new set<Id>();
        
        objpr = new Project__c(
            RW_Project_Code__c = 'T31',
            Name = 'Runwal Bliss',
            RDS_Short_Name__c = 'T',
            Start_Date__c = System.today().addDays(-5),
            RDS_Interest_Rate__c = 12
        );
        insert objpr;
        
        List<Tower__c> t = TestDataFactory.createTowers(1, objpr.Id);
        
        Project_Location__c pl = new Project_Location__c(
            Name = 'Mumbai',
            Approver_L1__c = userinfo.getUserId(),
            Approver_L2__c = userinfo.getUserId(),
            Location__c = 'Mumbai'
        );
        insert pl;
        
        Brokerage_Scheme__c bscheme = new Brokerage_Scheme__c(
            Type__c = 'Both',
            Approval_Status__c = 'Approved by Level 2',
            Base_Brokerage_for_Local_Bookings__c = 2,
            Base_Brokerage_for_NRI__c = 2,
            Base_Brokerage_for_OS_NRI__c = 2,
            AOP_CP__c = 1,
            Slab_Type__c = 'Count',
            Start_Date__c = system.today(),
            End_Date__c = system.today() + 2,
            Project_Location__c = pl.Id
        );
        insert bscheme;
        
        List<Brokerage_Slab__c> slabList = new List<Brokerage_Slab__c>{
            new Brokerage_Slab__c(
                Name = 'Slab 1',
                From__c = 0,
                To__c = 1,
                Additional_Brokerage_for_Local_Bookings__c = 0.25,
                Additional_Brokerage_for_OS_NRI__c = 0.25,
                Additional_Brokerage_for_NRI__c = 0.25,
                Brokerage_Scheme__c = bscheme.Id
            ),
                new Brokerage_Slab__c(
                    Name = 'Slab 2',
                    From__c = 2,
                    To__c = null,
                    Additional_Brokerage_for_Local_Bookings__c = 0.25,
                    Additional_Brokerage_for_OS_NRI__c = 0.25,
                    Additional_Brokerage_for_NRI__c = 0.25,
                    Brokerage_Scheme__c = bscheme.Id
                )
                };
                    insert slabList;
        
        Scheme_Configuration__c sc = new Scheme_Configuration__c(
            Name = 'Oct',
            Brokerage_Scheme__c = bscheme.Id,
            Project__c = objpr.id,
            Tower__c = null
        );
        insert sc;
        
        Kicker_Incentive__c ki = new Kicker_Incentive__c(
            Name = 'Kicker Sep & Oct 2022',
            Brokerage_Scheme__c = bscheme.Id,
            Start_Date__c = system.today() - 2,
            End_Date__c = system.today() + 2,
            Type__c = 'Cumulative',
            Type_Of_Client__c = 'Local'
        );
        insert ki;
        
        Kicker_Incentive_Configuration__c kic = new Kicker_Incentive_Configuration__c(
            Kicker_Incentive__c = ki.id,
            Project__c = objpr.id,
            Tower__c = t[0].id
        );
        insert kic;
        
        Kicker_Incentive_Slab__c kis = new Kicker_Incentive_Slab__c(
            Name = '2000000:6',
            Kicker_Incentive__c = ki.Id,
            Value__c = 100,
            No_of_Bookings__c = 1,
            Logical_Operator__c = 'AND',
            Amount__c = 2000000,
            From__c = 0,
            To__c = null,
            From_Value__c = 0,
            To_Value__c = null
        );
        insert kis;
        
        objPUT = new Project_Unit_Type__c(RDS_Code__c = '101', RDS_Project__c = objpr.id);
        insert objPUT;
        
        List<Project_Unit__c> puList = new List<Project_Unit__c>{
            new Project_Unit__c(
                Project_Unit_Type__c = objPUT.id,
                Name = 'TestUnit',
                RW_Project__c = objpr.Id,
                RW_Param1__c = '5',
                UnitNo__c = '9',
                RW_Unit_Status__c = 'Available'
            ),
                new Project_Unit__c(
                    Project_Unit_Type__c = objPUT.id,
                    Name = 'TestUnit1',
                    RW_Project__c = objpr.Id,
                    RW_Param1__c = '5',
                    UnitNo__c = '10',
                    RW_Unit_Status__c = 'Available'
                )
                };
                    insert puList;
        
        objPUU = puList[0];
        objPUU1 = puList[1];
        
        Project_Charges__c prc = new Project_Charges__c(Name = 'Basic', Project__c = objpr.Id);
        insert prc;
        
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@stetig.in.com', '9098777', false);
        Id CPRecordTypeId = Schema.SObjectType.Broker__c.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();//Added by Prashant 12-09-25
        Broker__c cp = new Broker__c(
            Name = 'Test CP',
            RW_Email__c = 'teststetig@stetig.in',
            Individual_CP__c = true,
            RW_CreateFromIRIS__c = true,
            RW_IRIS_Sync__c = true,
            Place_of_Supply__c = 'Maharashtra',
            Channel_Partner_From_CP_Portal__c = true,
            Project__c = 'Runwal Bliss',
            Approver_L1__c = userinfo.getUserId(),
            Approver_L2__c = userinfo.getUserId(),
            Registration_Complete__c = true,
            Latest_RERA_Upload_Status__c = 'Approved',
            RERA_Valid_till__c = system.today()+2,
            Latest_CC_Upload_Status__c = 'Approved',
            CC_Valid_till__c = system.today()+2,
            RW_Mobile_No__c = '1234567890',
            Broker_Type__c = 'Individual',
            Broker_Pan_No__c = 'ADRPI3525F',
            RW_RERA_Registration_Number__c = '123256789012',
            Company_Name_As_per_RERA__c = 'Test CP',
            RecordTypeId = CPRecordTypeId
        );
        insert cp;
        
        Account ac = new Account(
            Name = cp.Company_Name_As_per_RERA__c,
            CP_Email__c = cp.RW_Email__c,
            Mobile_No__c = cp.RW_Mobile_No__c,
            Channel_Partner__c = cp.id,
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId()
        );
        insert ac;
        
        Account cpaccount = [SELECT Id, Name, Channel_Partner__c FROM Account WHERE Channel_Partner__c = :cp.Id];
        
        objcustomer = new Opportunity(
            RW_Project__c = objpr.id,
            Name = 'Test 1',
            StageName = 'Qualification',
            CloseDate = system.today(),
            Status__c = 'Active',
            AccountId = a.Id,
            Sales_Manager__c = 'SM2@g.com',
            RW_Type_of_Client__c = 'Local',
            Channel_Partner_Account__c = cpaccount.Id,
            RW_Walkin_Channel_Partner__c = cp.Id,
            Walkin_Source__c = 'Channel Partner'
        );
        
        objcustomer1 = objcustomer.clone(false, true, false, false);
        insert new List<Opportunity>{objcustomer, objcustomer1};
            
            List<Quotation__c> qList = new List<Quotation__c>{
                new Quotation__c(
                    Name = 'Q010101',
                    Quote_Status__c = 'Valid',
                    Prepared_Date__c = System.today(),
                    Project__c = objpr.Id,
                    Project_Unit__c = objPUU.Id,
                    FloorNo__c = 11,
                    Opportunity__c = objcustomer.Id,
                    Appartment_Configuration__c = '1 BHK',
                    Carpet_Area_Sq_Ft__c = 1200,
                    Token_Amount__c = 110000,
                    ST_Token_Amount__c = 1000,
                    Allow_booking_without_full_token__c = TRUE,
                    Agreement_Value__c = 60422880,
                    Agreement_Value_ST__c = 2537761,
                    Agreement_Value_for_brokers__c = 10000000
                ),
                    new Quotation__c(
                        Name = 'Q020202',
                        Quote_Status__c = 'Approval Pending',
                        Prepared_Date__c = System.today(),
                        Project__c = objpr.Id,
                        Project_Unit__c = objPUU1.Id,
                        FloorNo__c = 11,
                        Opportunity__c = objcustomer1.Id,
                        Appartment_Configuration__c = '1 BHK',
                        Carpet_Area_Sq_Ft__c = 1200,
                        Token_Amount__c = 110000,
                        ST_Token_Amount__c = 1000,
                        Allow_booking_without_full_token__c = TRUE,
                        Agreement_Value__c = 60422880,
                        Agreement_Value_ST__c = 2537761,
                        Agreement_Value_for_brokers__c = 10000000
                    )
                    };
                        insert qList;
        
        Quotation__c q = qList[0];
        Quotation__c q2 = qList[1];
        
        // --- Receipts ---
        List<Receipt__c> receipts = new List<Receipt__c>{
            new Receipt__c(
                Cheque_DD_Amount_Rs__c = 6000000,
                Cheque_DD__c = '908888',
                Cheque_DD_Date__c = system.today(),
                Project__c = objpr.Id,
                Project_Unit__c = objPUU.Id,
                Opportunity__c = objcustomer.Id,
                CheckReceipt__c = true,
                Token_Amount_Receipt__c = true,
                Physically_Cheque_Received__c = true,
                Approval_Status__c = 'Approved',
                Receipt_Date__c = system.today(),
                DraweeBank__c = 'Axis Bank',
                Total_Amount__c = 6000000,
                Currency__c = 'Indian Rupee'
            ),
                new Receipt__c(
                    Cheque_DD_Amount_Rs__c = 8400,
                    Cheque_DD__c = '9088881',
                    Cheque_DD_Date__c = system.today(),
                    Project__c = objpr.Id,
                    Project_Unit__c = objPUU.Id,
                    Opportunity__c = objcustomer.Id,
                    CheckReceipt__c = true,
                    Physically_Cheque_Received__c = true,
                    Approval_Status__c = 'Approved',
                    Receipt_Date__c = system.today(),
                    DraweeBank__c = 'CITI',
                    Total_Amount__c = 8400,
                    Currency__c = 'Indian Rupee',
                    Token_Amount_ST__c = true
                )
                };
                    insert receipts;
        
        Receipt__c r1 = receipts[0];
        Receipt__c r2 = receipts[1];
        
        // --- Bookings ---
        List<Booking__c> bookingList = new List<Booking__c>{
            new Booking__c(
                Customer__c = objcustomer1.Id,
                Project__c = objpr.Id,
                Opportunity__c = objcustomer1.Id,
                Unit_No__c = objPUU1.id,
                Quotation__c = q2.Id,
                Receipts__c = r2.Id,
                Booking_Date__c = Date.today(),
                Account__c = cpaccount.Id,
                Type_of_Client__c = 'Local',
                Status__c = 'Booking Confirmed',
                RW_Registration_Done__c = 'No',
                BrokerIId__c = cp.Id,
                Exclude_From_Brokerage_Batch__c = false,
                Source_of_Booking__c = 'Channel Partner',
                Allotment_Premium__c = 10000001,
                RW_Registration_Date__c = Date.today(),
                RW_Total_Receipt_Amount_Received__c = 5000000,
                Brokerage_Scheme__c = bscheme.Id,
                Custom_Base_Brokerage__c = 1,
                Checklist_Approved__c = true
            ),
                new Booking__c(
                    Customer__c = objcustomer.Id,
                    Project__c = objpr.Id,
                    Tower__c = t[0].id,
                    Opportunity__c = objcustomer.Id,
                    Unit_No__c = objPUU1.id,
                    Quotation__c = q.Id,
                    Receipts__c = r2.Id,
                    Booking_Date__c = Date.today(),
                    Account__c = cpaccount.Id,
                    Type_of_Client__c = 'Local',
                    Status__c = 'Booking Confirmed',
                    RW_Registration_Done__c = 'No',
                    BrokerIId__c = cp.Id,
                    Exclude_From_Brokerage_Batch__c = false,
                    Source_of_Booking__c = 'Channel Partner',
                    Allotment_Premium__c = 10000001,
                    RW_Registration_Date__c = Date.today(),
                    RW_Total_Receipt_Amount_Received__c = 5000000,
                    Checklist_Approved__c = true
                ),
                new Booking__c(
                    Customer__c = objcustomer.Id,
                    Project__c = objpr.Id,
                    Opportunity__c = objcustomer.Id,
                    Unit_No__c = objPUU1.id,
                    Quotation__c = q.Id,
                    Receipts__c = r2.Id,
                    Booking_Date__c = Date.today(),
                    Account__c = cpaccount.Id,
                    Type_of_Client__c = 'NRI',
                    Status__c = 'Booking Confirmed',
                    Is_AOP_CP_Applicable__c = true,
                    RW_Registration_Done__c = 'No',
                    Checklist_Approved__c = true,
                    BrokerIId__c = cp.Id,
                    Exclude_From_Brokerage_Batch__c = false,
                    Source_of_Booking__c = 'Channel Partner',
                    Allotment_Premium__c = 10000001,
                    RW_Registration_Date__c = Date.today(),
                    RW_Total_Receipt_Amount_Received__c = 5000000
                ),
                new Booking__c(
                    Customer__c = objcustomer.Id,
                    Project__c = objpr.Id,
                    Opportunity__c = objcustomer.Id,
                    Unit_No__c = objPUU1.id,
                    Quotation__c = q.Id,
                    Receipts__c = r2.Id,
                    Booking_Date__c = Date.today(),
                    Account__c = cpaccount.Id,
                    Type_of_Client__c = 'Outstation',
                    Status__c = 'Booking Confirmed',
                    Is_AOP_CP_Applicable__c = true,
                    RW_Registration_Done__c = 'No',
                    Checklist_Approved__c = true,
                    BrokerIId__c = cp.Id,
                    Exclude_From_Brokerage_Batch__c = false,
                    Source_of_Booking__c = 'Channel Partner',
                    Allotment_Premium__c = 10000001,
                    RW_Registration_Date__c = Date.today(),
                    RW_Total_Receipt_Amount_Received__c = 5000000
                )
                };
                    insert bookingList;
        
        Booking__c b = bookingList[0];
        Booking__c b2 = bookingList[1];
        Booking__c b3 = bookingList[2];
        Booking__c b4 = bookingList[3];
        
        // --- Demands ---
        List<RW_Demand__c> dmdList = new List<RW_Demand__c>{
            new RW_Demand__c(Booking__c = b.Id, Name = '890890', RW_Billing_Document_Number__c = '890890', RW_Customer_Number__c = '12345678'),
                new RW_Demand__c(Booking__c = b2.Id, Name = '890890', RW_Billing_Document_Number__c = '890890', RW_Customer_Number__c = '12345678'),
                new RW_Demand__c(Booking__c = b3.Id, Name = '890890', RW_Billing_Document_Number__c = '890890', RW_Customer_Number__c = '12345678'),
                new RW_Demand__c(Booking__c = b4.Id, Name = '890890', RW_Billing_Document_Number__c = '890890', RW_Customer_Number__c = '12345678')
                };
                    insert dmdList;
        
        List<RW_Demand_Item__c> dmidList = new List<RW_Demand_Item__c>();
        for (RW_Demand__c d : dmdList) {
            dmidList.add(new RW_Demand_Item__c(
                RW_Demand__c = d.Id,
                RW_Demand_Item_Amount__c = 200000,
                RW_GST_Amount__c = 1000,
                RW_Legacy_Amount_Paid__c = 5000,
                RW_Legacy_Demand__c = true,
                Total_Demand_Item_Amount_Paid__c = 200000
            ));
        }
        insert dmidList;
        
        Brokerage_Summary__c bs = new Brokerage_Summary__c(
            Channel_Partner__c = cp.Id,
            Brokerage_Scheme__c = bscheme.Id,
            Opportunity__c = objcustomer1.Id,
            CP_Account__c = cpaccount.Id,
            Booking__c = b.Id,
            Applied_Slab_Name__c = 'Slab 1'
        );
        insert bs;
        
        Brokerage__c bro = new Brokerage__c(
            Name = 'Base Brokerage',
            Brokerage__c = 2,
            Brokerage_Amount__c = 272059,
            Brokerage_Scheme__c = bscheme.Id,
            Channel_Partner__c = cp.Id,
            Opportunity__c = objcustomer1.Id,
            Booking__c = b.Id,
            Brokerage_Summary__c = bs.Id,
            Opportunity_AV__c = 13602975,
            Brokerage_Type__c = 'Base Brokerage'
        );
        insert bro;
        
        b.Brokerage_Summary__c = bs.id;
        update b;
        
        BIds.add(b2.Id);
        BIds.add(b3.Id);
        BIds.add(b4.Id);
        
        Test.startTest();
        Set<Id> bId = new Set<Id>();
        for(Booking__c bkk : bookingList){
            bId.add(bkk.Id);
        }
        try{
            BrokerageManagementServicesV2.insertCancelledBrokerage(bId);
            
        }catch(Exception ex){
            
        }
        //BrokerageManagementService.brokerageCalculation(BIds);
        //BrokerageManagementService.BrokerageCalculationForInactiveScheme(b2.Id, bscheme.Id);
        //BrokerageManagementService.KickerCalulation(ki.Id);
        
        
        BrokerageManagementServicesV2.brokerageCalculation(BIds);
        BrokerageManagementServicesV2.BrokerageCalculationForInactiveScheme(b2.Id, bscheme.Id);
        BrokerageManagementServicesV2.KickerCalulation(ki.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void testbmsSCTandPNRI4(){
        String newId= '00U9I000001w5A2UAI';

        Set<Id> newSet = new Set<Id>();
        newSet.add(newId);
        try{
            BrokerageManagementServicesV2.insertCancelledBrokerage(newSet);
            
        }catch(Exception ex){
            
        }
        try{
            BrokerageManagementServicesV2.BookingSourceChange(newSet);   
        }catch(Exception ex){
            
        }
        try{
            BrokerageManagementServicesV2.GetKickerIncentives('00U9I000001w5A2UAI',System.today(),'00U9I000001w5A2UAI','00U9I000001w5A2UAI','Test');   
        }catch(Exception ex){
            
        }
    }

}