global class callActionController {
    
    public String accountId {get;set;}
    
    public callActionController(ApexPages.StandardController controller){  
         accountId = controller.getId();
    }
    public callActionController(){  
    }
    
    @RemoteAction
    global static Map<String,String> getPhoneFields(Id accId) {
        system.debug('inside getphoneFields method');
        List<Pair> lstfieldname = new List<Pair>();
        String queryFields;
        String sObjectName;
        Map<String,String> resultsMap = new Map<String,String>();
        // sObject types to describe
        String[] types = new String[]{'Account'};
        // Make the describe call
        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
        System.debug('Got describe information for ' + results.size() + ' sObjects.');
        // For each returned result, get some info
        for(Schema.DescribeSobjectResult res : results) {
            System.debug('sObject Label: ' + res.getLabel());
            sObjectname = res.getName();
            System.debug('Number of fields: ' + res.fields.getMap().size());
            System.debug(res.isCustom() ? 'This is a custom object.' : 'This is a standard object.');
            System.debug('Fields Map:' + res.fields.getMap());
            Map <String, Schema.SObjectField> fieldMap = res.fields.getMap();
            queryFields = 'Select ';
            for(Schema.SObjectField sfield : fieldMap.Values())
            {
                schema.describefieldresult dfield = sfield.getDescribe();
                Pair field = new Pair();
                //String fieldType = dfield.getType().name();
                String fieldLabel = dfield.getLabel();
                system.debug('fieldLabel ::: '+fieldLabel);
                if(fieldLabel.equalsIgnoreCase('Mobile No') || fieldLabel.equalsIgnoreCase('Secondary Mobile No.') || fieldLabel.equalsIgnoreCase('Account Phone')) {
                    field.key = dfield.getname();
                    field.val = dfield.getLabel ();
                    queryFields += dField.getName() + ',';
                    lstfieldname.add(field);
                }
                
            }
            
        }
        if(queryFields.length() > 0 && queryFields.substring(queryFields.length() -1).equals(','))
            queryFields = queryFields.substring(0,queryFields.length() -1);
        String query = queryFields + ' FROM ' + sObjectName + ' where Id = :accId';
        System.debug('List Field Names:' + lstFieldName);
        System.debug ('Query :' + query);
        List<sObject> sobjList = Database.query(query);
        System.debug('results: ' + sobjList[0]);
        for(Pair p : lstFieldName) {
            if(sObjList[0].get(p.key) != null) {
                System.debug('Field Name:' + p.val + '==>' + sObjList[0].get(p.key));
                String mobile = string.valueOf(sObjList[0].get(p.key));
                resultsMap.put(mobile.replace(mobile.substring(0,5),'XXXXX'), string.valueOf(sObjList[0].get(p.key)));
            }
        }
        return resultsMap;
    }
    
    @RemoteAction
    global static Map<String,String> getAllPhoneFields(Id accId) {
        List<Pair> lstfieldname = new List<Pair>();
        String queryFields;
        String sObjectName;
        Map<String,String> resultsMap = new Map<String,String>();
        // sObject types to describe
        String[] types = new String[]{'Account'};
        // Make the describe call
        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
        System.debug('Got describe information for ' + results.size() + ' sObjects.');
        // For each returned result, get some info
        for(Schema.DescribeSobjectResult res : results) {
            System.debug('sObject Label: ' + res.getLabel());
            sObjectname = res.getName();
            System.debug('Number of fields: ' + res.fields.getMap().size());
            System.debug(res.isCustom() ? 'This is a custom object.' : 'This is a standard object.');
            System.debug('Fields Map:' + res.fields.getMap());
            Map <String, Schema.SObjectField> fieldMap = res.fields.getMap();
            queryFields = 'Select ';
            for(Schema.SObjectField sfield : fieldMap.Values())
            {
                schema.describefieldresult dfield = sfield.getDescribe();
                Pair field = new Pair();
                String fieldType = dfield.getType().name();
                if(fieldType.equalsIgnoreCase('Phone')) {
                    field.key = dfield.getname();
                    field.val = dfield.getLabel ();
                    queryFields += dField.getName() + ',';
                    lstfieldname.add(field);
                }
                
            }
            
        }
        if(queryFields.length() > 0 && queryFields.substring(queryFields.length() -1).equals(','))
            queryFields = queryFields.substring(0,queryFields.length() -1);
        String query = queryFields + ' FROM ' + sObjectName + ' where Id = :accId';
        System.debug('List Field Names:' + lstFieldName);
        System.debug ('Query :' + query);
        List<sObject> sobjList = Database.query(query);
        System.debug('results: ' + sobjList[0]);
        for(Pair p : lstFieldName) {
            if(sObjList[0].get(p.key) != null) {
                System.debug('Field Name:' + p.val + '==>' + sObjList[0].get(p.key));
                String mobile = string.valueOf(sObjList[0].get(p.key));
                resultsMap.put(mobile.replace(mobile.substring(0,5),'XXXXX'), string.valueOf(sObjList[0].get(p.key)));
            }
        }
        return resultsMap;
    }
    
    @RemoteAction
    global static String click2CallKnowlarity(String recId, String customerPh) {
        JSONGenerator generator = JSON.createGenerator(true);   //instantiation of the generator
        generator.writeStartObject();               // Writes the starting marker of a JSON object '{'
        generator.writeStringField('k_number', '+917666912517');  
        generator.writeStringField('agent_number', '+919819369644');
        generator.writeStringField('customer_number', '+91' + customerPh);
        generator.writeEndObject(); 
         
        String jsonString = generator.getAsString();
        System.debug('JSON:' + jsonString);
        String endpoint = 'https://kpi.knowlarity.com/Basic/v1/account/call/makecall';
        System.debug('click2call URL:' + endpoint);
        Http httpProtocol = new Http();
        // Create HTTP request to send.
        HttpRequest request = new HttpRequest();
        
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'b835b06e-88cd-43d8-a63b-0a4212bc948d');
        request.setHeader('x-api-key', 'k0PpKUZUkq66ChJGuVgeT2V7CTJwAry89Db0MvqE');
        
        request.setMethod('POST');
        request.setEndPoint(endpoint);
        request.setBody(jsonString);
        System.Debug('Request:'+request);
        HttpResponse response = new HttpResponse();
        if(!Test.isRunningTest()){
            response = httpProtocol.send(request);
        } else {
             response.setBody('DUMMY');
        }
        System.debug(response.getBody());
        
        return (response.getBody());
       
    }
    
    // Ameyo manual dial API
    @RemoteAction
    global static String click2Call(String recId, String customerPh) {
        String userId = UserInfo.getUserId();
        String agentId = String.valueOf([Select Ameyo_Agent_Id__c From User Where Id = :UserInfo.getUserId()][0].Ameyo_Agent_Id__c);
        JSONGenerator generator = JSON.createGenerator(true);   //instantiation of the generator
        generator.writeStartObject();               // Writes the starting marker of a JSON object '{'
        generator.writeStringField('userId', agentId);  
        generator.writeNumberField('campaignId', 50);
        generator.writeStringField('phone', customerPh);
        generator.writeStringField('shouldAddCustomer', 'false');
        generator.writeFieldName('additionalParams');
        
        generator.writeStartObject(); 
        generator.writeStringField('recordId',recId);
        generator.writeEndObject(); 
         
        generator.writeEndObject(); 
                 
        String jsonString = generator.getAsString();
        System.debug('JSON:' + jsonString);
        String encodedJSON = EncodingUtil.urlEncode(jsonString, 'UTF-8');
        //String endpoint = 'http://203.115.114.90:8888/ameyowebaccess/command/?command=clickToDialWithToken&data='+encodedJSON;
        String endpoint = 'http://202.149.220.187:8888/ameyowebaccess/command/?command=clickToDialWithToken&data='+encodedJSON+'invalid';
        System.debug('click2call URL:' + endpoint);
        Http httpProtocol = new Http();
        // Create HTTP request to send.
        HttpRequest request = new HttpRequest();
        
        request.setHeader('hash-key', 'fecace70bf6ea0c450c5b2071cbabc9');
        request.setHeader('policy-name', 'token-based-authorization-policy');
        request.setHeader('requesting-host', 'runwal-api');
        request.setTimeout(120000);

        request.setMethod('GET');
        request.setEndPoint(endPoint);
        // request.setBody(jsonString);
        System.Debug('Request:'+request);
        HttpResponse response = new HttpResponse();
        if(!Test.isRunningTest()){
            response = httpProtocol.send(request);
        } else {
             response.setBody('DUMMY');
        }
        System.debug(response.getBody());
        
        return (response.getBody());
       
    }
    
    public class Pair
    {
        public String key {get; set;}
        public String val {get; set;}
    }
    
}