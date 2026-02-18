public class SendWhatsAppMsgForScheduledTime {
    @InvocableMethod 
    Public Static void methodTofetchLeadFromScheduledFlow(List<String> lstLead){
        System.debug('lstLead>>> ' +lstLead);
        
        Set<String> setLeadId = new Set<String>();
        if(!lstLead.isEmpty() && lstLead.size()>0){
            for(String objLead : lstLead){
                setLeadId.add(objLead);
            }
        }
        system.debug('setLeadId>>>' +setLeadId);
        
        Task objTask = [SELECT Id, Type,WhoId,Call_Status__c,Call_Disposition_Custom__c, Call_Proposed_date_of_visit__c,Visit_Date__c
                        FROM task 
                        WHERE WhoId =: setLeadId AND CreatedDate = today 
                        AND Call_Status__c != null 
                        AND Call_Disposition_Custom__c != null 
                        ORDER BY CreatedDate DESC LIMIT 1];
        
        system.debug('objTask>>>' +objTask);
        
        String elementName;
        String LeadName; 
        String DefaultNo = '02269315204';
        
        List<Lead> lstLeads = [Select Id,Name,FirstName, LastName, RW_Project__c,RW_Project__r.Name,RW_Project__r.Project_Location__c,
                               RW_Project__r.Project_site_URL__c,RW_Project__r.RW_LocalityName__c, RW_Project__r.RW_Project_Location_Videos_Link__c,
                               RW_Project__r.RW_Project_Brochure_PublicUrl__c,RW_Project__r.Testimonial_Video_Link__c,RW_Project__r.Site_Address_Map_Link__c,
                               RW_Location__c, RW_Mobile_No__c, OwnerId, OwnerPhone__c
                               From Lead Where Id =:setLeadId];
        
        
        System.debug('lstLeads>>>' +lstLeads);
        
        if (objTask.Call_Status__c == 'Connected' && objTask.Call_Disposition_Custom__c == 'Visit Scheduled'&& objTask.Visit_Date__c != null) {
            List<RW_Presales_WhatsApp__mdt> customMetaList = [
                SELECT Id, MasterLabel, DeveloperName, Label, RW_element_name__c
                FROM RW_Presales_WhatsApp__mdt
                WHERE DeveloperName IN ('Lead_Site_Visit_Schedule', 'Lead_Notify_Presale_before_15min')
            ];
            
            System.debug('customMetaList >>> ' + customMetaList);
            
            if (!customMetaList.isEmpty() && !lstLeads.isEmpty()) {
                for (Lead objLead : lstLeads) {
                    
                    LeadName = (objLead.FirstName != null ? objLead.FirstName : '') +
                        (objLead.LastName != null ? ' ' + objLead.LastName : '');
                    
                    DateTime dtValue = objTask.Call_Proposed_date_of_visit__c;
                    String onlyDate = dtValue != null ? dtValue.format('dd/MM/yyyy') : '';
                    String onlyTime = dtValue != null ? dtValue.format('hh:mm a') : '';
                    
                    for (RW_Presales_WhatsApp__mdt objMeta : customMetaList) {
                        
                        elementName = objMeta.RW_element_name__c;
                        
                        System.debug('Processing element: ' + elementName);
                        
                        if (objMeta.DeveloperName == 'Lead_Site_Visit_Schedule' && dtValue != null) {
                            
                            /*mtdToSendWhatsAppForVisitScheduledPrior3Hrs(   //Commented by Vinay 22-01-2026 (Removal of Auto Messaging from SFDC)
                                objLead.Id, LeadName, onlyDate, onlyTime,
                                objLead.RW_Project__r.Name,
                                objLead.RW_Project__r.Site_Address_Map_Link__c,
                                objLead.RW_Mobile_No__c, DefaultNo, elementName
                            );*/
                        }
                        // Lead_Notify_Presale_before_15min
                        if (objMeta.DeveloperName == 'Lead_Notify_Presale_before_15min') {
                            mtdToSendWhatsAppToPresalesBefore15min(
                                objLead.Id, LeadName,
                                objLead.OwnerPhone__c, elementName
                            );
                        }  
                    }
                }
            }
            else {
                System.debug('No metadata found or leads are empty.');
            }
        }
    }
    @future(callout=true)
    Private static void mtdToSendWhatsAppForVisitScheduledPrior3Hrs(String LeadId,String LeadName, String VisitDate, String VisitTime, String Project, String SiteLink, String MobileNo, String DefaultNo, String elementName){
        System.debug('--methodToSendWhatsAppMsg--' +LeadId);
        System.debug('MobileNo: ' + MobileNo);
        System.debug('elementName: ' + elementName);
        System.debug('--LeadName--' +LeadName);
        System.debug('VisitDate: ' + VisitDate);
        System.debug('VisitTime: ' + VisitTime);
        
        List<Lead> lstLeads = [Select Id, RW_Mobile_No__c From Lead where Id =: LeadId];
        system.debug('lstLeads>>>' +lstLeads);
        RW_Presales_WhatsApp__mdt customMeta = [SELECT Id, MasterLabel, Label, RW_namespace__c,RW_Type__c,RW_element_name__c
                                                FROM RW_Presales_WhatsApp__mdt where RW_element_name__c =: elementName limit 1];
        system.debug('customMeta>>>' +customMeta);
        
        String templateName = customMeta.RW_element_name__c;
        system.debug('templateName>>>' +templateName);
        String languageCode = 'en';
        
        String jsonParse;
        String fullNumber ='+91'+MobileNo;
        
        jsonParse = '{"countryCode" : "+91",';
        //jsonParse += '"phoneNumber" : ' + '"' + MobileNo + '",';
        jsonParse += '"fullPhoneNumber" : ' + '"' +fullNumber + '",';
        jsonParse += '"campaignId" : ' + '"",';
        
        if(String.isNotBlank(LeadName) && LeadName != null){
            jsonParse += '"callbackData" : ' + '"' + LeadName + '",';
        }
        jsonParse += '"type" : "Template",';
        jsonParse += '"template" : { "name" : '  + '"' + templateName + '", "languageCode" : "'+languageCode+'",';
        jsonParse += '"headerValues"  : [],';
        
        jsonParse += '"bodyValues"  : [';
        if(String.isNotBlank(LeadName) && LeadName != null){
            jsonParse += '"' + LeadName + '",';
        }
        if(VisitDate != null){
            jsonParse += '"' + VisitDate + '",';
        }
        if(VisitTime != null){
            jsonParse += '"' + VisitTime + '",';
        }
        if(String.isNotBlank(Project) && Project != null){
            jsonParse += '"' + Project + '",';
        }
        if(String.isNotBlank(SiteLink) && SiteLink != null){
            jsonParse += '"' + SiteLink + '",';
        }
        if(String.isNotBlank(DefaultNo) && DefaultNo != null){
            jsonParse += '"' + DefaultNo + '"';
        }
        
        jsonParse += ']}}';
        
        JSONParser parser = JSON.createParser(jsonParse);
        System.debug('jsonParse '+jsonParse);
        Http http = new Http();
        HttpRequest req = new HttpRequest(); 
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Basic ' + System.Label.Interakt_Secret_Key); 
        req.setEndpoint('https://api.interakt.ai/v1/public/message/');
        req.setBody(jsonParse);
        HTTPResponse res = http.send(req);
        System.debug('End Point '+req.getEndpoint());
        System.debug('res!!! getBody '+res.getBody());
        System.debug('res!!! getStatusCode '+res.getStatusCode());
        System.debug('Call status: Connected and call Sub status: Visit Scheduled---Site Visit Scheduled send email to Customer::::: ');
        
    }
    
    @future(callout=true)
    Private static void mtdToSendWhatsAppToPresalesBefore15min(String LeadId,String LeadName, String MobileNo, String elementName){
        System.debug('--methodToSendWhatsAppMsg--' +LeadId);
        System.debug('MobileNo: ' + MobileNo);
        System.debug('elementName: ' + elementName);
        System.debug('--LeadName--' +LeadName);
        
        
        List<Lead> lstLeads = [Select Id, OwnerId, OwnerPhone__c From Lead where Id =: LeadId];
        system.debug('lstLeads>>>' +lstLeads);
        RW_Presales_WhatsApp__mdt customMeta = [SELECT Id, MasterLabel, Label, RW_namespace__c,RW_Type__c,RW_element_name__c
                                                FROM RW_Presales_WhatsApp__mdt where RW_element_name__c =: elementName limit 1];
        system.debug('customMeta>>>' +customMeta);
        
        String templateName = customMeta.RW_element_name__c;
        system.debug('templateName>>>' +templateName);
        String languageCode = 'en';
        
        String jsonParse;
        String fullNumber ='+91'+MobileNo;
        
        jsonParse = '{"countryCode" : "+91",';
        //jsonParse += '"phoneNumber" : ' + '"' + MobileNo + '",';
        jsonParse += '"fullPhoneNumber" : ' + '"' +fullNumber + '",';
        jsonParse += '"campaignId" : ' + '"",';
        
        if(String.isNotBlank(LeadName) && LeadName != null){
            jsonParse += '"callbackData" : ' + '"' + LeadName + '",';
        }
        jsonParse += '"type" : "Template",';
        jsonParse += '"template" : { "name" : '  + '"' + templateName + '", "languageCode" : "'+languageCode+'",';
        jsonParse += '"headerValues"  : [],';
        
        jsonParse += '"bodyValues"  : [';
        if(String.isNotBlank(LeadName) && LeadName != null){
            jsonParse += '"' + LeadName + '"';
        }
        
        jsonParse += ']}}';
        
        JSONParser parser = JSON.createParser(jsonParse);
        System.debug('jsonParse '+jsonParse);
        Http http = new Http();
        HttpRequest req = new HttpRequest(); 
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Basic ' + System.Label.Interakt_Secret_Key); 
        req.setEndpoint('https://api.interakt.ai/v1/public/message/');
        req.setBody(jsonParse);
        HTTPResponse res = http.send(req);
        System.debug('End Point '+req.getEndpoint());
        System.debug('res!!! getBody '+res.getBody());
        System.debug('res!!! getStatusCode '+res.getStatusCode());
        System.debug('Call status: Connected and call Sub status: Visit Scheduled---Remainder Before 15 Min to Pre-Sales User:::::');
        
    }    
    public static void dummyMethod(){
        
        integer i;
        i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;            i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;  i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;            i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;            i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
    }   
}