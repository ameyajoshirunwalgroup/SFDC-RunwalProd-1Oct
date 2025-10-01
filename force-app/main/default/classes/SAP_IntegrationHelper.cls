public class SAP_IntegrationHelper {
    
    public static void insertLogEntry(String sAPI, String status, String sRefObj, String sParentId, String sRequest, String sResponse, String sErrorReaosn, String sBatchId) {
        System.debug('sAPI>>>' +sAPI);
        System.debug('status>>>' +status);
        System.debug('sRefObj>>>' +sRefObj);
        System.debug('sRequest>>>' +sRequest);
        System.debug('sResponse>>>' +sResponse);
        
        ERP_Integration_Log__c log = new ERP_Integration_Log__c();
        log.API_Name__c = sAPI;
        log.StatusTxt__c = status;
        if(sAPI == 'ADF Calculation'){
            log.Booking__c = sRefObj;
        }
        else if(sAPI == 'ADF Credit Note'){
            log.Credit_Note__c = sRefObj;
            log.Booking__c = sParentId;
        }
        else if(sAPI == 'Interest Waiver'){
            log.Interest_Waiver__c = sRefObj;
            log.Demand__c = sParentId;
        }
        else if(sAPI == 'Demand Interest' && sBatchId != null){
            log.Demand__c = sRefObj;
            log.INT_Batch_Id__c = sBatchId;
            log.Demand__c = sRefObj;
        }
        if(sResponse.length() > 131000){
            log.Response__c = sResponse.substring(0, 131000);
        } else {
            log.Response__c = sResponse;
        }
        if(sRequest.length() > 131000){
            log.Request__c = sRequest.substring(0, 131000);
        } else {
            log.Request__c = sRequest;
        }
        log.Error_Reason__c = sErrorReaosn;
        insert log;  
    } 
}