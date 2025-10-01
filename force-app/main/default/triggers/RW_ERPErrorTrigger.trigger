trigger RW_ERPErrorTrigger on ERP_Integration_Log__c (after insert,after update) {
RW_ERPErrorHandler handler = new RW_ERPErrorHandler();
    if(Trigger.isafter && Trigger.isInsert){
        handler.afterinsert(Trigger.new);
    }
      if(Trigger.isafter && Trigger.isUpdate){
        handler.afterUpdate(Trigger.new);
    }
}