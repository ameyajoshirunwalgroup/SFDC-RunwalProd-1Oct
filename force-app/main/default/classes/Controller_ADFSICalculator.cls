public class Controller_ADFSICalculator {
    
    @AuraEnabled(cacheable=false)
    public static List<WrapperADF> GetProjects(String sBookingId, Decimal principalAmount) {
        system.debug('sBookingId>>>>>>' + sBookingId);
        system.debug('Principal Amount>>>>>>' + principalAmount);

        List<Booking__c> lstBooking = [SELECT Id, Project__c,
                                              Project__r.RW_Status__c,
                                              Project__r.ADF_Threshold_Amount__c
                                       FROM Booking__c
                                       WHERE Project__r.RW_Status__c = 'Active'
                                       AND Project__r.ADF_Threshold_Amount__c != NULL
                                       AND Id =: sBookingId];

        List<Predefine_ADF_Thresholds__mdt> config = [
            SELECT Threshold_Start_Value__c, Threshold_End_Value__c, ADF_Interest_Rate__c 
            FROM Predefine_ADF_Thresholds__mdt
        ];

        List<WrapperADF> lstWrapp = new List<WrapperADF>();

        if (!lstBooking.isEmpty()) {
            for (Booking__c objBooking : lstBooking) {
                WrapperADF objWrapp = new WrapperADF();

                objWrapp.ADFThresholdAmount = objBooking.Project__r.ADF_Threshold_Amount__c;

                // Determine ROI dynamically based on principal
                for (Predefine_ADF_Thresholds__mdt objConfig : config) {
                    if (principalAmount >= objConfig.Threshold_Start_Value__c &&
                        principalAmount <= objConfig.Threshold_End_Value__c) {
                        objWrapp.ADFInterestRate = objConfig.ADF_Interest_Rate__c;
                       // break;
                    }
                }

                lstWrapp.add(objWrapp);
            }
        }

        return lstWrapp;
    }

    public class WrapperADF {
        @AuraEnabled public Decimal ADFInterestRate;
        @AuraEnabled public Decimal ADFThresholdAmount;
    }
}