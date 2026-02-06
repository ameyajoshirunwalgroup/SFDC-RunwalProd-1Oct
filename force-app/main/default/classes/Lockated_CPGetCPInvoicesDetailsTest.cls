@isTest
public class Lockated_CPGetCPInvoicesDetailsTest {
    @isTest
    static void TestCase1(){
        
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
        insert cp;
        
        list<AOP_Schemes__c> aopschlist = new list<AOP_Schemes__c>();
        AOP_Schemes__c ash = new AOP_Schemes__c();
        ash.Name = 'Test';
        ash.Financial_Year_Start_Date__c =  system.today()-10;
        ash.Financial_Year_End_Date__c =  system.today()+10;
        aopschlist.add(ash);
        insert aopschlist;
        
        list<AOP_Schemes_Slabs__c> asslblist = new list<AOP_Schemes_Slabs__c>();
        AOP_Schemes_Slabs__c asslb = new AOP_Schemes_Slabs__c();
        asslb.Slab_Name__c = 'Slab 1';
        asslb.Lower_Limit__c = 1;
        asslb.Upper_Limit__c = 100;
        asslb.Category__c = 'Silver';
        asslb.Brokerage_Rate__c = 0.2;
        asslb.AOP_Schemes__c = aopschlist[0].Id;
        asslblist.add(asslb);
        
        AOP_Schemes_Slabs__c asslb1 = new AOP_Schemes_Slabs__c();
        asslb1.Slab_Name__c = 'Slab 2';
        asslb1.Lower_Limit__c = 100;
        asslb1.Upper_Limit__c = 100000;
        asslb.Brokerage_Rate__c = 0.2;
        asslb1.Category__c = 'Gold';
        asslb1.AOP_Schemes__c = aopschlist[0].Id;
        asslblist.add(asslb1);
        
        AOP_Schemes_Slabs__c asslb2 = new AOP_Schemes_Slabs__c();
        asslb2.Slab_Name__c = 'Slab 3';
        asslb2.Lower_Limit__c = 100000;
        asslb2.Upper_Limit__c = 100000000;
        asslb2.Brokerage_Rate__c = 0.2;
        asslb2.Category__c = 'Platinum';
        asslb2.AOP_Schemes__c = aopschlist[0].Id;
        asslblist.add(asslb2);
        
        AOP_Schemes_Slabs__c asslb3 = new AOP_Schemes_Slabs__c();
        asslb3.Slab_Name__c = 'Slab 1';
        asslb3.Lower_Limit__c = 100000000;
        asslb3.Upper_Limit__c = 1000000000;
        asslb3.Brokerage_Rate__c = 0.2;
        asslb3.Category__c = 'Diamond';
        asslb3.AOP_Schemes__c = aopschlist[0].Id;
        asslblist.add(asslb3);
        insert asslblist;
        
        
        
        
        // Create AOP with different scenarios
        List<AOP__c> aops = new List<AOP__c>();
        
        // AOP for FY processing
        aops.add(new AOP__c(
          //  Name = 'AOP FY 2024-25',
            Channel_Partner__c = cp.Id,
            Start_Date__c = Date.newInstance(2024, 4, 1),
            End_Date__c = Date.newInstance(2025, 3, 31),
            Commitment_max__c = 50000000,
            AOP_Schemes__c = aopschlist[0].Id
        ));
        
        // AOP for end date processing (past)
        aops.add(new AOP__c(
           // Name = 'AOP Past End Date',
            Channel_Partner__c = cp.Id,
            Start_Date__c = Date.today().addDays(-60),
            End_Date__c = Date.today().addDays(-1),
            Commitment_max__c = 30000000,
            AOP_Schemes__c = aopschlist[0].Id
        ));
        
        // AOP for interim processing (ongoing)
        aops.add(new AOP__c(
           // Name = 'AOP Ongoing',
            Channel_Partner__c = cp.Id,
            Start_Date__c = Date.today().addDays(-30),
            End_Date__c = Date.today().addDays(30),
            Commitment_max__c = 40000000,
            AOP_Schemes__c = aopschlist[0].Id
        ));
        
        // AOP with no commitment
        aops.add(new AOP__c(
            //Name = 'AOP No Commitment',
            Channel_Partner__c = cp.Id,
            Start_Date__c = Date.today().addDays(-10),
            End_Date__c = Date.today().addDays(10),
            Commitment_max__c = null,
            AOP_Schemes__c = aopschlist[0].Id
        ));
        
        insert aops;
        
        // Create AOP Slabs for each AOP
        List<AOP_Slab__c> slabs = new List<AOP_Slab__c>();
        
        for (AOP__c aop : aops) {
            if (aop.Commitment_max__c != null) {
                // Slab 1
                slabs.add(new AOP_Slab__c(
                    AOP__c = aop.Id,
                    Slab_Name__c = 'Slab 1',
                    Lower_Limit__c = 0,
                    Upper_Limit__c = 10000000,
                    Brokerage_Rate__c = 1.0,
                    Priority__c = 1
                ));
                
                // Slab 2
                slabs.add(new AOP_Slab__c(
                    AOP__c = aop.Id,
                    Slab_Name__c = 'Slab 2',
                    Lower_Limit__c = 10000001,
                    Upper_Limit__c = 25000000,
                    Brokerage_Rate__c = 2.0,
                    Priority__c = 2
                ));
                
                // Slab 3
                slabs.add(new AOP_Slab__c(
                    AOP__c = aop.Id,
                    Slab_Name__c = 'Slab 3',
                    Lower_Limit__c = 25000001,
                    Upper_Limit__c = 50000000,
                    Brokerage_Rate__c = 3.0,
                    Priority__c = 3
                ));
            }
        }
        
        insert slabs;
        
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
        b.AOP_Scheme__c = aops[0].Id;
        

        
        Booking__c b2 = b.clone(false, true, false, false);
        Booking__c b3 = b.clone(false, true, false, false);
        
        List<Booking__c> bookingsToInsert = new List<Booking__c>{ b, b2, b3 };
            insert bookingsToInsert;
        
        RW_Registration_Challan__c r = new RW_Registration_Challan__c();
        r.RW_SDR_Instrument_Amount__c = 5000000;
        r.Booking__c = b.id;
        insert r;
        
        
        
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
            Booking__c = b2.Id,
            Applied_Slab_Name__c = 'Slab 1'
        );
        bslist.add(bs1);
        insert bslist;
        
        list<Brokerage__c> brolist = new list<Brokerage__c>();
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
        brolist.add(bro);
        
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
        
        Brokerage__c bro2 = new Brokerage__c(
            Name = 'Additional Brokerage',
            Brokerage__c = 2,
            Brokerage_Amount__c = 272059,
            Brokerage_Scheme__c = bscheme.Id,
            Channel_Partner__c = cp.Id,
            Opportunity__c = objcustomer1.Id,            
            Booking__c = b.Id,
            Brokerage_Summary__c = bs1.Id,
            Opportunity_AV__c = 13602975,
            Brokerage_Type__c = 'Additional Brokerage'
        );
        brolist.add(bro2);
        brolist.add(bro1);
        insert brolist;
        CP_Brokerage__c CPbrokerage = new CP_Brokerage__c(
            Invoice_Number__c = 'TEMP-001',
            If_GST_is_applicable__c = 'No',
            Invoice_Status__c = 'Not Submitted',
            Brokerage_Type__c = 'Additional Brokerage'
        );
        insert CPbrokerage;
        list<Booking__c> blisttt = new list<Booking__c>();
         b.Brokerage_Summary__c = bs.id;
        blisttt.add(b);
        
        b2.Brokerage_Summary__c = bs.id;
        blisttt.add(b2);
        
        b3.Brokerage_Summary__c = bs.id;
        blisttt.add(b3);
        update blisttt;
        
        // --- Combined Demand Inserts ---
        RW_Demand__c dmd = new RW_Demand__c(Name='890890', Booking__c=b.Id, RW_Billing_Document_Number__c='890890', RW_Customer_Number__c='12345678');
        RW_Demand__c dmd2 = new RW_Demand__c(Name='890890', Booking__c=b2.Id, RW_Billing_Document_Number__c='890890', RW_Customer_Number__c='12345678');
        RW_Demand__c dmd3 = new RW_Demand__c(Name='890890', Booking__c=b3.Id, RW_Billing_Document_Number__c='890890', RW_Customer_Number__c='12345678');
        insert new List<RW_Demand__c>{ dmd, dmd2, dmd3 };
            
            // --- Combined Demand Item Inserts ---
            RW_Demand_Item__c dmid = new RW_Demand_Item__c(RW_Demand_Item_Amount__c=200000, RW_Demand__c=dmd.Id, RW_GST_Amount__c=1000, RW_Legacy_Amount_Paid__c=5000, RW_Legacy_Demand__c=true, Total_Demand_Item_Amount_Paid__c=200000);
        RW_Demand_Item__c dmid2 = new RW_Demand_Item__c(RW_Demand_Item_Amount__c=200000, RW_Demand__c=dmd2.Id, RW_GST_Amount__c=1000, RW_Legacy_Amount_Paid__c=5000, RW_Legacy_Demand__c=true, Total_Demand_Item_Amount_Paid__c=200000);
        RW_Demand_Item__c dmid3 = new RW_Demand_Item__c(RW_Demand_Item_Amount__c=200000, RW_Demand__c=dmd3.Id, RW_GST_Amount__c=1000, RW_Legacy_Amount_Paid__c=5000, RW_Legacy_Demand__c=true, Total_Demand_Item_Amount_Paid__c=200000);
        insert new List<RW_Demand_Item__c>{ dmid, dmid2, dmid3 };
            
            system.debug('9.99 b3::'+ b3.RW_Total_Amount_Received_Without_GST__c );
            system.debug('9.99 b3::' + [SELECT Id, Name, RW_X9_99_Received__c FROM Booking__c WHERE Id = :b3.Id]);
         system.debug('9.99 b3::' + [SELECT Id, Name, RW_X9_99_Received__c FROM Booking__c WHERE RW_X9_99_Received__c = true]);
        
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'GET';
        req.requestURI = '/services/apexrest/cpGetCPInvoicesDetails';
        req.addParameter('cpId', cp.Id);
        
        RestContext.request = req;
        RestContext.response = res;
        
        // 4️⃣ Call REST method
        Test.startTest();
        Lockated_CPGetCPInvoicesDetails.doGet();
        Test.stopTest();
        
    }
    @isTest
    static void TestCase2(){
        
        
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'GET';
        req.requestURI = '/services/apexrest/cpGetCPInvoicesDetails';
        req.addParameter('cpId', '');
        
        RestContext.request = req;
        RestContext.response = res;
        
        // 4️⃣ Call REST method
        Test.startTest();
        Lockated_CPGetCPInvoicesDetails.doGet();
        Test.stopTest();
        
    }
    @isTest
    static void TestCase4(){
        
        
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'GET';
        req.requestURI = '/services/apexrest/cpGetCPInvoicesDetails';
        req.addParameter('cpId', 'test');
        
        RestContext.request = req;
        RestContext.response = res;
        
        // 4️⃣ Call REST method
        Test.startTest();
        Lockated_CPGetCPInvoicesDetails.doGet();
        Test.stopTest();
        
    }
    @isTest
    static void TestCase5(){
        
        
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'GET';
        req.requestURI = '/services/apexrest/cpGetCPInvoicesDetails';
        req.addParameter('cpId', 'test');
        
        RestContext.request = req;
        RestContext.response = res;
        
        // 4️⃣ Call REST method
        Test.startTest();
        Lockated_CPGetCPInvoicesDetails.InvDetailsForLadder LadderDetails = new Lockated_CPGetCPInvoicesDetails.InvDetailsForLadder();
        CP_Brokerage__c cpBrokerage = new CP_Brokerage__c();
        List<Brokerage_Invoice__c> brokerageInvoice = new List<Brokerage_Invoice__c>();
        Lockated_CPGetCPInvoicesDetails.assignLadderBrokerage(LadderDetails,cpBrokerage,brokerageInvoice);
        Lockated_CPGetCPInvoicesDetails.assignLadderBrokerageBI(LadderDetails, new Brokerage_Invoice__c());
        Lockated_CPGetCPInvoicesDetails.doGet();
        Test.stopTest();
        
    }
    @isTest
    static void TestCase6(){
        
        
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'GET';
        req.requestURI = '/services/apexrest/cpGetCPInvoicesDetails';
        req.addParameter('cpId', 'test');
        
        RestContext.request = req;
        RestContext.response = res;
        
        // 4️⃣ Call REST method
        Test.startTest();
        Lockated_CPGetCPInvoicesDetails.InvDetailsForAOP aopDetails = new Lockated_CPGetCPInvoicesDetails.InvDetailsForAOP();
        aopDetails.fyOfAOPScheme = 'test';
        aopDetails.aopAmout = 20;
        CP_Brokerage__c cpBrokerage = new CP_Brokerage__c();
        List<Brokerage_Invoice__c> brokerageInvoice = new List<Brokerage_Invoice__c>();
        Lockated_CPGetCPInvoicesDetails.assignAOPBrokerage(aopDetails,cpBrokerage,brokerageInvoice);
        Lockated_CPGetCPInvoicesDetails.assignAOPBrokerageBI(aopDetails, new Brokerage_Invoice__c());
        Lockated_CPGetCPInvoicesDetails.doGet();
        Test.stopTest();
        
    }
    @isTest
    static void TestCase9(){
        
        
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'GET';
        req.requestURI = '/services/apexrest/cpGetCPInvoicesDetails';
        req.addParameter('cpId', 'test');
        
        RestContext.request = req;
        RestContext.response = res;
        
        // 4️⃣ Call REST method
        Test.startTest();
        Lockated_CPGetCPInvoicesDetails.InvDetailsForBase baseDetails = new Lockated_CPGetCPInvoicesDetails.InvDetailsForBase();
        CP_Brokerage__c cpBrokerage = new CP_Brokerage__c();
        List<Brokerage_Invoice__c> brokerageInvoice = new List<Brokerage_Invoice__c>();
        Lockated_CPGetCPInvoicesDetails.assignBaseBrokerageBI(baseDetails, new Brokerage_Invoice__c());
        Lockated_CPGetCPInvoicesDetails.doGet();
        Test.stopTest();
        
    }
    @isTest
    static void testSetup7() {
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
        insert cp;
        
        list<AOP_Schemes__c> aopschlist = new list<AOP_Schemes__c>();
        AOP_Schemes__c ash = new AOP_Schemes__c();
        ash.Name = 'Test';
        ash.Financial_Year_Start_Date__c =  system.today()-10;
        ash.Financial_Year_End_Date__c =  system.today()+10;
        aopschlist.add(ash);
        insert aopschlist;
        
        list<AOP_Schemes_Slabs__c> asslblist = new list<AOP_Schemes_Slabs__c>();
        AOP_Schemes_Slabs__c asslb = new AOP_Schemes_Slabs__c();
        asslb.Slab_Name__c = 'Slab 1';
        asslb.Lower_Limit__c = 1;
        asslb.Upper_Limit__c = 100;
        asslb.Category__c = 'Silver';
        asslb.Brokerage_Rate__c = 0.2;
        asslb.AOP_Schemes__c = aopschlist[0].Id;
        asslblist.add(asslb);
        
        AOP_Schemes_Slabs__c asslb1 = new AOP_Schemes_Slabs__c();
        asslb1.Slab_Name__c = 'Slab 2';
        asslb1.Lower_Limit__c = 100;
        asslb1.Upper_Limit__c = 100000;
        asslb.Brokerage_Rate__c = 0.2;
        asslb1.Category__c = 'Gold';
        asslb1.AOP_Schemes__c = aopschlist[0].Id;
        asslblist.add(asslb1);
        
        AOP_Schemes_Slabs__c asslb2 = new AOP_Schemes_Slabs__c();
        asslb2.Slab_Name__c = 'Slab 3';
        asslb2.Lower_Limit__c = 100000;
        asslb2.Upper_Limit__c = 100000000;
        asslb2.Brokerage_Rate__c = 0.2;
        asslb2.Category__c = 'Platinum';
        asslb2.AOP_Schemes__c = aopschlist[0].Id;
        asslblist.add(asslb2);
        
        AOP_Schemes_Slabs__c asslb3 = new AOP_Schemes_Slabs__c();
        asslb3.Slab_Name__c = 'Slab 1';
        asslb3.Lower_Limit__c = 100000000;
        asslb3.Upper_Limit__c = 1000000000;
        asslb3.Brokerage_Rate__c = 0.2;
        asslb3.Category__c = 'Diamond';
        asslb3.AOP_Schemes__c = aopschlist[0].Id;
        asslblist.add(asslb3);
        insert asslblist;
        
        
        
        
        // Create AOP with different scenarios
        List<AOP__c> aops = new List<AOP__c>();
        
        // AOP for FY processing
        aops.add(new AOP__c(
          //  Name = 'AOP FY 2024-25',
            Channel_Partner__c = cp.Id,
            Start_Date__c = Date.newInstance(2024, 4, 1),
            End_Date__c = Date.newInstance(2025, 3, 31),
            Commitment_max__c = 50000000,
            AOP_Schemes__c = aopschlist[0].Id
        ));
        
        // AOP for end date processing (past)
        aops.add(new AOP__c(
           // Name = 'AOP Past End Date',
            Channel_Partner__c = cp.Id,
            Start_Date__c = Date.today().addDays(-60),
            End_Date__c = Date.today().addDays(-1),
            Commitment_max__c = 30000000,
            AOP_Schemes__c = aopschlist[0].Id
        ));
        
        // AOP for interim processing (ongoing)
        aops.add(new AOP__c(
           // Name = 'AOP Ongoing',
            Channel_Partner__c = cp.Id,
            Start_Date__c = Date.today().addDays(-30),
            End_Date__c = Date.today().addDays(30),
            Commitment_max__c = 40000000,
            AOP_Schemes__c = aopschlist[0].Id
        ));
        
        // AOP with no commitment
        aops.add(new AOP__c(
            //Name = 'AOP No Commitment',
            Channel_Partner__c = cp.Id,
            Start_Date__c = Date.today().addDays(-10),
            End_Date__c = Date.today().addDays(10),
            Commitment_max__c = null,
            AOP_Schemes__c = aopschlist[0].Id
        ));
        
        insert aops;
        
        // Create AOP Slabs for each AOP
        List<AOP_Slab__c> slabs = new List<AOP_Slab__c>();
        
        for (AOP__c aop : aops) {
            if (aop.Commitment_max__c != null) {
                // Slab 1
                slabs.add(new AOP_Slab__c(
                    AOP__c = aop.Id,
                    Slab_Name__c = 'Slab 1',
                    Lower_Limit__c = 0,
                    Upper_Limit__c = 10000000,
                    Brokerage_Rate__c = 1.0,
                    Priority__c = 1
                ));
                
                // Slab 2
                slabs.add(new AOP_Slab__c(
                    AOP__c = aop.Id,
                    Slab_Name__c = 'Slab 2',
                    Lower_Limit__c = 10000001,
                    Upper_Limit__c = 25000000,
                    Brokerage_Rate__c = 2.0,
                    Priority__c = 2
                ));
                
                // Slab 3
                slabs.add(new AOP_Slab__c(
                    AOP__c = aop.Id,
                    Slab_Name__c = 'Slab 3',
                    Lower_Limit__c = 25000001,
                    Upper_Limit__c = 50000000,
                    Brokerage_Rate__c = 3.0,
                    Priority__c = 3
                ));
            }
        }
        
        insert slabs;
        
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
        b.AOP_Scheme__c = aops[0].Id;
        

        
        Booking__c b2 = b.clone(false, true, false, false);
        Booking__c b3 = b.clone(false, true, false, false);
        
        List<Booking__c> bookingsToInsert = new List<Booking__c>{ b, b2, b3 };
            insert bookingsToInsert;
        
        RW_Registration_Challan__c r = new RW_Registration_Challan__c();
        r.RW_SDR_Instrument_Amount__c = 5000000;
        r.Booking__c = b.id;
        insert r;
        
        
        
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
            Booking__c = b2.Id,
            Applied_Slab_Name__c = 'Slab 1'
        );
        bslist.add(bs1);
        insert bslist;
        
        list<Brokerage__c> brolist = new list<Brokerage__c>();
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
        brolist.add(bro);
        
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
        
        Brokerage__c bro2 = new Brokerage__c(
            Name = 'Additional Brokerage',
            Brokerage__c = 2,
            Brokerage_Amount__c = 272059,
            Brokerage_Scheme__c = bscheme.Id,
            Channel_Partner__c = cp.Id,
            Opportunity__c = objcustomer1.Id,            
            Booking__c = b.Id,
            Brokerage_Summary__c = bs1.Id,
            Opportunity_AV__c = 13602975,
            Brokerage_Type__c = 'Additional Brokerage'
        );
        brolist.add(bro2);
        brolist.add(bro1);
        insert brolist;
        // 1. Create a Channel Partner (Account)
        Broker__c acc = new Broker__c(Name = 'Test Channel Partner');
        insert acc;

        // 2. Create CP_Brokerage__c records (Parent)
        // One for each status logic in your class
        List<CP_Brokerage__c> cpList = new List<CP_Brokerage__c>();
        
        // Paid status
        cpList.add(new CP_Brokerage__c(
            Channel_Partner__c = cp.Id,
            // Status__c = 'Paid',
            Total_Brokerage__c = 1000,
            Brokerage_Type__c = 'Base Brokerage',
            Invoice_Date__c = Date.today()
        ));

        // Invoice Raised status
        cpList.add(new CP_Brokerage__c(
            Channel_Partner__c = cp.Id,
            // Status__c = 'Unpaid',
            Invoice_Status__c = 'Invoice Uploaded',
            Total_Brokerage__c = 2000,
            Brokerage_Type__c = 'Additional Brokerage',
            Invoice_Date__c = Date.today()
        ));

        // Due Eligible status
        cpList.add(new CP_Brokerage__c(
            Channel_Partner__c = cp.Id,
            // Status__c = 'Unpaid',
            // Invoice_Status__c = 'Pending',
            Approval_Status_clearing__c = 'Approved By L1',
            Total_Brokerage__c = 3000,
            Brokerage_Type__c = 'AOP Brokerage',
            Invoice_Date__c = Date.today()
        ));

        insert cpList;

        // 3. Create Brokerage_Invoice__c records (Child)
        List<Brokerage_Invoice__c> childInvoices = new List<Brokerage_Invoice__c>();
        for(CP_Brokerage__c cpObj : cpList) {
            childInvoices.add(new Brokerage_Invoice__c(
                CP_Brokerage__c = cpObj.Id,
                Channel_Partner__c = cp.Id,
                //Customer_Name__c = 'Test Customer',
                Total_Agreement_Value__c = 500000,
                Brokerage_Lookup__c = bro2.Id
            ));
            childInvoices.add(new Brokerage_Invoice__c(
                Channel_Partner__c = cp.Id,
                //Customer_Name__c = 'Test Customer',
                Total_Agreement_Value__c = 500000,
                Brokerage_Lookup__c = bro2.Id
            ));
        }
        insert childInvoices;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'GET';
        req.requestURI = '/services/apexrest/cpGetCPInvoicesDetails';
        req.addParameter('cpId', cp.Id);
        
        RestContext.request = req;
        RestContext.response = res;
        
        // 4️⃣ Call REST method
        Test.startTest();
        Lockated_CPGetCPInvoicesDetails.doGet();
        Test.stopTest();
        
    }
}