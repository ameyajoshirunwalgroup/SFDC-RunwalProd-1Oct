public with sharing class customerPortalPopup {

    @AuraEnabled(cacheable=true)
    public static Boolean showPopupBasedonProfile(String accountId) {  
        System.debug('accountId: ' + accountId);      
        
        // Query current user's profile name
        User currentUser = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];        
        System.debug('currentUser: ' + currentUser); 

        // Label containing allowed profile names (assumed to be comma-separated)
        //String profileLabel = Label.Data_Gathering;
        String profileLabel = Label.Profile_Completeness;
        System.debug('profileLabel: ' + profileLabel);
        
        // Split the profile label into a list and trim each profile name
        List<String> allowedProfiles = new List<String>();
        for (String profile : profileLabel.split(',')) {
            allowedProfiles.add(profile.trim());
        }
        System.debug('allowedProfiles: ' + allowedProfiles);
        
        // Get the current user's profile name and trim any whitespace
        String currentUserProfileName = currentUser.Profile.Name.trim();
        System.debug('currentUser.Profile.Name: ' + currentUserProfileName);
        
        // Check if the current user's profile is in the allowed profiles list
        if (allowedProfiles.contains(currentUserProfileName)) {
            System.debug('TRUE');
            return TRUE;
        } else {
            System.debug('FALSE');
            return FALSE;
        }
    }


    @AuraEnabled(cacheable=true)
    public static List<Popup_Questions__mdt> getQuestions(String userId, String accountId) {
        System.debug('getQuestions function');
        System.debug('userId :: ' + userId);
        System.debug('accountId :: ' + accountId);
        return [SELECT Id, Object_Name__c, Field_Name__c, Questions__c FROM Popup_Questions__mdt ORDER BY Order__c ASC];
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Map<String, String>> fetchDataForObjectFields(String accountId,List<Popup_Questions__mdt> metadata) {
        System.debug('fetchDataForObjectFields function');  
        Map<String, Map<String, String>> fieldValuesWithType = new Map<String, Map<String, String>>();
        System.debug('accountId::- ' + accountId);
        system.debug('Metadata:-'+metadata);

        for (Popup_Questions__mdt meta : metadata) {
            System.debug('for loop Popup_Questions__mdt: ');  
            String objectName = meta.Object_Name__c;
            String fieldName = meta.Field_Name__c;
            String fieldType = getFieldDataType(objectName, fieldName);

            System.debug('objectName: ' + objectName);
            System.debug('fieldName: ' + fieldName);
            System.debug('fieldType: ' + fieldType);

            if (objectName != null && fieldName != null) {
                System.debug('If loop : objectName != null && fieldName != null ');  
                // Initialize field value and type map
                Map<String, String> fieldValueWithType = new Map<String, String>();

                if (objectName == 'Account') {
                    System.debug(' if loop account: ');  
                    // Query Account object
                    String query = 'SELECT ' + fieldName + ' FROM Account WHERE Id = :accountId LIMIT 1';
                    System.debug('Account query: ' + query);
                    try {
                        List<SObject> results = Database.query(query);
                        System.debug('Account results: ' + results);
                        if (!results.isEmpty()) {
                            System.debug('if results query');
                            SObject record = results[0];
                            System.debug('fieldValue: ' + record.get(fieldName));

                            String fieldValue = '';
                            if (fieldType == 'BOOLEAN') {
                                if (record.get(fieldName) == TRUE) {
                                    fieldValue = 'true';
                                } else if (record.get(fieldName) == FALSE) {
                                    fieldValue = null;
                                }
                            } else {
                                fieldValue = (String)record.get(fieldName);
                            }
                            fieldValueWithType.put('value', fieldValue);
                            fieldValueWithType.put('type', fieldType); // Set field type
                            System.debug('fieldValueWithType: ' + fieldValueWithType);
                        }
                    } catch (Exception e) {
                        System.debug('Error in dynamic query: ' + e.getMessage());
                    }
                } else if (objectName == 'Opportunity') {
                    System.debug('if objectName == opportunity');
                    // Query Opportunity object
                    String query = 'SELECT ' + fieldName + ' FROM Opportunity WHERE AccountId = :accountId AND StageName = \'Unit Booked\' AND Booking__c != null ORDER BY CreatedDate DESC';
                    System.debug('query: ' + query);
                    try {
                        List<SObject> results = Database.query(query);
                        System.debug('results: ' + results);
                        if (!results.isEmpty()) {
                            System.debug('Inside if !results.isEmpty()');
                            for (SObject record : results) {
                                System.debug('for loop sObject record');
                                System.debug('fieldValue: ' + record.get(fieldName));

                                String fieldValue = '';
                                if (fieldType == 'BOOLEAN') {
                                    if (record.get(fieldName) == TRUE) {
                                        fieldValue = 'true';
                                    } else if (record.get(fieldName) == FALSE) {
                                        fieldValue = null;
                                    }
                                } else if (record.get(fieldName) == null) {
                                    fieldValue = null;
                                }

                                fieldValueWithType.put('value', fieldValue);
                                fieldValueWithType.put('type', fieldType); // Set field type
                                System.debug('fieldValueWithType: ' + fieldValueWithType);
                                if (fieldValue == null) {
                                    break; 
                                }
                            }
                        }
                    } catch (Exception e) {
                        System.debug('Error in dynamic query: ' + e.getMessage());
                    }
                } else if (objectName == 'Booking__c') {
                    System.debug('accountId: ' + accountId);

                    try {
                        String bookingQuery = 'SELECT ' + fieldName + ' FROM Booking__c WHERE Opportunity__r.AccountId = :accountId AND Opportunity__r.StageName = \'Unit Booked\' ORDER BY Opportunity__r.CreatedDate DESC';
                        System.debug('bookingQuery: ' + bookingQuery);
                        List<SObject> bookingResults = Database.query(bookingQuery);
                        System.debug('bookingResults: ' + bookingResults);
                        if (!bookingResults.isEmpty()) {
                            for (SObject booking : bookingResults) {
                                System.debug('booking: ' + booking);
                                System.debug('value: ' + booking.get(fieldName));
                                System.debug('type: ' + fieldType);
                                String bookingFieldValue = '';
                                if (fieldType == 'BOOLEAN') {
                                    if (booking.get(fieldName) == TRUE) {
                                        bookingFieldValue = 'true';
                                    } else if (booking.get(fieldName) == FALSE) {
                                        bookingFieldValue = null;
                                    }
                                } else if (booking.get(fieldName) == null) {
                                    bookingFieldValue = null;
                                }
                                System.debug('bookingFieldValue: ' + bookingFieldValue);
                                fieldValueWithType.put('value', bookingFieldValue);
                                fieldValueWithType.put('type', fieldType);
                                System.debug('fieldValueWithType: ' + fieldValueWithType);
                                if (bookingFieldValue == null) {
                                    break; 
                                }
                            }
                        }
                    } catch (Exception e) {
                        System.debug('Error in booking dynamic query: ' + e.getMessage());
                    }
                } else {
                    // Handle other objects as needed
                    System.debug('Data not Found');
                }

                // Add to fieldValuesWithType map
                fieldValuesWithType.put(objectName + '.' + fieldName, fieldValueWithType);	
                System.debug('Inside fieldValuesWithType: ' + fieldValuesWithType);
            }
        }
        System.debug('Outside fieldValuesWithType: ' + fieldValuesWithType);
        return fieldValuesWithType;
    }


    @AuraEnabled(cacheable=true)
    public static String getFieldDataType(String objectName, String fieldName) {
        System.debug('getFieldDataType function');
        SObjectType r = ((SObject)(Type.forName('Schema.' + objectName).newInstance())).getSObjectType();
        DescribeSObjectResult d = r.getDescribe();
        String fieldType = String.valueOf(d.fields.getMap().get(fieldName).getDescribe().getType());
        System.debug('objectName: ' + objectName + ', fieldName: ' + fieldName + ', fieldType: ' + fieldType);
        return fieldType;
    }


    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getPicklistValues(String objectName, String fieldName) {
        System.debug('getPicklistValues function');  
        List<Map<String, String>> picklistValues = new List<Map<String, String>>();

        DescribeSObjectResult describeSObjectResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
        
        DescribeFieldResult fieldResult = describeSObjectResult.fields.getMap().get(fieldName).getDescribe();
        
        if (fieldResult.getType() == Schema.DisplayType.Picklist) {
            List<PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
            for (PicklistEntry entry : picklistEntries) {
                Map<String, String> picklistValue = new Map<String, String>();
                picklistValue.put('label', entry.getLabel());
                picklistValue.put('value', entry.getValue());
                picklistValues.add(picklistValue);
                System.debug('Picklist value: ' + picklistValue);
            }
        }
        
        return picklistValues;
    }


    @AuraEnabled
    public static void updateFieldData(String accountId, String objectName, String fieldName, String value) {
        System.debug('updateFieldData function');
        System.debug('accountId: ' + accountId);
        System.debug('objectName: ' + objectName);
        System.debug('fieldName: ' + fieldName);
        System.debug('value: ' + value);
        
        String fieldType = getFieldDataType(objectName, fieldName);

        if (objectName == 'Opportunity') {
            System.debug('updateFieldData Opportunity');
            String query = 'SELECT Id, ' + fieldName + ' FROM Opportunity WHERE AccountId = :accountId AND StageName = \'Unit Booked\' AND Booking__c != null ORDER BY CreatedDate DESC';
            try {
                List<Opportunity> opportunities = Database.query(query);
                System.debug('query: ' + query);
                System.debug('opportunities: ' + opportunities);
                for (Opportunity opp : opportunities) {
                    if (fieldType == 'BOOLEAN') {
                        if (value == 'true') {
                            opp.put(fieldName, TRUE);
                        } else if (value == null || value == '') {
                            opp.put(fieldName, FALSE);
                        }
                    } else if(fieldType == 'DATE'){
                        Date dateValue = Date.valueOf(value);
                        opp.put(fieldname, dateValue);
                    } else {
                        opp.put(fieldName, value);
                    }
                }
                update opportunities;
            } catch (Exception e) {
                System.debug('Error updating opportunities: ' + e.getMessage());
            }
        } else if (objectName == 'Account') {
            System.debug('updateFieldData Account');
            String query = 'SELECT Id FROM Account WHERE Id = :accountId LIMIT 1';
            try {
                List<SObject> results = Database.query(query);
                System.debug('query: ' + query);
                System.debug('results: ' + results);
                if (!results.isEmpty()) {
                    SObject record = results[0];
                    if (fieldType == 'BOOLEAN') {
                        if (value == 'true') {
                            record.put(fieldName, TRUE);
                        } else if (value == null || value == '') {
                            record.put(fieldName, FALSE);
                        }
                    } else if(fieldType == 'DATE'){
                        Date dateValue = Date.valueOf(value);
                        record.put(fieldname, dateValue);
                    } else  {
                        record.put(fieldName, value);
                    }
                    update record;
                }
            } catch (Exception e) {
                System.debug('Error updating account: ' + e.getMessage());
            }
        } else if (objectName == 'Booking__c') {
            System.debug('updateFieldData Booking');
            String query = 'SELECT Id, ' + fieldName + ' FROM Booking__c WHERE Opportunity__r.AccountId = :accountId AND Opportunity__r.StageName = \'Unit Booked\' ORDER BY Opportunity__r.CreatedDate DESC';
            try {
                List<Booking__c> bookingList = Database.query(query);
                System.debug('query: ' + query);
                System.debug('bookingList: ' + bookingList);
                for (Booking__c booking : bookingList) {
                    if (fieldType == 'BOOLEAN') {
                        if (value == 'true') {
                            booking.put(fieldName, TRUE);
                        } else if (value == null || value == '') {
                            booking.put(fieldName, FALSE);
                        }
                    } else if(fieldType == 'DATE'){
                        Date dateValue = Date.valueOf(value);
                        booking.put(fieldname, dateValue);                    
                    } else {
                        booking.put(fieldName, value);
                    }
                }
                try {
                    update bookingList;
                } catch (System.DmlException exp) {
                    System.debug('Failed to update record as Admin: ' + exp.getMessage());
                    throw exp;
                }
            } catch (Exception e) {
                System.debug('Error updating Bookings: ' + e.getMessage());
            }
        }
    }


    public class FieldUpdate {
        @AuraEnabled public String objectName;
        @AuraEnabled public String fieldName;
        @AuraEnabled public String value;
    }
}