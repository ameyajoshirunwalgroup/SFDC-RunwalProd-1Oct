public without sharing class PresalesProjectDetailsController {      
    @AuraEnabled  
    public static RW_Presales_Communication__c sendProjectDetailsAsEmail(String strLeadIdOROppIdORProspectID, String strSObjectType, List<string> ltsSelectedCheckBoxValueIs, List<Id> selectedProjectIds){  
        System.debug('strLeadIdOROppIdORProspectID____ ' + strLeadIdOROppIdORProspectID + 'strSObjectType____ '+ strSObjectType + 'ltsSelectedCheckBoxValueIs____ '+ ltsSelectedCheckBoxValueIs + 'selectedProjectIds==>'+ selectedProjectIds);  
        
        Lead objLead;  
        Opportunity objOpp;   
        Prospect__c objPrspct;
        Set<string> setOfselectcheckVal = new Set<String>(); 
        RW_Presales_Communication__c preComm = New RW_Presales_Communication__c();  
        setOfselectcheckVal.addAll(ltsSelectedCheckBoxValueIs);
        System.debug('setOfselectcheckVal____'+setOfselectcheckVal);
        
        If(strSObjectType == 'Lead'){   
            objLead = [SELECT Id,Email,LeadSource,Name,Project_Name__c,RW_Project__r.Id,RW_Project__r.RW_Project_Brochure_ID__c,RW_Project__r.RW_LocalityName__c, RW_Project__r.RW_Project_Brochure_PublicUrl__c,RW_Project__r.RW_Project_Location_Videos_Link__c,  
                       RW_Project__r.Site_Address_Map_Link__c,RW_Mobile_No__c FROM Lead WHERE Id =: strLeadIdOROppIdORProspectID Limit 1];  
        }
        If(strSObjectType == 'Opportunity'){  
            objOpp = [SELECT Id,RW_Email__c,LeadSource,Name,Project_Name__c,RW_Project__r.Id,RW_Project__r.RW_Project_Brochure_ID__c,RW_Project__r.RW_LocalityName__c,  RW_Project__r.RW_Project_Brochure_PublicUrl__c,RW_Project__r.RW_Project_Location_Videos_Link__c,  
                      RW_Project__r.Site_Address_Map_Link__c,RW_Mobile_No__c FROM Opportunity WHERE Id =: strLeadIdOROppIdORProspectID Limit 1];  
        }
        If(strSObjectType == 'Prospect__c'){  
            System.debug('strSObjectType____'+strSObjectType); 
            System.debug('strLeadIdOROppIdORProspectID____'+strLeadIdOROppIdORProspectID); 
            objPrspct = [SELECT Id,Project__r.Name,Lead__r.Email,Lead__r.RW_Mobile_No__c,Lead__r.LeadSource,Opportunity__r.LeadSource,Opportunity__r.RW_Email__c, Opportunity__r.RW_Mobile_No__c,Lead__r.IsConverted,Lead__r.ConvertedOpportunityId,
                         Project__c,Name,Project__r.RW_Project_Brochure_ID__c,Project__r.RW_LocalityName__c,  
                         Project__r.RW_Project_Brochure_PublicUrl__c,Project__r.RW_Project_Location_Videos_Link__c,  
                         Project__r.Site_Address_Map_Link__c,Lead_Source__c FROM Prospect__c WHERE Id =: strLeadIdOROppIdORProspectID Limit 1];  
            System.debug('objPrspct____'+objPrspct);    
        }
        
        if(setOfselectcheckVal.contains('Email')){  
            System.debug('In Side Email____');
            List<Messaging.SingleEmailMessage> ltsEmail = new List<Messaging.SingleEmailMessage>(); 
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            ContentVersion objContentVersion;
            String strEmailTemplateName;
            String strObjId;
            String strEmailId;
            String strProjectId;
            String strtrgtObjId;
            string sObjId;
            EmailTemplate EmailTemplateId;
            OrgWideEmailAddress owa = [select Id, Address, DisplayName FROM OrgWideEmailAddress where DisplayName = 'Runwal Cares'];
            
            //query on template object
            If(strSObjectType == 'Lead' ){
                strEmailTemplateName = 'Send Project Details on Lead Create';
                strProjectId  = objLead.RW_Project__r.Id;
                strObjId = objLead.Id;
                strtrgtObjId = objLead.Id;
                strEmailId = objLead.Email;
                sObjId = objLead.Id;
                
            }
            if(strSObjectType == 'Opportunity' ){ 
                strEmailTemplateName = 'Send Project Details on Opportunity';
                strProjectId  = objOpp.RW_Project__r.Id;
                strObjId = objOpp.Id;
                strtrgtObjId = userinfo.getuserid();
                strEmailId = objOpp.RW_Email__c;
                sObjId = objOpp.Id;
                
            }
            if(strSObjectType == 'Prospect__c'){ 
                strEmailTemplateName = 'Send Project Details on Prospect';
                strProjectId  = objPrspct.Project__r.Id;
                strObjId = objPrspct.Id;
                strtrgtObjId = userinfo.getuserid();
                sObjId = objPrspct.Id; 
                if(objPrspct.Lead__r.IsConverted == false && String.isBlank(objPrspct.Lead__r.ConvertedOpportunityId)
                   && String.isNotBlank(objPrspct.Lead__r.Email) ){
                       strEmailId = objPrspct.Lead__r.Email;
                       System.debug('in IF ____ ' +strEmailId);
                   }else if(String.isNotBlank(objPrspct.Opportunity__r.RW_Email__c)){
                       strEmailId = objPrspct.Opportunity__r.RW_Email__c;
                       System.debug('in else ____ ' +strEmailId);
                   }
                
            }
            System.debug('strEmailTemplateName____ ' + strEmailTemplateName + ' strProjectId____ '+ strProjectId + ' strObjId____ '+ strObjId + ' strtrgtObjId_____ '+ strtrgtObjId + ' strEmailId______' +strEmailId );  
            
            // Added bu Unicops team
            List<ContentVersion> lstContentVersion = new List<ContentVersion>();
            List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
            
            if(String.isNotBlank(strEmailTemplateName) && selectedProjectIds.size() == 0){
                EmailTemplateId =[Select Id,Name FROM EmailTemplate where name=: strEmailTemplateName];
                if(!Test.isRunningTest()){
                    try {
                        
                        if(String.isNotBlank(strProjectId)){                    
                            objContentVersion = [SELECT Id, Title,ContentBodyId, VersionData, isLatest,FileExtension, FileType, ContentDocumentId 
                                                 FROM ContentVersion WHERE isLatest = true AND FirstPublishLocationId =: strProjectId];//AND FileExtension = 'pdf'  
                            System.debug('objContentVersion____' +objContentVersion); 
                        }} catch(Exception e) {
                            System.debug('The following exception has occurred: ' + e.getMessage());
                            throw new CommonException('Provide the Project Brochure access to current user');
                        }
                }
                
                
                if(objContentVersion !=null){
                    attachment.setContentType('application/'+objContentVersion.FileExtension);
                    attachment.setFileName(objContentVersion.Title+'.'+objContentVersion.FileExtension);
                    attachment.setInline(false);
                    attachment.Body = objContentVersion.VersionData;
                }    
                
                Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
                
                if(String.isNotBlank(strEmailId)){
                    singleMail.setUseSignature(false);
                    singleMail.setBccSender(false);
                    singleMail.setSaveAsActivity(false);
                    singleMail.setTreatTargetObjectAsRecipient(false);
                    singleMail.setOrgWideEmailAddressId(owa.id);
                    singleMail.setTargetObjectId(strtrgtObjId);
                    singleMail.setTemplateId(EmailTemplateId.id);
                    singleMail.setWhatId(strObjId);
                    singleMail.toaddresses = new string[]{strEmailId};
                    singleMail.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});  
                    ltsEmail.add(singleMail);
                    //Adding content version name as project name
                    if(!Test.isRunningTest()){ 
                        preComm.RW_ProjectDetails_Sent__c= (String.isBlank(preComm.RW_ProjectDetails_Sent__c)) ? objContentVersion.Title : preComm.RW_ProjectDetails_Sent__c + ', ' + objContentVersion.Title;
                    }
                }
            } 
            // To send email when multiple projects are selected - Digicloud Team
            else if (selectedProjectIds.size() > 0) {
                system.debug('Inside else for multiple project ids ==>');
                
                String sObjectPrefix = String.valueOf(sObjId).substring(0, 3); 
                String customerName;
                String customerEmail;
                String Mob_Number;
                
                if (sObjectPrefix == Lead.SObjectType.getDescribe().getKeyPrefix()) {
                    Lead leadRecord = [SELECT Name, Email, RW_Mobile_No__c FROM Lead WHERE Id = :sObjId LIMIT 1];
                    customerName = leadRecord.Name;
                    customerEmail = leadRecord.Email;
                    Mob_Number = leadRecord.RW_Mobile_No__c;
                    
                    System.debug('Lead Record ==> ' + customerEmail);
                } 
                else if (sObjectPrefix == Opportunity.SObjectType.getDescribe().getKeyPrefix()) {
                    Opportunity oppRecord = [SELECT Name, RW_Email__c FROM Opportunity WHERE Id = :sObjId LIMIT 1];
                    customerName = oppRecord.Name;
                    customerEmail = oppRecord.RW_Email__c;
                    Mob_Number = null;
                    
                    System.debug('Opportunity Record ==> ' + customerEmail);
                } 
                else if (sObjectPrefix == Prospect__c.SObjectType.getDescribe().getKeyPrefix()) {
                    Prospect__c prospectRecord = [SELECT Name, Lead__r.Email FROM Prospect__c WHERE Id = :sObjId LIMIT 1];
                    customerName = prospectRecord.Name;
                    customerEmail = prospectRecord.Lead__r.Email;
                    Mob_Number = null;
                    
                    System.debug('Prospect Record ==> ' + customerEmail); 
                }
                else {
                    System.debug('Unknown object type for ID: ' + sObjId);
                }
                
                // Fetch brochures & lifestyle links for selected projects
                List<Project__c> projectList = [SELECT Id, Name, RW_Project_Brochure_PublicUrl__c,RW_Project_Location_Videos_Link__c FROM Project__c WHERE Id IN :selectedProjectIds];
                
                // Get ContentDocumentLinks related to those projects
                List<ContentDocumentLink> cdlList = [SELECT ContentDocumentId, LinkedEntityId 
                                                     FROM ContentDocumentLink 
                                                     WHERE LinkedEntityId IN :selectedProjectIds];
                
                // Collect ContentDocumentIds
                Set<Id> contentDocIds = new Set<Id>();
                Map<Id, List<Id>> projectToDocMap = new Map<Id, List<Id>>();
                
                for (ContentDocumentLink cdl : cdlList) {
                    contentDocIds.add(cdl.ContentDocumentId);
                    
                    if (!projectToDocMap.containsKey(cdl.LinkedEntityId)) {
                        projectToDocMap.put(cdl.LinkedEntityId, new List<Id>());
                    }
                    projectToDocMap.get(cdl.LinkedEntityId).add(cdl.ContentDocumentId);
                }
                
                // Query latest ContentVersions using ContentDocumentIds
                List<ContentVersion> contentVersions = [SELECT Id, Title, ContentBodyId, VersionData, IsLatest, FileExtension, FileType, ContentDocumentId 
                                                        FROM ContentVersion 
                                                        WHERE IsLatest = true AND ContentDocumentId IN :contentDocIds];
                
                // Map attachments to their related Project__c records
                Map<Id, List<ContentVersion>> projectAttachmentsMap = new Map<Id, List<ContentVersion>>();
                
                for (ContentVersion cv : contentVersions) {
                    for (Id projectId : projectToDocMap.keySet()) {
                        if (projectToDocMap.get(projectId).contains(cv.ContentDocumentId)) {
                            if (!projectAttachmentsMap.containsKey(projectId)) {
                                projectAttachmentsMap.put(projectId, new List<ContentVersion>());
                            }
                            projectAttachmentsMap.get(projectId).add(cv);
                        }
                    }
                }
                
                system.debug('projectAttachmentsMap==>'+  projectAttachmentsMap);
                
                string strSubject;
                string emailBody;
                // Send separate emails for each project
                for (Project__c proj : projectList) { 
                    List<ContentVersion> projectFiles = projectAttachmentsMap.get(proj.Id);
                    system.debug('projectFiles==>' + projectFiles); 
                    List<Messaging.EmailFileAttachment> email_Attachments = new List<Messaging.EmailFileAttachment>();
                    
                    strSubject = 'Project Details - '+proj.Name;
                    
                    // Prepare attachments for the current project
                    if (projectFiles != null) {
                        for (ContentVersion cv : projectFiles) {
                            Messaging.EmailFileAttachment file_attachment = new Messaging.EmailFileAttachment();
                            file_attachment.setContentType('application/' + cv.FileExtension);
                            file_attachment.setFileName(cv.Title + '.' + cv.FileExtension);
                            file_attachment.setInline(false);
                            file_attachment.Body = cv.VersionData;
                            email_Attachments.add(file_attachment);
                        }
                        
                        system.debug('proj.Brochure_Link__c==>'+ proj.RW_Project_Brochure_PublicUrl__c);
                        system.debug('proj.E_Brochure_URL__c==>'+ proj.RW_Project_Location_Videos_Link__c); 
                        
                        // Generate email body using the given method
                        if(proj.RW_Project_Brochure_PublicUrl__c != null || proj.RW_Project_Location_Videos_Link__c != null){
                            emailBody = generateEmailBody( customerName, proj.Name, proj.RW_Project_Brochure_PublicUrl__c, proj.RW_Project_Location_Videos_Link__c, customerName, Mob_Number );
                        }
                        
                        // Create and send individual email
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email.setUseSignature(false);
                        email.setBccSender(false);
                        email.setSaveAsActivity(false);
                        email.setTreatTargetObjectAsRecipient(false);
                        email.setOrgWideEmailAddressId(owa.id);
                        email.setTargetObjectId(strtrgtObjId);
                        email.setHtmlBody(emailBody);
                        email.setSubject(strSubject); 
                        if(customerEmail != null){
                            email.setToAddresses(new String[]{customerEmail});
                        }
                        
                        if (!email_Attachments.isEmpty()) {
                            email.setFileAttachments(email_Attachments);
                        }
                        
                        system.debug('Sending Email for Project: ' + proj.Name + ' to ' + customerEmail);
                        ltsEmail.add(email);
                           
                        preComm.RW_ProjectDetails_Sent__c= (String.isBlank(preComm.RW_ProjectDetails_Sent__c)) ? proj.Name : preComm.RW_ProjectDetails_Sent__c + ', ' + proj.Name;
                        
                    }else if(projectFiles == null){
                        
                        preComm.RW_ProjectDetails_Send_Failed__c= (String.isBlank(preComm.RW_ProjectDetails_Send_Failed__c)) ? proj.Name : preComm.RW_ProjectDetails_Send_Failed__c + ', ' + proj.Name;
                    }
                }  
            }
            
            
            if(!Test.isRunningTest()){
                Messaging.SendEmailResult[] results = Messaging.sendEmail(ltsEmail);  
                system.debug('Messaging ' + results[0]);  
                
                if (results[0].success)   
                {  
                    preComm.RW_ProjectDetails_Email_Sent_Date__c = system.now();
                    preComm.RW_Project_Details_Mode_of_Communication__c  = 'Email';  
                    System.debug('The email was sent successfully.');  
                } else   
                {   
                    System.debug('The email failed to send: ' + results[0].errors[0].message);  
                }   
            }
        }
        
        if(setOfselectcheckVal.contains('WhatsApp')){  
            System.debug('In Project deatils WhatsApp');  
            
            String Signature;
            String ContactNumber;
            List<Project__c> lstProject = new List<Project__c>();
            
            If(strSObjectType == 'Lead' ){
                if( selectedProjectIds.size() == 0){ 
                    System.debug('In Project deatils WhatsApp____Lead1');
                    if(String.isNotBlank(objLead.LeadSource)){
                        if(objLead.LeadSource == 'Channel Partner'){
                            Signature = System.Label.RW_CPSignature;
                            ContactNumber = System.Label.RW_CPContactNumber;
                        }else if(objLead.LeadSource != 'Channel Partner'){
                            Signature = System.Label.RW_NotCPSignature;
                            ContactNumber = System.Label.RW_NotCPContactNumber;
                            
                            // Assign default values if fields are null
                            String leadName = String.isNotBlank(objLead.Name) ? objLead.Name : 'Customer';
                            String projectName = String.isNotBlank(objLead.Project_Name__c) ? objLead.Project_Name__c : 'Our Project';
                            String localityName = String.isNotBlank(objLead.RW_Project__r.RW_LocalityName__c) ? objLead.RW_Project__r.RW_LocalityName__c : 'N/A';
                            String mobileNumber = String.isNotBlank(objLead.RW_Mobile_No__c) ? objLead.RW_Mobile_No__c : null;
                            
                            if(objLead.RW_Project__r.Site_Address_Map_Link__c != null && objLead.RW_Project__r.RW_Project_Brochure_PublicUrl__c != null && objLead.RW_Project__r.RW_Project_Location_Videos_Link__c != null ){
                                SendWhatsAppMsg.genaricMethodToSendWhatsAppMsg(leadName, projectName, localityName,
                                                                               objLead.RW_Project__r.Site_Address_Map_Link__c, objLead.RW_Project__r.RW_Project_Brochure_PublicUrl__c, 
                                                                               objLead.RW_Project__r.RW_Project_Location_Videos_Link__c,System.Label.Website_URL,ContactNumber,Signature,
                                                                               objLead.RW_Mobile_No__c,'Lead Project Content 2');
                                system.debug('Send Whatsapp Method for single projects called__');
                            }
                            
                            preComm.RW_ProjectDetails_WhatsApp_Sent_Date__c  = system.now();
                            preComm.RW_Project_Details_Mode_of_Communication__c += ',WhatsApp';
                            preComm.RW_ProjectDetails_Sent__c= (String.isBlank(preComm.RW_ProjectDetails_Sent__c)) ? projectName : preComm.RW_ProjectDetails_Sent__c + ', ' + projectName;
                        } 
                    }    
                    //to send whatsapp message to customer when multiple projects are selected
                }else if(selectedProjectIds.size() >= 1){
                    lstProject = [SELECT Id, Name, ProjectName__c, RW_LocalityName__c, Site_Address_Map_Link__c, RW_Project_Brochure_PublicUrl__c,  
                                  RW_Project_Location_Videos_Link__c from Project__c WHERE Id IN: selectedProjectIds];
                    
                    System.debug('In Project deatils WhatsApp____Lead2');
                    if(String.isNotBlank(objLead.LeadSource)){
                        if(objLead.LeadSource == 'Channel Partner'){
                            Signature = System.Label.RW_CPSignature;
                            ContactNumber = System.Label.RW_CPContactNumber;
                        }else if(objLead.LeadSource != 'Channel Partner'){
                            Signature = System.Label.RW_NotCPSignature;
                            ContactNumber = System.Label.RW_NotCPContactNumber;
                            
                            for(Project__c objProject : lstProject){
                                
                                if(objProject.Site_Address_Map_Link__c != null && objProject.RW_Project_Brochure_PublicUrl__c != null && objProject.RW_Project_Location_Videos_Link__c != null ){
                                    SendWhatsAppMsg.genaricMethodToSendWhatsAppMsg(objLead.Name, objProject.ProjectName__c, objProject.RW_LocalityName__c,
                                                                                   objProject.Site_Address_Map_Link__c, objProject.RW_Project_Brochure_PublicUrl__c, 
                                                                                   objProject.RW_Project_Location_Videos_Link__c,System.Label.Website_URL,ContactNumber,Signature,
                                                                                   objLead.RW_Mobile_No__c,'Lead Project Content 2');
                                    
                                    system.debug('Send Whatsapp Method for multiple projects called__');
                                    preComm.RW_ProjectDetails_WhatsApp_Sent_Date__c  = system.now();
                                    preComm.RW_Project_Details_Mode_of_Communication__c += ',WhatsApp';
                                    preComm.RW_ProjectDetails_Sent__c= (String.isBlank(preComm.RW_ProjectDetails_Sent__c)) ? objProject.Name : preComm.RW_ProjectDetails_Sent__c + ', ' + objProject.Name;
                                    
                                }else if(objProject.Site_Address_Map_Link__c == null || objProject.RW_Project_Brochure_PublicUrl__c == null || objProject.RW_Project_Location_Videos_Link__c == null ){
                                    
                                    preComm.RW_ProjectDetails_Send_Failed__c= (String.isBlank(preComm.RW_ProjectDetails_Send_Failed__c)) ? objProject.Name : preComm.RW_ProjectDetails_Send_Failed__c + ', ' + objProject.Name;
                                }
                            }
                        }
                    }
                }
            }  
            if(strSObjectType == 'Opportunity'){  
                System.debug('In Project deatils WhatsApp____Opportunity');  
                if(String.isNotBlank(objOpp.LeadSource)){
                    if(objOpp.LeadSource == 'Channel Partner'){
                        Signature = System.Label.RW_CPSignature;
                        ContactNumber = System.Label.RW_CPContactNumber;
                    }else if(objOpp.LeadSource != 'Channel Partner'){
                        Signature = System.Label.RW_NotCPSignature;
                        ContactNumber = System.Label.RW_NotCPContactNumber;
                        
                        SendWhatsAppMsg.genaricMethodToSendWhatsAppMsg(objOpp.Name, objOpp.Project_Name__c, objOpp.RW_Project__r.RW_LocalityName__c,
                                                                       objOpp.RW_Project__r.Site_Address_Map_Link__c, objOpp.RW_Project__r.RW_Project_Brochure_PublicUrl__c,
                                                                       objOpp.RW_Project__r.RW_Project_Location_Videos_Link__c,System.Label.Website_URL,ContactNumber,Signature, 
                                                                       objOpp.RW_Mobile_No__c,'Lead Project Content 2');  
                        preComm.RW_ProjectDetails_WhatsApp_Sent_Date__c  = system.now();  
                        preComm.RW_Project_Details_Mode_of_Communication__c += ',WhatsApp';
                    }
                } 
            }
            if(strSObjectType == 'Prospect__c'){
                System.debug('In Project deatils WhatsApp____Prospect__c');
                
                if(objPrspct.Lead__r.IsConverted == false && String.isBlank(objPrspct.Lead__r.ConvertedOpportunityId) && 
                   String.isNotBlank(objPrspct.Lead__r.RW_Mobile_No__c) && String.isNotBlank(objPrspct.Lead__r.LeadSource)){
                       String ProsLeadSignature;
                       String ProsLeadContactNumber;
                       
                       if(objPrspct.Lead__r.LeadSource == 'Channel Partner'){
                           ProsLeadSignature = System.Label.RW_CPSignature;
                           ProsLeadContactNumber = System.Label.RW_CPContactNumber;
                       }else if(objPrspct.Lead__r.LeadSource != 'Channel Partner'){
                           ProsLeadSignature = System.Label.RW_NotCPSignature;
                           ProsLeadContactNumber = System.Label.RW_NotCPContactNumber;
                           
                           SendWhatsAppMsg.genaricMethodToSendWhatsAppMsg(objPrspct.Name, objPrspct.Project__r.Name, objPrspct.Project__r.RW_LocalityName__c,
                                                                          objPrspct.Project__r.Site_Address_Map_Link__c, objPrspct.Project__r.RW_Project_Brochure_PublicUrl__c,
                                                                          objPrspct.Project__r.RW_Project_Location_Videos_Link__c,System.Label.Website_URL,ProsLeadContactNumber,
                                                                          ProsLeadSignature,objPrspct.Lead__r.RW_Mobile_No__c,'Lead Project Content 2');
                       }
                       
                   }else if(String.isNotBlank(objPrspct.Opportunity__r.RW_Mobile_No__c) && String.isNotBlank(objPrspct.Opportunity__r.LeadSource) ){
                       String ProsOppSignature;
                       String ProsOppContactNumber;
                       
                       if(objPrspct.Opportunity__r.LeadSource == 'Channel Partner'){  
                           ProsOppSignature = System.Label.RW_CPSignature;
                           ProsOppContactNumber = System.Label.RW_CPContactNumber;
                       }else if(objPrspct.Opportunity__r.LeadSource != 'Channel Partner'){
                           ProsOppSignature = System.Label.RW_NotCPSignature;
                           ProsOppContactNumber = System.Label.RW_NotCPContactNumber;
                           
                           SendWhatsAppMsg.genaricMethodToSendWhatsAppMsg(objPrspct.Name, objPrspct.Project__r.Name, objPrspct.Project__r.RW_LocalityName__c,
                                                                          objPrspct.Project__r.Site_Address_Map_Link__c, objPrspct.Project__r.RW_Project_Brochure_PublicUrl__c,
                                                                          objPrspct.Project__r.RW_Project_Location_Videos_Link__c,System.Label.Website_URL,ProsOppContactNumber,ProsOppSignature, 
                                                                          objPrspct.Opportunity__r.RW_Mobile_No__c,'Lead Project Content 2');
                       }
                   }
                
                preComm.RW_ProjectDetails_WhatsApp_Sent_Date__c  = system.now();     
                preComm.RW_Project_Details_Mode_of_Communication__c += ',WhatsApp';  
                
            }
        }
        
        
        If(strSObjectType == 'Lead'){
            preComm.RW_Lead__c = objLead.Id;  
        } else if(strSObjectType == 'Opportunity'){
            preComm.RW_Opportunity__c = objOpp.Id;
        } else if(strSObjectType == 'Prospect__c'){
            preComm.RW_Prospect__c = objPrspct.Id;
        }         
        
        
        preComm.RW_Project_Details_Type__c = 'Brochure,Location Videos,Location maps';  
        insert preComm;  
        System.debug('RW_Presales_Communication__c Record inserted______ ' +preComm);  
        
        return preComm; //RW_Presales_Communication__c;  
    }
    
    
    @AuraEnabled(cacheable=true)
    
    public static List<Project__c> getProjectList(Id recordId) {
        Id associatedProjectId;
        
        if (recordId != null) {
            String sobjectPrefix = String.valueOf(recordId).substring(0, 3);
            
            // Determine the object type by prefix
            if (sobjectPrefix == Lead.SObjectType.getDescribe().getKeyPrefix()) {
                Lead lead = [SELECT RW_Project__c FROM Lead WHERE Id = :recordId LIMIT 1];
                associatedProjectId = lead.RW_Project__c;
            } else if (sobjectPrefix == Opportunity.SObjectType.getDescribe().getKeyPrefix()) {
                Opportunity opp = [SELECT RW_Project__c FROM Opportunity WHERE Id = :recordId LIMIT 1];
                associatedProjectId = opp.RW_Project__c;
            } else if (sobjectPrefix == Prospect__c.SObjectType.getDescribe().getKeyPrefix()) {
                Prospect__c prospect = [SELECT Project__c FROM Prospect__c WHERE Id = :recordId LIMIT 1];
                associatedProjectId = prospect.Project__c; 
            }
        }
        
        // Return active projects excluding the associated one
        if (associatedProjectId != null) {
            return [ SELECT Id, Name, RW_Status__c FROM Project__c WHERE RW_Status__c = 'Active' AND Id != :associatedProjectId ];
        } else {
            return new List<Project__c>();
        }
    }
    
    
    @AuraEnabled
    public static String getSObjectTypeById(String url) {
        
        system.debug('Inside getSObjectTypeById ==>'); 
        
        if (String.isBlank(url)) {
            return 'Invalid URL';
        }
        
        // Extract Salesforce ID from URL
        Pattern idPattern = Pattern.compile('[a-zA-Z0-9]{15,18}');
        Matcher matcher = idPattern.matcher(url);
        
        if (matcher.find()) {
            String recordId = matcher.group(0);
            
            Schema.SObjectType sObjectType = ((Id)recordId).getSObjectType();
            return recordId + ',' + String.valueOf(sObjectType);
        }
        
        return 'Record ID not found in URL';
    }
    
    public static String generateEmailBody(String customerName, String projectName, String brochureUrl, String lifestyleUrl, String smsName, String smsNumber) {

    String emailBody = 'Dear ' + customerName + ',<br/><br/>' +
        'Thank you for your interest in ' + projectName + ' by Runwal Enterprises!';
		emailBody += ' As requested, please find the project collaterals attached:<br/>';

    if ((String.isNotBlank(brochureUrl) || String.isNotBlank(lifestyleUrl))) {

        if (String.isNotBlank(brochureUrl)) {
            emailBody += '<br/><a href="' + brochureUrl + '" target="_blank">Digital Brochure</a>';
        }

        if (String.isNotBlank(lifestyleUrl)) {
            emailBody += '<br/><a href="' + lifestyleUrl + '" target="_blank">Connectivity or Lifestyle</a>';
        }
    }
        
    emailBody += '<br/><br/>Have any questions? Our team is here to assist you. Looking forward to helping you take the next step toward your dream home!<br/><br/>' +
        'Visit us at <a href="https://www.runwalenterprises.com" target="_blank">www.runwalenterprises.com</a> to discover more exceptional projects by Runwal Enterprises.<br/><br/>' +
        'Best regards,<br/><br/>' +
        smsName + ' (' + smsNumber + ')<br/>' +
        'Runwal Enterprises';

    System.debug('Inside generateEmailBody ==> ' + emailBody);  
    return emailBody;
}

}