/**=====================================================================
* E&Y LLP
* Name: SendEmailWhatsAppToLeads
* Description: Batch class to send WhatsApp,Email for Lead created from
  FB,99Acres,HousingCom,MagicBricks
* Created Date: [26/03/2021]
* Created By: MounikaRamagoni (E&Y LLP)
*
* Date Modified Modified By Description of the update
* [MON DD, YYYY] [FirstName LastName] [Short description for changes]
=====================================================================*/


public class SendEmailWhatsAppToLeads implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        String STR_CUSTOM_SETTING_NAME = 'SendEmailWhatsAppLimit';
        List<SendEmailWhatsAppToLeadsLimit__c> lstSendEmailWhatsAppToLeadsLimit = [SELECT Name,Limit__c FROM SendEmailWhatsAppToLeadsLimit__c WHERE Name =: STR_CUSTOM_SETTING_NAME ];
        Decimal strLimit = lstSendEmailWhatsAppToLeadsLimit[0].Limit__c;
        String[] lstLeadSources = Label.LeadSourceToSendWhatsApp.split(',');
        String query = 'SELECT Id,Name,Email,Project_Name__c,RW_Mobile_No__c,RW_Project__r.RW_LocalityName__c, RW_Project__r.Site_Address_Map_Link__c, RW_Project__r.RW_Project_Brochure_PublicUrl__c, RW_Project__r.RW_Project_Location_Videos_Link__c,RW_WhatsApp_Sent_to_DigitalLead__c,LeadSource FROM Lead WHERE LeadSource IN: lstLeadSources AND CreatedDate = Today AND RW_WhatsApp_Sent_to_DigitalLead__c = false LIMIT '+ strLimit;
               
        system.debug('query___ '+query);
        return Database.getQueryLocator(query);
    } 
    
    public void execute(Database.BatchableContext bc, List<lead> leadList){
        String STR_EMAIL_TEMPLATE_NAME = 'Send Project Details on Lead Create';
        //String STR_ORGWIDE_EMAIL_ADDRESS_NAME = 'runwalcare@runwal.com'; //Commented by coServe 26-02-2024
        String STR_ORGWIDE_EMAIL_ADDRESS_NAME = 'runwalcare@runwalgroup.in';//Added by coServe 26-02-2024
        List<Lead> leadListToUpdate;
        List<RW_Presales_Communication__c> preCommListToInsert;
        
        System.debug('leadList____' + leadList.size()); 
        //query on template object
        EmailTemplate emailTemplate = [SELECT id,Name FROM EmailTemplate WHERE Name =: STR_EMAIL_TEMPLATE_NAME];
        OrgWideEmailAddress orgWideEmailAddress = [SELECT id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address =: STR_ORGWIDE_EMAIL_ADDRESS_NAME];
        
        //list of emails
        List<Messaging.SingleEmailMessage> lstEmails = new List<Messaging.SingleEmailMessage>();   
        preCommListToInsert = new List<RW_Presales_Communication__c>();
        leadListToUpdate = new List<Lead>();
        
        for(Lead lead: leadList){
            if(String.isNotBlank(lead.Project_Name__c)){
                RW_Presales_Communication__c preComm = new RW_Presales_Communication__c();
                if(lead.Email != null){
                    Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
                    singleMail.setTargetObjectId(lead.Id);
                    singleMail.setTemplateId(emailTemplate.id);
                    singleMail.setOrgWideEmailAddressId(orgWideEmailAddress.id);
                    singleMail.setSaveAsActivity(false);
                    singleMail.setWhatId(lead.Id);
                    singleMail.toaddresses = new string[]{lead.Email};
                        lstEmails.add(singleMail);
                }
                
                preComm.RW_Lead__c = lead.Id;
                
                preComm.RW_Lead_Created_Email_WhatsApp_Sent_Date__c = system.now();
                preComm.RW_Communication_Sent_To_DigitalLead__c = True;
                
                if(String.isNotBlank(lead.RW_Mobile_No__c) && String.isNotBlank(lead.RW_Project__c) &&
                   String.isNotBlank(System.Label.StopWhatsAppOnLeadCreationBatch) && System.Label.StopWhatsAppOnLeadCreationBatch == 'No'){
                       //Added by Vinay 29-10-2021
                       if(lead.LeadSource != 'Channel Partner' ){
                           //SendWhatsAppMsgForBatch.genaricMethodToSendWhatsAppMsgForBatch(lead.Id, System.Label.Lead_Project_Content2_HSM);
                           SendWhatsAppMsgForBatch.genaricMethodToSendWhatsAppMsgForBatch(lead.Id, 'Lead Project Content 2');
                       }
                     //Commented below one Line by Vinay 29-10-2021
                    //SendWhatsAppMsgForBatch.genaricMethodToSendWhatsAppMsgForBatch(lead.Id, System.Label.Lead_Project_Content2_HSM);
                    //lead.Name,lead.Project_Name__c, lead.RW_Project__r.RW_LocalityName__c, lead.RW_Project__r.Site_Address_Map_Link__c, lead.RW_Project__r.RW_Project_Brochure_PublicUrl__c, lead.RW_Project__r.RW_Project_Location_Videos_Link__c,System.Label.RW_SalesContact, lead.RW_Mobile_No__c,System.Label.Lead_Project_Content_HSM);	
                    lead.RW_WhatsApp_Sent_to_DigitalLead__c = True;
                    leadListToUpdate.add(lead);
                    preComm.RW_Lead_Created_Mode_of_Communication__c = 'WhatsApp';
                   }
                preCommListToInsert.add(preComm);
            }
        }
        system.debug('lstEmails___ ' + lstEmails);
        system.debug('lstEmails___size___ ' + lstEmails.size());
        
        
        Set<ID> targetIdsFailed = new Set<ID>(); 
        Messaging.SendEmailResult[] results = Messaging.sendEmail(lstEmails, false);
        for(Messaging.SendEmailResult result: results) {
            if(!result.isSuccess()) {
                // render the error somehow
                system.debug('insdie error');
                Messaging.SendEmailError[] errArr = result.getErrors();
                for(Messaging.SendEmailError err: errArr){
                    System.debug('errArr____' + err.getTargetObjectId());  
                    targetIdsFailed.add(err.getTargetObjectId()); 
                }
                
            }
        }
        
        
        for(RW_Presales_Communication__c precom: preCommListToInsert){
            if(!targetIdsFailed.contains(precom.RW_Lead__c)){
                If( String.isNotBlank(System.Label.StopWhatsAppOnLeadCreationBatch) && System.Label.StopWhatsAppOnLeadCreationBatch == 'No'){
                    precom.RW_Lead_Created_Mode_of_Communication__c += ',Email';
                }else{
                    precom.RW_Lead_Created_Mode_of_Communication__c = 'Email';
                }  
                
                system.debug('precom___ Error '+precom.Name);
                system.debug('precom___ Error '+precom.RW_Lead_Created_Mode_of_Communication__c);
            }    
        }
        
        insert preCommListToInsert;
        
        update leadListToUpdate; 
        System.debug('leadListToUpdate Total____' + leadListToUpdate.size());   
        
    }
    
    
    public void finish(Database.BatchableContext bc){
        
    }
}