trigger sendEmailOnEsclatation on Task (after insert, after update) 
{
    sendEmailOnEsclatationHandler objHandler = new sendEmailOnEsclatationHandler();
    
    if(Trigger.isUpdate && Trigger.isAfter)
        objHandler.sendEsclation(Trigger.new, trigger.OldMap);
    else 
        objHandler.afterInsert(Trigger.new);
}