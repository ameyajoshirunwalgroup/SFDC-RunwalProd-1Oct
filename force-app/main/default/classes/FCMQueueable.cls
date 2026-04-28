public class FCMQueueable implements Queueable, Database.AllowsCallouts {

    List<App_Notification__c> notifications;

    public FCMQueueable(List<App_Notification__c> notifications){
        this.notifications = notifications;
    }

    public void execute(QueueableContext context){
        
        for(App_Notification__c ntf : notifications){
            FCMService.sendNotification(ntf.Device_Token__c, ntf.Booking__c, ntf.Notification_Type__c, ntf.Title__c, ntf.Message__c, ntf.Record_Id__c, ntf.Id);
        }
    }
}