/**
* @File Name : SubmitForApprovalReferral.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : November 14, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | November 14, 2024 |   | Initial Version
**/

public class SubmitForApprovalReferral {
	@AuraEnabled(cacheable=true)
    public static Boolean CheckAttachmentinReferralCredit(Id rcId){
        system.debug('rcId::'+rcId);
        List<Referral_Credits__c> referralCredit = new List<Referral_Credits__c>();
        List<User> CurrentUser = new List<User>();
        referralCredit = [Select id,name from Referral_Credits__c where id=:rcId];
        system.debug('referralCredit'+referralCredit);
        system.debug('Inside check');
        Boolean attachment = false;
        List<ContentVersion> contentv = new List<ContentVersion>();
        Set<Id> contentDocumentId = new Set<Id>();
        List<ContentDocumentLink> contentDocument = new List<ContentDocumentLink>();
        contentDocument = [SELECT ContentDocumentId, LinkedEntityId 
                           FROM   ContentDocumentLink 
                           WHERE  LinkedEntityId =: referralCredit[0].Id];
        for(ContentDocumentLink u : contentDocument){
            contentDocumentId.add(u.ContentDocumentId);
        }
        contentv = [SELECT Id, Title, FileExtension,ContentSize,Description, ContentDocumentId,CreatedDate
                    From ContentVersion WHERE  ContentDocumentId IN : contentDocumentId];
        if(contentv.isEmpty()){
            attachment = false;
        }else{
            attachment = true;
        }
        return attachment;
        // return true;//for testing
    }
     
     @AuraEnabled(cacheable=true)
    public static Boolean CheckUploadAttachmenttobeShown(Id rcId){
        system.debug('rcId::'+rcId);
        List<Referral_Credits__c> referralCredit = new List<Referral_Credits__c>();
        List<User> CurrentUser = new List<User>();
        referralCredit = [Select id,name,Approval_Status__c from Referral_Credits__c where id=:rcId];
        system.debug('Inside check');
        Boolean isShowUploadSection;
        if(referralCredit[0].Approval_Status__c ==  '' || referralCredit[0].Approval_Status__c == 'Rejected by L1' || referralCredit[0].Approval_Status__c ==  null ){
            isShowUploadSection = true;
        }else{
            isShowUploadSection = false;
        }



        return isShowUploadSection;
    }


    @AuraEnabled
    public static list<Id> createContentLink(list<Object> uploadedfile, String rcId) {
        System.debug('uploadedfile::'+ uploadedfile);
        System.debug('recordId::'+ rcId);
        List<Id> cvId = new List<Id>();
        List<ContentDocumentLink >  cdlupdate = new List<ContentDocumentLink >();
        List<ContentVersion> cv = new List<ContentVersion>();
        for (Object file : uploadedfile) {
            Fileupload fileData = (Fileupload)JSON.deserialize(JSON.serialize(file), Fileupload.class);
            System.debug('contentVersionId::'+ fileData.contentVersionId);
            cvId.add(fileData.contentVersionId);
        }
        if(!cvId.isEmpty()){
            cv = [Select id,title,ContentDocumentId  from ContentVersion where id IN:cvId];
            if(!cv.isEmpty()){
                for (ContentVersion cc : cv) {
                    ContentDocumentLink  cdl = new ContentDocumentLink();
                    cdl.ContentDocumentId = cc.ContentDocumentId ;
                    cdl.LinkedEntityId  = rcId;
                    cdl.ShareType = 'V';
                    cdl.Visibility = 'InternalUsers';
                    cdlupdate.add(cdl);
                }
            }
        }
        try {
            insert cdlupdate;
        } catch(DMLException e) {
            System.debug(e);
        }
        return cvId;      
    }

    @AuraEnabled
    public static list<ContentVersion> returnFiles(list<Object> lstFileIds){
        System.debug('lstFileIds::'+ lstFileIds);
        list<String> lstCntVerIds = new list<String>();
        for(Object fid :lstFileIds){
            System.debug('serialize::'+ JSON.serialize(fid));
            List<String> splitList = new List<String>();
            List<String> splitList2 = new List<String>();
            system.debug('fid::'+String.valueOf(fid).split('\\('));
            splitList = String.valueOf(fid).split('\\(');
            system.debug('splitList::'+splitList[1]);
            splitList2 = splitList[1].split('\\)');
                system.debug('splitList::'+splitList2[0]);
            //Fileupload2 fileData1 = (Fileupload2)JSON.deserialize(JSON.serialize(fid), Fileupload2.class);
            lstCntVerIds.add(splitList2[0]); 
        }
        system.debug('lstCntVerIds::'+lstCntVerIds);
        return [SELECT Id, Title,ContentDocumentId FROM ContentVersion WHERE Id IN :lstCntVerIds];
    }

    @AuraEnabled
    public static boolean SendForReferralApproval(String comment, Id rcId){
        system.debug('comment::'+comment);
        system.debug('rcId::'+rcId);
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments(comment);
        req1.setObjectId(rcId);
        req1.setProcessDefinitionNameOrId('Referral_Credits_Approval_Process');
        req1.setSkipEntryCriteria(true);
        try{
            Approval.ProcessResult result = Approval.process(req1);
            return true;
        }catch(Exception ex){
            if(!Test.isRunningTest()){
                throw new AuraHandledException(ex.getMessage());
            }else{
                system.debug('Exception LIne'+ex.getLineNumber());
                return null;
            }
            
            
        }
    }

    public class Fileupload {
        public String name;
        public String contentVersionId;
        public Blob contentBodyId;
    }
}