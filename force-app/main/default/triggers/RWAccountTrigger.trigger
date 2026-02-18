trigger RWAccountTrigger on Account (after insert, after update, before insert, before update) 
{
    RWAccountTriggerHandler objClass = new RWAccountTriggerHandler();
    objClass.runTrigger();
}