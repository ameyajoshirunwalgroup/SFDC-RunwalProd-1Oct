@RestResource(urlMapping='/cpUploadInvoices/*')
global without sharing class Lockated_CPUploadCPInvoices {

    // Wrapper class for the Body (Only file details now)
    global class FileRequest {
        public String fileData;     // The Base64 encoded string
        public String fileName;     // Name of the file
    }

    @HttpPost
    global static void uploadInvoice() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        Map<String, Object> responseMap = new Map<String, Object>();
        
        try {
            // 1. Get invId from URL Parameter
            String invId = req.params.get('invId');
            
            if (String.isBlank(invId)) {
                res.statusCode = 400;
                responseMap.put('status', 'error');
                responseMap.put('message', 'invId parameter is missing in the URL');
                res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
                return;
            }

            // 2. Parse the Request Body for File Data
            String jsonBody = req.requestBody.toString();
            
            if (String.isBlank(jsonBody)) {
                res.statusCode = 400;
                responseMap.put('status', 'error');
                responseMap.put('message', 'Request body is empty.');
                res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
                return;
            }

            FileRequest input = (FileRequest)JSON.deserialize(jsonBody, FileRequest.class);

            if (String.isBlank(input.fileData)) {
                res.statusCode = 400;
                responseMap.put('status', 'error');
                responseMap.put('message', 'fileData (Base64 string) is missing in body.');
                res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
                return;
            }

            // Default filename if not provided
            String fName = String.isBlank(input.fileName) ? 'Invoice_' + System.now().getTime() + '.pdf' : input.fileName;

            // 3. Create ContentVersion (The File)
            ContentVersion cv = new ContentVersion();
            cv.Title = fName;
            cv.PathOnClient = fName; 
            cv.VersionData = EncodingUtil.base64Decode(input.fileData);
            
            // Link directly to the CP_Brokerage__c record from the Parameter
            cv.FirstPublishLocationId = invId; 
            
            insert cv;
            
            CP_Brokerage__c brokerageRecord = new CP_Brokerage__c();
            brokerageRecord.Id = invId; 
            brokerageRecord.Invoice_Status__c = 'Invoice Uploaded';
            
            update brokerageRecord;
            
            res.statusCode = 200;
            responseMap.put('status', 'success');
            responseMap.put('message', 'File uploaded successfully and now you can see this invoice in invoice raised section');
            
        } catch (Exception ex) {
            res.statusCode = 500;
            responseMap.put('status', 'error');
            responseMap.put('message', ex.getMessage());
        }
        res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
        return;
    }
}