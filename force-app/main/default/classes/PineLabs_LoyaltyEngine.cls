@RestResource(urlMapping='/loyaltyEngine/*')
global class PineLabs_LoyaltyEngine {

    @HttpGet
    global static void customerPoins(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        Map<String, Object> errorResult = new Map<String, Object>();
        Date fromDate;
        Date toDate;
        if(req != null && req.requestBody != null){
            system.debug('req: ' + req.requestBody);
            String jsonBody = req.requestBody.toString();
            system.debug('jsonBody: ' + jsonBody);
            
            if(String.isNotBlank(jsonBody)){
                DateRange resData = (DateRange)JSON.deserialize(jsonBody, DateRange.class);
                
                if(resData != null){
                    fromDate = (resData.fromDate != '')? Date.valueOf(resData.fromDate) : null;
                    toDate = (resData.toDate != '')? Date.valueOf(resData.toDate) : null;
                }
            }
            
            try{
                List<Referral_Points__c> refPoints = [SELECT Id,Type__c,Booking__r.Opportunity__r.RW_Mobile_No__c,CreatedDate FROM Referral_Points__c WHERE CreatedDate >=: fromDate AND CreatedDate <: toDate];
                
                for(Referral_Points__c ref : refPoints){
                    if(ref.Type__c == 'Birtday'){
                        Details det = new Details();
                        det.mobile_number = ref.Booking__r.Opportunity__r.RW_Mobile_No__c;
                        det.points = ref.Points__c;
                    }
                }
                
            }catch(exception e){
                errorResult.put('status', 'error');
                errorResult.put('message', e.getMessage() + ';  ' + e.getStackTraceString());
                res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                res.statusCode = 400;
            }
        }
    }
    
    global class DateRange{
        public String fromDate;
        public String toDate;
    }
    
    global class Details{
        public String mobile_number;
        public Decimal points;
    }
}