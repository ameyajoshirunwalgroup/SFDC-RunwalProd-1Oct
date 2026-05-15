public class InterestWaiverTriggerHandler {
    /*public static void submitIWforApproval(Map<Id,list<Id>> bkVsIwMapforApproval){
        list<booking__c> blist = [Select Id from Booking__c where Id IN: bkVsIwMapforApproval.keyset()];
        try {
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
        if(!blist.isEmpty()){
            for(Id bid:bkVsIwMapforApproval.keyset()){
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setObjectId(bid);
                req.setComments('Submitting for Interest Waiver Consolidation Approval');
                req.setProcessDefinitionNameOrId('Interest_Waiver_Approval');
                req.setSkipEntryCriteria(true);
                requests.add(req);
            }   
        }
        if (!requests.isEmpty()) {
            List<Approval.ProcessResult> results = Approval.process(requests);
            System.debug('Approval Results -> ' + results);
        }
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }*/
}