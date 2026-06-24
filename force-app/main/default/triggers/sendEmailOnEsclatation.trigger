trigger sendEmailOnEsclatation on Task (after insert, after update) 
{
    //Added by Prashant to bypass trigger in prod. /////// 19-05-25.
    ByPassTriggers__mdt[] byPasstrigMappings = [SELECT Id,Label, ByPassTrigger__c,Object_Name__c FROM ByPassTriggers__mdt];
    Boolean byPassTriggerExceution = false;
    for(ByPassTriggers__mdt bypass : byPasstrigMappings)
    {
        if(bypass.Object_Name__c == 'Task' && bypass.ByPassTrigger__c)
        {
            byPassTriggerExceution = true;
        }
    }
    
    if(!byPassTriggerExceution)
    {
    sendEmailOnEsclatationHandler objHandler = new sendEmailOnEsclatationHandler();
    
    if(Trigger.isUpdate && Trigger.isAfter)
        objHandler.sendEsclation(Trigger.new, trigger.OldMap);
    else 
        objHandler.afterInsert(Trigger.new);
    }
}