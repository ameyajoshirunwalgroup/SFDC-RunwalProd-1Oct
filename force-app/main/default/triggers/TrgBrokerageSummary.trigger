trigger TrgBrokerageSummary on Brokerage_Summary__c (after update) {
	if(Trigger.isafter && Trigger.isupdate){
        /*Set<Id> bsId = new Set<Id>();
        for (Brokerage_Summary__c bs: trigger.new){
            if(trigger.oldMap.get(bs.id).Raise_Performa_Invoice__c != trigger.newMap.get(bs.id).Raise_Performa_Invoice__c && trigger.newMap.get(bs.id).Raise_Performa_Invoice__c == true
              && trigger.oldMap.get(bs.id).Raise_Performa_Invoice__c == false){
                BookingTriggerHandler.updateBrokerageSummaryStatus(bs.Booking__c);
            }
            if(trigger.oldMap.get(bs.id).Show_Invoice__c != trigger.newMap.get(bs.id).Show_Invoice__c && trigger.newMap.get(bs.id).Show_Invoice__c == true
              && trigger.oldMap.get(bs.id).Show_Invoice__c == false){
                 bsId.add(bs.id);
            }
        }
        if(!bsId.isEmpty()){
            InvoiceTriggerHandler.sendEmailmethod(bsId);
        }*/
    }
}