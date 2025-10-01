@isTest
public class TestCallCustomerController {
    @isTest
    public static void TestLeadCall(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='pranay2@stetig.in', Department='',CTI_Agent_ID__c= 'Test', Campaign_name__c='Testing', api_key__c='KK37f7a89c616b3150169a5542ac1d97df',Ozontel_UserName__c='Test123');
        insert u;
        
        system.runAs(u){
            CallCustomerController.callAPI('1234567890', '+91', 'Testing');
            CallCustomerController.callAPI('12345678', '+71', 'Testing');
            CallCustomerOfflineController.callAPI('1234567890', '+91','Testing');
            CallCustomerOfflineController.callAPI('12345678', '+71','Testing');
        }
        
    }
    
    @isTest
    public static void TestDisposition(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='pranay2@stetig.in', Department='',CTI_Agent_ID__c= 'Test', Campaign_name__c='Testing', api_key__c='KK37f7a89c616b3150169a5542ac1d97df',Ozontel_UserName__c='Test123');
        insert u;
        
        Account Accnt = new Account(              
            FirstName='TestFName',                
            LastName='TestLName',                
            PersonMailingStreet='test@yahoo.com',                
            PersonMailingPostalCode='12345',                
            PersonMailingCity='SFO',                
            PersonEmail='test@yahoo.com',                
            PersonHomePhone='1234567',                
            PersonMobilePhone='12345678',
            Mobile_No__c = '1324235436',
            RM_Name__c = 'Testing2'
        );          
        
        insert Accnt;
        
        Account Accnt1 = new Account(              
            FirstName='TestFName',                
            LastName='TestLName',                
            PersonMailingStreet='test@yahoo.com',                
            PersonMailingPostalCode='12345',                
            PersonMailingCity='SFO',                
            PersonEmail='test@yahoo.com',                
            PersonHomePhone='1234567',                
            PersonMobilePhone='12345678',
            Mobile_No__c = '1324235431',
            RM_Name__c = 'Testing1'
        );          
        
        insert Accnt1;
        
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Name = 'Test';
        objOpportunity.Sales_Manager__c = 'Deepak Arya';
        objOpportunity.Sourcing_Manager__c = 'Deepak Arya';
        objOpportunity.CloseDate = System.today();
        objOpportunity.AccountId = Accnt.Id; 
        objOpportunity.Status__c = 'Active'; 
        objOpportunity.RW_Email__c = 'm@m.com';
        objOpportunity.StageName = 'Qualification'; 
        objOpportunity=RDSCommon.CreateOpportunity(objOpportunity);
        
        task t = new task();
        t.Subject = 'New Task';
        t.Task_Type__c = 'Presales Call';
        t.activityDate = System.Today();
        t.whatId = objOpportunity.Id;
        t.call_time__c = TaskManagementServices.FormatTime(system.now());
        t.ActivityDate__c = '25/05/2021';
        t.ActivityDate = System.Today();
        t.Next_Action_Date__c = System.Today();
        t.Visit_Form_No__c = '131243535';
        t.Description = 'Tetsing';
        t.CallObject = '43986759675585';
        t.Ameyo_Agent_Id__c = 'Testing1234';
        insert t;
        
        Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        insert objpr;
        
        Booking__c b = new Booking__c();
        b.Customer__c = objOpportunity.Id;
        b.Project__c = objpr.Id;
        b.Opportunity__c = objOpportunity.Id;
        b.Booking_Date__c = Date.today();
        b.Type_of_Client__c = 'Local';
        b.Status__c = 'Booking Confirmed';
        b.RW_Registration_Done__c = 'No';
        b.Exclude_From_Brokerage_Batch__c = false;
        b.Source_of_Booking__c = 'Channel Partner';
        b.Allotment_Premium__c = 10000000;
        b.Base_Brokerage__c = 2;
        b.RW_BRL_Number__c = '35363';
        b.RW_Registration_Status__c = 'Registration Completed';
        b.RW_Registration_Type__c = 'Offline Registration';
        b.RW_Expected_Registration_Date__c = system.today();
        b.RW_Registration_Date__c = system.today();
        b.RW_Total_Receipt_Amount_Received__c = 2000000;
        b.RW_Registration_Done__c = 'No';
        insert b;
        
        RW_Demand__c objDemand = new RW_Demand__c();
        objDemand.Booking__c = b.id;
        insert objDemand;
        
        case objCase = new case();
        insert objCase;
        
        Loan__c loanObj= new Loan__c();
        loanObj.RW_Bank_Name__c='ICICI Bank Ltd';
        loanObj.RW_Bank_Preference_1__c='ICICI Bank Ltd';
        insert loanObj;

        Loan_Disbursement_Details__c LDObject= new Loan_Disbursement_Details__c();
        LDObject.Loan__c=loanObj.id;
        LDObject.Disbursement_Type__c='First Disbursement';
        insert LDObject;
        
        List<Id> Tid = new List<Id>();
        Set<Id> Taskid = new Set<Id>();
        Tid.add(t.id);
        Taskid.add(t.id);
        Test.startTest();
        OzonetelCallDisposition.sendDisposition(Tid);
        CallOzonetelSchedulerAPI.scheduleCall(Taskid);
        CallCustomerOfflineController.oppData(objOpportunity.ID);
        CallCustomerOfflineController.demandData(objDemand.ID);
        CallCustomerOfflineController.caseData(objCase.ID);
        CallCustomerOfflineController.loanData(loanObj.ID);
        CallCustomerController.oppData(objOpportunity.ID);
        CallCustomerController.demandData(objDemand.ID);
        CallCustomerController.caseData(objCase.ID);
        Rest_getAgentdetails.Rest_getAgentdetails('1324235436', 'CampaignName', 'DID');
        Rest_getAgentdetails.Rest_getAgentdetails('1324235430', 'CampaignName', 'DID');
        Rest_getAgentdetails.Rest_getAgentdetails('1324235431', 'CampaignName', 'DID');
        Test.stopTest();
    }
    
    @isTest
    public static void testTataWebhook1(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id,Tata_CTI_Agent_Number__c = '912564789658',
                          TimeZoneSidKey='America/Los_Angeles', UserName='pranay2@stetig.in', Department='',CTI_Agent_ID__c= 'Test', Campaign_name__c='Testing', api_key__c='KK37f7a89c616b3150169a5542ac1d97df',Ozontel_UserName__c='Test123');
        insert u;
        
        system.runAs(u){
            CallCustomerController.callAPI('1234567890', '+91', 'Testing');
            CallCustomerOfflineController.callAPI('12345678', '+71','Testing');
        }
        
        //CallCustomerController.callAPI('1234567890', '+91', 'Testing');
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Mobile_No__c = '2356478568';
        acc.RM_Name__c = 'Aakash Motwani';
        insert acc;
        
        Lead ld = new Lead();
        ld.LastName = 'Test Lead';
        ld.Email = 'test@mail.com';
        ld.RW_Mobile_No__c = '2356478569';
        insert ld;
        
        
        RestRequest req1 = new RestRequest();
        RestResponse res1 = new RestResponse();
        req1.requestURI = 'https://runwal.my.salesforce-sites.com/tataWebhook/services/apexrest/tataWebhook'; 
        req1.httpMethod = 'Post';
        req1.addHeader('Content-Type', 'application/json'); 
        String body1 = '{"uuid" : "","call_to_number" : "","caller_id_number" : "","date" : "","call_flow" : "","dept_name" : "","ivr_name" : "","call_id" : "","billing_circle" : "","agent_number" : "","agent_name" : "","customer_no_with_prefix" : "+912356478568","start_stamp" : "","direction" : "inbound","answered_agent_number" : "","call_status" : "Missed","customer_ring_time" : "","answer_stamp" : "","end_stamp" : "2024-11-18 11:35:27","hangup_cause" : "","billsec" : "","digits_dialed" : "","duration" : "","answered_agent":{"id":"0505543550003","name":"Vinay","number":"0605543550003","agent_number":"+912564789658"},"answered_agent_name" : "","missed_agent" : "","broadcast_lead_fields" : "","recording_url" : "","outbound_sec" : "","agent_ring_time" : "","agent_transfer_ring_time" : "","call_connected" : "","aws_call_recording_identifier" : "","campaign_name" : "","campaign_id" : "","reason_key" : "Extension_Not_Registered","recordId" : "' + acc.Id + '"}';
        req1.requestBody =Blob.valueOf(body1);
        RestContext.request = req1;
        RestContext.response = res1; 
        TataWebhook.createTask();
        
        RestRequest req2 = new RestRequest();
        RestResponse res2 = new RestResponse();
        req2.requestURI = 'https://runwal.my.salesforce-sites.com/tataWebhook/services/apexrest/tataWebhook'; 
        req2.httpMethod = 'Post';
        req2.addHeader('Content-Type', 'application/json'); 
        String body2 = '{"uuid" : "","call_to_number" : "","caller_id_number" : "","date" : "","call_flow" : "","dept_name" : "","ivr_name" : "","call_id" : "","billing_circle" : "","agent_number" : "","agent_name" : "","customer_no_with_prefix" : "+912356478568","start_stamp" : "","direction" : "outbound","answered_agent_number" : "","call_status" : "","customer_ring_time" : "","answer_stamp" : "","end_stamp" : "2024-11-18 11:35:27","hangup_cause" : "","billsec" : "","digits_dialed" : "","duration" : "","answered_agent" : "","answered_agent_name" : "","missed_agent" : [{"id":"0505543550004","name":"Test","number":"0605543550004","agent_number":"02356478568","time":1731583367,"extension":"0605543550004"}],"broadcast_lead_fields" : "","recording_url" : "","outbound_sec" : "","agent_ring_time" : "","agent_transfer_ring_time" : "","call_connected" : "","aws_call_recording_identifier" : "","campaign_name" : "","campaign_id" : "","reason_key" : "","recordId" : ""}';
        req2.requestBody =Blob.valueOf(body2);
        RestContext.request = req2;
        RestContext.response = res2; 
        TataWebhook.createTask();
        
        RestRequest req3 = new RestRequest();
        RestResponse res3 = new RestResponse();
        req3.requestURI = 'https://runwal.my.salesforce-sites.com/tataWebhook/services/apexrest/tataWebhook'; 
        req3.httpMethod = 'Post';
        req3.addHeader('Content-Type', 'application/json'); 
        String body3 = '{"uuid" : "","call_to_number" : "","caller_id_number" : "","date" : "","call_flow" : "","dept_name" : "","ivr_name" : "","call_id" : "","billing_circle" : "","agent_number" : "","agent_name" : "","customer_no_with_prefix" : "+912356478569","start_stamp" : "","direction" : "inbound","answered_agent_number" : "","call_status" : "","customer_ring_time" : "","answer_stamp" : "","end_stamp" : "2024-11-18 11:35:27","hangup_cause" : "","billsec" : "","digits_dialed" : "","duration" : "","answered_agent" : "","answered_agent_name" : "","missed_agent" : "","broadcast_lead_fields" : "","recording_url" : "","outbound_sec" : "","agent_ring_time" : "","agent_transfer_ring_time" : "","call_connected" : "","aws_call_recording_identifier" : "","campaign_name" : "","campaign_id" : "","reason_key" : "","recordId" : ""}';
        req3.requestBody =Blob.valueOf(body3);
        RestContext.request = req3;
        RestContext.response = res3; 
        TataWebhook.createTask();
        
        
    }
    
    @isTest
    public static void testTataWebhook2(){
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Mobile_No__c = '2356478568';
        acc.RM_Name__c = 'Aakash Motwani';
        insert acc;
        
        Project__c proj = new Project__c();
        proj.Name = '7 Mahalaxmi';
        insert proj;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.AccountId = acc.Id;
        opp.StageName = 'Qualification';
        opp.CloseDate = Date.today() + 10;
        opp.RW_Mobile_No__c = '2356478567';
        opp.RW_Email__c = 'test@mail.com';
        opp.RW_Project__c = proj.Id;
        opp.RW_RM_Name__c = 'Aakash Motwani';
        insert opp;
        
        
        RestRequest req2 = new RestRequest();
        RestResponse res2 = new RestResponse();
        req2.requestURI = 'https://runwal.my.salesforce-sites.com/tataWebhook/services/apexrest/tataWebhook'; 
        req2.httpMethod = 'Post';
        req2.addHeader('Content-Type', 'application/json'); 
        String body2 = '{"uuid" : "","call_to_number" : "","caller_id_number" : "","date" : "","call_flow" : "","dept_name" : "","ivr_name" : "","call_id" : "","billing_circle" : "","agent_number" : "","agent_name" : "","customer_no_with_prefix" : "+912356478568","start_stamp" : "","direction" : "outbound","answered_agent_number" : "","call_status" : "missed","customer_ring_time" : "","answer_stamp" : "","end_stamp" : "2024-11-18 11:35:27","hangup_cause" : "","billsec" : "","digits_dialed" : "","duration" : "","answered_agent" : "","answered_agent_name" : "","missed_agent" : "","broadcast_lead_fields" : "","recording_url" : "","outbound_sec" : "","agent_ring_time" : "","agent_transfer_ring_time" : "","call_connected" : "","aws_call_recording_identifier" : "","campaign_name" : "","campaign_id" : "","reason_key" : "","recordId" : "' + opp.Id + '"}';
        req2.requestBody =Blob.valueOf(body2);
        RestContext.request = req2;
        RestContext.response = res2; 
        TataWebhook.createTask();
        
        
    }

    
}