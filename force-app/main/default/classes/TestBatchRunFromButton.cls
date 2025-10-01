@isTest
public class TestBatchRunFromButton {
	@isTest
    public static void runBatch(){
        BatchRunFromButton run = new BatchRunFromButton();
        run.BatchRun();
        run.BatchRunCancellation();
        run.BatchRunInactiveScheme();
        run.BatchRunLadderBrokerage();
        run.BatchRunLadderBrokerageListView();
        run.Home();
        
       
        
        PageReference Inactive = Page.BatchRunForInactiveBrokerageScheme;
        Test.setCurrentPage(Inactive);
        BatchRunFromButton run2 = new BatchRunFromButton();
        run2.Startdatename = Date.today();
        run2.Enddatename = Date.today();
        run2.BatchRunInactiveScheme();
        
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
        bscheme.Base_Brokerage_for_OS_NRI__c = 3;
        bscheme.Slab_Type__c = 'Count';
        bscheme.Start_Date__c = system.today();
        bscheme.End_Date__c = system.today()+2;
        bscheme.Project_Location__c = pl.Id;
        insert bscheme;
        
        Brokerage_Slab__c bslab = new Brokerage_Slab__c();
        bslab.Name = 'Slab 3';
        bslab.From__c = 0;
        bslab.To__c = 1;
        bslab.Additional_Brokerage_for_Local_Bookings__c = 0;
        bslab.Additional_Brokerage_for_OS_NRI__c = 0;
        bslab.Brokerage_Scheme__c = bscheme.Id;
        insert bslab;
        
        Brokerage_Slab__c bslab2 = new Brokerage_Slab__c();
        bslab2.Name = 'Slab 3';
        bslab2.From__c = 2;
        bslab2.To__c = null;
        bslab2.Additional_Brokerage_for_Local_Bookings__c = 0.25;
        bslab2.Additional_Brokerage_for_OS_NRI__c = 0.25;
        bslab2.Brokerage_Scheme__c = bscheme.Id;
        insert bslab2;
        
        Scheme_Configuration__c sc = new Scheme_Configuration__c();
        sc.Name = 'Oct';
        sc.Brokerage_Scheme__c = bscheme.Id;
        sc.Project__c = objpr.id;
        insert sc;
          
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
        
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@stetig.in.com','9098777',false);
        List<Tower__c> t = TestDataFactory.createTowers(1,objpr.Id);
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
        cp.RW_Mobile_No__c = '1234567890';
        cp.Broker_Type__c = 'Individual';
        cp.Broker_Pan_No__c = 'ADRPI3525F';
        cp.RW_RERA_Registration_Number__c = '123256789012';
        cp.RW_Mobile_No__c = '1234567890';
        insert cp;
        
        Account cpaccount = [Select Id,Name,Channel_Partner__c from Account where Channel_Partner__c =: cp.Id];
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
        
        objcustomer1= new Opportunity();
        objcustomer1.RW_Project__c=objpr.id;
        objcustomer1.name='Test 1';
        objcustomer1.StageName='Qualification';
        //objcustomer1.RW_Project_Unit__c=objPUU1.id;  
        objcustomer1.CloseDate=system.today();
        objcustomer1.Status__c ='Active';
        objcustomer1.AccountId = a.Id;
        objcustomer.RW_Type_of_Client__c = 'Local';
        objcustomer.Channel_Partner_Account__c = cpaccount.Id;
        objcustomer.RW_Walkin_Channel_Partner__c =  cp.Id;
        objcustomer.Walkin_Source__c = 'Channel Partner';
        //objcustomer1.Duplicate_Project_Unit_Request__c = false;
        //objcustomer1.Release_Unit__c = false;
        insert objcustomer1;
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
        q.Agreement_Value_for_brokers__c = 16595900;
        insert q;
        
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
        q2.Agreement_Value_for_brokers__c = 16595900;

        //q2.Service_Tax_On_Token_Amount__c = true;
        insert q2;
        
        Receipt__c r1 = new Receipt__c();
        r1.Cheque_DD_Amount_Rs__c = 200000;
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
        r1.Total_Amount__c = 200000;
        r1.Currency__c = 'Indian Rupee';
        insert r1;
        
        Receipt__c r2 = new Receipt__c();
        r2.Cheque_DD_Amount_Rs__c = 8400;
        r2.Cheque_DD__c = '9088881';
        r2.Cheque_DD_Date__c = system.today();
        r2.Project__c = objpr.Id;
        r2.Project_Unit__c = objPUU.Id;
        r2.Opportunity__c = objcustomer.Id;
        r2.CheckReceipt__c = true;
        r2.Physically_Cheque_Received__c = true;
        r2.Approval_Status__c = 'Approved';
        r2.Receipt_Date__c = system.today();
        r2.DraweeBank__c = 'CITI';
        r2.Total_Amount__c = 8400;
        r1.Currency__c = 'Indian Rupee';
        r2.Token_Amount_ST__c = true;
        insert r2;
        
        Booking__c b = new Booking__c();
        b.Customer__c = objcustomer.Id;
        b.Project__c = objpr.Id;
        b.Opportunity__c = objcustomer.Id;
        b.Unit_No__c = objPUU.id;
        b.Quotation__c = q.Id;
        b.Receipts__c = r1.Id;
        b.Booking_Date__c = Date.today();
        b.Account__c = cpaccount.Id;
        b.Type_of_Client__c = 'Local';
        //b.Tower__c = t[0].Id;
        b.Status__c = 'Booking Confirmed';
        b.RW_Registration_Done__c = 'No';
        b.BrokerIId__c = cp.Id;
        b.Exclude_From_Brokerage_Batch__c = false;
        b.Brokerage_Scheme__c = null;
        b.Source_of_Booking__c = 'Channel Partner';
        b.RW_Registration_Date__c = Date.today();
        b.Allotment_Premium__c = 10000000;
        b.RW_Total_Receipt_Amount_Received__c = 5000000;
        b.Custom_Base_Brokerage__c = 4;
        insert b;
        BIds.add(b.Id);
        
        RW_Demand__c dmd = new RW_Demand__c();
        dmd.Booking__c =b.id;
        dmd.name= '890890';
        dmd.RW_Billing_Document_Number__c = '890890';
        dmd.RW_Customer_Number__c = '12345678';
        insert dmd;
        
        RW_Demand_Item__c dmid= new RW_Demand_Item__c();
        dmid.RW_Demand_Item_Amount__c =200000;
        dmid.RW_Demand__c = dmd.id;
        dmid.RW_GST_Amount__c = 1000;
        dmid.RW_Legacy_Amount_Paid__c = 5000;
        dmid.RW_Legacy_Demand__c = true;
        dmid.Total_Demand_Item_Amount_Paid__c = 200000;
        insert dmid;
        
       /* Booking__c b2 = new Booking__c();
        b2.Customer__c = objcustomer1.Id;
        b2.Project__c = objpr.Id;
        b2.Opportunity__c = objcustomer1.Id;
        b2.Unit_No__c = objPUU1.id;
        b2.Quotation__c = q2.Id;
        b2.Receipts__c = r2.Id;
        b2.Booking_Date__c = Date.today();
        b2.Account__c = cpaccount.Id;
        b2.Type_of_Client__c = 'Local';
        //b2.Tower__c = t[0].Id;
        b2.Status__c = 'Booking Confirmed';
        b2.RW_Registration_Done__c = 'No';
        b2.BrokerIId__c = cp.Id;
        b2.Exclude_From_Brokerage_Batch__c = false;
        b2.Brokerage_Scheme__c = null;
        b2.Source_of_Booking__c = 'Channel Partner';
        b2.RW_Registration_Date__c = Date.today();
        b2.Allotment_Premium__c = 10000000;
        b2.RW_Total_Receipt_Amount_Received__c = 5000000;
        insert b2; */
        //BIds.add(b2.Id);
        
        RW_Demand__c dmd2 = new RW_Demand__c();
        dmd2.Booking__c =b.id;
        dmd2.name= '890890';
        dmd2.RW_Billing_Document_Number__c = '890890';
        dmd2.RW_Customer_Number__c = '12345678';
        insert dmd2;
        
        RW_Demand_Item__c dmid2= new RW_Demand_Item__c();
        dmid2.RW_Demand_Item_Amount__c =200000;
        dmid2.RW_Demand__c = dmd2.id;
        dmid2.RW_GST_Amount__c = 1000;
        dmid2.RW_Legacy_Amount_Paid__c = 5000;
        dmid2.RW_Legacy_Demand__c = true;
        dmid2.Total_Demand_Item_Amount_Paid__c = 200000;
        insert dmid2;
        
        Booking__c b3 = new Booking__c();
        b3.Customer__c = objcustomer.Id;
        b3.Project__c = objpr.Id;
        b3.Opportunity__c = objcustomer.Id;
        b3.Unit_No__c = objPUU.id;
        b3.Quotation__c = q.Id;
        b3.Receipts__c = r1.Id;
        b3.Booking_Date__c = Date.today();
        b3.Account__c = cpaccount.Id;
        b3.Type_of_Client__c = 'Local';
        //b3.Tower__c = t[0].Id;
        b3.Status__c = 'Booking Confirmed';
        b3.RW_Registration_Done__c = 'No';
        b3.BrokerIId__c = cp.Id;
        b3.Exclude_From_Brokerage_Batch__c = false;
        b3.Brokerage_Scheme__c = null;
        b3.Source_of_Booking__c = 'Channel Partner';
        b3.RW_Registration_Date__c = Date.today();
        b3.Custom_Base_Brokerage__c = 4;

        //insert b3;
        
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
        
        Brokerage_Summary__c bs2 = new Brokerage_Summary__c();
        bs2.Channel_Partner__c = cp.Id;
        bs2.Brokerage_Scheme__c = bscheme.Id;
        bs2.Opportunity__c = objcustomer1.Id;
        bs2.CP_Account__c = cpaccount.Id;
        
     //   bs2.Booking__c = b2.Id;
        bs2.Applied_Slab_Name__c = 'Slab 4';
        insert bs2;
        
        Booking__c b2 = new Booking__c();
        b2.Customer__c = objcustomer1.Id;
        b2.Project__c = objpr.Id;
        b2.Opportunity__c = objcustomer1.Id;
        b2.Unit_No__c = objPUU1.id;
        b2.Quotation__c = q2.Id;
        b2.Receipts__c = r2.Id;
        b2.Booking_Date__c = Date.today();
        b2.Account__c = cpaccount.Id;
        b2.Type_of_Client__c = 'Local';
        //b2.Tower__c = t[0].Id;
        b2.Status__c = 'Booking Confirmed';
        b2.RW_Registration_Done__c = 'No';
        b2.BrokerIId__c = cp.Id;
        b2.Exclude_From_Brokerage_Batch__c = false;
        b2.Brokerage_Scheme__c = null;
        b2.Brokerage_Summary__c = bs2.Id;
        b2.Source_of_Booking__c = 'Channel Partner';
        b2.RW_Registration_Date__c = Date.today();
        b2.Allotment_Premium__c = 10000000;
        b2.RW_Total_Receipt_Amount_Received__c = 5000000;
        b2.Custom_Base_Brokerage__c = 4;

        insert b2;
        
        Brokerage_Summary__c bs = new Brokerage_Summary__c();
        bs.Channel_Partner__c = cp.Id;
        bs.Brokerage_Scheme__c = bscheme.Id;
        bs.Opportunity__c = objcustomer1.Id;
        bs.CP_Account__c = cpaccount.Id;
        bs.Booking__c = b2.Id;
        bs.Applied_Slab_Name__c = 'Slab 4';
        insert bs;
        
        
        Brokerage__c bro = new Brokerage__c();
        bro.Name = 'Additional Brokerage';
        bro.Brokerage__c = 2;
        bro.Brokerage_Amount__c = 272059;
        bro.Brokerage_Scheme__c =  bscheme.Id;
        bro.Channel_Partner__c = cp.Id;
        bro.Opportunity__c = objcustomer1.Id;
        bro.Booking__c = b2.Id;
        bro.Brokerage_Summary__c = bs.Id;
        bro.Opportunity_AV__c = 13602975;
        bro.Brokerage_Type__c = 'Additional Brokerage';
        bro.Brokerage_Amount__c  = 321378;
        bro.Kicker_Incentive_Amount__c = 100;
        insert bro;
        
        b2.Brokerage_Summary__c = bs.id;
        update b2;
        
        
         Brokerage_Summary__c bs1 = new Brokerage_Summary__c();
        bs1.Channel_Partner__c = cp.Id;
        bs1.Brokerage_Scheme__c = bscheme.Id;
        bs1.Opportunity__c = objcustomer1.Id;
        bs1.CP_Account__c = cpaccount.Id;
        bs1.Booking__c = b2.Id;
        bs1.Applied_Slab_Name__c = 'Slab 4';
        insert bs1;
        
        
        
        Brokerage__c bro1 = new Brokerage__c();
        bro1.Name = 'Additional Brokerage';
        bro1.Brokerage__c = 2;
        bro1.Brokerage_Amount__c = 272059;
        bro1.Brokerage_Scheme__c =  bscheme.Id;
        bro1.Channel_Partner__c = cp.Id;
        bro1.Opportunity__c = objcustomer1.Id;
        bro1.Booking__c = b2.Id;
        bro1.Brokerage_Summary__c = bs1.Id;
        bro1.Opportunity_AV__c = 13602975;
        bro1.Brokerage_Type__c = 'Additional Brokerage';
        insert bro1;
        
        b2.Brokerage_Summary__c = bs1.id;
        update b2;
        
              
        Set<Id> CPId = New Set<Id>();
        Set<Id> BSId = New Set<Id>();
        CPId.add(cp.id);
        BSId.add(bscheme.id);
        BrokerageLadderCreation.CreateInvoice(CPId,bscheme.id);
        BrokerageLadderCreation.dummy();
        BrokerageManagementServicesV2.dummy();
        BatchBrokerageLadderCreation B1 = New BatchBrokerageLadderCreation(CPId,BSId);
       // B1.execute(Null);
         Database.executeBatch(B1,2);
        
    }
    @isTest
    public static void testbms2(){
        
        
        Opportunity objcustomer;
        Opportunity objcustomer1;
        Opportunity objcustomer2;
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
        bscheme.Base_Brokerage_for_OS_NRI__c = 3;
        bscheme.Slab_Type__c = 'Count';
        bscheme.Start_Date__c = system.today();
        bscheme.End_Date__c = system.today()+2;
        bscheme.Project_Location__c = pl.Id;
        insert bscheme;
        
        Brokerage_Slab__c bslab = new Brokerage_Slab__c();
        bslab.Name = 'Slab 2';
        bslab.From__c = 0;
        bslab.To__c = 1;
        bslab.Additional_Brokerage_for_Local_Bookings__c = 0;
        bslab.Additional_Brokerage_for_OS_NRI__c = 0;
        bslab.Brokerage_Scheme__c = bscheme.Id;
        insert bslab;
        
        Brokerage_Slab__c bslab2 = new Brokerage_Slab__c();
        bslab2.Name = 'Slab 2';
        bslab2.From__c = 2;
        bslab2.To__c = null;
        bslab2.Additional_Brokerage_for_Local_Bookings__c = 0.25;
        bslab2.Additional_Brokerage_for_OS_NRI__c = 0.25;
        bslab2.Brokerage_Scheme__c = bscheme.Id;
        insert bslab2;
        
        Scheme_Configuration__c sc = new Scheme_Configuration__c();
        sc.Name = 'Oct';
        sc.Brokerage_Scheme__c = bscheme.Id;
        sc.Project__c = objpr.id;
        insert sc;
          
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
        
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@stetig.in.com','9098777',false);
        List<Tower__c> t = TestDataFactory.createTowers(1,objpr.Id);
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
        cp.RW_Mobile_No__c = '1234567890';
        cp.Broker_Type__c = 'Individual';
        cp.Broker_Pan_No__c = 'ADRPI3525F';
        cp.RW_RERA_Registration_Number__c = '123256789012';
        cp.RW_Mobile_No__c = '1234567890';
        insert cp;
        
        Account cpaccount = [Select Id,Name,Channel_Partner__c from Account where Channel_Partner__c =: cp.Id];
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
        
        objcustomer1= new Opportunity();
        objcustomer1.RW_Project__c=objpr.id;
        objcustomer1.name='Test 1';
        objcustomer1.StageName='Qualification';
        //objcustomer1.RW_Project_Unit__c=objPUU1.id;  
        objcustomer1.CloseDate=system.today();
        objcustomer1.Status__c ='Active';
        objcustomer1.AccountId = a.Id;
        objcustomer.RW_Type_of_Client__c = 'Local';
        objcustomer.Channel_Partner_Account__c = cpaccount.Id;
        objcustomer.RW_Walkin_Channel_Partner__c =  cp.Id;
        objcustomer.Walkin_Source__c = 'Channel Partner';
        //objcustomer1.Duplicate_Project_Unit_Request__c = false;
        //objcustomer1.Release_Unit__c = false;
        insert objcustomer1;
      	
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
        insert q;
        
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
        //q2.Service_Tax_On_Token_Amount__c = true;
        insert q2;
        
        Quotation__c q3 = new Quotation__c();
        q3.Name = 'Q020202';
        q3.Quote_Status__c = 'Approval Pending';
        q3.Prepared_Date__c = System.today();
        q3.Project__c = objpr.Id;
        q3.Project_Unit__c = objPUU1.Id;
        q3.FloorNo__c = 11;
        q3.Opportunity__c = objcustomer2.Id;
        q3.Appartment_Configuration__c = '1 BHK';
        q3.Carpet_Area_Sq_Ft__c = 1200;
        q3.Token_Amount__c =110000;
        q3.ST_Token_Amount__c = 1000;
        q3.Allow_booking_without_full_token__c = TRUE;
        q3.Agreement_Value__c = 60422880;
        q3.Agreement_Value_ST__c = 2537761;
        q3.Tandem_car_park_Additional__c = 0;
        q3.Tandem_Open_Additional__c= 0;
        q3.Single_car_park_Additional__c= 0;
        q3.Single_Open_Additional__c = 0;
        q3.Stack_Additional__c = 0;
        q3.MLCP_Additional__c = null;
        //q2.Service_Tax_On_Token_Amount__c = true;
        insert q3;
        
        Receipt__c r1 = new Receipt__c();
        r1.Cheque_DD_Amount_Rs__c = 200000;
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
        r1.Total_Amount__c = 200000;
        r1.Currency__c = 'Indian Rupee';
        insert r1;
        
        Receipt__c r2 = new Receipt__c();
        r2.Cheque_DD_Amount_Rs__c = 8400;
        r2.Cheque_DD__c = '9088881';
        r2.Cheque_DD_Date__c = system.today();
        r2.Project__c = objpr.Id;
        r2.Project_Unit__c = objPUU.Id;
        r2.Opportunity__c = objcustomer.Id;
        r2.CheckReceipt__c = true;
        r2.Physically_Cheque_Received__c = true;
        r2.Approval_Status__c = 'Approved';
        r2.Receipt_Date__c = system.today();
        r2.DraweeBank__c = 'CITI';
        r2.Total_Amount__c = 8400;
        r1.Currency__c = 'Indian Rupee';
        r2.Token_Amount_ST__c = true;
        insert r2;
        
        Booking__c b = new Booking__c();
        b.Customer__c = objcustomer.Id;
        b.Project__c = objpr.Id;
        b.Opportunity__c = objcustomer.Id;
        b.Unit_No__c = objPUU.id;
        b.Quotation__c = q.Id;
        b.Receipts__c = r1.Id;
        b.Booking_Date__c = Date.today();
        b.Account__c = cpaccount.Id;
        b.Type_of_Client__c = 'Local';
        //b.Tower__c = t[0].Id;
        b.RW_Registration_Done__c = 'No';
        b.BrokerIId__c = cp.Id;
        b.Exclude_From_Brokerage_Batch__c = false;
        b.Brokerage_Scheme__c = null;
        b.Source_of_Booking__c = 'Channel Partner';
        b.RW_Registration_Date__c = Date.today();
        
        insert b;
        BIds.add(b.Id);
        Booking__c b2 = new Booking__c();
        b2.Customer__c = objcustomer1.Id;
        b2.Project__c = objpr.Id;
        b2.Opportunity__c = objcustomer1.Id;
        b2.Unit_No__c = objPUU1.id;
        b2.Quotation__c = q2.Id;
        b2.Receipts__c = r2.Id;
        b2.Booking_Date__c = Date.today();
        b2.Account__c = cpaccount.Id;
        b2.Type_of_Client__c = 'Local';
        //b2.Tower__c = t[0].Id;
        b2.RW_Registration_Done__c = 'No';
        b2.BrokerIId__c = cp.Id;
        b2.Exclude_From_Brokerage_Batch__c = false;
        b2.Brokerage_Scheme__c = null;
        b2.Source_of_Booking__c = 'Channel Partner';
        b2.RW_Registration_Date__c = Date.today();
        insert b2;
        //BIds.add(b2.Id);
        
        Booking__c b3 = new Booking__c();
        b3.Customer__c = objcustomer.Id;
        b3.Project__c = objpr.Id;
        b3.Opportunity__c = objcustomer.Id;
        b3.Unit_No__c = objPUU.id;
        b3.Quotation__c = q.Id;
        b3.Receipts__c = r1.Id;
        b3.Booking_Date__c = Date.today();
        b3.Account__c = cpaccount.Id;
        b3.Type_of_Client__c = 'NRI';
        //b3.Tower__c = t[0].Id;
        b3.Status__c = 'Booking Confirmed';
        b3.RW_Registration_Done__c = 'No';
        b3.BrokerIId__c = cp.Id;
        b3.Exclude_From_Brokerage_Batch__c = false;
        b3.Brokerage_Scheme__c = null;
        //b3.Brokerage_Summary__c = bs.id;

        b3.Source_of_Booking__c = 'Channel Partner';
        b3.RW_Registration_Date__c = Date.today();
        insert b3;
        
        
        
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
       
    }

}