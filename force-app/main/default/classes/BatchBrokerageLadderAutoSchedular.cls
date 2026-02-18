global class BatchBrokerageLadderAutoSchedular implements Schedulable {
    global void execute(SchedulableContext sc) {      
        Set<Id> CPIds = new Set<Id>();
        Set<Id> SchemeIds = new Set<Id>();
         Id CPRecordTypeId = Schema.SObjectType.Broker__c.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();//Added by Prashant 12-09-25
        list<Booking__c> bkList = [select Id,Name,Opportunity__c,BrokerIId__c,Agreement_Value_for_brokers__c,Project__c,Booking_Date__c,Tower__c,
                                   RW_X9_99_Received__c,RW_Registration_Done__c,Brokerage_Scheme__c from Booking__c where Project__c != null and Status__c = 'Booking Confirmed'
                                   and  RW_Registration_Done__c = 'Yes' and BrokerIId__c != null and Opportunity__c != null and Exclude_From_Brokerage_Batch__c = false and
                                   Type_of_Client__c != null and Brokerage_Summary__c != null and Booking_Date__c > 2022-09-29T23:01:01Z and RW_Registration_Date__c != null 
                                   and RW_X9_99_Received__c = true And Source_of_Booking__c = 'Channel Partner' /*and BrokerIId__c = 'a012800000sGnNs' */ and  Brokerage_Scheme__c != null 
                                   AND BrokerIId__r.RecordTypeId =: CPRecordTypeId //Added by Prashant to Stop billing creation until cp is Registered. 12-09-25. 
                                   AND Checklist_Approved__c = true//Added by Prashant to add checklist approved condition(billing checklist should be approved before summary creation )//17-11-2025....
                                   AND BrokerIId__r.Valid_RERA_certificate__c = true/* AND BrokerIId__r.Valid_competency_certificate__c = true*///Commented by Prashant as discussed with team to discard use of CC. 12/12/25.///Added by Prashant to update th condition to restrict billing creation for the cps who dont have valid RERA & CC.11-09-25.	
                                   and Brokerage_Scheme__r.End_Date__c >= LAST_90_DAYS /*and  Brokerage_Scheme__r.Active__c = false*/ and Brokerage_Scheme__r.Ladder_Creation_Manual__c = false/*Added deployment date filter to ignore the earlier ended schemes*/
                                   ORDER BY Booking_Date__c ASC];
        Set<Id> bookingIds = new Set<Id>();
        for (Booking__c b : bkList) {
            bookingIds.add(b.Id);
        }

        /*or(Booking__c b:bkList){
            CPIds.add(b.BrokerIId__c);
            SchemeIds.add(b.Brokerage_Scheme__c);
        }*/
        BatchBrokerageLadderCreationAuto  cc = new BatchBrokerageLadderCreationAuto(bookingIds);
        Database.executeBatch(cc,50);
        /*MonthwiseBrokerageRecords batch = new MonthwiseBrokerageRecords();
		Database.executebatch(batch,200);*/
    }
}