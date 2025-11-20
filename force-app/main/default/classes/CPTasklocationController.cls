public with sharing class CPTasklocationController {
   
    @AuraEnabled
    public static void updateTaskLocation(Id taskId, Decimal latitude, Decimal longitude) {
        // Get the sObject type dynamically
        String objectType = taskId.getSObjectType().getDescribe().getName();

        // Check if it’s a supported object (Task or Event)
        if (objectType == 'Task' || objectType == 'Event') {
            // Build a dynamic query
            String query = 'SELECT Id, CP_Meeting_Address__Latitude__s, CP_Meeting_Address__Longitude__s ' +
                        'FROM ' + objectType + ' WHERE Id = :taskId LIMIT 1';
            SObject recordToUpdate = Database.query(query);
            
            recordToUpdate.put('CP_Meeting_Address__Latitude__s', latitude);
            recordToUpdate.put('CP_Meeting_Address__Longitude__s', longitude);
            
            update recordToUpdate;
        } else {
            throw new AuraHandledException('Unsupported object type: ' + objectType);
        }
    }
    @AuraEnabled(cacheable=true)
    public static Sobject getTaskById(Id taskId) {
        // Ensure the fields are accessible and are queried
        String objectType = taskId.getSObjectType().getDescribe().getName();
        if(objectType == 'Event'){
            return [SELECT Id,CP_Meeting_Address__Latitude__s, CP_Meeting_Address__Longitude__s, Event_Status__c
                    FROM Event
                    WHERE Id = :taskId
                    LIMIT 1];
        }
        if(objectType == 'Task'){
            return [SELECT Id,CP_Meeting_Address__Latitude__s, CP_Meeting_Address__Longitude__s, Event_Status__c
                    FROM Task
                    WHERE Id = :taskId
                    LIMIT 1];
        }
        return null;
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getRestrictedLocations() {
        List<Map<String, Object>> restrictedList = new List<Map<String, Object>>();
        
        // Assuming you used a List Custom Setting named Restricted_Locations__c
        for (Restricted_Locations__c loc : [SELECT Name__c, Latitude__c, Longitude__c FROM Restricted_Locations__c]) {
            if (loc.Latitude__c != null && loc.Longitude__c != null) {
                restrictedList.add(new Map<String, Object>{
                    'name' => loc.Name__c,
                    'latitude' => Decimal.valueOf(loc.Latitude__c),
                    'longitude' => Decimal.valueOf(loc.Longitude__c)
                });
            }
        }
        return restrictedList;
    }
}