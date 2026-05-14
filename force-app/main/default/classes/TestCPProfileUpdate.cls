@isTest
public class TestCPProfileUpdate {
    @isTest
    public static void CPProfileUpdate(){
        Broker__c cp = new Broker__c();
        cp.Name = 'Test CP';
        cp.RW_Email__c = 'teststetig43646@stetig.in';
        cp.Individual_CP__c = true;
        cp.RW_CreateFromIRIS__c = true;
        cp.RW_IRIS_Sync__c = true;
        cp.Place_of_Supply__c = 'Maharashtra';
        cp.Channel_Partner_From_CP_Portal__c = true;
        cp.Project__c = 'Runwal Bliss';
        cp.Company_Name_As_per_RERA__c = 'Runwal Enterprises';
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
        
        Account ac = new Account();                        
        ac.Name = cp.Company_Name_As_per_RERA__c;
        ac.CP_Email__c = cp.RW_Email__c;
        ac.Mobile_No__c = cp.RW_Mobile_No__c;
        ac.Channel_Partner__c = cp.id;
        Id AccCPRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();                
        ac.RecordTypeId = AccCPRecordTypeId;
        insert ac;
        
        Broker__c cp2 = new Broker__c();
        cp2.Name = 'Test CP';
        cp2.RW_Email__c = 'teststetig43646@stetig.in';
        cp2.Individual_CP__c = true;
        cp2.RW_CreateFromIRIS__c = true;
        cp2.RW_IRIS_Sync__c = true;
        cp2.Place_of_Supply__c = 'Maharashtra';
        cp2.Channel_Partner_From_CP_Portal__c = true;
        cp2.Project__c = 'Runwal Bliss';
        cp2.Approver_L1__c = userinfo.getUserId();
        cp2.Approver_L2__c = userinfo.getUserId();
        cp2.Registration_Complete__c = true;
        cp2.RW_Mobile_No__c = '1234567890';
        cp2.Broker_Type__c = 'Individual';
        cp2.Broker_Pan_No__c = 'ADRPI3525F';
        cp2.RW_Mobile_No__c = '1234567890';
        cp2.NAME_FIRST__c = 'tets';
        cp2.NAME_MIDDLE__c = 'cp';
        cp2.NAME_LAST__c = 'test';
        cp2.TITLE__c = 'Mr.';
        cp2.Account_Number__c = '465446';
        cp2.Cheque_DD_Favouring_Name__c = 'test cp';
        cp2.IFSC_Code__c = 'BHSHVD';
        cp2.Is_NRI_CP__c = false;
        cp2.RW_Is_GST_Applicable__c = true;
        cp2.Channel_Partner_From_CP_Portal__c =true;
        
        Broker__c cp3 = new Broker__c();
        cp3.Name = 'Test CP';
        cp3.RW_Email__c = 'teststetig43646@stetig.in';
        cp3.Individual_CP__c = true;
        cp3.RW_CreateFromIRIS__c = true;
        cp3.RW_IRIS_Sync__c = true;
        cp3.Place_of_Supply__c = 'Maharashtra';
        cp3.Channel_Partner_From_CP_Portal__c = true;
        cp3.Project__c = 'Runwal Bliss';
        cp3.Approver_L1__c = userinfo.getUserId();
        cp3.Approver_L2__c = userinfo.getUserId();
        cp3.Registration_Complete__c = true;
        cp3.RW_Mobile_No__c = '1234567890';
        cp3.Broker_Type__c = 'Individual';
        cp3.Broker_Pan_No__c = 'ADRPI3525Q';
        cp3.RW_Mobile_No__c = '1234567890';
        cp3.NAME_FIRST__c = 'tets';
        cp3.NAME_MIDDLE__c = 'cp';
        cp3.NAME_LAST__c = 'test';
        cp3.TITLE__c = 'Mr.';
        cp3.Account_Number__c = '465446';
        cp3.Cheque_DD_Favouring_Name__c = 'test cp';
        cp3.IFSC_Code__c = 'BHSHVD';
        cp3.Is_NRI_CP__c = false;
        cp3.RW_Is_GST_Applicable__c = true;
        cp3.Channel_Partner_From_CP_Portal__c =true;
        
        
        
        Sobject objRecord = new Broker__c(
            Name = 'Test CP',
            RW_Email__c = 'teststetig43646@stetig.in',
            Individual_CP__c = true,
            RW_CreateFromIRIS__c = true,
            RW_IRIS_Sync__c = true,
            Place_of_Supply__c = 'Maharashtra',
            Project__c = 'Runwal Bliss',
            Approver_L1__c = userinfo.getUserId(),
            Approver_L2__c = userinfo.getUserId(),
            Registration_Complete__c = true,
            RW_Mobile_No__c = '1234567890',
            Broker_Type__c = 'Individual',
            Broker_Pan_No__c = 'ADRPI3525Q',
            NAME_FIRST__c = 'tets',
            NAME_MIDDLE__c = 'cp',
            NAME_LAST__c = 'test',
            TITLE__c = 'Mr.',
            Account_Number__c = '465446',
            Cheque_DD_Favouring_Name__c = 'test cp',
            IFSC_Code__c = 'BHSHVD',
            Is_NRI_CP__c = false,
            RW_Is_GST_Applicable__c = true,
            Channel_Partner_From_CP_Portal__c =true);
        system.debug('cp id -> '+cp.id);
         system.debug('cp id -> '+cp);
        
        Account cpaccount = [Select Id,Name,Channel_Partner__c from Account where Channel_Partner__c =: cp.Id];
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@stetig.in.com','9098777',false);
        
        Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.RW_Status__c = 'Active';
        insert objpr;
        
        Opportunity objcustomer= new Opportunity();
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
        
        Collateral__c c = new Collateral__c();
        c.Project__c = objpr.id;
        insert c;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = c.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;

        CP_Invoice_Approvers_list_CS__c appcs = new CP_Invoice_Approvers_list_CS__c();
        appcs.Name = 'Test123';
        appcs.CP_MIS__c = '56789';
        appcs.CP_Sourcing_Head__c = '1234567';
        insert appcs;
        
        
        List<Id> acId = new List<Id>();
        acId.add(cpaccount.id);
        EnableCPPortaluser.EnableCustomerCommunityUser(acId);
        system.debug('cpAccount:::'+cpaccount);
        User u = [Select Id,name from User where Email =: 'teststetig43646@stetig.in'];
        system.runAs(u){
            CPProfileUpdate.updateChannelPartner(cp);
            CPProfileUpdate.getopps('Test 1', 'Runwal Bliss','CloseDate','Asc');
            CPBookingController.selfregister(cp2);
            try{
                CPBookingController.selfregister(cp);
            }catch(Exception e){
                
            }
            //CPBookingController.getCpMandateBookings('test3', 'test4', 'testunit', 'Yes', 'Yes');
            CPBookingController.selfregister(cp);
            CPBookingController.selfregister(cp3);
            CPBookingController.getCollateralsA();
            CPBookingController.getCollateralsB();
            CPBookingController.getApprovers('Test123');
            CPBookingController.pickListValueDynamically(objRecord, 'Broker_Type__c');
        }
    }
    @isTest
    public static void CPProfileUpdate2(){
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
        pl.CP_MIS__c = userinfo.getUserId();
        pl.CP_Sourcing_Head__c = userinfo.getUserId();
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
        objpr.RW_Status__c = 'Active';
        insert objpr;
        
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
        b.Brokerage_Scheme__c = null;
        b.Source_of_Booking__c = 'Channel Partner';
        b.Allotment_Premium__c = 10000000;
        b.Brokerage_Scheme__c = bscheme.Id;
        b.Base_Brokerage__c = 2;
        b.Kicker_Incentive_lookup__c = ki.id;
        insert b;
        Booking__c b2 = new Booking__c();
        b2.Customer__c = objcustomer2.Id;
        b2.Project__c = objpr.Id;
        b2.Opportunity__c = objcustomer2.Id;
        b2.Unit_No__c = objPUU1.id;
        b2.Quotation__c = q2.Id;
        b2.Booking_Date__c = Date.today();
        b2.Account__c = cpaccount.Id;
        b2.Type_of_Client__c = 'Local';
        b2.Status__c = 'Cancelled';
        b2.RW_Registration_Done__c = 'No';
        b2.BrokerIId__c = cp.Id;
        b2.Exclude_From_Brokerage_Batch__c = false;
        b2.Brokerage_Scheme__c = bscheme.Id;
        b2.Source_of_Booking__c = 'Channel Partner';
        b2.Allotment_Premium__c = 10000000;
        b2.Base_Brokerage__c = 2;
        b2.Kicker_Incentive_lookup__c = ki.Id;
        insert b2;
        
        Brokerage_Summary__c bs = new Brokerage_Summary__c();
        bs.Channel_Partner__c = cp.Id;
        bs.Opportunity__c = objcustomer.Id;
        bs.CP_Account__c = cpaccount.Id;
        bs.Applied_Slab_Name__c = 'Slab 2';
        bs.Show_Invoice__c = true;
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
        insert bro;
        
        Brokerage_Invoice__c bi = new Brokerage_Invoice__c();
        bi.Brokerage_Summary__c = bs.id;
        bi.Brokerage_Lookup__c = bro.id;
        bi.Channel_Partner__c = cp.Id;
        insert bi;
        
        List<Id> acId = new List<Id>();
        acId.add(cpaccount.id);
        EnableCPPortaluser.EnableCustomerCommunityUser(acId);
        system.debug('cpAccount:::'+cpaccount);
        User u = [Select Id,name from User where Email =: 'teststetig43646@stetig.in'];
        system.runAs(u){
            CPBookingController.getInvoice('searchKey', null, null, 'searchKeystatus');
            CPBookingController.getCpMandateInvoice('searchKey', null, null, 'searchKeystatus');//Added by coServe 14-06-2024
            CPBookingController.getBrokerageSummary('BssearchKey', 'searchKeyBooking');
            CPBookingController.getOTPs('custname', 'projectname');
            CPBookingController.CPKickerBookings(ki.Id);
            CPBookingController.getBrokerageSummaryCountValue(bs.id);
            CPBookingController.ChannelPartnerId();
            CPBookingController.getProjectList();
            CPBookingController.getApprovers('Runwal Bliss');
            CPBookingController.UpdateGSTNo(cp.Id, '123456789012347');
            
        }
        test.stopTest();
    }
    @isTest
    public static void CPProfileUpdate3(){
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
        pl.CP_MIS__c = userinfo.getUserId();
        pl.CP_Sourcing_Head__c = userinfo.getUserId();
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
        objpr.RW_Status__c = 'Active';
        insert objpr;
        
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
     //   bscheme.Base_Brokerage_for_OS_NRI__c = 3;
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
        b.Brokerage_Scheme__c = null;
        b.Source_of_Booking__c = 'Channel Partner';
        b.Allotment_Premium__c = 10000000;
        b.Brokerage_Scheme__c = bscheme.Id;
        b.Base_Brokerage__c = 2;
        b.Kicker_Incentive_lookup__c = ki.id;
        insert b;
        Booking__c b2 = new Booking__c();
        b2.Customer__c = objcustomer2.Id;
        b2.Project__c = objpr.Id;
        b2.Opportunity__c = objcustomer2.Id;
        b2.Unit_No__c = objPUU1.id;
        b2.Quotation__c = q2.Id;
        b2.Booking_Date__c = Date.today();
        b2.Account__c = cpaccount.Id;
        b2.Type_of_Client__c = 'Local';
        b2.Status__c = 'Cancelled';
        b2.RW_Registration_Done__c = 'No';
        b2.BrokerIId__c = cp.Id;
        b2.Exclude_From_Brokerage_Batch__c = false;
        b2.Brokerage_Scheme__c = bscheme.Id;
        b2.Source_of_Booking__c = 'Channel Partner';
        b2.Allotment_Premium__c = 10000000;
        b2.Base_Brokerage__c = 2;
        b2.Kicker_Incentive_lookup__c = ki.Id;
        insert b2;
        
        Brokerage_Summary__c bs = new Brokerage_Summary__c();
        bs.Channel_Partner__c = cp.Id;
        bs.Opportunity__c = objcustomer.Id;
        bs.CP_Account__c = cpaccount.Id;
        bs.Applied_Slab_Name__c = 'Slab 2';
        bs.Show_Invoice__c = true;
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
        insert bro;
        
        Brokerage_Invoice__c bi = new Brokerage_Invoice__c();
        bi.Brokerage_Summary__c = bs.id;
        bi.Brokerage_Lookup__c = bro.id;
        bi.Channel_Partner__c = cp.Id;
        insert bi;
        
        List<Id> acId = new List<Id>();
        acId.add(cpaccount.id);
        EnableCPPortaluser.EnableCustomerCommunityUser(acId);
        system.debug('cpAccount:::'+cpaccount);
        User u = [Select Id,name from User where Email =: 'teststetig43646@stetig.in'];
        system.runAs(u){
            CPBookingController.UpdateRERANo(cp.Id, '123456789009');
            CPBookingController.RERAPresent(cp.Id);
            CPBookingController.GSTPresent(cp.Id);
            CPBookingController.CheckForGSTNo(bi.Id);
            CPBookingController.getbookings('projectname', 'custname', 'Unitno', 'Yes', 'Yes');
            CPBookingController.getCPDetails();
            CPBookingController.registrationcomplete(cp.Id);
            CPBookingController.updateChannelPartner(cp);
            CommunityAuthController.isEmailExist('teststetig43646@stetig.in');
        }
        test.stopTest();
    }
     @isTest
    public static void CPProfileUpdate4(){
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
        
        Broker__c cp2 = new Broker__c();
        cp2.Name = 'Test CP';
        cp2.RW_Email__c = 'teststetig43646@stetig.in';
        cp2.Individual_CP__c = true;
        cp2.RW_CreateFromIRIS__c = true;
        cp2.RW_IRIS_Sync__c = true;
        cp2.Place_of_Supply__c = 'Maharashtra';
        cp2.Channel_Partner_From_CP_Portal__c = true;
        cp2.Project__c = 'Runwal Bliss';
        cp2.Approver_L1__c = userinfo.getUserId();
        cp2.Approver_L2__c = userinfo.getUserId();
        cp2.Registration_Complete__c = true;
        cp2.RW_Mobile_No__c = '1234567890';
        cp2.Broker_Type__c = 'Individual';
        cp2.Broker_Pan_No__c = 'ADRPI3525F';
        cp2.RW_Mobile_No__c = '1234567890';
        cp2.NAME_FIRST__c = 'tets';
        cp2.NAME_MIDDLE__c = 'cp';
        cp2.NAME_LAST__c = 'test';
        cp2.TITLE__c = 'Mr.';
        cp2.Account_Number__c = '465446';
        cp2.Cheque_DD_Favouring_Name__c = 'test cp';
        cp2.IFSC_Code__c = 'BHSHVD';
        cp2.Is_NRI_CP__c = false;
        cp2.RW_Is_GST_Applicable__c = true;
        cp2.Channel_Partner_From_CP_Portal__c =true;
        
        Broker__c cp3 = new Broker__c();
        cp3.Name = 'Test CP';
        cp3.RW_Email__c = 'teststetig43646@stetig.in';
        cp3.Individual_CP__c = true;
        cp3.RW_CreateFromIRIS__c = true;
        cp3.RW_IRIS_Sync__c = true;
        cp3.Place_of_Supply__c = 'Maharashtra';
        cp3.Channel_Partner_From_CP_Portal__c = true;
        cp3.Project__c = 'Runwal Bliss';
        cp3.Approver_L1__c = userinfo.getUserId();
        cp3.Approver_L2__c = userinfo.getUserId();
        cp3.Registration_Complete__c = true;
        cp3.RW_Mobile_No__c = '1234567890';
        cp3.Broker_Type__c = 'Individual';
        cp3.Broker_Pan_No__c = 'ADRPI3525Q';
        cp3.RW_Mobile_No__c = '1234567890';
        cp3.NAME_FIRST__c = 'tets';
        cp3.NAME_MIDDLE__c = 'cp';
        cp3.NAME_LAST__c = 'test';
        cp3.TITLE__c = 'Mr.';
        cp3.Account_Number__c = '465446';
        cp3.Cheque_DD_Favouring_Name__c = 'test cp';
        cp3.IFSC_Code__c = 'BHSHVD';
        cp3.Is_NRI_CP__c = false;
        cp3.RW_Is_GST_Applicable__c = true;
        cp3.Channel_Partner_From_CP_Portal__c =true;
        
        Broker__c cp4 = new Broker__c();
        cp4.Name = 'Test CP';
        cp4.RW_Email__c = 'teststetig43646@stetig.in';
        cp4.Individual_CP__c = true;
        cp4.RW_CreateFromIRIS__c = true;
        cp4.RW_IRIS_Sync__c = true;
        cp4.Place_of_Supply__c = 'Maharashtra';
        cp4.Channel_Partner_From_CP_Portal__c = true;
        cp4.Project__c = 'Runwal Bliss';
        cp4.Approver_L1__c = userinfo.getUserId();
        cp4.Approver_L2__c = userinfo.getUserId();
        cp4.Registration_Complete__c = true;
        cp4.RW_Mobile_No__c = '1234567890';
        cp4.Broker_Type__c = 'Individual';
        cp4.Broker_Pan_No__c = 'ADRPI3525A';
        cp4.RW_Mobile_No__c = '1234567890';
        cp4.NAME_FIRST__c = 'tets';
        cp4.NAME_MIDDLE__c = 'cp';
        cp4.NAME_LAST__c = 'test';
        cp4.TITLE__c = 'Mr.';
        cp4.Account_Number__c = '465446';
        cp4.Cheque_DD_Favouring_Name__c = 'test cp';
        cp4.IFSC_Code__c = 'BHSHVD';
        cp4.Is_NRI_CP__c = false;
        cp4.RW_Is_GST_Applicable__c = true;
        cp4.Channel_Partner_From_CP_Portal__c =true;
        cp4.Company_Name_As_per_RERA__c = 'Test CP';
        insert cp4;
        cp4.Account__c = null;
        update cp4;
        
        Broker__c cp5 = new Broker__c();
        cp5.Name = 'Test CP';
        cp5.RW_Email__c = 'teststetig43646@stetig.in';
        cp5.Individual_CP__c = true;
        cp5.RW_CreateFromIRIS__c = true;
        cp5.RW_IRIS_Sync__c = true;
        cp5.Place_of_Supply__c = 'Maharashtra';
        cp5.Channel_Partner_From_CP_Portal__c = true;
        cp5.Project__c = 'Runwal Bliss';
        cp5.Approver_L1__c = userinfo.getUserId();
        cp5.Approver_L2__c = userinfo.getUserId();
        cp5.Registration_Complete__c = true;
        cp5.RW_Mobile_No__c = '1234567890';
        cp5.Broker_Type__c = 'Individual';
        cp5.Broker_Pan_No__c = 'ADRPI3525B';
        cp5.RW_Mobile_No__c = '1234567890';
        cp5.NAME_FIRST__c = 'tets';
        cp5.NAME_MIDDLE__c = 'cp';
        cp5.NAME_LAST__c = 'test';
        cp5.TITLE__c = 'Mr.';
        cp5.Account_Number__c = '465446';
        cp5.Cheque_DD_Favouring_Name__c = 'test cp';
        cp5.IFSC_Code__c = 'BHSHVD';
        cp5.Is_NRI_CP__c = false;
        cp5.RW_Is_GST_Applicable__c = true;
        cp5.Channel_Partner_From_CP_Portal__c =true;
        cp5.Company_Name_As_per_RERA__c = 'Test CP';
        insert cp5;
        cp5.Account__c = null;
        update cp5;
        
        Sobject objRecord = new Broker__c(
            Name = 'Test CP',
            RW_Email__c = 'teststetig43646@stetig.in',
            Individual_CP__c = true,
            RW_CreateFromIRIS__c = true,
            RW_IRIS_Sync__c = true,
            Place_of_Supply__c = 'Maharashtra',
            Project__c = 'Runwal Bliss',
            Approver_L1__c = userinfo.getUserId(),
            Approver_L2__c = userinfo.getUserId(),
            Registration_Complete__c = true,
            RW_Mobile_No__c = '1234567890',
            Broker_Type__c = 'Individual',
            Broker_Pan_No__c = 'ADRPI3525Q',
            NAME_FIRST__c = 'tets',
            NAME_MIDDLE__c = 'cp',
            NAME_LAST__c = 'test',
            TITLE__c = 'Mr.',
            Account_Number__c = '465446',
            Cheque_DD_Favouring_Name__c = 'test cp',
            IFSC_Code__c = 'BHSHVD',
            Is_NRI_CP__c = false,
            RW_Is_GST_Applicable__c = true,
            Channel_Partner_From_CP_Portal__c =true);
        
        Account cpaccount = [Select Id,Name,Channel_Partner__c from Account where Channel_Partner__c =: cp.Id];
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@stetig.in.com','9098777',false);
        
        Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.RW_Status__c = 'Active';
        insert objpr;
        
        Opportunity objcustomer= new Opportunity();
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
        
        Collateral__c c = new Collateral__c();
        c.Project__c = objpr.id;
        insert c;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = c.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        List<Id> acId = new List<Id>();
        acId.add(cpaccount.id);
        EnableCPPortaluser.EnableCustomerCommunityUser(acId);
        system.debug('cpAccount:::'+cpaccount);
        User u = [Select Id,name from User where Email =: 'teststetig43646@stetig.in'];
        system.runAs(u){
            CPBookingController.selfregister(cp4);
            CPBookingController.selfregister(cp5);
        }
    }
    
    @isTest
    static void testSaveFiles() {
        // Step 1: Create a test record (e.g., an Account) to associate with files
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Step 2: Mock file data to simulate input
        List<Object> filesToInsert = new List<Object>();
        
        // Adding two mock files
        filesToInsert.add(new TestCPProfileUpdate.FileInfo('TestFile1.txt', Blob.valueOf('Test content 1')));
        filesToInsert.add(new TestCPProfileUpdate.FileInfo('TestFile2.txt', Blob.valueOf('Test content 2')));

        // Step 3: Test the saveFiles method
        Test.startTest();
        List<Id> contentVersionIds = CPBookingController.saveFiles(filesToInsert, testAccount.Id);
        Test.stopTest();

    }
		
    
    // Helper class for mocking file input data
    public class FileInfo {
        public String Title;
        public Blob VersionData;

        public FileInfo(String title, Blob versionData) {
            this.Title = title;
            this.VersionData = versionData;
        }
    }
}