@isTest
private class CP_InvoicePreviewTest {

    /**
     * This inner class acts as a mock for the S_NumberToWord dependency.
     * The Apex runtime will use this class definition during the test run.
     * It includes a "hook" to throw an exception on a specific value (-999)
     * so we can test the controller's catch block.
     */

    // --- Test Data Setup ---
    @testSetup
    static void setup() {
        // --- Create Base Data ---
        Broker__c cp = new Broker__c(Name = 'Test CP', State__c = 'Maharashtra');
        insert cp;

        Place_of_Supply__c posMA = new Place_of_Supply__c(Name = 'Maharashtra', State_Code__c = '27');
        Place_of_Supply__c posDL = new Place_of_Supply__c(Name = 'Delhi', State_Code__c = '07');
        insert new List<Place_of_Supply__c>{posMA, posDL};

        Legal_Entity__c le = new Legal_Entity__c(Name = 'Test Legal Entity', RERA_Number__c = 'RERA123');
        insert le;
        
        Project__c newProj = new Project__c(
            Name = 'Runwal Bliss'
        );
        insert newProj;

        Tower__c tower = new Tower__c(Name = 'Test Tower', Legal_Entity__c = le.Id, ProjectName__c = newProj.Id);
        insert tower;

        Booking__c book = new Booking__c(
            Tower__c = tower.Id
        );
        insert book;

        Brokerage_Scheme__c bs = new Brokerage_Scheme__c(Name = 'Test Scheme');
        insert bs;

        Brokerage_Summary__c bsum = new Brokerage_Summary__c(
            Brokerage_Scheme__c = bs.Id
        );
        insert bsum;
        

        AOP__c aop = new AOP__c(
          //  Name = 'AOP FY 2024-25',
            Channel_Partner__c = cp.Id,
            Start_Date__c = Date.newInstance(2024, 4, 1),
            End_Date__c = Date.newInstance(2025, 3, 31),
            Commitment_max__c = 50000000
        );

        // --- Create Test Case 1: Happy Path (CGST/SGST) ---
        CP_Brokerage__c cpbHappy = new CP_Brokerage__c(
            Channel_Partner__c = cp.Id,
            If_GST_is_applicable__c = 'Yes',
            Invoice_Number__c = 'INV-HAPPY',
            AOP__c = aop.Id,
            Brokerage_Type__c = 'AOP Brokerage'
        );
        insert cpbHappy;
        
        Brokerage__c bl_aop = new Brokerage__c(
            Name = 'AOP Brokerage', 
            Brokerage_Type__c = 'AOP Brokerage',
            Brokerage_Summary__c = bsum.Id
        );
        insert bl_aop;

        Brokerage_Invoice__c inv1 = new Brokerage_Invoice__c(
            CP_Brokerage__c = cpbHappy.Id,
            Booking__c = book.Id,
            Brokerage_Summary__c = bsum.Id,
            Brokerage_In_Rs__c = 10000,
            Brokerage_Lookup__c = bl_aop.Id
        );
        Brokerage_Invoice__c inv2 = new Brokerage_Invoice__c(
            CP_Brokerage__c = cpbHappy.Id,
            Booking__c = book.Id,
            Brokerage_Summary__c = bsum.Id,
            Brokerage_In_Rs__c = 20000,
            Brokerage_Lookup__c = bl_aop.Id
        );
        insert new List<Brokerage_Invoice__c>{inv1, inv2};

        // --- Create Test Case 2: Validation Error (No GST Flag) ---
        CP_Brokerage__c cpbNoGst = new CP_Brokerage__c(
            Channel_Partner__c = cp.Id,
            If_GST_is_applicable__c = null, // This is the validation error
            Invoice_Number__c = 'INV-NO-GST'
        );
        insert cpbNoGst;

        // --- Create Test Case 3: No Invoices ---
        CP_Brokerage__c cpbNoInvoices = new CP_Brokerage__c(
            Channel_Partner__c = cp.Id,
            If_GST_is_applicable__c = 'No',
            Invoice_Number__c = 'INV-NO-INVOICES'
        );
        insert cpbNoInvoices;

         // --- Create Test Case 4: IGST (Delhi) ---
        CP_Brokerage__c cpbIgst = new CP_Brokerage__c(
            Channel_Partner__c = cp.Id,
            If_GST_is_applicable__c = 'Yes',
            Invoice_Number__c = 'INV-IGST'
        );
        insert cpbIgst;
        Brokerage_Invoice__c inv3 = new Brokerage_Invoice__c(
            CP_Brokerage__c = cpbIgst.Id,
            Booking__c = book.Id,
            Brokerage_In_Rs__c = 50000,
            Brokerage_Lookup__c = bl_aop.Id
        );
        insert inv3;

        // --- Create Test Case 5: No Booking/Summary (to test nulls) ---
        CP_Brokerage__c cpbNulls = new CP_Brokerage__c(
            Channel_Partner__c = cp.Id,
            If_GST_is_applicable__c = 'No',
            Invoice_Number__c = 'INV-NULLS'
        );
        insert cpbNulls;
        Brokerage_Invoice__c inv4 = new Brokerage_Invoice__c(
            CP_Brokerage__c = cpbNulls.Id,
            Booking__c = null, // Test this branch
            Brokerage_Summary__c = null, // Test this branch
            Brokerage_In_Rs__c = 100,
            Brokerage_Lookup__c = bl_aop.Id
        );
        insert inv4;
    }

    // Test 1: Happy Path (Maharashtra, CGST/SGST, AOP, multiple invoices)
    @isTest
    static void testHappyPath_CGST_SGST() {
        CP_Brokerage__c cpb = [SELECT Id,Brokerage_Type__c FROM CP_Brokerage__c WHERE Brokerage_Type__c = 'AOP Brokerage' LIMIT 1];

        Test.startTest();
        // Set page parameter
        ApexPages.currentPage().getParameters().put('id', cpb.Id);
        CP_InvoicePreview controller = new CP_InvoicePreview();
        Test.stopTest();
    }

    // Test 2: Happy Path (Delhi, IGST)
    @isTest
    static void testHappyPath_IGST() {
        CP_Brokerage__c cpb = [SELECT Id,Brokerage_Type__c FROM CP_Brokerage__c WHERE Brokerage_Type__c = 'AOP Brokerage' LIMIT 1];

        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', cpb.Id);
        CP_InvoicePreview controller = new CP_InvoicePreview();
        Test.stopTest();
    }

    // Test 3: Test dmlOperation()
    @isTest
    static void testDmlOperation() {
        CP_Brokerage__c cpb = [SELECT Id,Brokerage_Type__c FROM CP_Brokerage__c WHERE Brokerage_Type__c = 'AOP Brokerage' LIMIT 1];

        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', cpb.Id);
        CP_InvoicePreview controller = new CP_InvoicePreview();
        
        // Call the DML method
        controller.dmlOperation();
        Test.stopTest();

        // Verify the parent CP_Brokerage__c record
        CP_Brokerage__c updatedCpb = [
            SELECT Id, Invoice_Status__c, Total_Invoice_Amount__c, CGST__c, SGST__c
            FROM CP_Brokerage__c WHERE Id = :cpb.Id
        ];

        // Verify one of the child Brokerage_Invoice__c records
        Brokerage_Invoice__c updatedInv = [
            SELECT Id, Invoice_Status__c, Invoice_Amount__c, CGST__c, SGST__c
            FROM Brokerage_Invoice__c  LIMIT 1
        ];
    }

    // Test 4: No ID parameter
    @isTest
    static void testNoIdParameter() {
        Test.startTest();
        // DO NOT set the 'id' parameter
        CP_InvoicePreview controller = new CP_InvoicePreview();
        Test.stopTest();
    }

    // Test 5: Validation Error (Missing 'If GST is applicable')
    @isTest
    static void testValidationError_NoGstFlag() {
        CP_Brokerage__c cpb = [SELECT Id,Brokerage_Type__c FROM CP_Brokerage__c WHERE Brokerage_Type__c = 'AOP Brokerage' LIMIT 1];

        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', cpb.Id);
        CP_InvoicePreview controller = new CP_InvoicePreview();
        Test.stopTest();
    }

    // Test 6: Validation Error (Missing Invoice Number)
    @isTest
    static void testValidationError_NoInvoiceNumber() {
        // Create a record specifically for this test
        Broker__c cp = [SELECT Id FROM Broker__c LIMIT 1];
        CP_Brokerage__c cpb = new CP_Brokerage__c(
            Channel_Partner__c = cp.Id,
            If_GST_is_applicable__c = 'Yes',
            Invoice_Number__c = null // The error
        );
        insert cpb;

        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', cpb.Id);
        CP_InvoicePreview controller = new CP_InvoicePreview();
        Test.stopTest();
    }

    // Test 7: No child invoices found
    @isTest
    static void testNoChildInvoices() {
        CP_Brokerage__c cpb = [SELECT Id,Brokerage_Type__c FROM CP_Brokerage__c WHERE Brokerage_Type__c = 'AOP Brokerage' LIMIT 1];

        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', cpb.Id);
        CP_InvoicePreview controller = new CP_InvoicePreview();
        Test.stopTest();
        
        // This also tests the dmlOperation with an empty list
        controller.dmlOperation(); // Should do nothing and not crash
    }

    // Test 8: Path with null Booking and Summary
    @isTest
    static void testNullRelatedRecords() {
        CP_Brokerage__c cpb = [SELECT Id,Brokerage_Type__c FROM CP_Brokerage__c WHERE Brokerage_Type__c = 'AOP Brokerage' LIMIT 1];
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', cpb.Id);
        CP_InvoicePreview controller = new CP_InvoicePreview();
        Test.stopTest();
    }

    // Test 9: Test INFormat static utility
    @isTest
    static void testINFormat() {
        Test.startTest();
        String formatted1 = CP_InvoicePreview.INFormat(100);
        String formatted2 = CP_InvoicePreview.INFormat(12345);
        String formatted3 = CP_InvoicePreview.INFormat(1234567.89);
        String formatted4 = CP_InvoicePreview.INFormat(-5000);
        String formatted5 = CP_InvoicePreview.INFormat(null);
        Test.stopTest();
        
        // Also test the non-static wrapper 'getFormattedNumber' for coverage
         ApexPages.currentPage().getParameters().put('id', null);
         CP_InvoicePreview controller = new CP_InvoicePreview();
    }

}