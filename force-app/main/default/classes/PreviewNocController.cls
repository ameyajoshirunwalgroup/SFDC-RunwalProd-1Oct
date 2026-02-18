public class PreviewNocController {
    public RW_NOC_Template__c noc{get;set;}

    public PreviewNocController() {

        noc = [SELECT id,name,RW_Template__c,RW_Keyword__c,RW_Runwal_Logo__c from RW_NOC_Template__c WHERE Id = : ApexPages.currentpage().getParameters().get('id')];

    }
    
}