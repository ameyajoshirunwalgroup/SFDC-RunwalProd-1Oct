@isTest
public class LimeChat_LeadCreateUpdateTest {
    
    @isTest
    public static void leadCreateUpdateTest1(){
        Test.startTest();
        
        String jsonStr1 = '{"phone_number" : "1254789658","wa_display_name": "Vinay", "lead_status":"New","lead_stage":"Initial","entry_timestamp":""}';
        RestRequest req1 = new RestRequest(); 
        RestResponse res1 = new RestResponse();
        req1.requestURI = 'https://runwal--fullcopy.sandbox.my.salesforce.com/services/apexrest/limeChatLead/new'; 
        req1.httpMethod = 'Post';
        req1.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req1;
        RestContext.response = res1;
        req1.requestBody = Blob.valueOf(jsonStr1);
        LimeChat_LeadCreateUpdate.doPost();
        
        String jsonStr2 = '{"phone_number" : "1254789658","wa_display_name": "Vinay", "lead_status":"New","lead_stage":"Initial","entry_timestamp":""}';
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();
        req2.requestURI = 'https://runwal--fullcopy.sandbox.my.salesforce.com/services/apexrest/limeChatLead/update'; 
        req2.httpMethod = 'Post';
        req2.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req2;
        RestContext.response = res2;
        req2.requestBody = Blob.valueOf(jsonStr2);
        LimeChat_LeadCreateUpdate.doPost();
        
        
    }
    
    @isTest
    public static void leadCreateUpdateTest2(){
        Test.startTest();
        
        
        
        Project__c proj = new Project__c(Name = 'Test Project');
        Lead ld = new Lead(LastName = 'Kumar',RW_Mobile_No__c = '2255664478',RW_Project__c = proj.Id);
        
        String jsonStr1 = '{"phone_number" : "2255664478","wa_display_name": "Vinay", "lead_status":"New","lead_stage":"Initial","entry_timestamp":""}';
        RestRequest req1 = new RestRequest(); 
        RestResponse res1 = new RestResponse();
        req1.requestURI = 'https://runwal--fullcopy.sandbox.my.salesforce.com/services/apexrest/limeChatLead/new'; 
        req1.httpMethod = 'Post';
        req1.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req1;
        RestContext.response = res1;
        req1.requestBody = Blob.valueOf(jsonStr1);
        LimeChat_LeadCreateUpdate.doPost();
        
        String jsonStr3 = '{"phone_number" : "2255664478","wa_display_name": "Kumar", "lead_status":"New","lead_stage":"Initial","entry_timestamp":""}';
        RestRequest req3 = new RestRequest(); 
        RestResponse res3 = new RestResponse();
        req3.requestURI = 'https://runwal--fullcopy.sandbox.my.salesforce.com/services/apexrest/limeChatLead/new'; 
        req3.httpMethod = 'Post';
        req3.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req3;
        RestContext.response = res3;
        req3.requestBody = Blob.valueOf(jsonStr3);
        LimeChat_LeadCreateUpdate.doPost();
        
        String jsonStr4 = '{"phone_number" : "2255664478","wa_display_name": "Vinay", "lead_status":"New","lead_stage":"Initial","entry_timestamp":"","project": "' + proj.Id + '"}';
        RestRequest req4 = new RestRequest(); 
        RestResponse res4 = new RestResponse();
        req4.requestURI = 'https://runwal--fullcopy.sandbox.my.salesforce.com/services/apexrest/limeChatLead/update'; 
        req4.httpMethod = 'Post';
        req4.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req4;
        RestContext.response = res4;
        req4.requestBody = Blob.valueOf(jsonStr4);
        LimeChat_LeadCreateUpdate.doPost();
    }

}