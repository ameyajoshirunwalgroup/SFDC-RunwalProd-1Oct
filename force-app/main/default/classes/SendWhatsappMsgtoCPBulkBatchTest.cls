@isTest
public class SendWhatsappMsgtoCPBulkBatchTest {
    private class WhatsAppCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success", "message":"Message sent successfully"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest
    public static void test1(){
        list<Broker__c> brlist = new list<Broker__c>();
        Broker__c b = new Broker__c();
        b.Name = 'Test';
        b.RW_Email__c= 'test7849430@gmail.com';
        b.RW_Mobile_No__c = '3787654323';
        brlist.add(b);
        
        Broker__c b1 = new Broker__c();
        b1.Name = 'Test';
        b1.RW_Email__c= 'test7849430@gmail.com';
        brlist.add(b1);
        
        insert brlist;
        
        
        Test.setMock(HttpCalloutMock.class, new WhatsAppCalloutMock());
        Test.startTest();        
        String query = 'Select id,Name,RW_Email__c,RW_Mobile_No__c,RW_Broker_Number__c from Broker__c limit 100';
        Boolean sendEmail = true;        
        SendWhatsappMsgtoCPBulkBatch batch = new SendWhatsappMsgtoCPBulkBatch(query, sendEmail);
        Database.executeBatch(batch, 20);
        Test.stopTest();
        

    }
}