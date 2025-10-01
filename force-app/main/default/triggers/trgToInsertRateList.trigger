trigger trgToInsertRateList on Rate_List__c (after insert , after update) {
    
        ByPassTriggers__mdt[] byPasstrigMappings = [SELECT Id,Label, ByPassTrigger__c,Object_Name__c FROM ByPassTriggers__mdt];
    Boolean byPassTriggerExceution = false;
    for(ByPassTriggers__mdt bypass : byPasstrigMappings)
    {
        if(bypass.Object_Name__c == 'Rate_List__c' && bypass.ByPassTrigger__c)
        {
            byPassTriggerExceution = true;
        }
    }
      if(!byPassTriggerExceution)
    {
    if(Trigger.IsAfter && (Trigger.IsInsert || Trigger.IsUpdate))
    {system.debug('MK');
        List<Id> ratelistIds = new List<Id>();
        for(Rate_List__c rateid : Trigger.New)
        {            
            ratelistIds.add(rateid.id);
        }
      if(checkRecursion.isFirstRunA()) 
        {system.debug('MK');
        PricelistCallout.sendPricelist(ratelistIds);
        }
    }

    }
}