trigger RWTaskTrigger on Task (before insert, after insert,before update, after update, before delete) 
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
        RWTaskTriggerHandler obj = new RWTaskTriggerHandler();
        obj.runTrigger();
    }
}