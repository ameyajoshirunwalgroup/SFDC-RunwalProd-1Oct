@RestResource(urlMapping='/TDSDetails/*')
global without sharing class TDSCertificatesRestService {
	@HttpGet
    global static String doGet(){
        RestRequest req = RestContext.request;
        String tdsDocId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        
        /*List<TDS__c> tdsDetailsRecord = [SELECT Id,RW_TDS_Certificate_Number__c,Booking__c,RW_Amount__c,RW_TDS_Document_ID__c FROM TDS__c 
                                         WHERE Booking__c =:bookingId LIMIT 1];*/
        
        return KYCDetailsRestService.distPublicUrl(tdsDocId);
    }
    
    @HttpPost
    global static String doPost(String fileData, String fileType, String bkgId, String certNum, Decimal amount, String oppId){
        
        Blob blbdata = EncodingUtil.base64Decode(fileData);
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.PathOnClient = 'TDS.'+fileType;
        cv.VersionData = blbdata;
        cv.IsMajorVersion = true;
        Insert cv;
        
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        TDS__c tds = new TDS__c();
        tds.RW_TDS_Document_ID__c = conDocId;
        tds.RW_TDS_Certificate_Number__c = certNum;
        tds.Booking__c = bkgId;
        tds.RW_Amount__c = amount;
        tds.Opportunity__c = oppId;
        insert tds;
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = conDocId;
        cdl.LinkedEntityId = tds.Id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;
        
        return tds.Id;
    }
}