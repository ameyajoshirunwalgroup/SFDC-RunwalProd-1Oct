trigger trgReferralCredit on Referral_Credits__c (after Insert, after update,before update,before insert) {
    if(Trigger.isAfter && Trigger.isUpdate){
        list<Id> rcIds = new list<Id>();
        list<Id> rcIdsAccs = new list<Id>();
        list<Id> rcIdsCRMHeads = new list<Id>();
        list<Id> rcIdsCRMHOD = new list<Id>();
        list<Id> rcIdsafterPosting = new list<Id>();
        list<Booking__c> blisttoupdate = new list<Booking__c>();
        for(Referral_Credits__c rc : trigger.new){
            //Send referral credit data to SAP
            if(trigger.oldMap.get(rc.id).Approval_Status__c != null && trigger.oldMap.get(rc.id).Approval_Status__c != trigger.newMap.get(rc.id).Approval_Status__c && trigger.newMap.get(rc.id).Approval_Status__c == 'Approved by L2'){
                
                //   System.enqueueJob(new SAPReferralCreditQueueable(rc.Reference_Booking__c));
            }
                        
            //Send Intimation Email to CRM Head.
            if(trigger.oldMap.get(rc.id).Approval_Status__c != trigger.newMap.get(rc.id).Approval_Status__c && trigger.newMap.get(rc.id).Approval_Status__c == 'Submitted for Approval'){
                rcIdsCRMHeads.add(rc.Id);                
            }
            
            //Send Intimation Email to CRM HOD.
            if(trigger.oldMap.get(rc.id).Approval_Status__c != trigger.newMap.get(rc.id).Approval_Status__c && trigger.newMap.get(rc.id).Approval_Status__c == 'Approved by L1'){
                rcIdsCRMHOD.add(rc.Id);                
            }
            
   	 		//Send record details to SAP.         
            if(trigger.oldMap.get(rc.id).Approval_Status__c != trigger.newMap.get(rc.id).Approval_Status__c && trigger.newMap.get(rc.id).Approval_Status__c == 'Approved by L2' && trigger.oldMap.get(rc.id).Approval_Status__c == 'Approved by L1'){
                rcIds.add(rc.Id);
                //rcIdsAccs.add(rc.Id);                  
            }
            
            //Send Email to Accounts Team.
            if(trigger.oldMap.get(rc.id).Vendor_Code__c != trigger.newMap.get(rc.id).Vendor_Code__c && rc.Vendor_Code__c !=null  && 
               trigger.oldMap.get(rc.id).SAP_Document_No__c != trigger.newMap.get(rc.id).SAP_Document_No__c && rc.SAP_Document_No__c !=null &&
               trigger.oldMap.get(rc.id).SAP_Document_Date__c != trigger.newMap.get(rc.id).SAP_Document_Date__c && rc.SAP_Document_Date__c !=null && rc.Date_Error_Fixed__c == false){
                rcIdsAccs.add(rc.Id);                  
            }
            
            //Send referral credit data to SAP manually on checkbox.
            if(trigger.oldMap.get(rc.id).Date_Error_Fixed__c != trigger.newMap.get(rc.id).Date_Error_Fixed__c && trigger.newMap.get(rc.id).Date_Error_Fixed__c == true){
                rcIds.add(rc.Id);
            }
            
            if(trigger.oldMap.get(rc.id).SAP_Posting_Date__c != trigger.newMap.get(rc.id).SAP_Posting_Date__c && trigger.oldMap.get(rc.id).SAP_Posting_Date__c == null && trigger.newMap.get(rc.id).SAP_Posting_Date__c != null){
                rcIdsafterPosting.add(rc.Id);
            }
        }
        
        if(!rcIds.isEmpty()){
            SAP_Rest_ReferralCreditAPI.sendReferrallist(rcIds);
        }
        if(!rcIdsCRMHeads.isEmpty()){
            SendReferralCreditEmails.sendIntimationEmailtoCRMHead(rcIdsCRMHeads);
        }
        if(!rcIdsCRMHOD.isEmpty()){
            SendReferralCreditEmails.sendIntimationEmailtoCRMHOD(rcIdsCRMHOD);
        }
        if(!rcIdsAccs.isEmpty()){
            SendReferralCreditEmails.sendEmailtoAccounts(rcIdsAccs);
        }
        if(!rcIdsafterPosting.isEmpty()){
            SendReferralCreditEmails.sendEmailafterPosting(rcIdsafterPosting);
        }
    }
    
    if(Trigger.isAfter && Trigger.isInsert){
        list<Id> rcIds = new list<Id>();
        for(Referral_Credits__c rc : trigger.new){
            if(Trigger.oldMap == null && Trigger.newMap != null){
                rcIds.add(rc.Id);
            }
        }
        
        if(!rcIds.isEmpty()){
            SendReferralCreditEmails.sendIntimationEmailtoRM(rcIds);
        }
    }
}