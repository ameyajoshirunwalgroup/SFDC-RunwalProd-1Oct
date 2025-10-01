@isTest
public class CallLogTest {
    @isTest
    public static void testCallLog () {
         Project__c projObj = new Project__c();
     projObj.Name='Test Project';
     //projObj.EDC_Days__c = 90;
     insert projObj;
     
     Lead leadObj=new Lead();
     leadObj.LastName='Test Lead';
     leadObj.RW_Mobile_No__c = '9860708786';
     leadObj.RW_Project__c = projObj.Id;
     //leadObj.Budget_In_lacs__c=98;
     insert leadObj;
     
     Test.startTest();
     PageReference pRef = Page.callLogApiPage;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('mobile','9860708786');
        ApexPages.currentPage().getParameters().put('agent','test');
        ApexPages.currentPage().getParameters().put('LeadStatus','open');
        ApexPages.currentPage().getParameters().put('eventType','test');
        ApexPages.currentPage().getParameters().put('statusReason','test');
        ApexPages.currentPage().getParameters().put('Remarks','test');
        ApexPages.currentPage().getParameters().put('eventstartime','test');
        ApexPages.currentPage().getParameters().put('emailId','test');
        ApexPages.currentPage().getParameters().put('Name','test');
        
     CallLogApi cti = new CallLogApi();
     cti.createCallLog();
     
           Test.stopTest();             
    }
}