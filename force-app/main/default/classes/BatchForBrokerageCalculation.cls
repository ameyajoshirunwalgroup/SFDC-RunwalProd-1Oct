global class BatchForBrokerageCalculation implements Database.Batchable<sObject> {//, Schedulable
   @InvocableMethod
    Public static void callbatchbrokerage(){
        BatchForBrokerageCalculation  bb = new BatchForBrokerageCalculation();
        Database.executeBatch(bb,1);
    }
    global Database.QueryLocator start(Database.BatchableContext bc){
        system.debug('Inside start method----');
        Id CPRecordTypeId = Schema.SObjectType.Broker__c.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();//Added by Prashant 12-09-25
         return Database.getQueryLocator([select Id,Name,Opportunity__c,BrokerIId__c,Agreement_Value_for_brokers__c,Project__c,Booking_Date__c,Tower__c,X5_Received__c,
                                         RW_X9_99_Received__c,RW_Registration_Done__c,Brokerage_Scheme__c, Is_Special_Brokerage_Scheme__c,Type_Of_Client_Formula__c  from Booking__c where Project__c != null and Status__c = 'Booking Confirmed'
                                         and  RW_Registration_Done__c != 'Yes' and BrokerIId__c != null and Opportunity__c != null and Exclude_From_Brokerage_Batch__c = false
                                         and Brokerage_Summary__c = null and Booking_Date__c > 2022-09-29T23:01:01Z and (RW_Registration_Date__c != null OR (RW_Registration_Date__c = null And (Is_Special_Brokerage_Scheme__c=true or Is_AOP_CP_Applicable__c = true  OR Type_of_Client__c = 'NRI' OR Type_of_Client__c = 'Outstation' ))) 
                                         and Type_of_Client__c != null 
                                          and (RW_X9_99_Received__c = true or X5_Received__c = true)	
                                          AND BrokerIId__r.RecordTypeId =: CPRecordTypeId //Added by Prashant to Stop billing creation until cp is Registered. 12-09-25. 
                                          AND BrokerIId__r.Valid_RERA_certificate__c = true AND BrokerIId__r.Valid_competency_certificate__c = true//Added by Prashant to update th condition to restrict billing creation for the cps who dont have valid RERA & CC.11-09-25.
 										And Source_of_Booking__c = 'Channel Partner']);//RW_X9_99_Received__c = false 
      
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
                system.debug('Inside for loop::'+b.Name);
                if(b.Opportunity__c != null){
                    optyId.add(b.Opportunity__c);
                    system.debug('optyId::'+optyId);
                    bookingId.add(b.Id);
                    system.debug('bookingId::'+bookingId);
                }
              
                
            }
        }
      
        
        if(bookingId != null && !bookingId.isEmpty()){
          
             BrokerageManagementServicesV2.brokerageCalculation(bookingId);
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
                BatchForBrokerageCalculation Batch = new BatchForBrokerageCalculation();
                ID batchid = Database.executeBatch(Batch,1);         
            }
    }*/
}