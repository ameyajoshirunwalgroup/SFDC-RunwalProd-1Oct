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
    
    public static void callBackNotification(List<Task> tasks){ //Added by Vinay 20-01-2026
        
        CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='Call_Back'];
        List<Id> oppIds = new List<Id>();
        List<Id> accIds = new List<Id>();
        List<Id> leadIds = new List<Id>();
        for(Task tsk : tasks){
            if(tsk.WhatId != null){
                if(tsk.WhatId.getSObjectType().getDescribe().getName() == 'Account'){
                    accIds.add(tsk.WhatId);
                }else if(tsk.WhatId.getSObjectType().getDescribe().getName() == 'Opportunity'){
                    oppIds.add(tsk.WhatId);
                }
            }else if(tsk.WhoId != null){
                if(tsk.WhoId.getSObjectType().getDescribe().getName() == 'Lead'){
                    leadIds.add(tsk.WhoId);
                }
            }
        }
        
        Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id =: accIds]);
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Id, Name FROM Opportunity WHERE Id =: oppIds]);
        Map<Id, Lead> leadMap = new Map<Id, Lead>([SELECT Id, Name FROM Lead WHERE Id =: leadIds]);
        
        for(Task tsk : tasks){
            String customerName = '';
            if(tsk.WhatId != null && oppMap.get(tsk.WhatId) != null){
                customerName = oppMap.get(tsk.WhatId).Name;
            }else if(tsk.WhatId != null && accMap.get(tsk.WhatId) != null){
                customerName = accMap.get(tsk.WhatId).Name;
            }else if(tsk.WhoId != null && leadMap.get(tsk.WhoId) != null){
                customerName = leadMap.get(tsk.WhoId).Name;
            }
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle('Call back to the customer - ' + customerName);
            notification.setBody(tsk.Subject);
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(tsk.Id);
            notification.send(new Set<String>{tsk.OwnerId});
        }
    }
}