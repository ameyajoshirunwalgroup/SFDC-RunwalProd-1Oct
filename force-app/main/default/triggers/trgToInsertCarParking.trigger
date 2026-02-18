trigger trgToInsertCarParking on Car_Parking_Charge__c (after insert , after update) {
    
        
    ByPassTriggers__mdt[] byPasstrigMappings = [SELECT Id,Label, ByPassTrigger__c,Object_Name__c FROM ByPassTriggers__mdt];
    Boolean byPassTriggerExceution = false;
    for(ByPassTriggers__mdt bypass : byPasstrigMappings)
    {
        if(bypass.Object_Name__c == 'Car_Parking_Charge__c' && bypass.ByPassTrigger__c)
        {
            byPassTriggerExceution = true;
        }
    }
    if(!byPassTriggerExceution)
    {

if(Trigger.IsAfter && (Trigger.IsInsert || Trigger.IsUpdate))
    {
        List<Id> carParkingIds = new List<Id>();
        /*for(Car_Parking_Charge__c carpid : Trigger.New)  //Commented by Vinay 05-05-2025
if(Trigger.IsUpdate){
{  if(carpid.Status__c == 'Vacant' && Trigger.oldmap.get(carpid.id).Parking__c != Trigger.newmap.get(carpid.id).Parking__c)          
carParkingIds.add(carpid.id);
}}else{
carParkingIds.add(carpid.id);

}*/
        // PricelistCallout.sendPricelist(carParkingIds);
        // InventoryCallout.sendinventory(carParkingIds);
        for(Car_Parking_Charge__c carpid : Trigger.New){ //Added by Vinay 05-05-2025
            if(Trigger.IsUpdate){
                if((carpid.Status__c == 'Vacant' && Trigger.oldmap.get(carpid.id).Parking__c != Trigger.newmap.get(carpid.id).Parking__c) || 
                   (Trigger.oldmap.get(carpid.id).Car_Parking_Number__c != Trigger.newmap.get(carpid.id).Car_Parking_Number__c ||
                    Trigger.oldmap.get(carpid.id).Height_of_Car_Park_in_ft__c != Trigger.newmap.get(carpid.id).Height_of_Car_Park_in_ft__c ||
                    Trigger.oldmap.get(carpid.id).Length_of_Car_Park_in_ft__c != Trigger.newmap.get(carpid.id).Length_of_Car_Park_in_ft__c ||
                    Trigger.oldmap.get(carpid.id).Width_of_Car_Park_in_ft__c != Trigger.newmap.get(carpid.id).Width_of_Car_Park_in_ft__c)){
                        system.debug('carpid::'+carpid);
                        carParkingIds.add(carpid.id);
                        system.debug('carParkingIds::'+carParkingIds);
                    }
            }else{
                carParkingIds.add(carpid.id);
                system.debug('carParkingIds::'+carParkingIds);
            }
        }
        if(carParkingIds.size()>0){
            If(!test.isRunningTest())
                CarParkingCallout.sendCarPakingList(carParkingIds);
        }
    }
    }
}