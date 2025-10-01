public class SubmitForApprovalQuotationLwc {
    @AuraEnabled
    public static Boolean SendForApproval(String comment, Id recId){
        system.debug('comment::'+comment);
        system.debug('recId::'+recId);
        Approval.ProcessSubmitRequest req1 = New Approval.ProcessSubmitRequest();
        req1.setComments(comment);
        req1.setObjectId(recId);
        req1.setProcessDefinitionNameOrId('Quotation_CP_Passback_Approval');
        
        
        Approval.ProcessResult result = Approval.process(req1);
        return true;
    }
     @AuraEnabled
    public static Boolean ReferralPassbackSendForApproval(String comment, Id recId){
        system.debug('comment::'+comment);
        system.debug('recId::'+recId);
        Approval.ProcessSubmitRequest req1 = New Approval.ProcessSubmitRequest();
        req1.setComments(comment);
        req1.setObjectId(recId);
        req1.setProcessDefinitionNameOrId('Quotation_Referral_Discount_Approval');
        
        
        Approval.ProcessResult result = Approval.process(req1);
        return true;
    }
   	 @AuraEnabled(cacheable=true)
     public static Boolean CheckAttachment(Id QuotationId){
        system.debug('QuotationId::'+QuotationId);
        List<Quotation__c> QuotationList = new List<Quotation__c>();
        QuotationList = [Select id,name from Quotation__c where id =: QuotationId];
        system.debug('Inside CheckAttachment');
        Boolean attachment = false;
        List<ContentVersion> contentv = New List<ContentVersion>();
        Set<Id> contentDocumentId = new Set<Id>();
        List<ContentDocumentLink> contentDocument = New List<ContentDocumentLink>();
        contentDocument = [SELECT ContentDocumentId, LinkedEntityId 
                           FROM   ContentDocumentLink 
                           WHERE  LinkedEntityId =: QuotationList[0].id];
        for(ContentDocumentLink u : contentDocument){
            contentDocumentId.add(u.ContentDocumentId);
        }
        contentv = [SELECT Id, Title, FileExtension,ContentSize,Description, ContentDocumentId,CreatedDate
                    From ContentVersion WHERE  ContentDocumentId IN : contentDocumentId];
        
        if(contentv.isEmpty()){
            attachment = false;
        }
        else{
            attachment = true;
        }                
        return attachment;        
    }
    
    @AuraEnabled(cacheable=true)
     public static Boolean CheckReferralPassback(Id QuotationId){
        system.debug('QuotationId::'+QuotationId);
        List<Quotation__c> QuotationList = new List<Quotation__c>();
        QuotationList = [Select id,name,Discount_10_Type__c,Referral_Passback__c from Quotation__c where id =: QuotationId and Discount_10_Type__c= 'Referral Passback' and Referral_Passback__c <=1];
        system.debug('Inside CheckReferralPassback');
         Boolean ReferralPassback = false;
      
         if(QuotationList[0].Discount_10_Type__c  == 'Referral Passback'){
        if(QuotationList.isEmpty()){
            ReferralPassback = false;
        }
        else{
            ReferralPassback = true;
        }   
      }             
        return ReferralPassback;        
    }

}