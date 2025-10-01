public class IOMController {
    
    public IOM__c iom {
        get;
        private set;
    }
    
    public List<IOM_Item__c> iomItemList {get;set;}
    public Integer totalItems {get;set;}
    public Decimal totalAgrVal {get;set;}
    public Decimal totalOutstanding {get;set;}
    public Decimal totalAmtPaid {get;set;}
    public Decimal totalForfeitAmt {get;set;}
    public Decimal totalRefundAmt {get;set;}
    
    public IOMController(){
        
        string recordid = ApexPages.currentPage().getParameters().get('id');
        
        iom = [SELECT Id,Name,Comments__c, Nature_of_Request__c, Comments_2__c,Assistant_Manager__c, AVP_Sales__c, AGM_Verifier__c,
               C_O_O__c, C_E_O__c, MD__c FROM IOM__c WHERE Id =: recordid];
        
        iomItemList = [SELECT Id, Name, Unit__c, Unit__r.RW_Param4__c, RM_Name__c, Saleable_Area__c, Carpet_Area__c, Customer_Name__c, 
                       Booking_Date__c, Aging__c, SAP_Id__c, Agreement_Value__c, Amount_Paid__c, Outstanding_Amount__c, Registration_Status__c, 
                       Refunded_Forfeited1__c, Actual_Sold_Rate_Base__c, Current_Rate__c, Rate_Difference__c, Remarks__c, SDR_Paid_by_Runwal__c,
                       Brokerage_Amount1__c, GST_Amount__c, GST_Loss__c, Forfeiture_Amount__c,Refund_Amount1__c,Interest__c,Deduction_from_AGV__c,
                       Refund_Amount__c, New_Customer__c, New_Rate__c, New_Agreement_Value__c, Amount_Paid_New__c, New_Customer_CIF_No__c,
                       X1st_Attempt_Reason_For_Cancellation__c, X2nd_Attempt_Reason_For_Cancellation__c, Cancelled_Customer_CIF_No__c, 
                       Closing_SM__c, Booking_Source__c, Resale_Status__c, Profit_Loss__c, Booking_Source_New__c
                       FROM IOM_Item__c WHERE IOM__c =: iom.Id];
        totalItems = iomItemList.size();
        totalAgrVal = 0;
        totalAmtPaid = 0;
        totalOutstanding = 0;
        totalForfeitAmt = 0;
        totalRefundAmt = 0;
        for(IOM_Item__c item : iomItemList){
            totalAgrVal += item.Agreement_Value__c;
            totalAmtPaid += item.Amount_Paid__c;
            totalOutstanding += item.Outstanding_Amount__c;
            if(item.Forfeiture_Amount__c != null){
                totalForfeitAmt += item.Forfeiture_Amount__c;
            }
            if(item.Refund_Amount1__c != null){
                totalRefundAmt += item.Refund_Amount1__c;
            }
            
        }
        
    }

}