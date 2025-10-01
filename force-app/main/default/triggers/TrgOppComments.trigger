trigger TrgOppComments on Opportunity_Comment__c (before insert, after insert) {
    if(trigger.isbefore){
        List<User> u = new List<User>();
        u = [Select Id,ProfileId,UserType from user where Id =:UserInfo.getUserId()];
        for(Opportunity_Comment__c oc : Trigger.New){
            if(u[0].UserType == 'PowerPartner'){
                oc.Source_of_Comment__c = 'CP';
            }else{
                oc.Source_of_Comment__c = 'SM';
            }
            
        }
    }
    if(trigger.isafter){
        List<User> u = new List<User>();
        u = [Select Id,ProfileId,UserType from user where Id =:UserInfo.getUserId()];
        List<Opportunity> opp = new List<Opportunity>();
        for(Opportunity_Comment__c oc : Trigger.New){
            if(oc.Comment__c != null && u[0].UserType == 'PowerPartner'){
                Opportunity o = new Opportunity();
                o.Last_CP_Comments__c = oc.Comment__c;
                o.Id = oc.Opportunity__c;
                opp.add(o);
            }
        }
        update opp;
    }
}