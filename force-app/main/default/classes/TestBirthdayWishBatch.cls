@isTest
private class TestBirthdayWishBatch 
{
    @istest
    private static void birthdaywishtest(){
        
        Account a=new Account();
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
        opty.StageName='Unit Booked';
        opty.RW_Mobile_No__c='12345';
        opty.CloseDate=system.today();
        opty.RW_Rating__c='warm';
        opty.Remark__c='Test';
        opty.LeadSource='TV';
        insert opty;   

        Applicant_Details__c ad = new Applicant_Details__c();
        ad.Name='Test';
        ad.Opportunity__c = opty.Id;
        ad.DOB__c=System.today();
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
        
        Vendor__c ven = new Vendor__c();
        ven.Name = 'Test';
        ven.Param_1_Name__c = 'username';
        ven.Param_1_Status__c = true;
        ven.Param_1_Value__c = 'runwal';
        ven.Param_2_Name__c = 'password';
        ven.Param_2_Status__c = true;
        ven.Param_2_Value__c = 'password';
        ven.Param_3_Name__c = 'to';
        ven.Param_3_Status__c = true;
        ven.Param_4_Name__c = 'from';
        ven.Param_4_Status__c = true;
        ven.Param_4_Value__c = 'Test';
        ven.Param_5_Name__c = 'text';
        ven.Param_5_Status__c = true;
        ven.Param_6_Status__c = true;
        ven.Vendor_Status__c = true;
        ven.Vendor_URL__c = 'http://sms';
        insert ven;

        
        
       list < Messaging.SingleEmailMessage > mail = new list < Messaging.SingleEmailMessage > ();
        
        Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
        
       // mail1.setToAddresses(List<String> )

       
        Test.startTest();
            BirthdayWishBatch bw = new BirthdayWishBatch();
            bw.execute(null); 
    }
    
    @istest
    private static void PaymentDueAlertScheduleTest(){
        
        Account a=new Account();
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
        opty.StageName='Unit Booked';
        opty.RW_Mobile_No__c='12345';
        opty.CloseDate=system.today();
        opty.RW_Rating__c='warm';
        opty.Remark__c='Test';
        opty.LeadSource='TV';
        opty.SAP_Customer_Number__c = '123456';
        insert opty;   

        
        Booking__c objBking = new Booking__c();
        objBking.Customer__c = opty.Id;
        objBking.Project__c = pro.Id;
        objBking.Opportunity__c = opty.Id;
        objBking.Booking_Date__c = Date.today().addDays(-1);
        objBking.Status__c ='Booking Confirmed';
        objBking.Source_of_Booking__c='Direct';
        objBking.Carpet_Area__c=23;
        objBking.Primary_Applicant_Email__c = 'test@gmail.com';
        objBking.FBL5N__c = 1000;
        insert objBking;
        opty.Booking__c = objBking.Id;
        update opty;
        
        
       
        Test.startTest();
        PaymentDueAlertSchedule bw = new PaymentDueAlertSchedule(new List<String>{'123456'});
        database.executeBatch(bw,200);
        bw.execute(null); 
        Test.stopTest();
    }
    
    @istest
    private static void PaymentDueAlertWhatsAppScheduleTest(){
        
        Account a=new Account();
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
        opty.StageName='Unit Booked';
        opty.RW_Mobile_No__c='12345';
        opty.CloseDate=system.today();
        opty.RW_Rating__c='warm';
        opty.Remark__c='Test';
        opty.LeadSource='TV';
        opty.SAP_Customer_Number__c = '123456';
        opty.Payment_Due_Alert_Date__c = Date.today();
        insert opty;   

        
        Booking__c objBking = new Booking__c();
        objBking.Customer__c = opty.Id;
        objBking.Project__c = pro.Id;
        objBking.Opportunity__c = opty.Id;
        objBking.Booking_Date__c = Date.today().addDays(-1);
        objBking.Status__c ='Booking Confirmed';
        objBking.Source_of_Booking__c='Direct';
        objBking.Carpet_Area__c=23;
        objBking.Primary_Applicant_Email__c = 'test@gmail.com';
        objBking.FBL5N__c = 100000;
        insert objBking;
        opty.Booking__c = objBking.Id;
        update opty;
        
        
       
        Test.startTest();
        PaymentDueWhatsAppAlertSchedule bw = new PaymentDueWhatsAppAlertSchedule();
        database.executeBatch(bw,200);
        bw.execute(null); 
        Test.stopTest();
    }
    
    @istest
    private static void NewsLetterScheduleTest(){
        
        Account a=new Account();
        a.FirstName='test';
        a.LastName='test2';
        a.PersonEmail='abc@xyz.com';
        a.Mobile_No__c='12345';
        insert a;
       
        Opportunity opty=new Opportunity();
        //opty.RW_Project__c=pro.id;
        opty.Name='test';
        opty.AccountId=a.id;
        opty.RW_Email__c='abc@xyz.com';
        opty.StageName='Unit Booked';
        opty.RW_Mobile_No__c='12345';
        opty.CloseDate=system.today();
        opty.RW_Rating__c='warm';
        opty.Remark__c='Test';
        opty.LeadSource='TV';
        opty.SAP_Customer_Number__c = '123456';
        opty.News_Letter_Date__c = Date.today();
        opty.Primary_Name__c = 'Mr..Test';
        insert opty;   

        Test.startTest();
        NewsLetterSchedule bw = new NewsLetterSchedule();
        database.executeBatch(bw,100);
        bw.execute(null); 
        Test.stopTest();
    }
        
}