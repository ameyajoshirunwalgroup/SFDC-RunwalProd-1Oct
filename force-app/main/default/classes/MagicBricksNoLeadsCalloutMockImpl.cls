@isTest
global class MagicBricksNoLeadsCalloutMockImpl implements HttpCalloutMock {
  global HTTPResponse respond (HTTPRequest request){
      //System.assertEquals ('',request.getEndpoint());
      System.assertEquals('GET', request.getMethod());
      
      HTTPResponse response = new HTTPResponse();
      response.setStatusCode(200);
      response.setBody('<response>' +
                            '<status>error</status>' +
                            '<errormsg>Invalid Date Range!!</errormsg>' +
                            '<count>0</count>' +
                            '<leads/>' +
                        '</response>');
      return response;
    }
}