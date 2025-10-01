trigger ScheduleCallsTrigger on Scheduled_Call__c (after insert, after update) {

    if(Trigger.isInsert && Trigger.isAfter){
        //Call Ozonetel Schedle API
        Set<Id> scIds = new Set<Id>();
        for(Scheduled_Call__c sc : Trigger.New){
            if(sc.Agent_Id__c != null && sc.Agent_Id__c != ''){
                scIds.add(sc.Id);
            }
        }
        if(scIds.size() > 0){
            OzonetelCallScheduler.scheduleCall(scIds);
            System.debug('--scheduleCall--');
        }
    }
    
    if(Trigger.isUpdate && Trigger.isAfter){
        Set<Id> scIdsToDeleteInOzonetel = new Set<Id>();
        Set<Id> scIdsToScheduleInOzonetel = new Set<Id>();
        for(Scheduled_Call__c sc : Trigger.New){
            if(sc.Schedule_Date__c == null && sc.Schedule_Date__c != Trigger.oldMap.get(sc.Id).Schedule_Date__c){
                scIdsToDeleteInOzonetel.add(sc.Id);
            }else if(sc.Schedule_Date__c != null && sc.Schedule_Date__c != Trigger.oldMap.get(sc.Id).Schedule_Date__c){
                scIdsToDeleteInOzonetel.add(sc.Id);
                scIdsToScheduleInOzonetel.add(sc.Id);
            }
            
        }
        if(scIdsToDeleteInOzonetel.size() > 0)
            OzonetelCallScheduler.deleteScheduledCall(scIdsToDeleteInOzonetel);
            System.debug('--deleteScheduledCall--');
        if(scIdsToScheduleInOzonetel.size() > 0)
            OzonetelCallScheduler.scheduleCall(scIdsToScheduleInOzonetel);
            System.debug('--scheduleCall--');
    }
}