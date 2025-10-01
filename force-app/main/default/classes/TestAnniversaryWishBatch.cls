@isTest
private class TestAnniversaryWishBatch 
{
    @isTest
    private static void anniWishBatch()
    {    Account a=new Account();
        a.FirstName='test';
        a.LastName='test2';
        a.PersonEmail='abc@xyz.com';
        a.Mobile_No__c='12345';
        insert a;
       
        Project__c pro=new Project__c();
        pro.Name='Runwal Bliss';
        pro.RW_Project_Code__c='3';
       // pro.RDS_Company_Code__c='abcd';
        pro.Project_Property_Type__c='';
        pro.RW_Status__c='Active';
        insert pro;
        
        Opportunity opty=new Opportunity();
        opty.RW_Project__c=pro.id;
        opty.Name='test';
        opty.AccountId=a.id;
        opty.RW_Email__c='abc@xyz.com';
        opty.StageName='Qualification';
        opty.RW_Mobile_No__c='12345';
        opty.CloseDate=system.today();
        opty.RW_Rating__c='warm';
        opty.Remark__c='Test';
        opty.LeadSource='TV';
        insert opty;   

        Applicant_Details__c ad = new Applicant_Details__c();
        ad.Name='Test';
        ad.Anniversary__c=System.today();
        ad.Subtype_Of_Applicant__c='For NRI';
        ad.Permanent_Address__c ='abc';
        ad.Organisation_Pincode__c=123456;
        ad.Mailing_Pincode__c =234567;
        ad.Organisation_Country__c ='india';
        ad.Mailing_Country__c ='india';
        ad.Mobile_Number__c= '1234567899';
        ad.Email_Address__c='abc@xyz.com';
        ad.Nationality__c='India';
        insert ad;
        
         task t = new task();
        t.WhatId = opty.id;
        //t.OwnerId = opty.OwnerId;
        t.activityDate = System.today();
        t.Call_Time__c = System.Now().format('h:mm a');
        t.status = 'open';
        t.Subject = 'Anniversary Wish';
        t.priority = 'Normal';
        // t.ReminderDateTime = System.now().addHours(8);

        t.ReminderDateTime = System.now().addMinutes(2);

        t.IsReminderSet = true;
        insert t;
        
       list < Messaging.SingleEmailMessage > mail = new list < Messaging.SingleEmailMessage > ();
        
        Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
        

       
        Test.startTest();
             AnniversaryWishBatch bw = new  AnniversaryWishBatch();
            bw.execute(null); 
        
        
    }
}