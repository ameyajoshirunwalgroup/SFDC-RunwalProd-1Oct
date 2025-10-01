@isTest
public class TestSAPCreditNotADFAPICallout {
    
    class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            if (req.getMethod() == 'HEAD') {
                res.setHeader('x-csrf-token', 'mockCsrfToken');
                res.setHeader('Set-Cookie', 'mockCookie=abc123');
                res.setStatusCode(200);
            } else if (req.getMethod() == 'POST') {
                res.setStatusCode(201);
                res.setBody('{"status":"Success"}');
            }
            return res;
        }
    }

    @isTest
    static void testSAPCreditNoteADFCalloutExecution() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Create supporting records
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Opportunity opp = new Opportunity(Name = 'Test Opp', StageName = 'Prospecting', CloseDate = Date.today(), AccountId = acc.Id, SAP_Customer_Number__c = 'CUST123');
        insert opp;

        Project__c proj = new Project__c(Name = 'Test Project', RW_SAP_Company_Code__c = '1000', SAPMaterial_Code__c = 'MAT123');
        insert proj;

        Booking__c book = new Booking__c( Opportunity__c = opp.Id,  Project__c = proj.Id);
        insert book;

        Credit_Note__c cn = new Credit_Note__c(
           // Name = 'CN001',
            Approval_Status__c = 'Approved',
            //Customer_Name__c = 'Test Customer',
            Interest_To_Be_Settled__c = 1500,
            Reason_For_Settlement__c = 'Interest Refund',
            Booking__c = book.Id,
            ADF_Final_Approval_Date__c = Date.today()
        );
        insert cn;

        Test.startTest();
            SAPCreditNotADFAPICallout job = new SAPCreditNotADFAPICallout(new List<Id>{cn.Id});
            System.enqueueJob(job);

            POSTApprovedCN.getApprovedCN(new List<Id>{cn.Id});
        Test.stopTest();

        Credit_Note__c updatedCN = [SELECT Sent_to_SAP__c FROM Credit_Note__c WHERE Id = :cn.Id];
    }
}