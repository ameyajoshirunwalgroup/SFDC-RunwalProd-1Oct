trigger InterestWaiverTrigger on Interest_Waiver__c (after Insert, after update,before update) {
    
    ByPassTriggers__mdt[] byPasstrigMappings = [SELECT Id,Label, ByPassTrigger__c,Object_Name__c FROM ByPassTriggers__mdt];
    Boolean byPassTriggerExceution = false;
    for(ByPassTriggers__mdt bypass : byPasstrigMappings)
    {
        if(bypass.Object_Name__c == 'Interest_Waiver__c' && bypass.ByPassTrigger__c)
        {
            byPassTriggerExceution = true;
        }
    }
    
    if(!byPassTriggerExceution)
    {
        if(trigger.isAfter && trigger.isUpdate){
            List<Id> approvedIWIds = new list<Id>();
            list<id> iwSendforApproval = new list<Id>();
            Map<Id,list<Id>> bkVsIwMapforApproval = new Map<Id,list<Id>>();          
            for(Interest_Waiver__c iw: trigger.newMap.values()){
                if(trigger.oldMap.get(iw.Id).Approval_Status__c != trigger.newMap.get(iw.Id).Approval_Status__c && iw.Approval_Status__c == 'Approved'){
                    approvedIWIds.add(iw.Id);
                }
                if(trigger.oldMap.get(iw.Id).Approval_Status__c != trigger.newMap.get(iw.Id).Approval_Status__c && iw.Approval_Status__c == 'Submitted for Approval'){
                    if (!bkVsIwMapforApproval.containsKey(iw.Booking__c)) {
                        bkVsIwMapforApproval.put(iw.Booking__c, new List<Id>());
                    }else{
                        bkVsIwMapforApproval.get(iw.Booking__c).add(iw.Id);
                    }
                    
                }
            }
            if(!approvedIWIds.isEmpty()){
                Id JobId = System.enqueueJob(new SAPInterestWaiverAPICallOutNew(approvedIWIds));
            }
            
            if(!bkVsIwMapforApproval.isEmpty()){
                //InterestWaiverTriggerHandler.submitIWforApproval(bkVsIwMapforApproval);
            }
        }
    }
}