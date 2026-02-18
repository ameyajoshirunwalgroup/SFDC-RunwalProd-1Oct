@isTest
public class LockatedApp_NotificationsTest {
    
    @isTest
    public static void nextStepsGuideNotificationTest(){
        Booking__c bkg = new Booking__c();
        bkg.Lockated_User_Device_ID__c = '123';
        bkg.RW_Booking_Confirmed_Date__c = Date.today() - 2;
        insert bkg;
        
        LockatedApp_NotificationsSchedule sch = new LockatedApp_NotificationsSchedule();
        sch.nextStepsGuideNotification();
        
        List<App_Notification__c> notifications = [SELECT Id,Notification_Type__c FROM App_Notification__c  WHERE Booking__c =: bkg.Id];
        
        System.assertEquals(1,notifications.size(),'Exactly one notification should be created');
        System.assertEquals('customer_guide_video',notifications[0].Notification_Type__c,'Notification type should be : customer_guide_video');
    }
    
    @isTest
    public static void ncfNotificationTest(){
        Booking__c bkg = new Booking__c();
        bkg.Lockated_User_Device_ID__c = '123';
        insert bkg;
        
        RW_Welcome_Call__c wc = new RW_Welcome_Call__c();
        wc.RW_Booking__c = bkg.id;
        wc.RW_Welcome_Call_Accepted_date__c = Date.today() -3;
        insert wc;
        
        LockatedApp_NotificationsSchedule sch = new LockatedApp_NotificationsSchedule();
        sch.ncfNotification();
        
        List<App_Notification__c> notifications = [SELECT Id,Notification_Type__c FROM App_Notification__c  WHERE Booking__c =: bkg.Id];
        
        System.assertEquals(1,notifications.size(),'Exactly one notification should be created');
        System.assertEquals('ncf_form',notifications[0].Notification_Type__c,'Notification type should be : ncf_form');
    }
    
    @isTest
    public static void clearanceOf5And10PercentTest(){
        Booking__c bkg = new Booking__c();
        bkg.Lockated_User_Device_ID__c = '123';
        bkg.RW_Booking_Confirmed_Date__c = Date.today() - 2;
        bkg.RW_Total_Receipt_Amount_Received__c = 60000;
        bkg.Allotment_Premium__c = 1000000;
        insert bkg;
        
        RW_Demand__c dem = new RW_Demand__c();
        dem.Booking__c = bkg.Id;
        insert dem;
            
        RW_Demand_Item__c demItem = new RW_Demand_Item__c();
        demItem.RW_Demand__c = dem.Id;
        demItem.RW_Demand_Item_Amount__c = 10000;
        demItem.RW_GST_Amount__c = 0;
        insert demItem;
        
        LockatedApp_NotificationsSchedule sch = new LockatedApp_NotificationsSchedule();
        sch.clearanceOf5And10PercentNotification();
        
        bkg.RW_Total_Receipt_Amount_Received__c = 110000;
        update bkg;
        
        LockatedApp_NotificationsSchedule sch1 = new LockatedApp_NotificationsSchedule();
        sch1.clearanceOf5And10PercentNotification();
    }
    
    @isTest
    public static void loanDocSubmissionNotificationTest(){
        Booking__c bkg = new Booking__c();
        bkg.Lockated_User_Device_ID__c = '123';
        bkg.RW_Booking_Confirmed_Date__c = Date.today() - 2;
        bkg.RW_Total_Receipt_Amount_Received__c = 60000;
        bkg.Allotment_Premium__c = 1000000;
        insert bkg;
        
        Loan__c loan = new Loan__c();
        loan.RW_Booking__c = bkg.Id;
        loan.Logged_In_Date__c = Date.today() - 3;
        loan.RW_Bank_Preference_1__c = 'Axis Bank Ltd';
        insert loan;
        
        LockatedApp_NotificationsSchedule sch = new LockatedApp_NotificationsSchedule();
        sch.loanDocSubmissionNotification();
    }

    @isTest
    public static void outstandingDueNotificationTest(){
        Booking__c bkg = new Booking__c();
        bkg.Lockated_User_Device_ID__c = '123';
        bkg.FBL5N__c = 60000;
        insert bkg;
        
        List<RW_Demand__c> demands = new List<RW_Demand__c>();
        RW_Demand__c dem1 = new RW_Demand__c();
        dem1.Booking__c = bkg.Id;
        dem1.Due_Date__c = Date.today() + 10;
        demands.add(dem1);
        
        RW_Demand__c dem2 = new RW_Demand__c();
        dem2.Booking__c = bkg.Id;
        dem2.Due_Date__c = Date.today() + 5;
        demands.add(dem2);
        
        RW_Demand__c dem3 = new RW_Demand__c();
        dem3.Booking__c = bkg.Id;
        dem3.Due_Date__c = Date.today();
        demands.add(dem3);
        
        RW_Demand__c dem4 = new RW_Demand__c();
        dem4.Booking__c = bkg.Id;
        dem4.Due_Date__c = Date.today() - 7;
        demands.add(dem4);
        insert demands;
        
        LockatedApp_NotificationsSchedule sch = new LockatedApp_NotificationsSchedule();
        sch.outstandingDueNotification();
    }
    
    @isTest
    public static void newsLetterNotificationTest(){
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.News_Letter_Date__c = Date.today();
        opp.CloseDate = Date.today() + 10;
        opp.StageName = 'Qualification';
        insert opp;
        
        Booking__c bkg = new Booking__c();
        bkg.Opportunity__c = opp.Id;
        bkg.Lockated_User_Device_ID__c = '123';
        insert bkg;
        
        opp.Booking__c = bkg.Id;
        update opp;
        
        LockatedApp_NotificationsSchedule sch = new LockatedApp_NotificationsSchedule();
        sch.newsLetterNotification();
    }
    
    @isTest
    public static void birthdayNotificationTest(){
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.News_Letter_Date__c = Date.today();
        opp.CloseDate = Date.today() + 10;
        opp.StageName = 'Unit Booked';
        insert opp;
        
        Booking__c bkg = new Booking__c();
        bkg.Opportunity__c = opp.Id;
        bkg.Customer__c = opp.Id;
        bkg.Lockated_User_Device_ID__c = '123';
        insert bkg;
        
        Applicant_Details__c app = new Applicant_Details__c();
        app.Booking__c = bkg.Id;
        app.Opportunity__c = opp.Id;
        app.DOB__c = Date.today();
        insert app;
        
        LockatedApp_NotificationsSchedule sch = new LockatedApp_NotificationsSchedule();
        sch.birthdayNotification();
    }

    @isTest
    public static void timeboundMilestoneNotificationTest(){
        
        Quotation__c q = new Quotation__c();
        q.Name = 'Test Quotation';
        insert q;
        
        Global_Charges__c gc = new Global_Charges__c();
        gc.Name = 'Basic';
        gc.Code__c = '100';
        insert gc;
        
        Customer_Pay_Plan_Header__c cpph = new Customer_Pay_Plan_Header__c();
        cpph.Quotation__c = q.Id;
        cpph.Global_Charges__c = gc.Id;
        insert cpph;
        
        List<Standard_Customer_Pay_Plan_Detail__c> scppdList = new List<Standard_Customer_Pay_Plan_Detail__c>();
        Standard_Customer_Pay_Plan_Detail__c scppd1 = new Standard_Customer_Pay_Plan_Detail__c();
        scppd1.Customer_Pay_Plan_Header__c = cpph.Id;
        scppd1.Due_Date__c = Date.today() - 10;
        scppd1.Is_to_be_Paid__c = 'From Dt. of Booking';
        scppdList.add(scppd1);
        
        Standard_Customer_Pay_Plan_Detail__c scppd2 = new Standard_Customer_Pay_Plan_Detail__c();
        scppd2.Customer_Pay_Plan_Header__c = cpph.Id;
        scppd2.Due_Date__c = Date.today() - 7;
        scppd2.Is_to_be_Paid__c = 'From Dt. of Booking';
        scppdList.add(scppd2);
        
        Standard_Customer_Pay_Plan_Detail__c scppd3 = new Standard_Customer_Pay_Plan_Detail__c();
        scppd3.Customer_Pay_Plan_Header__c = cpph.Id;
        scppd3.Due_Date__c = Date.today() - 5;
        scppd3.Is_to_be_Paid__c = 'From Dt. of Booking';
        scppdList.add(scppd3);
        
        Standard_Customer_Pay_Plan_Detail__c scppd4 = new Standard_Customer_Pay_Plan_Detail__c();
        scppd4.Customer_Pay_Plan_Header__c = cpph.Id;
        scppd4.Due_Date__c = Date.today();
        scppd4.Is_to_be_Paid__c = 'From Dt. of Booking';
        scppdList.add(scppd4);
        
        insert scppdList;
        
        Booking__c bkg = new Booking__c();
        bkg.Quotation__c = q.Id;
        bkg.Lockated_User_Device_ID__c = '123';
        bkg.Status__c  = 'Booking Confirmed';
        insert bkg;
        
        LockatedApp_NotificationsSchedule sch = new LockatedApp_NotificationsSchedule();
        sch.timeboundMilestoneNotification();
    }


    @isTest
    public static void paymentReminderNotificationTest(){
        Booking__c bkg = new Booking__c();
        bkg.Lockated_User_Device_ID__c = '123';
        bkg.FBL5N__c = 60000;
        insert bkg;
        
        List<RW_Demand__c> demands = new List<RW_Demand__c>();
        RW_Demand__c dem1 = new RW_Demand__c();
        dem1.Booking__c = bkg.Id;
        dem1.Due_Date__c = Date.today() + 10;
        demands.add(dem1);
        
        RW_Demand__c dem2 = new RW_Demand__c();
        dem2.Booking__c = bkg.Id;
        dem2.Due_Date__c = Date.today() + 7;
        demands.add(dem2);
        
        RW_Demand__c dem3 = new RW_Demand__c();
        dem3.Booking__c = bkg.Id;
        dem3.Due_Date__c = Date.today();
        demands.add(dem3);
        
        RW_Demand__c dem4 = new RW_Demand__c();
        dem4.Booking__c = bkg.Id;
        dem4.Due_Date__c = Date.today() + 5;
        demands.add(dem4);
        
        RW_Demand__c dem5 = new RW_Demand__c();
        dem5.Booking__c = bkg.Id;
        dem5.Due_Date__c = Date.today() - 4;
        demands.add(dem5);
        insert demands;
        
        LockatedApp_NotificationsSchedule sch = new LockatedApp_NotificationsSchedule();
        sch.paymentReminderNotification();
    }
    
    @isTest
    public static void refBkg20PercentPayedTest(){
        
        Booking__c refBkg = new Booking__c();
        refBkg.Lockated_User_Device_ID__c = '123';
        refBkg.RW_Booking_Confirmed_Date__c = Date.today() - 2;
        refBkg.RW_Total_Receipt_Amount_Received__c = 60000;
        refBkg.Allotment_Premium__c = 100000;
        insert refBkg;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.News_Letter_Date__c = Date.today();
        opp.CloseDate = Date.today() + 10;
        opp.StageName = 'Qualification';
        opp.Booking__c = refBkg.Id;
        insert opp;
        
        RW_Demand__c dem = new RW_Demand__c();
        dem.Booking__c = refBkg.Id;
        insert dem;
            
        RW_Demand_Item__c demItem = new RW_Demand_Item__c();
        demItem.RW_Demand__c = dem.Id;
        demItem.RW_Demand_Item_Amount__c = 100000;
        demItem.RW_GST_Amount__c = 0;
        insert demItem;
        
        Booking__c bkg = new Booking__c();
        bkg.Lockated_User_Device_ID__c = '123';
        bkg.FBL5N__c = 60000;
        bkg.Customer_Reference_Opportunity__c = opp.Id;
        insert bkg;
        
        LockatedApp_NotificationsSchedule sch = new LockatedApp_NotificationsSchedule();
        sch.refBkg20PercentPayed();
    }
    
    @isTest
    public static void bookingConfirmedNotificationTest(){
        Booking__c bkg = new Booking__c();
        bkg.Lockated_User_Device_ID__c = '123';
        insert bkg;
        
        bkg.Status__c = 'Booking Confirmed';
        update bkg;
    }
    
    @isTest
    public static void sanctionStatusNotificationTest(){
        Booking__c bkg = new Booking__c();
        bkg.Lockated_User_Device_ID__c = '123';
        insert bkg;
        
        Loan__c loan = new Loan__c();
        loan.RW_Booking__c = bkg.Id;
        loan.RW_Bank_Preference_1__c = 'Axis Bank Ltd';
        insert loan;
        
        loan.RW_Sanction_Date__c = Date.today();
        loan.RW_Sanction_Amount__c = 1000000;
        loan.RW_Sanction_Status__c = 'Loan Sanctioned';
        loan.RW_Loan_Account_Number__c = '1234';
        loan.RW_Sanction_Letter_ID__c = '854785';
        loan.Loan_Document_Received_Date__c = Date.today();
        update loan;
    }
    
    @isTest
    public static void applicantDetailChangeTest(){
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.News_Letter_Date__c = Date.today();
        opp.CloseDate = Date.today() + 10;
        opp.StageName = 'Qualification';
        insert opp;
        
        Booking__c bkg = new Booking__c();
        bkg.Lockated_User_Device_ID__c = '123';
        bkg.Customer__c = opp.Id;
        insert bkg;
        
        Applicant_Details__c app = new Applicant_Details__c();
        app.Booking__c = bkg.Id;
        app.Applicant_Number__c = 'Primary Applicant';
        app.Correspondence_Address__c = 'Test Address';
        app.Mobile_Number__c = '1234567890';
        insert app;
        
        app.Correspondence_Address__c = 'Test Address1';
        app.Mobile_Number__c = '1234567891';
        update app;
    }
    
    @isTest
    public static void registrationCongratulatoryNotificationTest(){
        
        Booking__c bkg = new Booking__c();
        bkg.Lockated_User_Device_ID__c = '123';
        insert bkg;
        
        bkg.RW_Registration_Date__c = Date.today();
        update bkg;
    }
    
    @isTest
    public static void demandAndReceiptNotificationTest(){
        
        Booking__c bkg = new Booking__c();
        bkg.Lockated_User_Device_ID__c = '123';
        insert bkg;
        
        RW_Demand__c dem = new RW_Demand__c();
        dem.Booking__c = bkg.Id;
        insert dem;
        
        List<RW_Payment_Details__c> recList = new List<RW_Payment_Details__c>();
        RW_Payment_Details__c rec1 = new RW_Payment_Details__c();
        rec1.RW_Booking__c = bkg.Id;
        rec1.RW_Document_Type__c = 'DZ';
        recList.add(rec1);
        
        RW_Payment_Details__c rec2 = new RW_Payment_Details__c();
        rec2.RW_Booking__c = bkg.Id;
        rec2.RW_Document_Type__c = 'DS';
        recList.add(rec2);
        insert recList;
    }
    
    @isTest
    public static void referralLeadCreatedNotificationTest(){
        Account acc = new Account();
        acc.LastName = 'Test Account';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Test Opp';
        opp.News_Letter_Date__c = Date.today();
        opp.CloseDate = Date.today() + 10;
        opp.StageName = 'Qualification';
        insert opp;
        
        Booking__c bkg = new Booking__c();
        bkg.Lockated_User_Device_ID__c = '123';
        bkg.Customer__c = opp.Id;
        bkg.Opportunity__c = opp.Id;
        insert bkg;
        
        Lead ld = new Lead();
        ld.LastName = 'Test Lead';
        ld.LeadSource = 'Referral';
        ld.Customer_Reference__c = acc.Id;
        ld.RW_Mobile_No__c = '1234567890';
        insert ld;
    }
    
    @isTest
    public static void referralVisitDoneNotificationTest(){
        Account acc = new Account();
        acc.LastName = 'Test Account';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Test Opp';
        opp.News_Letter_Date__c = Date.today();
        opp.CloseDate = Date.today() + 10;
        opp.StageName = 'Qualification';
        insert opp;
        
        Booking__c bkg = new Booking__c();
        bkg.Lockated_User_Device_ID__c = '123';
        bkg.Customer__c = opp.Id;
        bkg.Opportunity__c = opp.Id;
        insert bkg;
        
        Opportunity opp1 = new Opportunity();
        opp1.AccountId = acc.Id;
        opp1.Name = 'Test Opp1';
        opp1.News_Letter_Date__c = Date.today();
        opp1.CloseDate = Date.today() + 10;
        opp1.StageName = 'Site Visit';
        opp1.LeadSource = 'Referral';
        opp1.Customer_Reference__c = acc.Id;
        insert opp1;
    }
    
    @isTest
    public static void caseNotificationTest(){
        Account acc = new Account();
        acc.LastName = 'Test Account';
        insert acc;
        
        Booking__c bkg = new Booking__c();
        bkg.Lockated_User_Device_ID__c = '123';
        insert bkg;
        
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Test Opp';
        opp.News_Letter_Date__c = Date.today();
        opp.CloseDate = Date.today() + 10;
        opp.StageName = 'Qualification';
        opp.Booking__c = bkg.Id;
        insert opp;
        
        Case cs = new Case();
        cs.AccountId = acc.Id;
        cs.Status = 'Open';
        cs.Opportunity__c = opp.Id;
        insert cs;
        
        cs.Status = 'Case Closed';
        cs.RW_RM_Remarks__c = 'Test';
        update cs;
    }
    
    @isTest
    public static void bookingNotificationTest(){
        Booking__c bkg = new Booking__c();
        bkg.Lockated_User_Device_ID__c = '123';
        bkg.Funding_Status__c = 'Self Funded';
        insert bkg;
        
        bkg.RW_Key_handover_date__c = Date.today();
        bkg.RW_BRL_Number__c = '123456';
        bkg.Possession_Guidelines_Sent_Date__c = Date.today();
        update bkg;
    }
    
    @isTest
    public static void rmChangedNotificationTest(){
        Booking__c bkg = new Booking__c();
        bkg.Lockated_User_Device_ID__c = '123';
        bkg.Funding_Status__c = 'Self Funded';
        insert bkg;
        
        List<Relationship_Manager__c> rmList = new List<Relationship_Manager__c>();
        Relationship_Manager__c rm1 = new Relationship_Manager__c();
        rm1.Name = 'Test RM 1';
        rmList.add(rm1);
        Relationship_Manager__c rm2 = new Relationship_Manager__c();
        rm2.Name = 'Test RM 2';
        rmList.add(rm2);
        insert rmList;
        
        Project__c proj = new Project__c();
        proj.Name = 'Test Project';
        insert proj;
        
        Project_Unit__c unit = new Project_Unit__c();
        unit.Name = 'Test Unit';
        unit.Relationship_Manager__c = rm1.Id;
        unit.Booking__c = bkg.Id;
        unit.RW_Project__c = proj.Id;
        unit.RW_Param1__c = 'Param1';
        unit.RW_Param2__c = 'Param2';
        unit.RW_Param3__c = 'Param3';
        unit.RW_Param4__c = 'Param4';
        unit.RW_Param5__c = 'Param5';
        unit.RW_Delimeter__c = '/';
        insert unit;
        
        unit.Relationship_Manager__c = rm2.Id;
        update unit;
    }
    
    @isTest
    public static void reminderLetterTaskNotificationTest(){
        Booking__c bkg = new Booking__c();
        bkg.Lockated_User_Device_ID__c = '123';
        insert bkg;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.News_Letter_Date__c = Date.today();
        opp.CloseDate = Date.today() + 10;
        opp.StageName = 'Qualification';
        opp.Booking__c = bkg.Id;
        insert opp;
        
        Task tsk = new Task();
        tsk.WhatId = opp.Id;
        tsk.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Reminder letter').getRecordTypeId();
        tsk.Subject = 'Test';
        insert tsk;
    }
    
}