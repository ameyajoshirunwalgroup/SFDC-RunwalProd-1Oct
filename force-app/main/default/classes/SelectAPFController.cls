public class SelectAPFController {
    
	@AuraEnabled
    public static List <APF__c> fetchApfRecords(String code) {
        
        List<APF__c> apfList = [SELECT Id, Name, Connector_Code__c, RW_Project__c, Project_Name__c, Company__c, RW_Bank_Name__c,
                                Connector_Fee__c, Connector_Fee_for_Residential__c, Connector_Fee_for_Commercial__c
                                FROM APF__c WHERE Connector_Code__c =: code];
        return apfList;
    }
    
    
    @AuraEnabled
    public static void updateApfOnLoan(String apfId, String loanId, String code) {
        
        Loan__c ln = new Loan__c();
        ln.Id = loanId;
        ln.RW_APF__c = apfId;
        ln.Connector_Code__c = code;
        update ln;
        
    }
}