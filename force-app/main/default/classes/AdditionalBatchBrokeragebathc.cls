// THis Batch is used to update field on the a field on Scheame record 

public class AdditionalBatchBrokeragebathc implements Database.Batchable<SObject>, Database.Stateful {

    // Start method: Query Booking__c
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Brokerage_Scheme__c ' +
            'FROM Booking__c ' +
            'WHERE Project__c != null ' +
            'AND Status__c = \'Booking Confirmed\' ' +
            'AND RW_Registration_Done__c = \'Yes\' ' +
            'AND BrokerIId__c != null ' +
            'AND Opportunity__c != null ' +
            'AND Exclude_From_Brokerage_Batch__c = false ' +
            'AND Type_of_Client__c != null ' +
            'AND Brokerage_Summary__c != null ' +
            'AND Booking_Date__c > 2022-09-29T23:01:01Z ' +
            'AND RW_Registration_Date__c != null ' +
            'AND Brokerage_Scheme__c != null ' +
            'AND RW_X9_99_Received__c = true ' +
            'AND Source_of_Booking__c = \'Channel Partner\' ' +
            'AND createddate =  LAST_N_MONTHS:2 '+
            'ORDER BY Booking_Date__c DESC'
        );
    }
  
    // Execute method: process records
    public void execute(Database.BatchableContext bc, List<Booking__c> scope) {
          system.debug('Inside first bathc ----'+scope); 
        Set<Id> schemeIds = new Set<Id>();
        for (Booking__c b : scope) {
            if (b.Brokerage_Scheme__c != null) {
                schemeIds.add(b.Brokerage_Scheme__c);
            }
        }

        if (!schemeIds.isEmpty()) {
            List<Brokerage_Scheme__c> schemeList = [
                SELECT Id, Run_Brokerage_Batch__c 
                FROM Brokerage_Scheme__c 
                WHERE Id IN :schemeIds
            ];

            for (Brokerage_Scheme__c scheme : schemeList) {
                scheme.Run_Brokerage_Batch__c = 'Run';
            }

            if (!schemeList.isEmpty()) {
                update schemeList;
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Brokerage Scheme batch completed.');
    }
}