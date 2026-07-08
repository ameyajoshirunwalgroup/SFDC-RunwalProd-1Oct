@isTest
public class TestBatch_UpdateLeadStatus
{
    static testMethod void BatchUpdateLeadStatustTest() 
    {
        
        Project__c objProject = new Project__c();
        objProject.name = 'Runwal Gardens';
        objProject.RW_Status__c = 'Active';
        insert objProject ;
        
        Project__c objProject1 = new Project__c();
        objProject1.name = 'Runwal Bliss';
        objProject1.RW_Status__c = 'Active';
        insert objProject1 ;
        
        Project__c objProject2 = new Project__c();
        objProject2.name = 'test';
        objProject2.RW_Status__c = 'Active';
        insert objProject2 ;
         
        Lead objLead = new Lead();
        objLead.LastName = 'test';
        objLead.Status = 'New';
        objLead.Email = 'test12@gmail.com';
        objLead.MobilePhone = '9243562121';
        objLead.RW_Mobile_No__c = '9243562121';
        objLead.LeadSource = 'Corporate Company';
        objLead.Remark__c = 'test remark';
        objLead.RW_Project__c = objProject.id; 
        objLead.CP_Lead_Status__c = 'Active';
        objLead.IsConverted = false;
        insert objLead;
        Test.setCreatedDate(objLead.Id, System.now().addDays(-61));
        
        Lead objLead1 = new Lead();
        objLead1.LastName = 'test';
        objLead1.Status = 'New';
        objLead1.Email = 'test12@gmail.com';
        objLead1.MobilePhone = '9243562121';
        objLead1.RW_Mobile_No__c = '9243562121';
        objLead1.LeadSource = 'Corporate Company';
        objLead1.Remark__c = 'test remark';
        objLead1.RW_Project__c = objProject1.id; 
        objLead1.CP_Lead_Status__c = 'Active';
        objLead1.IsConverted = false;
        insert objLead1;
        Test.setCreatedDate(objLead1.Id, System.now().addDays(-61));
        
        Lead objLead2 = new Lead();
        objLead2.LastName = 'test';
        objLead2.Status = 'New';
        objLead2.Email = 'test12@gmail.com';
        objLead2.MobilePhone = '9243562121';
        objLead2.RW_Mobile_No__c = '9243562121';
        objLead2.LeadSource = 'Corporate Company';
        objLead2.Remark__c = 'test remark';
        objLead2.RW_Project__c = objProject2.id; 
        objLead2.CP_Lead_Status__c = 'Active';
        objLead2.IsConverted = false;
        insert objLead2;
        Test.setCreatedDate(objLead2.Id, System.now().addDays(-61));
        
        Test.startTest();
        
        Batch_UpdateLeadStatus ba= new Batch_UpdateLeadStatus();
        Id jobid= Database.executeBatch(ba);                  
        Test.stopTest();
        
        //Lead leads = [select CP_Lead_Status__c from lead where id=:objLead.Id];
        // system.assertEquals('Inactive', leads.CP_Lead_Status__c);
    }
}