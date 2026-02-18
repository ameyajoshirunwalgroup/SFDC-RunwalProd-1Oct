trigger CPBrokerageTrigger on CP_Brokerage__c (before update, after insert, after update, before insert) {
    if(Trigger.isbefore && Trigger.isupdate){
        for(CP_Brokerage__c cpl : trigger.new){
            boolean DupFound = false; 
            
            // Check if Invoice Number is being added for the first time
            if(trigger.oldMap.get(cpl.id).Invoice_Number__c == null && trigger.oldMap.get(cpl.id).Invoice_Number__c != trigger.newMap.get(cpl.id).Invoice_Number__c && trigger.newMap.get(cpl.id).Invoice_Number__c != null){
                DupFound = duplicatecheck(cpl.Invoice_Number__c,cpl.Channel_Partner__c);
                if(DupFound){
                    cpl.addError('Duplicate Exist for invoice number-'+cpl.Invoice_Number__c+'');
                }
            } 
            // Check if Invoice Number is being changed from one value to another
            else if(trigger.oldMap.get(cpl.id).Invoice_Number__c != trigger.newMap.get(cpl.id).Invoice_Number__c && trigger.oldMap.get(cpl.id).Invoice_Number__c != null && trigger.newMap.get(cpl.id).Invoice_Number__c != null ){
                DupFound = duplicatecheck(cpl.Invoice_Number__c,cpl.Channel_Partner__c);
                if(DupFound){
                    cpl.addError('Duplicate Exist for invoice number-'+cpl.Invoice_Number__c+'');
                }
            }
        }
    }
    
    // Block 3: After Update Logic (Queueable Job & Email)
    if(Trigger.isAfter && Trigger.isUpdate){
        set<Id> InvoiceIds = new set<Id>();
        set<Id> InvoiceEmailIds = new set<Id>();
        set<Id> bIds = new set<Id>();
        
        for(CP_Brokerage__c cpl : trigger.new){
            // Check for SAP Integration status change
            if((trigger.oldMap.get(cpl.id).Approval_Status__c != null && trigger.oldMap.get(cpl.id).Approval_Status__c != trigger.newMap.get(cpl.id).Approval_Status__c && trigger.newMap.get(cpl.id).Approval_Status__c == 'Approved By L3 - Accounts')){
                system.debug('Inside if::');
                InvoiceIds.add(cpl.Id);
            }
            
            // Check for Email status change
            if(trigger.oldMap.get(cpl.id).Approval_Status_clearing__c != null && trigger.oldMap.get(cpl.id).Approval_Status_clearing__c != trigger.newMap.get(cpl.id).Approval_Status_clearing__c && trigger.newMap.get(cpl.id).Approval_Status_clearing__c == 'Approved By L1'){
                InvoiceEmailIds.add(cpl.Id);
            }
            
            //Call updateTDSonChildInvoices on TDS Change
            //Added by Prashant.... 5-1-26
             if((trigger.oldMap.get(cpl.id).SAP_TDS__c != trigger.newMap.get(cpl.id).SAP_TDS__c && trigger.newMap.get(cpl.id).SAP_TDS__c != null)){
                system.debug('Inside if:: TDS change');
                bIds.add(cpl.Id);
            }
        }
        
        // Enqueue SAP Job
        if(!InvoiceIds.isEmpty()){
            system.debug('Invoice API Triggered');
            System.enqueueJob(new SAPCPBrokerageCreationQueueable(InvoiceIds));
        }
        
        // Send Email
        if(!InvoiceEmailIds.isEmpty()){
            system.debug('Invoice Email Triggered');
            CPBrokerageTriggerHandler.sendEmailmethod(InvoiceEmailIds);
        }
        
        //Call updateTDSonChildInvoices on TDS Change
        //Added by Prashant.... 5-1-26
        if(!bIds.isEmpty()){
            system.debug('Invoice TDS population Triggered');
            CPBrokerageTriggerHandler.updateTDSonChildInvoices(bIds);
        }
    }
    
    // Helper Method: Duplicate Check
    public Boolean duplicatecheck(String InvoiceNo,Id CpId){ 
        boolean error = false; 
        system.debug('CpId::' + CpId);
        
        // Query the new object CP_Brokerage__c
        List <CP_Brokerage__c> lstbrokerageInv = new List <CP_Brokerage__c>();
        lstbrokerageInv = [select id,Name,Invoice_Number__c 
                           from CP_Brokerage__c 
                           where Invoice_Number__c =:InvoiceNo And Channel_Partner__c =:CpId ];
                           
        system.debug('lstbrokerageInv::' + lstbrokerageInv);
        if(!lstbrokerageInv.isEmpty() && lstbrokerageInv.size() > 0){
            error = true; 
        }
        return error;
    }
}