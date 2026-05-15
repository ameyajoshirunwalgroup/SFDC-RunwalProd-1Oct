public class RegistrationChallanController 
{
    /*public static void updateBooking(List<RW_Registration_Challan__c> Challans)
    {
        Map<ID, Booking__c> parentBooking = new Map<ID, Booking__c>(); 
        List<Id> listIds = new List<Id>();
        
        for(RW_Registration_Challan__c childObj : Challans)
        {
            listIds.add(childObj.Booking__c);
        }
        
        parentBooking = new Map<Id, Booking__c>([SELECT id,RW_Last_SDR_Received__c,RW_SDR_Status__c, RW_SDR_Ageing__c, Booking_Date__c,(SELECT ID, CreatedDate FROM Registration_Challans__r) FROM Booking__c WHERE ID IN :listIds]);
        system.debug('parentBooking-->' + parentBooking);
        
        for (RW_Registration_Challan__c ch: Challans){
            Booking__c myParentOpp = parentBooking.get(ch.Booking__c);
            myParentOpp.RW_Last_SDR_Received__c = ch.CreatedDate.date();
        }
        
        BookingTriggerHandler.byPass = true;
        update parentBooking.values();  
        BookingTriggerHandler.byPass = false;
        
    } */
}