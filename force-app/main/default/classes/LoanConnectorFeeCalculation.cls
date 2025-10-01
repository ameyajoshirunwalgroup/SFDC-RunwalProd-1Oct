public class LoanConnectorFeeCalculation {
    public static void updateAPFOnLoanForSanctionAmount(Map<Id,Loan_Disbursement_Details__c> mapOfLoanAndFirstDisb){
        Set<Id> loanId = new Set<Id>();
        if(!mapOfLoanAndFirstDisb.KeySet().isEmpty()){
            loanId.addAll(mapOfLoanAndFirstDisb.KeySet());
        }
        if(loanId.isEmpty()){return;}
        List<Loan__c> loanToUpdate = new List<Loan__c>();
        List<Loan__c> loanList = [Select Id, RW_Bank_Preference_1__c, RW_Project_Name__c, 
                                  RW_Project_Name__r.RDS_Company_Code__c,RW_Project_Name__r.RDS_Company_Code__r.Name,Final_Sanction_Amount__c, RW_Sanction_Amount__c,
                                  RW_Sanction_Date__c, RW_APF__c, Sanction_Connector_Fee__c
                                  from Loan__c where Id IN: loanId and RW_Sanction_Amount__c!=null and Home_Loan_Taken_From__c = 'Runwal'];
        Set<String> bankName = new Set<String>();
        Set<Id> LegalEntityId = new Set<Id>();
        for(Loan__c loanObj: loanList){
            if(loanObj.RW_Bank_Preference_1__c!=null){
                bankName.add(loanObj.RW_Bank_Preference_1__c);
            }
            if(loanObj.RW_Project_Name__r.RDS_Company_Code__c!=null){
                LegalEntityId.add(loanObj.RW_Project_Name__r.RDS_Company_Code__c);
            }
        }
        List<APF__c> apfList = [Select id,Legal_Entity__c,RW_Bank_Name__c, Start_Date__c, End_Date__c, Minimum_Threshold__c, Payout_Rate__c,
                                Maximum_Threshold__c from APF__c where 
                                Legal_Entity__c IN: LegalEntityId and RW_Bank_Name__c IN: bankName and Net_Gross__c = 'Gross'];
        Map<String, List<APF__c>> mapLegalEntityAndBankForAPF = new Map<String, List<APF__c>>();
        for(APF__c apfObj: apfList){
            if(apfObj.Legal_Entity__c!=null && apfObj.RW_Bank_Name__c!=null){
                String name = apfObj.Legal_Entity__c + '-' + apfObj.RW_Bank_Name__c;
                if(!mapLegalEntityAndBankForAPF.containsKey(name)){
                    mapLegalEntityAndBankForAPF.put(name,new List<APF__c>());
                }
                mapLegalEntityAndBankForAPF.get(name).add(apfObj);
            }
            
        }
        Decimal oneCR = 10000000;
        for(Loan__c loanObj: loanList){
            if(loanObj.RW_Bank_Preference_1__c!=null && loanObj.RW_Project_Name__r.RDS_Company_Code__c!=null){
                String name = loanObj.RW_Project_Name__r.RDS_Company_Code__c + '-' + loanObj.RW_Bank_Preference_1__c;
                if(mapLegalEntityAndBankForAPF.containsKey(name)){
                    for(APF__c apfObj: mapLegalEntityAndBankForAPF.get(name)){
                        if(apfObj.Start_Date__c <= loanObj.RW_Sanction_Date__c && apfObj.End_Date__c >= loanObj.RW_Sanction_Date__c){
                            if((apfObj.Minimum_Threshold__c * oneCR) <= loanObj.RW_Sanction_Amount__c && (apfObj.Maximum_Threshold__c * oneCR) > loanObj.RW_Sanction_Amount__c){
                                loanObj.RW_APF__c = apfObj.Id;
                                if(apfObj.Payout_Rate__c!=null){
                                	loanObj.Sanction_Connector_Fee__c = (apfObj.Payout_Rate__c * loanObj.RW_Sanction_Amount__c)/100;
                                }
                                if(mapOfLoanAndFirstDisb.containsKey(loanObj.Id)){
                                    if(loanObj.RW_APF__c!=null){
                                    	mapOfLoanAndFirstDisb.get(loanObj.Id).APF__c = loanObj.RW_APF__c;
                                    }
                                    if(loanObj.Sanction_Connector_Fee__c!=null){
                                    	mapOfLoanAndFirstDisb.get(loanObj.Id).Connector_Fee__c = loanObj.Sanction_Connector_Fee__c;
                                        mapOfLoanAndFirstDisb.get(loanObj.Id).Payout_On__c = 'Sanction Amount';
                                    }
                                }
                                loanToUpdate.add(loanObj);
                                break;
                            }
                        }
                    }
                }
            }
        }
        if(!loanToUpdate.isEmpty()){
            update loanToUpdate;
        }
        
    }
}