trigger EOITrigger on RW_EOI__c (before insert,after update) 
{
   ByPassTriggers__mdt[] byPasstrigMappings = [SELECT Id,Label, ByPassTrigger__c,Object_Name__c FROM ByPassTriggers__mdt];
   Boolean byPassTriggerExceution = false;
   for(ByPassTriggers__mdt bypass : byPasstrigMappings)
   {
       if(bypass.Object_Name__c == 'RW_EOI__c' && bypass.ByPassTrigger__c)
       {
          byPassTriggerExceution = true;
       }
   }
   
system.debug('MK'+byPassTriggerExceution);
    if(!byPassTriggerExceution)
    {
   if(Trigger.isUpdate && Trigger.isafter)
    {
       List<RW_EOI__c> eoiRecords = new List<RW_EOI__c>();
        Set<String> opportunityIds = new Set<String>();
         Set<String> cancellationOppIds = new Set<String>();
        Set<String> opportunityIdsForStageUpdate = new Set<String>();
        Set<Id> eoiIds = new Set<Id>();
         Map<Id,RW_EOI__c> cancellationEoiMap = new Map<Id,RW_EOI__c>();
         Map<Id,RW_EOI__c> cancellationInitiateEoiMap = new Map<Id,RW_EOI__c>();
        Map<Id,RW_EOI__c> cancellationCompleteEoiMap = new Map<Id,RW_EOI__c>();
        Map<Id,RW_EOI__c> BlockedEoiMap = new Map<Id,RW_EOI__c>();
        for(RW_EOI__c eoi : Trigger.New)
        {
            if(eoi.RW_Status__c == 'EOI Confirmed' || eoi.RW_Status__c == 'EOI Blocked')
            {
                System.debug('**inside trigger If');
                opportunityIds.add(eoi.Opportunity__c);
                eoiIds.add(eoi.Id);
            }
            
            if(eoi.RW_Status__c == 'EOI Confirmed' && eoi.RW_Status__c != Trigger.OldMap.get(eoi.Id).RW_Status__c)
            {
                opportunityIdsForStageUpdate.add(eoi.Opportunity__c);
            }
            
            if(eoi.RW_Status__c == 'EOI Cancelled - Refund pending' && eoi.RW_Status__c != Trigger.OldMap.get(eoi.Id).RW_Status__c)
            {
                cancellationEoiMap.put(eoi.id,eoi);
                cancellationOppIds.add(eoi.Opportunity__c);
            }
            
            if(eoi.RW_Status__c == 'Cancellation Initiated' && eoi.RW_Status__c != Trigger.OldMap.get(eoi.Id).RW_Status__c)
            {
                cancellationInitiateEoiMap.put(eoi.id,eoi);
            }
            
            if(eoi.RW_Status__c == 'EOI Cancelled -Refunded' && eoi.RW_Status__c != Trigger.OldMap.get(eoi.Id).RW_Status__c)
            {
                cancellationCompleteEoiMap.put(eoi.id,eoi);
            }
            
            if(eoi.RW_Status__c == 'EOI Blocked' && eoi.RW_Status__c != Trigger.OldMap.get(eoi.Id).RW_Status__c)
            {
                BlockedEoiMap.put(eoi.id,eoi);
            }
        }
        set<Id> lstOppBookedIds = new set<Id>();
        List<Opportunity> oppRecords = [Select Id from Opportunity where id IN : opportunityIds];
        for(Opportunity opp : oppRecords)
            {
                lstOppBookedIds.add(opp.Id);
            }
        
         if(lstOppBookedIds.size() > 0)
        {   
            System.debug('**inside EOITriggerHandler call');
            EOITriggerHandler.afterUpdateEOI(lstOppBookedIds,eoiIds);
        }
        
         if(cancellationEoiMap.size() > 0)
        {  
            EOITriggerHandler.afterUpdateCancellation(cancellationEoiMap);
        }
        
        if(cancellationInitiateEoiMap.size() > 0)
        {  
            EOITriggerHandler.afterCancellationInitiation(cancellationInitiateEoiMap);
        }
        
        if(BlockedEoiMap.size() > 0)
        {  
            EOITriggerHandler.afterEOIBlock(BlockedEoiMap);
        }
        
        if(cancellationCompleteEoiMap.size() >0)
        {
        EOITriggerHandler.afterCancellationComplete(cancellationCompleteEoiMap);
            
        }
        
        if(opportunityIdsForStageUpdate.size() >0)
        {
            List<Opportunity> oppRecUpdate = new List<Opportunity>();
            List<Opportunity> oList  = [Select Id, StageName from Opportunity where Id IN: opportunityIdsForStageUpdate];           
            for(Opportunity opp : oList)
            {
                if(opp.StageName != 'Unit Booked')
                {
                   opp.StageName = 'EOI Received'; 
                   oppRecUpdate.add(opp);
                }
            }
            
            Update oppRecUpdate;
        }
        
        
        if(cancellationOppIds.size() >0)
        {
            List<Opportunity> cancellationoppRecUpdate = new List<Opportunity>();
            List<Opportunity> cancellationoList  = [Select Id, StageName from Opportunity where Id IN: cancellationOppIds];           
            for(Opportunity opp : cancellationoList)
            {
               
                   opp.StageName = 'Lost'; 
                   opp.RW_Reason_for_Closed_Lost__c = 'EOI Cancelled';
                   cancellationoppRecUpdate.add(opp);
                
            }
            
            Update cancellationoppRecUpdate;
        }
    }
    }
}