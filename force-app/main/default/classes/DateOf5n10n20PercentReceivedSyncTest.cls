@isTest
public class DateOf5n10n20PercentReceivedSyncTest{
    
    @isTest
	public static void receivedDateStncTest() {
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
        opp.SAP_Customer_Number__c = '789123';
        opp.SalesOrder_Number__c = '123456';
        insert opp;
        
        Booking__c bkg = new Booking__c();
        bkg.Opportunity__c = opp.Id;
        bkg.Status__c  = 'Booking Confirmed';
        bkg.Date_of_Occupation_Certificate__c = Date.today();
        bkg.Project__c = proj.Id;
        bkg.FBL5N__c = 100000;
        insert bkg;
        
        DateOf5n10n20PercentReceivedSyncFromSAP b = new DateOf5n10n20PercentReceivedSyncFromSAP();
        b.execute(null);
    }
}