@isTest
public class TestKserveIntegration {
   @isTest
    public static void test (){
        
        Project__c prj = new Project__c();
        prj.Name='Runwal Gardens';
        prj.Kserve_Integration__c = true;
        insert prj;
        
        Lead l = new Lead();
        l.Project_Name__c = prj.id;
        l.RW_Mobile_No__c = '1234567890';
        l.Phone = '9987654321';
        l.FirstName ='test';
        l.LastName ='tested';
        l.Lead_Source__c='Digital';
        l.LeadSource ='Digital';
        l.Lead_Sub_Source__c='BING';
        l.RDS_Country_Code__c = '+91';
        insert l;
        Lead leadOb = [Select Id, Name,LeadSource,RDS_Country_Code__c,Kserve_Integration__c from Lead where Id =: l.Id];
        system.debug('LeadObj List::'+leadOb);
        Set<Id> IdSet = new Set<Id>{leadOb.Id};
        KserveIntegration ksv = new KserveIntegration(IdSet);  
        System.enqueueJob(new KserveIntegration(IdSet));
 
        KserveIntegration.dummy();
        
        //l.Send_to_Kserve__c = true;
        //update l;
        
        
        //KserveIntegration.LeadDetails(IdSet);
        //KserveIntegration.dummy();
    }
    
}