@RestResource(urlMapping='/cpGetInvoiceDocument/*')
global class Lockated_CPGetCPInvoices {
    @HttpGet
    global static void getInvoice(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        Map<String, Object> responseMap = new Map<String, Object>();
        try{
            String invId = req.params.get('invId');
            if(String.isBlank(invId)){
                res.statusCode = 400;
                responseMap.put('status','error');
                responseMap.put('message','invId parameter is missing in the URL');
                res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
                return;
            }
            List<ContentDocumentLink> links = [
                SELECT ContentDocumentId 
                FROM ContentDocumentLink 
                WHERE LinkedEntityId = :invId 
                ORDER BY SystemModstamp DESC 
                LIMIT 1
            ];
            if(links.isEmpty()){
                res.statusCode = 404;
                responseMap.put('status','error');
                responseMap.put('message','No document found for the provided invId.');
                res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
                return;
            }
            Id docId = links[0].ContentDocumentId;
            ContentVersion cv = [Select Title, VersionData, FileExtension, FileType from ContentVersion 
                                 where ContentDocumentId =: docId and IsLatest = true limit 1];
            responseMap.put('status','success');
            responseMap.put('fileName',cv.Title);
            responseMap.put('fileExtension',cv.FileExtension);
            responseMap.put('fileData',EncodingUtil.base64Encode(cv.VersionData));
            res.statusCode = 200;
        }catch(Exception ex){
            res.statusCode = 500;
            responseMap.put('status','error');
            responseMap.put('message',ex.getMessage());
        }
        res.addHeader('Content-Type','application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
    }
}