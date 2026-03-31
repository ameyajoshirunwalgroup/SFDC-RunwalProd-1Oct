public with sharing class GreetingCallController {

    /*@AuraEnabled
    public static Map<String, Object> getGreetingInitialData(Id oppId) {
        Map<String, Object> result = new Map<String, Object>();
        
        // Fetch Booking Details
        result.put('opportunityData', [SELECT Id ,Name,Project_Name__c,Unit_No__c,RW_Project_Unit__r.Type_Label__c,RW_Email__c,RW_Mobile_No__c,
                                       RW_Project_Unit__r.TowerName__r.Name,RW_Project_Unit__r.RW_Floor__c,Sales_Manager_User__c, RW_Agreement_Value__c,
                                       Sales_Manager_User__r.Name,RW_Booking_Date_Opp__c,Source_of_Funding__c
                                   FROM Opportunity WHERE Id = :oppId]);
        result.put('poc', [SELECT Id, Owner.Name
                                   FROM Greeting_Call__c WHERE Id = :oppId]);

        // Fetch Previous Remarks Blob for pre-population
        List<RW_Welcome_Call_Remarks__c> prev = [SELECT RW_Remarks__c FROM RW_Welcome_Call_Remarks__c 
                                              WHERE Greeting_Call__r.Opportunity__c = :oppId 
                                              ORDER BY CreatedDate DESC LIMIT 1];
        
        result.put('previousRemarksBlob', prev.isEmpty() ? null : prev[0].RW_Remarks__c);
        System.debug('Print result---->'+result);
        return result;
    }*/
    
    @AuraEnabled(cacheable=true)
    public static InitialDataWrapper getGreetingInitialData(Id oppId) {
        InitialDataWrapper wrapper = new InitialDataWrapper();
        
        // Fetch Opportunity Data
        wrapper.opportunityData = [SELECT Id ,Name,Project_Name__c,Unit_No__c,RW_Project_Unit__r.Type_Label__c,RW_Email__c,RW_Mobile_No__c,RW_Project_Unit__r.Name,Blocked_Date__c,Blocking_Amount_Received__c,
                                       RW_Project_Unit__r.TowerName__r.Name,RW_Project_Unit__r.RW_Floor__c,Sales_Manager_User__c, RW_Agreement_Value__c,
                                       Sales_Manager_User__r.Name,RW_Booking_Date_Opp__c,Source_of_Funding__c FROM Opportunity WHERE Id = :oppId];
        
        List<Greeting_Call__c> greetingCalls = [SELECT Mode_of_funding__c,Bank_Preference_1__c,Bank_Preference_2__c,Bank_Preference_3__c FROM Greeting_Call__c 
                                              WHERE Opportunity__c = :oppId 
                                              ORDER BY CreatedDate DESC LIMIT 1];

        List<Loan__c> loanRecordList = [SELECT Mode_of_funding__c,RW_Bank_Preference_1__c,RW_Bank_Preference_2__c,RW_Bank_Preference_3__c FROM Loan__c 
                                              WHERE RW_Opportunity__c = :oppId 
                                              ORDER BY CreatedDate DESC LIMIT 1];

        List<RW_Welcome_Call_Remarks__c> prev = [SELECT RW_Remarks__c FROM RW_Welcome_Call_Remarks__c 
                                              WHERE Greeting_Call__r.Opportunity__c = :oppId 
                                              ORDER BY CreatedDate DESC LIMIT 1];
        if(!loanRecordList.isEmpty()){
            wrapper.loanRecordData = loanRecordList;
        }
        if(!greetingCalls.isEmpty()){
            wrapper.greetingCallData = greetingCalls;
        }
        if(!prev.isEmpty() && prev[0].RW_Remarks__c!=null){
            wrapper.previousRemarksBlob = prev[0].RW_Remarks__c;
        }
        // Fetch Picklist Options Dynamically
        wrapper.fundingOptions = getPicklistOptions('Greeting_Call__c', 'Mode_of_funding__c');
        wrapper.bankPreferenceOptions = getPicklistOptions('Greeting_Call__c', 'Bank_Preference_1__c');
        
        return wrapper;
    }

    @AuraEnabled
    public static void processGreetingCall(Id oppId, String status, String reason, String remarksBlob, Map<String, String> fieldValues) {
        // Create/Update Greeting Call record
        Greeting_Call__c gc = new Greeting_Call__c();
        gc.Opportunity__c = oppId;
        gc.Status__c = status;
        gc.External_ID__c  = oppId;
        gc.Reason__c = reason; // Mandatory for Hold/Reject
        if (fieldValues != null) {
            if (fieldValues.containsKey('FundingType')) gc.Mode_of_funding__c = fieldValues.get('FundingType');
            if (fieldValues.containsKey('BankPreference1')) gc.Bank_Preference_1__c = fieldValues.get('BankPreference1');
            if (fieldValues.containsKey('BankPreference2')) gc.Bank_Preference_2__c = fieldValues.get('BankPreference2');
            if (fieldValues.containsKey('BankPreference3')) gc.Bank_Preference_3__c = fieldValues.get('BankPreference3');
            if (fieldValues.containsKey('ApplicantName1')) gc.Primary_Applicant_Name__c = fieldValues.get('ApplicantName1');
            if (fieldValues.containsKey('EmailAddresses1')) gc.Email__c = fieldValues.get('EmailAddresses1')!= 'N/A'? fieldValues.get('EmailAddresses1'): null;
            if (fieldValues.containsKey('MobileNo1')) gc.Mobile_No__c = fieldValues.get('MobileNo1')!='N/A' ? fieldValues.get('MobileNo1'): null;
            if (fieldValues.containsKey('ProjectName')) gc.Project_Name__c = fieldValues.get('ProjectName')!='N/A'? fieldValues.get('ProjectName'): null;
            if (fieldValues.containsKey('FlatNo')) gc.Flat_No__c = fieldValues.get('FlatNo')!='N/A'? fieldValues.get('FlatNo'): null;
            if (fieldValues.containsKey('AgreementValue')) gc.Agreement_Value__c = fieldValues.get('AgreementValue')!='N/A'?Decimal.valueOf(fieldValues.get('AgreementValue')): null;
            if (fieldValues.containsKey('BlockDate')) gc.Block_Date__c = fieldValues.get('BlockDate')!='N/A'? Date.valueOf(fieldValues.get('BlockDate')): null;
            if (fieldValues.containsKey('SalesManager')) gc.Sales_Manager__c = fieldValues.get('SalesManager')!='N/A'?fieldValues.get('SalesManager'): null;
            if (fieldValues.containsKey('BolckingAmount')) gc.Blocking_Amount__c = fieldValues.get('BolckingAmount')!= 'N/A' ? Decimal.valueOf(fieldValues.get('BolckingAmount')) : null;
            // Add other mappings here if needed
        }
        upsert gc External_ID__c;

        // Save serialized blob to Remarks object
        RW_Welcome_Call_Remarks__c wcr = new RW_Welcome_Call_Remarks__c();
        wcr.RW_Remarks__c = remarksBlob;
        wcr.Greeting_Call__c = gc.Id; 
        insert wcr;
    }
    
    private static List<Map<String, String>> getPicklistOptions(String objName, String fieldName) {
        List<Map<String, String>> options = new List<Map<String, String>>();
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(fieldName).getDescribe();
        for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
            if (entry.isActive()) {
                options.add(new Map<String, String>{'label' => entry.getLabel(), 'value' => entry.getValue()});
            }
        }
        return options;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getLatestRemarks(Id recordId) {
        // Querying the latest record based on CreatedDate
        List<RW_Welcome_Call_Remarks__c> remarks = [
            SELECT RW_Remarks__c 
            FROM RW_Welcome_Call_Remarks__c 
            WHERE Greeting_Call__c = :recordId // Replace with actual lookup field name
            ORDER BY CreatedDate DESC 
            LIMIT 1
        ];
        
        return (!remarks.isEmpty()) ? remarks[0].RW_Remarks__c : null;
    }
    
    public class InitialDataWrapper {
        @AuraEnabled public List<Opportunity> opportunityData;
        @AuraEnabled public List<Greeting_Call__c> greetingCallData;
        @AuraEnabled public List<Loan__c> loanRecordData;
        @AuraEnabled public List<Map<String, String>> fundingOptions;
        @AuraEnabled public List<Map<String, String>> bankPreferenceOptions;
        @AuraEnabled public String previousRemarksBlob;
    }
}