global without sharing class CustomerPotalFaqsControler {
    
    @AuraEnabled
    public static list<RW_FAQ__c> lstFetchFaqs() {
        return [SELECT Id,CreatedDate,RW_Question__c,RW_Answer__c,RW_Active__c,RW_Order__c FROM RW_FAQ__c WHERE RW_Active__c = false ORDER BY RW_Order__c ASC];     
        
    }
    
    @AuraEnabled
    public static list<RW_FAQ__c> englishFaq() {
        return [SELECT Id,CreatedDate,RW_Question__c,RW_Answer__c,RW_Active__c,RW_Order__c FROM RW_FAQ__c WHERE RW_Active__c = true AND Language__c = 'English' ORDER BY RW_Order__c ASC];     
        
    }
    
    @AuraEnabled
    public static list<RW_FAQ__c> hindiFaq() {
        return [SELECT Id,CreatedDate,RW_Question__c,RW_Answer__c,RW_Active__c,RW_Order__c FROM RW_FAQ__c WHERE RW_Active__c = true AND Language__c = 'Hindi' ORDER BY RW_Order__c ASC];     
        
    }
    
    @AuraEnabled
    public static list<RW_FAQ__c> marathiFaq() {
        return [SELECT Id,CreatedDate,RW_Question__c,RW_Answer__c,RW_Active__c,RW_Order__c FROM RW_FAQ__c WHERE RW_Active__c = true AND Language__c = 'Marathi' ORDER BY RW_Order__c ASC];     
        
    }
}