public class BillDeskSplitPaymentVFController {
    
    public String merchantId { get; set; }
    public String bdOrderId  { get; set; }
    public String rdata      { get; set; }
    public String paymentUrl { get; set; }
    
    public BillDeskSplitPaymentVFController() {
        String orderId = ApexPages.currentPage().getParameters().get('orderId');  
        
        if(String.isBlank(orderId)) return;
        Payment_Transaction__c payment = [
            SELECT Merchant_Id__c,
                   BillDesk_Order_Id__c,
                   RData__c,
                   Payment_Url__c
            FROM Payment_Transaction__c
            WHERE Order_Id__c = :orderId
            LIMIT 1
        ];
        
        merchantId = payment.Merchant_Id__c;
        bdOrderId  = payment.BillDesk_Order_Id__c;
        rdata      = payment.RData__c;
        paymentUrl = payment.Payment_Url__c;
    }
}