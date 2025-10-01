trigger Trigger_ADFCreditNote on Credit_Note__c (after update) {
    
    ByPassTriggers__mdt[] byPasstrigMappings = [SELECT Id,Label, ByPassTrigger__c,Object_Name__c FROM ByPassTriggers__mdt];
    Boolean byPassTriggerExceution = false;
    for(ByPassTriggers__mdt bypass : byPasstrigMappings)
    {
        if(bypass.Object_Name__c == 'Credit_Note__c' && bypass.ByPassTrigger__c)
        {
            byPassTriggerExceution = true;
        }
    }
    
    if(!byPassTriggerExceution)
    {
        
        List<String> lstCNIds = new List<String>();
        if(Trigger.isAfter && Trigger.isUpdate){
            for(Credit_Note__c objCN : Trigger.new){
                
                if(objCN.Sent_to_SAP__c != (Trigger.oldMap.get(objCN.Id).Sent_to_SAP__c) && objCN.Sent_to_SAP__c == True && objCN.Approval_Status__c == 'Approved'){
                lstCNIds.add(objCN.Id);
            } 
                }
            System.debug('lstCNIds>>>' +lstCNIds);
            if(!lstCNIds.isEmpty() && lstCNIds.size()>0){
                system.enqueuejob(new WhatsAppCustomerOnADFApproved(lstCNIds));
            }
        }
    }    
}