global class SAPCancellationBatch {//implements Database.Batchable <cancellationWrapper>, Database.AllowsCallouts {
  //Manoj 17-01-2020 commenting this as we have realtime apis
 /*   global final DateTime currentFireTime;
    
    global SAPCancellationBatch (DateTime current){
        currentFireTime  = current;
    }
    
    global List<cancellationWrapper> start(Database.BatchableContext BC) {
        List<cancellationWrapper> cancList = new List<cancellationWrapper>();
        List<SAPIntegrationServices.CanReqWrapper> canWrapList = SAPIntegrationServices.pollForCancellationRequests(currentFireTime);
        if(!canWrapList.isEmpty()) {
            for(SAPIntegrationServices.CanReqWrapper sp : canWrapList) {
                cancellationWrapper cw = new cancellationWrapper();
                cw.Mandt = sp.Mandt;
                cw.SalesOrder = sp.SalesOrder;
                cw.Timestamp = sp.Timestamp;
                cw.CancelReason = sp.CancelReason;
                cw.CancelDate = sp.CancelDate;
                cw.UnitStatus = sp.UnitStatus;
                cw.Type_x = sp.Type_x;
                cancList.add(cw);
            }
        }
        return cancList;//
    }
    global void execute(Database.BatchableContext BC, List<cancellationWrapper> scope) {
        List<SAPIntegrationServices.CanReqWrapper> canListToPass = new List<SAPIntegrationServices.CanReqWrapper>();
        if(!scope.isEmpty()) {
            for(cancellationWrapper sp : scope) {
                SAPIntegrationServices.CanReqWrapper cw = new SAPIntegrationServices.CanReqWrapper();
                cw.Mandt = sp.Mandt;
                cw.SalesOrder = sp.SalesOrder;
                cw.Timestamp = sp.Timestamp;
                cw.CancelReason = sp.CancelReason;
                cw.CancelDate = sp.CancelDate;
                cw.UnitStatus = sp.UnitStatus;
                cw.Type_x = sp.Type_x;
                canListToPass.add(cw);
            }
        }
        if(!canListToPass.isEmpty() && canListToPass.size() > 0) {
            SAPIntegrationServices.processCancellation(canListToPass);
        }
    }
    global void finish(Database.BatchableContext BC) {}  
    
    global class cancellationWrapper {
         public String Mandt;
        public String SalesOrder;
        public String Timestamp;
        public String CancelReason;
        public String CancelDate;
        public String UnitStatus;
        public String Type_x;
    }*/
}