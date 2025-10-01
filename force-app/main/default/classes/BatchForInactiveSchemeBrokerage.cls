global class BatchForInactiveSchemeBrokerage implements Database.Batchable<sObject> , Database.Stateful{//, Schedulable
    @InvocableMethod
    Public static void callInactivebatchbrokerage(){
        BatchForInactiveSchemeBrokerage  bb = new BatchForInactiveSchemeBrokerage(null,null);
        Database.executeBatch(bb,1);
    }
    global  Date strdate;
    global  Date enddate;
    global BatchForInactiveSchemeBrokerage(Date strdate, Date enddate) {
        this.strdate = strdate;
        this.enddate=enddate;
    }
    global Database.QueryLocator start(Database.BatchableContext bc){
        system.debug('Inside start method----');
        System.debug('strdate::'+strdate);
        System.debug('enddate::'+enddate);
        return Database.getQueryLocator([select Id,Name,Opportunity__c,BrokerIId__c,Agreement_Value_for_brokers__c,Project__c,Booking_Date__c,Tower__c,Is_AOP_CP_Applicable__c,
                                         RW_X9_99_Received__c,RW_Registration_Done__c,Brokerage_Scheme__c,Type_Of_Client_Formula__c from Booking__c where Project__c != null and Status__c = 'Booking Confirmed'
                                         and  RW_Registration_Done__c != 'Yes' and BrokerIId__c != null and Opportunity__c != null and Exclude_From_Brokerage_Batch__c = false
                                         and Brokerage_Summary__c = null and Booking_Date__c >= :strdate and Booking_Date__c <= :enddate and  Brokerage_Scheme__c != null
                                         and (RW_X9_99_Received__c = true or X5_Received__c = true) And Source_of_Booking__c = 'Channel Partner' and (RW_Registration_Date__c != null OR (RW_Registration_Date__c = null And (Is_Special_Brokerage_Scheme__c=true OR Is_AOP_CP_Applicable__c = true OR Type_of_Client__c = 'NRI' OR Type_of_Client__c = 'Outstation'  ))) ORDER BY Booking_Date__c ASC ]);//RW_X9_99_Received__c = false and
    }
    
    global void execute(Database.BatchableContext bc, List<Booking__c> bList){
        system.debug('Inside execute method----');
        set<Id> optyId = new set<Id>();
        set<Id> bookingId = new set<Id>();
        List<Opportunity> oppList = new List<Opportunity>();
        List<Booking__c> bookingList = new List<Booking__c>();
        
        system.debug('bList -->'+bList+'bList Size  -->'+bList.size());
        
        if(!bList.isEmpty()){
            for(Booking__c b : bList){
                if(b.Brokerage_Scheme__c != null){
                    system.debug('bookingId::'+b.Id);
                    system.debug('Inside for loop::'+b.Brokerage_Scheme__c);
                    BrokerageManagementServicesV2.BrokerageCalculationForInactiveScheme(b.Id, b.Brokerage_Scheme__c);
                    
                }
            }
        }
        
    }
    
    global void finish(Database.BatchableContext bc) {
        System.debug('I ma in Finish Method----');
    }
}