trigger TriggerAssignTaskToUser on Task (before update, after insert) {
    
    //Group queueObject = [Select Id,Name,DeveloperName,Type From Group Where Type = 'Queue' and Name = 'TaskQueue'];
    /*User usr = [SELECT Id, FirstName FROM User Where FirstName = 'Minal'];
String userID = usr.Id;
for(Task t : trigger.new){
if(t.Task_Type__c == 'Presales Call' || t.RecordTypeId == 'Presales Task'){
t.OwnerId = userID;
}
}*/	
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
        if(Trigger.isAfter && Trigger.isInsert){
            List<Task> lstTask = new List<Task>();
            for(Task t : Trigger.new){
                if(t.Task_Type__c == 'Enquiry Received'){
                    lstTask.add(t);
                }
            }
            //TaskAssignmentToPresales.assign(lstTask);
            if(lstTask.size() > 0){
                TaskAssignmentToPresales.assign(lstTask);
            }
        }
    }
}