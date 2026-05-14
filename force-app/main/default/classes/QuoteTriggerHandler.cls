public class QuoteTriggerHandler {
	public static  boolean firstRun = true;
    public static boolean byPass = false;
    
    public static void UpdateBookingAgreementValue(Set<id> qids){
        List<Booking__c> bookingsToUpdate = [SELECT Id, Quotation__c, Stamp_duty_Paid2__c, Quotation__r.Stamp_duty_payable_by_Runwal__c,  Agreement_Value_for_brokers__c,Quotation__r.Broker_Agreement_Value_New__c FROM Booking__c WHERE Quotation__c IN :qids];
        if(!bookingsToUpdate.isEmpty()){
            for(Booking__c b: bookingsToUpdate){
                if( b.Stamp_duty_Paid2__c > b.Quotation__r.Stamp_duty_payable_by_Runwal__c){
                    b.AV_for_broker_calculation_new__c = b.Quotation__r.Broker_Agreement_Value_New__c-(b.Stamp_duty_Paid2__c - b.Quotation__r.Stamp_duty_payable_by_Runwal__c);
                }else{
                    b.AV_for_broker_calculation_new__c = b.Quotation__r.Broker_Agreement_Value_New__c;
                }
            }
            Database.update(bookingsToUpdate, false);
        } 
    }
}