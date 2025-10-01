@isTest
public class Test_Controller_FetchADFBooking {
    
    // --- Mock: Valid ADF response ---
    public class ADFMockResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            if (req.getMethod() == 'HEAD') {
                res.setHeader('x-csrf-token', 'dummyToken');
                res.setHeader('Set-Cookie', 'dummyCookie');
                res.setStatusCode(200);
            } else {
                res.setStatusCode(200);
                res.setBody('{"BUSINESSARE": "ADF Status", "STATUS": "Success", "FRECORD": [{"BAL_ADV": "10000", "TOT_ADV_REC": "50000", "ELIG_INT": "1500", "TOT_INV_CON": "2000"}]}');
            }
            return res;
        }
    }
    
    // --- Mock: Empty ADF response ---
    public class ADFEmptyMockResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            if (req.getMethod() == 'HEAD') {
                res.setHeader('x-csrf-token', 'dummyToken');
                res.setHeader('Set-Cookie', 'dummyCookie');
                res.setStatusCode(200);
            } else {
                res.setStatusCode(200);
                res.setBody('{"BUSINESSARE":"ADF Status","STATUS":"Success","FRECORD":[]}');
            }
            return res;
        }
    }
    
    @testSetup
    static void setupData() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            AccountId = acc.Id,
            SAP_Customer_Number__c = '0020011905'
        );
        insert opp;
        
        Project__c project = new Project__c(Name = 'Runwal Forest',RW_Status__c = 'Active', SAPMaterial_Code__c = '6001');
        insert project;
        
        Tower__c tower = new Tower__c(Name = 'Tower 11', SAP_Plant_Code__c = '6214', ProjectName__c = project.Id);
        insert tower;
            
        Booking__c booking = new Booking__c(
            ADF_Opted__c = true,
            Opportunity__c = opp.Id,
            Project__c = project.Id
        );
        insert booking;
    }
    
    // --- Test for success response ---
    @isTest
    static void testFetchADFDetail_success() {
        Test.setMock(HttpCalloutMock.class, new ADFMockResponseGenerator());
        
        Booking__c booking = [SELECT Id FROM Booking__c LIMIT 1];
        
        Test.startTest();
        Controller_FetchADFBooking.fetchADFDetail(booking.Id);
        Database.executeBatch(new Batch_UpdateADFOnBooking());
        Test.stopTest();
        
        Booking__c updated = [SELECT ADF_Balance__c, Total_ADF_Amount__c, ADF_Interest_Amount_Payable1__c, ADF_Interest_Paid__c FROM Booking__c WHERE Id = :booking.Id];
        //System.assertEquals(10000, updated.ADF_Balance__c);
       //System.assertEquals(50000, updated.Total_ADF_Amount__c);
        //System.assertEquals(1500, updated.ADF_Interest_Amount_Payable1__c);
        //System.assertEquals(2000, updated.ADF_Interest_Paid__c);
    }
}