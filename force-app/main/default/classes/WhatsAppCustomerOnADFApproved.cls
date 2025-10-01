public class WhatsAppCustomerOnADFApproved implements Queueable, Database.allowscallouts {
   Private List<Id> CreditNoteIds;
    public WhatsAppCustomerOnADFApproved(List<Id> CreditNoteIds){
        system.debug('CreditNoteIds>>>' +CreditNoteIds);
        this.CreditNoteIds = CreditNoteIds;
        
    }
    public void execute(QueueableContext context){
   /*  @InvocableMethod
    Public Static void ApprovedCreditNote(List<String> lstCreditNote){
        System.debug('lstCreditNote>>> ' +lstCreditNote);
        
        Set<String> setCreditNoteId = new Set<String>();
        if(!lstCreditNote.isEmpty() && lstCreditNote.size()>0){
            for(String objCN : lstCreditNote){
                setCreditNoteId.add(objCN);
            }
        }
        system.debug('setCreditNoteId>>>' +setCreditNoteId);
        
*/
        String templateName;
        String languageCode = 'en';
        String jsonParse;
        String fullNumber;
        
        // Fetch metadata record
        Collection_WhatsApp__mdt objMeta = [
            SELECT element_name__c
            FROM Collection_WhatsApp__mdt 
            WHERE DeveloperName = 'Notify_Cust_for_ADF'
            LIMIT 1
        ];
        System.debug('objMeta >>> ' + objMeta);
        
        if (objMeta == null) {
            System.debug('Metadata not found. Exiting method.');
            return;
        }
        
        templateName = objMeta.element_name__c;
        
        // Query leads
        List<Credit_Note__c> lstCN = [SELECT Id, Name, Customer_Name__c,Interest_To_Be_Settled__c, Booking__r.Customer__r.RW_Mobile_No__c,
                                     Project__c, Unit_No__c //, Booking__r.Customer__r.Mobile_Number__c
                                          FROM Credit_Note__c 
                                          WHERE Approval_Status__c = 'Approved' AND Id IN :CreditNoteIds];
        system.debug('lstCN>>>>>' +lstCN);
        Http http = new Http();
        
        for (Credit_Note__c objCN : lstCN) {              
            
            if (String.isBlank(objCN.Booking__r.Customer__r.RW_Mobile_No__c)) {
                System.debug('Skipping lead ' + objCN.Id + ' due to missing mobile number.');
                continue;
            }
            
            fullNumber = '+91' + objCN.Booking__r.Customer__r.RW_Mobile_No__c;
            System.debug('Sending WhatsApp message to ' + fullNumber);
            
            // Construct JSON payload
            jsonParse = '{"countryCode": "+91",';
            jsonParse += '"fullPhoneNumber": "' + fullNumber + '",';
            jsonParse += '"campaignId": "",';
            jsonParse += '"callbackData": "' + objCN.Customer_Name__c + '",';
            jsonParse += '"type": "Template",';
            jsonParse += '"template": { "name": "' + templateName + '", "languageCode": "' + languageCode + '",';
            jsonParse += '"headerValues": [],';
            jsonParse += '"bodyValues": [';
            
            List<String> bodyValues = new List<String>();
            if (String.isNotBlank(objCN.Customer_Name__c)) {
                bodyValues.add('"' + objCN.Customer_Name__c + '"');
            }
            if (objCN.Interest_To_Be_Settled__c != null) {
                bodyValues.add('"' + objCN.Interest_To_Be_Settled__c + '"');
            }
            if (objCN.Project__c != null && String.isNotBlank(objCN.Project__c)) {
                bodyValues.add('"' + objCN.Project__c + '"');
            }
            if (objCN.Unit_No__c != null && String.isNotBlank(objCN.Unit_No__c)) {
                bodyValues.add('"' + objCN.Unit_No__c + '"');
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
            } catch (Exception e) {
                System.debug('Error sending WhatsApp message: ' + e.getMessage());
            }
        }        
    }
}