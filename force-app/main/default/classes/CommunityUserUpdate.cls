public class CommunityUserUpdate implements Queueable{
    
    public list<Id> userIds = new list<Id>();
    
    public CommunityUserUpdate(list<Id> usrIds){
        userIds = usrIds;
    }

@future
public static void updateUser(List<Id> userIds) 
{
       List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
       List<User> usersToUpdate = new List<User>();
       //EmailTemplate template = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='Community_User_Deactivation'];
 	   for(User u : [Select Id, IsActive, IsPortalEnabled, Email from User  where Id in :userIds])
         {
              	u.IsActive = false;
                u.IsPortalEnabled = false;
                usersToUpdate.add(u);
             	
             	 
            
            /*String htmlBody = template.HtmlValue; 
            //htmlBody = htmlBody.replace('{!RW_EOI__c.Name}', eoiRec.Name);
            String plainTextBody = template.Body; 
            //plainTextBody = plainTextBody.replace('{!RW_EOI__c.Name}', eoiRec.Name);
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
             message.toAddresses = new List<String>{u.email};
            message.subject = template.Subject;
            message.setTemplateId(template.Id);
            message.setHtmlBody(htmlBody);   
            message.setPlainTextBody(plainTextBody);
            message.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
			messages.add(message);
*/            
             
         }
    
     	if (usersToUpdate.size()>0)
         {
                update usersToUpdate;
         }
    
    // if(messages.size() >0)
         //Messaging.sendEmail(messages);
}
    
    public void execute(QueueableContext context) {
        List<User> usersToUpdate = new List<User>();
        for(User u : [Select Id, IsActive, IsPortalEnabled, Email from User  where Id in :userIds]){
            u.IsActive = false;
            u.IsPortalEnabled = false;
            usersToUpdate.add(u);
        }
        if (usersToUpdate.size()>0){
            update usersToUpdate;
         }
    }
}