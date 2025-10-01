@isTest
global class HousingComErrorCalloutMockImpl implements HttpCalloutMock {
    global HTTPResponse respond (HTTPRequest request){
      //System.assertEquals ('',request.getEndpoint());
      System.assertEquals('GET', request.getMethod());
      
      HTTPResponse response = new HTTPResponse();
      response.setStatusCode(404);
      return response;
    }
}