@IsTest
Public class BillDeskServiceTest {

    // ======================================================
    // 🔹 MOCK FOR BOTH CALLOUTS
    // ======================================================
    private class MultiCalloutMock implements HttpCalloutMock {

    public HTTPResponse respond(HTTPRequest req) {

        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setHeader('Content-Type','application/jose');

        if(req.getEndpoint().contains('ecomorders')){

            // FIRST API
            String ecomJson = JSON.serialize(new Map<String,Object>{
                'ecom_orderid' => 'ECOM123'
            });

            String header = EncodingUtil.base64Encode(Blob.valueOf('{"alg":"HS256"}'));
            String body   = EncodingUtil.base64Encode(Blob.valueOf(ecomJson));

            res.setBody(header + '.' + body + '.signature');
            return res;

        }
        else if(req.getEndpoint().contains('payments') || 
                req.getEndpoint().contains('orders') ||
                req.getEndpoint().contains('Billdesk')){

            // SECOND API
            String orderJson = JSON.serialize(new Map<String,Object>{
                'objectid' => 'order',
                'orderid' => 'ECOM123',
                'bdorderid' => 'BD123',
                'mercid' => 'RNLSPLTUAT',
                'order_date' => '2026-03-03T10:00:00+05:30',
                'amount' => '100.00',
                'ru' => 'https://example.com',
                'itemcode' => 'DIRECT',
                'createdon' => '2026-03-03',
                'next_step' => 'redirect',
                'additional_info' => new Map<String,Object>{
                    'additional_info1' => 'A1',
                    'additional_info2' => 'A2',
                    'additional_info3' => 'A3',
                    'additional_info4' => 'A4',
                    'additional_info5' => 'A5',
                    'additional_info6' => 'A6',
                    'additional_info7' => 'A7'
                },
                'links' => new List<Object>{
                    new Map<String,Object>{
                        'href' => 'self',
                        'rel' => 'self',
                        'method' => 'GET'
                    },
                    new Map<String,Object>{
                        'href' => 'redirect',
                        'rel' => 'redirect',
                        'method' => 'POST',
                        'parameters' => new Map<String,Object>{
                            'mercid' => 'RNLSPLTUAT',
                            'bdorderid' => 'BD123',
                            'rdata' => 'rdataValue'
                        },
                        'valid_date' => '2026-03-03',
                        'headers' => new Map<String,Object>{
                            'authorization' => 'Bearer token'
                        }
                    }
                }
            });

            String header = EncodingUtil.base64Encode(Blob.valueOf('{"alg":"HS256"}'));
            String body   = EncodingUtil.base64Encode(Blob.valueOf(orderJson));

            res.setBody(header + '.' + body + '.signature');
            return res;
        }

        // DEFAULT FALLBACK
        res.setBody('{"status":"mock-default"}');
        return res;
    }
}

    // ======================================================
    // 🔹 MAIN SUCCESS TEST
    // ======================================================
    @IsTest
    static void testCreateOrderRawSuccess() {

          // Create Project + Tower (minimal structure)
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
        
        Tower__c tower = new Tower__c();
        tower.Name='G';
        tower.ProjectName__c=objpr.id;
        insert tower;
        
        objPUU = new Project_Unit__c();  
        objPUU.Project_Unit_Type__c = objPUT.id;  
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c = objpr.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.TowerName__c=tower.id;
        objPUU.RW_Unit_Status__c ='Available';
        insert objPUU;
        
        objPUU1 = new Project_Unit__c();  
        objPUU1.Project_Unit_Type__c = objPUT.id;  
        objPUU1.Name = 'TestUnit1';      
        objPUU1.RW_Project__c = objpr.Id;
        objPUU1.RW_Param1__c = '5';
        objPUU1.UnitNo__c ='10';
        objPUU1.TowerName__c=tower.id;
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
        b.GST_Percent__c=18;
        insert b;
        
        Payment_Gateway__mdt gateway = [
            SELECT Bill_Desk_Merchant_ID__c, Bill_Desk_GST_Merchant_ID__c,Parent_Merchant_Id__c,Client_Id__c,Secret_Key__c
            FROM Payment_Gateway__mdt
            WHERE Project_Name__c = 'Runwal Bliss'
            AND Project_Tower__c = 'G'
            LIMIT 1
        ];
        
        // Prepare request
        Lockated_paymentApi.LockatedRequest req =
            new Lockated_paymentApi.LockatedRequest();
        req.bookingId = b.Id;
        req.totalAmount = 100;
        req.paymentType = 'PRINCIPAL_GST';

        Test.setMock(HttpCalloutMock.class, new MultiCalloutMock());

        Test.startTest();
        String response = BillDeskService.createOrderRaw(req);
        Test.stopTest();


    }

    // ======================================================
    // 🔹 INVALID PAYMENT TYPE (CATCH BLOCK)
    // ======================================================
    @IsTest
    static void testInvalidPaymentType() {

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
        b.GST_Percent__c=18;
        insert b;

        Lockated_paymentApi.LockatedRequest req =
            new Lockated_paymentApi.LockatedRequest();
        req.bookingId = b.Id;
        req.totalAmount = 100;
        req.paymentType = 'GST_ONLY';

        Test.startTest();
        String response = BillDeskService.createOrderRaw(req);
        Test.stopTest();
    }
     @IsTest
    static void testCreateSplitMerchant() {

        Map<String,Object> result =
            BillDeskService.createSplitMerchant('MER1', 100, 'BOOK1');

    }
    @IsTest
static void testDecodeBillDeskResponse() {

    String json = '{"status":"success"}';

    String header = EncodingUtil.base64Encode(Blob.valueOf('{"alg":"HS256"}'));
    String body   = EncodingUtil.base64Encode(Blob.valueOf(json));

    String jose = header + '.' + body + '.signature';

}
    @IsTest
static void testDecodeBase64Url() {

    String original = 'HelloWorld';

    String encoded = EncodingUtil.base64Encode(Blob.valueOf(original));
    encoded = encoded.replace('+','-').replace('/','_').replace('=','');

    String decoded = BillDeskService.decodeBase64Url(encoded);

}
    @IsTest
static void testBase64UrlEncode() {

    Blob input = Blob.valueOf('Test123');

    String encoded = BillDeskService.base64URLencode(input);

}
    @isTest
    static void testGenerateJoseToken() {

        String body = '{"sample":"value"}';
         Payment_Gateway__mdt gateway =
        [SELECT Bill_Desk_Merchant_ID__c, Bill_Desk_GST_Merchant_ID__c,Parent_Merchant_Id__c,Client_Id__c,Secret_Key__c
         FROM Payment_Gateway__mdt where DeveloperName='Runwal_Bliss_Tower_1Test'
         LIMIT 1];

        String jwt = BillDeskService.generateJoseToken(body, gateway);

    }
    @IsTest 
    static void testDecodeSuccess() {

        String json = '{"status":"success"}';

        String header = EncodingUtil.base64Encode(
            Blob.valueOf('{"alg":"HS256"}'));
        String body = EncodingUtil.base64Encode(
            Blob.valueOf(json));

        String jose = header + '.' + body + '.signature';

        String decoded =
            BillDeskService.decodeBillDeskResponse(jose);

    }
    @IsTest
    static void testBuildExactBilldeskResponse() {

        // Prepare nested objects
        BilldeskLockatedOrderAPI.AdditionaInfo addInfo =
            new BilldeskLockatedOrderAPI.AdditionaInfo();
        addInfo.additional_info1 = 'A1';
        addInfo.additional_info2 = 'A2';
        addInfo.additional_info3 = 'A3';
        addInfo.additional_info4 = 'A4';
        addInfo.additional_info5 = 'A5';
        addInfo.additional_info6 = 'A6';
        addInfo.additional_info7 = 'A7';

        BilldeskLockatedOrderAPI.Link_Parameters params =
            new BilldeskLockatedOrderAPI.Link_Parameters();
        params.mercid = 'MER1';
        params.bdorderid = 'BD1';
        params.rdata = 'RDATA1';

        BilldeskLockatedOrderAPI.Link_Headers headers =
            new BilldeskLockatedOrderAPI.Link_Headers();
        headers.authorization = 'Bearer token';

        BilldeskLockatedOrderAPI.Link link1 =
            new BilldeskLockatedOrderAPI.Link();
        link1.href = 'self';
        link1.rel = 'self';
        link1.method = 'GET';

        BilldeskLockatedOrderAPI.Link link2 =
            new BilldeskLockatedOrderAPI.Link();
        link2.href = 'redirect';
        link2.rel = 'redirect';
        link2.method = 'POST';
        link2.parameters = params;
        link2.valid_date = '2026-03-03';
        link2.headers = headers;

        BilldeskLockatedOrderAPI.ResponseBody resp =
            new BilldeskLockatedOrderAPI.ResponseBody();
        resp.objectid = 'order';
        resp.orderid = 'ORD1';
        resp.bdorderid = 'BD1';
        resp.mercid = 'MER1';
        resp.order_date = '2026-03-03';
        resp.amount = '100.00';
        resp.ru = 'https://return.url';
        resp.additional_info = addInfo;
        resp.itemcode = 'DIRECT';
        resp.createdon = '2026-03-03';
        resp.next_step = 'redirect';
        resp.links = new List<BilldeskLockatedOrderAPI.Link>{link1, link2};

        String result =
            BillDeskService.buildExactBilldeskResponse(resp);
    }
    @IsTest
    static void testCreatePaymentRecord_Success() {

        // Create minimal booking (optional)
        Booking__c booking = new Booking__c(GST_Percent__c=18);
        insert booking;
        Payment_Gateway__mdt gateway =
        [SELECT Bill_Desk_Merchant_ID__c, Bill_Desk_GST_Merchant_ID__c,Parent_Merchant_Id__c,Client_Id__c,Secret_Key__c
         FROM Payment_Gateway__mdt where DeveloperName='Runwal_Bliss_Tower_1Test'
         LIMIT 1];

        Test.startTest();
        BillDeskService.createPaymentRecord(
            'ORD100',
            'BD100',
            booking.Id,
            'MER1',
            500,
            'RDATA1',
            'https://pay.url',
            'PRINCIPAL_GST',
            400,
            100,
            gateway
        );
        Test.stopTest();
    }
    
}