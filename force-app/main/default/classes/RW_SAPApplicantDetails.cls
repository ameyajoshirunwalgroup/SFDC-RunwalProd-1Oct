public class RW_SAPApplicantDetails {
@invocablemethod
    public static void callSAPCustomerUpdate(List<Id> oIdSet){
        set<id> newids= new set<id>();
        for(id i : oIdSet){
            newids.add(i);
        }
      if(! test.isRunningTest())
        CustomerUpdateCallout.afterUpdateApplicant(newids);
    }
}