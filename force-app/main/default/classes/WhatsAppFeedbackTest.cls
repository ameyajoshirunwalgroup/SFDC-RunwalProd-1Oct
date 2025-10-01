@isTest
public class WhatsAppFeedbackTest {

    @isTest
    public static void fbTest(){
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.RW_Email__c = 'test@mail.com';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.AccountId = acc.Id;
        opp.RW_Mobile_No__c = '9874563210';
        opp.RW_Email__c = 'test@mail.com';
        opp.StageName = 'Unit Booked';
        opp.SAP_Customer_Number__c = '0020012345';
        opp.CloseDate = Date.today() + 10;
        insert opp;
        
        
        WhatsApp_Campaign__c camp = new WhatsApp_Campaign__c();
        camp.Campaign_Name__c = 'Post possession - customers';
        camp.Active__c = true;
        insert camp;
        
        
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'https://runwal--uat.my.salesforce.com/services/apexrest/whatsappFb';
        req.httpMethod = 'Get';
        req.params.put('type', 'Case closure');
        req.params.put('mobile', opp.RW_Mobile_No__c);
        req.params.put('crn', '');
        Test.startTest();
        RestContext.request = req;
        WhatsAppFeedback.doGet();
        req.params.put('type', 'Day of Registration');
        req.params.put('crn', '');
        RestContext.request = req;
        WhatsAppFeedback.doGet();
        req.params.put('type', 'Day of Registration');
        req.params.put('crn', opp.SAP_Customer_Number__c);
        RestContext.request = req;
        WhatsAppFeedback.doGet();
        req.params.put('type', 'Day of Possession Handover');
        req.params.put('crn', '');
        RestContext.request = req;
        WhatsAppFeedback.doGet();
        req.params.put('type', 'Day of Possession Handover');
        req.params.put('crn', opp.SAP_Customer_Number__c);
        RestContext.request = req;
        WhatsAppFeedback.doGet();
        req.params.put('type', 'Post Possession Handover');
        req.params.put('crn', opp.SAP_Customer_Number__c);
        RestContext.request = req;
        WhatsAppFeedback.doGet();
        req.params.put('type', 'Call Disposition');
        req.params.put('crn', opp.SAP_Customer_Number__c);
        RestContext.request = req;
        WhatsAppFeedback.doGet();
        req.params.put('type', 'Generic Feedback');
        req.params.put('crn', opp.SAP_Customer_Number__c);
        req.params.put('camp', camp.Id);
        RestContext.request = req;
        WhatsAppFeedback.doGet();
        req.params.put('type', 'Generic Feedback');
        req.params.put('crn', '');
        req.params.put('camp', camp.Id);
        RestContext.request = req;
        WhatsAppFeedback.doGet();
        
        String jsonRespose1 = '{"feedbackType": "Case closure","mobile":"","crn":"","qa":{"Question1":"Answer1"}}';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonRespose1);
        RestContext.request = req;
        RestContext.response = res;
        WhatsAppFeedback.doPost();
        
		String jsonRespose2 = '{"feedbackType": "Day of Registration","mobile":"","crn":"","qa":{"Question1":"Answer1"}}';
        req.requestBody = Blob.valueof(jsonRespose2);
        RestContext.request = req;
        RestContext.response = res;
        WhatsAppFeedback.doPost();
        
        String jsonRespose3 = '{"feedbackType": "Day of Possession Handover","mobile":"","crn":"","qa":{"Question1":"Answer1"}}';
        req.requestBody = Blob.valueof(jsonRespose3);
        RestContext.request = req;
        RestContext.response = res;
        WhatsAppFeedback.doPost();
        
        String jsonRespose4 = '{"feedbackType": "Post Possession Handover","mobile":"","crn":"0020012345","qa":{"Question1":"Answer1"}}';
        req.requestBody = Blob.valueof(jsonRespose4);
        RestContext.request = req;
        RestContext.response = res;
        WhatsAppFeedback.doPost();
        
        String jsonRespose5 = '{"feedbackType": "Generic Feedback","mobile":"","crn":"","campaign":"'+ camp.Id +'","qa":{"Question1":"Answer1"}}';
        req.requestBody = Blob.valueof(jsonRespose5);
        RestContext.request = req;
        RestContext.response = res;
        WhatsAppFeedback.doPost();
        
        String jsonRespose6 = '{"feedbackType": "Sales Experience","mobile":"","crn":"","qa":{"Question1":"Answer1"}}';
        req.requestBody = Blob.valueof(jsonRespose6);
        RestContext.request = req;
        RestContext.response = res;
        WhatsAppFeedback.doPost();
        
        
        Test.stopTest();
    }
    
    @isTest
    public static void fbReportTest1(){
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        User testUser = new User(
            Alias = 'testuser', 
            Email = 'newcase@gmail.com', 
            EmailEncodingKey = 'UTF-8', 
            LastName = 'User', 
            LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', 
            ProfileId = p.Id, FirstName='test',
            TimeZoneSidKey = 'America/Los_Angeles', 
            UserName = 'newcase@gmail.com'
        );
        insert testUser;
        Project__c proj1 = new Project__c();
        proj1.Name = 'Runwal MyCity';
        insert proj1;
        
        Project__c proj2 = new Project__c();
        proj2.Name = 'Runwal Gardens';
        insert proj2;
        
        Project__c proj3 = new Project__c();
        proj3.Name = 'Runwal Bliss';
        insert proj3;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.AccountId = acc.Id;
        opp.RW_Mobile_No__c = '9874563210';
        opp.RW_Email__c = 'test@mail.com';
        opp.StageName = 'Unit Booked';
        opp.SAP_Customer_Number__c = '0020012345';
        opp.RW_Project__c = proj2.Id;
        opp.CloseDate = Date.today() + 10;
        insert opp;
        
        WhatsApp_Feedback__c fb1 = new WhatsApp_Feedback__c();
        fb1.Feedback_Type__c = 'Day of Registration';
        fb1.Answer_2__c = 'Excellent';
        fb1.Answer_3__c = 'Very Good';
        fb1.Answer_4__c = 'Good';
        fb1.Answer_5__c = 'Bad';
        fb1.Answer_7__c = 'Excellent';
        fb1.Answer_8__c = 'Very Good';
        fb1.Answer_9__c = 'Good';
        fb1.Answer_10__c = 'Bad';
        fb1.Answer_6__c = '10';
        fb1.Opportunity__c = opp.Id;
        insert fb1;
        
        WhatsApp_Feedback__c fb2 = new WhatsApp_Feedback__c();
        fb2.Feedback_Type__c = 'Day of Possession Handover';
        fb2.Answer_13__c = 'Excellent';
        fb2.Answer_14__c = 'Very Good';
        fb2.Answer_15__c = 'Good';
        fb2.Answer_16__c = 'Bad';
        fb2.Answer_17__c = 'Excellent';
        fb2.Answer_18__c = 'Very Good';
        fb2.Answer_20__c = '09';
        fb2.Opportunity__c = opp.Id;
        insert fb2;
        
        WhatsApp_Feedback__c fb3 = new WhatsApp_Feedback__c();
        fb3.Feedback_Type__c = 'Post Possession Handover';
        fb3.Answer_21__c = 'Excellent';
        fb3.Answer_22__c = 'Very Good';
        fb3.Answer_23__c = 'Good';
        fb3.Answer_24__c = 'Bad';
        fb3.Answer_25__c = 'Excellent';
        fb3.Answer_26__c = 'Very Good';
        fb3.Answer_27__c = 'Good';
        fb3.Answer_29__c = '08';
        fb3.Opportunity__c = opp.Id;
        insert fb3;
        
        WhatsApp_Feedback__c fb4 = new WhatsApp_Feedback__c();
        fb4.Feedback_Type__c = 'Sales Experience';
        fb4.Sales_Experience_Answer_1__c = 'Excellent';
        fb4.Sales_Experience_Answer_2__c = 'Very Good';
        fb4.Sales_Experience_Answer_3__c = 'Good';
        fb4.Sales_Experience_Answer_4__c = 'Bad';
        fb4.Sales_Experience_Answer_5__c = 'Excellent';
        fb4.Sales_Experience_Answer_6__c = 'Very Good';
        fb4.Sales_Experience_Answer_7__c = 'Good';
        fb4.Opportunity__c = opp.Id;
        insert fb4;
         RecordType feedbackRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND Name = 'Customer Feedback' LIMIT 1];
        Case testCase2 = new Case(
            SuppliedEmail = 'test5@example.com',
            RW_Reporting_2_Email__c = 'test6@example.com',
            Description = 'Test Case 2',
            Subject = 'Test Subject 2',
            Status = 'Open',            RW_Case_Type__c='Complaint',
            RW_Complaint_Type__c='Legal Related',RW_Complaint_SubType__c='approvals related',
            AccountId = acc.Id,
            OwnerId = testUser.Id,
            CSAT_Feedback_Rating__c = 'Happy',
            RecordTypeId = feedbackRecordType.Id,
            RW_RM_Name__c='test',
            RW_Project__c=proj1.id
        );
        WhatsAppFeedbackBotReportsController.eventReport('Admin:All','','','');
        WhatsAppFeedbackBotReportsController.eventReport('Gardens:All','LAST_N_MONTHS:3','','');
        WhatsAppFeedbackBotReportsController.eventReport('Gardens:All','LAST_N_MONTHS:6','','');
        //WhatsAppFeedbackBotReportsController.remarksReport('','LAST_N_MONTHS:3');
        //WhatsAppFeedbackBotReportsController.remarksReport('Gardens','LAST_N_MONTHS:3');
        WhatsAppFeedbackBotReportsController.recordDetails('Day of Registration_Excellent','Gardens','LAST_N_MONTHS:3','','');
        WhatsAppFeedbackBotReportsController.recordDetails('Day of Registration_Very Good','Gardens','LAST_N_MONTHS:3','','');
        WhatsAppFeedbackBotReportsController.recordDetails('Day of Possession_Excellent','Gardens','LAST_N_MONTHS:6','','');
        WhatsAppFeedbackBotReportsController.recordDetails('Day of Possession_Good','Gardens','LAST_N_MONTHS:6','','');
        WhatsAppFeedbackBotReportsController.recordDetails('Post 60 Days Possession_Excellent','Mumbai','LAST_N_MONTHS:3','','');
        WhatsAppFeedbackBotReportsController.recordDetails('Post 60 Days Possession_Bad','Mumbai','LAST_N_MONTHS:3','','');
        WhatsAppFeedbackBotReportsController.recordDetails('Sales Experience_Bad','Mumbai','LAST_N_MONTHS:3','','');
        WhatsAppFeedbackBotReportsController.recordDetails('Sales Experience_Excellent','Mumbai','LAST_N_MONTHS:3','','');
        WhatsAppFeedbackBotReportsController.recordDetails('Sales Experience_Good','Mumbai','LAST_N_MONTHS:3','','');
        WhatsAppFeedbackBotReportsController.dayOfRegData('MyCity','LAST_N_MONTHS:3','','','Event',false);
        WhatsAppFeedbackBotReportsController.dayofPosData('MyCity','LAST_N_MONTHS:3','','','',false);
        WhatsAppFeedbackBotReportsController.postPosData('MyCity','LAST_N_MONTHS:3','','','',false);
        WhatsAppFeedbackBotReportsController.caseClosureData('Runwal MyCity','LAST_N_MONTHS:3','MyCity','','');
        WhatsAppFeedbackBotReportsController.callDispData('Runwal MyCity','LAST_N_MONTHS:3','MyCity','','');
        WhatsAppFeedbackBotReportsController.endOfBotData('Runwal MyCity','LAST_N_MONTHS:3', 'MyCity');
        WhatsAppFeedbackBotReportsController.npsReport('Admin:All','LAST_N_MONTHS:3','','');
        WhatsAppFeedbackBotReportsController.npsRecordDetails('MyCity_Day of Registration_10','Admin','LAST_N_MONTHS:3','','');
        WhatsAppFeedbackBotReportsController.userDetails();
        WhatsAppFeedbackBotReportsController.npsRecordDetailsPPD('MyCity_Day of Registration_promoters','Admin','LAST_N_MONTHS:3','','');
        WhatsAppFeedbackBotReportsController.overallDayOfRegData('Day of Registration_Excellent','Admin','LAST_N_MONTHS:3');
        WhatsAppFeedbackBotReportsController.dayOfRegNpsData('Runwal MyCity','LAST_N_MONTHS:3','MyCity','','');
        WhatsAppFeedbackBotReportsController.dayofPosNpsData('Runwal MyCity','LAST_N_MONTHS:3','MyCity','','');
        WhatsAppFeedbackBotReportsController.postPosNpsData('Runwal MyCity','LAST_N_MONTHS:3','MyCity','','');
        WhatsAppFeedbackBotReportsController.customerInsightsReport('Admin','','','');
        List<WhatsAppFeedbackBotReportsController.ProjectFeedbackWrapper> PFW=WhatsAppFeedbackBotReportsController.getProjectFeedback('LAST_N_MONTHS:3','','');   
        List<case> clist=WhatsAppFeedbackBotReportsController.getFilteredCases('{"Status":"Reopened","Project Name":"Runwal MyCity","RM Name":"janhavi tawade"}','LAST_N_MONTHS:3','','');
        List<case> clist1=WhatsAppFeedbackBotReportsController.getFilteredCases('{"Status":"Total case","Project Name":"Runwal MyCity","RM Name":"janhavi tawade"}','LAST_N_MONTHS:3','','');
        List<case> clist2=WhatsAppFeedbackBotReportsController.getFilteredCases('{"Status":"Total case","Project Name":"Runwal MyCity","RM Name":"janhavi tawade"}','Custom','2024','March');
        Map<Id,String> maplist= WhatsAppFeedbackBotReportsController.getUserIdToManagerNameMap();
        //WhatsAppFeedbackBotReportsController.getFeedbackData();
        WhatsAppFeedbackBotReportsController.dummyMethod();
    }
      
    @isTest
    public static void fbReportTest2(){
        WhatsApp_Feedback__c fb1 = new WhatsApp_Feedback__c();
        fb1.Feedback_Type__c = 'Day of Registration';
        fb1.Answer_2__c = 'Excellent';
        fb1.Answer_3__c = 'Very Good';
        fb1.Answer_4__c = 'Good';
        fb1.Answer_5__c = 'Bad';
        fb1.Answer_7__c = 'Excellent';
        fb1.Answer_8__c = 'Very Good';
        fb1.Answer_9__c = 'Good';
        fb1.Answer_10__c = 'Bad';
        fb1.Answer_6__c = '10';
        insert fb1;
        
        WhatsApp_Feedback__c fb2 = new WhatsApp_Feedback__c();
        fb2.Feedback_Type__c = 'Day of Possession Handover';
        fb2.Answer_13__c = 'Excellent';
        fb2.Answer_14__c = 'Very Good';
        fb2.Answer_15__c = 'Good';
        fb2.Answer_16__c = 'Bad';
        fb2.Answer_17__c = 'Excellent';
        fb2.Answer_18__c = 'Very Good';
        fb2.Answer_20__c = '09';
        insert fb2;
        
        WhatsApp_Feedback__c fb3 = new WhatsApp_Feedback__c();
        fb3.Feedback_Type__c = 'Post Possession Handover';
        fb3.Answer_21__c = 'Excellent';
        fb3.Answer_22__c = 'Very Good';
        fb3.Answer_23__c = 'Good';
        fb3.Answer_24__c = 'Bad';
        fb3.Answer_25__c = 'Excellent';
        fb3.Answer_26__c = 'Very Good';
        fb3.Answer_27__c = 'Good';
        fb3.Answer_29__c = '08';
        fb3.Camp_NPS__c = '08';
        fb3.Campaign_Name__c = 'Pre -possession post registration from August';
        insert fb3;
        
        /*WhatsApp_Feedback__c fb4 = new WhatsApp_Feedback__c();
        fb4.Feedback_Type__c = 'Case Closure';
        fb4.Answer_1__c = '10';
        insert fb4;
        
        WhatsApp_Feedback__c fb5 = new WhatsApp_Feedback__c();
        fb5.Feedback_Type__c = 'Call Disposition';
        fb5.Answer_1__c = '10';
        insert fb5;*/
        
        WhatsApp_Feedback__c fb6 = new WhatsApp_Feedback__c();
        fb6.Feedback_Type__c = 'Sales Experience';
        fb6.Sales_Experience_Answer_1__c = 'Excellent';
        fb6.Sales_Experience_Answer_2__c = 'Very Good';
        fb6.Sales_Experience_Answer_3__c = 'Good';
        fb6.Sales_Experience_Answer_4__c = 'Bad';
        fb6.Sales_Experience_Answer_5__c = 'Excellent';
        fb6.Sales_Experience_Answer_6__c = 'Very Good';
        fb6.Sales_Experience_Answer_7__c = 'Good';
        insert fb6;
        
        
        WhatsAppFeedbackBotReportsController.eventReport('Admin:All','LAST_N_MONTHS:3','','');
        WhatsAppFeedbackBotReportsController.eventReport('Gardens:All','LAST_N_MONTHS:3','','');
        WhatsAppFeedbackBotReportsController.eventReport('Gardens:All','LAST_N_MONTHS:6','','');
        //WhatsAppFeedbackBotReportsController.remarksReport('','LAST_N_MONTHS:3');
        //WhatsAppFeedbackBotReportsController.remarksReport('Gardens','LAST_N_MONTHS:3');
        WhatsAppFeedbackBotReportsController.recordDetails('Day of Possession_Excellent','Gardens','LAST_N_MONTHS:6','','');
        WhatsAppFeedbackBotReportsController.recordDetails('Day of Possession_Good','Gardens','LAST_N_MONTHS:6','','');
        WhatsAppFeedbackBotReportsController.recordDetails('Post 60 Days Possession_Excellent','Mumbai','LAST_N_MONTHS:3','','');
        WhatsAppFeedbackBotReportsController.recordDetails('Post 60 Days Possession_Bad','Mumbai','LAST_N_MONTHS:3','','');
        WhatsAppFeedbackBotReportsController.recordDetails('Post 60 Days Possession_Bad','Admin','LAST_N_MONTHS:3','','');
        WhatsAppFeedbackBotReportsController.recordDetails('Post 60 Days Possession_Bad','Dombivli','LAST_N_MONTHS:3','','');
        WhatsAppFeedbackBotReportsController.dayOfRegData('MyCity','LAST_N_MONTHS:3','','','',false);
        WhatsAppFeedbackBotReportsController.dayOfRegData('MyCity','','','','',false);
        WhatsAppFeedbackBotReportsController.dayofPosData('MyCity','LAST_N_MONTHS:3','','','',false);
        WhatsAppFeedbackBotReportsController.postPosData('MyCity','LAST_N_MONTHS:3','','','',false);
        WhatsAppFeedbackBotReportsController.salesExpData('MyCity','LAST_N_MONTHS:3','','','',false);
        WhatsAppFeedbackBotReportsController.caseClosureData('Runwal MyCity','LAST_N_MONTHS:3','MyCity','','');
        WhatsAppFeedbackBotReportsController.callDispData('Runwal MyCity','LAST_N_MONTHS:3','MyCity','','');
        WhatsAppFeedbackBotReportsController.endOfBotData('Runwal MyCity','LAST_N_MONTHS:3','MyCity');
        WhatsAppFeedbackBotReportsController.npsReport('MyCity:All','LAST_N_MONTHS:3','','');
        WhatsAppFeedbackBotReportsController.npsRecordDetails('MyCity_Day of Registration_10','Admin','LAST_N_MONTHS:3','','');
        WhatsAppFeedbackBotReportsController.npsRecordDetails('MyCity_Day of Registration_10','Admin','LAST_N_MONTHS:6','','');
        WhatsAppFeedbackBotReportsController.userDetails();
        WhatsAppFeedbackBotReportsController.npsRecordDetailsPPD('MyCity_Day of Registration_promoters','Admin','LAST_N_MONTHS:3','','');
        WhatsAppFeedbackBotReportsController.npsRecordDetailsPPD('MyCity_Day of Registration_passives','Admin','LAST_N_MONTHS:6','','');
        WhatsAppFeedbackBotReportsController.npsRecordDetailsPPD('MyCity_Day of Registration_detractors','Admin','','','');
        WhatsAppFeedbackBotReportsController.overallDayOfRegData('Day of Registration_Excellent','Mumbai','LAST_N_MONTHS:3');
         WhatsAppFeedbackBotReportsController.overallDayOfRegData('Day of Registration_Very Good','MyCity','LAST_N_MONTHS:3');
         WhatsAppFeedbackBotReportsController.overallDayOfRegData('Day of Registration_Good','Mumbai','LAST_N_MONTHS:6');
        WhatsAppFeedbackBotReportsController.overallDayOfRegData('Day of Registration_Good','Gardens','LAST_N_MONTHS:6');
        WhatsAppFeedbackBotReportsController.overallDayOfRegData('Day of Registration_Good','Dombivli','LAST_N_MONTHS:6');
        WhatsAppFeedbackBotReportsController.dayOfRegNpsData('Runwal MyCity','LAST_N_MONTHS:3','MyCity','','');
        WhatsAppFeedbackBotReportsController.dayofPosNpsData('Runwal MyCity','LAST_N_MONTHS:3','MyCity','','');
        WhatsAppFeedbackBotReportsController.postPosNpsData('Runwal MyCity','LAST_N_MONTHS:3','MyCity','','');
        WhatsAppFeedbackBotReportsController.salesExpNpsData('Runwal MyCity','LAST_N_MONTHS:3','MyCity','','');
        
        WhatsAppFeedbackBotReportsController.campaignDetails();
        WhatsAppFeedbackBotReportsController.campaignFBDetails('Pre -possession post registration from August');
        WhatsAppFeedbackBotReportsController.campaignFBQuestions('Pre -possession post registration from August');
        WhatsAppFeedbackBotReportsController.campaignReport('Pre -possession post registration from August');
        WhatsAppFeedbackBotReportsController.campaignRecDetails('Pre -possession post registration from August','Excellent');
        WhatsAppFeedbackBotReportsController.campaignNPS('Pre -possession post registration from August');
        WhatsAppFeedbackBotReportsController.campNpsRecordDetails('Pre -possession post registration from August_10');
    }
    
    @isTest
    public static void fbReportTest3(){
        WhatsApp_Feedback__c fb1 = new WhatsApp_Feedback__c();
        fb1.Feedback_Type__c = 'Day of Registration';
        fb1.Answer_2__c = 'Excellent';
        fb1.Answer_3__c = 'Very Good';
        fb1.Answer_4__c = 'Good';
        fb1.Answer_5__c = 'Bad';
        fb1.Answer_7__c = 'Excellent';
        fb1.Answer_8__c = 'Very Good';
        fb1.Answer_9__c = 'Good';
        fb1.Answer_10__c = 'Bad';
        fb1.Answer_6__c = '10';
        insert fb1;
        
        WhatsApp_Feedback__c fb2 = new WhatsApp_Feedback__c();
        fb2.Feedback_Type__c = 'Day of Possession Handover';
        fb2.Answer_13__c = 'Excellent';
        fb2.Answer_14__c = 'Very Good';
        fb2.Answer_15__c = 'Good';
        fb2.Answer_16__c = 'Bad';
        fb2.Answer_17__c = 'Excellent';
        fb2.Answer_18__c = 'Very Good';
        fb2.Answer_20__c = '09';
        insert fb2;
        
        WhatsApp_Feedback__c fb3 = new WhatsApp_Feedback__c();
        fb3.Feedback_Type__c = 'Post Possession Handover';
        fb3.Answer_21__c = 'Excellent';
        fb3.Answer_22__c = 'Very Good';
        fb3.Answer_23__c = 'Good';
        fb3.Answer_24__c = 'Bad';
        fb3.Answer_25__c = 'Excellent';
        fb3.Answer_26__c = 'Very Good';
        fb3.Answer_27__c = 'Good';
        fb3.Answer_29__c = '08';
        fb3.Camp_NPS__c = '08';
        fb3.Campaign_Name__c = 'Pre -possession post registration from August';
        insert fb3;
        String data = '{"grandTotal":"grandTotal"}';
        
        
        WhatsAppFeedbackBotReportsController.npsExport('MyCity:All','LAST_N_MONTHS:3','','');
        WhatsAppFeedbackBotReportsController.custInsExport('MyCity','LAST_N_MONTHS:3','','');
        WhatsAppFeedbackBotReportsController.campaignExport('Pre -possession post registration from August');
        WhatsAppFeedbackBotReportsController.npsMonthYear('MyCity','','');
        WhatsAppFeedbackBotReportsController.dayOfPosDataExport('MyCity','LAST_N_MONTHS:3','');
        WhatsAppFeedbackBotReportsController.postPosDataExport('MyCity','LAST_N_MONTHS:3','');
        WhatsAppFeedbackBotReportsController.caseClsDataExport('MyCity','LAST_N_MONTHS:3','');
        WhatsAppFeedbackBotReportsController.callDispDataExport('MyCity','LAST_N_MONTHS:3','');
        WhatsAppFeedbackBotReportsController.npsSummaryForYear('MyCity:All');
        WhatsAppFeedbackBotReportsController.custInstSummaryForYear('MyCity');
    }

}