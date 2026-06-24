public class SendWhatsAppOnNewLeadCreation {
    
    @invocablemethod
    Public static void  WhatsAppOnNewLeadCreation(List<Id> Ids){
        system.debug('Process builder Ids_______ '+ Ids);
        
        
        Lead led = [SELECT Id,LeadSource,Email,Name,RW_Project__c,Project_Name__c,RW_Project__r.RW_Project_Brochure_ID__c,RW_Project__r.RW_LocalityName__c,	
                    RW_Project__r.RW_Project_Brochure_PublicUrl__c,RW_Project__r.RW_Project_Location_Videos_Link__c,	
                    RW_Project__r.Site_Address_Map_Link__c,RW_Mobile_No__c, Referral_Batch_Lead__c FROM Lead Where ID In: Ids  Limit 1];
        
        //query on template object
        EmailTemplate et=[Select id,Name from EmailTemplate where name=:'Lead welcome email notification to customer'];
     //commented on 9-5-25 
     //   OrgWideEmailAddress owa = [select id, Address, DisplayName from OrgWideEmailAddress where DisplayName = 'Runwal Cares'];
          OrgWideEmailAddress owa = [select id, Address, DisplayName from OrgWideEmailAddress where DisplayName = 'Runwal  Homes'];

        //list of emails
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();   
        RW_Presales_Communication__c preComm = New RW_Presales_Communication__c();
        
        if(String.isNotBlank(led.Email)){
            Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
            singleMail.setTargetObjectId(led.Id);
            singleMail.setTemplateId(et.id);
            singleMail.setUseSignature(false);
            singleMail.setBccSender(false);
            singleMail.setSaveAsActivity(false);
            singleMail.setOrgWideEmailAddressId(owa.id);
            singleMail.setWhatId(led.Id);
            singleMail.toaddresses = new string[]{led.Email};
            emails.add(singleMail);
        }
        preComm.RW_Lead_Created_Mode_of_Communication__c = 'Email';
        
        
        system.debug('Process builder NewLeadCreation_______ '+ led);
        system.debug('Process builder RW_Project__c _______ '+ led.RW_Project__c);
        system.debug('Process builder Project_Name__c _______ '+ led.Project_Name__c);
        
        // SendWhatsAppMsg.genaricMethodToSendWhatsAppMsg(led.Project_Name__c, null, null, null,null,null,null, led.RW_Mobile_No__c,System.Label.New_Lead_Greeting_HSM);
        if(String.isNotBlank(led.Name) && String.isNotBlank(led.Project_Name__c) && 
           String.isNotBlank(led.RW_Project__r.RW_LocalityName__c) && String.isNotBlank(led.RW_Project__r.Site_Address_Map_Link__c) && 
           String.isNotBlank(led.RW_Project__r.RW_Project_Brochure_PublicUrl__c) &&
           String.isNotBlank(led.RW_Project__r.RW_Project_Location_Videos_Link__c) && String.isNotBlank(led.RW_Mobile_No__c)){
            
               String Signature;
               String ContactNumber;
               if(String.isNotBlank(led.LeadSource)){
                   if(led.LeadSource == 'Channel Partner'){
                       Signature = System.Label.RW_CPSignature;
                       ContactNumber = System.Label.RW_CPContactNumber;
                   }else if(led.LeadSource != 'Channel Partner'){
                       Signature = System.Label.RW_NotCPSignature;
                       ContactNumber = System.Label.RW_NotCPContactNumber;
                   }
               } 
               
               //if(!Test.isRunningTest()){
                   If(String.isNotBlank(System.Label.StopWhatsAppOnLeadCreation) && System.Label.StopWhatsAppOnLeadCreation == 'No'){
                       System.debug('inside Label If_____'+System.Label.StopWhatsAppOnLeadCreation);
                       List<String> leadSources = System.label.Loyalty_Referral_Lead_Sources.split(','); //Added by coServe 19-06-2024
                       //Added by Vinay 29-10-2021
                       if(led.LeadSource != 'Channel Partner' && !leadSources.contains(led.LeadSource)){
                          /*SendWhatsAppMsg.genaricMethodToSendWhatsAppMsg(led.Name,led.Project_Name__c, led.RW_Project__r.RW_LocalityName__c,
                                                                      led.RW_Project__r.Site_Address_Map_Link__c, 
                                                                      led.RW_Project__r.RW_Project_Brochure_PublicUrl__c,
                                                                      led.RW_Project__r.RW_Project_Location_Videos_Link__c,System.Label.Website_URL,
                                                                      ContactNumber,Signature,led.RW_Mobile_No__c,System.Label.Lead_Project_Content2_HSM);*/
                           if(!Test.isRunningTest()){
                               /*SendWhatsAppMsg.genaricMethodToSendWhatsAppMsg(led.Name,led.Project_Name__c, led.RW_Project__r.RW_LocalityName__c,
                                                                      led.RW_Project__r.Site_Address_Map_Link__c, 
                                                                      led.RW_Project__r.RW_Project_Brochure_PublicUrl__c,
                                                                      led.RW_Project__r.RW_Project_Location_Videos_Link__c,System.Label.Website_URL,
                                                                      ContactNumber,Signature,led.RW_Mobile_No__c,'Lead Project Content 2');*/  //Commented by Vinay 04-02-2025
                           }
                       		preComm.RW_Lead_Created_Mode_of_Communication__c += ',WhatsApp'; 
                       }
                       if(leadSources.contains(led.LeadSource) && !led.Referral_Batch_Lead__c){ //Added by coServe 19-06-2024
                           if(!Test.isRunningTest()){
                                SendWhatsAppMsg.methodToSendWhatsAppMsg(null,led.Project_Name__c,null,null, null,null,null,null,null,'+91',led.RW_Mobile_No__c,'Loyalty Lead Creation');
                           }
                            preComm.RW_Lead_Created_Mode_of_Communication__c += ',WhatsApp'; 
                       }
                       //Commented by Vinay 29-10-2021
                       /*SendWhatsAppMsg.genaricMethodToSendWhatsAppMsg(led.Name,led.Project_Name__c, led.RW_Project__r.RW_LocalityName__c,
                                                                      led.RW_Project__r.Site_Address_Map_Link__c, 
                                                                      led.RW_Project__r.RW_Project_Brochure_PublicUrl__c,
                                                                      led.RW_Project__r.RW_Project_Location_Videos_Link__c,System.Label.Website_URL,
                                                                      ContactNumber,Signature,led.RW_Mobile_No__c,System.Label.Lead_Project_Content2_HSM);	
                       preComm.RW_Lead_Created_Mode_of_Communication__c += ',WhatsApp';*/
                       
                   }
                    System.debug('Outside Label If_____'+System.Label.StopWhatsAppOnLeadCreation);
               //} 
           }
        preComm.RW_Lead__c = led.Id;
        preComm.RW_Lead_Created_Email_WhatsApp_Sent_Date__c= system.now();
        
        
        Messaging.SendEmailResult[] results = Messaging.sendEmail(emails);
        system.debug('Messaging ' + results[0]);
        
        if (results[0].success) 
        {
            Insert preComm;
            System.debug('RW_Presales_Communication__c Record Created______ ' +preComm);
            System.debug('The email was sent successfully.');
        } else 
        {
            System.debug('The email failed to send: ' + results[0].errors[0].message);
        }
        //Ends here
        
    }
    
}