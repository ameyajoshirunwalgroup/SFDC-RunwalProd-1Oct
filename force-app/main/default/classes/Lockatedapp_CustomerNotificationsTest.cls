@isTest
public class Lockatedapp_CustomerNotificationsTest {
    
    @isTest
    public static void customerNotificationsTest(){
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CreateUserWhenUnitBookedMock()); 
        Test.stopTest();
        
        Booking__c bkg = new Booking__c();
        bkg.Status__c = 'Booking Confirmed';
        insert bkg;
        
        App_Notification__c ntf = new App_Notification__c();
        ntf.Booking__c = bkg.Id;
        ntf.Device_Token__c = '1234';
        insert ntf;
        
        String jsonStr6 = '{"bookingNumber" : " ' + bkg.Id + '","deviceToken": "1234"}';
        RestRequest req6 = new RestRequest(); 
        RestResponse res6 = new RestResponse();
        req6.requestURI = 'https://runwal--fullcopy.sandbox.my.salesforce.com/services/apexrest/customerNotifications/'; 
        req6.httpMethod = 'Get';
        req6.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req6;
        RestContext.response = res6;
        req6.requestBody = Blob.valueOf(jsonStr6);
        Lockatedapp_CustomerNotifications.doGet();
    }

    @isTest
    public static void customerNotificationsTest1(){
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CalloutMockClass()); 
        Test.stopTest();
        
        
        App_Notification__c ntf = new App_Notification__c();
        ntf.Device_Token__c = '1234';
        insert ntf;
        
        String jsonStr6 = '{"bookingNumber" : "","deviceToken": "1234"}';
        RestRequest req6 = new RestRequest(); 
        RestResponse res6 = new RestResponse();
        req6.requestURI = 'https://runwal--fullcopy.sandbox.my.salesforce.com/services/apexrest/customerNotifications/'; 
        req6.httpMethod = 'Get';
        req6.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req6;
        RestContext.response = res6;
        req6.requestBody = Blob.valueOf(jsonStr6);
        Lockatedapp_CustomerNotifications.doGet();
        
        Lockatedapp_CustomerNotifications.dummy();
    }

}