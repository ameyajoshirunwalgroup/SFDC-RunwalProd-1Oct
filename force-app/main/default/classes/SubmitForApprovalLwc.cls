public class SubmitForApprovalLwc {
    @AuraEnabled
    public static Boolean SendForApproval(String comment, Id recId){
        
        try{
            system.debug('comment::'+comment);
            system.debug('recId::'+recId);
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments(comment);
            req1.setObjectId(recId);
            req1.setProcessDefinitionNameOrId('Send_Brokerage_Scheme_for_Approval');
            req1.setSkipEntryCriteria(true);
            Approval.ProcessResult result = Approval.process(req1);
            return true;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled(cacheable=true)
    public static Boolean CheckAttachment(Id schemeId){
        system.debug('schemeId::'+schemeId);
        List<Brokerage_Scheme__c> brokerageScheme = new List<Brokerage_Scheme__c>();
        brokerageScheme = [Select id,name from Brokerage_Scheme__c where id=:schemeId];
        system.debug('Inside check');
        Boolean attachment = false;
        List<ContentVersion> contentv = new List<ContentVersion>();
        Set<Id> contentDocumentId = new Set<Id>();
        List<ContentDocumentLink> contentDocument = new List<ContentDocumentLink>();
        contentDocument = [SELECT ContentDocumentId, LinkedEntityId 
                           FROM   ContentDocumentLink 
                           WHERE  LinkedEntityId =: brokerageScheme[0].id];
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
    }
    @AuraEnabled
    public static boolean SendForApprovalInvoice(String comment, Id recId){
        system.debug('comment::'+comment);
        system.debug('recId::'+recId);
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments(comment);
        req1.setObjectId(recId);
        req1.setProcessDefinitionNameOrId('CP_Invoice_Approval_Process_v33');
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
    @AuraEnabled(cacheable=true)
    public static Boolean CheckAttachmentInvoice(Id InvId){
        system.debug('InvId::'+InvId);
        List<Brokerage_Invoice__c> brokerageInv = new List<Brokerage_Invoice__c>();
        List<User> CurrentUser = new List<User>();
        brokerageInv = [Select id,name from Brokerage_Invoice__c where id=:InvId];
        system.debug('Inside check');
        Boolean attachment = false;
        List<ContentVersion> contentv = new List<ContentVersion>();
        List<ContentVersion> contentv2 = new List<ContentVersion>();
        Set<Id> contentDocumentId = new Set<Id>();
        List<ContentDocumentLink> contentDocument = new List<ContentDocumentLink>();
        contentDocument = [SELECT ContentDocumentId, LinkedEntityId 
                           FROM   ContentDocumentLink 
                           WHERE  LinkedEntityId =: brokerageInv[0].id];
        for(ContentDocumentLink u : contentDocument){
            contentDocumentId.add(u.ContentDocumentId);
        }
        contentv = [SELECT Id, Title, FileExtension,ContentSize,Description, ContentDocumentId,CreatedDate,OwnerId
                    From ContentVersion WHERE  ContentDocumentId IN : contentDocumentId order by CreatedDate Asc];
        for(ContentVersion c :contentv){
            List<User> ExistingUser = new List<User>();
            ExistingUser = [Select Id,ProfileId,UserType from user where Id =:c.OwnerId];
            if(ExistingUser[0].UserType == 'PowerPartner'){
                attachment = false;
            }else{
                attachment = true;
            }
        }
        /*if(!contentv.isEmpty()){
CurrentUser = [Select Id,ProfileId,UserType from user where Id =:UserInfo.getUserId()];
ExistingUser = [Select Id,ProfileId,UserType from user where Id =:contentv[0].OwnerId];
contentv2 = [SELECT Id, Title, FileExtension,ContentSize,Description, ContentDocumentId,CreatedDate,OwnerId
From ContentVersion WHERE  ContentDocumentId IN : contentDocumentId];
if(ExistingUser[0].UserType == 'PowerPartner'){
attachment = false;
}else{
attachment = true;
}
}else{
attachment = false;
}*/
        
        return true;
    }
    @AuraEnabled
    public static list<Id> createContentLink(list<Object> uploadedfile, String recId) {
        System.debug('uploadedfile::'+ uploadedfile);
        System.debug('recordId::'+ recId);
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
                    cdl.LinkedEntityId  = recId;
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
    public class Fileupload {
        public String name;
        public String contentVersionId;
        public Blob contentBodyId;
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
    public static list<ContentVersion> returnFilesignore(list<Object> lstFileIds){
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
    /*@AuraEnabled
    public static Boolean ApproveRecord(String RecId,String cmt){
        List<ProcessInstanceWorkitem> workItems = [
            SELECT Id, ProcessInstanceId 
            FROM ProcessInstanceWorkitem 
            WHERE ProcessInstance.TargetObjectId = :RecId and OriginalActorId = : UserInfo.getUserId()
        ];
        List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
        for(ProcessInstanceWorkitem workItem : workItems){
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setWorkitemId(workItem.Id);
            //Valid values are: Approve, Reject, or Removed. 
            //Only system administrators can specify Removed.
            req.setAction('Approve');
            req.setComments(cmt);
            requests.add(req);
        }
        Approval.ProcessResult[] processResults = Approval.process(requests);
        return null;
    }
    @AuraEnabled
    public static String RejectRecord(String RecId,String cmt){
        List<ProcessInstanceWorkitem> workItems = [
            SELECT Id, ProcessInstanceId 
            FROM ProcessInstanceWorkitem 
            WHERE ProcessInstance.TargetObjectId = :RecId and OriginalActorId = : UserInfo.getUserId()
        ];
        List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
        for(ProcessInstanceWorkitem workItem : workItems){
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setWorkitemId(workItem.Id);
            //Valid values are: Approve, Reject, or Removed. 
            //Only system administrators can specify Removed.
            req.setAction('Reject');
            req.setComments(cmt);
            requests.add(req);
        }
        Approval.ProcessResult[] processResults = Approval.process(requests);
        return null;
    }
    @AuraEnabled
    public static Boolean CheckApprovalReq(String RecId){
        Boolean noapprovalreq = false;
        List<ProcessInstanceWorkitem> workItems = [
            SELECT Id, ProcessInstanceId 
            FROM ProcessInstanceWorkitem 
            WHERE ProcessInstance.TargetObjectId = :RecId and OriginalActorId = : UserInfo.getUserId()
        ];
        system.debug('workItems::'+workItems);
        if(workItems.isEmpty()){
            noapprovalreq = true;
        }
        system.debug('noapprovalreq::'+noapprovalreq);
        return noapprovalreq;
    }*/
    @AuraEnabled(cacheable=true)
    public static Boolean CheckClient(Id InvId){
        system.debug('InvId::'+InvId);
        Boolean isnri = false;
        List<Brokerage_Invoice__c> brokerageInv = new List<Brokerage_Invoice__c>();
        brokerageInv = [Select id,name,Type_of_Client__c,Channel_Partner__r.Is_NRI_CP__c from Brokerage_Invoice__c where id=:InvId];
        if(brokerageInv[0].Type_of_Client__c == 'NRI'){
            isnri = true;            
        }
        else{
            isnri = false;
        }
        
        return isnri;
        
    }
     @AuraEnabled(cacheable=true)
    public static Boolean IsKicker(Id InvId){
        system.debug('InvId::'+InvId);
        Boolean iskicker = false;
        List<Brokerage_Invoice__c> brokerageInv = new List<Brokerage_Invoice__c>();
        brokerageInv = [Select id,name,Brokerage_Lookup__r.Brokerage_Type__c from Brokerage_Invoice__c where id=:InvId];
        if(brokerageInv[0].Brokerage_Lookup__r.Brokerage_Type__c == 'Kicker Incentive'){
            iskicker = true;            
        }
        else{
            iskicker = false;
        }
        return iskicker;
    
}
     @AuraEnabled(cacheable=true)
    public static Boolean CheckClientOuts(Id InvId){
        system.debug('InvId::'+InvId);
        Boolean isOutstation = false;
        List<Brokerage_Invoice__c> brokerageInv = new List<Brokerage_Invoice__c>();
        brokerageInv = [Select id,name,Type_of_Client__c,Channel_Partner__r.Place_of_Supply__c from Brokerage_Invoice__c where id=:InvId];
     
         if(brokerageInv[0].Type_of_Client__c == 'Outstation'){
            isOutstation = true;
        }else{
            isOutstation = false;	
        }
        return isOutstation;
    }
}