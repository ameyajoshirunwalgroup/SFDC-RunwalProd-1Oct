trigger trgSocialMediaLead on Social_Media_Lead__c (after insert , after update) {
    
    // List<Social_Media_Lead__c> fbLeadList1 = new List<Social_Media_Lead__c>();
    List<Social_Media_Lead__c> fbLeadList2 = new List<Social_Media_Lead__c>();
    /** if(Trigger.isInsert) {
        for(Social_Media_Lead__c sml : trigger.new) {
            if(String.isNotBlank(sml.source__c) && sml.source__c.equalsIgnoreCase('Facebook'))
                fbLeadList1.add(sml);
        }
        if(!fbLeadList1.isEmpty())
            SocialMediaLeadServices.getFBLeads(trigger.new);
            
    }**/
    if(Trigger.isUpdate) {
        
        for(Social_Media_Lead__c sml : trigger.new) {
            if(String.isNotBlank(sml.Form_Data__c) && !sml.processed__c)
                fbLeadList2.add(sml);
        }
        if(!fbLeadList2.isEmpty())
            SocialMediaLeadServices.formDataParser(trigger.new);
    }
}