trigger OfferTrigger on Offer__c (before insert) 
{
    
   List<Offer__c> offerRecords = [Select Name from Offer__c];
    System.debug('inside 1');
   if(offerRecords!= null && offerRecords.size() >0)
   {
       System.debug('inside 2');
       for(Offer__c existingoffers : offerRecords)
       {
           for(Offer__c offer:Trigger.new)
           {
               System.debug('inside 3'+offer +'\n'+existingoffers);
             
             
             if(offer.Name == existingoffers.Name) 
             {
                 System.debug('inside 4');
                 offer.addError('An offer with same name already exists.');
             }  
               
               
                            
           }
       }
   }
}