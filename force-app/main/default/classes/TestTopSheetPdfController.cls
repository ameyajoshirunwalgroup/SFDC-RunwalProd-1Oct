@isTest
public class TestTopSheetPdfController {
    @isTest
    public static void TopSheetPdf(){
        Test.startTest();
        Opportunity objcustomer;
        Booking__c objBooking;
        Project__c objpr;
        Project_Unit__c objPUU;
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
        insert cp;
        
        Legal_Entity__c le = new Legal_Entity__c();
        le.RDS_Company_Code__c = '1000';
        le.Name = 'Test Company';
        insert le;
        
        objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.Project_Location__c = pl.id;
        objpr.RDS_Company_Code__c = le.Id;
        insert objpr;
        
        Tower__c t = new Tower__c();
        t.ProjectName__c = objpr.id;
        t.Legal_Entity__c = le.id;
        insert t;
        
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
                
        Brokerage_Scheme__c bscheme = new Brokerage_Scheme__c();
        bscheme.Type__c = 'Both';
        bscheme.Approval_Status__c = 'Approved by Level 2';
        bscheme.Base_Brokerage_for_Local_Bookings__c = 2;
        bscheme.Base_Brokerage_for_OS_NRI__c = 3;
        bscheme.Slab_Type__c = 'Value';
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
        b.RW_Total_Receipt_Amount_Received__c = 1000;
        b.Kicker_Incentive_lookup__c = ki.id;
        b.Tower__c = t.Id;
        insert b;
        Booking__c b2 = new Booking__c();
        b2.Customer__c = objcustomer.Id;
        b2.Project__c = objpr.Id;
        b2.Opportunity__c = objcustomer.Id;
        b2.Unit_No__c = objPUU.id;
        b2.Quotation__c = q.Id;
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
        b2.Tower__c = t.Id;
        insert b2;
        
        Brokerage_Summary__c bs = new Brokerage_Summary__c();
        bs.Channel_Partner__c = cp.Id;
        bs.Opportunity__c = objcustomer.Id;
        bs.CP_Account__c = cpaccount.Id;
        bs.Applied_Slab_Name__c = 'Slab 2';
        bs.Booking__c = b.Id;
        insert bs;
        
        Brokerage__c bro = new Brokerage__c();
        bro.Name = 'Base Brokerage';
        bro.Brokerage__c = 2;
        bro.Brokerage_Amount__c = 272059;
        bro.Brokerage_Type__c = 'Base Brokerage';
        bro.Booking__c = b.Id;
        bro.Brokerage_Summary__c = bs.id;
        insert bro;
        
        Brokerage_Invoice__c bi = new Brokerage_Invoice__c();
        bi.Brokerage_Summary__c = bs.id;
        bi.Brokerage_Lookup__c = bro.id;
        bi.Channel_Partner__c = cp.Id;
        bi.Booking__c = b.Id;
        bi.Invoice_Number__c = '35352';
        bi.Brokerage__c = 2;
        bi.Total_Agreement_Value__c = 13602975;
        bi.Invoice_Status__c = 'Not Submitted';
        bi.Opportunity__c = objcustomer.Id;
        bi.Invoice_Date__c = system.today();
        bi.Brokerage_In_Rs__c = 53633;
        bi.Invoice_Amount__c = 6000000;
        bi.CGST__c = '1000';
        bi.IGST__c = '500';
        bi.SGST__c = '1000';
        bi.SAP_TDS__c = 100;
        bi.CP_Invoice_Approver_L1__c = userinfo.getUserId();
        bi.CP_Invoice_Approver_L2__c = userinfo.getUserId();
        bi.CP_Invoice_Approver_L3__c = userinfo.getUserId();
        bi.CP_Invoice_Approver_L4__c = userinfo.getUserId();
        bi.CP_Invoice_Approver_L5__c = userinfo.getUserId();        
        insert bi;
          
        PageReference TopSheetPdf1 = Page.TopSheetPdf;
        Test.setCurrentPage(TopSheetPdf1);
        ApexPages.currentPage().getParameters().put('id',bi.Id);
        TopSheetPdfController topsheet= new TopSheetPdfController();       
        test.stopTest();
        
    }
    
}