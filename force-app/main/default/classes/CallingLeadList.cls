public class CallingLeadList {

    @AuraEnabled
    public static List<Lead> leadList(String camp, String status){
        Id userId = UserInfo.getUserId();
        User usr = [SELECT Id, Name FROM User WHERE Id =: userId LIMIT 1];
        List<Lead> leads = new List<Lead>();
        if(status == 'All'){
            leads = [SELECT Id, Name, RW_Project__r.Name, Sales_Team_Calling_status__c FROM Lead WHERE Calling_Campaign__c != null AND
                            Calling_Campaign__c =: camp AND Calling_Closing_SM__c =: usr.Name ORDER BY CreatedDate DESC];
        }else{
            leads = [SELECT Id, Name, RW_Project__r.Name, Sales_Team_Calling_status__c FROM Lead WHERE Calling_Campaign__c != null AND
                            Calling_Campaign__c =: camp AND Sales_Team_Calling_status__c =: status AND Calling_Closing_SM__c =: usr.Name ORDER BY CreatedDate DESC];
        }
        return leads;
    }
    
    @AuraEnabled
    public static List<String> getStatusValues(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Lead.Sales_Team_Calling_status__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.add(p.getLabel());
        }
        return options;
    }
    
    @AuraEnabled
    public static List<String> getCampaignValues(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Lead.Calling_Campaign__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.add(p.getLabel());
        }
        return options;
    }
}