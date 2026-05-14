public class ServiceRoomUnitHandler {
  
    public static void updateStatusAndUnitOnServiceRoom(List<Project_Unit__c> unitList){
        Set<Id> towerIds = new Set<Id>();
        Map<String, String> towerIdVsUnitId = new Map<String, String>();
        Map<String,Project_Unit__c> srMap = new Map<String,Project_Unit__c>();
        List<Project_Unit__c> ServiceRooms = [SELECT Id, RW_Project__c, TowerName__c, New_Floor__c, Service_Room_Status__c, Actual_Area_value__c, Deck_Area__c, Carpet_Area__c, Utility_Area__c, Saleable_Area__c FROM Project_Unit__c WHERE Is_Service_Room_Unit__c = true];
        if(ServiceRooms.size() > 0){
            for(Project_Unit__c  sr : ServiceRooms){
                srMap.put(sr.RW_Project__c + '_' + sr.TowerName__c + '_' + sr.New_Floor__c, sr);
            }
            Map<String, Decimal> unitVsAreaMap = new Map<String, Decimal>();
            List<Project_Unit__c> serviceRoomsToUpdate = new List<Project_Unit__c>();
            for(Project_Unit__c unit : unitList){
                if(srMap.get(unit.RW_Project__c + '_' + unit.TowerName__c + '_' + unit.New_Floor__c) != null){
                    Project_Unit__c ServiceRoom = srMap.get(unit.RW_Project__c + '_' + unit.TowerName__c + '_' + unit.New_Floor__c);
                    if(ServiceRoom.Service_Room_Status__c == 'Sold'){
                        unit.addError('Service Room is already Sold for this floor');
                    }else{
                        //unit.Previous_Saleable_Area__c = unit.Saleable_Area__c;
                        //unit.Carpet_Area__c = unit.Carpet_Area__c + ServiceRoom.Carpet_Area__c;
                        //unit.Deck_Area__c = unit.Deck_Area__c + ServiceRoom.Deck_Area__c;
                        //unit.Utility_Area__c = unit.Utility_Area__c + ServiceRoom.Utility_Area__c;
                        unit.Total_RERA_Carpet_Area__c = unit.Carpet_Area__c + unit.Deck_Area__c + unit.Utility_Area__c + ServiceRoom.Carpet_Area__c;
                        if(unit.Total_RERA_Carpet_Area__c != null && unit.Loading__c != null)
                        	unit.Saleable_Area__c = Math.ceil((unit.Total_RERA_Carpet_Area__c * unit.Loading__c) / 5) * 5;
                        unit.Actual_Area_value__c = unit.Saleable_Area__c;
                        unit.Service_Room_Unit__c = ServiceRoom.Id;
                        unit.Service_Room_Carpet_Area__c = ServiceRoom.Carpet_Area__c;
                        unitVsAreaMap.put(unit.id, unit.Saleable_Area__c);
                        serviceRoomsToUpdate.add(ServiceRoom);
                    }
                }else{
                    unit.addError('No Service Room found for the combination of Project, Tower and Floor');
                }
            }
            if(unitVsAreaMap.keySet().size() > 0){
                List<Rate_List__c> rateList = new List<Rate_List__c>();
                for(Rate_List__c rt : [SELECT Id, Project_Unit__c FROM Rate_List__c WHERE Project_Unit__c =: unitVsAreaMap.keySet() AND Global_Charges__r.Name = 'Basic']){
                    rt.Value__c = unitVsAreaMap.get(rt.Project_Unit__c);
                    rateList.add(rt);
                }
                update rateList;
            }
            /*for(Project_Unit__c sr : ServiceRooms){
                if(sr.Service_Room_Status__c != 'Sold'){
                    sr.Service_Room_Status__c = 'Sold';
                }
            }
            Database.update(ServiceRooms, false);*/
            if(serviceRoomsToUpdate.size() > 0){
                for(Project_Unit__c sr : serviceRoomsToUpdate){
                     sr.Service_Room_Status__c = 'Sold';
                }
                Database.update(serviceRoomsToUpdate, false);
            }
        }else{
            unitList[0].addError('No Service Room found for this tower');
        }
    }
    
    public static void removeUnitFromServiceRoom(List<Project_Unit__c> unitList){
        
        List<String> srIds = new List<String>();
        for(Project_Unit__c unit : unitList){
            srIds.add(unit.Service_Room_Unit__c);
        }
        if(srIds.size() > 0){
            Map<Id,Project_Unit__c> srMap = new Map<Id,Project_Unit__c>([SELECT Id, RW_Project__c, TowerName__c, New_Floor__c, Service_Room_Status__c, Actual_Area_value__c, Deck_Area__c, Carpet_Area__c, Utility_Area__c, Saleable_Area__c, Loading__c FROM Project_Unit__c WHERE Id =: srIds]);
            for(Project_Unit__c sr : srMap.values()){
                sr.Service_Room_Status__c = 'Available';
            }
            update srMap.values();
            
            for(Project_Unit__c unit : unitList){
                if(srMap.get(unit.Service_Room_Unit__c) != null){
                    //unit.Carpet_Area__c = unit.Carpet_Area__c - srMap.get(unit.Service_Room_Unit__c).Carpet_Area__c;
                    //unit.Deck_Area__c = unit.Deck_Area__c - srMap.get(unit.Service_Room_Unit__c).Deck_Area__c;
                    //unit.Utility_Area__c = unit.Utility_Area__c - srMap.get(unit.Service_Room_Unit__c).Utility_Area__c;
                    /*Decimal quotient = unit.Saleable_Area__c / 5;
                    if(math.mod(Long.valueOf(String.valueOf(unit.Saleable_Area__c)),5) != 0){
                        quotient -= 1;
                    }
                    Decimal d = (quotient * 5)/unit.Loading__c;
                    unit.Saleable_Area__c = d;*/
                    //unit.Saleable_Area__c = unit.Previous_Saleable_Area__c;
                    unit.Total_RERA_Carpet_Area__c = unit.Carpet_Area__c + unit.Deck_Area__c + unit.Utility_Area__c;
                    if(unit.Total_RERA_Carpet_Area__c != null && unit.Loading__c != null)
                        	unit.Saleable_Area__c = Math.ceil((unit.Total_RERA_Carpet_Area__c * unit.Loading__c) / 5) * 5;
                    unit.Actual_Area_value__c = unit.Saleable_Area__c;
                    unit.Service_Room_Unit__c = null;
                }
            }
        }
    }
    
    public static void serviceRoomCheck(List<Project_Unit__c> srList){
        List<Project_Unit__c> existinfSrList = [SELECT Id, RW_Project__c, TowerName__c, New_Floor__c FROM Project_Unit__c WHERE Is_Service_Room_Unit__c = true];
        Map<String,Project_Unit__c> srMap = new Map<String, Project_Unit__c>();
        for(Project_Unit__c sr : existinfSrList){
            srMap.put(sr.RW_Project__c + '_' + sr.TowerName__c  + '_' + sr.New_Floor__c, sr);
        }
        List<String> projects = System.label.Service_Room_Available_Projects.split(',');
        List<String> towers = System.label.Service_Room_available_Towers.split(',');
        for(Project_Unit__c s : srList){
            if((!projects.contains(s.RW_Project__c) || !towers.contains(s.TowerName__c)) && !Test.isRunningTest()){
                s.addError('You can not create Service Room for this Tower or Project');
            }
            if(srMap.containsKey(s.RW_Project__c + '_' + s.TowerName__c  + '_' + s.New_Floor__c)){
                s.addError('Service Room already exists for the combination of Project, Tower and Floor.');
            }
        }
    }
    
    public static void updateServiceRoomAreaOnUnits(List<Project_Unit__c> srList){
        Map<String,Project_Unit__c> srMap = new Map<String, Project_Unit__c>();
        Set<String> projIds = new Set<String>();
        Set<String> towerIds = new Set<String>();
        Set<String> floors = new Set<String>();
        for(Project_Unit__c s : srList){
            srMap.put(s.RW_Project__c + '_' + s.TowerName__c  + '_' + s.New_Floor__c, s);
            projIds.add(s.RW_Project__c);
            towerIds.add(s.TowerName__c);
            floors.add(s.New_Floor__c);
        }
        List<Project_Unit__c> units = [SELECT Id, RW_Project__c, TowerName__c, New_Floor__c FROM Project_Unit__c WHERE RW_Project__c =: projIds AND TowerName__c =: towerIds AND New_Floor__c =: floors AND Is_Service_Room_Unit__c = false AND Avail_Service_Room__c = false];
        for(Project_Unit__c unit : units){
            unit.Service_Room_Carpet_Area__c = srMap.get(unit.RW_Project__c + '_' + unit.TowerName__c  + '_' + unit.New_Floor__c).Carpet_Area__c;
        }
        update units;
    }
    
    public static void updateRateList(List<Id> unitIds){
        List<Rate_List__c> rateList = new List<Rate_List__c>();
        for(Rate_List__c rt : [SELECT Id, Project_Unit__c, Project_Unit__r.Carpet_Area__c, Rate__c, Charge_on_Area_Type__c, Charge_Based_On_Master__c, ChargeCost__c, Project_Unit__r.Actual_Area_value__c FROM Rate_List__c WHERE Project_Unit__c =: unitIds]){
            if(rt.Charge_on_Area_Type__c == 'Carpet Area'){
                if(rt.Charge_Based_On_Master__c == 'Rate'){
                    rt.Amount__c = rt.Project_Unit__r.Carpet_Area__c * rt.Rate__c;
                }else{
                    rt.Amount__c = rt.ChargeCost__c;
                }
            }else if(rt.Charge_Based_On_Master__c == 'Rate'){
                rt.Amount__c = rt.Project_Unit__r.Actual_Area_value__c * rt.Rate__c;
            }else{
                rt.Amount__c = rt.ChargeCost__c;
            }
            rateList.add(rt);
        }
        if(rateList.size() > 0){
            update rateList;
        }
    }
    
    public static void updateSaleableAreaOnUnits(List<Project_Unit__c> units){
        for(Project_Unit__c unit : units){
            if(unit.Total_RERA_Carpet_Area__c != null && unit.Loading__c != null){
                unit.Saleable_Area__c = Math.ceil((unit.Total_RERA_Carpet_Area__c * unit.Loading__c) / 5) * 5;
            }
        }
    }
}