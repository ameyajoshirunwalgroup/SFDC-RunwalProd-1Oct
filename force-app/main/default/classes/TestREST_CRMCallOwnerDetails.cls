@isTest
public class TestREST_CRMCallOwnerDetails {
    @isTest 
    public static void test1(){
        
        RM_Usernames__c objRM = new RM_Usernames__c();
        objRM.Name = 'test';
        objRM.RW_Email__c='test@stetig.in';
        objRM.RW_Mobile_No__c = '1234567890';
        objRM.User_Name__c ='test123@stetig.com';
        insert objRM;
        
        Account acc = new Account();
        acc.LastName = 'Test';
        acc.FirstName = 'tesing';
        acc.Phone = '9234567890';
        acc.PersonMobilePhone = '1234567890';
        acc.PersonEmail = 'test@stetig.in';
        acc.Mobile_No__c = '1234567890';
        acc.RM_Name__c = 'test';
        insert acc;
     
        String JSONMsg = '{"mobile":"' + acc.Mobile_No__c +'""}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CRMcall/ownerdetails/'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JSONMsg);
        RestContext.request = req;
        RestContext.response= res;
        REST_CRMCallOwnerDetails obj = new REST_CRMCallOwnerDetails();
        REST_CRMCallOwnerDetails.validMobileNo(acc.Mobile_No__c);
        REST_CRMCallOwnerDetails.validMobileNo('');
        REST_CRMCallOwnerDetails.validMobileNo('1122112211');
        REST_CRMCallOwnerDetails.validMobileNo('112211221');
        
    }
    @isTest 
    public static void test2(){
        
        RM_Usernames__c objRM1 = new RM_Usernames__c();
        objRM1.Name = 'test';
        objRM1.RW_Email__c='test@stetig.in';
        objRM1.RW_Mobile_No__c = '1234567890';
        objRM1.User_Name__c ='test123@stetig.com';
        insert objRM1;
       
               
        Account acc1 = new Account();
        acc1.LastName = 'Test';
        acc1.FirstName = 'tesing';
        acc1.Phone = '9234567890';
        acc1.PersonMobilePhone = '1234567890';
        acc1.PersonEmail = 'test@stetig.in';
        acc1.Mobile_No__c = '1234567890';
        acc1.RM_Name__c ='testing';
        insert acc1;
        
        String JSONMsg1 = '{"mobile":"1234567890"}';
        RestRequest req1 = new RestRequest();
        RestResponse res1 = new RestResponse();
        req1.requestURI = '/services/apexrest/CRMcall/ownerdetails/'; //Request URL
        req1.httpMethod = 'POST';
        req1.requestBody = Blob.valueof(JSONMsg1);
        RestContext.request = req1;
        RestContext.response= res1;
        REST_CRMCallOwnerDetails obj1 = new REST_CRMCallOwnerDetails();
        REST_CRMCallOwnerDetails.validMobileNo('1234567890');
    }
    @isTest
    public static void test3(){
        
        RM_Usernames__c objRM = new RM_Usernames__c();
        objRM.Name = 'test';
        objRM.RW_Email__c='test@stetig.in';
        objRM.RW_Mobile_No__c = '1234567890';
        objRM.User_Name__c ='test123@stetig.com';
        insert objRM;
        
        Account acc2 = new Account();
        acc2.LastName = 'Test';
        acc2.FirstName = 'tesing';
        acc2.Phone = '9234567890';
        acc2.PersonMobilePhone = '1234567890';
        acc2.PersonEmail = 'test@stetig.in';
        acc2.Mobile_No__c = '1234007890';
        acc2.RM_Name__c='';
        insert acc2;
        
        String JSONMsg2 = '{"mobile":"1234007890"}';
        RestRequest req2 = new RestRequest();
        RestResponse res2 = new RestResponse();
        req2.requestURI = '/services/apexrest/CRMcall/ownerdetails/'; //Request URL
        req2.httpMethod = 'POST';
        req2.requestBody = Blob.valueof(JSONMsg2);
        
        RestContext.request = req2;
        RestContext.response= res2;
        
        
        REST_CRMCallOwnerDetails obj2 = new REST_CRMCallOwnerDetails();
        REST_CRMCallOwnerDetails.validMobileNo('1234007890');
        
    }
}