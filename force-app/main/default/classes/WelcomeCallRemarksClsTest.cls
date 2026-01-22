@IsTest
private class WelcomeCallRemarksClsTest {

    @IsTest
    static void testWcCallRemarks() {
        // Create a test Welcome Call record
        RW_Welcome_Call__c welcomeCall = new RW_Welcome_Call__c(
            RW_Welcome_Call_Remarks__c='test'
        );
        insert welcomeCall;
        
        // Create test remarks records linked to the above Welcome Call
        List<RW_Welcome_Call_Remarks__c> remarksList = new List<RW_Welcome_Call_Remarks__c>();
        for (Integer i = 0; i < 3; i++) {
            remarksList.add(new RW_Welcome_Call_Remarks__c(
                RW_Welcome_Call__c = welcomeCall.Id,
                RW_Remarks__c = 'This is remark ' + i
            ));
        }
        insert remarksList;

        Test.startTest();
        // Call the AuraEnabled method
        List<RW_Welcome_Call_Remarks__c> result = WelcomeCallRemarksCls.wcCallRemarks(welcomeCall.Id);
        Test.stopTest();

    }
}