trigger DigitalLinkTrigger on RW_Digital_Link_Status__c (before insert,before update) 
{
for(RW_Digital_Link_Status__c link:Trigger.new)
   {
     if(link.RW_Link_Status__c =='Expired' && link.RW_Link_Expiry_Time__c == null) 
     {
         link.RW_Link_Expiry_Time__c = System.now();
     }
       
       if(link.RW_Link_Status__c =='Active' && link.RW_Link_Expiry_Time__c != null) 
     {
         link.RW_Link_Expiry_Time__c = null;
     }
       
       if(Trigger.isupdate)
       {
           if(link.RW_Link_Status__c =='Active' && Trigger.oldMap.get(link.Id).RW_Link_Status__c == 'Expired')
           {
               link.addError('You cannot change the status from Expired to Active. Please generate a new EOI Link');
           }
       }
   }
}