@isTest
public class InboundSMSTracker
{
    private static Lead objLead;
    private static testmethod void TestMethod1()
    {
      ApexPages.currentPage().getParameters().put('mobile','9868675645');
      ApexPages.currentPage().getParameters().put('SMSText','abc');
      ApexPages.currentPage().getParameters().put('time','system.today()');
      ApexPages.currentPage().getParameters().put('to','test'); 
      ApexPages.currentPage().getParameters().put('Circle','delhi');
      ApexPages.currentPage().getParameters().put('Operator','vodafone');
      InboundSMS objInboundsms = new InboundSMS();
      objInboundsms.InsertLead();
    }
    
    private static testMethod void TestMethod2()
    {
    InboundSMS objInboundsms = new InboundSMS();
    objInboundsms.InsertLead();
    }
 }