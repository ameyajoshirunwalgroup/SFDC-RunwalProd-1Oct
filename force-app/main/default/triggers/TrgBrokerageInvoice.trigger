trigger TrgBrokerageInvoice on Brokerage_Invoice__c (before update, after insert, after update, before insert) {
    if(Trigger.isbefore && Trigger.isupdate){
        for(Brokerage_Invoice__c cpl : trigger.new){
            //List<Profile> pf = [SELECT Id FROM Profile WHERE Name =: 'Customer Portal User'];
            //system.debug('UserInfo:::'+UserInfo.getProfileId()+'::::pfID:::'+pf[0].id);
            //if(UserInfo.getProfileId() == pf[0].id){
            boolean DupFound = false; 
            if(trigger.oldMap.get(cpl.id).Invoice_Number__c == null && trigger.oldMap.get(cpl.id).Invoice_Number__c != trigger.newMap.get(cpl.id).Invoice_Number__c && trigger.newMap.get(cpl.id).Invoice_Number__c != null){
                DupFound = duplicatecheck(cpl.Invoice_Number__c,cpl.Channel_Partner__c);
                if(DupFound){
                    cpl.addError('Duplicate Exist for invoice number-'+cpl.Invoice_Number__c+'');
                }
            }else if(trigger.oldMap.get(cpl.id).Invoice_Number__c != trigger.newMap.get(cpl.id).Invoice_Number__c && trigger.oldMap.get(cpl.id).Invoice_Number__c != null && trigger.newMap.get(cpl.id).Invoice_Number__c != null ){
                DupFound = duplicatecheck(cpl.Invoice_Number__c,cpl.Channel_Partner__c);
                if(DupFound){
                    cpl.addError('Duplicate Exist for invoice number-'+cpl.Invoice_Number__c+'');
                }
            }
            /*if(trigger.oldMap.get(cpl.id).Name != trigger.newMap.get(cpl.id).Name){
                cpl.addError('Field is not Editable');
            }*/
            //}
            
        }
    }
    /*if(Trigger.isAfter && Trigger.isInsert){
        set<Id> InvoiceIds = new set<Id>();
        for(Brokerage_Invoice__c cpl : trigger.new){
            system.debug('cpl::' + cpl.Id);
            InvoiceTriggerHandler.sendEmailmethod(cpl.Channel_Partner__c,cpl.Id);
        }
    }*/
    if(Trigger.isAfter && Trigger.isUpdate){
        set<Id> InvoiceIds = new set<Id>();
        set<Id> InvoiceEmailIds = new set<Id>();
        for(Brokerage_Invoice__c cpl : trigger.new){
           // if(trigger.oldMap.get(cpl.id).Approval_Status__c != null && trigger.oldMap.get(cpl.id).Approval_Status__c != trigger.newMap.get(cpl.id).Approval_Status__c && trigger.newMap.get(cpl.id).Approval_Status__c == 'Approved By L5 - Accounts'){
              if((trigger.oldMap.get(cpl.id).Approval_Status__c != null && trigger.oldMap.get(cpl.id).Approval_Status__c != trigger.newMap.get(cpl.id).Approval_Status__c && trigger.newMap.get(cpl.id).Approval_Status__c == 'Approved By L3 - Accounts')){
                  system.debug('Inside if::');
               InvoiceIds.add(cpl.Id);
            }
            if(trigger.oldMap.get(cpl.id).Approval_Status_clearing__c != null && trigger.oldMap.get(cpl.id).Approval_Status_clearing__c != trigger.newMap.get(cpl.id).Approval_Status_clearing__c && trigger.newMap.get(cpl.id).Approval_Status_clearing__c == 'Approved By L1'){
                InvoiceEmailIds.add(cpl.Id);
            }
           
        }
        if(!InvoiceIds.isEmpty()){
            system.debug('Invoice API Triggered');
            System.enqueueJob(new SAPCPInvoiceCreationQueueable(InvoiceIds));
        }
        if(!InvoiceEmailIds.isEmpty()){
            system.debug('Invoice Email Triggered');
            InvoiceTriggerHandler.sendEmailmethod(InvoiceEmailIds);
        }
    }
    public Boolean duplicatecheck(String InvoiceNo,Id CpId){	
        boolean error = false; 
        system.debug('CpId::' + CpId);
        List <Brokerage_Invoice__c> lstbrokerageInv = new List <Brokerage_Invoice__c>();
        lstbrokerageInv = [select id,Name,Invoice_Number__c from Brokerage_Invoice__c where Invoice_Number__c =:InvoiceNo And Channel_Partner__c =:CpId ];
        system.debug('lstbrokerageInv::' + lstbrokerageInv);
        if(!lstbrokerageInv.isEmpty() && lstbrokerageInv.size() > 0){
            error = true; 
        }
        return error;
    } 
   
}