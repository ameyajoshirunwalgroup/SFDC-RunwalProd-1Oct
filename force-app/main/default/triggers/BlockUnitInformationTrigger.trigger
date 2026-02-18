trigger BlockUnitInformationTrigger on Blocking_Unit_Information__c (after insert) {
    if(Trigger.isInsert && Trigger.isAfter){
        BlockUnitInformationHandler.handleAfterInsert(Trigger.new);
    }
}