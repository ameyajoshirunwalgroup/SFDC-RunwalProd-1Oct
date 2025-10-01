@isTest
public class OutboundSMSFutureHandlerTest {
    
    @isTest
    private static void testSendSMSOnOppCallCompletion(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
      User u = new User(Alias = 'standt', Email='standarduserrtt@testorg.com', 
      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
      LocaleSidKey='en_US', ProfileId = p.Id, 
      TimeZoneSidKey='America/Los_Angeles', UserName='standarduserrr@testorg.com');
      insert u;
        
    
        Project__c objProj = new Project__c();
        objProj.name = 'test2';
        insert objProj;
        
        Relationship_Manager__c rm1 = new Relationship_Manager__c();
        rm1.Name = 'test9';
        insert rm1;
        
        Project_Unit__c objPU = new Project_Unit__c();
        objPU.name = 'test2';
        objPU.RW_Project__c = objProj.id;
        objPU.RW_Param1__c = 'P1';
        objPU.RW_Param2__c = 'T1';
        objPU.RW_Param3__c = 'F1';
        objPU.RW_Param4__c = 'U1';
        objPU.RW_Unit_Status__c = 'Available';
        objPU.RW_Seventh_Day__c = false;
        objPU.Relationship_Manager__c = rm1.Id;
        insert objPU;
        
        RecordType personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'];
        
        Account objAcc = new Account();
        objAcc.lastname = 'test2';
        objAcc.PersonEmail = 'teststetigin@test.in';
        objAcc.RecordType = personAccountRecordType;
        objAcc.MasterRecord__c = true;
        insert objAcc;
        
        Opp_Close_Date__c dt = new Opp_Close_Date__c();
        dt.Project_Name__c = 'test2';
        dt.Name = objProj.Id;
        dt.No_of_Days__c = 45;
        insert dt;
        
        Opportunity objopp = new Opportunity();
        objopp.name = 'test2';
        objopp.AccountId = objAcc.id;
        objopp.CloseDate = system.today();
        objopp.StageName = 'Qualification';
        objopp.RW_Project__c = objProj.id;
        objopp.RW_Project_Unit__c = objPU.id;
        objopp.Walkin_Source__c = 'Referral';
        objopp.RW_Sales_Associate__c = 'Test2';
        objopp.RW_Mobile_No__c = '1233211231';
        objopp.RW_Email__c = 'test1@test2.com';
        objopp.RW_RM_Name__c = 'Aliya Kirkire';
        objopp.LeadSource = 'Retention';
        objopp.Retention_RM_Name__c = u.Id;
        objopp.Retention_Closing_Head_Name__c = u.Id;
        objopp.Retention_Presales_User__c = u.Id;
        objopp.Retention_Sales_Manager__c = u.Id;
        objopp.SalesOrder_Number__c = null;
        objopp.RW_Call_Completion__c = false;
        objopp.RW_Missed_Call__c = false;
        objopp.RW_Site_Visit_Completion__c = false;
        insert objopp;
        
        objopp.RW_Call_Completion__c = true;
        objopp.RW_Missed_Call__c = true;
        objopp.RW_Site_Visit_Completion__c = true;
        update objopp;
        
        event objEvent = new Event();
        objEvent.Subject = 'Site Visit';
        objEvent.StartDateTime = System.now();
        objEvent.EndDateTime = System.now();
        objEvent.WhatId= objopp.Id;
        objEvent.OwnerId = u.id;      //UserInfo.getUserId();
        insert objEvent;

        Task tsk = new Task();
        tsk.WhatId = objopp.Id;
        tsk.Disposition_Type__c = 'Success';
        insert tsk;
        
        OutboundSMSFutureHandler.SendSMSOnOppCallCompletionTask(new Set<Id>{tsk.Id});
        OutboundSMSFutureHandler.SendSMSOnOppProcess(new Set<Id>{objopp.Id});
        OutboundSMSFutureHandler.SendSMSOnOppCallCompletion(new Set<Id>{objopp.Id});
        OutboundSMSFutureHandler.SendSMSOnOppMissedCall(new Set<Id>{objopp.Id});
		OutboundSMSFutureHandler.SendSMSOnOppSiteVisitConfrm(new Set<Id>{objEvent.Id});
        OutboundSMSFutureHandler.SendSMSOnOppBooking(new Set<Id>{objPU.Id});
        
        AutocompleteV2Demo_con a = new AutocompleteV2Demo_con();
        a.targetField = 'Test';
    }

}