@isTest
    private class TestProspectAccessController {
        @isTest static void reference(){
           ProspectAccessController pp = new ProspectAccessController();
           Lead l = new Lead();   
           Project__c obj = new Project__c();
           Prospect__c p = new Prospect__c();
            
            l.FirstName='Harish1';
            l.LastName ='KK';
            l.Company ='AA';
            l.Project_Name__c = 'runwal bliss';
            l.RW_Mobile_No__c = '1234567897';
            l.Email = 'test1@stetig.com';
            l.Email_1__c = 'test1@stetig.com';
            insert l;
            pp.NewLead.RW_Mobile_No__c = l.RW_Mobile_No__c;
            pp.searchAllLead();
            pp.saveMethod();  
            pp.duplead();
            pp.goBack();  
            
            //p.Project__c = ;
            insert p;
            pp.NewLead.RW_Mobile_No__c = l.RW_Mobile_No__c;
            pp.searchAllLead();
            pp.saveMethod();  
            pp.duplead();
            pp.goBack();  
            
        }
         @isTest
    private static void applicantdetailtest2(){
        Test.startTest();
    //ProspectAccessController.dummy();
         test.stopTest();
    }
 
}