public class LoanDisbTrgHandler {
	
    // Added By Dolly
   public static void calculateConnectorFees(List<Loan_Disbursement_Details__c> newList,
                                          Map<Id, Loan_Disbursement_Details__c> oldMap) {

    Set<Id> loanIds = new Set<Id>();

    for (Loan_Disbursement_Details__c ld : newList) {
        // INSERT case
        if (oldMap == null) {
            if (ld.Loan__c != null && ld.Disbursement_Amount__c != null && ld.Disbursement_Date__c!=null) {
                loanIds.add(ld.Loan__c);
            }
        }
        // UPDATE case → only if Disbursement_Amount__c changed
        else {
            Loan_Disbursement_Details__c oldRec = oldMap.get(ld.Id);
            if (ld.Loan__c != null && ld.Disbursement_Date__c!=null && ld.Disbursement_Amount__c != null && ld.Disbursement_Amount__c != oldRec.Disbursement_Amount__c) {
                loanIds.add(ld.Loan__c);
            }
        }
    }
    if (loanIds.isEmpty()) return;

    // Step 1: Fetch Loans with Project + Bank
    Map<Id, Loan__c> loanMap = new Map<Id, Loan__c>([ SELECT Id, RW_Bank_Preference_1__c, RW_Project_Name__c,RW_Project_Name__r.RDS_Company_Code__c
                                                      FROM Loan__c WHERE Id IN :loanIds and Home_Loan_Taken_From__c = 'Runwal']);

    // Step 2: Collect Legal Entities & Banks (bank is text field)
    Set<Id> legalEntityIds = new Set<Id>();
    Set<String> bankNames = new Set<String>();

    for (Loan__c loanRec : loanMap.values()) {
        if (loanRec.RW_Project_Name__c != null && loanRec.RW_Project_Name__r.RDS_Company_Code__c != null) {
            legalEntityIds.add(loanRec.RW_Project_Name__r.RDS_Company_Code__c);
        }
        if (loanRec.RW_Bank_Preference_1__c != null) {
            bankNames.add(loanRec.RW_Bank_Preference_1__c);
        }
    }

    if (legalEntityIds.isEmpty() || bankNames.isEmpty()) return;

    // Step 3: Fetch APF slabs (Legal Entities + Bank Names)
    Map<String, List<APF__c>> apfMap = new Map<String, List<APF__c>>();
    for (APF__c slab : [SELECT Id, Minimum_Threshold__c, Maximum_Threshold__c, Payout_Rate__c, Legal_Entity__c, RW_Bank_Name__c,Net_Gross__c ,Start_Date__c,End_Date__c
                        FROM APF__c WHERE Legal_Entity__c IN :legalEntityIds AND RW_Bank_Name__c IN :bankNames AND Net_Gross__c = 'Net']) {
        String key = slab.Legal_Entity__c + '_' + slab.RW_Bank_Name__c;
        if (!apfMap.containsKey(key)) {
            apfMap.put(key, new List<APF__c>());
        }
        apfMap.get(key).add(slab);
    }

    // Step 4: Match APF slab and calculate fee
    Decimal oneCR = 10000000;
    for (Loan_Disbursement_Details__c ld : newList) {
        Loan__c loanRec = loanMap.get(ld.Loan__c);
        if (loanRec!=null && loanRec.RW_Project_Name__r.RDS_Company_Code__c != null && loanRec.RW_Bank_Preference_1__c != null){
        	String key = loanRec.RW_Project_Name__r.RDS_Company_Code__c + '_' + loanRec.RW_Bank_Preference_1__c;
        	List<APF__c> slabs = apfMap.get(key);
        	if (slabs == null) continue;
        	List<APF__c> matches = new List<APF__c>();
            for (APF__c slab : slabs) {
                if(slab.Start_Date__c <= ld.Disbursement_Date__c && slab.End_Date__c >= ld.Disbursement_Date__c){
                Decimal minAmt = (slab.Minimum_Threshold__c != null) ? slab.Minimum_Threshold__c * oneCR : null;
                Decimal maxAmt = (slab.Maximum_Threshold__c != null) ? slab.Maximum_Threshold__c * oneCR : null;
            
                Boolean matchesMin = (minAmt == null || ld.Disbursement_Amount__c >= minAmt);
                Boolean matchesMax = (maxAmt == null || ld.Disbursement_Amount__c < maxAmt);
                if (matchesMin && matchesMax) {
                    ld.APF__c = slab.Id;
                    system.debug('ld.APF__c---->'+ld.APF__c);
                    ld.Connector_Fee__c = ld.Disbursement_Amount__c * (slab.Payout_Rate__c / 100);
                    system.debug('ld.APF__c---->'+ld.Connector_Fee__c);
                    ld.Payout_On__c = 'Disbursement Amount';
                    system.debug('ld.APF__c---->'+ld.Payout_On__c);
                    break;
                }
            }
        }
    }
}
}
    
    // Added by Aditya
    public static void handleSanctionCase(List<Loan_Disbursement_Details__c> newList,Map<Id, Loan_Disbursement_Details__c> oldMap){
        
        Map<Id,Loan_Disbursement_Details__c> mapOfLoanAndFirstDisb = new Map<Id,Loan_Disbursement_Details__c>();
        for(Loan_Disbursement_Details__c disbObj: newList){
            if(disbObj.Disbursement_Type__c == 'First Disbursement'){
                if (oldMap == null) {
                    if (disbObj.Loan__c != null) {
                        mapOfLoanAndFirstDisb.put(disbObj.Loan__c,disbObj);
                    }
                }
                else {
                    Loan_Disbursement_Details__c oldRec = oldMap.get(disbObj.Id);
                    if (disbObj.Loan__c != null && disbObj.Disbursement_Type__c != oldRec.Disbursement_Type__c) {
                        mapOfLoanAndFirstDisb.put(disbObj.Loan__c,disbObj);
                    }
                }
            }
        }
        if(mapOfLoanAndFirstDisb!=null){
            LoanConnectorFeeCalculation.updateAPFOnLoanForSanctionAmount(mapOfLoanAndFirstDisb);
        }
    }

    public static void afterDelete(Map<Id,Loan_Disbursement_Details__c> oldDisbMap){
        List<Loan__c> loansToUpdate = new List<Loan__c>();
        List<String> loanIds = new List<String>();
        for(Loan_Disbursement_Details__c ds : oldDisbMap.values()){
            loanIds.add(ds.Loan__c);
        }
        Map<Id,Loan__c> loanMap = new Map<Id,Loan__c>([SELECT Id FROM Loan__c WHERE Id =: loanIds]);
        for(Loan_Disbursement_Details__c dis : oldDisbMap.values()){
            if(dis.Disbursement_Type__c == 'First Disbursement'){
                loanMap.get(dis.Loan__c).RW_First_Disbursement_Amount__c = null;
                loanMap.get(dis.Loan__c).RW_First_Disbursement_Date__c = null;   
                loanMap.get(dis.Loan__c).RW_First_Disbursement_Status__c = null; 
                loanMap.get(dis.Loan__c).First_Disbursement_sub_status__c = null; 
                loanMap.get(dis.Loan__c).RW_First_Disbursement_Received__c = null;
                loanMap.get(dis.Loan__c).Connector_Fee_with_GST__c = null;
                loansToUpdate.add(loanMap.get(dis.Loan__c));
            }
        }
        update loansToUpdate;
    }
}