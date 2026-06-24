@isTest
public class TestBatchRunFromButton {
    
    @isTest
    public static void testbms1(){
        
        
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
        
        list<Brokerage_Slab__c> bslablist = new list<Brokerage_Slab__c>();
        Brokerage_Slab__c bslab = new Brokerage_Slab__c();
        bslab.Name = 'Slab 2';
        bslab.From__c = 0;
        bslab.To__c = 1;
        bslab.Additional_Brokerage_for_Local_Bookings__c = 0;
        bslab.Additional_Brokerage_for_OS_NRI__c = 0;
        bslab.Brokerage_Scheme__c = bscheme.Id;
        bslablist.add(bslab);
        
        Brokerage_Slab__c bslab2 = new Brokerage_Slab__c();
        bslab2.Name = 'Slab 2';
        bslab2.From__c = 2;
        bslab2.To__c = null;
        bslab2.Additional_Brokerage_for_Local_Bookings__c = 0.25;
        bslab2.Additional_Brokerage_for_OS_NRI__c = 0.25;
        bslab2.Brokerage_Scheme__c = bscheme.Id;
        bslablist.add(bslab2);
        insert bslablist;
        
        Scheme_Configuration__c sc = new Scheme_Configuration__c();
        sc.Name = 'Oct';
        sc.Brokerage_Scheme__c = bscheme.Id;
        sc.Project__c = objpr.id;
        insert sc;
          
        objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.id;
        insert objPUT;
          
        list<Project_Unit__c> pulist = new list<Project_Unit__c>();
        objPUU = new Project_Unit__c();  
        objPUU.Project_Unit_Type__c = objPUT.id;  
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c = objpr.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.RW_Unit_Status__c ='Available';
        pulist.add(objPUU);
        
        objPUU1 = new Project_Unit__c();  
        objPUU1.Project_Unit_Type__c = objPUT.id;  
        objPUU1.Name = 'TestUnit1';      
        objPUU1.RW_Project__c = objpr.Id;
        objPUU1.RW_Param1__c = '5';
        objPUU1.UnitNo__c ='10';
        objPUU1.RW_Unit_Status__c ='Available';
        pulist.add(objPUU1);
        
        
        
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
        cp.Company_Name_As_per_RERA__c = 'Test Company';
        insert cp;
        //Account cpaccount = [Select Id,Name,Channel_Partner__c from Account where Channel_Partner__c =: cp.Id];
        Account cpaccount = new Account();
        cpaccount.Name = cp.Company_Name_As_per_RERA__c;
        cpaccount.CP_Email__c = cp.RW_Email__c;
        cpaccount.Mobile_No__c = cp.RW_Mobile_No__c;
        cpaccount.Channel_Partner__c = cp.id;
        cpaccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
        insert cpaccount;
        List<Opportunity> oppList = new List<Opportunity>();
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
        oppList.add(objcustomer);
        //insert objcustomer;
        
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
        //insert objcustomer1;
        oppList.add(objcustomer1);
      	
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
        oppList.add(objcustomer2);
        insert oppList;
        
        
       // insert rlist1;
       // 
       List<Booking__c> bookingList = new List<Booking__c>();
        
        Booking__c b = new Booking__c();
        b.Customer__c = objcustomer.Id;
        b.Project__c = objpr.Id;
        b.Opportunity__c = objcustomer.Id;
        b.Unit_No__c = objPUU.id;
        //b.Receipts__c = r1.Id;
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
        b.Checklist_Approved__c = true;
        
        bookingList.add(b);
        BIds.add(b.Id);
        Booking__c b2 = new Booking__c();
        b2.Customer__c = objcustomer1.Id;
        b2.Project__c = objpr.Id;
        b2.Opportunity__c = objcustomer1.Id;
        b2.Unit_No__c = objPUU1.id;
        //b2.Receipts__c = r2.Id;
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
        b2.Checklist_Approved__c = true;
        bookingList.add(b2);
        //BIds.add(b2.Id);
        
        Booking__c b3 = new Booking__c();
        b3.Customer__c = objcustomer.Id;
        b3.Project__c = objpr.Id;
        b3.Opportunity__c = objcustomer.Id;
        b3.Unit_No__c = objPUU.id;
        //b3.Receipts__c = r1.Id;
        b3.Booking_Date__c = Date.today();
        b3.Account__c = cpaccount.Id;
        b3.Type_of_Client__c = 'NRI';
        //b3.Tower__c = t[0].Id;
        b3.Status__c = 'Booking Confirmed';
        b3.RW_Registration_Done__c = 'No';
        b3.BrokerIId__c = cp.Id;
        b3.Exclude_From_Brokerage_Batch__c = false;
        b3.Checklist_Approved__c = true;
        b3.Brokerage_Scheme__c = null;
        //b3.Brokerage_Summary__c = bs.id;

        b3.Source_of_Booking__c = 'Channel Partner';
        b3.RW_Registration_Date__c = Date.today();
        bookingList.add(b3);
        
        if(!bookingList.isEmpty()){
            insert bookingList;
        }
        
        
        
        
        BatchRunFromButton run = new BatchRunFromButton();
        try{
        run.BatchRun();
        }catch(Exception ex){
            
        }
        try{
        run.BatchRunCancellation();
        }catch(Exception ex){
            
        }
        try{
        run.BatchRunInactiveScheme();
        }catch(Exception ex){
            
        }
        
       
        
        PageReference Inactive = Page.BatchRunForInactiveBrokerageScheme;
        Test.setCurrentPage(Inactive);
        BatchRunFromButton run2 = new BatchRunFromButton();
        run2.Startdatename = Date.today();
        run2.Enddatename = Date.today();
        run2.BatchRunInactiveScheme();
       
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
        
        list<Brokerage_Slab__c> bslablist = new list<Brokerage_Slab__c>();
        Brokerage_Slab__c bslab = new Brokerage_Slab__c();
        bslab.Name = 'Slab 2';
        bslab.From__c = 0;
        bslab.To__c = 1;
        bslab.Additional_Brokerage_for_Local_Bookings__c = 0;
        bslab.Additional_Brokerage_for_OS_NRI__c = 0;
        bslab.Brokerage_Scheme__c = bscheme.Id;
        bslablist.add(bslab);
        
        Brokerage_Slab__c bslab2 = new Brokerage_Slab__c();
        bslab2.Name = 'Slab 2';
        bslab2.From__c = 2;
        bslab2.To__c = null;
        bslab2.Additional_Brokerage_for_Local_Bookings__c = 0.25;
        bslab2.Additional_Brokerage_for_OS_NRI__c = 0.25;
        bslab2.Brokerage_Scheme__c = bscheme.Id;
        bslablist.add(bslab2);
        insert bslablist;
        
        Scheme_Configuration__c sc = new Scheme_Configuration__c();
        sc.Name = 'Oct';
        sc.Brokerage_Scheme__c = bscheme.Id;
        sc.Project__c = objpr.id;
        insert sc;
          
        objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.id;
        insert objPUT;
          
        list<Project_Unit__c> pulist = new list<Project_Unit__c>();
        objPUU = new Project_Unit__c();  
        objPUU.Project_Unit_Type__c = objPUT.id;  
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c = objpr.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.RW_Unit_Status__c ='Available';
        pulist.add(objPUU);
        
        objPUU1 = new Project_Unit__c();  
        objPUU1.Project_Unit_Type__c = objPUT.id;  
        objPUU1.Name = 'TestUnit1';      
        objPUU1.RW_Project__c = objpr.Id;
        objPUU1.RW_Param1__c = '5';
        objPUU1.UnitNo__c ='10';
        objPUU1.RW_Unit_Status__c ='Available';
        pulist.add(objPUU1);
        
        
        
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
        cp.Company_Name_As_per_RERA__c = 'Test Company';
        insert cp;
        //Account cpaccount = [Select Id,Name,Channel_Partner__c from Account where Channel_Partner__c =: cp.Id];
        Account cpaccount = new Account();
        cpaccount.Name = cp.Company_Name_As_per_RERA__c;
        cpaccount.CP_Email__c = cp.RW_Email__c;
        cpaccount.Mobile_No__c = cp.RW_Mobile_No__c;
        cpaccount.Channel_Partner__c = cp.id;
        cpaccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
        insert cpaccount;
        List<Opportunity> oppList = new List<Opportunity>();
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
        //insert objcustomer;
        oppList.add(objcustomer);
        
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
        //insert objcustomer1;
        oppList.add(objcustomer1);
      	
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
        oppList.add(objcustomer2);
        insert oppList;
        
       // insert rlist1;
       // 
       List<Booking__c> bookingList = new List<Booking__c>();
        
        Booking__c b = new Booking__c();
        b.Customer__c = objcustomer.Id;
        b.Project__c = objpr.Id;
        b.Opportunity__c = objcustomer.Id;
        b.Unit_No__c = objPUU.id;
        //b.Receipts__c = r1.Id;
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
        b.Checklist_Approved__c = true;
        
        bookingList.add(b);
        BIds.add(b.Id);
        Booking__c b2 = new Booking__c();
        b2.Customer__c = objcustomer1.Id;
        b2.Project__c = objpr.Id;
        b2.Opportunity__c = objcustomer1.Id;
        b2.Unit_No__c = objPUU1.id;
        //b2.Receipts__c = r2.Id;
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
        b2.Checklist_Approved__c = true;
        bookingList.add(b2);
        //BIds.add(b2.Id);
        
        Booking__c b3 = new Booking__c();
        b3.Customer__c = objcustomer.Id;
        b3.Project__c = objpr.Id;
        b3.Opportunity__c = objcustomer.Id;
        b3.Unit_No__c = objPUU.id;
        //b3.Receipts__c = r1.Id;
        b3.Booking_Date__c = Date.today();
        b3.Account__c = cpaccount.Id;
        b3.Type_of_Client__c = 'NRI';
        //b3.Tower__c = t[0].Id;
        b3.Status__c = 'Booking Confirmed';
        b3.RW_Registration_Done__c = 'No';
        b3.BrokerIId__c = cp.Id;
        b3.Exclude_From_Brokerage_Batch__c = false;
        b3.Checklist_Approved__c = true;
        b3.Brokerage_Scheme__c = null;
        //b3.Brokerage_Summary__c = bs.id;

        b3.Source_of_Booking__c = 'Channel Partner';
        b3.RW_Registration_Date__c = Date.today();
        bookingList.add(b3);
        
        if(!bookingList.isEmpty()){
            insert bookingList;
        }
        
        
        
        
        BatchRunFromButton run = new BatchRunFromButton();
       
        run.Startdatename = Date.today();
        run.Enddatename = Date.today();
        run.LadderCreationManual = '1';
        try{
        run.BatchRunLadderBrokerage();
        }catch(Exception ex){
            
        }
        
        run.Home();
        
       
        
        PageReference Inactive = Page.BatchRunForInactiveBrokerageScheme;
        Test.setCurrentPage(Inactive);
        BatchRunFromButton run2 = new BatchRunFromButton();
        run2.Startdatename = Date.today();
        run2.Enddatename = Date.today();
        
        run2.BatchRunInactiveScheme();
       
    }

     @isTest
    public static void testbms3(){
        
        
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
        
        list<Brokerage_Slab__c> bslablist = new list<Brokerage_Slab__c>();
        Brokerage_Slab__c bslab = new Brokerage_Slab__c();
        bslab.Name = 'Slab 2';
        bslab.From__c = 0;
        bslab.To__c = 1;
        bslab.Additional_Brokerage_for_Local_Bookings__c = 0;
        bslab.Additional_Brokerage_for_OS_NRI__c = 0;
        bslab.Brokerage_Scheme__c = bscheme.Id;
        bslablist.add(bslab);
        
        Brokerage_Slab__c bslab2 = new Brokerage_Slab__c();
        bslab2.Name = 'Slab 2';
        bslab2.From__c = 2;
        bslab2.To__c = null;
        bslab2.Additional_Brokerage_for_Local_Bookings__c = 0.25;
        bslab2.Additional_Brokerage_for_OS_NRI__c = 0.25;
        bslab2.Brokerage_Scheme__c = bscheme.Id;
        bslablist.add(bslab2);
        insert bslablist;
        
        Scheme_Configuration__c sc = new Scheme_Configuration__c();
        sc.Name = 'Oct';
        sc.Brokerage_Scheme__c = bscheme.Id;
        sc.Project__c = objpr.id;
        insert sc;
          
        objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.id;
        insert objPUT;
          
        list<Project_Unit__c> pulist = new list<Project_Unit__c>();
        objPUU = new Project_Unit__c();  
        objPUU.Project_Unit_Type__c = objPUT.id;  
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c = objpr.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.RW_Unit_Status__c ='Available';
        pulist.add(objPUU);
        
        objPUU1 = new Project_Unit__c();  
        objPUU1.Project_Unit_Type__c = objPUT.id;  
        objPUU1.Name = 'TestUnit1';      
        objPUU1.RW_Project__c = objpr.Id;
        objPUU1.RW_Param1__c = '5';
        objPUU1.UnitNo__c ='10';
        objPUU1.RW_Unit_Status__c ='Available';
        pulist.add(objPUU1);
        
        
        
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
        cp.Company_Name_As_per_RERA__c = 'Test Company';
        insert cp;
        //Account cpaccount = [Select Id,Name,Channel_Partner__c from Account where Channel_Partner__c =: cp.Id];
        Account cpaccount = new Account();
        cpaccount.Name = cp.Company_Name_As_per_RERA__c;
        cpaccount.CP_Email__c = cp.RW_Email__c;
        cpaccount.Mobile_No__c = cp.RW_Mobile_No__c;
        cpaccount.Channel_Partner__c = cp.id;
        cpaccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
        insert cpaccount;
        List<Opportunity> oppList = new List<Opportunity>();
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
        //insert objcustomer;
        oppList.add(objcustomer);
        
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
        //insert objcustomer1;
        oppList.add(objcustomer1);
      	
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
        oppList.add(objcustomer2);
        
       // insert rlist1;
       // 
       List<Booking__c> bookingList = new List<Booking__c>();
        
        Booking__c b = new Booking__c();
        b.Customer__c = objcustomer.Id;
        b.Project__c = objpr.Id;
        b.Opportunity__c = objcustomer.Id;
        b.Unit_No__c = objPUU.id;
        //b.Receipts__c = r1.Id;
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
        b.Checklist_Approved__c = true;
        
        bookingList.add(b);
        BIds.add(b.Id);
        Booking__c b2 = new Booking__c();
        b2.Customer__c = objcustomer1.Id;
        b2.Project__c = objpr.Id;
        b2.Opportunity__c = objcustomer1.Id;
        b2.Unit_No__c = objPUU1.id;
        //b2.Receipts__c = r2.Id;
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
        b2.Checklist_Approved__c = true;
        bookingList.add(b2);
        //BIds.add(b2.Id);
        
        Booking__c b3 = new Booking__c();
        b3.Customer__c = objcustomer.Id;
        b3.Project__c = objpr.Id;
        b3.Opportunity__c = objcustomer.Id;
        b3.Unit_No__c = objPUU.id;
        //b3.Receipts__c = r1.Id;
        b3.Booking_Date__c = Date.today();
        b3.Account__c = cpaccount.Id;
        b3.Type_of_Client__c = 'NRI';
        //b3.Tower__c = t[0].Id;
        b3.Status__c = 'Booking Confirmed';
        b3.RW_Registration_Done__c = 'No';
        b3.BrokerIId__c = cp.Id;
        b3.Exclude_From_Brokerage_Batch__c = false;
        b3.Checklist_Approved__c = true;
        b3.Brokerage_Scheme__c = null;
        //b3.Brokerage_Summary__c = bs.id;

        b3.Source_of_Booking__c = 'Channel Partner';
        b3.RW_Registration_Date__c = Date.today();
        bookingList.add(b3);
        
        if(!bookingList.isEmpty()){
            insert bookingList;
        }
                
        BatchRunFromButton run = new BatchRunFromButton();
        try{
        run.BatchRunLadderBrokerageListView();
        }catch(Exception ex){
            
        }
       
    }
}