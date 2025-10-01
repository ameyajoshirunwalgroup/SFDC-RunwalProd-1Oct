@RestResource(urlMapping='/KYCDetails/*')
global without sharing class KYCDetailsRestService {
	 @HttpGet
    global static String doGet(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        /*String appDetails = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        String docType = appDetails.split(':')[0];
        String appId = appDetails.split(':')[1];*/
        String docType = req.params.get('type');
        String appId = req.params.get('id');
        String docId;
        System.debug('docType: ' + docType);
        System.debug('appId: ' + appId);
        Map<String, String> mapDocTypeVsId = new Map<String, String>();
        List<Document_Details__c> documentDetailsRecord = [SELECT Id,RW_Applicant_Details__c,Applicant_Number__c,Booking__c,RW_Document_ID__c,
                                                           RW_Document_Type__c,RW_Residential_Status__c 
                                                           FROM Document_Details__c WHERE RW_Applicant_Details__c =: appId];
        if(documentDetailsRecord.size() > 0){
           for(Document_Details__c doc : documentDetailsRecord){
                mapDocTypeVsId.put(doc.RW_Document_Type__c, doc.RW_Document_ID__c);
            }
            System.debug('mapDocTypeVsId: ' + mapDocTypeVsId);
            if(docType == 'aadhar'){
                docId = mapDocTypeVsId.get('Aadhar Card');
                System.debug('docId: ' + docId);
                return distPublicUrl(docId);
            }else if(docType == 'pan'){
                docId = mapDocTypeVsId.get('PAN Card');
                return distPublicUrl(docId);
            }else{
                System.debug('else: ');
                return 'Please upload the document';
            }
            
            
        }else{
            return 'Please upload the document';
        }
        //return file.Title;
    }
    
     @HttpPost
    global static String doPost(String fileData, String recId, String docType, String appType, String resStatus, String oppId, String bkgId, String appNum, String fileType){
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        
        
        Blob blbdata = EncodingUtil.base64Decode(fileData);
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.PathOnClient = docType +'.'+fileType;
        cv.VersionData = blbdata;
        cv.IsMajorVersion = true;
        Insert cv;
        
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
             
        Document_Details__c Details = new Document_Details__c();
        Details.RW_Type_Of_Applicant__c = appType;
        Details.RW_Residential_Status__c = resStatus;
        Details.Opportunity__c = oppId;
        Details.RW_Document_Type__c= docType;
        Details.RW_Document_ID__c = conDocId;
        Details.Booking__c = bkgId;
        Details.Applicant_Number__c = appNum;
        Details.RW_Applicant_Details__c = recId;
        Details.RW_Document_Status__c = 'Active';
        insert Details;
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = conDocId;
        cdl.LinkedEntityId = recId;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;
        
        Applicant_Details__c app = [SELECT Id FROM Applicant_Details__c WHERE Id =: recId];
        if(docType == 'Aadhar Card'){
            app.Address_Proof__c = true;
        }else if(docType == 'PAN Card'){
            app.Pancard__c = true;
        }
        update app;
        
        return conDocId;
    }
    
    public static String distPublicUrl(String docId){
        if(docId != null){
            ContentVersion file = [SELECT Id, Title FROM ContentVersion WHERE ContentDocumentId =: docId];
            List<ContentDistribution> dist = [SELECT Id, DistributionPublicUrl, ContentDownloadUrl FROM ContentDistribution 
                                        WHERE ContentVersionId =: file.Id LIMIT 1];
            if(dist.size() > 0){
                return dist[0].DistributionPublicUrl;
            }else{
                ContentDistribution newDist = new ContentDistribution(
                                       Name = file.Title,
                                       ContentVersionId = file.Id,
                                       PreferencesAllowViewInBrowser= true,
                                       PreferencesNotifyOnVisit = false);
                insert newDist;
                ContentDistribution distb = [SELECT Id, DistributionPublicUrl, ContentDownloadUrl FROM ContentDistribution WHERE Id =: newDist.Id];
                return distb.DistributionPublicUrl;
            }
        }else{
            return 'Please upload the document';
        }
        
    }
}