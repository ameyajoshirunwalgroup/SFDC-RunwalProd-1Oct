@isTest
public class CSATFeedbackControllerTest {
	@isTest
    private static void CSATFeedbackTest1(){
        Account a = new Account();
        a.FirstName ='TestAccount1';
        a.LastName ='TestAccount2';
        a.PersonEmail = 'wc@email.com';
        a.City__c='TestCity';
        a.RW_Zip_Code__c = '999999';
        a.State__c ='Karnataka';
        a.Country__c ='India';
        a.Mobile_No__c = '9876543212';
        a.Alternate_Email__c = 'wc1@email.com';
        a.Gender__c='Male';
        a.Salutation = 'Mr.';
        a.Birth_Date__c = System.today().addYears(-20);  
        insert a;
        
        Case objCase = new Case();
        //objCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        objCase.AccountId = a.Id;
        objCase.Subject = 'testSubject';
        objCase.Description = 'testDescription';
        insert objCase;
        
        CSAT__c csat = new CSAT__c();
        csat.Account__c = a.Id;
        csat.Contact_Email__c = 'test@mail.com';
        csat.Case__c = objCase.Id;
        insert csat;
        
        test.startTest();
        pageReference pagRef = page.CSATFeedbackForm;
        //System.currentPageReference().getParameters().put('objId', objBking.Id);
        test.setCurrentPage(pagRef);
        CSATFeedbackController cf = new CSATFeedbackController();
        cf.recId = csat.Id;
        cf.rating = 'UnHappy';
      //cf.remarks = 'Test';
        cf.submitFeedback();
        test.stopTest();
    }
    
    @isTest
    private static void CSATFeedbackTest2(){
        Account a = new Account();
        a.FirstName ='TestAccount1';
        a.LastName ='TestAccount2';
        a.PersonEmail = 'wc@email.com';
        a.City__c='TestCity';
        a.RW_Zip_Code__c = '999999';
        a.State__c ='Karnataka';
        a.Country__c ='India';
        a.Mobile_No__c = '9876543212';
        a.Alternate_Email__c = 'wc1@email.com';
        a.Gender__c='Male';
        a.Salutation = 'Mr.';
        a.Birth_Date__c = System.today().addYears(-20);  
        insert a;
        
        Case objCase = new Case();
        //objCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        objCase.AccountId = a.Id;
        objCase.Subject = 'testSubject';
        objCase.Description = 'testDescription';
        insert objCase;
        
        CSAT__c csat = new CSAT__c();
        csat.Account__c = a.Id;
        csat.Contact_Email__c = 'test@mail.com';
        csat.Case__c = objCase.Id;
        insert csat;
        
        test.startTest();
        pageReference pagRef = page.CSATFeedbackForm;
        //System.currentPageReference().getParameters().put('objId', objBking.Id);
        test.setCurrentPage(pagRef);
        CSATFeedbackController cf = new CSATFeedbackController();
        cf.recId = csat.Id;
        cf.remarks = 'Test';
        cf.submitFeedback();
        test.stopTest();
    }
    
    @isTest
    private static void CSATFeedbackTest(){
        Account a = new Account();
        a.FirstName ='TestAccount1';
        a.LastName ='TestAccount2';
        a.PersonEmail = 'wc@email.com';
        a.City__c='TestCity';
        a.RW_Zip_Code__c = '999999';
        a.State__c ='Karnataka';
        a.Country__c ='India';
        a.Mobile_No__c = '9876543212';
        a.Alternate_Email__c = 'wc1@email.com';
        a.Gender__c='Male';
        a.Salutation = 'Mr.';
        a.Birth_Date__c = System.today().addYears(-20);  
        insert a;
        
        Case objCase = new Case();
        //objCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        objCase.AccountId = a.Id;
        objCase.Subject = 'testSubject';
        objCase.Description = 'testDescription';
        insert objCase;
        
        CSAT__c csat = new CSAT__c();
        csat.Account__c = a.Id;
        csat.Contact_Email__c = 'test@mail.com';
        csat.Case__c = objCase.Id;
        insert csat;
        
        test.startTest();
        pageReference pagRef = page.CSATFeedbackForm;
        //System.currentPageReference().getParameters().put('objId', objBking.Id);
        test.setCurrentPage(pagRef);
        CSATFeedbackController cf = new CSATFeedbackController();
        cf.recId = csat.Id;
        cf.rating = 'Happy';
        cf.successPage();
        cf.submitFeedback();
        test.stopTest();
    }
    
    @isTest
    private static void CSATFeedbackTest4(){
        Account a = new Account();
        a.FirstName ='TestAccount1';
        a.LastName ='TestAccount2';
        a.PersonEmail = 'wc@email.com';
        a.City__c='TestCity';
        a.RW_Zip_Code__c = '999999';
        a.State__c ='Karnataka';
        a.Country__c ='India';
        a.Mobile_No__c = '9876543212';
        a.Alternate_Email__c = 'wc1@email.com';
        a.Gender__c='Male';
        a.Salutation = 'Mr.';
        a.Birth_Date__c = System.today().addYears(-20);  
        insert a;
        
        Case objCase = new Case();
        //objCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        objCase.AccountId = a.Id;
        objCase.Subject = 'testSubject';
        objCase.Description = 'testDescription';
        insert objCase;
        
                
        test.startTest();
        pageReference pagRef = page.CSATFeedbackForm;
        //System.currentPageReference().getParameters().put('objId', objBking.Id);
        test.setCurrentPage(pagRef);
        CSATFeedbackController cf = new CSATFeedbackController();
        cf.recId = objCase.Id;
        //cf.rating = 'Happy';
        cf.successPage();
        cf.submitFeedback();
        test.stopTest();
    }
}