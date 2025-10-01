@istest
public class UniversalTestClassForChannelPartner2 {
    
    @testsetup
    public static void setupdata(){
        
        Broker__c br = new Broker__c();
        br.name ='test';
        //br.Broker_Pan_No__c ='tyui6uus';
        br.Broker_Pan_No__c ='TYUI6UUS';
        //br.RW_RERA_Registration_Number__c='fghjkl';
        br.RW_RERA_Registration_Number__c='123456789012';
        br.RW_IRIS_Sync__c = true;
        br.RW_CreateFromIRIS__c=true;
        br.STREET__c = 'Street';
        br.STR_SUPPL1__c = 'Street1';
        br.STR_SUPPL2__c = 'Street2';
        br.STR_SUPPL3__c = 'street3';
        insert br;
    }
 @istest
    public static void testsapapi(){
          Test.setMock(HttpCalloutMock.class, new UniversalHttpMockClass());  
        Test.setMock(WebServiceMock.class, new UniversalSAPMockClass());

          List<Broker__c> s = [select id from Broker__c];
                 SAPChannelPartnerAPICallOut.sendBrokerlist(s[0].id);

    }
     @istest
    public static void testsapapi1(){
  Test.setMock(HttpCalloutMock.class, new UniversalIrisMockErrorClass());  
        Test.setMock(WebServiceMock.class, new UniversalSAPMockClass());

          List<Broker__c> s = [select id from Broker__c];
                 SAPChannelPartnerAPICallOut.sendBrokerlist(s[0].id);

    }
       @istest
    public static void testsapapi3(){
  Test.setMock(HttpCalloutMock.class, new UniversalIrisMockClass());  
        Test.setMock(WebServiceMock.class, new UniversalSAPMockClass());

          List<Broker__c> s = [select id from Broker__c];
                 SAPChannelPartnerAPICallOut.sendBrokerlist(s[0].id);

    }     

}