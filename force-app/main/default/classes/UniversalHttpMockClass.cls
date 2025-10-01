@istest
global class UniversalHttpMockClass implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        system.debug(request.getEndpoint());
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"animal": {"id":2, "name":"Test"}}');
        response.setStatusCode(200);
        return response; 
    }
}