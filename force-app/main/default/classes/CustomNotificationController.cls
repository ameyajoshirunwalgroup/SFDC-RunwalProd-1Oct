public class CustomNotificationController {
    
    //Commented by prashant because it is not used any further
   /* public static void presalesLeadAssignNotification(List<Lead> leads){
        
        CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType  WHERE DeveloperName='Presales_Lead_Assignment'];
        for(Lead ld : leads){
            
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle('A new Lead assigned to you');
            notification.setBody(ld.Name);
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(ld.Id);
            notification.send(new Set<String>{ld.OwnerId});
        }
    }

    public static void caseAssignmentNotification(List<Case> cases){
        
     CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='Case_Assignment'];
        for(Case cs : cases){
            if(string.valueOf(cs.OwnerId).startsWith('005')){
                
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                notification.setTitle('A Case assigned to you');
                notification.setBody(cs.CaseNumber);
                notification.setNotificationTypeId(notificationType.Id);
                notification.setTargetId(cs.Id);
                notification.send(new Set<String>{cs.OwnerId});   
            }
            
        }
    }*/
    
    public static void taskAssignmentNotification(List<Task> tasks){
        
        CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='Task_Assignment'];
        for(Task tsk : tasks){
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle('A Task assigned to you');
            notification.setBody(tsk.Subject);
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(tsk.Id);
            notification.send(new Set<String>{tsk.OwnerId});
        }
    }
}