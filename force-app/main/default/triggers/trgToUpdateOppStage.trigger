trigger trgToUpdateOppStage on Project_Unit__c (after update, before update , after insert, before insert) 
{
     set<Id> projectUnitIds = new set<Id>();
 static boolean firstrun = true;
    List<String> projects = System.label.Service_Room_Available_Projects.split(','); // Added by Vinay 18-02-2025
    List<String> towers = System.label.Service_Room_available_Towers.split(',');// Added by Vinay 18-02-2025
    ByPassTriggers__mdt[] byPasstrigMappings = [SELECT Id,Label, ByPassTrigger__c,Object_Name__c FROM ByPassTriggers__mdt];
    Boolean byPassTriggerExceution = false;
    for(ByPassTriggers__mdt bypass : byPasstrigMappings)
    {
        if(bypass.Object_Name__c == 'Project_Unit__c' && bypass.ByPassTrigger__c)
        {
            byPassTriggerExceution = true;
        }
    }
    
    if(!byPassTriggerExceution)
    {
    system.debug('PU trigger');

 trgToUpdateOppStageHandler objHandler = new trgToUpdateOppStageHandler();     
 if(Trigger.IsAfter && Trigger.IsUpdate && firstrun)
 {firstrun= false;
     objHandler.afterUpdate(Trigger.new, Trigger.oldMap);
 }
 if(Trigger.IsAfter && Trigger.IsUpdate)
 {
     //objHandler.BeforeInsert(Trigger.new, Trigger.oldMap);
     /*
     for(Project_Unit__c pu : Trigger.New)
     {
         //Added by Prashant to update possession date if tower is changed.
         if(trigger.oldMap.get(pu.Id).TowerName__c != trigger.newMap.get(pu.Id).TowerName__c && pu.TowerName__c != null){
			
         }
     }
	*/
     

 }
 if(Trigger.IsAfter && (Trigger.IsInsert || Trigger.IsUpdate))
 {
     List<Id> unitIds = new List<Id>();  //Added by Vinay 18-02-2025
     list<Id> unitIdstoUpdate = new list<Id>();//Added by Prashant 5-3-25
     List<Id> unitIdsLst = new List<Id>();//Added for SDR/ROC Management
     for(Project_Unit__c pid : Trigger.New)
     {     system.debug(pid.RW_Unit_Status__c);
      
      if(Trigger.IsUpdate){
          if((Trigger.oldmap.get(pid.id).Deck_Area__c != Trigger.newmap.get(pid.id).Deck_Area__c ||
              Trigger.oldmap.get(pid.id).Utility_Area__c != Trigger.newmap.get(pid.id).Utility_Area__c || 
              Trigger.oldmap.get(pid.id).new_view__c != Trigger.newmap.get(pid.id).new_view__c ||
              Trigger.oldmap.get(pid.id).new_type__c != Trigger.newmap.get(pid.id).new_type__c ||
              Trigger.oldmap.get(pid.id).new_floor__c != Trigger.newmap.get(pid.id).new_floor__c ||
              Trigger.oldmap.get(pid.id).Saleable_Area__c != Trigger.newmap.get(pid.id).Saleable_Area__c ||
              Trigger.oldmap.get(pid.id).Carpet_Area__c != Trigger.newmap.get(pid.id).Carpet_Area__c ||
                      Trigger.oldmap.get(pid.id).Unit_SAP_Code__c != Trigger.newmap.get(pid.id).Unit_SAP_Code__c  ) &&
             ( pid.RW_Unit_Status__c!='Booked' ||  Trigger.oldmap.get(pid.id).RW_Unit_Status__c !='Booked') ){
                 projectUnitIds.add(pid.id);
             }
          if(projects.contains(pid.RW_Project__c) && towers.contains(pid.TowerName__c) && Trigger.oldmap.get(pid.id).Saleable_Area__c != Trigger.newmap.get(pid.id).Saleable_Area__c){ //Added by Vinay 18-02-2025
              unitIds.add(pid.Id);
          }
          if(Trigger.oldmap.get(pid.id).New_Type__c != Trigger.newmap.get(pid.id).New_Type__c){
              unitIdstoUpdate.add(pid.Id);//Added by Prashant 5-3-25
          }
          if(String.isNotBlank(pid.Service_Room_Unit__c) && pid.RW_Unit_Status__c =='Booked' && Trigger.oldmap.get(pid.id).RW_Unit_Status__c !='Booked'){ //Added by Vinay 20-05-2025
              Project_Unit__c unit = new Project_Unit__c();
              unit.Id = pid.Service_Room_Unit__c;
              unit.RW_Unit_Status__c = 'Sold';
              serviceRoomsToUpdate.add(unit);
          }
      }else{
                 unitIdstoUpdate.add(pid.Id);//Added by Prashant 5-3-25
                 projectUnitIds.add(pid.id);
             }
     }
     
     if(unitIds.size() > 0){ //Added by Vinay 18-02-2025
         ServiceRoomUnitHandler.updateRateList(unitIds);
     }
     if(!unitIdstoUpdate.isEmpty()){
         objHandler.updateTypeLabel(unitIdstoUpdate);
     }
     if(!unitIdsLst.isEmpty()){
            objHandler.calculateRRR(unitIdsLst);
     }
     if(serviceRoomsToUpdate.size() > 0){ //Added by Vinay 20-05-2025
        update serviceRoomsToUpdate;
     }
     
 }
  		//Added by Prashant to assign the date on which the RM is updated.
        Set<Id> puIdstoUpdate = new Set<Id>();
        if(Trigger.IsAfter && Trigger.IsUpdate)
        {
            for(Project_Unit__c pu : Trigger.New)
            {
                if(Trigger.oldmap.get(pu.Id).Relationship_Manager__c != Trigger.newmap.get(pu.Id).Relationship_Manager__c && Trigger.newmap.get(pu.Id).Relationship_Manager__c != null ){                    
                    puIdstoUpdate.add(pu.Id);
                }
            }
        }
        
        //Call the Logic cls
        if(puIdstoUpdate.size() > 0){
            SendRMdetailstoSAP.updateRMUpdationDate(puIdstoUpdate);
        }
        
        
 if(projectUnitIds.size()>0){
     system.debug('OU');
     system.debug(projectUnitIds);
     InventoryCallout.sendinventory(projectUnitIds);
 }
        
        
        //Added by Vinay 17-02-2025 Start
        
        if(Trigger.isInsert){
            
            List<Project_Unit__c> serviceRooms = new List<Project_Unit__c>();
            List<Project_Unit__c> units = new List<Project_Unit__c>();
            for(Project_Unit__c unit : trigger.new){
                if(projects.contains(unit.RW_Project__c) && towers.contains(unit.TowerName__c)){
                    units.add(unit);
                }
                if(unit.Is_Service_Room_Unit__c){
                    serviceRooms.add(unit);
                }
            }
            if(Trigger.isBefore){
                if(serviceRooms.size() > 0){
                    ServiceRoomUnitHandler.serviceRoomCheck(serviceRooms);
                }
                if(units.size() > 0){
                    ServiceRoomUnitHandler.updateSaleableAreaOnUnits(units);
                }
            }
            if(serviceRooms.size() > 0 && Trigger.isAfter){
                serviceRoomUnitHandler.updateServiceRoomAreaOnUnits(serviceRooms);
            }
        }
        if(Trigger.isUpdate && Trigger.isBefore){
            List<Project_Unit__c> units = new List<Project_Unit__c>();
            List<Project_Unit__c> srRemovedUnits = new List<Project_Unit__c>();
            List<Project_Unit__c> serviceRooms = new List<Project_Unit__c>();
            List<Project_Unit__c> unitsForSalableAreaUpdate = new List<Project_Unit__c>();
            List<Project_Unit__c> unitsForServiceAreaUpdate = new List<Project_Unit__c>();
            for(Project_Unit__c unit : trigger.new){
                if(unit.Avail_Service_Room__c == true && unit.Avail_Service_Room__c != trigger.oldMap.get(unit.Id).Avail_Service_Room__c){
                    units.add(unit);
                }else if(unit.Avail_Service_Room__c == false && unit.Avail_Service_Room__c != trigger.oldMap.get(unit.Id).Avail_Service_Room__c){
                    srRemovedUnits.add(unit);
                }
                if(unit.Is_Service_Room_Unit__c == true && !trigger.oldMap.get(unit.Id).Is_Service_Room_Unit__c){
                    serviceRooms.add(unit);
                }
                if(projects.contains(unit.RW_Project__c) && towers.contains(unit.TowerName__c) && unit.Avail_Service_Room__c == false && (unit.Total_RERA_Carpet_Area__c != trigger.oldMap.get(unit.Id).Total_RERA_Carpet_Area__c || unit.Loading__c != trigger.oldMap.get(unit.Id).Loading__c) ){
                    unitsForSalableAreaUpdate.add(unit);
                }
                if(projects.contains(unit.RW_Project__c) && towers.contains(unit.TowerName__c) && unit.Is_Service_Room_Unit__c == true && unit.Carpet_Area__c != trigger.oldMap.get(unit.Id).Carpet_Area__c){
                    unitsForServiceAreaUpdate.add(unit);
                }
            }
            if(units.size() > 0){
                serviceRoomUnitHandler.updateStatusAndUnitOnServiceRoom(units);
            }
            if(srRemovedUnits.size() > 0){
                serviceRoomUnitHandler.removeUnitFromServiceRoom(srRemovedUnits);
            }
            if(serviceRooms.size() > 0){
                serviceRoomUnitHandler.serviceRoomCheck(serviceRooms);
            }
            if(unitsForSalableAreaUpdate.size() > 0){
                serviceRoomUnitHandler.updateSaleableAreaOnUnits(unitsForSalableAreaUpdate);
            }
            if(unitsForServiceAreaUpdate.size() > 0){
                serviceRoomUnitHandler.updateServiceRoomAreaOnUnits(unitsForServiceAreaUpdate);
            }
        }
       //Added by Vinay 17-02-2025 End
    }
}