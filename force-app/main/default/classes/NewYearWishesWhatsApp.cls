global class NewYearWishesWhatsApp implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        List<Opportunity> opps = [SELECT Id, AccountId FROM Opportunity WHERE StageName = 'Unit Booked'];
        Set<Id> accIds = new Set<Id>();
        for(Opportunity opp : opps){
            accIds.add(opp.AccountId);
        }
        return Database.getQueryLocator([SELECT Id, Mobile_No__c, Country_Code__c FROM Account WHERE Id IN: accIds]);
    }
    
    global void execute(Database.BatchableContext BC,list<Account> accList){
        if(accList.size() > 0){
            for(Account acc : accList){
                String jsonParse;
                String templateName = 'new_year_wishes';
                String languageCode = 'en';
                if(String.isNotBlank(acc.Country_Code__c) && acc.Country_Code__c != null){
                    jsonParse = '{"countryCode" : ' + '"' + acc.Country_Code__c + '",';
                }else{
                    jsonParse = '{"countryCode" : "+91",';
                }
                jsonParse += '"phoneNumber" : ' + '"' + acc.Mobile_No__c + '",';
                jsonParse += '"type" : "Template",';
                jsonParse += '"template" : { "name" : '  + '"' + templateName + '", "languageCode" : "'+languageCode+'",';
                jsonParse += '"headerValues"  : [';
                jsonParse += '"' + System.label.New_Year_Wishes + '"';
                jsonParse += '],';
                jsonParse += '"bodyValues"  : [';
                jsonParse += '],';
                jsonParse += '"buttonPayload" : {';
                jsonParse += '"0" : ["';
                jsonParse +=  'Test' + '"]},';
                
                jsonParse += '"buttonValues" : {';
                jsonParse += '"0" : ["';
                jsonParse +=  'Test' + '"]}}}';
                
                JSONParser parser = JSON.createParser(jsonParse);
                //string str = System.JSON.serialize(parser);
                Http http = new Http();
                HttpRequest req = new HttpRequest(); 
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Authorization', 'Basic ' + System.Label.Interakt_Secret_Key); 
                req.setEndpoint('https://api.interakt.ai/v1/public/message/');
                req.setBody(jsonParse);
                if(!Test.isRunningTest()){
                    HTTPResponse res = http.send(req);
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){
        
    }

}