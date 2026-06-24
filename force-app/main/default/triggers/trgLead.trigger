Trigger trgLead on Lead (before insert, after insert, before update, after update) {
    //Added by Prashant to bypass trigger in prod. /////// 19-05-25.
    ByPassTriggers__mdt[] byPasstrigMappings = [SELECT Id,Label, ByPassTrigger__c,Object_Name__c FROM ByPassTriggers__mdt];
    Boolean byPassTriggerExceution = false;
    for(ByPassTriggers__mdt bypass : byPasstrigMappings)
    {
        if(bypass.Object_Name__c == 'Lead' && bypass.ByPassTrigger__c)
        {
            byPassTriggerExceution = true;
        }
    }
    if(!byPassTriggerExceution)
    {
        
        leadTriggerHandler objTrigger = new leadTriggerHandler();
        
        if(Trigger.isInsert && Trigger.isBefore)
        {
            objTrigger.BeforeInsert(trigger.new);
        }
        
        if(Trigger.isInsert && Trigger.isAfter)
        {
            objTrigger.AfterInsert(trigger.new);
        }
        
        if(Trigger.isUpdate && Trigger.isBefore)
        {
            objTrigger.BeforeUpdate(trigger.new, trigger.oldmap);
        }
        
        if(Trigger.isUpdate && Trigger.isAfter)
        {
            objTrigger.AfterUpdate(trigger.new, trigger.oldmap);
        }
    }
}