trigger SendSMSTrigger on SMS_Schedule_SMS_c__c (after Insert) 
{     
        
       set<Id> smsIds = new set<Id>();
       system.debug('trigger execution begins');
      for(SMS_Schedule_SMS_c__c smsList : trigger.new)
      {
                if(smsList.Id != null && smsList.Sender_Mobile__c != null &&  smsList.Name != 'Birthday Wishes')
                {
                        smsIds.add(smsList.Id);   
                        system.debug('sms list id >>>' +smsList.Id);  
                        system.debug('Sender mobile>> '+smsList.Sender_Mobile__c);                       
                }  
     }         
    if(trigger.isAfter && trigger.isInsert)
    {    
        if(smsIds.size() > 0){
                SMSFutureHandler.outboundSMS(smsIds);
        }
        
               
    }  
}