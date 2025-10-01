@isTest
global class HTTPCalloutMockTestCommon implements HttpCalloutMock
{
	// Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"size":0,"totalSize":0,"done":true,"queryLocator":null,"entityTypeName":null,"records":[]}');
        res.setStatusCode(201);
        res.setStatus('NOT OK');
        return res;
    }
}