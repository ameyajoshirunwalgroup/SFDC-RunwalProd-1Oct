public class BrokerageHistoricalBatch implements Database.Batchable<SObject>, Database.Stateful {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Booking__c, Booking__r.Tower__r.Legal_Entity__c,
                   Channel_Partner__c, Invoice_Amount__c,
                   Brokerage_Lookup__r.Name, CreatedDate
            FROM Brokerage_Invoice__c
            WHERE Brokerage_Lookup__r.Name = 'Additional Brokerage'
              AND Booking__r.Tower__r.Legal_Entity__c != null
              AND Channel_Partner__c != null ORDER BY CreatedDate DESC LIMIT 200 
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Brokerage_Invoice__c> invoices) {
        if(invoices.isEmpty()) return;

        // Group: LegalEntity + CP + Month
        Map<String, Decimal> totals = new Map<String, Decimal>();
        Map<String, List<Id>> invoiceMap = new Map<String, List<Id>>();
        Map<String, Date> monthMap = new Map<String, Date>();

        for(Brokerage_Invoice__c inv : invoices) {
            Id legalEntity = inv.Booking__r.Tower__r.Legal_Entity__c;
            Id cp = inv.Channel_Partner__c;
            Date monthStart = Date.newInstance(inv.CreatedDate.year(), inv.CreatedDate.month(), 1);

            String key = legalEntity + '-' + cp + '-' + monthStart;

            totals.put(key, (totals.containsKey(key) ? totals.get(key) : 0) + inv.Invoice_Amount__c);
            monthMap.put(key, monthStart);

            if(!invoiceMap.containsKey(key)) invoiceMap.put(key, new List<Id>());
            invoiceMap.get(key).add(inv.Id);
        }

        // Insert CP_Brokerage
        List<CP_Brokerage__c> toInsert = new List<CP_Brokerage__c>();
        Map<String, CP_Brokerage__c> createdMap = new Map<String, CP_Brokerage__c>();

        for(String key : totals.keySet()) {
            List<String> parts = key.split('-');
            CP_Brokerage__c cpb = new CP_Brokerage__c();
            cpb.Legal_Entity__c    = parts[0];
            cpb.Channel_Partner__c = parts[1];
            cpb.Brokerage_Type__c= 'Additional Brokerage';
            String monthName = getMonthName(monthMap.get(key));
             cpb.Month__c = monthName;
            cpb.Total_Brokerage__c = totals.get(key);
            toInsert.add(cpb);
            createdMap.put(key, cpb);
        }
        insert toInsert;

        // Update invoice links
        List<Brokerage_Invoice__c> toUpdate = new List<Brokerage_Invoice__c>();
        for(String key : invoiceMap.keySet()) {
            CP_Brokerage__c cpb = createdMap.get(key);
            for(Id invId : invoiceMap.get(key)) {
                toUpdate.add(new Brokerage_Invoice__c(Id = invId, CP_Brokerage__c = cpb.Id));
            }
        }
        if(!toUpdate.isEmpty()) update toUpdate;
    }
public static String getMonthName(Date d) {
    List<String> months = new List<String>{
        'January','February','March','April','May','June',
        'July','August','September','October','November','December'
    };
    return months[d.month() - 1] + ' ' + d.year();
}

    public void finish(Database.BatchableContext bc) {
        System.debug('Historical Brokerage Batch completed successfully.');
    }


}