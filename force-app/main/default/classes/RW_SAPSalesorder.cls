public class RW_SAPSalesorder {
@invocablemethod
    public static void callSAPServicesforSalesorder(List<Id> oIdSet){
        set<id> newids= new set<id>();
        for(id i : oIdSet){
            newids.add(i);
        }
      if(! test.isRunningTest())
        SAPIntegrationServices.createSO(newids);
    }
}