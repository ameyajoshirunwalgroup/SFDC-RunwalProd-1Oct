@IsTest
public class SendWhatsAppMsgForBatchTest {
    @IsTest
    public static void SendWhatsAppMsgForBatchTst(){
        Profile p = [Select Id, Name from Profile where Name = 'System Administrator'];
  
    String orgId = UserInfo.getOrganizationId();
    String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
    Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
    String uniqueName = orgId + dateString + randomInt;
    User tuser = new User(  firstname = 'TestUser1',
                            lastName = 'TestUser2',
                            email = uniqueName + orgId+ '@gmail' +'.com',
                            Username = uniqueName + '@test' + orgId + '.org',
                            EmailEncodingKey = 'ISO-8859-1',
                            Alias = uniqueName.substring(18, 23),
                            TimeZoneSidKey = 'America/Los_Angeles',
                            LocaleSidKey = 'en_US',
                            LanguageLocaleKey = 'en_US',
                            ProfileId = p.id
                            );
         insert tuser;
      
        Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.Sales_Site_Head__c = tuser.Id;
        objpr.SAPMaterial_Code__c = '1211';
        objpr.Project_CRM_Lead__c = tuser.Id;
        objpr.CRMHead__c = tuser.Id;
        objpr.Presales_TL__c = tuser.Id;
        objpr.RW_LocalityName__c = 'test';
        objpr.Site_Address_Map_Link__c = 'https://goo.gl/maps/ZH6QR3jwP3k4d6Cz7'; 
        objpr.RW_Project_Brochure_PublicUrl__c = 'https://goo.gl/maps/ZH6QR3jwP3k4d6Cz7';
        objpr.RW_Project_Location_Videos_Link__c = 'https://goo.gl/maps/ZH6QR3jwP3k4d6Cz7';
       
        insert objpr;
    
       Account a = new Account();
        a.FirstName ='TestAccount1';
        a.LastName ='TestAccount2';
        a.PersonEmail = 'wc@email.com';
        a.City__c='TestCity';
        a.RW_Zip_Code__c = '999999';
        a.State__c ='Karnataka';
        a.Country__c ='India';
        a.Mobile_No__c = '9876543212';
        a.Alternate_Email__c = 'wc1@email.com';
        a.Gender__c='Male';
        a.Salutation = 'Mr.';
        a.Birth_Date__c = System.today().addYears(-20);   
        insert a;
    
        
        Broker__c br = new Broker__c();
        br.Name = 'Test';
        br.SAP_CP_Code__c = '1000';
        br.Broker_Pan_No__c = 'SDRIP5776F';
        insert br;
        
        List<Lead> lstLead = new List<Lead>();
        Lead objLead = new Lead();
        objLead.LastName = 'testLast';
        objLead.Email = 'test1@test.com';
        objLead.RW_Mobile_No__c = '1221122100';
        objLead.Remark__c = 'testRemark';
        objLead.RW_Project__c = objpr.Id;
        objLead.RW_Rating__c = 'Hot';
        objLead.Lead_Source__c = 'Channel Partner';
        objLead.LeadSource = 'Channel Partner';
        objLead.Status = 'Not Sure';
        objLead.Customer_Reference__c = a.Id;
        objLead.Country__c = 'India';
        objLead.State__c = 'Odisha';
        objLead.City__c = 'Bhubaneshwar';
        objLead.RW_Budget__c = '< 1Cr';
        objLead.RW_Configuration__c = '1.5 BHK';
        objLead.RW_Location__c = 'MANGLAUR';
        objLead.RW_Time_line__c = 'Ready Possession';
        objLead.RW_Mobile_No__c= '8000000123';
        //objLead.RW_Referral_Lead__c= reffList[0].Id;
        objLead.RW_Broker__c = br.Id;
        //objLead.RW_Batch_Lead_Check__c = True;
        lstLead.add(objLead);
        insert lstLead;
   
        Task objTask = new Task();
        objTask.Type = 'Presales Call';
        objTask.Call_Status__c = 'Connected';
        objTask.Call_Disposition_Custom__c = 'Interested';
        objTask.Call_Proposed_date_of_visit__c = System.Today();
        objTask.WhoId = lstLead[0].Id;
        Insert objTask;
        
        Task objTask1 = new Task();
        objTask1.Type = 'Presales Call';
        objTask1.Call_Status__c = 'Not Connected';
        objTask1.Call_Disposition_Custom__c = 'Number Busy';
        objTask1.Call_Proposed_date_of_visit__c = System.Today();
        objTask1.WhoId = lstLead[0].Id;
        Insert objTask1;
        
        Task objTask2 = new Task();
        objTask2.Type = 'Presales Call';
        objTask2.Call_Status__c = 'Not Connected';
        objTask2.Call_Disposition_Custom__c = 'Not Answering';
        objTask2.Call_Proposed_date_of_visit__c = System.Today();
        objTask2.WhoId = lstLead[0].Id;
        Insert objTask2;
        
        Task objTask3 = new Task();
        objTask3.Type = 'Presales Call';
        objTask3.Call_Status__c = 'Connected';
        objTask3.Call_Disposition_Custom__c = 'Visit Scheduled';
        objTask3.Call_Proposed_date_of_visit__c = System.Today() +2;
        objTask3.WhoId = lstLead[0].Id;
        Insert objTask3;
        
       Team__c tem = new Team__c();
        tem.Name = 'Presales TL';
        tem.Project__c = objpr.Id;
        tem.Team_Type__c= 'Presales TL';
        insert tem;
        
        Team_Members__c temMbr = new Team_Members__c();
        temMbr.Team__c = tem.Id;
        temMbr.User__c = tuser.Id;
        temMbr.User_Active__c  =true;
        insert temMbr;
        
        SendEmailWhatsAppToLeadsLimit__c setting = new SendEmailWhatsAppToLeadsLimit__c();
        setting.Name = 'SendEmailWhatsAppLimit';
        setting.Limit__c = 1000;
        insert setting;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        //SendWhatsAppMsgForBatch.genaricMethodToSendWhatsAppMsgForBatch(objLead.Id, System.Label.Lead_Project_Content2_HSM); //Commented by Vinay 29-08-2025
        //SendWhatsAppMsg.genaricMethodToSendWhatsAppMsg('param1', 'param2', 'param3', 'param4', 'param5', 'param6', 'param7','param8','param9', '8989898989', System.Label.Lead_Project_Content_HSM); //Commented by Vinay 29-08-2025
        //SendWhatsAppMsg.genaricMethodToSendWhatsAppMsgBatch('param1', 'param2', 'param3', 'param4', 'param5', 'param6', 'param7','param8','param9', '8989898989', System.Label.Lead_Project_Content_HSM); //Commented by Vinay 29-08-2025
        SendWhatsAppMsg.methodToSendWhatsAppMsg('Test', null, null, null, null, null, null, null, null, '+91', '8989898989', 'welcome_call_ov');
        SendWhatsAppMsg.methodToSendWhatsAppMsgBatch('Test', null, null, null, null, null, null, null, null, '+91', '8989898989', 'welcome_call_ov');
        SendWhatsAppMsg.methodTofetchLeadforSendingWhatsAppMsg(new List<String>{lstLead[0].Id});
        SendWhatsAppMsg.dummyMethod();
        SendWhatsAppMsgOnVisitDay.methodTofetchLeadFromScheduledFlow(new List<String>{lstLead[0].Id});
        SendWhatsAppMsgOnVisitDay.dummyMethod();
        SendWhatsAppMsgForScheduledTime.methodTofetchLeadFromScheduledFlow(new List<String>{lstLead[0].Id});
        SendWhatsAppMsgForScheduledTime.dummyMethod();
      //  WhatsAppMSGForNewLeadTriggerHandler.sendWelcomeWhatsAppMsg(new List<String>{lstLead[0].Id});
        system.enqueuejob(new WhatsAppMSGForNewLeadTriggerHandler(new List<String>{lstLead[0].Id}));
        WhatsAppMSGForNewLeadTriggerHandler.dummyMethod();
        Test.stopTest();
    }
}