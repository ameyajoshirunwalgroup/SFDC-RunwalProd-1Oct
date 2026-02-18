@isTest
global class Lockated_CP_Mock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response for the Lockated API
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"status": "success", "message": "Channel Partner created"}');
        res.setStatusCode(201); // Match the success code in your service class
        return res;
    }
}