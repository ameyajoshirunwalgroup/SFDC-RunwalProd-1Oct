trigger LoanCreation on Loan__c (before insert, after insert, after update, before update)
{
    ByPassTriggers__mdt[] byPasstrigMappings = [SELECT Id,Label, ByPassTrigger__c,Object_Name__c FROM ByPassTriggers__mdt];
    Boolean byPassTriggerExceution = false;
    for(ByPassTriggers__mdt bypass : byPasstrigMappings)
    {
        if(bypass.Object_Name__c == 'Loan__c' && bypass.ByPassTrigger__c)
        {
            byPassTriggerExceution = true;
        }
    }
    
    if(!byPassTriggerExceution)
    {
        if (trigger.isBefore) {
            if (trigger.isInsert) {
                LoanController.loanInsert(trigger.new);
                LoanController.updateHLRM(trigger.new,trigger.oldMap);
            }
            if(trigger.isUpdate){
                LoanController.updateHLRM(trigger.new,trigger.oldMap);
            }
        }
        if (trigger.isAfter) {
            if (trigger.isUpdate) {
                Set<Id> lnIdsBkFnd = new Set<Id>();
               for(Loan__c ln: trigger.new){
                    
                        if((ln.HL_Status__c == 'Self- funding' && ln.HL_Status__c != trigger.oldMap.get(ln.Id).HL_Status__c) || 
                          (ln.RW_Reason__c == 'Self- funding' && ln.RW_Reason__c != trigger.oldMap.get(ln.Id).RW_Reason__c)){
                            	lnIdsBkFnd.add(ln.RW_Booking__c);
                        }
                    
                }
                if(lnIdsBkFnd.size()>0)
                	LoanController.updateBookingFundStatus(lnIdsBkFnd);
                
                LoanController.sendEmailAfterLoanClosed(trigger.new, trigger.OldMap);
                LoanController.SendEmailOnNOCGeneration(trigger.new, trigger.OldMap);
                
            }
        }
    }
    
}