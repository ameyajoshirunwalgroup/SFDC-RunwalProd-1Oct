public class RW_UnitTransferPaymentUpdate {
 @InvocableMethod(label='UpdatingPaymentDetails' description='Updating the payment details of transferred Unit')
    public static void updatePaymentDetails(List<ID> ids){
        system.debug(ids);
        set<Id> setPaymentId = new set<Id>();
        Opportunity NewOpp = [Select Id, Booking__c ,RW_Previous_Opportunity__c from Opportunity Where Id =: ids and RW_Previous_Opportunity__c != null LIMIT 1];
        Opportunity PrevOpp = [Select Id, Booking__c from Opportunity Where Id =: NewOpp.RW_Previous_Opportunity__c LIMIT 1];
        if(PrevOpp != null){
        List<RW_Payment_Details__c> payment = [Select Id , RW_Booking__c  from RW_Payment_Details__c Where RW_Booking__c =: PrevOpp.Booking__c];        
        if(payment.size() > 0){
                for(RW_Payment_Details__c pay:payment){
                	   pay.RW_Booking__c = NewOpp.Booking__c;
                       setPaymentId.add(pay.Id);
                }
                update payment;
            
         } 
            
         List<RW_Demand__c> demand = [Select Id, Booking__c from RW_Demand__c Where Booking__c =: PrevOpp.Booking__c] ;   
         if(demand.size() > 0){
             for(RW_Demand__c dem : demand){
                 dem.Booking__c = NewOpp.Booking__c;
             }
             update demand;
             
            } 
            if(setPaymentId.size()>0){
            PaymentItemHandler.reCalculateReceipt(setPaymentId);
            SAPReceiptAPICallOut.paymentDetailRollUps(new set<id>{NewOpp.Booking__c});    
            }
            
     /*   List<Receipt__c> receipt = [Select Id , Booking__c from Receipt__c Where Booking__c =: PrevOpp.Booking__c];
            if(receipt.size()>0){
                for(Receipt__c rec : receipt){
                    rec.Booking__c = NewOpp.Booking__c;
                }
                update receipt;
            }*/
        }
    }
}