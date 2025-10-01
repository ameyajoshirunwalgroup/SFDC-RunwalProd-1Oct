public class SendNotificationtoSMforVisitFollowUp {
    public static void sendCustomNotification(List<Opportunity> opplist)
    {
        system.debug('opplist'+opplist);
        system.debug('opplist size'+opplist.size());
        Id SalesRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Sales Task').getRecordTypeId();
        for(Opportunity opp : opplist){
            system.debug('Date of Visit:-'+opp.Date_Of_Visit__c);
            list<User> ulist = [Select Id,Name,Profile.Name from User where name =: opp.RW_Sales_Associate__c and IsActive = true];
            system.debug('ulist'+ulist);
            if(ulist.size() == 1){
                system.debug('User'+ulist);
                list<CustomNotificationType> notificationType = [SELECT Id,DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'PushNotificationtoSM'];   
                system.debug('notificationType'+notificationType);              
                String Body = 'Please Call ' + opp.Name + ' who visited on ' + opp.Date_Of_Visit__c.format();
                if (!notificationType.isEmpty()) {          
                    Messaging.CustomNotification customNotificationObj = new Messaging.CustomNotification();              
                    customNotificationObj.setBody(Body);                
                    customNotificationObj.setTitle('Reminder for Visit Follow-Up');  
                    customNotificationObj.setNotificationTypeId(notificationType[0].id);                     
                    customNotificationObj.setTargetId(opp.Id);
                    customNotificationObj.send(new Set<String> {ulist[0].Id});
                }
                
                Task t = new Task();
                t.WhatId = opp.id;
                t.OwnerId = ulist[0].Id;
                t.Visitor_Name__c = opp.Name;
                t.activityDate = System.today();
                //t.Call_Time__c = System.Now().format('h:mm a');
                t.status = 'Not Started';
                t.Subject = 'Visit Follow Up - Auto';
                t.Task_Type__c = 'Sales Call';
                t.Type = 'Site Visit';
                t.RecordTypeId = SalesRecordTypeId;
                t.Type_Of_Meeting__c = 'Inbound';
                t.priority = 'Normal';
                t.Description = 'Reminder to perform Inbound Call to the Customer for Site Visit';
                if(opp.RW_Project__c != null){
                    t.Project__c = opp.RW_Project__c;
                }
                t.ReminderDateTime = DateTime.newInstance(Date.today(), Time.newInstance(8, 15, 0, 0));// schedule date time
                //t.ReminderDateTime = DateTime.now();//Set current date time
                t.IsReminderSet = true;               
                
                try{
                    insert t;
                }catch(Exception e){
                    system.debug('Error while creating Task-------->>>'+e.getMessage());
                }
                
            }
            else if(ulist.size() > 1){
                system.debug('User'+ulist);
                for(User u : ulist){
                    if(u.Profile.Name == 'NRI Sales Manager'){
                        list<CustomNotificationType> notificationType = [SELECT Id,DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'PushNotificationtoSM'];   
                        system.debug('notificationType'+notificationType);              
                        String Body = 'Please Call ' + opp.Name + ' who visited on ' + opp.Date_Of_Visit__c.format();
                        if (!notificationType.isEmpty()) {          
                            Messaging.CustomNotification customNotificationObj = new Messaging.CustomNotification();      
                            if(Test.isRunningTest()){
                            customNotificationObj.setBody(Body);   
                            }
                            customNotificationObj.setTitle('Reminder for Visit Follow-Up');  
                            customNotificationObj.setNotificationTypeId(notificationType[0].id);                     
                            customNotificationObj.setTargetId(opp.Id);
                            customNotificationObj.send(new Set<String> {u.Id});
                        }
                        
                        Task t = new Task();
                        t.WhatId = opp.id;
                        t.OwnerId = u.Id;
                        t.Visitor_Name__c = opp.Name;
                        t.activityDate = System.today();
                        //t.Call_Time__c = System.Now().format('h:mm a');
                        t.status = 'Not Started';
                        t.Subject = 'Visit Follow Up - Auto';
                        t.Task_Type__c = 'Sales Call';
                        t.Type = 'Site Visit';
                        t.RecordTypeId = SalesRecordTypeId;
                        t.Type_Of_Meeting__c = 'Inbound';
                        t.priority = 'Normal';
                        t.Description = 'Reminder to perform Inbound Call to the Customer for Site Visit';
                        if(opp.RW_Project__c != null){
                            t.Project__c = opp.RW_Project__c;
                        }
                        t.ReminderDateTime = DateTime.newInstance(Date.today(), Time.newInstance(8, 15, 0, 0));// schedule date time
                        //t.ReminderDateTime = DateTime.now();//Set current date time
                        t.IsReminderSet = true;               
                        
                        try{
                            insert t;
                        }catch(Exception e){
                            system.debug('Error while creating Task-------->>>'+e.getMessage());
                        }
                    }
                }
                
            }
            else{
                system.debug('No Sales Manager lookup found');
            }
            
        }
    }
}