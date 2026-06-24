public class Ozonetel_AgentLoginCheck {
    
    public static Boolean agentLoginCheck(String agentId){
        Boolean loggedIn = false;
        String jsonData = '{"userName": "runwal","agentId": "' + agentId + '"}';
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://in1-ccaas-api.ozonetel.com/ca_apis/AgentDetails');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('apiKey', System.label.Ozonetel_API_Key);
        req.setBody(jsonData);
        Http http = new Http();
        HTTPResponse res = new HttpResponse();
        if(!Test.isRunningTest()){
            res = http.send(req);
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            if(responseMap.containsKey('message')) {
                Object messageObj = responseMap.get('message');
                // Case 1: message is a LIST
                if(messageObj instanceof List<Object>) {
                    List<Object> msgList = (List<Object>) messageObj;
                    if(!msgList.isEmpty()) {
                        Map<String, Object> agentData = (Map<String, Object>) msgList[0];
                        if(agentData.containsKey('State')) {
                            String state = (String) agentData.get('State');
                            if(state != 'LOGOUT') {
                                loggedIn = true;
                            }
                        }
                    }
                }
                // Case 2: message is STRING ("No Data Found")
                else if(messageObj instanceof String) {
                    loggedIn = false;
                }
            }
        }
        return loggedIn;
    }
    
}