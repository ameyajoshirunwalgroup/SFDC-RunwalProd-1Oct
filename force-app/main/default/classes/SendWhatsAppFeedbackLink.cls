public class SendWhatsAppFeedbackLink {
    
   @invocablemethod
  Public static void  WhatsAppFeedbackLink(List<Id> Ids){
     //Opportunity Oppo = [SELECT Id, RW_Mobile_No__c, Project_Name__c, RW_Email__c,Latest_SV_Survey_Link__c FROM Opportunity where ID In: Ids Limit 1];
     //SendWhatsAppMsg.genaricMethodToSendWhatsAppMsg(Oppo.Project_Name__c, Url.getOrgDomainUrl().toExternalForm()+'/SurveyPage?sid='+Oppo.Latest_SV_Survey_Link__c, null, null,null,null,null, Oppo.RW_Mobile_No__c,System.Label.Lead_Visit_Done_Thank_You_Feedback_HSM);
        
      Survey__c survey = [SELECT Id, Name, Opportunity__c,Survey_Link__c,Opportunity__r.RW_Mobile_No__c,Opportunity__r.Project_Name__c, Opportunity__r.LeadSource FROM Survey__c where ID In: Ids Limit 1]; 
      system.debug('Process builder CIF whatsApp_______ '+ survey);
      //Added by Vinay 29-10-2021
      if(survey.Opportunity__r.LeadSource != 'Channel Partner' && !Test.isRunningTest()){
      		//SendWhatsAppMsg.genaricMethodToSendWhatsAppMsg(survey.Opportunity__r.Project_Name__c, Url.getOrgDomainUrl().toExternalForm()+'/SurveyPage?sid='+survey.Id, null, null,null,null,null,null,null, survey.Opportunity__r.RW_Mobile_No__c,System.Label.Lead_Visit_Done_Thank_You_Feedback_HSM);
            SendWhatsAppMsg.genaricMethodToSendWhatsAppMsg(survey.Opportunity__r.Project_Name__c, Url.getOrgDomainUrl().toExternalForm()+'/SurveyPage?sid='+survey.Id, null, null,null,null,null,null,null, survey.Opportunity__r.RW_Mobile_No__c,'Lead Visit Done Thank You Feedback');
      }
      //Commented by Vinay 29-10-2021
      //SendWhatsAppMsg.genaricMethodToSendWhatsAppMsg(survey.Opportunity__r.Project_Name__c, Url.getOrgDomainUrl().toExternalForm()+'/SurveyPage?sid='+survey.Id, null, null,null,null,null,null,null, survey.Opportunity__r.RW_Mobile_No__c,System.Label.Lead_Visit_Done_Thank_You_Feedback_HSM);
   }

}