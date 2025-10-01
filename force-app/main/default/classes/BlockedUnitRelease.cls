public class BlockedUnitRelease {
    
    @AuraEnabled(cacheable=true)
    public static String releaseUnit(String oppId){
        System.debug('-- BlockedUnitRelease --');
        System.debug('oppId: ' + oppId);

        List<Blocking_Unit_Information__c> info = [SELECT Id, Active__c, Approval_Status__c, Opportunity__r.StageName, Opportunity__r.Blocked_Date__c, Opportunity__r.Reason_for_Release_Inventory__c FROM Blocking_Unit_Information__c WHERE Opportunity__c =: oppId AND Active__c = true];
        if(info.size() > 0){
            if((info[0].Approval_Status__c == 'Approved' || info[0].Approval_Status__c == 'Release Rejected') && info[0].Opportunity__r.Reason_for_Release_Inventory__c != null && info[0].Opportunity__r.StageName == 'Unit Blocked'){
                return info[0].Id;
            }else{
                throw new AuraHandledException('Either Blocking Unit is not Approved or the Reason for Release Inventory field is not updated');
            }
        }else{
            throw new AuraHandledException('No Active Blocking Unit Information Found');
        }
        
        
    }

    @AuraEnabled
    public static string sendApproval(String blkInfoId){
        try{
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('');
            req1.setObjectId(blkInfoId);
            req1.setProcessDefinitionNameOrId('Blocked_Unit_Release_Approval');
            Approval.ProcessResult result = Approval.process(req1);
            System.debug('result: ' + result);
            return 'Approval request submitted';
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    }
}