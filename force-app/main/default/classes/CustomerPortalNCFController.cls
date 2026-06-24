public with sharing class CustomerPortalNCFController {

    @AuraEnabled(cacheable=true)
    public static Name_Confirmation_Form__c getNCF(Id bookingId) {
        if (bookingId == null) {
            return null;
        }

        List<Name_Confirmation_Form__c> listNCF = [
            SELECT Id, Status__c, Booking__c,
                   RW_Primary_First_Name__c,
                   RW_Primary_Middle_Name__c,
                   RW_Primary_Last_Name__c,
                   RW_Primary_Email__c,
                   RW_Primary_Mobile_Number__c,
                   RW_Primary_Permanent_Address_Line_1__c,
                   RW_Primary_Country__c,
                   RW_Primary_DOB__c,
                   Booking__r.Unit_Number__c,
                   Booking__r.Unit_No__c,
                   Booking__r.OwnerId,
                   Booking__r.Unit_No__r.Name,
                   Applicant2_Name__c, Applicant2_Email_Address__c, Applicant2_Mobile_No__c, 
                   Applicant2_Permanent_Address__c, Applicant2_PAN__c, Applicant3_Name__c, Applicant4_Name__c, 
                   Applicant5_Name__c, Applicant3_Mobile_No__c, Applicant4_Mobile_No__c, Applicant5_Mobile_No__c, Applicant3_Permanent_Address__c, Applicant4_Permanent_Address__c, 
                   Applicant5_Permanent_Address__c, Applicant3_Email_Address__c, Applicant4_Email_Address__c, Applicant5_Email_Address__c
            FROM Name_Confirmation_Form__c
            WHERE Booking__c = :bookingId And RW_Active_NCF__c = true
            LIMIT 1
        ];

        return listNCF.isEmpty() ? null : listNCF[0];
    }

    @AuraEnabled
    public static String createCaseWithBookingOwner(Case caseRecord, String bookingId, String ncfId) {
        try {
            // 2. Assign to Current User (Standard Community Behavior)
            // We do NOT set OwnerId to the Booking Owner here.
            caseRecord.OwnerId = UserInfo.getUserId();
            
            // 3. Ensure Contact/Account are linked (Best Practice for Community Cases)
            // This helps prevent other visibility errors
            List<User> currentContactId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()];
            if (!currentContactId.isEmpty()) {
                caseRecord.ContactId = currentContactId[0].ContactId;
            }
            if(ncfId!=null){
                caseRecord.Name_Confirmation_Form__c = ncfId;
            }

            // 4. Insert
            insert caseRecord;

            Name_Confirmation_Form__c ncf = new Name_Confirmation_Form__c(
                Id = ncfId,
                Status__c = 'Raised a Case'
            );
            update ncf;

            Booking__c booking = new Booking__c(
                Id = bookingId,
                NCF_Status__c = 'Pending'
            );
            update booking;
            return caseRecord.Id;

        } catch (Exception e) {
            throw new AuraHandledException('Error creating case: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void approveNCF(Id ncfId, Id bookingId) {
        if (ncfId == null && bookingId == null) {
            throw new AuraHandledException('ncfId is required');
        }
        try{
            Name_Confirmation_Form__c ncf = new Name_Confirmation_Form__c(
                Id = ncfId,
                Status__c = 'Approved'
            );
            // Booking__c booking = new Booking__c(
            //     Id = bookingId,
            //     NCF_Status__c = 'Completed'
            // );
            // update booking;
            update ncf;
        }catch(Exception ex){
            throw new AuraHandledException('Error in Updating Status'+ex.getMessage());
        }
    }

    // @AuraEnabled
    // public static Id createCaseWrapper(CaseInputWrapper input) {
    //     if (input == null) {
    //         throw new AuraHandledException('Input cannot be empty.');
    //     }
    //     System.debug('INPUT: ' + JSON.serialize(input));

    //     // Validate minimal required fields if needed (optional)
    //     Case c = new Case();

    //     // Assign values directly from wrapper
    //     c.RW_Case_Type__c = input.caseType;
    //     c.Customer_Lifecycle_Touchpoint__c = input.touchPoint;
    //     c.RW_Complaint_Type__c = input.complaintType;
    //     c.RW_Complaint_SubType__c = input.complaintSubType;
    //     //c.Unit_Number__c = input.unitNumber;
    //     c.Description = input.description;

    //     // Safely set Booking lookup if field exists on Case object
    //     if (input.bookingId != null &&
    //         Schema.sObjectType.Case.fields.getMap().containsKey('Booking__c')) {
    //         c.put('Booking__c', input.bookingId);
    //     }

    //     // Set defaults
    //     c.Origin  = 'Portal';
    //     c.Subject = (input.caseType != null && input.caseType.trim().length() > 0)
    //                 ? input.caseType + ' - Customer Portal'
    //                 : 'Portal Case';

    //     insert c;
    //     return c.Id;
    // }
    @AuraEnabled
    public static Id createCaseWrapper(String jsonString) {

        if (String.isBlank(jsonString)) {
            throw new AuraHandledException('Input JSON is empty.');
        }

        System.debug('RAW JSON RECEIVED: ' + jsonString);

        // -----------------------------
        // Convert JSON into Wrapper
        // -----------------------------
        CaseInputWrapper input;
        try {
            input = (CaseInputWrapper) JSON.deserialize(jsonString, CaseInputWrapper.class);
        } catch (Exception e) {
            throw new AuraHandledException('Failed to parse JSON: ' + e.getMessage());
        }

        System.debug('DESERIALIZED WRAPPER: ' + JSON.serialize(input));

        // -----------------------------
        // CREATE CASE
        // -----------------------------
        Case c = new Case();

        c.RW_Case_Type__c = input.caseType;
        c.Customer_Lifecycle_Touchpoint__c = input.touchPoint;
        c.RW_Complaint_Type__c = input.complaintType;
        c.RW_Complaint_SubType__c = input.complaintSubType;
        //c.Unit_Number__c = input.unitNumber;    // IMPORTANT: Do NOT comment out
        c.Description = input.description;

        // Add booking lookup if field exists
        if (Schema.sObjectType.Case.fields.getMap().containsKey('Booking__c')) {
            c.put('Booking__c', input.bookingId);
        }

        c.Origin = 'Portal';
        c.Subject = input.caseType + ' - Customer Portal';

        insert c;
        return c.Id;
    }
    
    public class CaseInputWrapper {
        @AuraEnabled public String caseType;
        @AuraEnabled public String touchPoint;
        @AuraEnabled public String complaintType;
        @AuraEnabled public String complaintSubType;
        @AuraEnabled public String unitNumber;
        @AuraEnabled public String description;
        @AuraEnabled public Id bookingId;
    }


}