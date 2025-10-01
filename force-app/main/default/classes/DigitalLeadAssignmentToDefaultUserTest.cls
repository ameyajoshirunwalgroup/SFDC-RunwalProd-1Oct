@isTest
public class DigitalLeadAssignmentToDefaultUserTest {
    
    @isTest
    public static void test1(){
        
        
        Lead ld = new Lead();
        ld.LastName = 'Test';
        ld.RW_Mobile_No__c = '2563214578';
        ld.Email = 'test@mail.com';
        ld.LeadSource = 'Digital';
        ld.Lead_Sub_Source__c = 'AdgebraNative';
        ld.Client_Type__c = 'Local';
        insert ld;
        
        DigitalLeadAssignmentToDefaultUser b = new DigitalLeadAssignmentToDefaultUser();
        b.execute(null);
        
    }
    
}