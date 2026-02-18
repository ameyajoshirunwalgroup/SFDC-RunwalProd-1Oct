trigger trgQuote on Quotation__c (before insert,after Insert, after update,before update) {
    ByPassTriggers__mdt[] byPasstrigMappings = [SELECT Id,Label, ByPassTrigger__c,Object_Name__c FROM ByPassTriggers__mdt];
    Boolean byPassTriggerExceution = false;
    for(ByPassTriggers__mdt bypass : byPasstrigMappings)
    {
        if(bypass.Object_Name__c == 'Quotation__c' && bypass.ByPassTrigger__c)
        {
            byPassTriggerExceution = true;
        }
    }
    
    if(!byPassTriggerExceution)
    {
        Set<Id> qids = new Set<Id>();
        if(trigger.isAfter){
            System.debug('trigger.isAfter____');
            System.debug('trigger.isInsert & trigger.isUpdate____');
            /*
            for (Quotation__c q : Trigger.new) {
                if((trigger.isUpdate && (
                    q.Agreement_Value_D__c != trigger.oldMap.get(q.id).Agreement_Value_D__c || 
                    q.Agreement_Value_Not_for_brokers__c != trigger.oldMap.get(q.id).Agreement_Value_Not_for_brokers__c ||
                    q.Agreement_Value_for_brokers__c != trigger.oldMap.get(q.id).Agreement_Value_for_brokers__c ||
                    q.Discount_Applied__c != trigger.oldMap.get(q.id).Discount_Applied__c ||
                   	q.Stamp_duty_payable_by_Runwal__c != trigger.oldMap.get(q.id).Stamp_duty_payable_by_Runwal__c)) || 
                   (trigger.isInsert && (q.Agreement_Value_D__c != null || q.Agreement_Value_Not_for_brokers__c != null || q.Agreement_Value_for_brokers__c != null || q.Discount_Applied__c != null || q.Stamp_duty_payable_by_Runwal__c != null))
                  ) 
                {
                    if(q.Discount_Applied__c == true){
                        q.Broker_Agreement_Value_New__c = q.Agreement_Value_D__c - q.Agreement_Value_Not_for_brokers__c;
                    }else if(q.Discount_Applied__c == false){
                        q.Broker_Agreement_Value_New__c = q.Agreement_Value_for_brokers__c;
                    }
                    qids.add(q.Id);
                }
            }
*/
            if(!qids.isEmpty()){
                //QuoteTriggerHandler.UpdateBookingAgreementValue(qids);
            }
        }
        
    }
}