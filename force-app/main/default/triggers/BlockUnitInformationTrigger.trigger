trigger BlockUnitInformationTrigger on Blocking_Unit_Information__c (after insert) {
    if(Trigger.isInsert && Trigger.isAfter){
        
        
        List<Loan__c> loansToInsert = new List<Loan__c>();
        Set<Id> oppId = new Set<Id>();
        for(Blocking_Unit_Information__c blockUnit: trigger.new){
            if(blockUnit.Opportunity__c!=null && blockUnit.Project_Unit__c!=null){
                oppId.add(blockUnit.Opportunity__c);
            }
        }
        Map<Id,CIF__c> mapOfOppAndCIF = new Map<Id,CIF__c>();
        if(!oppId.isEmpty()){
            List<CIF__c> cifList = [Select id,Opportunity__c,Banking_Preference_for_Loan__c from CIF__c where Opportunity__c IN: oppId];
            if(!cifList.isEmpty()){
                for(CIF__c cifObj: cifList){
                    mapOfOppAndCIF.put(cifObj.Opportunity__c,cifObj);
                }
            }
        }
        List<Blocking_Unit_Information__c> validUnits = [Select id,Opportunity__c,Project_Unit__c,Project_Unit__r.RW_Project__c,Project_Unit__r.TowerName__c,Project_Unit__r.TowerName__r.Name,
                                                         Project_Unit__r.RW_Project__r.Name
                                                         from Blocking_Unit_Information__c where Opportunity__c IN: oppId];
        for(Blocking_Unit_Information__c blockUnit: validUnits){
            if(blockUnit.Opportunity__c!=null && blockUnit.Project_Unit__c!=null){
                List<String> pref = new List<String>();
                if(mapOfOppAndCIF.containsKey(blockUnit.Opportunity__c) && mapOfOppAndCIF.get(blockUnit.Opportunity__c).Banking_Preference_for_Loan__c != null){
                    pref = mapOfOppAndCIF.get(blockUnit.Opportunity__c).Banking_Preference_for_Loan__c.split(',');
                    Loan__c ln =  new Loan__c();
                    ln.RW_Customer_Loan_Preference__c = mapOfOppAndCIF.get(blockUnit.Opportunity__c).Banking_Preference_for_Loan__c;
                    ln.RW_Opportunity__c = blockUnit.Opportunity__c;
                    ln.RW_Loan_Record_Status__c = 'Loan Process Initiated';
                    ln.RW_Project_Name__c = blockUnit.Project_Unit__r.RW_Project__c;
                    ln.RW_Tower__c = blockUnit.Project_Unit__r.TowerName__r.Name;
                    ln.RW_Unit_No__c = blockUnit.Project_Unit__c ;
                    if(pref.size() > 0){
                        ln.RW_Bank_Name__c = pref[0];
                        for(Integer i=0;i<pref.size();i++){
                            if(i == 0){
                                ln.RW_Bank_Preference_1__c = pref[i];
                            }
                            if(i == 1){
                                ln.RW_Bank_Preference_2__c = pref[i];
                            }
                            if(i == 2){
                                ln.RW_Bank_Preference_3__c = pref[i];
                            }
                            
                        }
                    }
                    loansToInsert.add(ln);
                }
            }
        }
        if(!loansToInsert.isEmpty()){
            insert loansToInsert;
        }
    }
}