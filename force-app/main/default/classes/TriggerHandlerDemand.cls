public class TriggerHandlerDemand {
    public static void createTask(List<RW_Demand__c> lstDemand){
        
        List<Task> lstTasksToInsert = new List<Task>();
        Set<Id> setBookingId = new Set<Id>();
        Id RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Collection_Task').getRecordTypeId();
        system.debug('RecordTypeId>>>>' +RecordTypeId);
        
        if(!lstDemand.isEmpty() && lstDemand.size()>0){
            for(RW_Demand__c objDemand : lstDemand){
                if(objDemand.Booking__c != null){
                    setBookingId.add(objDemand.Booking__c);
                }
            }
            system.debug('setBookingId>>>>>' +setBookingId);
            Map<Id, Booking__c> mapBooking = new Map<Id, Booking__c>([SELECT Id,Customer__r.AccountId, Unit_No__r.Relationship_Manager__r.User__c 
                                                                      FROM Booking__c 
                                                                      WHERE Id IN :setBookingId]);
            Booking__c objBooking;
            system.debug('mapBooking>>>>>' +mapBooking);
            for(RW_Demand__c objDemand : lstDemand){
                Task objTask = new Task();
                objTask.RecordTypeId = RecordTypeId;
                objTask.Demand__c = objDemand.Id;
                objTask.Task_Type__c = 'Collection Call';
                objTask.Subject = 'Collection Call Task';
                objTask.Collection_Status__c = 'Due (default)';
                objBooking = mapBooking.get(objDemand.Booking__c);
                objTask.Demand__c = objDemand.Id;
                objTask.WhatId = objDemand.Id;
                objTask.Booking__c = objBooking.Id;
                system.debug('objTask.WhatId >>>' +objTask.WhatId);
               /* if(objBooking.Customer__r.AccountId != null){
                    objTask.WhoId = objBooking.Customer__r.AccountId;
                }
                system.debug('objTask.WhoId >>>' +objTask.WhoId);*/
                if(objBooking != null &&
                   objBooking.Unit_No__r != null &&
                   objBooking.Unit_No__r.Relationship_Manager__r != null &&
                   objBooking.Unit_No__r.Relationship_Manager__r.User__c != null){
                       objTask.OwnerId = objBooking.Unit_No__r.Relationship_Manager__r.User__c;
                   }  
                lstTasksToInsert.add(objTask);
            }
        }
        system.debug('lstTasksToInsert>>>>' +lstTasksToInsert);
        if(!lstTasksToInsert.isEmpty()){
            Insert lstTasksToInsert;
        }
    }
}