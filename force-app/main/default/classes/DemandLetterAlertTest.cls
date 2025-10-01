@isTest
public class DemandLetterAlertTest {

    @isTest
    public static void demandLetterTest(){
        
        Project__c proj = new Project__c();
        proj.Name = 'Test Project';
        proj.Outstanding_Amount_Limit__c = 0;
        insert proj;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.StageName = 'Unit Booked';
        opp.CloseDate = Date.today() + 5;
        opp.RW_Mobile_No__c = '1236547896';
        opp.RW_Email__c = 'test@mail.com';
        opp.RW_Agreement_Value__c = 10000;
        insert opp;
        
        Booking__c bkg = new Booking__c();
        bkg.Opportunity__c = opp.Id;
        bkg.Status__c  = 'Booking Confirmed';
        bkg.Date_of_Occupation_Certificate__c = Date.today();
        bkg.Project__c = proj.Id;
        bkg.FBL5N__c = 100000;
        insert bkg;
        
        RW_Demand__c dem = new RW_Demand__c();
        dem.Name = '12345';
        dem.Booking__c = bkg.Id;
        dem.RW_Billing_Document_Number__c = '98564';
        insert dem;
        
        RW_Demand_Item__c demItem = new RW_Demand_Item__c();
        demItem.RW_Demand_Item_Amount__c = 975000;
        demItem.RW_Demand__c = dem.Id;
        insert demItem;
        
        RW_Payment_Details__c rec1 = new RW_Payment_Details__c();
        rec1.RW_Document_Type__c = 'DZ';
        rec1.RW_Booking__c = bkg.Id;
        insert rec1;
        
        RW_Payment_Details__c rec2 = new RW_Payment_Details__c();
        rec2.RW_Document_Type__c = 'DS';
        rec2.RW_Booking__c = bkg.Id;
        insert rec2;
        
        Applicant_Details__c app = new Applicant_Details__c();
        app.Applicant_Number__c = 'Primary Applicant';
        insert app;
        
        DemandLetterAlert b = new DemandLetterAlert();
        b.execute(null);
        
        DemandReminderDateUpdate.updateReminderDate();
        
        DemandReminderAlert dr = new DemandReminderAlert();
        dr.execute(null);
        
        ReceiptLetterAlert r = new ReceiptLetterAlert();
        r.execute(null);
        
        PaymentDueAlertForPossessionCustomers p = new PaymentDueAlertForPossessionCustomers();
        p.execute(null);
        
        PageReference demPdf = Page.CRMBotDocument;
        Test.setCurrentPage(demPdf);
        ApexPages.currentPage().getParameters().put('id',dem.Id);
        ApexPages.currentPage().getParameters().put('doc','dem');
        CRMBotDocumentController demDoc = new CRMBotDocumentController();
        
        PageReference recpPdf = Page.CRMBotDocument;
        Test.setCurrentPage(recpPdf);
        ApexPages.currentPage().getParameters().put('id',rec1.Id);
        ApexPages.currentPage().getParameters().put('doc','recp');
        CRMBotDocumentController recp = new CRMBotDocumentController();
        
        PageReference acsPdf = Page.CRMBotDocument;
        Test.setCurrentPage(acsPdf);
        ApexPages.currentPage().getParameters().put('id',bkg.Id);
        ApexPages.currentPage().getParameters().put('doc','acs');
        CRMBotDocumentController acs = new CRMBotDocumentController();
        
    }
}