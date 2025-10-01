@IsTest public with sharing class PossessioncontrollerTest 
{
     @IsTest static void testSave() 
     {                           
         Survey_Template__c sTemp = new Survey_Template__c();
         sTemp.Name = 'Possession Template';
         sTemp.Active__c = true;
         insert sTemp;
         
         Survey_Questions_Template__c sqTemp = new Survey_Questions_Template__c();
         Survey_Questions_Template__c sqTemp1 = new Survey_Questions_Template__c();
         sqTemp.Survey_Template__c = sTemp.Id;
         sqTemp.RecordTypeId = Schema.SObjectType.Survey_Questions_Template__c.getRecordTypeInfosByName().get('Free Text Questions').getRecordTypeId();
         sqTemp.Name = 'Q1';
         sqTemp.Question_Number__c = 1;
         sqTemp.Question_Text__c = 'Your Comments';
         insert sqTemp;
         
         sqTemp1.Survey_Template__c = sTemp.Id;
         sqTemp1.RecordTypeId = Schema.SObjectType.Survey_Questions_Template__c.getRecordTypeInfosByName().get('Yes or No Questions').getRecordTypeId();
         sqTemp1.Name = 'Q2';
         sqTemp1.Question_Number__c = 2;
         sqTemp1.Question_Text__c = 'Your Decision';
         insert sqTemp1;
         
         
         Project__c Pro = new Project__c();
         pro.Name = 'Runwal Test 1';
         pro.RW_Project_Code__c = '180';
         pro.Possession_Template__c = sTemp.Id;
         insert pro;

         Relationship_Manager__c rms = new Relationship_Manager__c();
         rms.Project__c = pro.id;
         insert rms;
         
         Project_Unit__c punit = new Project_Unit__c();
         punit.Name = 'P101';
         punit.RW_Project__c = pro.Id;
         punit.RW_Unit_Status__c = 'Available';
         punit.RW_Param1__c = 'Runwal Test 1';
         punit.Relationship_Manager__c = rms.id;
         insert punit;
         
         Account acc = new Account();
         acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
         acc.FirstName = 'Chetan';
         acc.LastName = 'Bhuimbar';
         acc.Mobile_No__c = '9879879870';
         insert acc;
         
         Opportunity opp = new Opportunity();
         opp.Name = 'Test 123';
         opp.AccountId = acc.Id;
         opp.RW_Project__c = pro.Id;
         opp.RW_Email__c = 'Test@test.com';
         opp.StageName = 'Qualification';
         opp.CloseDate = system.today();
         opp.RW_Rating__c = 'Hot';
         opp.Remark__c = 'Test 123';
         opp.LeadSource = 'Digital';
         opp.RW_Possession_Done__c = FALSE;
         opp.RW_Project_Unit__c = punit.Id;
         insert opp;
         
         punit.RW_Unit_Status__c = 'Booked';
         punit.RW_Booking_Date__c = system.today();
         update punit;
         opp.RW_Possession_Done__c = TRUE;
         opp.StageName = 'Unit Booked';
         update opp;
         
         
         test.startTest();
         test.stopTest();
     }
     @IsTest static void testSave1()
     {
         Survey_Template__c sTemp = new Survey_Template__c();
         sTemp.Name = 'Possession Template';
         sTemp.Active__c = true;
         insert sTemp;
         
         Survey_Questions_Template__c sqTemp = new Survey_Questions_Template__c();
         Survey_Questions_Template__c sqTemp1 = new Survey_Questions_Template__c();
         sqTemp.Survey_Template__c = sTemp.Id;
         sqTemp.RecordTypeId = Schema.SObjectType.Survey_Questions_Template__c.getRecordTypeInfosByName().get('Free Text Questions').getRecordTypeId();
         sqTemp.Name = 'Q1';
         sqTemp.Question_Number__c = 1;
         sqTemp.Question_Text__c = 'Your Comments';
         insert sqTemp;
         
         sqTemp1.Survey_Template__c = sTemp.Id;
         sqTemp1.RecordTypeId = Schema.SObjectType.Survey_Questions_Template__c.getRecordTypeInfosByName().get('Yes or No Questions').getRecordTypeId();
         sqTemp1.Name = 'Q2';
         sqTemp1.Question_Number__c = 2;
         sqTemp1.Question_Text__c = 'Your Decision';
         insert sqTemp1;
         
         
         Project__c Pro = new Project__c();
         pro.Name = 'Runwal Test 1';
         pro.RW_Project_Code__c = '180';
         pro.Possession_Template__c = sTemp.Id;
         insert pro;

         Relationship_Manager__c rms = new Relationship_Manager__c();
         rms.Project__c = pro.id;
         insert rms;
         
         Project_Unit__c punit = new Project_Unit__c();
         punit.Name = 'P101';
         punit.RW_Project__c = pro.Id;
         punit.RW_Unit_Status__c = 'Available';
         punit.RW_Param1__c = 'Runwal Test 1';
         punit.Relationship_Manager__c = rms.id;
         insert punit;
         
         Account acc = new Account();
         acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
         acc.FirstName = 'Chetan';
         acc.LastName = 'Bhuimbar';
         acc.Mobile_No__c = '9879879870';
         insert acc;
         
         Opportunity opp = new Opportunity();
         opp.Name = 'Test 123';
         opp.AccountId = acc.Id;
         opp.RW_Project__c = pro.Id;
         opp.RW_Email__c = 'Test@test.com';
         opp.StageName = 'Qualification';
         opp.CloseDate = system.today();
         opp.RW_Rating__c = 'Hot';
         opp.Remark__c = 'Test 123';
         opp.LeadSource = 'Digital';
         opp.RW_Possession_Done__c = FALSE;
         opp.RW_Project_Unit__c = punit.Id;
         insert opp;
         
         punit.RW_Unit_Status__c = 'Booked';
         punit.RW_Booking_Date__c = system.today();
         update punit;
         opp.RW_Possession_Done__c = TRUE;
         opp.StageName = 'Unit Booked';
         update opp;
         
         Survey__c surobj = new Survey__c();
         surobj.RecordTypeId = Schema.SObjectType.Survey__c.getRecordTypeInfosByName().get('Possession Survey').getRecordTypeId();
         surobj.Active__c = opp.RW_Project__r.Possession_Template__r.Active__c;
         surobj.Opportunity__c = opp.id;
         surobj.Survey_Template__c = opp.RW_Project__r.Possession_Template__r.id;
         surobj.Survey_Type__c = 'Site Visit';
         surobj.Survey_For_Activity__c = 'Site Visit';
         surobj.Account_Email_for_Opportunity__c = opp.Account.PersonEmail;
         surobj.Account_Phone_for_Opportunity__c = opp.Account.PersonMobilePhone;
         surobj.Account_Name_for_Opportunity__c = opp.Account.Name;
         surobj.Mode__c = 'Both';
         String PageLink = 'http://devsb2-runwalsbhttps://runwal--ProdSb.cs5.my.salesforce.com/PossessionPage?sid=';
         surobj.Survey_Link__c = PageLink + surobj.id;
         surobj.Survey_Template__c = sTemp.Id;
         insert surobj;
         
         Survey_Questions__c ques = new Survey_Questions__c();
         ques.RecordTypeId = Schema.SObjectType.Survey_Questions__c.getRecordTypeInfosByName().get('Yes or No Questions').getRecordTypeId();
         //ques.Name = 'Q2';
         ques.Survey__c = surobj.Id;
         ques.Question_Number__c = 2;
         ques.Question_Text__c = 'Your Decision';
         //ques.Type_of_Question__c =  'SITE EXPERIENCE';
         insert ques;
         
         test.startTest();
         pageReference pageRef = page.PossessionPage;
         Test.setCurrentPage(pageRef);
         ApexPages.currentPage().getParameters().put('sid',surobj.Id);
         possessionController ps = new possessionController();
         ps.save();
         test.stopTest();

     }

}