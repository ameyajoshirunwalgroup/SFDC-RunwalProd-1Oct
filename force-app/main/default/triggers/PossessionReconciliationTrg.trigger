trigger PossessionReconciliationTrg on Possession_Reconciliation__c (after insert, after update, after delete) {
	
    if(Trigger.isInsert && Trigger.isAfter){
        List<Possession_Reconciliation__c> prsInsert = new List<Possession_Reconciliation__c>();
        for(Possession_Reconciliation__c pr : Trigger.new){
            prsInsert.add(pr);
    	}
        PossessionReconciliationController.afterInsert(prsInsert);
    }
    
    if(Trigger.isUpdate && Trigger.isAfter){
        List<Possession_Reconciliation__c> prsUpdate = new List<Possession_Reconciliation__c>();
        List<Possession_Reconciliation__c> prsDelete = new List<Possession_Reconciliation__c>();
        for(Possession_Reconciliation__c pr : Trigger.new){
            if(pr.Stop_Schedule_Job__c == true && Trigger.oldMap.get(pr.Id).Stop_Schedule_Job__c == false){
                prsDelete.add(pr);
            }else{
                prsUpdate.add(pr);
            }
    	}
        if(prsUpdate.size() > 0){
            PossessionReconciliationController.afterUpdate(prsUpdate);
        }
        if(prsDelete.size() > 0){
            PossessionReconciliationController.afterDelete('PossessionReconciliationEmail- ' + prsDelete[0].Project__c);
        }
        
    }
    
    if(Trigger.isDelete && Trigger.isAfter){
        List<Possession_Reconciliation__c> prsDelete = new List<Possession_Reconciliation__c>();
        for(Possession_Reconciliation__c pr : Trigger.old){
        	prsDelete.add(pr);
    	}
        PossessionReconciliationController.afterDelete('PossessionReconciliationEmail- ' + prsDelete[0].Project__c);
    }
    
}