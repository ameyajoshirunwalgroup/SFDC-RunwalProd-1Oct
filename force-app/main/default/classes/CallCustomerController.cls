public class CallCustomerController {
    
    @AuraEnabled(cacheable=true)
    public static Opportunity oppData(String recId){
        system.debug('recId>>>' +recId);
        return [SELECT Id, Account.Mobile_No__c, Account.RW_Country__c, Account.Country_Code__c, Account.Dialing_Country_2__c, Account.Country_Code_2__c, Account.RW_Secondary_Mobile_No__pc, Account.Alternate_Mobile_No__c FROM Opportunity WHERE Id =: recId];
    }

    @AuraEnabled(cacheable=true)
    public static Opportunity loanData(String recId){
        system.debug('recId>>>' +recId);
        Loan__c loanRecord = [Select id,RW_Opportunity__c from Loan__c where Id =: recId];
        if(loanRecord!=null && loanRecord.RW_Opportunity__c!=null){
            return [SELECT Id, Account.Mobile_No__c, Account.RW_Country__c, Account.Country_Code__c, Account.Dialing_Country_2__c, Account.Country_Code_2__c, Account.RW_Secondary_Mobile_No__pc, Account.Alternate_Mobile_No__c FROM Opportunity WHERE Id =: loanRecord.RW_Opportunity__c];

        }
        return null;
    }   
    
    // added by vaishnavi 11/06/2025 
    @AuraEnabled(cacheable=true)
    public static Case caseData(String recId){
        system.debug('recId>>>>' +recId);
        return [SELECT Id, AccountId, Account.Mobile_No__c, Account.RW_Country__c, Account.Country_Code__c, Account.Dialing_Country_2__c, Account.Country_Code_2__c, Account.RW_Secondary_Mobile_No__pc, Account.Alternate_Mobile_No__c FROM CASE WHERE Id =: recId];
    }
    @AuraEnabled(cacheable=true)
    public static RW_Demand__c demandData(String recId){
        system.debug('recID>>>>>>' +recId);
      
        return [SELECT Id, Booking__r.Customer__r.AccountId, Booking__r.Customer__c, Booking__r.Customer__r.Account.Mobile_No__c, 
                Booking__r.Customer__r.Account.RW_Country__c,  Booking__r.Customer__r.Account.Country_Code__c, 
                Booking__r.Customer__r.Account.Dialing_Country_2__c,  Booking__r.Customer__r.Account.Country_Code_2__c, 
                Booking__r.Customer__r.Account.RW_Secondary_Mobile_No__pc,  Booking__r.Customer__r.Account.Alternate_Mobile_No__c
                FROM RW_Demand__c Where Id =: recId];
        
    }
    @AuraEnabled
    public static String callAPI(String customerPh, String countryCode, String recId){
        system.debug('countryCode>>>>' +countryCode);
        system.debug('click2CallCloudagent');
        system.debug('customerPh from page::: ' + customerPh);
        system.debug('recId::: ' + recId);
        String campaignName = '';
        String userName = '';
        String apiKey = '';
        String agentId = '';
        String mobileNum = customerPh;
        String mobileNumWithCountryCode = countryCode + customerPh;
        system.debug('Country Code : '+countryCode);
        if(customerPh.length() == 10 && (countryCode == '' || countryCode.equals('+91') || countryCode.equals('91') || countryCode.equals('0091') || countryCode.equals('091'))){          
            customerPh = '0' + customerPh;
            System.debug('Inside India Customer Phone:' + customerPh);
        } else {  
            system.debug('Inside International');
            List<User> userList = [Select Id/*, Enable_International_Calling__c*/ From User Where Id = :UserInfo.getUserId()];
            system.debug('userList'+userList);
            if(userList != null && userList.size() > 0){
                User usrRec = userList.get(0);
                //if(usrRec.Enable_International_Calling__c){ 
                System.debug('International Calling Enabled for user: ' + customerPh);
                if(countryCode != null && !String.isBlank(countryCode)){
                    if(customerPh != null && !String.isBlank(customerPh)){
                        customerPh = customerPh.removeStart('0');
                    }
                    if(countryCode.indexOf('\'++') != -1){
                        countryCode = countryCode.removeStart('\'++');
                        countryCode = '00' + countryCode;
                    } else if(countryCode.indexOf('\'+') != -1){
                        countryCode = countryCode.removeStart('\'+');
                        countryCode = '00' + countryCode;
                    } 
                    else if(countryCode.indexOf('+0') != -1){
                        countryCode = countryCode.removeStart('+0');
                        countryCode = '00' + countryCode;
                    } else if(countryCode.indexOf('0') != -1){
                        countryCode = countryCode.removeStart('0');
                        countryCode = '00' + countryCode;
                    } else if(countryCode.indexOf('+') != -1){
                        countryCode = countryCode.removeStart('+');
                        countryCode = '00' + countryCode;
                    } 
                    customerPh = countryCode + customerPh;
                }
                System.debug('countryCode:: ' + countryCode + ' customerPh:: ' + customerPh);
                //}           
            }
        }
        
        List<User> uList = [Select Id, CTI_Agent_ID__c, Campaign_name__c, api_key__c,Ozontel_UserName__c, Schedule_Campaign_Name__c, Profile.Name, Backup_Campaign__c, Tata_CTI_Agent_Number__c, International_Campaign__c From User Where Id = :UserInfo.getUserId()];
        if(uList != null && !uList.isEmpty()) {
            if(System.label.Conditional_Campaign_Assignment == 'true'){
                List<String> profilesList = new List<String>{'Relationship Manager','Team Leader'};
                    //if(uList[0].Profile.Name == 'Relationship Manager' || uList[0].Profile.Name == 'Team Leader'){
                    if(profilesList.contains(uList[0].Profile.Name)){
                        campaignName = uList[0].Schedule_Campaign_Name__c;
                    }else{
                        if(uList[0].Backup_Campaign__c != null){
                            campaignName = uList[0].Backup_Campaign__c;
                        }else{
                            campaignName = uList[0].Campaign_name__c;
                        }
                        //campaignName = uList[0].Campaign_name__c;
                    }
            }else{
                campaignName = uList[0].Campaign_name__c;
            }
            
            if(countryCode != '+91' && countryCode != '91' && countryCode != '0091' && countryCode != '091' && uList[0].Profile.Name == 'Pre Sales Executive'){
                campaignName = uList[0].International_Campaign__c;
            }
            
            //campaignName = uList[0].Campaign_name__c;
            //campaignName = uList[0].Schedule_Campaign_Name__c;
            //agentID = uList[0].CTI_Agent_ID__c;
            agentId = uList[0].CTI_Agent_ID__c;
            apiKey = uList[0].api_key__c; 
            userName = uList[0].Ozontel_UserName__c;
        }
        
        
        
        
        //Commented by coServe 22-08-2024   
        
        
        /*String queryString = 'api_key='+apiKey+'&username='+username+'&agentID='+agentId+'&campaignName='+campaignName+'&customerNumber='+customerPh;

//String endpoint = 'https://api1.cloudagent.in/CAServices/AgentManualDial.php?'+queryString;
String endpoint = 'https://in1-ccaas-api.ozonetel.com/CAServices/AgentManualDial.php?'+queryString;

System.debug('click2call URL:' + endpoint);
Http httpProtocol = new Http();

// Create HTTP request to send.
HttpRequest request = new HttpRequest();

request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
request.setMethod('GET');        
request.setEndPoint(endpoint);        
System.Debug('Request:'+request);

HttpResponse response = new HttpResponse();
if(!Test.isRunningTest()){
response = httpProtocol.send(request);
} else {
response.setBody('DUMMY');
}

System.debug(response.getBody());
string tempResponse = response.getBody();
return tempResponse; */
        
        if(uList[0].Tata_CTI_Agent_Number__c != null && uList[0].Tata_CTI_Agent_Number__c != ''){
            System.debug('Tata_CTI_Agent_Number__c: ' + uList[0].Tata_CTI_Agent_Number__c);
            String resp = tataCallAPI(mobileNumWithCountryCode,uList[0].Tata_CTI_Agent_Number__c, recId);
            /*String resp;
if(countryCode != '+91' && countryCode != '91' && countryCode != '0091' && countryCode != '091'){
resp = tataCallAPI(mobileNum,uList[0].Tata_CTI_Agent_Number__c, recId);
}else{
resp = tataCallAPI(mobileNumWithCountryCode,uList[0].Tata_CTI_Agent_Number__c, recId);
}*/
            return resp;
        }else{
            //Added by coServe 22-08-2024 Start
            ReqData rd = new ReqData();
            rd.userName = userName;
            rd.agentID = agentId;
            rd.campaignName = campaignName;
            rd.customerNumber = customerPh;
            rd.UCID = String.valueOf(true);
            rd.uui = recId;
            String jsonData = JSON.serialize(rd);
            System.debug('agentId: ' + agentId);
            apiKey = System.label.Ozonetel_API_Key;
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://in1-ccaas-api.ozonetel.com/ca_apis/AgentManualDial');//(.invalid) Added by Prashant
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('apiKey', apiKey);
            req.setBody(jsonData);
            system.debug('req>>>>>'+req);
            system.debug('jsonData>>>>>'+jsonData);
            system.debug('apiKey>>>>>'+apiKey);
            Http http = new Http();
            //HTTPResponse res = http.send(req);
            HTTPResponse res = new HttpResponse();
            system.debug('res>>>>' +res);
            if(!Test.isRunningTest()){
                res = http.send(req);
                system.debug('res1>>>>' +res);
            } else {
                res.setBody('{"status" : "queued successfully", "UCID" : "", "message" : ""}');
            }
            System.debug(res.getBody());
            
            RespData resp = new RespData();
            resp = (RespData)JSON.deserialize(res.getBody(), RespData.class);
            string tempResponse;
            if(resp.status == 'queued successfully'){
                tempResponse = resp.status + '!  UCID - ' + resp.UCID;
            }else if(resp.status == 'Fail' || resp.status == 'false'){
                tempResponse = resp.status + ' : ' + resp.message;
            }
            return tempResponse; 
            //Added by coServe 22-08-2024 End         
        }
        
    }
    
    
    public static String tataCallAPI(String customerPh, String agentNum, String recId){
        
        System.debug('tataCallAPI: ');
        
        String jsonData = '{"agent_number" : "' + agentNum + '", "destination_number" : "' + customerPh + '", "async" : 1, "recordId" : "' + recId + '", "get_call_id" : 1 }';
        //String jsonData = '{"agent_number" : "' + agentNum + '", "destination_number" : "' + customerPh + '", "async" : 1}';
        System.debug('jsonData: ' + jsonData);
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api-smartflo.tatateleservices.com/v1/click_to_call');
        req.setMethod('POST');
        req.setHeader('content-Type', 'application/json');
        //req.setHeader('Authorization', 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiI1NDA5MTgiLCJpc3MiOiJodHRwczovL2Nsb3VkcGhvbmUudGF0YXRlbGVzZXJ2aWNlcy5jb20vdG9rZW4vZ2VuZXJhdGUiLCJpYXQiOjE3Mjg5NzEyNDEsImV4cCI6MjAyODk3MTI0MSwibmJmIjoxNzI4OTcxMjQxLCJqdGkiOiJaaHFGbHRXNTRLcVlKUnp4In0.xLHWf3b5n3m7uij2yO2ja5D3lSdz0jj0vmthhpUofzc');
        req.setHeader('Authorization', System.label.Tata_Call_API_Authorization_Key);
        req.setBody(jsonData);
        
        Http http = new Http();
        HTTPResponse res = new HttpResponse();
        if(!Test.isRunningTest()){
            res = http.send(req);
        } else {
            res.setBody('{"status" : "queued successfully", "message" : ""}');
        }
        System.debug(res.getBody());
        TataRespData resp = new TataRespData();
        resp = (TataRespData)JSON.deserialize(res.getBody(), TataRespData.class);
        return resp.message;
    }
    
    public class ReqData{
        public String userName;
        public String agentID;
        public String campaignName;
        public String customerNumber;
        public String UCID;
        public String uui;
    }
    
    public class RespData{
        public String status;
        public String UCID;
        public String message;
    }
    
    public class TataRespData{
        public String success;
        public String message;
        public String call_id;
    }
}