trigger APFCreation on APF__c (after Insert, after update)
{    
    ByPassTriggers__mdt[] byPasstrigMappings = [SELECT Id,Label, ByPassTrigger__c,Object_Name__c FROM ByPassTriggers__mdt];
    Boolean byPassTriggerExceution = false;
    for(ByPassTriggers__mdt bypass : byPasstrigMappings)
    {
        if(bypass.Object_Name__c == 'APF__c' && bypass.ByPassTrigger__c)
        {
            byPassTriggerExceution = true;
        }
    }
    
    if(!byPassTriggerExceution)
    {
    if (trigger.isAfter) {
        if (trigger.isInsert) {
            //APFController.SendEmailOnAPFGeneration(trigger.new);
        }
    }}
}