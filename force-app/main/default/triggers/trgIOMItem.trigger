trigger trgIOMItem on IOM_Item__c (before insert, after insert) {
    
    Map<String, String> bkgVsIom = new Map<String, String>();
    List<String> unitIds = new List<String>();
    Map<String, Project_Unit__c> unitIdVsUnit = new Map<String, Project_Unit__c>();
    List<Project_Unit__c> units = new List<Project_Unit__c>();
	
    if(Trigger.isInsert && Trigger.isBefore){
        for(IOM_Item__c item : Trigger.new){
            unitIds.add(item.Unit__c);
            bkgVsIom.put(item.Unit__r.Booking__c, item.IOM__r.Name);
        }
        
        unitIdVsUnit = new Map<String, Project_Unit__c>([SELECT Id, Booking__c, Booking__r.Source_of_Booking__c, IOM__c
                                                         FROM Project_Unit__c WHERE Id =: unitIds]);
        for(IOM_Item__c item : Trigger.new){
            item.Booking__c = unitIdVsUnit.get(item.Unit__c).Booking__c;
            item.Booking_Source__c = unitIdVsUnit.get(item.Unit__c).Booking__r.Source_of_Booking__c;
        }
    }
    
    if(Trigger.isInsert && Trigger.isAfter){
        List<Project_Unit__c> unitsToUpdate = new List<Project_Unit__c>();
        for(IOM_Item__c item : Trigger.new){
            Project_Unit__c unit = new Project_Unit__c();
            unit.IOM__c = item.IOM__c;
            unit.Id = item.Unit__c;
            unitsToUpdate.add(unit);
        }
        if(unitsToUpdate.size() > 0){
            update unitsToUpdate;
        }
    }
}