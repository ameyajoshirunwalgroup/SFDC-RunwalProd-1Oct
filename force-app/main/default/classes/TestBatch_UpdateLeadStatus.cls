@isTest
public class TestBatch_UpdateLeadStatus
{
    static testMethod void BatchUpdateLeadStatustTest() 
    {
        
        Project__c objProject = new Project__c();
        objProject.name = 'test';
        objProject.RW_Status__c = 'Active';
        insert objProject ;
        
        Lead objLead = new Lead();
        objLead.LastName = 'test';
        objLead.Status = 'Not Sure';
        objLead.Email = 'test12@gmail.com';
        objLead.MobilePhone = '9243562121';
        objLead.RW_Mobile_No__c = '9243562121';
        objLead.LeadSource = 'Corporate Company';
        objLead.Remark__c = 'test remark';
        objLead.RW_Project__c = objProject.id; 
        objLead.CP_Lead_Status__c = 'Active';
        objLead.IsConverted = false;
        insert objLead;
        
        Test.startTest();
        
        Batch_UpdateLeadStatus ba= new Batch_UpdateLeadStatus();
        Id jobid= Database.executeBatch(ba);                  
        Test.stopTest();
        
        //Lead leads = [select CP_Lead_Status__c from lead where id=:objLead.Id];
        // system.assertEquals('Inactive', leads.CP_Lead_Status__c);
    }
}