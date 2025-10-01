public class HomeLoanLadder implements Schedulable {
    
    
    
    public void execute(SchedulableContext SC){
        ladder();
    }
	
    public static void ladder(){
        System.debug('--ladder--');
        List<Loan_Disbursement_Details__c> disbList = [SELECT Id, Name, Disbursement_Amount__c, Loan__c, Loan__r.RW_APF__c, Disbursement_Type__c
                                                       FROM Loan_Disbursement_Details__c WHERE CreatedDate = THIS_MONTH ];
        
        List<String> apfIds  = new List<String>();
        Map<String, List<Loan_Disbursement_Details__c>> apfDisbMap = new Map<String, List<Loan_Disbursement_Details__c>>();
        for(Loan_Disbursement_Details__c disb : disbList){
            apfIds.add(disb.Loan__r.RW_APF__c);
        }
        for(String apfId : apfIds){
            List<Loan_Disbursement_Details__c> disbs = new List<Loan_Disbursement_Details__c>();
            for(Loan_Disbursement_Details__c disb : disbList){
                if(disb.Loan__r.RW_APF__c == apfId){
                    disbs.add(disb);
                }
            } 
            apfDisbMap.put(apfId, disbs);
        }
        
        List<Home_Loan_Ladder__c> loanLadder = [SELECT Id, Name, Gross_Payout__c, Amount_Range_From__c, Amount_Range_To__c, APF__c
                                                FROM Home_Loan_Ladder__c WHERE APF__r.Ladder_Scheme__c = 'Yes'];
        
        Map<String, List<Home_Loan_Ladder__c>> apfLadderMap = new Map<String, List<Home_Loan_Ladder__c>>();
        for(String aId : apfIds){
            List<Home_Loan_Ladder__c> lads = new List<Home_Loan_Ladder__c>();
            for(Home_Loan_Ladder__c lad : loanLadder){
                if(lad.APF__c == aId){
                    lads.add(lad);
                }
            }
            apfLadderMap.put(aId, lads);
        }
        
        Map<String, Decimal> apfVsDisbAmt = new Map<String, Decimal>();
        for(String apf : apfIds){
            Decimal totalDisbursedAmount = 0;    
            for(Loan_Disbursement_Details__c disb : apfDisbMap.get(apf)){
                totalDisbursedAmount += disb.Disbursement_Amount__c;
            }
            apfVsDisbAmt.put(apf,totalDisbursedAmount);
        }
        
        Map<String, Decimal> apfLadPercentage = new Map<String, Decimal>();
        for(String apf : apfIds){
            Decimal laddedPercentage;
            for(Home_Loan_Ladder__c lad : apfLadderMap.get(apf)){
                if(apfVsDisbAmt.get(apf) >= lad.Amount_Range_From__c && apfVsDisbAmt.get(apf) < lad.Amount_Range_To__c){
                    laddedPercentage = lad.Gross_Payout__c;
                }
            }
            apfLadPercentage.put(apf, laddedPercentage);
        }
        
        List<Loan_Disbursement_Details__c> disbToUpdate = new List<Loan_Disbursement_Details__c>();
        for(Loan_Disbursement_Details__c disb : disbList){
            if(disb.Disbursement_Type__c == 'First Disbursement' && apfLadPercentage.get(disb.Loan__r.RW_APF__c) != null){
                disb.Connector_Fee_Ladder__c = apfLadPercentage.get(disb.Loan__r.RW_APF__c);
                disb.Ladder_Applied__c = true;
                System.debug('disb.Ladder_Applied__c: ' + disb.Ladder_Applied__c);
                System.debug('disb.Connector_Fee_Ladder__c: ' + disb.Connector_Fee_Ladder__c);
                disbToUpdate.add(disb);
            }
        }
        update disbToUpdate;
    }
    
}