@RestResource(urlMapping='/ncf/*')
global class LockatedApp_NCFConfirmation {

    @HttpPost
    global static void doPost(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        Map<String, Object> errorResult = new Map<String, Object>();
        try{
            system.debug('req: ' + req.requestBody);
            String jsonBody = req.requestBody.toString();
            NCFDetails resData = (NCFDetails)JSON.deserialize(jsonBody, NCFDetails.class);
            if(String.isNotBlank(resData.booking)){
                Booking__c bkg = new Booking__c();
                bkg.Id = resData.booking;
                bkg.NCF_Status__c = resData.ncf_status;
                update bkg;
                res.responseBody = Blob.valueOf('Details updated successfully');
                res.statusCode = 200;
            }else{
                errorResult.put('status', 'error');
                errorResult.put('message', 'Please pass valid Booking Id');
                res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                res.statusCode = 400;
            }
        }catch(exception e){
            errorResult.put('status', 'error');
            errorResult.put('message', e.getMessage() + ';  ' + e.getStackTraceString());
            res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
            res.statusCode = 400;
        }
        
    }
    
    global class NCFDetails{
        public String booking;
        public String ncf_status;
    }
}