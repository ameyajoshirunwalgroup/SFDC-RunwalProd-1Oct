@isTest
global class HTTPCalloutMockTestAuraCommon implements HttpCalloutMock
{
	// Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"totalSize":129,"done":true,"records":[{"attributes":{"type":"AuraDefinition","url":"/services/data/v36.0/sobjects/AuraDefinition/0Ad28000000gpUVCAY"},"LastModifiedDate":"2017-01-16T05:58:59.000+0000","LastModifiedBy":{"attributes":{"type":"User","url":"/services/data/v36.0/sobjects/User/00528000003o059AAA"},"Name":"Syed Insha Jawaid"},"AuraDefinitionBundleId":"0Ab2800000019UsCAI","DefType":"APPLICATION","Format":"XML","Id":"0Ad28000000gpUVCAY"}]}');
        res.setStatusCode(201);
        res.setStatus('NOT OK');
        return res;
    }
}