public with sharing class GenerateOtpControllerforLeadLWC {

    @AuraEnabled
    public static String generateOtp(String leadId) {
        try {
            Lead leadObj = [
                SELECT Id, Status, RW_Project__c, RW_Sourcing_Manager__c,Lead_Sourcing_Manager__c,
                       Lead_Source__c, Lead_Sub_Source__c, Customer_Reference__c, LeadSource, OwnerId,
                       RW_Broker__c, Temp_Channel_Partner__c, Vertical__c, Generated_OTP_On_Lead__c, RW_Lead_Sub_Source__c,Proposed_Visit_Date__c
                FROM Lead
                WHERE Id = :leadId
                LIMIT 1
            ];

            if (leadObj.Status != 'VCVP') {
                return 'ERROR:This Customer does not have any site visit confirmed yet';
            }

            if (leadObj.RW_Project__c == null) {
                return 'ERROR:Please add the Project in Lead.';
            }

            // Check if an active OTP already exists
            List<OTP__c> existingOtps = [
                SELECT Id, Generated_OTP__c, OTP_Expired__c, CreatedById
                FROM OTP__c
                WHERE Lead__c = :leadId AND OTP_Expired__c = false
                LIMIT 1
            ];

            if (!existingOtps.isEmpty()) {
                // If OTP was created by current Owner → return existing OTP
                if (existingOtps[0].CreatedById == leadObj.OwnerId) {
                    return 'EXISTS:' + existingOtps[0].Generated_OTP__c;
                } else {
                    // If Owner changed → mark old OTP as expired
                    existingOtps[0].Owner_Changed__c = true; 
                    update existingOtps;
                }
            }

            // Generate a new 5-digit OTP
            String OTPNumber;
            Integer len;
            do {
                Long y = Math.round(Math.random() * 100000);
                len = String.valueOf(y).length();
                OTPNumber = String.valueOf(y);
            } while (len < 5);
            
            if (String.isBlank(OTPNumber)) {
                return 'ERROR: OTP generation failed.';
            }

            OTP__c otp = new OTP__c();
            otp.Generated_OTP__c = OTPNumber;
            otp.OTP_Generated_on__c = String.valueOf(System.now());
            otp.User_Info__c = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
            otp.Lead__c = leadObj.Id;
            otp.Project__c = leadObj.RW_Project__c;
            otp.User__c = UserInfo.getUserId();
            otp.OTP_Generate_For__c = leadObj.LeadSource;

            leadObj.Generated_OTP_On_Lead__c = OTPNumber;

            /*if (leadObj.RW_Sourcing_Manager__c != null) {  //Commented by Vinay 25-11-2025
                otp.Sourcing_Manager__c = leadObj.RW_Sourcing_Manager__c;
            }*/
            if (leadObj.Lead_Sourcing_Manager__c != null) { //Added by Vinay 25-11-2025
                otp.Sourcing_Manager_LU__c = leadObj.Lead_Sourcing_Manager__c;
            }
            
            if(leadObj.Proposed_Visit_Date__c != null){
                otp.Customer_Site_Visit_On__c= String.valueOf(leadObj.Proposed_Visit_Date__c);
            
            } else{
                List<Task> vcvpTaskList=[SELECT Id,Call_Proposed_date_of_visit__c,Call_Status__c,Call_Disposition_Custom__c 
                 From Task Where WhoId=:leadId AND Call_Status__c= 'Connected'
                  AND Call_Disposition_Custom__c='Visit Scheduled'
                  ORDER BY CreatedDate DESC LIMIT 1];
                
                 if (!vcvpTaskList.isEmpty() && vcvpTaskList[0].Call_Proposed_date_of_visit__c != null) {
                     otp.Customer_Site_Visit_On__c =  String.valueOf(vcvpTaskList[0].Call_Proposed_date_of_visit__c);
                   }
                 }

            // Referral logic
            if (leadObj.Lead_Source__c == 'Referral' &&
                leadObj.RW_Lead_Sub_Source__c == 'Existing client reference' &&
                leadObj.Customer_Reference__c != null) {

                otp.Customer_Reference_Lookup__c = leadObj.Customer_Reference__c;
                otp.Referral_Sub_Source__c = leadObj.RW_Lead_Sub_Source__c;

                List<Opportunity> lstopp = [
                    SELECT SAP_Customer_Number__c, RW_Project_Unit__c, AccountId
                    FROM Opportunity
                    WHERE StageName = 'Unit Booked' AND AccountId = :leadObj.Customer_Reference__c
                    ORDER BY RW_Booking_Date_Opp__c DESC
                ];

                if (!lstopp.isEmpty()) {
                    otp.Customer_reference_SAP_Code__c = lstopp[0].SAP_Customer_Number__c;
                    otp.Customer_reference_Booked_Unit__c = lstopp[0].RW_Project_Unit__c;
                }
            }

            if (leadObj.Temp_Channel_Partner__c != null) {
                otp.Temp_Channel_Partner__c = leadObj.Temp_Channel_Partner__c;
            }
            if ( leadObj.RW_Broker__c  != null){
                otp.Channel_Partner_Lookup__c= leadObj.RW_Broker__c ;
            }

            insert otp;
            update leadObj;

            return 'SUCCESS:' + OTPNumber;

        } catch (Exception ex) {
            return 'ERROR:' + ex.getMessage();
        }
    }

   @AuraEnabled(cacheable=true)
public static OTP__c getActiveOtpForLead(Id leadId) {
    List<OTP__c> otps = [
        SELECT Id, Generated_OTP__c, OTP_Expired__c
        FROM OTP__c
        WHERE Lead__c = :leadId AND OTP_Expired__c = false
        ORDER BY CreatedDate DESC
        LIMIT 1
    ];
    return otps.isEmpty() ? null : otps[0];
}

}