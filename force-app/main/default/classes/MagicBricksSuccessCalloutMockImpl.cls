@isTest
global class MagicBricksSuccessCalloutMockImpl implements HttpCalloutMock{
    global HTTPResponse respond (HTTPRequest request){
      //System.assertEquals ('',request.getEndpoint());
      //System.assertEquals('GET', request.getMethod());
      
      HTTPResponse response = new HTTPResponse();
      response.setStatusCode(200);
      response.setBody('<response>' +
                            '<status>success</status>' +
                            '<count>2</count>' +
                            '<leads>' +
                                '<lead>' +
                                    '<city>Bangalore</city>' +
                                    '<dt>20160607</dt>' +
                                    '<email>mayursolidMagicBricks@gmail.com</email>' +
                                    '<id>79467506</id>' +
                                    '<isd>91</isd>' +
                                    '<loginid>5740683</loginid>' +
                                    '<mobile>9845533577</mobile>' +
                                    '<msg>' +
                                    'Ozone Urbana, Bangalore I' +
                                    'am Interested. Please call me Additional Details City:' +
                                    'Karnataka' +
                                    '</msg>' +
                                    '<name>mayurMagicBricks</name>' +
                                    '<project>Runwal Bliss</project>' +
                                    '<subject>' +
                                    'Query from magicbricks.com Ozone' +
                                    'Urbana by Ozone Group Mailer' +
                                    '</subject>' +
                                    '<time>171613</time>' +
                                    '<tranType>b</tranType>' +
                                '</lead>' +
                                
                            '</leads>' +
                        '</response>');
      return response;
    }
}