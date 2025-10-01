trigger SurveyTrigger on Survey__c (before insert, before update) {

    Set<Id> oppsIds = new Set<Id>();
    if(Trigger.isInsert || Trigger.isUpdate){
        for(Survey__c survey: trigger.new){
            if(String.isNotBlank(survey.Opportunity__c)){
                oppsIds.add(survey.Opportunity__c);
            }
        }
        
        Map<Id, String> oppEmails = new Map<Id, String>();
        for(Opportunity opp: [Select Id,RW_Email__c From Opportunity where Id In:oppsIds]){
            oppEmails.put(opp.Id, opp.RW_Email__c);
        }
        
        for(Survey__c survey: trigger.new){
            if(String.isNotBlank(survey.Opportunity__c)){
                if(oppEmails.containsKey(survey.Opportunity__c)){
                    survey.Email_on_Survey__c = oppEmails.get(survey.Opportunity__c);
                }
            }
        }
    }
}