public class SalesOrderErrorLogger {
    Public String CustomerNumber;
    public        SalesOrderSAPAPIMCS.ZsdstOrderHeader orderHeader ; 
    public            SalesOrderSAPAPIMCS.TableOfZsdstOrderItem orderItemsList;
    public             SalesOrderSAPAPIMCS.TableOfZsdstCondition orderConditionsList ;
    public             SalesOrderSAPAPIMCS.TableOfZsdstPartnerFunction partnerFunctionList ;
    public        SalesOrderSAPAPIMCS.TableOfZsdstBillPlan billPlanList ;
    
    public SalesOrderErrorLogger(){
        orderHeader = new SalesOrderSAPAPIMCS.ZsdstOrderHeader();
        orderItemsList = new SalesOrderSAPAPIMCS.TableOfZsdstOrderItem();
        orderConditionsList = new SalesOrderSAPAPIMCS.TableOfZsdstCondition();
        partnerFunctionList = new SalesOrderSAPAPIMCS.TableOfZsdstPartnerFunction();
        billPlanList = new SalesOrderSAPAPIMCS.TableOfZsdstBillPlan();
    }
}