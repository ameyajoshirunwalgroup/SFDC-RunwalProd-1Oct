@isTest
global class HousingComSuccessCalloutMockImpl implements HttpCalloutMock{
    global HTTPResponse respond (HTTPRequest request){
      //System.assertEquals ('',request.getEndpoint());
      //System.assertEquals('GET', request.getMethod());
      
      HTTPResponse response = new HTTPResponse();
      response.setStatusCode(200);
     // [{"lead_date":1509466424,"lead_name":"amol","lead_email":"mantria10@gmail.com",
      //"lead_phone":"7378410707","project_id":45612,"project_name":"The Courtyard"},
      response.setBody('[{"lead_date":1509466424,"lead_name":"test Lead1","lead_email":"mayursolidHousingCom@gmail.com","lead_phone":"9845533577","project_id":45612,"project_name":"The Courtyard"},{"lead_date":1509466424,"lead_name":"test Lead2","lead_email":"mayurliquidHousingCom@gmail.com","lead_phone":"9845533578","project_id":45612,"project_name":"Runwal Bliss"}]');
                                 
      return response;
    }
}