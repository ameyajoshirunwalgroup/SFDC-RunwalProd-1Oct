trigger WhatsAppCampaignTrg on WhatsApp_Campaign__c (before insert, before update) {
	
    
    List<WhatsApp_Campaign__c> camps = [SELECT Id, Active__c FROM WhatsApp_Campaign__c WHERE Active__c = true];
    
    for(WhatsApp_Campaign__c wc : Trigger.New){
        if(Trigger.isInsert){
            if(wc.Active__c && camps.size() > 0){
                wc.addError('There is already an active campaign exists, please deactivate that before creating the active campaign active');
            }
        }
        if(Trigger.IsUpdate){
            if(Trigger.oldMap.get(wc.Id).Active__c == false && wc.Active__c == true && camps.size() > 0){
                wc.addError('There is already an active campaign exists, please deactivate that before making this campaign as active');
            }
        }
    }
}