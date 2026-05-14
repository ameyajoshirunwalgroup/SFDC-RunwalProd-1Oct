global class BatchRunLadderBrokerage implements Database.Batchable<sObject>,Database.Stateful {//, Schedulable   
    //public list<Booking__c> bookingListToUpdate = new list<Booking__c>();
    Public static void callBatchRunLadderBrokerage(){
        BatchRunLadderBrokerage  bb = new BatchRunLadderBrokerage();
        Database.executeBatch(bb,50);
    }
    global Database.QueryLocator start(Database.BatchableContext bc){
        system.debug('Inside start method----');
        return Database.getQueryLocator([select Id,Name,Opportunity__c,BrokerIId__c,Agreement_Value_for_brokers__c,Project__c,Booking_Date__c,Tower__c,
                                         RW_X9_99_Received__c,RW_Registration_Done__c,Brokerage_Scheme__c from Booking__c where Project__c != null and Status__c = 'Booking Confirmed'
                                         and  RW_Registration_Done__c = 'Yes' and BrokerIId__c != null and Opportunity__c != null and Exclude_From_Brokerage_Batch__c = false and
                                         Type_of_Client__c != null and Brokerage_Summary__c != null and Booking_Date__c > 2022-09-29T23:01:01Z and RW_Registration_Date__c != null 
                                         and /*Brokerage_Scheme__c ='a2a5j000000YiBiAAK' and BrokerIId__c = 'a010I00001ao4UpQAI' and*/ RW_X9_99_Received__c = true
                                         And Source_of_Booking__c = 'Channel Partner' and Brokerage_Scheme__r.Active__c = false and Brokerage_Scheme__r.End_Date__c	 <= TODAY /*and Brokerage_Scheme__r.End_Date__c >= 2025-11-10*/ 
                                         ORDER BY Booking_Date__c ASC]); 	
    }
    
    global void execute(Database.BatchableContext bc, List<Booking__c> bklist){
        system.debug('Inside execute method----');
        set<ID> SchemeIds = new set<ID>();
        set<ID> CPIds = new set<ID>();
        for(Booking__c b : bklist){
            //CPIds.add(b.BrokerIId__c);
            CPIds.add(b.BrokerIId__c);
            SchemeIds.add(b.Brokerage_Scheme__c);
        }
        
        //SchemeIds.add(SchemeId);
        BatchBrokerageLadderCreation  cc = new BatchBrokerageLadderCreation(CPIds,SchemeIds);
        Database.executeBatch(cc,1);

    }
    
    global void finish(Database.BatchableContext bc) {
}    
}