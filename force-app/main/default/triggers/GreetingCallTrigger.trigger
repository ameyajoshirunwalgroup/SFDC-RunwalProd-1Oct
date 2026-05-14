trigger GreetingCallTrigger on Greeting_Call__c (before insert) {
    if(Trigger.isBefore && Trigger.isInsert){
        GreetingcallTriggerHandler.ownerChanges(Trigger.New);
    }
}