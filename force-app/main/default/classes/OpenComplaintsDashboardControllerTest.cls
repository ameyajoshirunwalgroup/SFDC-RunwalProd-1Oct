@isTest
public class OpenComplaintsDashboardControllerTest {
    
    @isTest
    static void testGetOpenComplaints() {

        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Booking__c bkg = new Booking__c();
        bkg.RW_Key_handover_date__c = Date.today();
        insert bkg;
        
        Opportunity opp = new Opportunity(Name = 'Test Customer',StageName = 'Unit Booked',CloseDate = Date.today().addDays(30),AccountId = acc.Id,Last_CRM_Call_Subject__c = 'Missed Call',Booking__c = bkg.Id);
        insert opp;
        
        
        
        Case cs1 = new Case(AccountId = acc.Id,Opportunity__c = opp.Id,Status = 'Open');
        Case cs2 = new Case(AccountId = acc.Id,Opportunity__c = opp.Id,Status = 'Open');
        
        
        insert new List<Case>{cs1,cs2};
            
        cs2.Status = 'Reopened';
        cs2.RW_Case_Reopened_Date__c=System.now();
        update cs2;
        
        Test.startTest();
        List<OpenComplaintsDashboardController.OpenComplaintsWrapper> result = OpenComplaintsDashboardController.getOpenComplaints(null, null, null, null);
        Test.stopTest();

    }

}