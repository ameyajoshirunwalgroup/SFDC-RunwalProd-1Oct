trigger AppNotificationTrg on App_Notification__c (after insert) {
    
    for(App_Notification__c ntf : trigger.new){
        if(ntf.Device_Token__c != null){
            if(!Test.isRunningTest()){
                FCMService.sendNotification(ntf.Device_Token__c, ntf.Booking__c, ntf.Notification_Type__c, ntf.Title__c, ntf.Message__c, ntf.Record_Id__c, ntf.Id);
            }
            //FCMService.sendNotification(ntf.Device_Token__c, ntf.Booking__c, ntf.Notification_Type__c, ntf.Title__c, ntf.Message__c, ntf.Record_Id__c);
        }
    }

}