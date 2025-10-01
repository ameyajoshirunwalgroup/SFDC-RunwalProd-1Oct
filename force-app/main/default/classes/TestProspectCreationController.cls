@isTest
    private class TestProspectCreationController {
        @isTest static void reference1(){
           ProspectCreationController pp = new ProspectCreationController();
           Lead ld = new Lead();   
           Project__c obj = new Project__c();
            ld.FirstName='Harish';
            ld.LastName ='KK';
            ld.Company ='AA';
            ld.Project_Name__c = 'runwal bliss';
            ld.RW_Mobile_No__c = '1234567890';
            ld.Email = 'test@stetig.com';
            ld.Email_1__c = 'test@stetig.com';
            insert ld;
            pp.NewLead.RW_Mobile_No__c = ld.RW_Mobile_No__c;
            pp.searchAllLead();
            pp.saveMethod();  
            pp.duplead();
            pp.goBack();  
        }
}