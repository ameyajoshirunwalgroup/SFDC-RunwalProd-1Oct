public class TrgBrokerageHandler {
    /*//Added by Prashant - Assigning Additional Brokerage Accrued (Dashboards). ///START 02-07-2025.////
	public static void AssignAdditionalBrokerageAccruedDashboards(Map<Id,Decimal> bkIdVsBrgMap){
        system.debug('bkIdVsBrgMap - '+bkIdVsBrgMap);
        list<Booking__c> blist =[Select Id,Additional_Brokerage_Accrued_Dashboards__c,opportunity__r.stagename from Booking__c where Id In : bkIdVsBrgMap.keyset() and Source_of_Booking__c= 'Channel Partner' and Status__c = 'Booking Confirmed' and opportunity__r.stagename = 'Unit Booked'];
        if(!blist.isEmpty()){
            for(Booking__c b: blist){
                Decimal additionalBrokerage = 0;
                if( b.Additional_Brokerage_Accrued_Dashboards__c != null){
                    additionalBrokerage =  b.Additional_Brokerage_Accrued_Dashboards__c;
                }
                additionalBrokerage += bkIdVsBrgMap.get(b.Id);
                b.Additional_Brokerage_Accrued_Dashboards__c = additionalBrokerage;
            }
            system.debug('blist'+blist);
            system.debug('blist size'+blist.size());
            update blist;
        }
    }
    //Added by Prashant - Assigning Additional Brokerage Accrued (Dashboards). ///END 02-07-2025.////*/
}