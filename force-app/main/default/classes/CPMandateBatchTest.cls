@isTest
public class CPMandateBatchTest {
    
    @isTest
    public static void batchTest(){
        
        Broker__c cp = new 	Broker__c();
        cp.Name = 'Test CP';
        cp.RW_Mobile_No__c = '1234567890';
        cp.Broker_Pan_No__c = 'ASDER5433F';
        cp.SAP_CP_Code__c = '12345';
        insert cp;
        
        Id recordTypeId = Schema.SObjectType.AOP__c.getRecordTypeInfosByName().get('CP Mandate').getRecordTypeId();
        AOP__c aop = new AOP__c();
        aop.RecordTypeId = recordTypeId;
        aop.Start_Date__c = Date.today() - 10;
        aop.End_Date__c = Date.today() + 10;
        aop.Projects__c = 'Runwal Bliss';
        aop.Channel_Partner__c = cp.Id;
        aop.CP_Mandate_Scheme__c = 'Test Scheme';
        aop.Brokerage__c = 1.3;
        aop.Brokerage_for_Outstation__c = 1.5;
        aop.Brokerage_for_NRI__c = 2;
        aop.Approver_L1__c = UserInfo.getUserId();
        insert aop;
        
        Project__c proj = new Project__c();
        proj.Name = 'Runwal Bliss';
        insert proj;
        
        Legal_Entity__c le = new Legal_Entity__c();
        le.Name = 'Test Legal Entityyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy';
        insert le;

        Project_Unit__c unit = new Project_Unit__c();
        unit.Name = 'Test Unit';
        unit.RW_Unit_Status__c = 'Booked';
        unit.RW_Param1__c = 'RUNWAL BLISS';
        unit.RW_Project__c = proj.Id;
        unit.Legal_Entity__c = le.Id;
        unit.RW_Booking_Date__c = Date.today();
        insert unit;
        
        Booking__c bkg = new Booking__c();
        bkg.RW_Registration_Date__c = Date.today();
        bkg.Booking_Date__c = Datetime.now();
        bkg.Unit_No__c = unit.Id;
        bkg.Project__c = proj.Id;
        bkg.Status__c = 'Booking Confirmed';
        bkg.Allotment_Premium__c = 100000;
        bkg.Type_of_Client__c = 'Local';
        insert bkg;        
        CPMandateBatch b = new CPMandateBatch();
        b.execute(null); 
    }
    
     @isTest
    public static void batchTest1(){
        
        Broker__c cp = new 	Broker__c();
        cp.Name = 'Test CP';
        cp.RW_Mobile_No__c = '1234567890';
        cp.Broker_Pan_No__c = 'ASDER5433F';
        cp.SAP_CP_Code__c = '12345';
        insert cp;
        
        Id recordTypeId = Schema.SObjectType.AOP__c.getRecordTypeInfosByName().get('CP Mandate').getRecordTypeId();
        AOP__c aop = new AOP__c();
        aop.RecordTypeId = recordTypeId;
        aop.Start_Date__c = Date.today() - 10;
        aop.End_Date__c = Date.today() + 10;
        aop.Projects__c = 'Runwal Bliss';
        aop.Channel_Partner__c = cp.Id;
        aop.CP_Mandate_Scheme__c = 'Test Scheme';
        aop.Brokerage__c = 1.3;
        aop.Brokerage_for_Outstation__c = 1.5;
        aop.Brokerage_for_NRI__c = 2;
        aop.Approver_L1__c = UserInfo.getUserId();
        insert aop;
        
        Project__c proj = new Project__c();
        proj.Name = 'Runwal Bliss';
        insert proj;
        
        Legal_Entity__c le = new Legal_Entity__c();
        le.Name = 'Test Legal Entityyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy';
        insert le;

        Project_Unit__c unit = new Project_Unit__c();
        unit.Name = 'Test Unit';
        unit.RW_Unit_Status__c = 'Booked';
        unit.RW_Param1__c = 'RUNWAL BLISS';
        unit.RW_Project__c = proj.Id;
        unit.Legal_Entity__c = le.Id;
        unit.RW_Booking_Date__c = Date.today();
        insert unit;
        
        Booking__c bkg1 = new Booking__c();
        bkg1.Booking_Date__c = Datetime.now();
        bkg1.Unit_No__c = unit.Id;
        bkg1.Project__c = proj.Id;
        bkg1.Status__c = 'Booking Cancelled – Refund Pending';
        bkg1.Allotment_Premium__c = 100000;
        bkg1.Type_of_Client__c = 'NRI';
        bkg1.AOP_Mandate__c = 'Test AOP';
        bkg1.CP_Mandate_Invoice_Date__c = Date.today();
        insert bkg1;
        
        CPMandateBatch b = new CPMandateBatch();
        b.execute(null); 
    }
    
     @isTest
    public static void invoicePreviewTest1(){
        
        Broker__c cp = new 	Broker__c();
        cp.Name = 'Test CP';
        cp.RW_Mobile_No__c = '1234567890';
        cp.Broker_Pan_No__c = 'ASDER5433F';
        cp.SAP_CP_Code__c = '12345';
        insert cp;
        
        Id recordTypeId = Schema.SObjectType.AOP__c.getRecordTypeInfosByName().get('CP Mandate').getRecordTypeId();
        AOP__c aop = new AOP__c();
        aop.RecordTypeId = recordTypeId;
        aop.Start_Date__c = Date.today() - 10;
        aop.End_Date__c = Date.today() + 10;
        aop.Projects__c = 'Runwal Bliss';
        aop.Channel_Partner__c = cp.Id;
        aop.CP_Mandate_Scheme__c = 'Test Scheme';
        aop.Brokerage__c = 1.3;
        aop.Brokerage_for_Outstation__c = 1.5;
        aop.Brokerage_for_NRI__c = 2;
        aop.Approver_L1__c = UserInfo.getUserId();
        insert aop;
        
        AOP__c a = [SELECT Id, Name, Start_Date__c, End_Date__c, Projects__c, Channel_Partner__c, CP_Mandate_Scheme__c, Brokerage__c, Approver_L1__c, Approver_L2__c FROM AOP__c WHERE Id =: aop.Id];
        
        Project__c proj = new Project__c();
        proj.Name = 'Runwal Bliss';
        insert proj;
        
        Legal_Entity__c le = new Legal_Entity__c();
        le.Name = 'Test Legal Entity';
        insert le;

        Project_Unit__c unit = new Project_Unit__c();
        unit.Name = 'Test Unit';
        unit.RW_Unit_Status__c = 'Booked';
        unit.RW_Param1__c = 'RUNWAL BLISS';
        unit.RW_Project__c = proj.Id;
        unit.Legal_Entity__c = le.Id;
        unit.RW_Booking_Date__c = Date.today();
        insert unit;
        
        Booking__c bkg = new Booking__c();
        bkg.RW_Registration_Date__c = Date.today();
        bkg.Booking_Date__c = Datetime.now();
        bkg.Unit_No__c = unit.Id;
        bkg.Project__c = proj.Id;
        bkg.Status__c = 'Booking Confirmed';
        bkg.Allotment_Premium__c = 100000;
        bkg.AOP_Mandate__c = a.Name;
        insert bkg;
        System.debug('bkg.AOP_Mandate__c: ' + bkg.AOP_Mandate__c);
        
        Brokerage_Summary__c bs = new Brokerage_Summary__c();
        insert bs;
        
        Brokerage__c br = new Brokerage__c();
        br.Name = 'AOP Mandate';
        br.Brokerage_Summary__c = bs.Id;
        insert br;
        
        Brokerage_Invoice__c inv = new Brokerage_Invoice__c();
        inv.Channel_Partner__c = a.Channel_Partner__c;
        inv.Total_Agreement_Value__c = 100000;
        inv.AOP__c = a.Id;
        inv.Brokerage_Lookup__c = br.Id;
        inv.Legal_Entity__c = le.Id;
        inv.Brokerage__c = a.Brokerage__c;
        inv.Brokerage_In_Rs__c = (inv.Total_Agreement_Value__c * inv.Brokerage__c)/100;
        inv.Invoice_Amount__c = (inv.Total_Agreement_Value__c * inv.Brokerage__c)/100;
        inv.CP_Invoice_Clearing_L1__c = a.Approver_L1__c;
        inv.CP_Invoice_Clearing_L2__c = a.Approver_L2__c;
        inv.If_GST_is_applicable__c = 'Yes';
        inv.Booking_List__c = bkg.Name;
        insert inv;
        
        PageReference pRef1 = Page.CPMandateInvoicePreview;
        Test.setCurrentPage(pRef1);
        ApexPages.currentPage().getParameters().put('id',inv.Id);
        CPMandateInvoicePreview cf = new CPMandateInvoicePreview();
        
    }
    
     @isTest
    public static void invoicePreviewTest2(){
        
        Broker__c cp = new 	Broker__c();
        cp.Name = 'Test CP';
        cp.RW_Mobile_No__c = '1234567890';
        cp.Broker_Pan_No__c = 'ASDER5433F';
        cp.SAP_CP_Code__c = '12345';
        insert cp;
        
        Id recordTypeId = Schema.SObjectType.AOP__c.getRecordTypeInfosByName().get('CP Mandate').getRecordTypeId();
        AOP__c aop = new AOP__c();
        aop.RecordTypeId = recordTypeId;
        aop.Start_Date__c = Date.today() - 10;
        aop.End_Date__c = Date.today() + 10;
        aop.Projects__c = 'Runwal Bliss';
        aop.Channel_Partner__c = cp.Id;
        aop.CP_Mandate_Scheme__c = 'Test Scheme';
        aop.Brokerage__c = 1.3;
        aop.Brokerage_for_Outstation__c = 1.5;
        aop.Brokerage_for_NRI__c = 2;
        aop.Approver_L1__c = UserInfo.getUserId();
        insert aop;
        
        AOP__c a = [SELECT Id, Name, Start_Date__c, End_Date__c, Projects__c, Channel_Partner__c, CP_Mandate_Scheme__c, Brokerage__c, Approver_L1__c, Approver_L2__c FROM AOP__c WHERE Id =: aop.Id];
        
        Project__c proj = new Project__c();
        proj.Name = 'Runwal Bliss';
        insert proj;
        
        Legal_Entity__c le = new Legal_Entity__c();
        le.Name = 'Test Legal Entity';
        insert le;

        Project_Unit__c unit = new Project_Unit__c();
        unit.Name = 'Test Unit';
        unit.RW_Unit_Status__c = 'Booked';
        unit.RW_Param1__c = 'RUNWAL BLISS';
        unit.RW_Project__c = proj.Id;
        unit.Legal_Entity__c = le.Id;
        unit.RW_Booking_Date__c = Date.today();
        insert unit;
        
        Booking__c bkg = new Booking__c();
        bkg.RW_Registration_Date__c = Date.today();
        bkg.Booking_Date__c = Datetime.now();
        bkg.Unit_No__c = unit.Id;
        bkg.Project__c = proj.Id;
        bkg.Status__c = 'Cancelled';
        bkg.Allotment_Premium__c = 100000;
        bkg.AOP_Mandate__c = a.Name;
        insert bkg;
        System.debug('bkg.AOP_Mandate__c: ' + bkg.AOP_Mandate__c);
        
        Brokerage_Summary__c bs = new Brokerage_Summary__c();
        insert bs;
        
        Brokerage__c br = new Brokerage__c();
        br.Name = 'AOP Mandate';
        br.Brokerage_Summary__c = bs.Id;
        insert br;
        
        Brokerage_Invoice__c inv = new Brokerage_Invoice__c();
        inv.Channel_Partner__c = a.Channel_Partner__c;
        inv.Total_Agreement_Value__c = 100000;
        inv.AOP__c = a.Id;
        inv.Brokerage_Lookup__c = br.Id;
        inv.Legal_Entity__c = le.Id;
        inv.Brokerage__c = a.Brokerage__c;
        inv.Brokerage_In_Rs__c = (inv.Total_Agreement_Value__c * inv.Brokerage__c)/100;
        inv.Invoice_Amount__c = (inv.Total_Agreement_Value__c * inv.Brokerage__c)/100;
        inv.CP_Invoice_Clearing_L1__c = a.Approver_L1__c;
        inv.CP_Invoice_Clearing_L2__c = a.Approver_L2__c;
        inv.If_GST_is_applicable__c = 'Yes';
        inv.Booking_List__c = bkg.Name;
        insert inv;
        
        PageReference pRef1 = Page.CPMandateInvoicePreview;
        Test.setCurrentPage(pRef1);
        ApexPages.currentPage().getParameters().put('id',inv.Id);
        CPMandateInvoicePreview cf = new CPMandateInvoicePreview();
        
    }
    
    @isTest
    public static void invoicePreviewTest3(){
        
        Broker__c cp = new 	Broker__c();
        cp.Name = 'Test CP';
        cp.RW_Mobile_No__c = '1234567890';
        cp.Broker_Pan_No__c = 'ASDER5433F';
        cp.SAP_CP_Code__c = '12345';
        insert cp;
        
        Id recordTypeId = Schema.SObjectType.AOP__c.getRecordTypeInfosByName().get('CP Mandate').getRecordTypeId();
        AOP__c aop = new AOP__c();
        aop.RecordTypeId = recordTypeId;
        aop.Start_Date__c = Date.today() - 10;
        aop.End_Date__c = Date.today() + 10;
        aop.Projects__c = 'Runwal Bliss';
        aop.Channel_Partner__c = cp.Id;
        aop.CP_Mandate_Scheme__c = 'Test Scheme';
        aop.Brokerage__c = 1.3;
        aop.Brokerage_for_Outstation__c = 1.5;
        aop.Brokerage_for_NRI__c = 2;
        aop.Approver_L1__c = UserInfo.getUserId();
        insert aop;
        
        AOP__c a = [SELECT Id, Name, Start_Date__c, End_Date__c, Projects__c, Channel_Partner__c, CP_Mandate_Scheme__c, Brokerage__c, Approver_L1__c, Approver_L2__c FROM AOP__c WHERE Id =: aop.Id];
        
        Project__c proj = new Project__c();
        proj.Name = 'Runwal Bliss';
        insert proj;
        
        Legal_Entity__c le = new Legal_Entity__c();
        le.Name = 'Test Legal Entity';
        insert le;

        Project_Unit__c unit = new Project_Unit__c();
        unit.Name = 'Test Unit';
        unit.RW_Unit_Status__c = 'Booked';
        unit.RW_Param1__c = 'RUNWAL BLISS';
        unit.RW_Project__c = proj.Id;
        unit.Legal_Entity__c = le.Id;
        unit.RW_Booking_Date__c = Date.today();
        insert unit;
        
        Booking__c bkg = new Booking__c();
        bkg.RW_Registration_Date__c = Date.today();
        bkg.Booking_Date__c = Datetime.now();
        bkg.Unit_No__c = unit.Id;
        bkg.Project__c = proj.Id;
        bkg.Status__c = 'Booking Confirmed';
        bkg.Allotment_Premium__c = 100000;
        bkg.AOP_Mandate__c = a.Name;
        insert bkg;
        System.debug('bkg.AOP_Mandate__c: ' + bkg.AOP_Mandate__c);
        
        Brokerage_Summary__c bs = new Brokerage_Summary__c();
        insert bs;
        
        Brokerage__c br = new Brokerage__c();
        br.Name = 'AOP Mandate';
        br.Brokerage_Summary__c = bs.Id;
        insert br;
        
        Brokerage_Invoice__c inv = new Brokerage_Invoice__c();
        inv.Channel_Partner__c = a.Channel_Partner__c;
        inv.Total_Agreement_Value__c = 100000;
        inv.AOP__c = a.Id;
        inv.Brokerage_Lookup__c = br.Id;
        inv.Legal_Entity__c = le.Id;
        inv.Brokerage__c = a.Brokerage__c;
        inv.Brokerage_In_Rs__c = (inv.Total_Agreement_Value__c * inv.Brokerage__c)/100;
        inv.Invoice_Amount__c = (inv.Total_Agreement_Value__c * inv.Brokerage__c)/100;
        inv.CP_Invoice_Clearing_L1__c = a.Approver_L1__c;
        inv.CP_Invoice_Clearing_L2__c = a.Approver_L2__c;
        inv.If_GST_is_applicable__c = 'Yes';
        inv.CP_Mandate_Recovery_Amount__c = 0;
        inv.Booking_List__c = bkg.Name;
        insert inv;
        
        Booking__c bk = [SELECT Id, Name FROM Booking__c WHERE Id =: bkg.Id];
        
        PageReference pRef1 = Page.CPMandateInvoiceAttachment;
        Test.setCurrentPage(pRef1);
        ApexPages.currentPage().getParameters().put('id',inv.Id);
        ApexPages.currentPage().getParameters().put('brokerage', '2');
        ApexPages.currentPage().getParameters().put('bkgListStr', bk.Name);
        ApexPages.currentPage().getParameters().put('recovery', '0');
        CPMandateInvoiceAttachmentController cf = new CPMandateInvoiceAttachmentController();
        
    }
    
    @isTest
    public static void flowTest(){
        CPMandateBatch.executeCpMandateBatch();
    }

}