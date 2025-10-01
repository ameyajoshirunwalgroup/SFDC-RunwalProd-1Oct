@isTest
public class TestSendBulkLead{
@isTest
    public Static void BulkSendLead(){
        Campaign camp = new Campaign();
        camp.Name = 'Test Campaign';
        insert camp;
        
        Account a = new Account();
        a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        a.PersonMobilePhone = '65345367654';
        a.FirstName = 'test';
        a.LastName = 'Account';
        a.PersonEmail = 'test@stetig.in';
        insert a;
        
        Account a2 = new Account();
        a2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        a2.PersonMobilePhone = '65345367654';
        a2.FirstName = 'test';
        a2.LastName = 'Account';
        a2.PersonEmail = 'test@stetig.in';
        insert a2;
       
        CBSLBulkLead__c sm = new CBSLBulkLead__c();
        sm.Name = 'URL';
        sm.Endpoint__c  = 'https://ldhcrm.conneqtcorp.com/RunwalAPI/API/Lead/SaveLeadAsync';
        //sm.Api_Key__c = 'adc3b4d87b56e9c116d59c4d8f3f1b5cfc9ccd9f';
        Insert sm;
        
        Contact con = [SELECT Id,Name FROM Contact WHERE AccountId =:a.Id];
        Contact con2 = [SELECT Id,Name FROM Contact WHERE AccountId =:a2.Id];
        
        CampaignMember cm = new CampaignMember(); 
        cm.CampaignId = camp.Id;
        cm.ContactId = con.Id;
       // cm.Status = 'Needs Renewal and Invoice';
        insert cm;
        
        CampaignMember cm2 = new CampaignMember(); 
        cm2.CampaignId = camp.Id;
        cm2.ContactId = con2.Id;
       // cm2.Status = 'Needs Renewal and Invoice';
        insert cm2;
        
         set<Id> cmids = new Set<Id>();
        cmids.add(cm.id);
        cmids.add(cm2.id);
        
        SendBulkLeadClass MSM= new SendBulkLeadClass();
        MSM.getCampList();
       // MSM.getTemplateList();
        MSM.getMembers();
        MSM.sendMassEmailLead();
        MSM.checkBatchStatus();
        
         System.runAs ( new User(Id = UserInfo.getUserId()) ) {       
            Set<Id> setcm = new Set<Id>();
            setcm.add(cm.id);
            setcm.add(cm2.id);
            
            SendBulkLeadManagementServices.sendMail(setcm);
            SendBulkLeadManagementServices.insertTask(setcm);
            Database.executeBatch(new SendBulkLeadBatch(setcm));
            
        }
        
    }
    
    @isTest
    public Static void MassSendSMS(){
        
        Campaign camp = new Campaign();
        camp.Name = 'Test Campaign';
        insert camp;
        
        Account a = new Account();
        a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        a.PersonMobilePhone = '65345367654';
        a.FirstName = 'test';
        a.LastName = 'Account';
        a.PersonEmail = 'test@stetig.in';
        insert a;
        
        Account a2 = new Account();
        a2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        a2.PersonMobilePhone = '65345367654';
        a2.FirstName = 'test';
        a2.LastName = 'Account';
        a2.PersonEmail = 'test@stetig.in';
        insert a2;
        
        CBSLBulkLead__c sm = new CBSLBulkLead__c();
        sm.Name = 'URL';
        sm.Endpoint__c  = 'https://ldhcrm.conneqtcorp.com/RunwalAPI/API/Lead/SaveLeadAsync';
        Insert sm;
        
         Contact con = [SELECT Id,Name FROM Contact WHERE AccountId =:a.Id];
        Contact con2 = [SELECT Id,Name FROM Contact WHERE AccountId =:a2.Id];
        
        CampaignMember cm = new CampaignMember(); 
        cm.CampaignId = camp.Id;
        cm.ContactId = con.Id;
        cm.Status = 'Needs Renewal and Invoice';
        insert cm;
        
        CampaignMember cm2 = new CampaignMember(); 
        cm2.CampaignId = camp.Id;
        cm2.ContactId = con2.Id;
        cm2.Status = 'Needs Renewal and Invoice';
        insert cm2;
        
        set<Id> cmids = new Set<Id>();
        cmids.add(cm.id);
        cmids.add(cm2.id);
        
         SendBulkLeadClass MSM= new SendBulkLeadClass();
        MSM.getCampList();
       // MSM.getTemplateList();
        MSM.getMembers();
        MSM.sendMassEmailLead();
        MSM.checkBatchStatus();
        
    }
    
}