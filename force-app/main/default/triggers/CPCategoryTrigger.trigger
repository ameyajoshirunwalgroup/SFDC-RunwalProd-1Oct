trigger CPCategoryTrigger on CP_Category__c (after update, after insert, before update, before insert) {
  /*  list<Id> cpCatIds = new list<Id>();
    if((trigger.isInsert && trigger.isBefore) || (trigger.isUpdate && trigger.isBefore)) {
        /*list<CP_Category__c> cpCategories = [select id,Channel_Partner__c,Project__c,Category__c from CP_Category__c where Channel_Partner__c != null and Project__c != null and Category__c != null ];
        Map<Id,String> cpCatUniqIdentifierMap = new Map<Id,String>();
        Set<String> cpCatUniqIdentifierSet = new Set<String>();
        for(CP_Category__c c : cpCategories){
            String uniqueIdentifier = c.Channel_Partner__c + '-' + c.Project__c + '-' + c.Category__c;
            cpCatUniqIdentifierMap.put(c.id,uniqueIdentifier);    
            cpCatUniqIdentifierSet.add(uniqueIdentifier);
        }
        for(CP_Category__c c : trigger.new){
            cpCatIds.add(c.Id);
        }
        
        if(!cpCatIds.isEmpty()){
            CPCategoryManagementServices.AssignCPCategories(cpCatIds);
        }
        /*for(CP_Category__c newR : Trigger.new){
            if(newR.Channel_Partner__c != null && newR.Project__c != null && newR.Category__c != null ){
                String uniqueIdentifier = newR.Channel_Partner__c + '-' + newR.Project__c + '-' + newR.Category__c;
                system.debug('uniqueIdentifier'+uniqueIdentifier);
                system.debug('cpCatUniqIdentifierMap.get(newR.Id)'+cpCatUniqIdentifierMap.get(newR.Id));
                if(Trigger.isUpdate && cpCatUniqIdentifierMap.get(newR.Id).equals(uniqueIdentifier)){
                    newR.addError('A CP Category with the same Channel Partner, Project, and Category already exists.');
                }
                if (Trigger.isInsert && cpCatUniqIdentifierSet.contains(uniqueIdentifier)) {
                    newR.addError('A CP Category with the same Channel Partner, Project, and Category already exists.');
                }
            }
        }
    } */
    //Added by Prashant to Trigger to tag P1-P4 category automatically - 19-3-25. 
    list<Id> cpCatIds = new list<Id>();
    if((trigger.isInsert && trigger.isAfter) || (trigger.isUpdate && trigger.isAfter)) {
        for(CP_Category__c cpc : Trigger.new){
            if(trigger.oldMap != null){
                if((trigger.oldMap.get(cpc.id).Channel_Partner__c != trigger.newMap.get(cpc.id).Channel_Partner__c && cpc.Channel_Partner__c != null) || (trigger.oldMap.get(cpc.id).Segment__c != trigger.newMap.get(cpc.id).Segment__c && cpc.Segment__c != null) ){
                    cpCatIds.add(cpc.Id);
                }
            }else{
                if(cpc.Channel_Partner__c != null || cpc.Segment__c != null ){
                    cpCatIds.add(cpc.Id);
                }
            }
        }
    }
    if(!cpCatIds.isEmpty()){
        //P1toP4CategoyAutomation.updateCPCategory(cpCatIds);
    }
    
    
}