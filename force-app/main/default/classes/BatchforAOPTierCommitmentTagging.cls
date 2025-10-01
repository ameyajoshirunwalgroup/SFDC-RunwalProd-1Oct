global class BatchforAOPTierCommitmentTagging implements Database.Batchable<sObject>,Database.Stateful {//, Schedulable   
    public integer currentYear;
    /*public static void callBatchforAOPTierCommitmentTagging(){
        BatchforAOPTierCommitmentTagging  bb = new BatchforAOPTierCommitmentTagging('');
        Database.executeBatch(bb,20);
    }*/
    
     global BatchforAOPTierCommitmentTagging(Integer currentYear){
         this.currentYear = currentYear;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        system.debug('Inside start method----');
        
        Date startDate = Date.newInstance(currentYear - 1, 4, 1);
        Date endDate = Date.newInstance(currentYear, 3, 31);          
        System.debug('Start Date: ' + startDate);
        System.debug('End Date: ' + endDate);
        return Database.getQueryLocator([SELECT Id, Name, Start_Date__c, End_Date__c, Legacy_booking_treated__c, Category__c, Channel_Partner__c, RecordTypeId 
                                  FROM AOP__c WHERE /*CreatedDate < TODAY AND*/ RecordType.Name = 'AOP' and Start_Date__c >=: startDate and End_Date__c <=: endDate]); 
    }
    
    global void execute(Database.BatchableContext bc, List<AOP__c> AOPScheme){
        system.debug('Inside execute method----');
        System.debug('AOPScheme --> ' + AOPScheme);
        System.debug('AOPScheme Size --> ' + AOPScheme.size());
        system.debug('Current Year - '+currentYear); 

        //List<Booking__c> bookingListToUpdate = new List<Booking__c>();
        List<AOP__c> AOPSchemetoUpdate = new List<AOP__c>();
        Map<Id, List<Booking__c>> aopIdvsBkListMap = new Map<Id, List<Booking__c>>();
        String currentyr = String.valueOf(currentYear);	
        
        list<AOP_tier_commitment_classification__c> AOPTierCommitmentCS = [SELECT Id,Commitment_max__c,Commitment_min__c,Tier__c,Year__c FROM AOP_tier_commitment_classification__c where Year__c =: currentyr];
        Map<String,AOP_tier_commitment_classification__c> aopTierVsCsMap = new Map<String,AOP_tier_commitment_classification__c>();
        for(AOP_tier_commitment_classification__c aopCs : AOPTierCommitmentCS){
            if(aopCs.Tier__c != null){
                aopTierVsCsMap.put(aopCs.Tier__c,aopCs);
            }
        }

        if (!AOPScheme.isEmpty()) {
            for (AOP__c aop : AOPScheme) {
                if(aop.Category__c != null){
                    if(aopTierVsCsMap.get(aop.Category__c) != null){
                        if(aopTierVsCsMap.get(aop.Category__c).Commitment_min__c != null){
                            aop.Commitment_min__c = aopTierVsCsMap.get(aop.Category__c).Commitment_min__c;
                        }
                        if(aopTierVsCsMap.get(aop.Category__c).Commitment_max__c != null){
                            aop.Commitment_max__c = aopTierVsCsMap.get(aop.Category__c).Commitment_max__c;
                        }
                    }
                }
            }
            Database.update(AOPScheme, false);
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        System.debug('Inside Finish Method');
    }
}