public class APFController 
{
   public static void SendEmailOnAPFGeneration(List<APF__c> APF)
    {     
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();        
        List<APF__c> apfRecord = [Select Id, Name, RW_Relationship_Manager__r.RM_Name__c, RW_Project__r.Name,RW_Project__r.CRMHead__r.Email, RW_Project__r.Sales_Site_Head__r.Email, RW_Project__r.Project_CRM_Lead__r.Email, RW_Relationship_Manager__r.RM_Email__c,APF_Number__c from APF__c where Id IN: APF];
        List<String> emailsToSend = new List<String>();
        string RManager = '';
        string CRMLead = '';
        string SHead = '';
        
        for(APF__c emails: apfRecord)   
        {
            if(emails.RW_Relationship_Manager__r.RM_Email__c !=null)
            {
                Rmanager =  emails.RW_Relationship_Manager__r.RM_Email__c;
                emailsToSend.add(Rmanager);
            }
            
            if(emails.RW_Project__r.CRMHead__r.Email !=null)
            {
                CRMLead = emails.RW_Project__r.CRMHead__r.Email;
                emailsToSend.add(CRMLead);
            }
            
            if(emails.RW_Project__r.Sales_Site_Head__r.Email !=null)
            {
                SHead = emails.RW_Project__r.Sales_Site_Head__r.Email;
                emailsToSend.add(SHead);
            }                
        }
           
        
        
        for(APF__c apf1 : apfRecord)
        {
           if(apf1 !=null )
            {
                Messaging.SingleEmailMessage Message = new Messaging.SingleEmailMessage();
                EmailTemplate template = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName = 'APF_Created'];
                String htmlBody = template.HtmlValue;
                String plainTextBody = template.Body;
                system.debug('htmlBody -->' + htmlBody);
                system.debug('plainTextBody -->' + plainTextBody);
                system.debug('Email Template -->' + template);
                system.debug('before replace -->');
                system.debug('apf rm name - **' + apf1.RW_Relationship_Manager__r.RM_Name__c);     
                    if(apf1.RW_Relationship_Manager__r.RM_Name__c !=null)
                    {
                    htmlBody = htmlBody.replace('{!APF__c.RW_Relationship_Manager__r.RM_Name__c}', apf1.RW_Relationship_Manager__r.RM_Name__c);
                  
                    }
                    else
                    {
                     htmlBody = htmlBody.replace('{!APF__c.RW_Relationship_Manager__r.RM_Name__c}', 'Team');
                    }               
                    
                    if(apf1.APF_Number__c !=null)
                    {
                    htmlBody = htmlBody.replace('{!APF__c.APF_Number__c}', apf1.APF_Number__c);
                     
                    }
                    else
                    {
                     htmlBody = htmlBody.replace('{!APF__c.APF_Number__c}', '');
                    }
                   
                     if(apf1.RW_Project__r.Name != null)
                    {
                    htmlBody = htmlBody.replace('{!APF__c.RW_Project__c}',  apf1.RW_Project__r.Name);
                    
                    }
                    else
                    {
                     htmlBody = htmlBody.replace('{!APF__c.RW_Project__c}', '');
                    } 
                    
                    if(apf1.RW_Relationship_Manager__r.RM_Name__c !=null)
                    {
                    plainTextBody = plainTextBody.replace('{!APF__c.RW_Relationship_Manager__r.RM_Name__c}',apf1.RW_Relationship_Manager__r.RM_Name__c);
                  
                    }
                    else
                    {
                     plainTextBody = plainTextBody.replace('{!APF__c.RW_Relationship_Manager__r.RM_Name__c}', 'Team');
                    }               
                    
                    if(apf1.APF_Number__c  !=null)
                    {
                    plainTextBody = plainTextBody.replace('{!APF__c.APF_Number__c}', apf1.APF_Number__c);
                     
                    }
                    else
                    {
                     plainTextBody = plainTextBody.replace('{!APF__c.APF_Number__c}', '');
                    }
                   
                     if(apf1.RW_Project__r.Name != null)
                    {
                    plainTextBody = plainTextBody.replace('{!APF__c.RW_Project__c}',  apf1.RW_Project__r.Name);
                    
                    }
                    else
                    {
                     plainTextBody = plainTextBody.replace('{!APF__c.RW_Project__c}', '');
                    }   
              
                message.toAddresses = emailsToSend;
                message.subject = template.Subject;
                message.setTemplateId(template.Id);
                message.setHtmlBody(htmlBody);   
                message.setPlainTextBody(plainTextBody);
                message.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
                Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            }
            
        }
    }
}