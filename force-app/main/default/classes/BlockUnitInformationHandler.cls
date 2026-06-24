public class BlockUnitInformationHandler {

    public static void handleAfterInsert(List<Blocking_Unit_Information__c> newList) {
        
        List<Loan__c> loansToInsert = new List<Loan__c>();
        List<Loan__c> loansToUpdate = new List<Loan__c>();
        Set<Id> oppId = new Set<Id>();

        for(Blocking_Unit_Information__c blockUnit: newList){
            if(blockUnit.Opportunity__c!=null && blockUnit.Project_Unit__c!=null){
                oppId.add(blockUnit.Opportunity__c);
            }
        }

        Map<Id,CIF__c> mapOfOppAndCIF = new Map<Id,CIF__c>();
        if(!oppId.isEmpty()){
            for(CIF__c cifObj : [SELECT Id, Opportunity__c, Banking_Preference_for_Loan__c,Mode_of_funding__c FROM CIF__c WHERE Opportunity__c IN :oppId]){
                mapOfOppAndCIF.put(cifObj.Opportunity__c, cifObj);
            } 
        }
        
        Map<String, Loan__c> existingLoanMap = new Map<String, Loan__c>();
        for (Loan__c ln : [SELECT Id, RW_Opportunity__c, RW_Unit_No__c, RW_Customer_Loan_Preference__c,RW_Loan_Record_Status__c FROM Loan__c WHERE RW_Opportunity__c IN :oppId]) {
            if (ln.RW_Opportunity__c != null && ln.RW_Unit_No__c != null) {
                String key = String.valueOf(ln.RW_Opportunity__c);
                existingLoanMap.put(key, ln);
            }   
        }
        
        List<Blocking_Unit_Information__c> validUnits = [SELECT Id, Opportunity__c, Project_Unit__c, Project_Unit__r.RW_Project__c,Project_Unit__r.TowerName__r.Name FROM Blocking_Unit_Information__c WHERE Opportunity__c IN :oppId AND Active__c=True];
        for(Blocking_Unit_Information__c blockUnit: validUnits){
            if(blockUnit.Opportunity__c!=null && blockUnit.Project_Unit__c!=null){
                 String key = String.valueOf(blockUnit.Opportunity__c);
                 CIF__c cifObj = mapOfOppAndCIF.get(blockUnit.Opportunity__c);
					
                 // Case 1: Existing Loan → Update
                 if (existingLoanMap.containsKey(key)) {
                    Loan__c existingLoan = existingLoanMap.get(key);
                        updateExistingLoan(existingLoan, cifObj);
                        loansToUpdate.add(existingLoan);
                    	continue;
                }
                
				// Case 2: No existing Loan → Insert new Loan (only if CIF has loan preference)
                if(cifObj != null && cifObj.Banking_Preference_for_Loan__c != null){
                    Loan__c newLoan = createNewLoan(blockUnit, cifObj);
                    loansToInsert.add(newLoan);
                    existingLoanMap.put(key, newLoan);
                }
            }
        }

        if(!loansToInsert.isEmpty()){
            insert loansToInsert;
        }
        if(!loansToUpdate.isEmpty()){
            update loansToUpdate;
        }
    }

    public static Loan__c createNewLoan(Blocking_Unit_Information__c blockUnit, CIF__c cifObj) {
        Loan__c ln = new Loan__c();
        List<String> pref = cifObj.Banking_Preference_for_Loan__c != null 
            ? cifObj.Banking_Preference_for_Loan__c.split(',')
            : new List<String>();
        
        ln.RW_Customer_Loan_Preference__c = cifObj.Banking_Preference_for_Loan__c;
        ln.RW_Opportunity__c = blockUnit.Opportunity__c;
        ln.RW_Loan_Record_Status__c = 'Loan Process Initiated';
        ln.RW_Project_Name__c = blockUnit.Project_Unit__r.RW_Project__c;
        ln.RW_Tower__c = blockUnit.Project_Unit__r.TowerName__r.Name;
        ln.RW_Unit_No__c = blockUnit.Project_Unit__c;

        if (!pref.isEmpty()) {
            ln.RW_Bank_Name__c = pref[0];
            if (pref.size() > 0) ln.RW_Bank_Preference_1__c = pref[0];
            if (pref.size() > 1) ln.RW_Bank_Preference_2__c = pref[1];
            if (pref.size() > 2) ln.RW_Bank_Preference_3__c = pref[2];
        }

        return ln;
    }
    
	public static void updateExistingLoan(Loan__c existingLoan, CIF__c cifObj) {
        if (cifObj == null || existingLoan == null) return;

        // CASE 1 → Self Funded → clear all preferences
        if (cifObj.Mode_of_Funding__c == 'Self Funded'  && existingLoan.RW_Loan_Record_Status__c != 'Loan Closed') {
            existingLoan.RW_Customer_Loan_Preference__c = null;
            existingLoan.RW_Bank_Name__c = null;
            existingLoan.RW_Bank_Preference_1__c = null;
            existingLoan.RW_Bank_Preference_2__c = null;
            existingLoan.RW_Bank_Preference_3__c = null;
            existingLoan.RW_Loan_Record_Status__c = 'Loan Closed';
            existingLoan.Loan_Record_Sub_Status__c = 'Self-Funding';
            existingLoan.RW_Reason__c = 'Self-funding';
            existingLoan.RW_Loan_Closure_Date__c = Date.today();
            existingLoan.HL_RM__c=null;
            return;
        }

        // CASE 2 → Banking preference changed → update preferences
        if (cifObj.Mode_of_Funding__c != 'Self Funded' && cifObj.Banking_Preference_for_Loan__c != existingLoan.RW_Customer_Loan_Preference__c) {
            existingLoan.RW_Customer_Loan_Preference__c = cifObj.Banking_Preference_for_Loan__c;
            List<String> pref = new List<String>();
            if (cifObj.Banking_Preference_for_Loan__c != null) {
                pref = cifObj.Banking_Preference_for_Loan__c.split(',');
            }
            if(!pref.isEmpty()){
                existingLoan.RW_Bank_Name__c = pref[0];
                if(pref.size() > 0) existingLoan.RW_Bank_Preference_1__c = pref[0];
                if(pref.size() > 1) existingLoan.RW_Bank_Preference_2__c = pref[1];
                if(pref.size() > 2) existingLoan.RW_Bank_Preference_3__c = pref[2];
                existingLoan.RW_Loan_Record_Status__c = 'Loan Process Initiated';
                existingLoan.Loan_Record_Sub_Status__c = '';
                existingLoan.RW_Reason__c = '';
            	existingLoan.RW_Loan_Closure_Date__c = null;
            }
        }
    }
}