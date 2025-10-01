trigger TrgBrokerage on Brokerage__c (after insert, before insert) {
    /*if (trigger.isafter && trigger.isInsert){
        List<Brokerage_Summary__c> brokerSummaryList = new List<Brokerage_Summary__c>();
        List<Brokerage__c> brokerageupdateList = new List<Brokerage__c>();
        for (Brokerage__c b: trigger.new) {
            if(b.Brokerage_Summary__c != null){
                brokerSummaryList = [select Id,Name,Broker__c,Brokerage_Scheme__c,Opportunity__c,Status__c
                                     from Brokerage_Summary__c where Id =: b.Brokerage_Summary__c];
                if(brokerSummaryList[0].Status__c == 'Due' && !brokerSummaryList.isEmpty()){
                    Brokerage__c bb = new Brokerage__c();
                    bb.Id = b.Id;
                    bb.Status__c = 'Due';
                    brokerageupdateList.add(bb);
                }
            }
        }
        if(!brokerageupdateList.isEmpty()){
            update brokerageupdateList;
        }
    }*/
    
    if (trigger.isbefore && trigger.isInsert){
        List<Brokerage_Summary__c> brokerSummaryList = new List<Brokerage_Summary__c>();
        Set<Id> brokerSummaryIds = new Set<Id>();
        List<Brokerage__c> brokerageupdateList = new List<Brokerage__c>();
        for (Brokerage__c b: trigger.new) {
            system.debug('Inside loop');
            brokerSummaryIds.add(b.Brokerage_Summary__c);
        }
        brokerSummaryList = [Select Id,Name,Status__c from Brokerage_Summary__c where Id IN:brokerSummaryIds];
        for (Brokerage__c b: trigger.new) {
            for (Brokerage_Summary__c bs: brokerSummaryList) {
                if(b.Brokerage_Summary__c != null && bs.Status__c == 'Due' && b.Status__c != 'Due' && b.Brokerage_Summary__c == bs.Id){
                    system.debug('Inside if');
                    b.Status__c = 'Due';
                }
            }
        }
        
    }
}