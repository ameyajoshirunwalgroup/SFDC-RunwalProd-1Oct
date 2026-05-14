@isTest
public Class TestTaskSurvey {
  @isTest  
public static void TaskTest() {
             
     integer a = 0 ,b = 0 ,c = 0;
                        
        Survey_Template__c sTemp = new Survey_Template__c();
         sTemp.Name = 'Site Visit Survey Template';
         sTemp.Active__c = true;
         insert sTemp;
        
         Survey_Questions_Template__c sqTemp = new Survey_Questions_Template__c();
         //Survey_Questions_Template__c sqTemp1 = new Survey_Questions_Template__c();
         sqTemp.Survey_Template__c = sTemp.Id;
         sqTemp.RecordTypeId = Schema.SObjectType.Survey_Questions_Template__c.getRecordTypeInfosByName().get('Free Text Questions').getRecordTypeId();
         sqTemp.Name = 'Q1';
         sqTemp.Question_Number__c = 1;
         sqTemp.Question_Text__c = 'Your Comments';
         SqTemp.Type_of_Question__c =  'PROJECT FEEDBACK';
         insert sqTemp;
    
         Project__c Pro = new Project__c();
         pro.Name = 'Runwal Test 1';
         pro.RW_Project_Code__c = '180';
         //pro.Site_Visit_Survey_Template__c = sTemp.Id;
         pro.Booking_Template__c = sTemp.Id;
         pro.Send_SV_Survey__c = true;
         insert pro;
         
         Account acc = new Account();
         acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
         acc.FirstName = 'Chetan';
         acc.LastName = 'Bhuimbar';
         acc.Mobile_No__c = '9879879870';
         acc.PersonEmail = 'sarj@gmail.com';
         insert acc;
         
         Opportunity opp = new Opportunity();
         opp.Name = 'Test 123';
         opp.AccountId = acc.Id;
         opp.RW_Project__c = pro.Id;
         opp.StageName = 'Qualification';
         opp.CloseDate = system.today();
         opp.RW_Rating__c = 'Hot';
         opp.Remark__c = 'Test 123';
         opp.LeadSource = 'Digital';
         insert opp;
         update opp;
      
         Task t = new Task();
         t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Site Visit task').getRecordTypeId();
         t.WhoId = acc.personcontactId;
         t.Subject = 'Call';
         t.Status = 'Completed';
         t.Priority = 'Normal';
         t.Call_Rating__c = 'Hot';
         t.OwnerId = '00528000001G0TP';
         t.WhatId = opp.Id;
         t.ActivityDate = system.today();
         t.Visitor_Name__c = opp.Name;
         t.Next_Action_Date__c = system.now();
         t.Visited_With__c = 'Alone';
         t.Call_Time__c = '08:00 AM';
         t.Event_Status__c = 'Booked';
         t.Description = 'Testing';
         insert t;
        
         Survey_Expiry_Days__c ex = new Survey_Expiry_Days__c();
         ex.name = 'Expire';
         ex.Expiry_Days__c= 1;
         insert ex;
        
         Survey__c surobj = new Survey__c();
         surobj.RecordTypeId = Schema.SObjectType.Survey__c.getRecordTypeInfosByName().get('Site Visit Survey').getRecordTypeId();
         surobj.Active__c = opp.RW_Project__r.Site_Visit_Survey_Template__r.Active__c;
         surobj.Opportunity__c = opp.id;
         //surobj.Survey_Template__c = opp.RW_Project__r.Site_Visit_Survey_Template__r.id;
         //surobj.Survey_Type__c = 'Site Visit';
         surobj.Survey_For_Activity__c = 'Site Visit';
         surobj.Account_Email_for_Opportunity__c = opp.Account.PersonEmail;
         surobj.Account_Phone_for_Opportunity__c = opp.Account.PersonMobilePhone;
         surobj.Account_Name_for_Opportunity__c = opp.Account.Name;
         surobj.Mode__c = 'Email';
         String PageLink = System.label.Site_Url_New + '/SurveyPage?sid=';
         surobj.Survey_Link__c = PageLink + surobj.id;
         insert surobj;
                        
         Survey_Questions__c ques = new Survey_Questions__c();
         ques.RecordTypeId = Schema.SObjectType.Survey_Questions__c.getRecordTypeInfosByName().get('Picklist Questions').getRecordTypeId();
         //ques.Name = 'Q2';
         ques.Survey__c = surobj.Id;
         ques.Question_Number__c = 2;
         ques.Question_Text__c = 'Your Decision';
         ques.Type_of_Question__c =  'SITE EXPERIENCE';
         insert ques;
    
    	Booking__c bkg = new Booking__c();
        bkg.Opportunity__c = opp.Id;
        bkg.Customer__c = opp.Id;
        bkg.Status__c = 'Booking Received';
        bkg.Cancellation_Requested_Status__c = null;
        insert bkg;
        
        bkg.Status__c = 'Booking Confirmed';
        bkg.RW_Booking_Confirmed_Date__c = Date.today();
        update bkg;
 
  }
 

}