@isTest
public class BrokerageInvoiceReportControllerTest {
	
    @isTest
    public static void biReportTest(){
        
        /*Account acc = new Account();
        acc.RW_Email__c = 'test@mail.com';
        acc.LastName = 'Test';
        insert acc;*/
        
        Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.SAPMaterial_Code__c = '1211';
        objpr.RW_Project_Location_Videos_Link__c='test';
        objpr.RW_Project_Brochure_PublicUrl__c='test1';
		objpr.RW_SAP_Company_Code__c='5245';
        objpr.CP_Invoice_Clearing_L1__c = UserInfo.getUserId();
        objpr.CP_Invoice_Approver_L1__c = UserInfo.getUserId();
        objpr.CP_Invoice_Approver_L2__c = UserInfo.getUserId();
        objpr.CP_Invoice_Approver_L3__c = UserInfo.getUserId();
        objpr.CP_Invoice_Approver_L4__c = UserInfo.getUserId();
        objpr.CP_Invoice_Clearing_L2__c = UserInfo.getUserId();
        insert objpr;
        
        Brokerage_Scheme__c bscheme = new Brokerage_Scheme__c();
        bscheme.Type__c = 'Both';
        bscheme.Approval_Status__c = 'Approved by Level 2';
        bscheme.Base_Brokerage_for_Local_Bookings__c = 2;
        bscheme.Base_Brokerage_for_OS_NRI__c = 3;
        bscheme.Slab_Type__c = 'Value';
        bscheme.Start_Date__c = system.today();
        bscheme.End_Date__c = system.today()+2;
        insert bscheme;
        
        Opportunity objcustomer= new Opportunity();
        objcustomer.name='Test 1';
        //objcustomer.AccountId = acc.Id;
        objcustomer.StageName='Qualification';
        objcustomer.CloseDate=system.today();
        objcustomer.Status__c ='Active';
        objcustomer.Sales_Manager__c = 'SM2@g.com';
        objcustomer.RW_Type_of_Client__c = 'Local';
        objcustomer.RW_RM_Email__c = 'test@mail.com';
        objcustomer.RW_Mobile_No__c = '2564789658';
        insert objcustomer;
        
        Booking__c b = new Booking__c();
        b.Opportunity__c = objcustomer.Id;
        b.Booking_Date__c = Date.today();
        b.Type_of_Client__c = 'Local';
        b.Status__c = 'Booking Confirmed';
        b.RW_Registration_Done__c = 'No';
        b.Exclude_From_Brokerage_Batch__c = false;
        b.Brokerage_Scheme__c = null;
        b.Allotment_Premium__c = 10000000;
        b.Brokerage_Scheme__c = bscheme.Id;
        b.CP_Invoice_Clearing_L1__c = UserInfo.getUserId();
        b.Base_Brokerage__c = 2;
        b.Project__c = objpr.Id;
        b.Is_AOP_CP_Applicable__c = true;
        insert b;
        
        Brokerage_Summary__c bs = new Brokerage_Summary__c();
        bs.Opportunity__c = objcustomer.Id;
        bs.Applied_Slab_Name__c = 'Slab 2';
        bs.Booking__c = b.Id;
        bs.Project_Lookup__c = objpr.Id;
        bs.Brokerage_Scheme__c = bscheme.Id;
        insert bs;
        
        Brokerage__c bro = new Brokerage__c();
        bro.Name = 'Base Brokerage';
        bro.Brokerage__c = 2;
        bro.Brokerage_Amount__c = 272059;
        bro.Cancelled_Brokerage_Amount__c = 0;
        bro.Cancelled_Brokerage_percentage__c = 0;
        bro.Opportunity__c = objcustomer.Id;
        bro.Brokerage_Summary__c = bs.Id;
        bro.Opportunity_AV__c = 13602975;
        bro.Brokerage_Type__c = 'Base Brokerage';
        bro.Booking__c = b.Id;
        bro.Status__c = 'Due';
        insert bro;
        
        Brokerage__c bro1 = new Brokerage__c();
        bro1.Name = 'Base Brokerage';
        bro1.Brokerage__c = 2;
        bro1.Brokerage_Amount__c = 272059;
        bro1.Opportunity__c = objcustomer.Id;
        bro1.Brokerage_Summary__c = bs.Id;
        bro1.Opportunity_AV__c = 13602975;
        bro1.Brokerage_Type__c = 'Base Brokerage';
        bro1.Booking__c = b.Id;
        bro1.AOP_CP__c = true;
        bro1.Status__c = 'Due';
        insert bro1;
        
        Brokerage_Invoice__c bi = new Brokerage_Invoice__c();
        bi.Brokerage_Summary__c = bs.id;
        bi.Brokerage_Lookup__c = bro.id;
        bi.Booking__c = b.Id;
        bi.Invoice_Number__c = '35352';
        bi.If_GST_is_applicable__c = 'Yes';
        bi.Brokerage__c = 2;
        bi.Total_Agreement_Value__c = 13602975;
        bi.Invoice_Status__c = 'Not Submitted';
        bi.Opportunity__c = objcustomer.Id;
        bi.Invoice_Date__c = system.today();
        bi.Brokerage_In_Rs__c = 53633;
        bi.CP_Invoice_Approver_L1__c = userinfo.getUserId();
        bi.CP_Invoice_Approver_L2__c = userinfo.getUserId();
        bi.CP_Invoice_Approver_L4__c = userinfo.getUserId();
        bi.CP_Invoice_Approver_L5__c = userinfo.getUserId();
        insert bi;
                
        Test.startTest();
        //BrokerageInvoiceReportController biRep = new BrokerageInvoiceReportController();
        BrokerageInvoiceReportController.aopCpReportData(bscheme.Id, '');
        BrokerageInvoiceReportController.otherCpReportData(bscheme.Id, '');
        
        pageReference pageRef = page.BrokerageInvoiceReportPdf;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('scheme',bscheme.Id);
        ApexPages.currentPage().getParameters().put('cpId', '');
        BrokerageInvoiceReportControllerPdf broRep = new BrokerageInvoiceReportControllerPdf();
        Test.stopTest();
        
    }
    
    @isTest
    public static void biReportTest2(){
        
        /*Account acc = new Account();
        acc.RW_Email__c = 'test@mail.com';
        acc.LastName = 'Test';
        insert acc;*/
        
        Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.SAPMaterial_Code__c = '1211';
        objpr.RW_Project_Location_Videos_Link__c='test';
        objpr.RW_Project_Brochure_PublicUrl__c='test1';
		objpr.RW_SAP_Company_Code__c='5245';
        objpr.CP_Invoice_Clearing_L1__c = UserInfo.getUserId();
        objpr.CP_Invoice_Approver_L1__c = UserInfo.getUserId();
        objpr.CP_Invoice_Approver_L2__c = UserInfo.getUserId();
        objpr.CP_Invoice_Approver_L3__c = UserInfo.getUserId();
        objpr.CP_Invoice_Approver_L4__c = UserInfo.getUserId();
        objpr.CP_Invoice_Clearing_L2__c = UserInfo.getUserId();
        insert objpr;
        
        Brokerage_Scheme__c bscheme = new Brokerage_Scheme__c();
        bscheme.Type__c = 'Both';
        bscheme.Approval_Status__c = 'Approved by Level 2';
        bscheme.Base_Brokerage_for_Local_Bookings__c = 2;
        bscheme.Base_Brokerage_for_OS_NRI__c = 3;
        bscheme.Slab_Type__c = 'Value';
        bscheme.Start_Date__c = system.today();
        bscheme.End_Date__c = system.today()+2;
        insert bscheme;
        
        Opportunity objcustomer= new Opportunity();
        objcustomer.name='Test 1';
        //objcustomer.AccountId = acc.Id;
        objcustomer.StageName='Qualification';
        objcustomer.CloseDate=system.today();
        objcustomer.Status__c ='Active';
        objcustomer.Sales_Manager__c = 'SM2@g.com';
        objcustomer.RW_Type_of_Client__c = 'Local';
        objcustomer.RW_RM_Email__c = 'test@mail.com';
        objcustomer.RW_Mobile_No__c = '2564789658';
        insert objcustomer;
        
        Booking__c b = new Booking__c();
        b.Opportunity__c = objcustomer.Id;
        b.Booking_Date__c = Date.today();
        b.Type_of_Client__c = 'Local';
        b.Status__c = 'Booking Confirmed';
        b.RW_Registration_Done__c = 'No';
        b.Exclude_From_Brokerage_Batch__c = false;
        b.Brokerage_Scheme__c = null;
        b.Allotment_Premium__c = 10000000;
        b.Brokerage_Scheme__c = bscheme.Id;
        b.CP_Invoice_Clearing_L1__c = UserInfo.getUserId();
        b.Base_Brokerage__c = 2;
        b.Project__c = objpr.Id;
        b.Is_AOP_CP_Applicable__c = false;
        insert b;
        
        Brokerage_Summary__c bs = new Brokerage_Summary__c();
        bs.Opportunity__c = objcustomer.Id;
        bs.Applied_Slab_Name__c = 'Slab 2';
        bs.Booking__c = b.Id;
        bs.Project_Lookup__c = objpr.Id;
        bs.Brokerage_Scheme__c = bscheme.Id;
        insert bs;
        
        Brokerage__c bro = new Brokerage__c();
        bro.Name = 'Base Brokerage';
        bro.Brokerage__c = 2;
        bro.Brokerage_Amount__c = 272059;
        bro.Cancelled_Brokerage_Amount__c = 0;
        bro.Cancelled_Brokerage_percentage__c = 0;
        bro.Opportunity__c = objcustomer.Id;
        bro.Brokerage_Summary__c = bs.Id;
        bro.Opportunity_AV__c = 13602975;
        bro.Brokerage_Type__c = 'Base Brokerage';
        bro.Booking__c = b.Id;
        bro.Status__c = 'Due';
        insert bro;
        
        Brokerage__c bro1 = new Brokerage__c();
        bro1.Name = 'Base Brokerage';
        bro1.Brokerage__c = 2;
        bro1.Brokerage_Amount__c = 272059;
        bro1.Opportunity__c = objcustomer.Id;
        bro1.Brokerage_Summary__c = bs.Id;
        bro1.Opportunity_AV__c = 13602975;
        bro1.Brokerage_Type__c = 'Base Brokerage';
        bro1.Booking__c = b.Id;
        bro1.AOP_CP__c = true;
        bro1.Status__c = 'Due';
        insert bro1;
        
        Brokerage_Invoice__c bi = new Brokerage_Invoice__c();
        bi.Brokerage_Summary__c = bs.id;
        bi.Brokerage_Lookup__c = bro.id;
        bi.Booking__c = b.Id;
        bi.Invoice_Number__c = '35352';
        bi.If_GST_is_applicable__c = 'Yes';
        bi.Brokerage__c = 2;
        bi.Total_Agreement_Value__c = 13602975;
        bi.Invoice_Status__c = 'Not Submitted';
        bi.Opportunity__c = objcustomer.Id;
        bi.Invoice_Date__c = system.today();
        bi.Brokerage_In_Rs__c = 53633;
        bi.CP_Invoice_Approver_L1__c = userinfo.getUserId();
        bi.CP_Invoice_Approver_L2__c = userinfo.getUserId();
        bi.CP_Invoice_Approver_L4__c = userinfo.getUserId();
        bi.CP_Invoice_Approver_L5__c = userinfo.getUserId();
        insert bi;
                
        Test.startTest();
        //BrokerageInvoiceReportController biRep = new BrokerageInvoiceReportController();
        BrokerageInvoiceReportController.aopCpReportData(bscheme.Id, '');
        BrokerageInvoiceReportController.otherCpReportData(bscheme.Id, '');
        
        pageReference pageRef = page.BrokerageInvoiceReportPdf;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('scheme',bscheme.Id);
        ApexPages.currentPage().getParameters().put('cpId', '');
        BrokerageInvoiceReportControllerPdf broRep = new BrokerageInvoiceReportControllerPdf();
        Test.stopTest();
        
    }
}