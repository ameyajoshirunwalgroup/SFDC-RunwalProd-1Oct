trigger PaymentDetailsTrigger on RW_Payment_Details__c (after insert,after Update) 
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
       
        
        if(trigger.isUpdate)
        {
            // for() -- Loop through payment id 
            // RW_Status_Code__c
            // if(trigger.oldmap.get(loopvariable).id.RW_Status_Code__c != LoopVariable.RW_Status_Code__c 
            // add to a set of ids - recipet - payement detail.
            // set is > 0 call handler method - reCalculateReceipt 
            set<id> payId = new set<Id>();
            List<String> receiptIds = new List<String>(); // Added by coServe 25-09-2024
            for(RW_Payment_Details__c payd : trigger.new)
            {
                if(trigger.oldMap.get(payd.Id).RW_Status_Code__c != payd.RW_Status_Code__c)
                {
                    payId.add(payd.Id);
                }  
                if(payd.Send_Receipt_Letter__c == true && trigger.oldMap.get(payd.Id).Send_Receipt_Letter__c != payd.Send_Receipt_Letter__c){ // Added by coServe 25-09-2024
                    receiptIds.add(payd.Id);
                }
            } 
            
            if(payId.size()>0)
            {
                PaymentItemHandler.reCalculateReceipt(payId);
            }

            if(receiptIds.size() > 0){ // Added by coServe 25-09-2024
                Id JobId = System.enqueueJob(new SendReceiptDetailsForCRMBot(receiptIds));
            }
            
        }
    }
    
    
}