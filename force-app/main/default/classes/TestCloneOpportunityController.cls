@isTest(seeAllData= true)
public class TestCloneOpportunityController {
    public static String OptyID{get;set;}
    
    static testMethod void myUnitTest11() 
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduserrtt@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduserrr@testorg.com');
        insert u;
        List <Opportunity> ld = new List <Opportunity> ();
        OppTriggerHandler opp = new OppTriggerHandler();
        opp.BeforeInsert(ld);
        update ld;
        
        
        Project__c objProj = new Project__c();
        objProj.name = 'test22';
        insert objProj;
    
        
        RecordType personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'];
        
        Account objAcc = new Account();
        objAcc.lastname = 'test2';
        objAcc.PersonEmail = 'test2289stetigin@test.in';
        objAcc.RecordType = personAccountRecordType;
        objAcc.MasterRecord__c = true;
        insert objAcc;
        
        Opportunity objopp = new Opportunity();
        objopp.name = 'test2';
        objopp.AccountId = objAcc.id;
        objopp.CloseDate = system.today();
        objopp.StageName = 'Qualification';
        objopp.RW_Project__c = objProj.id;
        //objopp.RW_Project_Unit__c = objPU.id;
        objopp.RW_Sales_Associate__c = 'Test22';
        objopp.RW_Mobile_No__c = '1233211222';
        objopp.RW_Email__c = 'test@56test2.com';
        //objopp.RW_RM_Name__c = 'test RM';
        insert objopp;
        OptyID = objopp.Id;
               
        Test.startTest();
        CloneOpportunityController.creteCloneOpportunities(OptyID);            
        Test.stopTest();
        
    }
    
}