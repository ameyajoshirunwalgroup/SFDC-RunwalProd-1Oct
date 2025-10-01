@isTest
public class Test_Batch_IntWaiverAPICallout {
    // Mock class for HTTP callout
    class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            
            WrapperIntWaiverAPI wrapper = new WrapperIntWaiverAPI();
            wrapper.items = new List<WrapperIntWaiverAPI.items>();
            
            WrapperIntWaiverAPI.items item = new WrapperIntWaiverAPI.items();
            item.belnr = '1000001';
            item.int_amt = 500.0;
            item.waived_amt = 200.0;
            item.net_int_amt = 300.0;
            item.int_days = 10;
            item.sgtxt = 'Slab A';
            item.mlbez = 'SC123';
            item.unit_no = 'U1001';
            item.fkdat = '302';
            item.balance = 299.99;
            item.project = '6000';
            item.kunnr = '200010283';
            item.name = '9029389829';
            item.netdt = '302';
            item.recv_dmbtr = 299.99;
            item.recvd_dmbtr = 600.09;
            item.vbeln = '200010283';
            
            wrapper.items.add(item);
            wrapper.has_more = 'N';
            wrapper.balance = '600000';
            wrapper.batch_id = '309';
            String mockBody = JSON.serialize(wrapper);
            
            res.setBody(mockBody);
            return res;
        }
    }
    
    @isTest
    static void testBatchExecute() {
        // Create dummy user (since your start method queries User)
        User u = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];
        
        // Insert SAP Integration metadata
        SAP_Integration__mdt metadata = new SAP_Integration__mdt(
            DeveloperName = 'GET_Interest_Waiver',
            MasterLabel = 'GET_Interest_Waiver',
            End_Point_URL__c = 'https://dummy.sap.com/api?type=waiver',
            Username__c = 'RG_SUPPORT2',
            Password__c = 'Runwal@@2025'
        );
        
        // Set label value in a custom label mock if needed (otherwise hardcode chunkSize)
        Test.startTest();
        // Create test Opportunity
        Opportunity objOpp = new Opportunity();
        objOpp.Name = 'Test Opp';
        objOpp.StageName = 'Unit Booked';
        objOpp.CloseDate = Date.today();
        objOpp.SAP_Customer_Number__c = '123456';
        insert objOpp;
        
        // Create Booking record
        Booking__c objBooking = new Booking__c();
        objBooking.Opportunity__c = objOpp.Id;
        insert objBooking;
        
        // Insert a RW_Demand__c record with the same Billing Document Number as in mock
        RW_Demand__c demand = new RW_Demand__c(
            RW_Billing_Document_Number__c = '1000001',
            Booking__c = objBooking.Id,
            Due_Date__c = Date.today()
        );
        insert demand;
        
        // Register the mock
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Run the batch
        Database.executeBatch(new Batch_IntWaiverAPICallout(), 1);
        Test.stopTest();
        
        // Verify data updated
        RW_Demand__c updated = [SELECT Total_Interest_Amount__c, Previously_Waived_Amount_SAP__c, Net_Interest_Amount__c,
                                Interest_Days__c, SAP_Slab_Description__c, SAP_Slab_Code__c, Unit_No__c
                                FROM RW_Demand__c WHERE Id = :demand.Id];
        
        System.assertEquals(500.0, updated.Total_Interest_Amount__c);
        System.assertEquals(200.0, updated.Previously_Waived_Amount_SAP__c);
        System.assertEquals(300.0, updated.Net_Interest_Amount__c);
        System.assertEquals(10, updated.Interest_Days__c);
        System.assertEquals('Slab A', updated.SAP_Slab_Description__c);
        System.assertEquals('SC123', updated.SAP_Slab_Code__c);
        System.assertEquals('U1001', updated.Unit_No__c);
    }
    
    @isTest
    static void testSchedulableExecution() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        SAP_Integration__mdt metadata = new SAP_Integration__mdt(
            DeveloperName = 'GET_Interest_Waiver',
            MasterLabel = 'GET_Interest_Waiver',
            End_Point_URL__c = 'https://dummy.sap.com/api?type=waiver',
            Username__c = 'RG_SUPPORT2',
            Password__c = 'Runwal@@2025'
        );
        
        Batch_IntWaiverAPICallout obj = new Batch_IntWaiverAPICallout();
        Test.startTest();
        obj.execute(null);
        Test.stopTest();
    }
}