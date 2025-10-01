public class SendWhatsAppLeadVisitConfirmed {
    
  @invocablemethod
  Public static void  WhatsAppLeadVisitconfirmed(List<Id> Ids){
      OTP__c otp = [SELECT Id, Customer_Name__c,Project__r.ProjectName__c,Customer_Site_Visit_On__c,Generated_OTP__c,
                    Project__r.RW_Address__c,Direction__c,CP_Name__c,Customer_Mobile_No__c FROM OTP__c where ID In: Ids Limit 1];
      system.debug('Process builder OTP whatsApp_______ '+ otp);
      if(!test.isRunningTest()){
      	SendWhatsAppMsg.genaricMethodToSendWhatsAppMsg(otp.Customer_Name__c,otp.Project__r.ProjectName__c,otp.Customer_Site_Visit_On__c, otp.Generated_OTP__c,otp.Project__r.RW_Address__c,otp.Direction__c,null,otp.Customer_Mobile_No__c,System.Label.Lead_Visit_Confirmed_HSM);
      }        
       
    }


}