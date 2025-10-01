@istest

global class UniversalIrisMockErrorClass implements HttpCalloutMock{
  global HTTPResponse respond(HTTPRequest request) {
        system.debug(request.getEndpoint());
        HttpResponse response = new HttpResponse();
	              CalloutException e = new CalloutException();
        e.setMessage('Validation Error(s) occurred during inventory Get.');
        throw e; 
            
    }
}