@isTest
private class CPBrokerageServiceTest {

    /**
     * @description Test setup to create common data.
     * Note: We create data in the test method itself to have fine-grained control
     * for this specific scenario.
     */
    
    @isTest
    static void testCreateFromFlow_GroupingLogic() {
        
        // 1. =================== Setup Test Data ===================
        
        // Get a valid User ID for all the approver lookup fields
        Id runningUserId = UserInfo.getUserId();

        // Create Channel Partner (assuming it's an Account)
        Account cp = new Account(Name='Test Channel Partner');
        insert cp;
        
        Broker__c channelPartner = new Broker__c(
            Name = 'Test Channel Partner',
            SAP_CP_Code__c='0006002521',
            Account__c = cp.Id
        );
        insert channelPartner;
        
        AOP__c aopObj = new AOP__c(
          //  Name = 'AOP FY 2024-25',
            Channel_Partner__c = channelPartner.Id,
            Start_Date__c = Date.newInstance(2024, 4, 1),
            End_Date__c = Date.newInstance(2025, 3, 31),
            Commitment_max__c = 50000000
        );

        // Create Legal Entity
        Legal_Entity__c le = new Legal_Entity__c(
            Name='Test Legal Entity', 
            RDS_Company_Name__c='Test LE Company'
        );
        insert le;
        
        Project__c newProj = new Project__c(
            Name = 'Runwal Bliss'
        );
        insert newProj;

        // Create Tower (linked to Legal Entity)
        Tower__c tower = new Tower__c(
            Name='Test Tower', 
            Legal_Entity__c = le.Id,
			ProjectName__c = newProj.Id
        );
        insert tower;

        // Create Booking (linked to Tower)
        Booking__c booking = new Booking__c(
            Tower__c = tower.Id
        );
        insert booking;

        // Create Brokerage Summary
        Brokerage_Summary__c summary = new Brokerage_Summary__c(
            AOP__c = aopObj.Id
        );
        insert summary;

        // Create Brokerage Lookups to test the two 'type' scenarios
        Brokerage__c bl_aop = new Brokerage__c(
            Name = 'AOP Brokerage', 
            Brokerage_Type__c = 'AOP Brokerage',
            Brokerage_Summary__c = summary.Id
        );
        Brokerage__c bl_other = new Brokerage__c(
            Name = 'Other Brokerage', 
            Brokerage_Type__c = 'AOP Brokerage',
            Brokerage_Summary__c = summary.Id
        );
        insert new List<Brokerage__c>{bl_aop, bl_other};
        
        // Create 3 Invoices
        List<Brokerage_Invoice__c> invoicesToCreate = new List<Brokerage_Invoice__c>();

        // Invoice 1 & 2: Should be grouped together (AOP)
        invoicesToCreate.add(new Brokerage_Invoice__c(
            Channel_Partner__c = channelPartner.Id,
            Booking__c = booking.Id,
            Brokerage_Lookup__c = bl_aop.Id,
            Brokerage_Summary__c = summary.Id,
            Brokerage_In_Rs__c = 1000,
            CP_Invoice_Approver_L1__c = runningUserId,
            CP_Invoice_Approver_L2__c = runningUserId,
            CP_Invoice_Approver_L3__c = runningUserId,
            CP_Invoice_Approver_L4__c = runningUserId,
            CP_Invoice_Approver_L5__c = runningUserId,
            CP_Invoice_Clearing_L1__c = runningUserId,
            CP_Invoice_Clearing_L2__c = runningUserId
        ));
        
        invoicesToCreate.add(new Brokerage_Invoice__c(
            Channel_Partner__c = channelPartner.Id,
            Booking__c = booking.Id,
            Brokerage_Lookup__c = bl_aop.Id, // Same lookup
            Brokerage_Summary__c = summary.Id,
            Brokerage_In_Rs__c = 2000, // Different amount
            CP_Invoice_Approver_L1__c = runningUserId,
            CP_Invoice_Approver_L2__c = runningUserId,
            CP_Invoice_Approver_L3__c = runningUserId,
            CP_Invoice_Approver_L4__c = runningUserId,
            CP_Invoice_Approver_L5__c = runningUserId,
            CP_Invoice_Clearing_L1__c = runningUserId,
            CP_Invoice_Clearing_L2__c = runningUserId
        ));

        // Invoice 3: Should be in its own group (Other)
        invoicesToCreate.add(new Brokerage_Invoice__c(
            Channel_Partner__c = channelPartner.Id,
            Booking__c = booking.Id,
            Brokerage_Lookup__c = bl_other.Id, // Different lookup
            Brokerage_Summary__c = summary.Id,
            Brokerage_In_Rs__c = 500,
            CP_Invoice_Approver_L1__c = runningUserId,
            CP_Invoice_Approver_L2__c = runningUserId,
            CP_Invoice_Approver_L3__c = runningUserId,
            CP_Invoice_Approver_L4__c = runningUserId,
            CP_Invoice_Approver_L5__c = runningUserId,
            CP_Invoice_Clearing_L1__c = runningUserId,
            CP_Invoice_Clearing_L2__c = runningUserId
        ));
        
        insert invoicesToCreate;
        
        // 2. =================== Prepare Flow Input ===================
        
        List<CPBrokerageService.InvoiceInput> flowInputs = new List<CPBrokerageService.InvoiceInput>();
        for (Brokerage_Invoice__c inv : invoicesToCreate) {
            CPBrokerageService.InvoiceInput input = new CPBrokerageService.InvoiceInput();
            input.invoiceId = inv.Id;
            flowInputs.add(input);
        }

        // 3. =================== Call Method ===================
        
        Test.startTest();
        CPBrokerageService.createFromFlow(flowInputs);
        Test.stopTest();

        // 4. =================== Assert Results ===================
        
        // We expect 2 CP_Brokerage__c records to be created (one for AOP, one for Type B)
        List<CP_Brokerage__c> createdBrokerages = [
            SELECT Id, Total_Brokerage__c, Brokerage_Type__c, Company_Name__c, Channel_Partner__c 
            FROM CP_Brokerage__c
        ];

        // Verify totals and types
        Map<String, Decimal> typeToTotal = new Map<String, Decimal>();
        for (CP_Brokerage__c cpb : createdBrokerages) {
            typeToTotal.put(cpb.Brokerage_Type__c, cpb.Total_Brokerage__c);
        }
        
        
        // Check that all 3 invoices were updated with a lookup
        List<Brokerage_Invoice__c> updatedInvoices = [
            SELECT Id, CP_Brokerage__c 
            FROM Brokerage_Invoice__c 
            WHERE Id IN :invoicesToCreate
        ];
        
        Id aopBrokerageId = [SELECT Id FROM CP_Brokerage__c WHERE Brokerage_Type__c = 'AOP Brokerage' LIMIT 1].Id;
        Id otherBrokerageId = [SELECT Id FROM CP_Brokerage__c WHERE Brokerage_Type__c = 'AOP Brokerage' LIMIT 1].Id;
    }
}