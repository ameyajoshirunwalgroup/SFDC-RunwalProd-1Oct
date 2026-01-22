@RestResource(urlMapping='/utrUpload/*')
global class LockatedApp_UploadUTRDetails {

    @HttpPost
    global static void doPost(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        Map<String, Object> errorResult = new Map<String, Object>();
        String postType = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        try{
            system.debug('req: ' + req.requestBody);
            String jsonBody = req.requestBody.toString();
            system.debug('jsonBody: ' + jsonBody);
            UTRDetails resData = (UTRDetails)JSON.deserialize(jsonBody, UTRDetails.class);
            system.debug('resData: ' + resData);
            system.debug('booking: ' + resData.booking);
            if(String.isBlank(resData.booking)){
                errorResult.put('status', 'error');
                errorResult.put('message', 'Please pass valid Booking Id');
                res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                res.statusCode = 400;
            }/*else if(String.isBlank(resData.utrNumber)){
                errorResult.put('status', 'error');
                errorResult.put('message', 'Please enter URT number');
                res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                res.statusCode = 400;
            }*/else{
                Receipt__c rec = new Receipt__c();
                rec.Booking__c = resData.booking;
                rec.UTR_Uploaded_From_Lockated_App__c = true;
                rec.Cheque_DD__c = resData.utrNumber;
                rec.Total_Amount__c = 0;
                if(postType == 'StampDuty'){
                    rec.UTR_Uploaded_For__c = postType;
                }else if(postType == 'Payment'){
                    rec.UTR_Uploaded_For__c = postType + ' ' + resData.paymentType;
                }
                //rec.UTR_Uploaded_For__c = postType;
                insert rec;
                
                Attachment attach = new Attachment();
                attach.ParentId = rec.Id;
                //attach.Name = postType + '.' + resData.fileType;
                attach.Name = rec.UTR_Uploaded_For__c + '.' + resData.fileType;
                attach.Body = EncodingUtil.base64Decode(resData.fileContent);
                attach.ContentType = 'application/resData.fileType';
                insert attach;
                
                res.responseBody = Blob.valueOf('UTR details updated successfully');
                res.statusCode = 200;
            }
        }catch(exception e){
            errorResult.put('status', 'error');
            errorResult.put('message', e.getMessage() + ';  ' + e.getStackTraceString());
            res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
            res.statusCode = 400;
        }
    }
    
    global class UTRDetails{
        public String booking;
        public String utrNumber;
        public String fileType;
        public String fileContent;
        public String paymentType;
    }
}