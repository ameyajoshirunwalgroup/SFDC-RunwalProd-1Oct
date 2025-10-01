trigger PaymentDetailRollUp on RW_Payment_Details__c (after delete, after insert, after update) 
{
    
    ByPassTriggers__mdt[] byPasstrigMappings = [SELECT Id,Label, ByPassTrigger__c,Object_Name__c FROM ByPassTriggers__mdt];
    Boolean byPassTriggerExceution = false;
    for(ByPassTriggers__mdt bypass : byPasstrigMappings)
    {
        if(bypass.Object_Name__c == 'RW_Payment_Details__c' && bypass.ByPassTrigger__c)
        {
            byPassTriggerExceution = true;
        }
    }
    if(!byPassTriggerExceution)
    {
   Set<id> PaymentdetailIds = new Set<id>();
    

      if(trigger.isinsert || trigger.isundelete){
    for (RW_Payment_Details__c paymentDetail : Trigger.new)
      {
           if(paymentDetail.RW_Booking__c != null)
           {
                PaymentdetailIds.add(paymentDetail.RW_Booking__c);
           }
    
      }
      }    
    if (Trigger.isUpdate || Trigger.isDelete) {
        for (RW_Payment_Details__c paymentdetail : Trigger.old)
        {
            PaymentdetailIds.add(paymentdetail.RW_Booking__c);
         if(Trigger.isUpdate)
         {
             if(paymentDetail.RW_Booking__c != null){
                if(trigger.oldmap.get(paymentDetail.id).RW_Booking__c != paymentDetail.RW_Booking__c){
                    PaymentdetailIds.add(paymentDetail.RW_Booking__c);     
                }
            } 
             system.debug(paymentDetail.id);
            PaymentdetailIds.add(trigger.oldmap.get(paymentDetail.id).RW_Booking__c);
         }
        }
    }
                 system.debug(PaymentdetailIds);

      if(PaymentdetailIds.size() > 0){
      SAPReceiptAPICallOut.paymentDetailRollUps(PaymentdetailIds);
      }
    }
}