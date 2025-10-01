trigger DemandTrigger on RW_Demand__c (After insert) {
    
    ByPassTriggers__mdt[] byPasstrigMappings = [SELECT Id,Label, ByPassTrigger__c,Object_Name__c FROM ByPassTriggers__mdt];
    Boolean byPassTriggerExceution = false;
    for(ByPassTriggers__mdt bypass : byPasstrigMappings){
        if(bypass.Object_Name__c == 'RW_Demand__c' && bypass.ByPassTrigger__c){
            byPassTriggerExceution = true;
        }
    }    
    if(!byPassTriggerExceution){
        if(Trigger.isAfter && Trigger.isInsert){
            TriggerHandlerDemand.createTask(Trigger.new);
        }
    }
}