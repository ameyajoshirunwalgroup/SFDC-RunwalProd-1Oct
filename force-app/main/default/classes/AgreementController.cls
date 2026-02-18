public class AgreementController{
    
    @AuraEnabled
    public static void approveAgreement(String BookingId){
        Booking__c  bookingRec = [Select id,name,RW_Agreement_Status__c,RW_Agreement_Rejection_Reason__c from Booking__c Where Id=:BookingId];
        bookingRec.RW_Agreement_Status__c = 'Approved';
        bookingRec.RW_Agreement_Rejection_Reason__c = '';
        
        update bookingRec;
    }
    
    @AuraEnabled
    public static void rejectAgreement(String BookingId,String RejectionReason){
        Booking__c  bookingRec = [Select id,name,RW_Agreement_Status__c,RW_Agreement_Rejection_Reason__c from Booking__c Where Id=:BookingId];
        bookingRec.RW_Agreement_Status__c = 'Rejected';
        bookingRec.RW_Agreement_Rejection_Reason__c = RejectionReason;
        update bookingRec;
    }
    
}