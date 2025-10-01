public class CallCustomerOfflineController {
    
    @AuraEnabled(cacheable=true)
    public static Opportunity oppData(String recId){
        return [SELECT Id, Account.Mobile_No__c, Account.RW_Country__c, Account.Country_Code__c, Account.Dialing_Country_2__c, Account.Country_Code_2__c, Account.RW_Secondary_Mobile_No__pc, Account.Alternate_Mobile_No__c FROM Opportunity WHERE Id =: recId];
    }

    //Added by Dolly
    @AuraEnabled(cacheable=true)
    public static Opportunity loanData(String recId){
        system.debug('recId>>>' +recId);
        Loan__c loanRecord = [Select id,RW_Opportunity__c from Loan__c where Id =: recId];
        if(loanRecord!=null && loanRecord.RW_Opportunity__c!=null){
            return [SELECT Id, Account.Mobile_No__c, Account.RW_Country__c, Account.Country_Code__c, Account.Dialing_Country_2__c, Account.Country_Code_2__c, Account.RW_Secondary_Mobile_No__pc, Account.Alternate_Mobile_No__c FROM Opportunity WHERE Id =: loanRecord.RW_Opportunity__c];

        }
        return null;
    } 
    
    @AuraEnabled(cacheable=true)
    public static Account accData(String recId){ //Added by Vinay 01-08-2025
        system.debug('recId>>>' +recId);
        return [SELECT Id, Mobile_No__c, RW_Country__c, Country_Code__c, Country_Code_2__c, RW_Secondary_Mobile_No__pc, Alternate_Mobile_No__c FROM Account WHERE Id =: recId];
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
    public static String callAPI(String customerPh, String countryCode, String RecordId){
        
        system.debug('click2CallCloudagent');
        system.debug('customerPh from page::: ' + customerPh);
        String campaignName = '';
        String userName = '';
        String apiKey = '';
        String agentId = '';
        String PhoneName = '';
        String DID = '';
        String mobileNum = customerPh;
        String mobileNumWithCountryCode = countryCode + customerPh;
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
        
        List<User> uList = [Select Id, CTI_Agent_ID__c,	DID__c,Offline_Agent_Name__c, Campaign_name__c, api_key__c,Ozontel_UserName__c, Schedule_Campaign_Name__c, Profile.Name, Backup_Campaign__c, Tata_CTI_Agent_Number__c, International_Campaign__c, International_DID__c From User Where Id = :UserInfo.getUserId()];
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
            
            
            
            //campaignName = uList[0].Campaign_name__c;
            //campaignName = uList[0].Schedule_Campaign_Name__c;
            //agentID = uList[0].CTI_Agent_ID__c;
            agentId = uList[0].CTI_Agent_ID__c;
            apiKey = uList[0].api_key__c; 
            userName = uList[0].Ozontel_UserName__c;
            PhoneName = uList[0].Offline_Agent_Name__c;
            DID = uList[0].DID__c;
            
            if(countryCode != '+91' && countryCode != '91' && countryCode != '0091' && countryCode != '091' && uList[0].Profile.Name == 'Pre Sales Executive'){
                campaignName = uList[0].International_Campaign__c;
                DID = uList[0].International_DID__c;
            }
        }
        /////////////////////https://api1.cloudagent.in/CAServices/PhoneManualDial.php?apikey=KK37f7a89c616b3150169a5542ac1d97df&username=runwal&custNumber=+918668418263&phoneName=Pranay&did=918047921101&uui= 
        /////////////////////https://api1.cloudagent.in/CAServices/PhoneManualDial.php?apiKey=KK37f7a89c616b3150169a5542ac1d97df&userName=runwal&custNumber=+918668418263&phoneName=Pranay&did=918047921101&uui= 
        //String endpoint = 'https://api1.cloudagent.in/CAServices/PhoneManualDial.php?apiKey=KK37f7a89c616b3150169a5542ac1d97df&userName=runwal&custNumber=+918668418263&phoneName=Pranay&did=918047921101&uui= ';
        /////////////////////https://api1.cloudagent.in/CAServices/PhoneManualDial.php?apikey=KK37f7a89c616b3150169a5542ac1d97df&username=runwal&custNumber=+918668418263&phoneName=Pranay&did=918047921101&uui= 
        system.debug('Username::'+userName);
        system.debug('RecordId::'+RecordId);
        
        if(uList[0].Tata_CTI_Agent_Number__c != null){
            System.debug('Tata_CTI_Agent_Number__c: ' + uList[0].Tata_CTI_Agent_Number__c);
            String resp = CallCustomerController.tataCallAPI(mobileNumWithCountryCode,uList[0].Tata_CTI_Agent_Number__c, RecordId);
            /*String resp;
if(countryCode != '+91' && countryCode != '91' && countryCode != '0091' && countryCode != '091'){
resp = CallCustomerController.tataCallAPI(mobileNum,uList[0].Tata_CTI_Agent_Number__c, RecordId);
}else{
resp = CallCustomerController.tataCallAPI(mobileNumWithCountryCode,uList[0].Tata_CTI_Agent_Number__c, RecordId);
}*/
            return resp;
        }else{
            //Commented by coServe 22-08-2024 
            String queryString = 'apiKey='+apiKey+'&userName='+username+'&custNumber='+customerPh+'&phoneName='+PhoneName+'&did='+DID+'&uui='+RecordId;
            
            //String endpoint = 'https://api1.cloudagent.in/CAServices/PhoneManualDial.php?'+queryString;
            String endpoint = 'https://in1-ccaas-api.ozonetel.com/CAServices/PhoneManualDial.php?'+queryString;//(.invalid) Added by Prashant
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
            return tempResponse; 
        }
        
        
        //Added by coServe 22-08-2024 Start
        /*ReqData rd = new ReqData();
rd.userName = username;
rd.agentID = agentId;
rd.campaignName = campaignName;
rd.customerNumber = customerPh;
rd.UCID = String.valueOf(true);
rd.uui = RecordId;
String jsonData = JSON.serialize(rd);

apiKey = System.label.Ozonetel_API_Key;
HttpRequest req = new HttpRequest();
req.setEndpoint('https://in1-ccaas-api.ozonetel.com/ca_apis/AgentManualDial');
req.setMethod('POST');
req.setHeader('Content-Type', 'application/json');
req.setHeader('apiKey', apiKey);
req.setBody(jsonData);

Http http = new Http();
//HTTPResponse res = http.send(req);
HTTPResponse res = new HttpResponse();
if(!Test.isRunningTest()){
res = http.send(req);
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
return tempResponse;*/
        //Added by coServe 22-08-2024 End   
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
}