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
        List<String> creditNoteLst = new List<String>();
        if(Trigger.isAfter && Trigger.isUpdate){
            for(Credit_Note__c objCN : Trigger.new){
                
                if(objCN.Sent_to_SAP__c != (Trigger.oldMap.get(objCN.Id).Sent_to_SAP__c) && objCN.Sent_to_SAP__c == True && objCN.Approval_Status__c == 'Approved'){
                lstCNIds.add(objCN.Id);
            } 
            /**Added for Referral Credit Changes starts */
            if(objCN.CN_type__c == 'Offer / Voucher' && ((objCN.Date_Error_Fixed__c != (Trigger.oldMap.get(objCN.Id).Date_Error_Fixed__c) && objCN.Date_Error_Fixed__c == true) || (objCN.Approval_Status__c !=(Trigger.oldMap.get(objCN.Id).Approval_Status__c) && objCN.Approval_Status__c =='Approved By L2'))){
                System.debug('Inside approval');
                creditNoteLst.add(objCN.Id);
            }
            /**Added for Referral Credit Changes ends */
                }
            System.debug('lstCNIds>>>' +lstCNIds);
            System.debug('creditNoteLst>>>' +creditNoteLst);
            /**Added for Referral Credit Changes starts */
            if(!creditNoteLst.isEmpty() && creditNoteLst.size()>0){
                SAP_Rest_ReferralCreditAPI.sendReferrallist(creditNoteLst);
            }
            /**Added for Referral Credit Changes ends */
            if(!lstCNIds.isEmpty() && lstCNIds.size()>0){
                system.enqueuejob(new WhatsAppCustomerOnADFApproved(lstCNIds));
            }
        }
    }    
}