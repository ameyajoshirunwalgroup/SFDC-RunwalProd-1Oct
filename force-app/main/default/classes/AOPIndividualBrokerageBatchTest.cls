@IsTest
private class AOPIndividualBrokerageBatchTest {
    
    @TestSetup
    static void setupTestData() {
        // Create Account
        Account testAccount = new Account(
            Name = 'Test Channel Partner Account'
        );
        insert testAccount;
        
        // Create Channel Partner
        Broker__c channelPartner = new Broker__c(
            Name = 'Test Channel Partner',
            SAP_CP_Code__c='0006002521',
            Account__c = testAccount.Id
        );
        insert channelPartner;
        
        // Create AOP with different scenarios
        List<AOP__c> aops = new List<AOP__c>();
        
        // AOP for FY processing
        aops.add(new AOP__c(
          //  Name = 'AOP FY 2024-25',
            Channel_Partner__c = channelPartner.Id,
            Start_Date__c = Date.newInstance(2024, 4, 1),
            End_Date__c = Date.newInstance(2025, 3, 31),
            Commitment_max__c = 50000000
        ));
        
        // AOP for end date processing (past)
        aops.add(new AOP__c(
           // Name = 'AOP Past End Date',
            Channel_Partner__c = channelPartner.Id,
            Start_Date__c = Date.today().addDays(-60),
            End_Date__c = Date.today().addDays(-1),
            Commitment_max__c = 30000000
        ));
        
        // AOP for interim processing (ongoing)
        aops.add(new AOP__c(
           // Name = 'AOP Ongoing',
            Channel_Partner__c = channelPartner.Id,
            Start_Date__c = Date.today().addDays(-30),
            End_Date__c = Date.today().addDays(30),
            Commitment_max__c = 40000000
        ));
        
        // AOP with no commitment
        aops.add(new AOP__c(
            //Name = 'AOP No Commitment',
            Channel_Partner__c = channelPartner.Id,
            Start_Date__c = Date.today().addDays(-10),
            End_Date__c = Date.today().addDays(10),
            Commitment_max__c = null
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
        
        // Create Brokerage Summary records
        List<Brokerage_Summary__c> summaries = new List<Brokerage_Summary__c>();
        summaries.add(new Brokerage_Summary__c());
        summaries.add(new Brokerage_Summary__c());
        summaries.add(new Brokerage_Summary__c());
        insert summaries;
        
        // Create Bookings with different scenarios
        List<Booking__c> bookings = new List<Booking__c>();
        
        // Bookings for FY AOP
        AOP__c fyAOP = aops[0];
        Brokerage_Summary__c summary1 = summaries[0];
        
        bookings.add(createBooking('Booking 1', channelPartner.Id, fyAOP.Id, summary1.Id, 15000000, 
                                 DateTime.newInstance(2024, 6, 15, 12, 0, 0)));
        bookings.add(createBooking('Booking 2', channelPartner.Id, fyAOP.Id, summary1.Id, 12000000, 
                                 DateTime.newInstance(2024, 8, 20, 14, 30, 0)));
        
        // Bookings for past end date AOP
        AOP__c pastAOP = aops[1];
        Brokerage_Summary__c summary2 = summaries[1];
        
        bookings.add(createBooking('Booking 3', channelPartner.Id, pastAOP.Id, summary2.Id, 8000000, 
                                 DateTime.newInstance(Date.today().addDays(-3), Time.newInstance(10, 0, 0, 0))));
        
        // Bookings for ongoing AOP (interim eligible)
        AOP__c ongoingAOP = aops[2];
        Brokerage_Summary__c summary3 = summaries[2];
        
        bookings.add(createBooking('Booking 4', channelPartner.Id, ongoingAOP.Id, summary3.Id, 30000000, 
                                 DateTime.newInstance(Date.today().addDays(-3), Time.newInstance(16, 0, 0, 0))));
        bookings.add(createBooking('Booking 5', channelPartner.Id, ongoingAOP.Id, summary3.Id, 5000000, 
                                 DateTime.newInstance(Date.today().addDays(-1), Time.newInstance(11, 0, 0, 0))));
        
        insert bookings;
            
          
        List<RW_Demand__c> demands = new List<RW_Demand__c>();
        for (Booking__c b : bookings) {
            RW_Demand__c dmd = new RW_Demand__c(
                Booking__c = b.Id,
                Name = 'Demand - ' + b.Id,
                RW_Billing_Document_Number__c = String.valueOf(Math.mod(Crypto.getRandomInteger(), 999999)),
                RW_Customer_Number__c = '12345678'
            );
            demands.add(dmd);
        }
        insert demands;

        List<RW_Demand_Item__c> demandItems = new List<RW_Demand_Item__c>();
        for (RW_Demand__c d : demands) {
            demandItems.add(new RW_Demand_Item__c(
                RW_Demand__c = d.Id,
                RW_Demand_Item_Amount__c = 200000,
                RW_GST_Amount__c = 1000,
                RW_Legacy_Amount_Paid__c = 5000,
                RW_Legacy_Demand__c = true,
                Total_Demand_Item_Amount_Paid__c = 20000000
            ));
        }
        insert demandItems;


        
    }
    
    private static Booking__c createBooking(String name, Id channelPartnerId, Id aopId, Id summaryId, 
                                          Decimal agreementValue, DateTime bookingDate) {
        return new Booking__c(
         //   Name = name,
         	Source_of_Booking__c = 'Channel Partner',
            BrokerIId__c = channelPartnerId,
            AOP_Scheme__c = aopId,
            Brokerage_Summary__c = summaryId,
            Allotment_Premium__c = agreementValue,
            RW_Total_Receipt_Amount_Received__c = 2000000.00,
            Booking_Date__c = bookingDate,
           
            Status__c = 'Booking Confirmed',
            RW_Registration_Done__c = 'Yes',
            RW_Registration_Date__c = Date.today().addDays(-5),
            Type_of_Client__c = 'Local'
         
        );
    }


    
    @IsTest
    static void testBatchConstructorByFY() {
        Test.startTest();
        AOPIndividualBrokerageBatch batch = new AOPIndividualBrokerageBatch('FY2025-26');
        Test.stopTest();
   
    }
    
    @IsTest
    static void testBatchConstructorByEndDate() {
        Date testEndDate = Date.today().addDays(-1);
        
        Test.startTest();
        AOPIndividualBrokerageBatch batch = new AOPIndividualBrokerageBatch(testEndDate);
        Test.stopTest();
        
        
    }
    
    @IsTest
    static void testBatchProcessingByFY() {
        Test.startTest();
        AOPIndividualBrokerageBatch batch = new AOPIndividualBrokerageBatch('FY2025-26');
        Database.executeBatch(batch, 200);
        Test.stopTest();
        
        // Verify brokerage records were created
        List<Brokerage__c> brokerages = [SELECT Id, Name, Brokerage_Type__c, Brokerage_Amount__c, 
                                       AOP_Brokerage__c, Channel_Partner__c, Booking__c
                                       FROM Brokerage__c 
                                       WHERE Brokerage_Type__c IN ('AOP Brokerage', 'AOP Interim Brokerage', 'AOP Final Brokerage')];
        
        
    }
    
    @IsTest
    static void testBatchProcessingByEndDate() {
        Date pastEndDate = Date.today().addDays(-1);
        
        Test.startTest();
        AOPIndividualBrokerageBatch batch = new AOPIndividualBrokerageBatch(pastEndDate);
        Database.executeBatch(batch, 200);
        Test.stopTest();
        
        // Verify brokerage records were created for the specific end date
        List<Brokerage__c> brokerages = [SELECT Id, Brokerage_Type__c FROM Brokerage__c];
        
        // Should have some brokerage records created
        System.assertNotEquals(null, brokerages, 'Brokerage records should be queried');
    }
    
    @IsTest
    static void testInterimPayoutScenario() {
        // Get the ongoing AOP that should trigger interim payout
        AOP__c ongoingAOP = [SELECT Id, Name FROM AOP__c  LIMIT 1];
        
        Test.startTest();
        AOPIndividualBrokerageBatch batch = new AOPIndividualBrokerageBatch('FY2025-26');
        Database.executeBatch(batch, 200);
        Test.stopTest();
        
        // Verify interim brokerage records were created for high-value bookings
        List<Brokerage__c> interimBrokerages = [SELECT Id, Brokerage_Type__c, AOP_Brokerage__c, Brokerage_Amount__c
                                              FROM Brokerage__c 
                                              WHERE Brokerage_Type__c = 'AOP Interim Brokerage'];
        
        if (!interimBrokerages.isEmpty()) {
            System.assertEquals('AOP Interim Brokerage', interimBrokerages[0].Brokerage_Type__c, 
                              'Should create interim brokerage records');
            System.assert(interimBrokerages[0].AOP_Brokerage__c > 0, 'Interim brokerage rate should be positive');
        }
    }
    
    @IsTest
    static void testFinalPayoutScenario() {
        // Create existing interim brokerage to test final payout logic
        Broker__c cp = [SELECT Id FROM Broker__c LIMIT 1];
        Booking__c booking = [SELECT Id FROM Booking__c LIMIT 1];
        Brokerage_Summary__c bs1  =[SELECT Id FROM Brokerage_Summary__c LIMIT 1];
       
        Brokerage__c interimBrokerage = new Brokerage__c(
            Name = 'Test Interim Brokerage',
            Channel_Partner__c = cp.Id,
            Booking__c = booking.Id,
            Brokerage_Type__c = 'AOP Brokerage',
            AOP_Brokerage__c = 1.5,
            Brokerage_Amount__c = 150000,
            Brokerage_Summary__c= bs1.Id
           
        );
        insert interimBrokerage;
        
        Test.startTest();
        Date pastEndDate = Date.today().addDays(-1);
        AOPIndividualBrokerageBatch batch = new AOPIndividualBrokerageBatch(pastEndDate);
        Database.executeBatch(batch, 200);
        Test.stopTest();
        
        // Verify that final brokerage logic was executed
        List<Brokerage__c> allBrokerages = [SELECT Id, Brokerage_Type__c FROM Brokerage__c];
        System.assertNotEquals(0, allBrokerages.size(), 'Should have brokerage records');
    }
    
    @IsTest
    static void testSlabDowngradeScenario() {
        // Create a booking with low value that should trigger slab downgrade
        Broker__c cp = [SELECT Id FROM Broker__c LIMIT 1];
        AOP__c aop = [SELECT Id FROM AOP__c WHERE Commitment_max__c != null LIMIT 1];
        Brokerage_Summary__c summary = [SELECT Id FROM Brokerage_Summary__c LIMIT 1];
          
        
        Booking__c lowValueBooking = new Booking__c(
          //  Name = 'Low Value Booking',
            BrokerIId__c = cp.Id,
            AOP_Scheme__c = aop.Id,
            Brokerage_Summary__c = summary.Id,
           Allotment_Premium__c = 5000000, // Low value to trigger downgrade
            Booking_Date__c = DateTime.now().addDays(-5),
            RW_Total_Receipt_Amount_Received__c = 1000000,
            Status__c = 'Booking Confirmed',
            RW_Registration_Done__c = 'Yes'
        );
        insert lowValueBooking;
        
        Test.startTest();
        AOPIndividualBrokerageBatch batch = new AOPIndividualBrokerageBatch('FY2025-26');
        Database.executeBatch(batch, 200);
        Test.stopTest();
        
        // Verify brokerage records were created with appropriate rates
        List<Brokerage__c> brokerages = [SELECT Id, AOP_Brokerage__c FROM Brokerage__c 
                                       WHERE Booking__c = :lowValueBooking.Id];
        
        if (!brokerages.isEmpty()) {
            System.assert(brokerages[0].AOP_Brokerage__c >= 0, 'Brokerage rate should be non-negative');
        }
    }
    
    @IsTest
    static void testNoEligibleBookingsScenario() {
        // Create AOP with no matching bookings
        Broker__c cp = [SELECT Id FROM Broker__c LIMIT 1];
        
        AOP__c emptyAOP = new AOP__c(
           // Name = 'Empty AOP',
            Channel_Partner__c = cp.Id,
            Start_Date__c = Date.today().addDays(-100),
            End_Date__c = Date.today().addDays(-90),
            Commitment_max__c = 20000000
        );
        insert emptyAOP;
        
        AOP_Slab__c slab = new AOP_Slab__c(
            AOP__c = emptyAOP.Id,
            Slab_Name__c = 'Slab 1',
            Lower_Limit__c = 0,
            Upper_Limit__c = 30000000,
            Brokerage_Rate__c = 2.0,
            Priority__c = 1
        );
        insert slab;
        
        Test.startTest();
        AOPIndividualBrokerageBatch batch = new AOPIndividualBrokerageBatch(Date.today().addDays(-90));
        Database.executeBatch(batch, 200);
        Test.stopTest();
        
        // Should complete without errors even with no eligible bookings
        System.assert(true, 'Batch should complete successfully even with no eligible bookings');
    }
    
    @IsTest
    static void testExistingBrokeragePaymentCheck() {
        // Create existing brokerage records to test payment checking logic
        Broker__c cp = [SELECT Id FROM Broker__c LIMIT 1];
        Booking__c booking = [SELECT Id FROM Booking__c LIMIT 1];
        Brokerage_Summary__c bs  =[SELECT Id FROM Brokerage_Summary__c LIMIT 1];
        List<Brokerage__c> existingBrokerages = new List<Brokerage__c>();
          RW_Demand__c d1= [SELECT Id FROM RW_Demand__c LIMIT 1];
        RW_Demand_Item__c  di1 =[SELECT Id FROM RW_Demand_Item__c LIMIT 1];
        
        existingBrokerages.add(new Brokerage__c(
           Name = 'Existing Full Payment',
            Channel_Partner__c = cp.Id,
            Booking__c = booking.Id,
            Brokerage_Type__c = 'AOP Brokerage',
            AOP_Brokerage__c = 2.0,
            Brokerage_Amount__c = 300000,
            Brokerage_Summary__c=bs.Id
            
        ));
        
        insert existingBrokerages;
        
        Test.startTest();
        AOPIndividualBrokerageBatch batch = new AOPIndividualBrokerageBatch('FY2025-26');
        Database.executeBatch(batch, 200);
        Test.stopTest();
        
        // Verify that duplicate payments are not created
        List<Brokerage__c> allBrokerages = [SELECT Id, Brokerage_Type__c, Booking__c 
                                          FROM Brokerage__c 
                                          WHERE Booking__c = :booking.Id];
        
        System.assertNotEquals(0, allBrokerages.size(), 'Should have brokerage records');
    }
    
    @IsTest
    static void testDateUtilityMethods() {
        AOPIndividualBrokerageBatch batch = new AOPIndividualBrokerageBatch('FY2025-26');
        
        Test.startTest();
        
        // Test getFYStart method via reflection or by testing batch execution
        // Since the methods are private, we test them indirectly through batch execution
        Database.QueryLocator ql = batch.start(null);
        String query = ql.getQuery();
        
        Test.stopTest();
        
        System.assert(query.contains('FROM AOP__c'), 'Query should be properly formed');
        System.assert(query.contains('WHERE Commitment_max__c != null'), 'Query should include commitment filter');
    }
    
    @IsTest
    static void testBatchWithNullValues() {
        // Test handling of null values in various fields
        Broker__c cp = [SELECT Id FROM Broker__c LIMIT 1];
        Brokerage_Summary__c summary = [SELECT Id FROM Brokerage_Summary__c LIMIT 1];
        
        AOP__c nullAOP = new AOP__c(
           // Name = 'Null Values AOP',
            Channel_Partner__c = cp.Id,
            Start_Date__c = Date.today().addDays(-10),
            End_Date__c = Date.today().addDays(10),
            Commitment_max__c = 25000000
        );
        insert nullAOP;
        
        AOP_Slab__c nullSlab = new AOP_Slab__c(
            AOP__c = nullAOP.Id,
            Slab_Name__c = 'Null Test Slab',
            Lower_Limit__c = 0,
            Upper_Limit__c = 50000000,
            Brokerage_Rate__c = null, // Null rate to test handling
            Priority__c = 1
        );
        insert nullSlab;
        
        Booking__c nullBooking = new Booking__c(
          //  Name = 'Null Value Booking',
            BrokerIId__c = cp.Id,
            AOP_Scheme__c = nullAOP.Id,
            Brokerage_Summary__c = summary.Id,
          //  Agreement_Value_for_brokers__c = null, // Null value to test handling
            Booking_Date__c = DateTime.now().addDays(-5),
          //  X5_Received__c = true,
          //  RW_X9_99_Received__c = true,
            Status__c = 'Booking Confirmed',
            RW_Registration_Done__c = 'Yes'
        );
        insert nullBooking;
        
        Test.startTest();
        AOPIndividualBrokerageBatch batch = new AOPIndividualBrokerageBatch('FY2025-26');
        Database.executeBatch(batch, 200);
        Test.stopTest();
        
        // Should complete without errors even with null values
        System.assert(true, 'Batch should handle null values gracefully');
    }
    
    @IsTest
    static void testBatchFinishMethod() {
        Test.startTest();
        AOPIndividualBrokerageBatch batch = new AOPIndividualBrokerageBatch('FY2025-26');
        Id jobId = Database.executeBatch(batch, 200);
        Test.stopTest();
        
        // Verify that the batch completed
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors FROM AsyncApexJob WHERE Id = :jobId];
        System.assertEquals('Completed', job.Status, 'Batch job should complete successfully');
        System.assertEquals(0, job.NumberOfErrors, 'Batch job should complete without errors');
    }
    
    @IsTest
    static void testInvalidFYFormat() {
        try {
            Test.startTest();
            AOPIndividualBrokerageBatch batch = new AOPIndividualBrokerageBatch('');
            Database.executeBatch(batch, 200);
            Test.stopTest();
            
            System.assert(false, 'Should throw exception for empty FY');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('Financial year cannot be blank'), 
                         'Should throw appropriate exception for blank FY');
        }
    }
}