trigger PaymentTransactionTrigger on Payment_Transaction__c (after insert) {

    if(Trigger.isInsert && Trigger.isAfter){
        List<Id> bkgIds = new List<Id>();
        for(Payment_Transaction__c pt : Trigger.new){
            if(pt.Booking__c != null && (pt.Status__c == 'FAILED' || pt.Status__c == 'CANCELLED')){
                bkgIds.add(pt.Booking__c);
            }
        }
        if(bkgIds.size() > 0){
            LockatedApp_Notifications.paymentFailedNotification(bkgIds);
        }
    }
}