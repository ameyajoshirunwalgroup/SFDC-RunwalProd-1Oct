@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {
      	
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"example":"test"}');
        res.setBody('{"subject":"vm","start":{"timeZone":"India Standard Time","dateTime":"2021-01-09T13:15:00"},"onlineMeetingProvider":"teamsForBusiness","onlineMeeting":{"joinUrl":"https://google.com"},"location":{"displayName":"online"},"isOnlineMeeting":true,"id":"QWERTY","end":{"timeZone":"India Standard Time","dateTime":"2021-01-09T13:30:00"},"body":{"contentType":"HTML","content":"gcmh"},"attendees":[{"type":"required","emailAddress":{"name":"mounika TestDec28","address":"mounika16r@gmail.com"}}],"allowNewTimeProposals":true}');
        res.setStatusCode(201);
        res.setStatusCode(200);
        return res;
    }
}