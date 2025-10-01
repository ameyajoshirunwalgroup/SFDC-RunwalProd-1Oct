@isTest
public class TestRESTGetExistingLead 
{
    public static testMethod void getExistingLead() 
    {
        Test.startTest();
        REST_GetExistingLead.REST_result re=new REST_GetExistingLead.REST_result();
        re.returnCode=1;re.message='gg';re.recordId='sefe';
        
        Lead l=new Lead(lastname='A',IsConverted=false,RW_Mobile_No__c='8855885729');
        insert l;
        
        Account a=new Account(name='B',Mobile_No__c='8855885731');
        insert a;
        
        
        REST_GetExistingLead gl=new REST_GetExistingLead();
        REST_GetExistingLead.REST_result r1= REST_GetExistingLead.GetId('8855885729');
        REST_GetExistingLead.REST_result r2= REST_GetExistingLead.GetId('8855885731');
        REST_GetExistingLead.REST_result r3= REST_GetExistingLead.GetId('8855885726');
        REST_GetExistingLead.REST_result r4= REST_GetExistingLead.GetId('');
        System.debug(r1);System.debug(r2);System.debug(r3);System.debug(r4);



   Test.stopTest();      
    }
}