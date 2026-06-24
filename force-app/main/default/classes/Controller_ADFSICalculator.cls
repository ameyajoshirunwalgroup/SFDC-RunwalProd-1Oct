public class Controller_ADFSICalculator {
    
    @AuraEnabled(cacheable=false)
    public static WrapperADF GetProjects(String sBookingId, Decimal principalAmount) {

        WrapperADF res = new WrapperADF();

        List<Booking__c> lstBooking = [
                                       SELECT Id, Project__c,
                                              Project__r.Name,
                                              Project__r.RW_Status__c,
                                              Project__r.ADF_Threshold_Amount__c,
                                              Project__r.ADF_Interest_Rate__c
                                       FROM Booking__c
                                       WHERE Project__r.RW_Status__c = 'Active'
                                       AND Project__r.ADF_Threshold_Amount__c != NULL
                                       AND Id =: sBookingId limit 1
        ];

        if (lstBooking.isEmpty()) {
            res.success = false;
            res.message = 'Booking not found.';
            return res;
        }

        Booking__c booking = lstBooking[0];
        res.ADFThresholdAmount = booking.Project__r.ADF_Threshold_Amount__c;

        List<Predefine_ADF_Thresholds__mdt> config = [
            SELECT Threshold_Start_Value__c, Threshold_End_Value__c,
                   ADF_Interest_Rate__c, Project_Name__c
            FROM Predefine_ADF_Thresholds__mdt
            WHERE Project_Name__c IN (:booking.Project__r.Name, 'Default')
        ];

        if (config.isEmpty()) {
            res.success = false;
            res.message = 'No ADF configuration found for this project.';
            return res;
        }

        // Split meta into two groups
        List<Predefine_ADF_Thresholds__mdt> projectConfigs = new List<Predefine_ADF_Thresholds__mdt>();
        List<Predefine_ADF_Thresholds__mdt> defaultConfigs = new List<Predefine_ADF_Thresholds__mdt>();

        for (Predefine_ADF_Thresholds__mdt cfg : config) {
            if (cfg.Project_Name__c == booking.Project__r.Name)
                projectConfigs.add(cfg);
            else if (cfg.Project_Name__c == 'Default')
                defaultConfigs.add(cfg);
        }
        
        // Determine which config to use
        List<Predefine_ADF_Thresholds__mdt> finalConfig = !projectConfigs.isEmpty() ? projectConfigs : defaultConfigs;

        // Slab match
        for (Predefine_ADF_Thresholds__mdt slab : config) {
            Boolean isMatch = false;

            // Infinite range
            if (slab.Threshold_End_Value__c == null) {
                isMatch = principalAmount >= slab.Threshold_Start_Value__c;
            }
            // Normal slab
            else {
                isMatch = principalAmount >= slab.Threshold_Start_Value__c &&
                          principalAmount <= slab.Threshold_End_Value__c;
            }
            if (isMatch) {
                res.ADFInterestRate = slab.ADF_Interest_Rate__c;
                res.success = true;
                res.message = 'Success';
                return res;
            }
            // if (principalAmount >= slab.Threshold_Start_Value__c &&
            //     (principalAmount <= slab.Threshold_End_Value__c || slab.Threshold_End_Value__c== null)) {

            //     res.ADFInterestRate = slab.ADF_Interest_Rate__c;
            //     res.success = true;
            //     res.message = 'Success';
            //     return res;
            // }
            System.debug('SLAB: Start=' + slab.Threshold_Start_Value__c +
             ' End=' + slab.Threshold_End_Value__c +
             ' Rate=' + slab.ADF_Interest_Rate__c);

        }

        res.success = false;
        res.message = 'No threshold slab matches the entered principal amount.';
        return res;
    }

    public class WrapperADF {
        @AuraEnabled public Decimal ADFInterestRate;
        @AuraEnabled public Decimal ADFThresholdAmount;
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
    }
}