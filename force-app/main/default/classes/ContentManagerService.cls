public with sharing class ContentManagerService {
    
    @AuraEnabled
    public static String getContentDetails(String recordId) {
        List<ContentDocumentLink> contentDocumentList = [SELECT ContentDocumentId, LinkedEntityId 
                                                            FROM   ContentDocumentLink 
                                                            WHERE  LinkedEntityId =: recordId];
        Set<Id> contentDocumentId = new Set<Id>();
            
        for(ContentDocumentLink cdl : contentDocumentList){
            contentDocumentId.add(cdl.ContentDocumentId);
        }
            
        List<ContentVersion> contentVersionList = [SELECT Id, FileType, Title, FileExtension,
                                                    ContentDocument.CreatedBy.Name, ContentDocument.ContentSize,
                                                    CreatedDate, ContentDocumentId, ContentDocument.FileType
                                                    FROM   ContentVersion 
                                                    WHERE  ContentDocumentId IN : contentDocumentId];//VersionData
        system.debug('contentVersionList::'+contentVersionList);
        return JSON.serialize(contentVersionList);
    }

    /*@AuraEnabled
    public static void deleteContentDocument(String recordId) {
        Database.delete(recordId);
    }*/
    @AuraEnabled
    public static void invoicestatus(String status,String recid){
        System.debug('status::'+status);
        System.debug('recid::'+recid);
        List<Brokerage_Invoice__c> cpInv = new List<Brokerage_Invoice__c>();
        Brokerage_Invoice__c cpl = new Brokerage_Invoice__c();
        cpInv = [select id,Name,Invoice_Status__c from Brokerage_Invoice__c where Id =:recid];
        if(!cpInv.isEmpty()){
            cpl.Invoice_Status__c = status;
            cpl.Id = cpInv[0].id;
            update cpl;  
        }
        
        
    }
    public static string ContentType(String fileType) {

        switch on fileType.toLowerCase(){
            when 'docx' {
                return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
            }
            when 'csv' {
                return 'application/vnd.ms-excel';
            }
            when 'wav' {
                return 'audio/wav';
            }
            when 'wmv' {
                return 'video/x-ms-wmv';
            }
            when 'mp3' {
                return 'audio/mpeg';
            }
            when 'mp4' {
                return 'video/mp4';
            }
            when 'png' {
                return 'image/png';
                
            }
            when 'pdf' {
                return 'application/pdf';
                
            }
            when else {
                return 'image/jpeg';
            }
        }

    }

    @AuraEnabled(cacheable=true)
    public static String getLoginURL(){
        String baseURL = System.URL.getSalesforceBaseUrl().toExternalForm();
        User userRecord = [Select Id, AccountId, ContactId FROM User Where Id = :UserInfo.getUserId()];
        if(userRecord.ContactId != null){
            baseUrl = getExperienceURL();
        }
        return baseUrl;
    }

    public static String getExperienceURL(){
        String baseUrl = Network.getLoginUrl(Network.getNetworkId());
        baseURL =  baseURL.replace('/s/login', '');
        baseURL =  baseURL.replace('/s/Login', '');
        baseURL =  baseURL.replace('/login', '');
        baseURL =  baseURL.replace('/Login', '');
        return baseURL;
    }
    
    
}