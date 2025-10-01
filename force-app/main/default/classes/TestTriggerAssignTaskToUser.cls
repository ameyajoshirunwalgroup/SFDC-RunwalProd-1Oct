@isTest
public class TestTriggerAssignTaskToUser 
{
    public static testmethod void AssignTask1()
    {
               
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduserrtt@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduserrr@testorg.com');
        insert u;
        
        Project__c p2 = TestDataFactory.createProject('Xanadu_prj2','111');
        Account acc2 = TestDataFactory.createPATemplate('TestPA2' , 'testleada@ozonetest.com', '9876544441', false);
        
        List<Lead> llist2 = TestDataFactory.createLead(3);
        List<Opportunity>  oList2 = TestDataFactory.createOpptyForAccount(acc2.Id, p2.Id, 3);
        
        system.debug(oList2[0].Name);                
                
        task t = new task();
        t.Subject = 'New Task';
        t.Task_Type__c = 'Presales Call';
        t.activityDate = System.Today();
        t.whatId = oList2[0].Id;
        t.call_time__c = TaskManagementServices.FormatTime(system.now());
        t.ActivityDate__c = '30/12/2021';
        t.ActivityDate = System.Today();
        t.Next_Action_Date__c = System.Today();
        insert t;
        
        t.OwnerId = u.id;
        update t;       
    }  
    
    public static testmethod void AssignTask2()
    {
               
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduserrtt@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduserrr@testorg.com');
        insert u;
        
        Project__c p2 = TestDataFactory.createProject('Xanadu_prj2','111');
        Account acc2 = TestDataFactory.createPATemplate('TestPA2' , 'testleada@ozonetest.com', '9876544441', false);
        
        List<Lead> llist2 = TestDataFactory.createLead(3);
        List<Opportunity>  oList2 = TestDataFactory.createOpptyForAccount(acc2.Id, p2.Id, 3);
        
        system.debug(oList2[0].Name);                
                
        Id PresalesRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Presales Task').getRecordTypeId();
        
        task t = new task();
        t.Subject = 'New Task';
        t.Task_Type__c = 'Enquiry Received';
        t.activityDate = System.Today();
        t.WhoId = llist2[0].Id;
        t.call_time__c = TaskManagementServices.FormatTime(system.now());
        t.ActivityDate__c = '30/12/2021';
        t.ActivityDate = System.Today();
        t.Next_Action_Date__c = System.Today();
        t.RecordTypeId = PresalesRecordTypeId;
        insert t;
        
        //t.OwnerId = u.id;
        //update t;       
    }   
}