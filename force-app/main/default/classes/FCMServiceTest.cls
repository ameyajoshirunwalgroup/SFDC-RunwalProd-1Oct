@isTest
public class FCMServiceTest {
    
    @isTest
    public static void test1(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CalloutMockClass());
        //FCMService.sendNotification('ntf.Device_Token__c', 'ntf.Booking__c', 'ntf.Notification_Type__c', 'ntf.Title__c', 'ntf.Message__c', 'ntf.Record_Id__c', 'ntf.Id');
        App_Notification__c an = new App_Notification__c();
        an.Title__c = 'Home Loan Notification';
        an.Message__c = 'message';
        an.Notification_Type__c = 'loan_assistance';
        an.Device_Token__c = 'token';
        insert an;
        
        
        
        Test.stopTest();
    }
}