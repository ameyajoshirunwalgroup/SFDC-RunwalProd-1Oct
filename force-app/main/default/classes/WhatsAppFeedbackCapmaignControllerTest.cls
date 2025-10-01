@isTest
public class WhatsAppFeedbackCapmaignControllerTest {
    
    @isTest
    public static void campTest1(){
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.RW_Mobile_No__c = '1234567890';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.AccountId  =acc.Id;
        opp.StageName = 'Qualification';
        opp.CloseDate = Date.today();
        insert opp;
        
        Id filteredId = Schema.SObjectType.WhatsApp_Campaign__c.getRecordTypeInfosByName().get('Filtered').getRecordTypeId();
        WhatsApp_Campaign__c camp = new WhatsApp_Campaign__c();
        camp.Campaign_Name__c = 'Test Campaign';
        camp.Active__c = true;
        camp.Member_Type__c = 'Account';
        camp.RecordTypeId = filteredId;
        camp.Field_1__c = 'CloseDate';
        camp.Operator_1__c = 'greater or equal';
        camp.Value_1__c = '2024-01-03';
        camp.Field_2__c = 'StageName';
        camp.Operator_2__c = 'includes';
        camp.Value_2__c = 'Qualification';
        camp.Field_3__c = 'StageName';
        camp.Operator_3__c = 'excludes';
        camp.Value_3__c = 'Unit Booked';
        insert camp;
        
        WhatsApp_Campaign_Member__c mem = new WhatsApp_Campaign_Member__c();
        mem.WhatsApp_Campaign__c = camp.Id;
        mem.Member_Id__c = acc.Id;
        insert mem;
        
        WhatsAppFeedbackCapmaignController.whatsAppCapmaign(camp.Id);
    }
    
    @isTest
    public static void campTest2(){
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.RW_Mobile_No__c = '1234567890';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.AccountId  =acc.Id;
        opp.StageName = 'Qualification';
        opp.CloseDate = Date.today();
        insert opp;
        
        
        Id customizedId = Schema.SObjectType.WhatsApp_Campaign__c.getRecordTypeInfosByName().get('Customized').getRecordTypeId();
        WhatsApp_Campaign__c camp = new WhatsApp_Campaign__c();
        camp.Campaign_Name__c = 'Test Campaign1';
        camp.Active__c = true;
        camp.Member_Type__c = 'Account';
        camp.RecordTypeId = customizedId;
        insert camp;
        
        WhatsApp_Campaign_Member__c mem = new WhatsApp_Campaign_Member__c();
        mem.WhatsApp_Campaign__c = camp.Id;
        mem.Member_Id__c = acc.Id;
        insert mem;
        
        WhatsAppFeedbackCapmaignController.whatsAppCapmaign(camp.Id);
        WhatsAppFeedbackCapmaignController.updateCampaign(camp.Id, 'Campaign Sent');
        
        camp.Member_Type__c = 'Opportunity';
        update camp;
        WhatsApp_Campaign_Member__c mem1 = new WhatsApp_Campaign_Member__c();
        mem1.WhatsApp_Campaign__c = camp.Id;
        mem1.Member_Id__c = opp.Id;
        insert mem1;
        WhatsAppFeedbackCapmaignController.whatsAppCapmaign(camp.Id);
    }
    
    @isTest
    public static void campTest3(){
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.RW_Mobile_No__c = '1234567890';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.AccountId  =acc.Id;
        opp.StageName = 'Qualification';
        opp.CloseDate = Date.today();
        insert opp;
        
        
        Id customizedId = Schema.SObjectType.WhatsApp_Campaign__c.getRecordTypeInfosByName().get('Customized').getRecordTypeId();
        WhatsApp_Campaign__c camp = new WhatsApp_Campaign__c();
        camp.Campaign_Name__c = 'Test Campaign1';
        camp.Active__c = true;
        camp.Member_Type__c = 'Opportunity';
        camp.RecordTypeId = customizedId;
        insert camp;
        
        WhatsApp_Campaign_Member__c mem = new WhatsApp_Campaign_Member__c();
        mem.WhatsApp_Campaign__c = camp.Id;
        mem.Member_Id__c = opp.Id;
        insert mem;
        
        WhatsAppFeedbackCapmaignController.whatsAppCapmaign(camp.Id);
    }
    
    @isTest
    public static void campTest4(){
        
        Lead ld  = new Lead();
        ld.LastName = 'Test Lead';
        ld.RW_Mobile_No__c = '1234567890';
        insert ld;
        
        Id customizedId = Schema.SObjectType.WhatsApp_Campaign__c.getRecordTypeInfosByName().get('Customized').getRecordTypeId();
        WhatsApp_Campaign__c camp = new WhatsApp_Campaign__c();
        camp.Campaign_Name__c = 'Test Campaign1';
        camp.Active__c = true;
        camp.Member_Type__c = 'Lead';
        camp.RecordTypeId = customizedId;
        insert camp;
        
        WhatsApp_Campaign_Member__c mem = new WhatsApp_Campaign_Member__c();
        mem.WhatsApp_Campaign__c = camp.Id;
        mem.Member_Id__c = ld.Id;
        insert mem;
        
        WhatsAppFeedbackCapmaignController.whatsAppCapmaign(camp.Id);
    }
    
    @isTest
    public static void campTest5(){
        
        Lead ld  = new Lead();
        ld.LastName = 'Test Lead';
        ld.RW_Mobile_No__c = '1234567890';
        insert ld;
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.RW_Mobile_No__c = '1234567890';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.AccountId  =acc.Id;
        opp.StageName = 'Qualification';
        opp.CloseDate = Date.today();
        insert opp;
        
        Id recTypeId = Schema.SObjectType.WhatsApp_Campaign__c.getRecordTypeInfosByName().get('Email').getRecordTypeId();
        WhatsApp_Campaign__c camp = new WhatsApp_Campaign__c();
        camp.Campaign_Name__c = 'Test Campaign';
        camp.Member_Type__c = 'Lead';
        camp.RecordTypeId = recTypeId;
        camp.Email_Template__c = 'News Letter';
        insert camp;
        
        WhatsApp_Campaign__c camp1 = new WhatsApp_Campaign__c();
        camp1.Campaign_Name__c = 'Test Campaign1';
        camp1.Member_Type__c = 'Opportunity';
        camp1.RecordTypeId = recTypeId;
        camp1.Email_Template__c = 'News Letter';
        insert camp1;
        
        WhatsApp_Campaign__c camp2 = new WhatsApp_Campaign__c();
        camp2.Campaign_Name__c = 'Test Campaign2';
        camp2.Member_Type__c = 'Account';
        camp2.RecordTypeId = recTypeId;
        camp2.Email_Template__c = 'News Letter';
        insert camp2;
        
        WhatsApp_Campaign_Member__c mem = new WhatsApp_Campaign_Member__c();
        mem.WhatsApp_Campaign__c = camp.Id;
        mem.Member_Id__c = ld.Id;
        insert mem;
        
        WhatsApp_Campaign_Member__c mem1 = new WhatsApp_Campaign_Member__c();
        mem1.WhatsApp_Campaign__c = camp1.Id;
        mem1.Member_Id__c = opp.Id;
        insert mem1;
        
        WhatsApp_Campaign_Member__c mem2 = new WhatsApp_Campaign_Member__c();
        mem2.WhatsApp_Campaign__c = camp2.Id;
        mem2.Member_Id__c = acc.Id;
        insert mem2;
        
        Test.startTest();
        WhatsAppFeedbackCapmaignController.whatsAppCapmaign(camp.Id);
        WhatsAppFeedbackCapmaignController.whatsAppCapmaign(camp1.Id);
        WhatsAppFeedbackCapmaignController.whatsAppCapmaign(camp2.Id);
        
        
        Database.executeBatch(new SendCampaignEmailsBatch(new List<String>{'test@mail.com'}, 'News Letter'));
        
        Test.stopTest();
    }


}