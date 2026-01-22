public class EventTriggerHandler {
    
    public static void handleBeforeInsert(List<Event> newList) {
        Set<Id> accountIds = new Set<Id>();
        RecordType rt = [SELECT Id FROM RecordType WHERE SobjectType='Event' AND DeveloperName = 'Channel_Partner_Corporates_Event' LIMIT 1];

        for (Event ev : newList) {
            System.debug('Check RecordType Name--->'+ev.RecordTypeId);
            System.debug('Check AccountId--->'+ev.WhatId);
            if (ev.RecordTypeId == rt.Id &&
                ev.WhatId != null) {
                    if(ev.StartDateTime.date()!=ev.EndDateTime.date()){
                        ev.addError('Start Date And End Date For An Event Must Be Same!!');
                    }
                accountIds.add(ev.WhatId);
            }
        }

        if (accountIds.isEmpty()) return;

        // Query Accounts with their Channel Partner
        Map<Id, Account> accMap = new Map<Id, Account>(
            [SELECT Id, Channel_Partner__c FROM Account WHERE Id IN :accountIds]
        );

        for (Event ev : newList) {
            if (ev.WhatId != null &&
                accMap.containsKey(ev.WhatId) &&
                ev.RecordTypeId == rt.Id) {
                ev.Channel_Partner__c = accMap.get(ev.WhatId).Channel_Partner__c;
                
            }
        }
    }

    public static void handleAfterUpdate(List<Event> newList, Map<Id, Event> oldMap) {
        List<Event> closedEvents = new List<Event>();
        List<Event> eventToUpdate = new List<Event>();
        Set<Id> channelPartnerId = new Set<Id>();
        List<CP_Meeting_Targets__c> targetToCreate = new List<CP_Meeting_Targets__c>();
        
        Map<String, Id> recordTypeIds = new Map<String, Id>();
        for (RecordType rt : [
            SELECT DeveloperName, Id 
            FROM RecordType 
            WHERE SobjectType IN ('Event', 'CP_Meeting_Targets__c')
            AND DeveloperName IN ('Channel_Partner_Corporates_Event', 'AOP_Targets', 'Non_AOP_Targets')
        ]) {
            recordTypeIds.put(rt.DeveloperName, rt.Id);
        }
        
        Id rt = recordTypeIds.get('Channel_Partner_Corporates_Event');
        Id rtForTargetAOP = recordTypeIds.get('AOP_Targets');
        Id rtForTargetNonAOP = recordTypeIds.get('Non_AOP_Targets');
        
        // Step 1: Filter qualifying Events
        for (Event ev : newList) {
            Event oldEv = oldMap.get(ev.Id);
            if (
                ev.RecordTypeId == rt &&
                ev.Event_Status__c == 'Completed' &&
                oldEv.Event_Status__c != 'Completed' &&
                ev.WhatId != null
            ) {
                closedEvents.add(ev);
            }
        }

        if (closedEvents.isEmpty()) return;

        // Step 2: Collect Account Ids
        for (Event ev : closedEvents) {
            channelPartnerId.add(ev.Channel_Partner__c);
        }

        if (channelPartnerId.isEmpty()) return;
        
        Set<Id> channelPartnerAOP = new Set<Id>();
        List<AOP__c> aopList = [Select id,Channel_Partner__c,Start_Date__c,End_Date__c from AOP__c where Channel_Partner__c IN: channelPartnerId and Start_Date__c!=null and End_Date__c!=null];
        for(AOP__c aopObj: aopList){
            for(Event eventObj: closedEvents){
                if(aopObj.Start_Date__c <= eventObj.StartDateTime.date() && aopObj.End_Date__c >= eventObj.StartDateTime.date()){
                    channelPartnerAOP.add(aopObj.Channel_Partner__c);
                }
            }
        }

        

        // Step 4: Prepare data for query
        Set<String> smNames = new Set<String>();
        Set<Id> cpIds = new Set<Id>();
        Set<String> months = new Set<String>();
        Set<String> years = new Set<String>();

        Map<Id, Map<String, Object>> eventInfoMap = new Map<Id, Map<String, Object>>();

        for (Event ev : closedEvents) {
            Id cpId = ev.Channel_Partner__c;
            if (cpId == null) continue;

            String eventMonth = String.valueOf(ev.StartDateTime != null ? ev.StartDateTime.month() : Date.today().month());
            String eventYear = String.valueOf(ev.StartDateTime != null ? ev.StartDateTime.year() : Date.today().year());

            smNames.add(ev.OwnerId);
            cpIds.add(cpId);
            months.add(eventMonth);
            years.add(eventYear);

            eventInfoMap.put(ev.Id, new Map<String, Object>{
                'cpId' => cpId,
                'smName' => ev.OwnerId,
                'month' => eventMonth,
                'year' => eventYear
            });
        }

        if (smNames.isEmpty() || cpIds.isEmpty()) return;

        // Step 5: Query matching CP_Meeting_Targets__c
        List<CP_Meeting_Targets__c> cpTargetList = [
            SELECT Id, SM_Name__c, CP_Name__c, Month__c, Year__c, Achievement__c, RecordType.DeveloperName
            FROM CP_Meeting_Targets__c
            WHERE SM_Name__c IN :smNames
            AND Month__c IN :months
            AND Year__c IN :years
        ];

        // Step 6: Build a map for fast lookup
        Map<String, CP_Meeting_Targets__c> targetMap = new Map<String, CP_Meeting_Targets__c>();
        Map<String, CP_Meeting_Targets__c> targetMapNonAOP = new Map<String, CP_Meeting_Targets__c>();
        for (CP_Meeting_Targets__c target : cpTargetList) {
            String key;
            if(channelPartnerAOP.contains(target.CP_Name__c) && target.RecordType.DeveloperName == 'AOP_Targets'){
            	key = target.SM_Name__c + '-' + target.CP_Name__c + '-' + target.Month__c + '-' + target.Year__c;
                targetMap.put(key, target);
            }
            else if(!channelPartnerAOP.contains(target.CP_Name__c) && target.RecordType.DeveloperName == 'Non_AOP_Targets'){
                key = target.SM_Name__c + '-' + target.Month__c + '-' + target.Year__c;
                targetMapNonAOP.put(key, target);
            }
            
        }

        // Step 7: Increment Achievement__c where applicable
        List<CP_Meeting_Targets__c> targetsToUpdate = new List<CP_Meeting_Targets__c>();
        for (Event ev : closedEvents) {
            Map<String, Object> info = eventInfoMap.get(ev.Id);
            if (info == null) continue;

            String smName = (String) info.get('smName');
            Id cpId = (Id) info.get('cpId');
            String month =  (String) info.get('month');
            String year =  (String) info.get('year');
            // String key;
            
            String key = (channelPartnerAOP.contains(cpId))
            ? smName + '-' + cpId + '-' + month + '-' + year
            : smName + '-' + month + '-' + year;
            
            Boolean isAop = channelPartnerAOP.contains(cpId);
        	Map<String, CP_Meeting_Targets__c> mapRef = isAop ? targetMap : targetMapNonAOP;
            Id rtId = isAop ? rtForTargetAOP : rtForTargetNonAOP;
            
            if (mapRef.containsKey(key)) {
                CP_Meeting_Targets__c tgt = mapRef.get(key);
                tgt.Achievement__c = (tgt.Achievement__c == null ? 0 : tgt.Achievement__c) + 1;
                targetsToUpdate.add(tgt);
    
                eventToUpdate.add(new Event(Id = ev.Id, CP_Meeting_Targets__c = tgt.Id));
            } else {
                CP_Meeting_Targets__c newTarget = new CP_Meeting_Targets__c(
                    RecordTypeId = rtId,
                    CP_Name__c = cpId,
                    SM_Name__c = smName,
                    Month__c = month,
                    Year__c = year,
                    Achievement__c = 1
                );
                targetToCreate.add(newTarget);
            }

            
        }

        // Step 8: Perform DML
        if (!targetsToUpdate.isEmpty()) {
            update targetsToUpdate;
        }
        if (!targetToCreate.isEmpty()) {
            Insert targetToCreate;
        }
        
        // Map new inserted Targets to Events
        if (!targetToCreate.isEmpty()) {
            Map<String, Id> newTargetKeyMap = new Map<String, Id>();
            for (CP_Meeting_Targets__c t : targetToCreate) {
                String key = (t.RecordTypeId == rtForTargetAOP)
                    ? t.SM_Name__c + '-' + t.CP_Name__c + '-' + t.Month__c + '-' + t.Year__c
                    : t.SM_Name__c + '-' + t.Month__c + '-' + t.Year__c;
                newTargetKeyMap.put(key, t.Id);
            }
    
            for (Event ev : closedEvents) {
                Map<String, Object> info = eventInfoMap.get(ev.Id);
                if (info == null) continue;
    
                String smId = (String) info.get('smName');
                Id cpId = (Id) info.get('cpId');
                String month =  (String) info.get('month');
                String year =  (String) info.get('year');
    
                String key = (channelPartnerAOP.contains(cpId))
                    ? smId + '-' + cpId + '-' + month + '-' + year
                    : smId + '-' + month + '-' + year;
    
                if (newTargetKeyMap.containsKey(key))
                    eventToUpdate.add(new Event(Id = ev.Id, CP_Meeting_Targets__c = newTargetKeyMap.get(key)));
            }
        }
        
        if(!eventToUpdate.isEmpty()){
            update eventToUpdate;
        }
    }
}