@isTest
public class Lockated_CPCustomerAnalyticsTest {
	 
    @isTest
    static void TestLockated_CPCustomerAnalytics_CP(){
        
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
        bscheme.Name = 'Test Scheme';
        bscheme.Approval_Status__c = 'Approved by Level 2';
        bscheme.Base_Brokerage_for_Local_Bookings__c = 2;
        bscheme.Base_Brokerage_for_NRI__c = 2;
        bscheme.Base_Brokerage_for_OS_NRI__c = 2;
        bscheme.Slab_Type__c = 'Count';
        bscheme.Start_Date__c = system.today()-20;
        bscheme.End_Date__c = system.today()-10;
        bscheme.Project_Location__c = pl.Id;
        insert bscheme;
        
        Brokerage_Slab__c bslab = new Brokerage_Slab__c();
        bslab.Name = 'Slab 1';
        bslab.From__c = 0;
        bslab.To__c = 1;
        bslab.Additional_Brokerage_for_Local_Bookings__c = 2;
        bslab.Additional_Brokerage_for_OS_NRI__c = 2;
        bslab.Additional_Brokerage_for_NRI__c = 2;
        bslab.Brokerage_Scheme__c = bscheme.Id;
        
        Brokerage_Slab__c bslab2 = new Brokerage_Slab__c();
        bslab2.Name = 'Slab 2';
        bslab2.From__c = 2;
        bslab2.To__c = null;
        bslab2.Additional_Brokerage_for_Local_Bookings__c = 2.5;
        bslab2.Additional_Brokerage_for_OS_NRI__c = 2.5;
        bslab2.Additional_Brokerage_for_NRI__c = 2.5;																																																																																																																																																	
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
        
        list<Broker__c> cplist = new list<Broker__c>();
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
        cp.SAP_CP_Code__c = '6000022';
        cp.Broker_Pan_No__c = 'ADRPI3525F';
        cp.RW_RERA_Registration_Number__c = '123256789012';
        cp.Company_Name_As_per_RERA__c = 'Test CP';
        cp.Latest_RERA_Upload_Status__c = 'Approved';
        cp.RERA_Valid_till__c = system.today()+199;
        Id cpRtId = Schema.SObjectType.Broker__c
            .getRecordTypeInfosByName()
            .get('Channel Partner')
            .getRecordTypeId();
        cp.RecordTypeId =cpRtId; 
        cplist.add(cp);
        insert cplist;
        
        
        
        Account ac = new Account();
        ac.Name = cp.Company_Name_As_per_RERA__c;
        ac.CP_Email__c = cp.RW_Email__c;
        ac.Mobile_No__c = cp.RW_Mobile_No__c;
        ac.Channel_Partner__c = cp.id;
        ac.Zone__c = 'Central Zone 3';
        ac.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
        insert ac;
        
        Account cpaccount = [SELECT Id, Name, Channel_Partner__c FROM Account WHERE Channel_Partner__c = :cp.Id];
        
        objcustomer = new Opportunity();
        objcustomer.RW_Project__c = objpr.id;
        objcustomer.Name = 'Test 1';
        objcustomer.StageName = 'Qualification';
        objcustomer.CloseDate = system.today();
        objcustomer.Status__c = 'Active';
        objCustomer.AccountId = ac.Id;
        objcustomer.Budget_In_Cr__c = 20000000;
        objcustomer.Sales_Manager__c = 'SM2@g.com';
        objcustomer.RW_Type_of_Client__c = 'Local';
        objcustomer.Channel_Partner_Account__c = cpaccount.Id;
        objcustomer.RW_Walkin_Channel_Partner__c = cp.Id;
        objcustomer.Walkin_Source__c = 'Temp Channel Partner';
        objcustomer.Booking__c = null;
        
        objcustomer1 = new Opportunity();
        objcustomer1.RW_Project__c = objpr.id;
        objcustomer1.Name = 'Test 1';
        objcustomer1.StageName = 'Qualification';
        objcustomer1.CloseDate = system.today();
        objcustomer1.Status__c = 'Active';
        objcustomer1.AccountId = ac.Id;
        objcustomer1.Budget_In_Cr__c = 20000000;
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
        b.Customer__c = objcustomer.Id;
        b.Project__c = objpr.Id;
        b.Tower__c = t[0].Id;
        b.Opportunity__c = objcustomer.Id;
        b.Unit_No__c = objPUU1.id;
        b.Quotation__c = q.Id;
        b.Receipts__c = r2.Id;
        b.Booking_Date__c = system.today()-15;
        b.Account__c = cpaccount.Id;
        b.Type_of_Client__c = 'NRI';
        b.Status__c = 'Booking Confirmed';
        b.RW_Registration_Done__c = 'Yes';
        b.BrokerIId__c = cp.Id;
        b.Checklist_Approved__c = true;
        b.Exclude_From_Brokerage_Batch__c = false;
        b.Source_of_Booking__c = 'Channel Partner';
        b.RW_Registration_Date__c = Date.today();
        b.RW_Total_Receipt_Amount_Received__c = 5000000;
        b.Brokerage_Scheme__c = bscheme.Id;
        b.Allotment_Premium__c = 50000000;
        b.Custom_Base_Brokerage__c = 1;
        b.Checklist_Approved__c = true;
        

        List<Booking__c> bookingsToInsert = new List<Booking__c>{ b};
            insert bookingsToInsert;
      
       
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'GET';
        req.requestURI = '/services/apexrest/cpGetDetails';
        req.addParameter('cpId', cp.Id);
        
        RestContext.request = req;
        RestContext.response = res;
        
        // 4️⃣ Call REST method
        Test.startTest();
        Lockated_CPCustomerAnalytics.doGet();
        Test.stopTest();
        
    }
    
    @isTest
    static void TestLockated_CPCustomerAnalytics_TempCP(){
        
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
        bscheme.Name = 'Test Scheme';
        bscheme.Approval_Status__c = 'Approved by Level 2';
        bscheme.Base_Brokerage_for_Local_Bookings__c = 2;
        bscheme.Base_Brokerage_for_NRI__c = 2;
        bscheme.Base_Brokerage_for_OS_NRI__c = 2;
        bscheme.Slab_Type__c = 'Count';
        bscheme.Start_Date__c = system.today()-20;
        bscheme.End_Date__c = system.today()-10;
        bscheme.Project_Location__c = pl.Id;
        insert bscheme;
        
        Brokerage_Slab__c bslab = new Brokerage_Slab__c();
        bslab.Name = 'Slab 1';
        bslab.From__c = 0;
        bslab.To__c = 1;
        bslab.Additional_Brokerage_for_Local_Bookings__c = 2;
        bslab.Additional_Brokerage_for_OS_NRI__c = 2;
        bslab.Additional_Brokerage_for_NRI__c = 2;
        bslab.Brokerage_Scheme__c = bscheme.Id;
        
        Brokerage_Slab__c bslab2 = new Brokerage_Slab__c();
        bslab2.Name = 'Slab 2';
        bslab2.From__c = 2;
        bslab2.To__c = null;
        bslab2.Additional_Brokerage_for_Local_Bookings__c = 2.5;
        bslab2.Additional_Brokerage_for_OS_NRI__c = 2.5;
        bslab2.Additional_Brokerage_for_NRI__c = 2.5;																																																																																																																																																	
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
        objPUU1.Type__c = '2 BHK';
        objPUU1.RW_Param1__c = '5';
        objPUU1.UnitNo__c = '10';
        objPUU1.RW_Unit_Status__c = 'Available';
        
        insert new List<Project_Unit__c>{ objPUU, objPUU1 };
            
            Project_Charges__c prc = new Project_Charges__c();
        prc.Name = 'Basic';
        prc.Project__c = objpr.Id;
        insert prc;
        
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@stetig.in.com','9098777',false);
        
        
        list<Broker__c> cplist = new list<Broker__c>();
        Broker__c cp1 = new Broker__c();
        cp1.Name = 'Test CP';
        cp1.RW_Email__c = 'teststetig@stetig.in';
        cp1.Individual_CP__c = true;
        cp1.RW_CreateFromIRIS__c = true;
        cp1.RW_IRIS_Sync__c = true;
        cp1.Place_of_Supply__c = 'Maharashtra';
        cp1.Channel_Partner_From_CP_Portal__c = true;
        cp1.Project__c = 'Runwal Bliss';
        cp1.Approver_L1__c = userinfo.getUserId();
        cp1.Latest_RERA_Upload_Status__c = 'Approved';
        cp1.RERA_Valid_till__c = system.today()+2;
        cp1.Latest_CC_Upload_Status__c = 'Approved';
        cp1.CC_Valid_till__c = system.today()+2;
        cp1.Approver_L2__c = userinfo.getUserId();
        cp1.Registration_Complete__c = true;
        cp1.RW_Mobile_No__c = '1234567890';
        cp1.Broker_Type__c = 'Individual';
        cp1.SAP_CP_Code__c = '6000022';
        cp1.Broker_Pan_No__c = 'ADRPI3525F';
        cp1.RW_RERA_Registration_Number__c = '123256789012';
        cp1.Company_Name_As_per_RERA__c = 'Test CP';
        cp1.Latest_RERA_Upload_Status__c = 'Approved';
        cp1.RERA_Valid_till__c = system.today()+199;
        Id cpRtId1 = Schema.SObjectType.Broker__c
            .getRecordTypeInfosByName()
            .get('Temp Channel Partner')
            .getRecordTypeId();
        cp1.RecordTypeId =cpRtId1; 
        cplist.add(cp1);
        insert cplist;
        
        Account ac = new Account();
        ac.Name = cp1.Company_Name_As_per_RERA__c;
        ac.CP_Email__c = cp1.RW_Email__c;
        ac.Mobile_No__c = cp1.RW_Mobile_No__c;
        ac.Channel_Partner__c = cp1.id;
        ac.Zone__c = 'Central Zone 3';
        ac.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
        insert ac;
        
        Account cpaccount = [SELECT Id, Name, Channel_Partner__c FROM Account WHERE Channel_Partner__c = :cp1.Id];
        
        objcustomer = new Opportunity();
        objcustomer.RW_Project__c = objpr.id;
        objcustomer.Name = 'Test 1';
        objcustomer.StageName = 'Qualification';
        objcustomer.CloseDate = system.today();
        objcustomer.Status__c = 'Active';
        objCustomer.AccountId = ac.Id;
        objcustomer.Budget_In_Cr__c = 20000000;
        objcustomer.Sales_Manager__c = 'SM2@g.com';
        objcustomer.RW_Type_of_Client__c = 'Local';
        objcustomer.Channel_Partner_Account__c = cpaccount.Id;
        objcustomer.RW_Walkin_Channel_Partner__c = cp1.Id;
        objcustomer.Walkin_Source__c = 'Temp Channel Partner';
        objcustomer.Booking__c = null;
        
        objcustomer1 = new Opportunity();
        objcustomer1.RW_Project__c = objpr.id;
        objcustomer1.Name = 'Test 1';
        objcustomer1.StageName = 'Qualification';
        objcustomer1.CloseDate = system.today();
        objcustomer1.Status__c = 'Active';
        objcustomer1.AccountId = ac.Id;
        objcustomer1.Budget_In_Cr__c = 20000000;
        objcustomer1.RW_Type_of_Client__c = 'Local';
        objcustomer1.Channel_Partner_Account__c = cpaccount.Id;
        objcustomer1.RW_Walkin_Channel_Partner__c = cp1.Id;
        objcustomer1.Walkin_Source__c = 'Temp Channel Partner';
        
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
        b.Booking_Date__c = system.today()-15;
        b.Account__c = cpaccount.Id;
        b.Type_of_Client__c = 'NRI';
        b.Status__c = 'Booking Confirmed';
        b.RW_Registration_Done__c = 'Yes';
        b.BrokerIId__c = cp1.Id;
        b.Checklist_Approved__c = true;
        b.Exclude_From_Brokerage_Batch__c = false;
        b.Source_of_Booking__c = 'Temp Channel Partner';
        b.RW_Registration_Date__c = Date.today();
        b.RW_Total_Receipt_Amount_Received__c = 5000000;
        b.Brokerage_Scheme__c = bscheme.Id;
        b.Allotment_Premium__c = 50000000;
        b.Custom_Base_Brokerage__c = 1;
        b.Checklist_Approved__c = true;
        insert b;
        
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'GET';
        req.requestURI = '/services/apexrest/cpGetDetails';
        req.addParameter('cpId', cp1.Id);
        
        RestContext.request = req;
        RestContext.response = res;
        
        // 4️⃣ Call REST method
        Test.startTest();
        Lockated_CPCustomerAnalytics.doGet();
        Test.stopTest();
        
    }
}