public class sendEmailAndSMSOnPresalesOutboundCall {
    
     Boolean EmailSent;
     public void presalesOutboundCall(List<Task> lstTask){
         system.debug('in sendEmailOnPresalesOutboundCall________ '+lstTask.size());
      //Added by Mounika from EY (Date: 22/Nov/2020 - Presales FRD:3)
     
     Set<ID> setOfLead = new Set<ID>();
     Id presalesTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Presales Task').getRecordTypeId();//Added by Vinay 24-04-2025
      for(Task objTask : lstTask)
        {
            if(objTask.WhoId != null && objTask.WhoId.getSObjectType()==Lead.sObjectType && objTask.RecordTypeId != presalesTaskRecordTypeId){ //Added objTask.RecordTypeId == presalesTaskRecordTypeId by Vinay 24-04-2025
                  system.debug('in line 10________');//objTask.Task_Type__c == 'Presales Task' && 
                if(objTask.Communication_Type__c == 'Outbound Call' 
                   && (objTask.Call_Status__c == 'Ringing' || objTask.Call_Status__c == 'Number Busy'
                   || objTask.Call_Status__c == 'Not contactable' || objTask.Call_Status__c == 'Switched off' 
                   || objTask.Call_Status__c == 'Customer Disconnected(DNC)' || objTask.Call_Status__c == 'Follow Up- NC'  
                   || objTask.Call_Status__c == 'Out of Coverage Area' || objTask.Call_Status__c == 'Spoke to the 3rd party')){
                   system.debug('in line 14________');
                  setOfLead.add(objTask.WhoId);
                }
               
            }
               
        }
        
        List<Lead> ledList =[select Id,Name,Email,RW_Mobile_No__c,LeadSource From Lead WHERE Id=: setOfLead];
         system.debug('### ledList '+ledList.size());
        for(Lead led: ledList){
            
            if(led.LeadSource != 'Corporate' && led.LeadSource != 'Channel Partner' && led.LeadSource != 'NRI'
               && led.LeadSource != 'Outstation' && led.LeadSource !='loyalty' && led.LeadSource != 'Referral'){
                sendEmailToLead(led);
                sendSMSToLead(led);
            }
        }
        
    
   }
 
    public void sendEmailToLead(Lead led){
       
        //query on template object
        EmailTemplate et=[Select id,Name from EmailTemplate where name=:'Presales Outbound Call'];

        //list of emails
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();   
       
         
            if(led.Id != null && led.Email != null){
                Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
                singleMail.setTargetObjectId(led.Id);
                singleMail.setTemplateId(et.Id);
                singleMail.setSaveAsActivity(false);
                emails.add(singleMail);
            }
        try{
      
       Messaging.SendEmailResult[] results = Messaging.sendEmail(emails,false);
            system.debug('Messaging ' + results[0]);
               
            if (results[0].success) 
            {
                EmailSent = True;
                System.debug('The email was sent successfully.');
            } else 
            {	
                 EmailSent = false;
                System.debug('The email failed to send: ' + results[0].errors[0].message);
            }
        }catch(exception e){
            system.debug(e.getMessage());
        }
      //Ends here
     }
        
    public void sendSMSToLead(Lead led){
        
         RW_Presales_Communication__c preComm = New RW_Presales_Communication__c();
       
        preComm.RW_Outbound_Call_Mode_of_Communication__c  = 'SMS';
        If(EmailSent == True){
        preComm.RW_Outbound_Call_Mode_of_Communication__c += ',Email';
        }
        preComm.RW_OutboundCall_Email_WhatsApp_Sent_Date__c = system.now();
        preComm.RW_Lead_Email__c = led.Email;
        preComm.RW_Lead_Mobile_No__c =led.RW_Mobile_No__c;
        preComm.RW_Lead__c = led.Id;
        insert preComm;
        System.debug('RW_Presales_Communication__c Record inserted______ ' +preComm);
      
        }
    
  }