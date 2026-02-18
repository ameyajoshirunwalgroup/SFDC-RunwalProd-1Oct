trigger trgOnCountOfVisit on Event (after insert, before insert , before update, before delete,after update) 
{
	if(trigger.isInsert && trigger.isAfter)
	{
		sendEmailOnEsclatationHandler objClass = new sendEmailOnEsclatationHandler();
        objClass.countNumberOfVisitsOnOpportunity(trigger.new, trigger.oldMap);
	}
    
    if(trigger.isInsert && trigger.isBefore)
    {
        sendEmailOnEsclatationHandler objEventLastSiteVisitInsert = new sendEmailOnEsclatationHandler();
        objEventLastSiteVisitInsert.updateLastSiteVisit(trigger.new, trigger.oldMap);
    }
    if(trigger.isUpdate && trigger.isBefore)
    {
        sendEmailOnEsclatationHandler objEventLastSiteVisitUpdate = new sendEmailOnEsclatationHandler();
        objEventLastSiteVisitUpdate.updateLastSiteVisit(trigger.new, trigger.oldMap);
    }

	if(trigger.isDelete && trigger.isBefore)
    {
        sendEmailOnEsclatationHandler objEventLastSiteVisitUpdate = new sendEmailOnEsclatationHandler();
        objEventLastSiteVisitUpdate.validateDelte(trigger.new, trigger.oldMap);
    }
    if (Trigger.isbefore && Trigger.isInsert) {
        EventTriggerHandler.handleBeforeInsert(Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isUpdate) {
        EventTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
    }
    
}