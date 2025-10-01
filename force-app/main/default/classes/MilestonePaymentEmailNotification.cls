public with sharing class MilestonePaymentEmailNotification {  
    @InvocableMethod(label='EmailNotification' description='notfications')
     public static void sendEmail(List<ID> ids){
       string projectstage = '';
       string recordId = ''; 
         String OrgWideEmailAddressId = Utility.getOrgWideEmailAddress();
     List<Payment_Milestone__c> obj = [Select Project_Stage__c , Id from Payment_Milestone__c Where Id in:ids];
         List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
         for(Payment_Milestone__c pm : obj){
             
              projectstage = pm.Project_Stage__c;
              recordId = pm.Id;
              mails.add(sendEmail(projectstage , recordId,OrgWideEmailAddressId));
         }   
         //(emailMessage);
		 Messaging.sendEmail(mails);
         
     
    }
    
    public static Messaging.SingleEmailMessage sendEmail(string projectStage , string recordId,string OrgWideEmailAddressId)
    {
     Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();            	
     List<String> sendTo = new List<String>();
	 sendTo.addAll((Label.RW_Email_Milestone).split(','));
	 emailMessage.setToAddresses(sendTo);
     emailMessage.setOrgWideEmailAddressId(OrgWideEmailAddressId);   
     //emailMessage.setReplyTo('sharique1.khan@in.ey.com');
     //emailMessage.setSenderDisplayName('Sharique Khan');  
   	 String Sub = 'New Milestone Inserted.';
     emailMessage.setSubject(Sub);        
     String body = 'This is to be notify that a new milestone is inserted in sfdc. Below is the information:<br /><br />';
     body += '<b>Project Stage :</b> ' + projectStage + '<br>';     
     body += URL.getSalesforceBaseUrl().toExternalForm() + '/' + recordId + '<br><br>'; 
     body += 'Thanks,';  
     emailMessage.setHtmlBody(body);  
        return emailMessage;
     
    }

}