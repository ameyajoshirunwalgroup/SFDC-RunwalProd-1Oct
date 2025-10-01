@IsTest
global class PaymentLinkMock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake HTTP Response with the correct structure
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        
        // Simulating a successful response
        res.setBody('{"status": true, "data": {"payment_url": "https://testpayment.com"}}');
        res.setStatusCode(200);
        
        return res;
    }
}