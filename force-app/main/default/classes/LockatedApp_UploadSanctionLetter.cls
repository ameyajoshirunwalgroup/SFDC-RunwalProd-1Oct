@RestResource(urlMapping='/sanctionLetter/*')
global class LockatedApp_UploadSanctionLetter {
	
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
            SanctionDetails resData = (SanctionDetails)JSON.deserialize(jsonBody, SanctionDetails.class);
            system.debug('resData: ' + resData);
            system.debug('booking: ' + resData.booking);
            if(String.isBlank(resData.booking)){
                errorResult.put('status', 'error');
                errorResult.put('message', 'Please pass valid Booking Id');
                res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                res.statusCode = 400;
            }else{
                List<Loan__c> ln = [SELECT Id FROM Loan__c WHERE RW_Booking__c =: resData.booking];
                
                
                Blob fileBody = EncodingUtil.base64Decode(resData.fileContent);
                
                ContentVersion contentVersion = new ContentVersion();
                contentVersion.Title = 'Sanction Letter';                     
                contentVersion.PathOnClient = 'Sanction Letter.pdf';     
                contentVersion.VersionData = fileBody;                
                insert contentVersion;
                
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = [
                    SELECT ContentDocumentId 
                    FROM ContentVersion 
                    WHERE Id = :contentVersion.Id
                ].ContentDocumentId;
                
               
                cdl.LinkedEntityId = ln[0].Id; 
                cdl.ShareType = 'V'; 
                cdl.Visibility = 'AllUsers';
                insert cdl;
                
                ln[0].RW_Sanction_Letter_ID__c = cdl.ContentDocumentId;
                update ln[0];
                
                res.responseBody = Blob.valueOf('Sanction letter uploaded successfully');
                res.statusCode = 200;
            }
        }catch(exception e){
            errorResult.put('status', 'error');
            errorResult.put('message', e.getMessage() + ';  ' + e.getStackTraceString());
            res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
            res.statusCode = 400;
        }
    }
    
    global class SanctionDetails{
        public String booking;
        public String fileType;
        public String fileContent;
    }
}