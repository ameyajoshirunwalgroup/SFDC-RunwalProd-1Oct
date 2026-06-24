public without sharing class EOICancellationController{
    @AuraEnabled
    public  static void sendApprovalRequest(String recordId){
        try{
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Request for EOI Cancellation');
        req1.setObjectId(recordId);
        
        // Submit on behalf of a specific submitter
        
        // Submit the record to specific process and skip the criteria evaluation
        req1.setProcessDefinitionNameOrId('EOI_Cancellation');
        //req1.setSkipEntryCriteria(true);
        
        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req1);
        
        // Verify the result
        //System.assert(result.isSuccess());
    }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
}
    
    @AuraEnabled
    public static String getProjectSiteHead(String eoiRecId){
        RW_EOI__c eoirec = Utility.getEOIRecord(eoiRecId);
        if(eoirec != null){
        return Utility.getProjectSiteHead(eoirec.Opportunity__r.RW_Project__c);
        }
        else{
            return '';
        }
    }
    
    @AuraEnabled
    public static RW_EOI__c getEOIRecordData(String eoiRecId){
        return Utility.getEOIRecord(eoiRecId);
    }
}