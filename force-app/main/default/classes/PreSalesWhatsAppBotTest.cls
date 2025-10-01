@isTest
public class PreSalesWhatsAppBotTest {
    
    @isTest
    public static void test1(){
        
        Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.SAPMaterial_Code__c = '1211';
        objpr.RW_Project_Location_Videos_Link__c='test';
        objpr.RW_Project_Brochure_PublicUrl__c='test1';
        objpr.RW_SAP_Company_Code__c='5245';
        objpr.Haptik_Bot_Active__c = true;
        objpr.RW_Status__c = 'Active';
        insert objpr;
        
        Test.startTest();
            
        RestRequest req1 = new RestRequest(); 
        RestResponse res1 = new RestResponse();
        req1.requestURI = 'https://runwal.my.salesforce.com/services/apexrest/PreSalesWhatsAppBot'; 
        req1.httpMethod = 'Get';
        req1.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req1;
        RestContext.response = res1;
        PreSalesWhatsAppBot.doGet();
        
        String jsonStr = '{"name":"Test","email":"test@mail.com","mobile":"1234567890","configuration":"1 BHK","project":"","conversationId":"123456"}';
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();
        req1.requestURI = 'https://runwal.my.salesforce.com/services/apexrest/PreSalesWhatsAppBot'; 
        req1.httpMethod = 'Post';
        req1.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req2;
        RestContext.response = res2;
        req2.requestBody = Blob.valueOf(jsonStr);
        PreSalesWhatsAppBot.doPost();
        
        Test.stopTest();
    }

}