trigger TaskDescriptionAppendTrigger on Task (before insert, before update) {
    
    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            TaskTriggerHandler.handleRemarksAppend(Trigger.new, Trigger.oldMap, Trigger.isUpdate);
        }
    }
}