public class POSTApprovedCN {
    
    @InvocableMethod()
    public static void getApprovedCN(List<Id> lstCNIds) {
        system.debug('lstCNIds>>>>>' +lstCNIds);
        if (lstCNIds == null || lstCNIds.isEmpty()) {
            return; 
        }
        Id JobId = System.enqueueJob(new SAPCreditNotADFAPICallout(lstCNIds));
        system.debug('lstCNIds??????' +lstCNIds);
    }
}