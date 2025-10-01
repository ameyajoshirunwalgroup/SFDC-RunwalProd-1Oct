trigger WhatsAppCampaignMemberTrg on WhatsApp_Campaign_Member__c (before insert) {
    
    
    List<String> campIds = new List<String>();
    for(WhatsApp_Campaign_Member__c mem : Trigger.New){
        campIds.add(mem.WhatsApp_Campaign__c);
    }
    
    List<WhatsApp_Campaign__c> campList = [SELECT Id, Member_Type__c FROM WhatsApp_Campaign__c WHERE Id =: campIds];
    Map<String, String> objMap = new Map<String, String>();
    for(WhatsApp_Campaign__c camp : campList){
        objMap.put(camp.Id, camp.Member_Type__c);
    }

    for(WhatsApp_Campaign_Member__c mem : Trigger.New){
        String campaignObjectType = objMap.get(mem.WhatsApp_Campaign__c);
        Id memId =  mem.Member_Id__c;
        String memberObjectType = memId.getSObjectType().getDescribe().getName();
        if(campaignObjectType != memberObjectType){
            mem.addError('You entered the wrong member type. Please add the member of ' + campaignObjectType + ' type');
        }
    }
}