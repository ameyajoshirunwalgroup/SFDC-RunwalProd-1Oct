public with sharing class TaskBookingController {
    
    @AuraEnabled(cacheable=true)
    public static BookingDataWrapper getBookingAndRelatedRemarks(Id taskId) {
        // 1. Fetch current task's WhatId
        Task currentTask = [
            SELECT Id, WhatId 
            FROM Task 
            WHERE Id = :taskId 
            LIMIT 1
        ];
        
        Id bookingId = currentTask.WhatId;
        
        if (bookingId == null) {
            return new BookingDataWrapper(null, new List<Task>());
        }

        // 2. Query the requested fields from the Parent Booking record
        List<Booking__c> bookings = [
            SELECT Id, Reason_For_Cancellation__c, Unit_No__r.Name, Customer__r.Name 
            FROM Booking__c 
            WHERE Id = :bookingId 
            LIMIT 1
        ];
        
        Booking__c parentBooking = bookings.isEmpty() ? null : bookings[0];

        // 3. Fetch other Retention Tasks remarks related to this Booking
        List<Task> relatedTasks = [
            SELECT Id, Subject, Remarks__c, CreatedDate 
            FROM Task 
            WHERE WhatId = :bookingId 
            AND RecordType.DeveloperName = 'Retention_Task' 
            AND Id != :taskId
            AND Remarks__c != null
            ORDER BY CreatedDate DESC
        ];
        
        return new BookingDataWrapper(parentBooking, relatedTasks);
    }
    
    // Wrapper class to pass back structured data
    public class BookingDataWrapper {
        @AuraEnabled public Booking__c booking { get; set; }
        @AuraEnabled public List<Task> relatedRemarksTasks { get; set; }
        
        public BookingDataWrapper(Booking__c booking, List<Task> relatedRemarksTasks) {
            this.booking = booking;
            this.relatedRemarksTasks = relatedRemarksTasks;
        }
    }
}