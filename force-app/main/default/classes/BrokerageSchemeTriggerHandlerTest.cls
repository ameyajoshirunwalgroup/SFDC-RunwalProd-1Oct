@isTest
private class BrokerageSchemeTriggerHandlerTest {
    @testSetup
    static void setupData() {

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
        
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@stetig.in.com','9098777',false);
		//Account cpaccount = [Select Id,Name,Channel_Partner__c from Account where Channel_Partner__c =: cp.Id];
        
        Account cpaccount = new Account();
        cpaccount.Name = 'Test account6378';
        cpaccount.Channel_Partner__c = cp.id;
        insert cpaccount;
        
        Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.RW_Status__c = 'Active';
        insert objpr;
        
        
        
        
         // Create Project Location
        Project_Location__c pl = new Project_Location__c(
            Name = 'Mumbai',
            Approver_L1__c = userinfo.getUserId(),
            Approver_L2__c = userinfo.getUserId(),
            Location__c = 'Mumbai'
        );
        insert pl;
        
        // Create Tower (if Tower__r is used)
        Tower__c tower = new Tower__c(Name = 'Tower A', ProjectName__c	 = objpr.Id);
        insert tower;
        
        Project_Unit_Type__c objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.id;
        insert objPUT;
        
        Project_Unit__c objPUU = new Project_Unit__c();  
        objPUU.Project_Unit_Type__c = objPUT.id;  
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c = objpr.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.TowerName__c = tower.Id;
        objPUU.RW_Unit_Status__c ='Available';
        insert objPUU;
        
        // Create Brokerage Scheme
        Brokerage_Scheme__c bscheme = new Brokerage_Scheme__c(
            Name = 'Test Scheme',
            Type__c = 'Both',
            Approval_Status__c = 'Approved by Level 2',
            Base_Brokerage_for_Local_Bookings__c = 2,
            Base_Brokerage_for_OS_NRI__c = 3,
            Base_Brokerage_for_NRI__c= 2.5,
            Slab_Type__c = 'Count',
            Start_Date__c = Date.today().addDays(-1),
            End_Date__c = Date.today().addDays(2),
            Project_Location__c = pl.Id,
            AOP_CP__c = 5
        );
        insert bscheme;

        // Create Scheme Configuration
        Scheme_Configuration__c sc = new Scheme_Configuration__c(
            Name = 'Scheme Conf',
            Brokerage_Scheme__c = bscheme.Id,
            Project__c = objpr.Id,
            Tower__c = tower.Id
        );
        insert sc;
        
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
        
        List<Quotation__c> quotationList = new List<Quotation__c>();
        Quotation__c q = new Quotation__c();
        q.Name = 'Q010101';
        q.Quote_Status__c = 'Valid';
        q.Prepared_Date__c = System.today();
        q.Project__c = objpr.Id;
        //q.Project_Unit__c = objPUU.Id;
        q.FloorNo__c = 11;
        q.Opportunity__c = objcustomer.Id;
        q.Appartment_Configuration__c = '1 BHK';
        q.Carpet_Area_Sq_Ft__c = 1200;
        q.Token_Amount__c =110000;
        q.ST_Token_Amount__c = 1000;
        q.Allow_booking_without_full_token__c = TRUE;
        q.Agreement_Value__c = 60422880;
        q.Agreement_Value_ST__c = 2537761;
        q.Tandem_car_park_Additional__c = 1;
        q.Tandem_Open_Additional__c= 1;
        //q.Service_Tax_On_Token_Amount__c = true;
        q.Single_car_park_Additional__c= 1;
        q.Single_Open_Additional__c = 1;
        q.Stack_Additional__c = 1;
        q.MLCP_Additional__c = 1;
        q.Basement_Additional__c = 1;
        q.Podium__c = 1;
        q.Puzzle_Car_Park__c = 1;
        q.Agreement_Value_for_brokers__c  = 100000;
        quotationList.add(q);
        
        insert quotationList;
        list<Booking__c> blist = new list<Booking__c>();
        // Create Booking
        Booking__c booking = new Booking__c(
            Status__c = 'Booking Confirmed',
            Booking_Date__c = Date.today(),
            Type_of_Client__c = 'Local',
            Passback_Amount__c = 1000,
            Project__c = objpr.Id,
            Tower__c = tower.Id,
            BrokerIId__c = cp.Id,
            Opportunity__c = objcustomer.id,
            Quotation__c = quotationList[0].Id,
            Brokerage_Scheme__c = null,
            Source_of_Booking__c = 'Channel Partner',
            Exclude_From_Brokerage_Batch__c = false,
            Brokerage_Summary__c = null,
            Unit_No__c = objPUU.Id
            
        );
        blist.add(booking);
        
        Booking__c booking2 = new Booking__c(
            Status__c = 'Booking Confirmed',
            Booking_Date__c = Date.today(),
            Type_of_Client__c = 'NRI',
            Passback_Amount__c = 1000,
            Project__c = objpr.Id,
            Tower__c = tower.Id,
            BrokerIId__c = cp.Id,
            Opportunity__c = objcustomer.id,
            Quotation__c = quotationList[0].Id,
            Brokerage_Scheme__c = null,
            Source_of_Booking__c = 'Channel Partner',
            Exclude_From_Brokerage_Batch__c = false,
            Brokerage_Summary__c = null,
            Unit_No__c = objPUU.Id
            
        );
        blist.add(booking2);
        
        Booking__c booking3 = new Booking__c(
            Status__c = 'Booking Confirmed',
            Booking_Date__c = Date.today(),
            Type_of_Client__c = 'Outstation',
            Passback_Amount__c = 1000,
            Project__c = objpr.Id,
            Tower__c = tower.Id,
            BrokerIId__c = cp.Id,
            Opportunity__c = objcustomer.id,
            Quotation__c = quotationList[0].Id,
            Brokerage_Scheme__c = null,
            Source_of_Booking__c = 'Channel Partner',
            Exclude_From_Brokerage_Batch__c = false,
            Brokerage_Summary__c = null,
            Unit_No__c = objPUU.Id
            
        );
        blist.add(booking3);
        
        insert blist;
    }

    @isTest
    static void testBrokerageSchemeTagging() {
        List<Brokerage_Scheme__c> schemes = [SELECT Id FROM Brokerage_Scheme__c];  
        list<id> schIds = new list<Id>();
        for(Brokerage_Scheme__c bs : schemes){
          schIds.add(bs.id);  
        }
        Booking__c booking= [Select Id,Status__c,Booking_Date__c,Type_of_Client__c,Passback_Amount__c,Project__c,Tower__c,BrokerIId__c,Opportunity__c,Quotation__c
                             ,Brokerage_Scheme__c,Source_of_Booking__c,Exclude_From_Brokerage_Batch__c,Brokerage_Summary__c   from Booking__c limit 1];
        System.debug('booking -> ' + booking);
        System.debug('booking.Status__c -> ' + booking.Status__c);
        System.debug('booking.Booking_Date__c -> ' + booking.Booking_Date__c);
        System.debug('booking.Type_of_Client__c -> ' + booking.Type_of_Client__c);
        System.debug('booking.Passback_Amount__c -> ' + booking.Passback_Amount__c);
        System.debug('booking.Project__c -> ' + booking.Project__c);
        System.debug('booking.Tower__c -> ' + booking.Tower__c);
        System.debug('booking.BrokerIId__c -> ' + booking.BrokerIId__c);
        System.debug('booking.Opportunity__c -> ' + booking.Opportunity__c);
        System.debug('booking.Quotation__c -> ' + booking.Quotation__c);
        System.debug('booking.Brokerage_Scheme__c -> ' + booking.Brokerage_Scheme__c);
        System.debug('booking.Source_of_Booking__c -> ' + booking.Source_of_Booking__c);
        System.debug('booking.Exclude_From_Brokerage_Batch__c -> ' + booking.Exclude_From_Brokerage_Batch__c);
        System.debug('booking.Brokerage_Summary__c -> ' + booking.Brokerage_Summary__c);
        
        Test.startTest();
        BrokerageSchemeTriggerHandler.BrokerageSchemeTagging(schIds);
        Test.stopTest();
    }
}