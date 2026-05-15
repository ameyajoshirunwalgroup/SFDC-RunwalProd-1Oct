public class BillDeskPayButtomTestCompController {
    
    
    public class BillDeskResponseWrapper {
        @AuraEnabled public String status;
        @AuraEnabled public String transactionId;
        @AuraEnabled public String message;
        @AuraEnabled public Decimal amount;
    }

    @AuraEnabled
    public static String processPayment(String paymentType, Decimal amount) {
        
        Lockated_paymentApi.LockatedRequest reqData = new Lockated_paymentApi.LockatedRequest();
        reqData.bookingId = 'a0s9I000000qFvpQAE';
        reqData.totalAmount = 10000;
        reqData.paymentType = 'PRINCIPAL_GST';
        
        String billDeskResponse = BillDeskService.createOrderRaw(reqData);
        System.debug('billDeskResponse: ' + billDeskResponse);
        
        return billDeskResponse;
    }
    

}