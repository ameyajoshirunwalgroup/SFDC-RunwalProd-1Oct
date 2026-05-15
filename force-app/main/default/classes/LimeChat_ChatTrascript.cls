@RestResource(urlMapping='/limeChatTranscript/*')
global class LimeChat_ChatTrascript {

    @HttpPost
    global static void doPost(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        Map<String, Object> errorResult = new Map<String, Object>();
        Map<String, Object> successResult = new Map<String, Object>();
        
        try{
            system.debug(req.requestBody);
        	String jsonBody = req.requestBody.toString();
            system.debug('jsonBody: ' + jsonBody);
            RequestData reqData = (RequestData)JSON.deserialize(jsonBody, RequestData.class);
            List<Lead> leadList = [SELECT Id FROM Lead WHERE RW_Mobile_No__c =: reqData.mobile AND WhatsApp_Lead_LimeChat__c = true];
            if(leadList.size() > 0){
                String transcriptText = reqData.transcript;
                
                ContentVersion cv = new ContentVersion();
                cv.Title = 'Chat_Transcript.txt';
                cv.PathOnClient = 'Chat_Transcript.txt';
                cv.VersionData = Blob.valueOf(transcriptText);
                insert cv;
                
                Id contentDocumentId = [
                    SELECT ContentDocumentId 
                    FROM ContentVersion 
                    WHERE Id = :cv.Id
                ].ContentDocumentId;
                
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = contentDocumentId;
                cdl.LinkedEntityId = leadList[0].Id;
                cdl.ShareType = 'V';
                cdl.Visibility = 'AllUsers';
                
                insert cdl;
            }
        }catch(exception e){
            errorResult.put('status', 'error');
            //errorResult.put('message', e.getMessage() + ';  ' + e.getStackTraceString());
            res.responseBody = Blob.valueOf(JSON.serialize(e.getMessage()));
            res.statusCode = 400;
        }
    }
    
    global class RequestData{
        public String mobile;
        public String transcript;
    }
}