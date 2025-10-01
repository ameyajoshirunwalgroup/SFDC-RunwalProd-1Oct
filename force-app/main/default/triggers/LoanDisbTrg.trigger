trigger LoanDisbTrg on Loan_Disbursement_Details__c (before insert, before update, after delete) {
    
    if(Trigger.isInsert && Trigger.isBefore){
       // LoanDisbTrgHandler.beforeInsert(Trigger.New);
        LoanDisbTrgHandler.calculateConnectorFees(Trigger.new, null);
    }  
    
    if(Trigger.isUpdate && Trigger.isBefore){
       // LoanDisbTrgHandler.beforeUpdate(Trigger.New, Trigger.OldMap);
       LoanDisbTrgHandler.calculateConnectorFees(Trigger.new, Trigger.oldMap);
    }
    
    if(Trigger.isDelete && Trigger.isAfter){
       LoanDisbTrgHandler.afterDelete(Trigger.OldMap);
    }
    
    if(Trigger.isInsert || Trigger.isUpdate){
        if(Trigger.isBefore){
        	LoanDisbTrgHandler.handleSanctionCase(Trigger.New,Trigger.oldMap);
        }
    }
    
}