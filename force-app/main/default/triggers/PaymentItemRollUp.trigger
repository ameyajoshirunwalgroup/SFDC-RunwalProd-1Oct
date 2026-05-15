trigger PaymentItemRollUp on RW_Payment_Detail_Item__c (after delete, after insert, after update) 
{ 
    ByPassTriggers__mdt[] byPasstrigMappings = [SELECT Id,Label, ByPassTrigger__c,Object_Name__c FROM ByPassTriggers__mdt];
    Boolean byPassTriggerExceution = false;
    for(ByPassTriggers__mdt bypass : byPasstrigMappings)
    {
        if(bypass.Object_Name__c == 'RW_Payment_Detail_Item__c' && bypass.ByPassTrigger__c)
        {
            byPassTriggerExceution = true;
        }
    }
    
    
    if(!byPassTriggerExceution)
    {
        
        Set<id> PaymentItemIds = new Set<id>();
        
        
        if(trigger.isinsert || trigger.isundelete){
            for (RW_Payment_Detail_Item__c paymentItem : Trigger.new)
            {
                if(paymentItem.RW_Demand_Item__c != null)
                {
                    PaymentItemIds.add(paymentItem.RW_Demand_Item__c);
                    system.debug('Is Insert or Undeleted PaymentItemIds>>>>>' +PaymentItemIds);
                }
                
            }
        }    
        if (Trigger.isUpdate || Trigger.isDelete) {
            for (RW_Payment_Detail_Item__c paymentItem : Trigger.old)
            {
                PaymentItemIds.add(paymentItem.RW_Demand_Item__c);
                system.debug('Is Delete PaymentItemIds>>>>>' +PaymentItemIds);

                if(Trigger.isUpdate)
                {
                    if(paymentItem.RW_Demand_Item__c != null){
                        if(trigger.oldmap.get(paymentItem.id).RW_Demand_Item__c != paymentItem.RW_Demand_Item__c){
                            PaymentItemIds.add(paymentItem.RW_Demand_Item__c);   
                              system.debug('Is Update PaymentItemIds>>>>>' +PaymentItemIds);
                        }
                    } 
                    PaymentItemIds.add(trigger.oldmap.get(paymentItem.id).RW_Demand_Item__c);
                    system.debug('Is old map PaymentItemIds>>>>>' +PaymentItemIds);
                }
            }
        }
        
        if(PaymentItemIds.size() > 0){
            PaymentItemHandler.paymentRollUps(PaymentItemIds);
        }
        
    }
}