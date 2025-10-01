public class SendBulkLeadManagementServices {
    
    Public static Id SendBulkLeadBatch(string CampName){ //, string templateName
        List<CampaignMember> lstSendMailCM = new List<CampaignMember>();
        Set<Id> lstSendMail = new Set<Id>();
        lstSendMailCM = [SELECT Id,Lead.id,Lead.Name,Contact.AccountId ,Contact.name, Email, FirstName ,LastName, Type 
                         FROM CampaignMember 
                         WHERE Campaignid = :CampName ]; // email != '' AND 
        for(CampaignMember cm : lstSendMailCM){
            lstSendMail.add(cm.id); 
        }
        system.debug('lstSendMail:: '+lstSendMail.size());
        SendBulkLeadBatch sm = new SendBulkLeadBatch(lstSendMail); //templateName
        Id batchId = database.executeBatch(sm, 200);
        return batchId;
    } 
    
    @future(callout=true)
    Public static void sendMail( Set<Id> cmIds){   //, string templateName
        List<CampaignMember> cmList = new List<CampaignMember>();
        cmList = [SELECT Id,Lead.id,Lead.Name, Lead.RW_Configuration__c,Lead.Address,Lead.Mobile_Number__c,
                  Lead.RW_Budget__c,Lead.RW_Mobile_No__c,Lead.X18_Digit_SF_ID__c,Lead.RDS_Country_Code__c,Lead.Project_Name__c,
                  Contact.AccountId ,Contact.name, Contact.Account.X18_Digit_SF_ID__c,Contact.Account.Mobile_No__c,
                  Contact.Account.Country_Code__c,Contact.Account.PersonEmail,
                  Email,FirstName ,LastName, Type 
                  FROM CampaignMember WHERE id IN :cmIds]; //email != '' AND
       
        
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
      
        system.debug('CM in the sendMail::'+cmList);
        
        List<CBSLBulkLead__c> cblist = [select id, name, Endpoint__c From CBSLBulkLead__c Where name =: 'URL'];
        System.debug('cblist::::::::::::::::'+cblist[0]);
        String url = cblist[0].Endpoint__c; //CBSLBulkLead__c.getValues('Endpoint').URL;
        req.setEndpoint(url);
        req.setTimeout(120000);  
        req.setHeader('Content-Type', 'application/json');
        
        String authorizationHeader = 'Basic'; //+Encodingutil.base64Encode(Blob.valueOf(User+':'+Pwd));  //
        req.setHeader('Authorization', authorizationHeader);                                                 
        req.setMethod('POST');

        System.debug('authorizationHeader::::::::::::::::::::::::::::'+authorizationHeader);
        System.debug('req::::::::::::::::::::::::::::::'+req);
     
        JSONGenerator leadEmailJson = JSON.createGenerator(true);
        
        if(cmList != null && !cmList.isEmpty()){
            leadEmailJson.writeStartObject();
            leadEmailJson.writeFieldName('LeadInfoList');
            leadEmailJson.writeStartArray();
            
            for(CampaignMember cm : cmList){
                leadEmailJson.writeStartObject();
                if(cm.type == 'Lead'){
                    leadEmailJson.writeStringField('p_cCon', cm.Lead.X18_Digit_SF_ID__c);
                    leadEmailJson.writeStringField('p_cCustomerName', cm.Lead.name);
                    leadEmailJson.writeStringField('p_cPhNo1',cm.Lead.RDS_Country_Code__c+' '+ cm.Lead.RW_Mobile_No__c);
                    leadEmailJson.writeStringField('p_cEmailID', cm.Email);
                    leadEmailJson.writeStringField('p_cProject', cm.Lead.Project_Name__c);
                    
                } if(cm.type == 'Contact'){
                    leadEmailJson.writeStringField('p_cCon', cm.Contact.Account.X18_Digit_SF_ID__c);
                    leadEmailJson.writeStringField('p_cCustomerName', cm.Contact.name);
                    leadEmailJson.writeStringField('p_cPhNo1',cm.Contact.Account.Country_Code__c+' '+ cm.Contact.Account.Mobile_No__c);
                    leadEmailJson.writeStringField('p_cEmailID', cm.Contact.Account.PersonEmail);
                    leadEmailJson.writeStringField('p_cProject', '');
                }
                leadEmailJson.writeStringField('p_cBatchID', '101');
                leadEmailJson.writeStringField('p_cProcess', '76');
                leadEmailJson.writeStringField('p_cConfiguration', ''); //cm.Lead.RW_Configuration__c
                leadEmailJson.writeStringField('p_cCustLocation', ''); 
                leadEmailJson.writeStringField('p_cPhNo2', '');
                leadEmailJson.writeStringField('p_cMob1', '');
                leadEmailJson.writeStringField('p_cMob2', '');
                leadEmailJson.writeStringField('p_cEthnicity', '');//cm.Lead.RW_Ethnicity__c
                leadEmailJson.writeStringField('p_cBudget', ''); //cm.Lead.RW_Budget__c
                leadEmailJson.writeStringField('p_cCustomerID', ''); //cm.Lead.X18_Digit_SF_ID__c
                
                leadEmailJson.writeEndObject(); 
            }
            leadEmailJson.writeEndArray();
            leadEmailJson.writeEndObject();
        }
        String JBody = leadEmailJson.getAsString();
        System.debug('JBody::::'+JBody);
        if(jBody != '' && jBody != null){
            req.setBody(jBody);
        }
        
        if(!Test.isRunningTest()) { 
         res = http.send(req);
         }else{}
        System.debug(res.getBody());
        System.debug('res success:: '+ res.getStatusCode());
    }
    
    
    Public static void insertTask( Set<Id> cmIds){  //, string templateName
        List<CampaignMember> lstSendMailCM = new List<CampaignMember>();
        List<Task> TaskToInsertOnlead = new List<Task>();
        List<Task> TaskToInsertOnAcc = new List<Task>();
        List<Task> TaskToInsertOnCampaign = new List<Task>();
        lstSendMailCM = [SELECT Id,Lead.id,Lead.Name, Contact.AccountId ,Contact.name, Email,FirstName ,LastName, Type ,CampaignId
                         FROM CampaignMember WHERE  email != '' AND id IN :cmIds];
       // List<EmailTemplate> et = [SELECT Id, Name, Subject, Body FROM EmailTemplate WHERE Id =: templateName];
        if(lstSendMailCM != null && !lstSendMailCM.isEmpty()){
               Task tskNew1 = new Task();
                tskNew1.WhatId = lstSendMailCM[0].CampaignId;
                System.debug('cm id :'+lstSendMailCM[0].CampaignId);    
                tskNew1.Subject = 'Mass Lead Send';
                tskNew1.Priority = 'Normal';
                tskNew1.Status= 'Completed';
                tskNew1.ActivityDate = System.Today();
                tskNew1.Description = 'Campaign - Lead has been sent sucessfully';
                TaskToInsertOnCampaign.add(tskNew1);
            for(CampaignMember cm : lstSendMailCM){
                Task tskNew = new Task();              
                if(cm.Type == 'Lead'){
                    tskNew.WhoId = cm.Lead.id;
                    System.debug('lead id'+cm.Lead.Id);    
                    tskNew.Subject = 'Mass Lead Send';
                    tskNew.Priority = 'Normal';
                    tskNew.Status= 'Completed';
                    tskNew.ActivityDate = System.Today();
                    tskNew.Description = 'Lead has been sent sucessfully';
                    TaskToInsertOnlead.add(tskNew);
                } 
                else if (cm.Type == 'Contact'){
                    tskNew.whatId = cm.Contact.AccountId;
                    System.debug('AccountId'+cm.Contact.AccountId);
                    tskNew.Subject = 'Mass Lead Send';
                    tskNew.Priority = 'Normal';
                    tskNew.Status= 'Completed';
                    tskNew.ActivityDate = System.Today();
                    tskNew.Description = 'Lead has been sent sucessfully';
                    TaskToInsertOnAcc.add(tskNew);    
                }else{}
            }
             if(!Test.isRunningTest()) {
            insert TaskToInsertOnCampaign;
            insert TaskToInsertOnlead;
            insert TaskToInsertOnAcc;
            }else{}
        }
    }

}