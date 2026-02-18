global class FullCopySandboxCreationBatch implements Database.Batchable<SObject>, Database.Stateful {
    private List<String> sObjectList;
    private String sObjectType;
    //private String SuffixEmail = '.invalid';
    private Integer PrefixPhone = 100000;
    private Integer currentIndex;
    private String countryCodeField = null;
    
    global FullCopySandboxCreationBatch(List<String> sObjectList, Integer currentIndex) {
        this.sObjectList = sObjectList;
        this.currentIndex = currentIndex;
        this.sObjectType = sObjectList[currentIndex];
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        SObjectType objType = Schema.getGlobalDescribe().get(sObjectType);
        Map<String, Schema.SObjectField> fieldMap = objType.getDescribe().fields.getMap();
        String query = 'SELECT Id';
        
        for (String fieldName : fieldMap.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
            if (fieldDescribe.isAccessible() && fieldDescribe.isUpdateable()) {
                if (fieldMap.get(fieldName).getDescribe().getType() == Schema.DisplayType.Email) {
                    query += ', ' + fieldName;
                }
                if (fieldMap.get(fieldName).getDescribe().getType() == Schema.DisplayType.Phone) {
                    query += ', ' + fieldName;
                }
            }
        }
        
        query += ' FROM ' + sObjectType /*+ ' Where RW_Applicant1_Email_Address__c != null AND (NOT (RW_Applicant1_Email_Address__c LIKE \'%.invalid%\'))'*/;
        system.debug(query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        List<ERP_Integration_Log__c> APILogInsert = new List<ERP_Integration_Log__c>();
        SObjectType objType = Schema.getGlobalDescribe().get(sObjectType);
        Map<String, Schema.SObjectField> fieldMap = objType.getDescribe().fields.getMap();
        Set<String> emailFields = new Set<String>();
        Set<String> phoneFields = new Set<String>();
        
        for (String fieldName : fieldMap.keySet()) {
            Schema.DisplayType fieldType = fieldMap.get(fieldName).getDescribe().getType();
            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
            if (fieldDescribe.isAccessible() && fieldDescribe.isUpdateable()) {
                if (fieldType == Schema.DisplayType.Email) {
                    emailFields.add(fieldName);
                } else if (fieldType == Schema.DisplayType.Phone) {
                    phoneFields.add(fieldName);
                }
            }
        }
        for (SObject record : scope) {
            for (String fieldName : emailFields) {
                String SuffixEmail = '.invalid';
                if (fieldMap.get(fieldName).getDescribe().getType() == Schema.DisplayType.Email) {
                    String TempEmail = (String)record.get(fieldName);
                    if(String.isNotBlank(TempEmail)){
                        list<string> emailCopy = TempEmail.split('@');
                        //system.debug('email'+TempEmail.split('@'));
                        //system.debug('email'+emailCopy[0]);
                        if(emailCopy[0].length()>4){
                            String newLocalPart = 'xxxx';
                            //system.debug('Inside length > 4');
                            //system.debug('email'+ newLocalPart + TempEmail.right(TempEmail.length()-4)+SuffixEmail);
                            record.put(fieldName, newLocalPart + TempEmail.right(TempEmail.length()-4)+SuffixEmail);
                        }else {
                            //system.debug('Inside length <= 4');
                            String newLocalPart = '';
                            for(Integer i = 0; i < emailCopy[0].length(); i++) {
                                newLocalPart += 'x';
                            }
                            String newEmail = newLocalPart + '@' + emailCopy[1];
                            //system.debug('modified email for short local part: ' + newEmail);
                            record.put(fieldName, newEmail + SuffixEmail);
                        }
                    }
                }
            }
            
            for (String fieldName : phoneFields) {
                if (fieldMap.get(fieldName).getDescribe().getType() == Schema.DisplayType.Phone) {
                    String TempPhone = (String)record.get(fieldName);
                    //String countryCode = (countryCodeField != null) ? (String) record.get(countryCodeField) : '';
                     /*if(String.isNotBlank(TempPhone) && TempPhone.length() > 6 && countryCode == '+91' && TempPhone.startswith('6') ){
                        record.put(fieldName, '1' + TempPhone.substring(1));
                         PrefixPhone++;
                     } else if(String.isNotBlank(TempPhone) && TempPhone.length() > 6 && countryCode == '+91' && TempPhone.startswith('7')){
                         record.put(fieldName, '2' + TempPhone.substring(1));
                         PrefixPhone++;
                     } else if(String.isNotBlank(TempPhone) && TempPhone.length() > 6 && countryCode == '+91' && TempPhone.startswith('8')){
                         record.put(fieldName, '3' + TempPhone.substring(1));
                         PrefixPhone++;
                     } else if(String.isNotBlank(TempPhone) && TempPhone.length() > 6 && countryCode == '+91' && TempPhone.startswith('9')){
                         record.put(fieldName, '4' + TempPhone.substring(1));
                         PrefixPhone++;
                     }*/
                    
                    if(String.isNotBlank(TempPhone) && TempPhone.length() > 6){
                        record.put(fieldName, PrefixPhone + TempPhone.substring(6));
                         PrefixPhone++;
                     }
                }
            }
        }
        
        if (!scope.isEmpty()) {
            Database.SaveResult[] updateResults = Database.update(scope,false);
            for (Integer i = 0; i < updateResults.size(); i++) {
                system.debug('updateResults'+updateResults);
                if (!updateResults[i].isSuccess()) {
                    for (Database.Error error : updateResults[i].getErrors()) {                        
                        ERP_Integration_Log__c api = new ERP_Integration_Log__c();
                        //api.Name = sObjectType;
                        api.API_Name__c = 'Full Copy';
                        api.Request__c = scope[i].Id;
                        api.Response__c = error.getStatusCode() + ' - ' + error.getMessage();
                        APILogInsert.add(api);
                        system.debug('api'+api);
                         system.debug('APILogInsert'+APILogInsert);
                    }
                }
            }
            if(!APILogInsert.isEmpty()){
                system.debug('APILogInsert'+APILogInsert);
                Database.insert(APILogInsert,false);
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        if (currentIndex + 1 < sObjectList.size()) {
            FullCopySandboxCreationBatch nextBatch = new FullCopySandboxCreationBatch(sObjectList, currentIndex + 1);
            Database.executeBatch(nextBatch,500);
        } else {
            /*Integer currentIndex = 0;
list<String> sObjectList = new list<string>{'Applicant_Details__c'};
FullCopySandboxCreationBatch nextBatch = new FullCopySandboxCreationBatch(sObjectList, currentIndex);
Database.executeBatch(nextBatch,500);*/
            System.debug('All batch processes completed.');
        }
    }
}