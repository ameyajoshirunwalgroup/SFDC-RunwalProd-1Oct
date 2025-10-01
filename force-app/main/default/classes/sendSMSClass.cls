public Class sendSMSClass
{        
    public static void mySMS(String strURL)
    {
        
        system.debug('strURL In mySMS Class: ' + strURL);
        HttpRequest req = new HttpRequest();
        req.setEndpoint (strURL);
        req.setMethod ('GET');
        req.setTimeout(120000); // Addedd by Vinay 10-02-2025
        system.debug('req: ' + req);
        Http http = new Http();
        if(!test.isRunningTest()){
            HTTPResponse res = http.send(req);
            system.debug('HTTPResponse : '+ res);
        }
        
        
    }
}