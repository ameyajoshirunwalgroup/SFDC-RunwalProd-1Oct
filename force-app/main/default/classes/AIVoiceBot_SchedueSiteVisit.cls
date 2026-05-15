@RestResource(urlMapping='/AIVoiceBot/siteVisit/*')
global class AIVoiceBot_SchedueSiteVisit {
    
    @HttpPost
    global static void doPost(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        Map<String, Object> errorResult = new Map<String, Object>();
        try{
            system.debug('req: ' + req.requestBody);
            String jsonBody = req.requestBody.toString();
            system.debug('jsonBody: ' + jsonBody);
            ResponseDetails resData = (ResponseDetails)JSON.deserialize(jsonBody, ResponseDetails.class);
            system.debug('resData: ' + resData);
            if(resData != null && resData.visit_details != null && resData.visit_details.size() > 0){
                Map<String,VisitDetails> mobileMap = new Map<String,VisitDetails>();
                Map<String,VisitDetails> leadIdMap = new Map<String,VisitDetails>();
                for(VisitDetails resp : resData.visit_details){
                    if(resp.lead_id != null){
                        leadIdMap.put(resp.lead_id, resp);
                    }else if(resp.mobile != null){
                        mobileMap.put(resp.mobile, resp);
                    }
                }
                List<Lead> leads = new List<Lead>();
                if(leadIdMap.size() > 0){
                    for(String leadId : leadIdMap.keySet()){
                        String dateTimeStr = leadIdMap.get(leadId).visit_date + ' ' + leadIdMap.get(leadId).visit_time + ':00';
                        Datetime visitDateTime = Datetime.valueOf(dateTimeStr);
                        System.debug('visitDateTime ' + visitDateTime);
                        Lead ld = new Lead();
                        ld.Id = leadId;
                        //ld.Proposed_Visit_Date__c = visitDateTime;
                        ld.First_Call_Attempt_Date__c = visitDateTime;
                        leads.add(ld);
                    }
                }
                if(mobileMap.size() > 0){
                    for(String mobile : mobileMap.keySet()){
                        String dateTimeStr = mobileMap.get(mobile).visit_date + ' ' + mobileMap.get(mobile).visit_time + ':00';
                        Datetime visitDateTime = Datetime.valueOf(dateTimeStr);
                        Lead ld = [SELECT Id FROM Lead WHERE RW_Mobile_No__c =: mobile];
                        ld.Proposed_Visit_Date__c = visitDateTime;
                        leads.add(ld);
                    }
                }
                if(leads.size() > 0){
                    update leads;
                    res.responseBody = Blob.valueOf('Details updated successfully');
                    res.statusCode = 200;
                }
            }
            
        }catch(exception e){
            errorResult.put('status', 'error');
            errorResult.put('message', e.getMessage() + ';  ' + e.getStackTraceString());
            res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
            res.statusCode = 400;
        }
    }
    
    global class ResponseDetails{
        public List<VisitDetails> visit_details;
    }
    
    global class VisitDetails{
        public String lead_id;
        public String mobile;
        public String visit_date;
        public String visit_time;
        public String budget;
        public String configuration;
        public String timeline;
    }

}