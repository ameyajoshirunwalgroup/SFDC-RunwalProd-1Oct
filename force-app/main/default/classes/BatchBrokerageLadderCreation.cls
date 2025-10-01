global class BatchBrokerageLadderCreation implements Database.Batchable<sObject> , Database.Stateful{//, Schedulable
    global  Set<Id> CPId;
    global  Set<Id> BSId;
	global BatchBrokerageLadderCreation(Set<Id> CPId,Set<Id> BSId) {
        this.CPId = CPId;
        this.BSId = BSId;
    }
    global Database.QueryLocator start(Database.BatchableContext bc){
        system.debug('Inside start method----');
        System.debug('CPId::'+CPId);
        return Database.getQueryLocator([select Id,Name From Broker__c where Id IN: CPId ]);//RW_X9_99_Received__c = false and
    }
    
    global void execute(Database.BatchableContext bc, List<Broker__c> CPList){
        system.debug('Inside execute method----');
        system.debug('bList -->'+CPList+'bList Size  -->'+CPList.size());
        
        if(!CPList.isEmpty()){
            for(Broker__c cp : CPList){
                    system.debug('Scheme Id::'+BSId);
                    BrokerageLadderCreation.CreateInvoice(BSId,cp.Id);
            }
        }
        
    }
    
    global void finish(Database.BatchableContext bc) {
        System.debug('I ma in Finish Method----');
    }
}