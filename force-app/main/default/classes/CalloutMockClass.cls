@isTest
global class CalloutMockClass implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if(req.getEndpoint().contains('add_loyalty_member')){
            res.setBody('{"status":"completed"}');
        }
        else if(req.getEndpoint().contains('credit_wallet')){
            res.setBody('{"status":"completed"}');
        }
        //res.setBody('{"status":"success","message":"Test Response"}');
        res.setStatusCode(200);

        return res;
    }
}