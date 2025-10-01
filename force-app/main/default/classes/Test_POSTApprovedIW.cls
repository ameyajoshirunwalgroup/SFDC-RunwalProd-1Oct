@isTest
public class Test_POSTApprovedIW {
    
    // Mock class for simulating SAP callout
    class MockSAPCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            
            if (req.getMethod() == 'HEAD') {
                res.setHeader('x-csrf-token', 'dummy_token');
                res.setHeader('Set-Cookie', 'dummy_cookie');
                res.setStatusCode(200);
                res.setBody('HEAD call successful');
            } else if (req.getMethod() == 'POST') {
                res.setStatusCode(201);
                res.setStatus('Created');
                res.setBody('Interest waiver created in SAP');
            }
            return res;
        }
    }
      class WhatsAppMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"status":"success"}');
            return res;
        }
    }
 

    @isTest
    static void testGetApprovedIW() {
        // Setup mock
        Test.setMock(HttpCalloutMock.class, new MockSAPCallout());
   Test.setMock(HttpCalloutMock.class, new WhatsAppMock());
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

         RW_Demand__c demand = new RW_Demand__c(
            RW_Billing_Document_Number__c = '1000001',
            Booking__c = objBooking.Id,
            Due_Date__c = Date.today()
        );
        insert demand;
        
        // Create Interest Waiver record
        Interest_Waiver__c objIW = new Interest_Waiver__c();
            objIW.Booking__c = objBooking.Id;
            objIW.Approval_Status__c = 'Approved';
            objIW.Waiver_Amount__c = 50;
            objIW.Demand__c = demand.id;
            objIW.Is_Send_To_SAP__c = false;
        insert objIW;

        // Create Custom Metadata for SAP config
        SAP_Integration__mdt config = new SAP_Integration__mdt();
        
        Test.startTest();
           POSTApprovedInterestWaivers.getApprovedIW(new List<Id>{ objIW.Id });
        SAPInterestWaiverAPICallOutNew.sendWhatsAppMsg(objIW.Id, 'CustName', 'UNIT1', '92093098371', '100');
        SAPInterestWaiverAPICallOutNew.dummyMethod();
        Test.stopTest();

        // Verify that Is_Send_To_SAP__c is updated
        Interest_Waiver__c updatedIW = [SELECT Id, Is_Send_To_SAP__c FROM Interest_Waiver__c WHERE Id = :objIW.Id];
        System.assertEquals(true, updatedIW.Is_Send_To_SAP__c);
    }
   
  
}