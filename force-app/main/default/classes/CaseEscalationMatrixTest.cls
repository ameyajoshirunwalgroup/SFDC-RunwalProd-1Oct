@isTest
public class CaseEscalationMatrixTest {
    
    @isTest
    public static void escalationTest(){
        
        Case cs = new Case();
        cs.Status = 'Open';
        cs.RW_Case_Type__c = 'Complaint';
        cs.Customer_Lifecycle_Touchpoint__c = 'Pre-Booking Experience';
        cs.RW_Complaint_Type__c = 'Booking Experience';
        cs.RW_Complaint_SubType__c = 'Misinformed by Sales';
        cs.Escalation_Level__c = 'New';
        cs.RW_RM_Name__c = 'Vinay Kumar';
        insert cs;
        
        RM_Usernames__c rm = new RM_Usernames__c();
        rm.Name = 'EY Admin';
        rm.RW_Email__c = 'vinay@mail.com';
        rm.User_Name__c = 'vinay@mail.com';
        rm.RW_Reporting_1_Email__c = 'vinay@mail.com';
        rm.RW_Reporting_2_Email__c = 'vinay@mail.com';
        rm.RW_Reporting_3_Email__c = 'vinay@mail.com';
        rm.RW_Reporting_4_Email__c = 'vinay@mail.com';
        insert rm;
        
        Case_Escalation_Matrix_SLA__c sla = new Case_Escalation_Matrix_SLA__c();
        sla.Name = 'sla1';
        sla.SLA__c = 1;
        sla.Case_Type__c = 'Booking Experience';
        sla.Case_Sub_Type__c = 'Misinformed by Sales';
        sla.Customer_Lifecycle_Touchpoint__c = 'Pre-Booking Experience';
        sla.Active__c = true;
        insert sla;
        
        User usr = new User();
        usr.FirstName = 'Vinay';
        usr.LastName = 'V2';
        usr.email = 'vinay@mail.com';
        usr.Username =  'vinay@mail.com';
        usr.EmailEncodingKey = 'ISO-8859-1';
        usr.Alias = 'vina';
        usr.TimeZoneSidKey = 'America/Los_Angeles';
        usr.LocaleSidKey = 'en_US';
        usr.LanguageLocaleKey = 'en_US';
        usr.ProfileId = System.label.System_Administrator_Profile_Id;
        insert usr;
        
        
        Test.startTest();
        CaseEscalationMatrix c1 = new CaseEscalationMatrix();
        c1.execute(null);
        
        Case cs1 = [SELECT Id, Escalation_Level__c FROM Case WHERE Id =: cs.Id];
        Assert.areEqual('Level 1', cs1.Escalation_Level__c, 'Escalation Level should be updated as Level 1');
        
        CaseEscalationMatrix c2 = new CaseEscalationMatrix();
        c2.execute(null);
        
        Case cs2 = [SELECT Id, Escalation_Level__c FROM Case WHERE Id =: cs.Id];
        Assert.areEqual('Level 2', cs2.Escalation_Level__c, 'Escalation Level should be updated as Level 2');
        
        CaseEscalationMatrix c3 = new CaseEscalationMatrix();
        c3.execute(null);
        
        Case cs3 = [SELECT Id, Escalation_Level__c FROM Case WHERE Id =: cs.Id];
        Assert.areEqual('Level 3', cs3.Escalation_Level__c, 'Escalation Level should be updated as Level 3');
        
        Test.stopTest();
    }

}