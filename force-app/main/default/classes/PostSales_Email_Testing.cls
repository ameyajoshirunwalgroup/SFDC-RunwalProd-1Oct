public class PostSales_Email_Testing {
    
    public static void emailTesting(){
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.AccountId = acc.Id;
        opp.RW_Email__c = 'test1@mail.com';
        opp.StageName = 'Unit Booked';
        opp.CloseDate = Date.today().addDays(30);
        insert opp;
        
        Relationship_Manager__c rm = new Relationship_Manager__c();
        rm.Name = 'Test RM';
        rm.User__c = UserInfo.getUserId();
        insert rm;
        
        Project_Unit__c unit = new Project_Unit__c();
        unit.Name = 'Test Unit';
        insert unit;
        
        Booking__c bkg = new Booking__c();
        bkg.Opportunity__c = opp.Id;
        bkg.Customer__c = opp.Id;
        bkg.Status__c = 'Booking Confirmed';
        insert bkg;
        
        bkg.RW_Registration_Date__c = Date.today();
        bkg.RW_Key_handover_date__c = Date.today();
        bkg.RW_BRL_Number__c = '1234';
        bkg.Funding_Status__c = 'Self Funded';
        bkg.Possession_Guidelines_Sent_Date__c = Date.today();
        bkg.RW_Booking_Confirmed_Date__c = Date.today() - 2;
        update bkg;
        
        Applicant_Details__c app = new Applicant_Details__c();
        app.Booking__c = bkg.Id;
        app.Applicant_Number__c = 'Primary Applicant';
        app.Email_Address__c = 'vinay.kumar.os@runwalgroup.in';
        app.Permanent_Address_Line_1__c = 'Address Line 1';
        app.Mobile_Number__c = '1977007794';
        insert app;
        
        app.Permanent_Address_Line_1__c = 'Address Line 1 Updated';
        app.Mobile_Number__c = '8977007794';
        update app;
        
        RW_Welcome_Call__c wc = new RW_Welcome_Call__c();
        wc.RW_Booking__c = bkg.Id;
        wc.RW_Welcome_Call_Status__c = 'Due';
        insert wc;
        
        
        Loan__c ln = new Loan__c();
        ln.RW_Sanction_Date__c = Date.today() + 10;
        ln.RW_Loan_Record_Status__c = 'Loan Process Initiated';
        ln.RW_Booking__c = bkg.Id;
        insert ln;
        
        ln.RW_Loan_Record_Status__c = 'HL Documentation Initiated';
        update ln;
        
        RW_Demand__c dem = new RW_Demand__c();
        dem.Booking__c = bkg.Id;
        insert dem;
        
        RW_Payment_Details__c rec = new RW_Payment_Details__c();
        rec.RW_Document_Type__c = 'DF';
        rec.RW_Booking__c = bkg.Id;
        insert rec;
        
        Lead refLead = new Lead();
        refLead.LeadSource = 'Referral';
        refLead.Customer_Reference__c = acc.Id;
        insert refLead;
        
        Opportunity refOpp = new Opportunity();
        refOpp.StageName = 'Site Visit';
        refOpp.LeadSource = 'Referral';
        refOpp.Customer_Reference__c = acc.Id;
        insert refOpp;
        
        Booking__c refBkg = new Booking__c();
        refBkg.Customer_Reference__c = acc.Name;
        insert refBkg;
        
        Case cs = new Case();
        cs.Status = 'Open';
        cs.AccountId = acc.Id;
        insert cs;
        
        cs.Status = 'Case Closed';
        update cs;
        
        unit.Relationship_Manager__c = rm.Id;
        update unit;
        
        Id reminderLetterRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Reminder letter').getRecordTypeId(); 
        Task reminderLetterTsk = new Task();
        reminderLetterTsk.WhatId = opp.Id;
        insert reminderLetterTsk;
        
        Payment_Transaction__c pt = new Payment_Transaction__c();
        pt.Booking__c = bkg.Id;
        pt.Status__c = 'FAILED';
        insert pt;
        
    }
    
    
}