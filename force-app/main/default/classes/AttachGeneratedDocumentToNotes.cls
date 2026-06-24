public with sharing class AttachGeneratedDocumentToNotes {
    @InvocableMethod(label='Download Docupilot PDF' description='Downloads PDF from URL and uploads as File')
    public static void downloadAndAttach(List<Request> requests) {
        for(Request r : requests) {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(r.fileUrl);
            req.setMethod('GET');

            Http http = new Http();
            //HttpResponse res = http.send(req);
            HttpResponse res = new HttpResponse();
            if(Test.isRunningTest()){
                res.setStatusCode(200);
                res.setBody('{"status":"SUCCESS"}');
            }else{
                res = http.send(req);
            }
            if(res.getStatusCode() == 200) {
                // Create the file
                ContentVersion cv = new ContentVersion();
                cv.Title = r.fileName;
                cv.PathOnClient = r.fileName;
                cv.VersionData = res.getBodyAsBlob();
                insert cv;

                // Link file to record
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
                cdl.LinkedEntityId = r.recordId;
                cdl.ShareType = 'V';
                insert cdl;
            }
        }
    }

    public class Request {
        @InvocableVariable(required=true) public String fileUrl;
        @InvocableVariable(required=true) public String recordId;
        @InvocableVariable(required=true) public String fileName;
    }
}