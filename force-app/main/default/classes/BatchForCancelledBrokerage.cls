global class BatchForCancelledBrokerage implements Database.Batchable<sObject> {//, Schedulable
   	@InvocableMethod
    Public static void callbatchcancellation(){
        BatchForCancelledBrokerage  cc = new BatchForCancelledBrokerage();
        Database.executeBatch(cc,1);
    }
    global Database.QueryLocator start(Database.BatchableContext bc){
        system.debug('Inside Cancellation start method----');
        return Database.getQueryLocator([select Id,Name,Customer__c,Agreement_Value_for_brokers__c,Project__c,Status__c,Booking_Date__c,Tower__c,
                                         RW_Total_Receipt_Amount_Received__c,Brokerage_Scheme__c,RW_Registration_Done__c, BrokerIId__c from Booking__c where
                                         Status__c = 'Cancelled' and BrokerIId__c != null and Brokerage_Cancelled__c = false and Brokerage_Scheme__c != null and Exclude_From_Brokerage_Batch__c = false
                                        and Brokerage_Summary__c != null]);
        //and RW_Registration_Done__c != 'Yes' and RW_X9_99_Received__c = false
    }
    
    global void execute(Database.BatchableContext bc, List<Booking__c> bList){
        system.debug('Inside execute method----');
        set<Id> bookingId = new set<Id>();
        List<Booking__c> bookingList = new List<Booking__c>();
        
        system.debug('bList -->'+bList+'bList Size  -->'+bList.size());
        
        if(!bList.isEmpty()){
            for(Booking__c b : bList){
                system.debug('Inside for loop');
                if(b.Status__c == 'Cancelled' && b.Brokerage_Scheme__c != null){
                    bookingId.add(b.id);
                    system.debug('bookingId::'+bookingId);
                    
                }
              
                
            }
        }
      
        
        if(bookingId != null && !bookingId.isEmpty()){
          
             BrokerageManagementService.insertCancelledBrokerage(bookingId);
        }
       
    }
    
    global void finish(Database.BatchableContext bc) {
        System.debug('I ma in Finish Method----');
    }
    /*global void execute(SchedulableContext sc) {
        system.debug('Inside SchedulableContext-----');
        BusinessHours bh = [Select Id , Name From BusinessHours Where Name =: 'Default'];
            DateTime CreatedTime = System.now();
          
            Boolean isWithin = BusinessHours.isWithin(bh.id, CreatedTime);
            System.debug('is within :: ' + isWithin);
            System.debug('Created time is :: ' +CreatedTime );
            if(isWithin == True ){
                BatchForCancelledBrokerage Batch = new BatchForCancelledBrokerage();
                ID batchid = Database.executeBatch(Batch,1);         
            }
    }*/
}