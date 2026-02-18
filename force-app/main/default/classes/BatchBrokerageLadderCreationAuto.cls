global class BatchBrokerageLadderCreationAuto implements Database.Batchable<SObject>, Database.Stateful {

    global Set<Id> BkIds;

    global BatchBrokerageLadderCreationAuto(Set<Id> BkIds) {
        this.BkIds = BkIds;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id FROM Booking__c WHERE Id IN :BkIds]);
    }

    global void execute(Database.BatchableContext bc, List<Booking__c> blist) {

        if (blist.isEmpty()) return;

        Set<Id> BookingIds = new Set<Id>();
        for (Booking__c b : blist) {
            BookingIds.add(b.Id);
        }
        if(!BookingIds.isEmpty()){
            BrokerageLadderCreation.createInvoicesForSchemesAndCPs(BookingIds);
        }
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('Batch completed successfully');
    }
}