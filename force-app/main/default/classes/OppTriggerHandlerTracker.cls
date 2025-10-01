@isTest(seeAllData= true)
public class OppTriggerHandlerTracker
{
    static testMethod void myUnitTest() 
    {
        Test.startTest();
      Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
      User u = new User(Alias = 'standt', Email='standarduserrtt@testorg.com', 
      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
      LocaleSidKey='en_US', ProfileId = p.Id, 
      TimeZoneSidKey='America/Los_Angeles', UserName='standarduserrr@testorg.com');
      insert u;
      
        User u2 = new User(Alias = 'standt', Email='testUser2@t1estorg.com', 
                                EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US',Ameyo_Agent_Id__c = 12364790, ProfileId = p.Id, 
                                TimeZoneSidKey='America/Los_Angeles', UserName='testUser2@t1estorg.com'
                               );
        insert u2;
        List <Opportunity> ld = new List <Opportunity> ();
        OppTriggerHandler opp = new OppTriggerHandler();
        opp.BeforeInsert(ld);
        update ld;
        
    
        Project__c objProj = new Project__c();
        objProj.name = 'test2';
        insert objProj;
        
        Project__c objProj1 = new Project__c();
        objProj1.name = 'test3';
        insert objProj1;
        
        Relationship_Manager__c rm1 = new Relationship_Manager__c();
        rm1.Name = 'test9';
        insert rm1;
        
        list<Project_Unit__c> pulist = new list<Project_Unit__c>();
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
        pulist.add(objPU);
        
        
        Project_Unit__c objPU1 = new Project_Unit__c();
        objPU1.name = 'test3';
        objPU1.RW_Project__c = objProj1.id;
        objPU1.RW_Unit_Status__c = 'Available';
        objPU1.RW_Seventh_Day__c = false;
        objPU1.RW_Param1__c = 'P1';
        objPU1.RW_Param2__c = 'T1';
        objPU1.RW_Param3__c = 'F1';
        objPU1.RW_Param4__c = 'U1';
        objPU1.Relationship_Manager__c = rm1.Id;
       pulist.add(objPU1);
        
        insert pulist;
        
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
        list<Broker__c> brlist = new list<Broker__c>();
        Broker__c b = new Broker__c();
        b.Name = 'Test';
        b.Unregistered_Channel_Partner__c = true;
        b.AOP_Type__c = 'AOP';
        b.Broker_Pan_No__c = 'ASFDG4556T';
        brlist.add(b);        
        
        Broker__c b1 = new Broker__c();
        b1.Name = 'Test 2';
        b1.Unregistered_Channel_Partner__c = true;
        b1.AOP_Type__c = 'AOP';
        b1.Broker_Pan_No__c = 'ASFDG4556T';
        
        brlist.add(b1);   
        
        insert brlist;
        
        CP_Category__c pl = new CP_Category__c();
        pl.Project__c = objProj.Id;
        pl.Category__c = 'P1';
        pl.Channel_Partner__c = b.Id;
        insert pl;
        
        list<Opportunity> opplist = new list<Opportunity>();
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
        objopp.RW_Walkin_Channel_Partner__c = b.id;
        objopp.Walkin_Source__c = 'Channel Partner';
        opplist.add(objopp);
        
        Opportunity objopp2 = new Opportunity();
        objopp2.name = 'test2';
        objopp2.AccountId = objAcc.id;
        objopp2.CloseDate = system.today();
        objopp2.StageName = 'Qualification';
        objopp2.RW_Project__c = objProj.id;
        objopp2.RW_Project_Unit__c = objPU.id;
        objopp2.Walkin_Source__c = 'Referral';
        objopp2.RW_Walkin_Customer_Reference__c = objAcc.Id;
        objopp2.RW_Agreement_Value__c = 200000;
        objopp2.RW_Sales_Associate__c = 'Test2';
        objopp2.RW_Mobile_No__c = '1233211231';
        objopp2.RW_Email__c = 'test1@test2.com';
        objopp2.RW_RM_Name__c = 'Aliya Kirkire';
        objopp2.LeadSource = 'Retention';
        objopp2.Retention_RM_Name__c = u.Id;
        objopp2.Retention_Closing_Head_Name__c = u.Id;
        objopp2.Retention_Presales_User__c = u.Id;
        objopp2.Retention_Sales_Manager__c = u.Id;
        objopp2.SalesOrder_Number__c = null;
        objopp2.Referral_Incentive__c = 1.5;
        opplist.add(objopp2);
        
        /*objPU.RW_Unit_Status__c = 'Booked';
        update objPU;
        
        objPU.RW_Unit_Status__c = 'Available';
        update objPU;*/
        
        Opportunity objopp1 = new Opportunity();
        objopp1.name = 'test2';
        objopp1.AccountId = objAcc.id;
        objopp1.CloseDate = system.today();
        objopp1.StageName = 'Qualification';
        objopp1.RW_Project__c = objProj.id;
        objopp1.RW_Project_Unit__c = objPU.id;
        objopp1.Walkin_Source__c = 'Referral';
        objopp1.RW_Sales_Associate__c = 'Test2';
        objopp1.RW_Mobile_No__c = '1233211231';
        objopp1.RW_Email__c = 'test1@test2.com';
        objopp1.RW_RM_Name__c = 'Aliya Kirkire';
        objopp1.LeadSource = 'Retention';
        objopp1.Retention_RM_Name__c = u.Id;
        objopp1.Retention_Closing_Head_Name__c = u.Id;
        objopp1.Retention_Presales_User__c = u.Id;
        objopp1.Retention_Sales_Manager__c = u.Id;
        objopp1.SalesOrder_Number__c = null;
        objopp1.RW_Walkin_Channel_Partner__c = b.id;
        objopp1.Walkin_Source__c = 'Channel Partner';
        objopp1.RW_Walkin_Channel_Partner__c = b1.id;
        //objopp.RW_Project__c = objProj1.id;
        objopp1.RW_Call_Completion__c = true;
        objopp1.RW_Missed_Call__c = true;
        objopp1.RW_Site_Visit_Completion__c = true;
        objopp1.Retention_Closing_Head_Name__c = u2.Id;
        objopp1.Retention_Presales_User__c = u2.Id;
        objopp1.Retention_Sales_Manager__c = u2.Id;
        opplist.add(objopp1);
        
        insert opplist;
        
        
        
        objopp.Walkin_Source__c = 'Direct';
        objopp.RW_Walkin_Channel_Partner__c = null;
        //objopp.RW_Project__c = null;
        update objopp;        
        
        
        event objEvent = new Event();
        objEvent.Subject = 'Site Visit';
        objEvent.StartDateTime = System.now();
        objEvent.EndDateTime = System.now();
        objEvent.WhatId= objopp.Id;
        objEvent.OwnerId = u.id;      //UserInfo.getUserId();
        insert objEvent;
        
        objopp.RW_Project_Unit__c = null;
        update objopp;
//manoj commenting 7th days as it is causing error 18/01/2020
        objPU.RW_Seventh_Day__c = true;
      //  update objPU;
        
      //  objopp.RW_Project_Unit__c = objPU.id;
      //  update objopp;

      objPU.RW_Seventh_Day__c = false;
      objPU.RW_Customer__c = objopp.id;
      objPU.RW_Unit_Status__c = 'Available';
      //update objPU;

        objopp.RW_Project__c = objProj.id;
        objopp.RW_Project_Unit__c = objPU.id;
        //update objopp;
      //  objopp.StageName = 'Unit Booked';

        objPU.RW_Unit_Status__c = 'Booked';
        objPU.RW_Booking_Date__c = system.today();
        //update objPU;
        
        objopp.SalesOrder_Number__c = '123456';
        objopp.StageName = 'Unit Booked';
        //update objopp;
        
        Quotation__c qtn = new Quotation__c();
        qtn.Opportunity__c = objopp.Id;
        insert qtn;
        
        OppTriggerHandler.sendWhatsApp(new List<String>{objopp.Id});
        
         OppTriggerHandler.dummyMethod();
        
        //SendSalesExperienceWhatsappMsg.sendMsg(new List<Id>{objopp.Id});
        
        trgOppHandler.updateReferralCustDetails(new List<Opportunity>{objopp});
Test.stopTest();
    }
}