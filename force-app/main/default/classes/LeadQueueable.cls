public class LeadQueueable implements Queueable, Database.AllowsCallouts {
    List<Lead> leads = new List<Lead>();

    public LeadQueueable(List<Lead> leads) {
        this.leads = leads;
    }

    public void execute(QueueableContext context) {
        List<Id> digitalLeadIds = new List<Id>();
        List<Id> allLeadIds = new List<Id>();
        for(Lead l : leads){
            allLeadIds.add(l.Id);
            if(l.LeadSource == 'Digital'){
                digitalLeadIds.add(l.Id);
            }
        }
        try{
            if(digitalLeadIds.size() > 0){
                GetCurrentLoggedInAgents.getAgentsDetailsForBatch(digitalLeadIds);
            }
        }catch(exception e){
            System.debug('Error: ' + e.getMessage());
        }finally{
            whatsAppMsgForNewLead(allLeadIds);
        }
        
    }
    
    @future(callout=true)
    public static void whatsAppMsgForNewLead(List<Id> allLeadIds){
        
        String templateName;
        String languageCode = 'en';
        String jsonParse;
        String fullNumber;
        
        // Fetch metadata record
        RW_Presales_WhatsApp__mdt objMeta = [
            SELECT RW_element_name__c
            FROM RW_Presales_WhatsApp__mdt 
            WHERE DeveloperName = 'Lead_Welcome_Msg'
            LIMIT 1
        ];
        System.debug('objMeta >>> ' + objMeta);
        
        if (objMeta == null) {
            System.debug('Metadata not found. Exiting method.');
            return;
        }
        
        templateName = objMeta.RW_element_name__c;
        
        // Query leads
        List<Lead> lstLeads = [SELECT Id, Name, RW_Mobile_No__c, RW_Project__r.Name, RW_Project__r.RW_LocalityName__c, Owners_Team__c,LeadSource
                               FROM Lead 
                               WHERE Id IN :allLeadIds];
        system.debug('lstLeads>>>>>' +lstLeads);
        Http http = new Http();
        for (Lead objLead : lstLeads) {
            
            if (String.isBlank(objLead.RW_Mobile_No__c)) {
                System.debug('Skipping lead ' + objLead.Id + ' due to missing mobile number.');
                continue;
            }
            fullNumber = '+91' + objLead.RW_Mobile_No__c;
            System.debug('Sending WhatsApp message to ' + fullNumber);
            
            // Construct JSON payload
            jsonParse = '{"countryCode": "+91",';
            jsonParse += '"fullPhoneNumber": "' + fullNumber + '",';
            jsonParse += '"campaignId": "",';
            jsonParse += '"callbackData": "' + objLead.Name + '",';
            jsonParse += '"type": "Template",';
            jsonParse += '"template": { "name": "' + templateName + '", "languageCode": "' + languageCode + '",';
            jsonParse += '"headerValues": [],';
            jsonParse += '"bodyValues": [';
            
            List<String> bodyValues = new List<String>();
            if (String.isNotBlank(objLead.Name)) {
                bodyValues.add('"' + objLead.Name + '"');
            }
            if (objLead.RW_Project__r.Name != null && String.isNotBlank(objLead.RW_Project__r.Name)) {
                bodyValues.add('"' + objLead.RW_Project__r.Name + '"');
            }
            if (objLead.RW_Project__r.RW_LocalityName__c != null && String.isNotBlank(objLead.RW_Project__r.RW_LocalityName__c)) {
                bodyValues.add('"' + objLead.RW_Project__r.RW_LocalityName__c + '"');
            }
            jsonParse += String.join(bodyValues, ',') + ']}}';
            
            System.debug('JSON Payload: ' + jsonParse);
            
            // Send HTTP request
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', 'Basic ' + System.Label.Interakt_Secret_Key);
            req.setEndpoint('https://api.interakt.ai/v1/public/message/');
            req.setBody(jsonParse);
            
            try {
                HTTPResponse res = http.send(req);
                System.debug('Response Status: ' + res.getStatusCode());
                System.debug('Response Body: ' + res.getBody());
                System.debug('Welcome Lead Email::::::');
            } catch (Exception e) {
                System.debug('Error sending WhatsApp message: ' + e.getMessage());
            }
        }    
    }
    
    
}