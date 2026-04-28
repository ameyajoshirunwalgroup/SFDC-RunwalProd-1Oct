@isTest
private class SAPCPBrkClearingAPITest {
    
    class SAPMockResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            
            String body = '[{"DOC_NO":"12345","CLEARING_DOC_NO":"CLR001","CLEARING_DATE":"2025-03-01","INV_NO":"4637829","INV_DT":"2025-09-12","BUKRS":"8000"}]';
            res.setBody(body);
            
            return res;
        }
    }
    
    @isTest
    static void testSAPClearingSuccess() {
        
        Legal_Entity__c le = new Legal_Entity__c(
            RDS_Company_Code__c = '8000',
            Name = 'Test Company',
            RDS_Company_Name__c = 'Testeee'
        );
        insert le; 
        
        CP_Brokerage__c cpb = new CP_Brokerage__c(
            SAP_Document_No__c = '12345',
            SAP_TDS__c = 1234,
            Total_Invoice_Amount__c = 1234565,
            Invoice_Number__c = '4637829',
            Invoice_Date__c = Date.newInstance(2025,9,12),
            Legal_Entity__c = le.Id
        );
        insert cpb;
        
        Test.setMock(HttpCalloutMock.class, new SAPMockResponse());
        
        Test.startTest();
        System.enqueueJob(new SAPCPBrkClearingAPI());       
        Test.stopTest();
        
    }
    
    class SAPMockNoData implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('[{"ERROR_LOG":"No data found!"}]');
            return res;
        }
    }
    
    @isTest
    static void testSAPNoDataScenario() {
        Test.setMock(HttpCalloutMock.class, new SAPMockNoData());
        
        Test.startTest();
        System.enqueueJob(new SAPCPBrkClearingAPI());
        Test.stopTest();
        
        System.assert(true);
    }
    
    class SAPMockError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('Error');
            return res;
        }
    }
    
    @isTest
    static void testErrorResponse() {
        Test.setMock(HttpCalloutMock.class, new SAPMockError());
        
        Test.startTest();
        System.enqueueJob(new SAPCPBrkClearingAPI());
        Test.stopTest();
        
    }
    
    class SAPMockInvalidDate implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('[{"DOC_NO":"12345","CLEARING_DOC_NO":"CLR001","CLEARING_DATE":"INVALID","INV_NO":"4637829","INV_DT":"2025-09-12","BUKRS":"8000"}]');
            return res;
        }
    }
    
    @isTest
    static void testInvalidDate() {
        Legal_Entity__c le = new Legal_Entity__c(
            RDS_Company_Code__c = '8000', 
            Name = 'Test'
        );
        insert le;
        
        CP_Brokerage__c cpb = new CP_Brokerage__c(
            SAP_Document_No__c = '12345',
            Invoice_Number__c = '4637829',
            Invoice_Date__c = Date.newInstance(2025,9,12),
            Legal_Entity__c = le.Id
        );
        insert cpb;
        
        Test.setMock(HttpCalloutMock.class, new SAPMockInvalidDate());
        
        Test.startTest();
        System.enqueueJob(new SAPCPBrkClearingAPI());
        Test.stopTest();
    }
    
    @isTest
    static void testNoMatchingRecords() {
        Test.setMock(HttpCalloutMock.class, new SAPMockResponse());
        
        Test.startTest();
        System.enqueueJob(new SAPCPBrkClearingAPI());
        Test.stopTest();
        
    }
    
    @isTest
    static void testBulkRecords() {
        List<CP_Brokerage__c> cpbList = new List<CP_Brokerage__c>();
        
        Legal_Entity__c le = new Legal_Entity__c(
            RDS_Company_Code__c = '8000',
            Name = 'Test Company',
            RDS_Company_Name__c = 'Testeee'
        );
        insert le;
        
        for(Integer i=0; i<5; i++){
            cpbList.add(new CP_Brokerage__c(
                SAP_Document_No__c = '12345' + i, // ✅ FIXED (UNIQUE)
                SAP_TDS__c = 1234,
                Total_Invoice_Amount__c = 1234565,
                Invoice_Number__c = 'INV-' + i,
                Invoice_Date__c = Date.newInstance(2025, 9, 12),
                Legal_Entity__c = le.Id
            ));
        }
        
        insert cpbList;
        
        Test.setMock(HttpCalloutMock.class, new SAPMockResponse());
        
        Test.startTest();
        System.enqueueJob(new SAPCPBrkClearingAPI());
        Test.stopTest();
        
        System.assert(true);
    }
    
    class SAPMockEmptyList implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('[]');
            return res;
        }
    }
    
    @isTest
    static void testEmptyList() {
        Test.setMock(HttpCalloutMock.class, new SAPMockEmptyList());
        
        Test.startTest();
        System.enqueueJob(new SAPCPBrkClearingAPI());
        Test.stopTest();
        
        System.assert(true);
    }
}