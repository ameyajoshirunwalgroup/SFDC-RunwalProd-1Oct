public class CancellationRequestController {
    @AuraEnabled(cacheable=true)
    public static Booking__c getBookingDetails(Id recordId) {
        try {
            return [
                SELECT Id, Name, Status__c, Source_of_Booking__c, Booking_Date__c, 
                       Primary_Applicant_Name__c, Cancellation_Reason__c, 
                       Cancellation_Sub_reason__c, Cancellation_Subtype__c,
                       Mode_of_Cancellation__c, Meeting_Status__c, Meeting_Date__c,
                       Other_Reason__c, Reason_For_Cancellation__c,
                       RW_Registration_Status__c,
                       Project__r.Name, 
                       Unit_No__r.RW_Param4__c, 
                       Unit_No__r.TowerName__r.Name,
                       Opportunity__r.SAP_Customer_Number__c, 
                       Opportunity__r.Other_Applicants_Name__c, Source_of_Cancellation__c
                FROM Booking__c 
                WHERE Id = :recordId 
                LIMIT 1
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching booking: ' + e.getMessage());
        }
    }
    @AuraEnabled
    public static void saveBookingDetails(Booking__c bookingData) {
        try {
            // Security Check (Optional but recommended)
            if (!Schema.sObjectType.Booking__c.isUpdateable()) {
                throw new AuraHandledException('Insufficient Permissions');
            }
    
            // 2. Query existing record to get "Old" values
            // We include the Opportunity relationship to get the StageName
            Booking__c oldRecord = [
                SELECT Status__c, Opportunity__r.StageName, Opportunity__c,RW_Registration_Status__c
                FROM Booking__c 
                WHERE Id = :bookingData.Id 
                LIMIT 1
            ];
    
            // 3. Map old values to the bookingData object before saving
            bookingData.Old_status__c = oldRecord.Status__c;
            
            if (oldRecord.Opportunity__c != null) {
                bookingData.Old_Opp_Status__c = oldRecord.Opportunity__r.StageName;
            }
            if(oldRecord.RW_Registration_Status__c == 'Registration Completed'){
                bookingData.Cancellation_Initiated_Stage__c = 'Post-Registration';
            }else{
                bookingData.Cancellation_Initiated_Stage__c = 'Post-Book Now';
            }
            System.debug('Source Of Cancellation----->'+bookingData.Source_of_Cancellation__c);
    
            // 4. Perform the update
            update bookingData;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}