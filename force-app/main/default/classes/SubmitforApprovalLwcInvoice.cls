public class SubmitforApprovalLwcInvoice {
@AuraEnabled
public static Boolean SendForApproval(String comment, Id recId){
        
        try{
            system.debug('comment::'+comment);
            system.debug('recId::'+recId);
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments(comment);
            req1.setObjectId(recId);
            req1.setProcessDefinitionNameOrId('CP_Invoice_Clearing_Approval_ProcessRej');
            req1.setSkipEntryCriteria(true);
            Approval.ProcessResult result = Approval.process(req1);
            return true;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}