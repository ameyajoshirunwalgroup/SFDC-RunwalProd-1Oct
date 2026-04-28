trigger DemandTrigger on RW_Demand__c (After insert, after update) {
    
    ByPassTriggers__mdt[] byPasstrigMappings = [SELECT Id,Label, ByPassTrigger__c,Object_Name__c FROM ByPassTriggers__mdt];
    Boolean byPassTriggerExceution = false;
    for(ByPassTriggers__mdt bypass : byPasstrigMappings){
        if(bypass.Object_Name__c == 'RW_Demand__c' && bypass.ByPassTrigger__c){
            byPassTriggerExceution = true;
        }
    }    
    if(!byPassTriggerExceution){
        if(Trigger.isAfter && Trigger.isInsert){
            TriggerHandlerDemand.createTask(Trigger.new);
            List<Id> demandIds = new List<Id>(); //Added by Vinay 14-01-2026
            List<Id> bkgIds = new List<Id>(); //Added by Vinay 24-03-2026
            for(RW_Demand__c dem : Trigger.new){ //Added by Vinay 14-01-2026
                if(dem.RW_Demand_Status__c != 'Revoke'){
                    demandIds.add(dem.Id);
                    bkgIds.add(dem.Booking__c); //Added by Vinay 24-06-2026
                }
            }
            //LockatedApp_Notifications.tdsPaymentGuideNotification(demandIds); //Added by Vinay 14-01-2026
            LockatedApp_Notifications.demandNotification(demandIds); //Added by Vinay 14-01-2026
            CurrentPreviousMilestoneUpdateOnBooking.updateMilestones(bkgIds); //Added by Vinay 24-06-2026
        }
        if(Trigger.isAfter && Trigger.isUpdate){ // Added by Vinay 15-10-2025
            List<RW_Demand__c> onTimePayments = new List<RW_Demand__c>();
            Date dateAfert7Days = Date.today() + 7;
            for(RW_Demand__c dem : Trigger.new){
                if(trigger.oldMap.get(dem.Id).RW_Demand_Status__c != 'Paid' && dem.RW_Demand_Status__c == 'Paid' && dem.Due_Date__c <= dateAfert7Days){
                    onTimePayments.add(dem);
                }
            }
            if(onTimePayments.size() > 0){
                LockatedApp_LoyaltyEngine.earlyPayment(onTimePayments); //Added by Vinay 19-01-2026
            }
        }
    }
}