public class DynamicEmailService {

    public static String generateEmailBody(Id recordId, String cmdtName, String messageType) {
        
        // 1. Fetch the template
        Post_Sales_App_Notifications__mdt templateMdt = [
            SELECT Email_Message__c,Email_Subject__c 
            FROM Post_Sales_App_Notifications__mdt 
            WHERE DeveloperName = :cmdtName 
            LIMIT 1
        ];
        //String emailBody = templateMdt.Email_Message__c;
        String message;
        if(messageType == 'Subject'){
            message = templateMdt.Email_Subject__c;
        }else if(messageType == 'Body'){
            message = templateMdt.Email_Message__c;
        }

        // 2. Extract dynamic parameters using Regex
        Set<String> fieldsToQuery = new Set<String>();
        Map<String, String> labelReplacements = new Map<String, String>();
        
        Pattern mergeFieldPattern = Pattern.compile('\\{!(.*?)\\}');
        //Matcher matcher = mergeFieldPattern.matcher(emailBody);
        Matcher matcher = mergeFieldPattern.matcher(message);

        while (matcher.find()) {
            String mergeContent = matcher.group(1); // e.g., "Account.Name" or "$Label.Greeting"
            
            // 3. Separate Custom Labels from SObject Fields
            if (mergeContent.startsWithIgnoreCase('$Label.')) {
                String labelName = mergeContent.substringAfter('.');
                
                try {
                    // System.Label.get(namespace, labelName, language)
                    // Empty string '' assumes the local namespace
                    String labelValue = System.Label.get('', labelName, UserInfo.getLanguage());
                    labelReplacements.put('{!' + mergeContent + '}', labelValue);
                } catch (Exception e) {
                    // If the label is misspelled or doesn't exist, replace with blank
                    labelReplacements.put('{!' + mergeContent + '}', ''); 
                }
            } else {
                // It's a database field, add it to the SOQL list
                fieldsToQuery.add(mergeContent);
            }
        }

        // 4. Replace Custom Labels in the body right away
        for (String labelMergeTag : labelReplacements.keySet()) {
            //emailBody = emailBody.replace(labelMergeTag, labelReplacements.get(labelMergeTag));
            message = message.replace(labelMergeTag, labelReplacements.get(labelMergeTag));
        }

        // If there are no SObject fields to query, return the body now
        if (fieldsToQuery.isEmpty()) {
            //return emailBody;
            System.debug('message: ' + message);
            return message;
        }

        // 5. Build & Execute Dynamic SOQL for the remaining SObject fields
        String sObjectName = recordId.getSObjectType().getDescribe().getName();
        List<String> fieldList = new List<String>(fieldsToQuery);
        String query = 'SELECT ' + String.join(fieldList, ', ') + 
                       ' FROM ' + sObjectName + 
                       ' WHERE Id = :recordId';

        SObject record = Database.query(query);

        // 6. Replace SObject fields in the template
        for (String fieldPath : fieldsToQuery) {
            String mergeTag = '{!' + fieldPath + '}';
            String fieldValue = getFieldValue(record, fieldPath);
            //emailBody = emailBody.replace(mergeTag, fieldValue == null ? '' : fieldValue);
            message = message.replace(mergeTag, fieldValue == null ? '' : fieldValue);
        }
		System.debug('message: ' + message);
        //return emailBody;
        return message;
    }

    /**
     * Helper method to dynamically fetch field values (Same as previous step)
     */
    private static String getFieldValue(SObject record, String fieldPath) {
        if (record == null) return '';

        if (fieldPath.contains('.')) {
            List<String> parts = fieldPath.split('\\.');
            SObject parentRecord = record;
            for (Integer i = 0; i < parts.size() - 1; i++) {
                parentRecord = parentRecord.getSObject(parts[i]);
                if (parentRecord == null) return '';
            }
            Object val = parentRecord.get(parts[parts.size() - 1]);
            return val != null ? String.valueOf(val) : '';
        } else {
            Object val = record.get(fieldPath);
            return val != null ? String.valueOf(val) : '';
        }
    }
    
    
    
    //Use this working method
    public static String processTemplate(String templateBody, SObject record) {
        if (String.isBlank(templateBody)) return '';
        
        // Regex to find anything inside {! }
        Pattern p = Pattern.compile('\\{!\\s*(.*?)\\s*\\}');
        Matcher m = p.matcher(templateBody);
        
        String finalContent = templateBody;
        
        while (m.find()) {
            String fullTag = m.group(0); // {!$Label.Support_Email}
            String varName = m.group(1); // $Label.Support_Email
            String value = '';
            
            try {
                if (varName.startsWith('$Label.')) {
                    // Dynamic Label Fetching
                    String labelApiName = varName.substringAfter('.');
                    value = System.Label.get('', labelApiName);
                } else if (varName.contains('.')) {
                    value = getRelatedFieldValue(record, varName);
                } else {
                    // Dynamic Field Fetching from the Record
                    value = String.valueOf(record.get(varName));
                }
            } catch (Exception e) {
                // If field/label doesn't exist, replace with empty string
                value = '';
            }
            
            finalContent = finalContent.replace(fullTag, value != null ? value : '');
        }
        return finalContent;
    }
    
    private static String getRelatedFieldValue(SObject record, String fieldPath) {
        List<String> parts = fieldPath.split('\\.');
        SObject tempObj = record;

        for (Integer i = 0; i < parts.size() - 1; i++) {
            if (tempObj == null) return '';
            tempObj = tempObj.getSObject(parts[i]);
        }
        
        return (tempObj == null) ? '' : String.valueOf(tempObj.get(parts[parts.size() - 1]));
    }
}