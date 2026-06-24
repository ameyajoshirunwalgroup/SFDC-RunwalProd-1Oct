@isTest
public class CPBrkInvoiceEmailToSubmitControllerTest {

    @testSetup
    static void makeData() {
        // 1. Basic Setup
        Account testAccount = new Account(Name = 'Test Channel Partner Account');
        insert testAccount;
        
        Legal_Entity__c legalEntity = new Legal_Entity__c(Name ='RREPL', RDS_Company_Code__c = '2020');
        insert legalEntity;
        
        list<Broker__c> cplist = new list<Broker__c>();
        // 2. Create Channel Partner
        Broker__c channelPartner = new Broker__c(
            Name = 'Test Channel Partner',
            SAP_CP_Code__c='0006002521',
            Account__c = testAccount.Id,
            RW_Email__c = 'test7489349@gmail.com',
            Place_of_supply__c = 'Maharashtra'
        );
        cplist.add(channelPartner);
        Broker__c channelPartner1 = new Broker__c(
            Name = 'Test Channel Partner',
            SAP_CP_Code__c='0006002521',
            Account__c = testAccount.Id,
            RW_Email__c = 'test7489349@gmail.com',
            Place_of_supply__c = 'Gujarat'
        );
        cplist.add(channelPartner1);
        insert cplist;

        // 3. Create Supporting Transactional Data
        Project_Location__c pl = new Project_Location__c(
            Name = 'Mumbai',
            Approver_L1__c = UserInfo.getUserId(),
            Approver_L2__c = UserInfo.getUserId(),
            Location__c = 'Mumbai'
        );
        insert pl;

        // Booking is needed for the bklist logic in your controller
        Booking__c testBooking = new Booking__c(
            Booking_Date__c = System.today(),
            //Unit_Number__c = '101',
            Status__c = 'Booking Confirmed'
        );
        insert testBooking;

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
        
        
        Kicker_Incentive__c ki = new Kicker_Incentive__c();
        ki.Name = 'Kicker Sep & Oct 2022';
        ki.Brokerage_Scheme__c = bscheme.Id;
        ki.Start_Date__c = system.today() - 2;
        ki.End_Date__c = system.today() + 2;
        ki.Type__c = 'Cumulative';
        ki.Type_Of_Client__c = 'Local';
        insert ki;     

        
        Brokerage_Summary__c bs = new Brokerage_Summary__c();
        bs.Applied_Slab_Name__c = 'Slab 10';
        bs.Brokerage_Scheme__c = bscheme.Id;
        bs.Kicker_Incentive__c = ki.Id;
        insert bs;
        
        Brokerage__c bro = new Brokerage__c();
        bro.Name = 'Base Brokerage';
        bro.Brokerage__c = 2;
        bro.Brokerage_Amount__c = 272059;
        bro.Brokerage_Summary__c = bs.Id;
        bro.Opportunity_AV__c = 13602975;
        bro.Brokerage_Type__c = 'Base Brokerage';
        insert bro;
        
        
        List<Brokerage_Invoice__c> bilist = new List<Brokerage_Invoice__c>();
        
        Brokerage_Invoice__c bi1 = new Brokerage_Invoice__c();

        bi1.Booking__c = testBooking.Id;
        bi1.Brokerage_Summary__c = bs.Id;
        bi1.Invoice_Number__c = '8000';
        bi1.Brokerage_In_Rs__c = 3000;
        bi1.Brokerage_Lookup__c = bro.Id;
        bilist.add(bi1);
        
        Brokerage_Invoice__c bi2 = new Brokerage_Invoice__c();
       
        bi2.Booking__c = testBooking.Id;
        bi2.Brokerage_Summary__c = bs.Id;
        bi2.Invoice_Number__c = '8282';
        bi2.Brokerage_In_Rs__c = 3000;
        bi2.Brokerage_Lookup__c = bro.Id;
        bilist.add(bi2);
        
        Brokerage_Invoice__c bi3 = new Brokerage_Invoice__c();
        
        bi3.Booking__c = testBooking.Id;
        bi3.Brokerage_Summary__c = bs.Id;
        bi3.Invoice_Number__c = '8893';
        bi3.Brokerage_In_Rs__c = 3000;
        bi3.Brokerage_Lookup__c = bro.Id;
        bilist.add(bi3);
        
        insert bilist;

        // 4. Create CP_Brokerage__c records using variables
        List<CP_Brokerage__c> brokeragesToInsert = new List<CP_Brokerage__c>();

        // cpb1: Base Brokerage, No GST
        CP_Brokerage__c cpb1 = new CP_Brokerage__c();
        cpb1.Approval_Status__c = 'Approved By L4 - Accounts';
        cpb1.Brokerage_Type__c = 'Base Brokerage';
        cpb1.Channel_Partner__c = channelPartner.Id;
        cpb1.Total_Brokerage__c = 3000;
        cpb1.Invoice_Date__c = Date.today();
        cpb1.Invoice_Number__c = '8000';
        cpb1.If_GST_is_applicable__c = 'No';
        cpb1.Total_Agreement_Value__c = 1000000;
        cpb1.Booking__c = testBooking.Id;
        brokeragesToInsert.add(cpb1);

        // cpb2: Base Brokerage, With GST (Maharashtra)
        CP_Brokerage__c cpb2 = new CP_Brokerage__c();
        cpb2.Approval_Status__c = 'Approved By L4 - Accounts';
        cpb2.Brokerage_Type__c = 'Kicker Incentive';
        cpb2.Channel_Partner__c = channelPartner1.Id;
        cpb2.Total_Brokerage__c = 3000;
        cpb2.Invoice_Date__c = Date.today();
        cpb2.Invoice_Number__c = '8282';
        cpb2.If_GST_is_applicable__c = 'Yes';
        cpb2.CGST__c = '270.00'; // Numeric strings to avoid Decimal.valueOf errors
        cpb2.SGST__c = '270.00';
        cpb2.IGST__c = '0.00';
        cpb2.Total_Invoice_Amount__c = 3540;
        cpb2.Total_Agreement_Value__c = 1000000;
        cpb2.Booking__c = testBooking.Id;
        brokeragesToInsert.add(cpb2);

        // cpb3: Additional Brokerage (Outstation - IGST)
        CP_Brokerage__c cpb3 = new CP_Brokerage__c();
        cpb3.Approval_Status__c = 'Approved By L4 - Accounts';
        cpb3.Brokerage_Type__c = 'Additional Brokerage';
        cpb3.Channel_Partner__c = channelPartner.Id;
        cpb3.Total_Brokerage__c = 4000;
        cpb3.Invoice_Number__c = '8893';
        cpb3.If_GST_is_applicable__c = 'Yes';
        cpb3.IGST__c = '720.00';
        cpb3.Total_Invoice_Amount__c = 4720;
        cpb3.Booking__c = testBooking.Id;
         cpb3.Total_Agreement_Value__c = 1000000;
        brokeragesToInsert.add(cpb3);

        insert brokeragesToInsert;

        bi1.CP_Brokerage__c = cpb1.Id;
        bi2.CP_Brokerage__c = cpb2.Id;
        bi3.CP_Brokerage__c = cpb3.Id;
        UPDATE BILIST;
        
        
        // 6. Create Dummy Contact for Email logic
        insert new Contact(LastName = 'Dummy Contact', Email = 'test@example.com');
    }

    @isTest
    static void testBaseNoGst() {
        CP_Brokerage__c cp = [SELECT Id FROM CP_Brokerage__c WHERE Invoice_Number__c = '8000' LIMIT 1];
        Brokerage_Invoice__c bi = [Select Id from Brokerage_Invoice__c where CP_Brokerage__c =: cp.Id];
        system.debug('bi->'+bi);
        
        Test.startTest();
        CPBrkInvoiceEmailToSubmitterController controller = new CPBrkInvoiceEmailToSubmitterController();
        controller.cpId = cp.Id; // Triggers load logic
        Test.stopTest();
        
    }
																		
    @isTest
    static void testBaseWithGst() {
        CP_Brokerage__c cp = [SELECT Id FROM CP_Brokerage__c WHERE Invoice_Number__c = '8282' LIMIT 1];
        
        Test.startTest();
        CPBrkInvoiceEmailToSubmitterController controller = new CPBrkInvoiceEmailToSubmitterController();
        controller.cpId = cp.Id;
        Test.stopTest();
        
    }

    @isTest
    static void testAdditionalWithIgst() {
        CP_Brokerage__c cp = [SELECT Id FROM CP_Brokerage__c WHERE Invoice_Number__c = '8893' LIMIT 1];
        
        Test.startTest();
        CPBrkInvoiceEmailToSubmitterController controller = new CPBrkInvoiceEmailToSubmitterController();
        controller.cpId = cp.Id;
        Test.stopTest();
    }
}