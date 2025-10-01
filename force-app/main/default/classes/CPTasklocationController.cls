public with sharing class CPTasklocationController {
    @AuraEnabled
    public static void updateTaskLocation(Id taskId, Decimal latitude, Decimal longitude) {
        Task taskToUpdate = [SELECT Id, CP_Meeting_Address__Latitude__s, CP_Meeting_Address__Longitude__s 
                             FROM Task WHERE Id = :taskId LIMIT 1];
        taskToUpdate.CP_Meeting_Address__Latitude__s = latitude;
        taskToUpdate.CP_Meeting_Address__Longitude__s = longitude;
        update taskToUpdate;
    }
    @AuraEnabled(cacheable=true)
    public static Task getTaskById(Id taskId) {
        // Ensure the fields are accessible and are queried
        return [SELECT CP_Meeting_Address__Latitude__s, CP_Meeting_Address__Longitude__s,Status
                FROM Task
                WHERE Id = :taskId
                LIMIT 1];
    }
}