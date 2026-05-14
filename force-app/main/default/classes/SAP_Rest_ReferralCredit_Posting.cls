//Added by Prashant to populate Referral Credit Posting date on due. 21-11-25.
global class SAP_Rest_ReferralCredit_Posting implements Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable {

    global List<Referral_Credits__c> start(Database.BatchableContext bc) {

        return [
            Select id,SAP_Document_Date__c, SAP_Document_No__c, SAP_Posting_Date__c,Booking__r.Project__r.RW_SAP_Company_Code__c,Reference_Booking__r.Project__r.RW_SAP_Company_Code__c,Financial_Year__c from Referral_Credits__c 
            where SAP_Document_No__c != null and Reference_Booking__r.Project__r.RW_SAP_Company_Code__c != null and Financial_Year__c != null
        ];
    }

    global void execute(Database.BatchableContext bc, List<Referral_Credits__c> rcList) {

        String username = System.label.SAP_Username;
        String password = System.label.SAP_Password;
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
		
        
        String baseUrl = System.label.SAP_Referral_Posting_Date; 
        // Example label value: http://123.108.44.40:8002/post_date_sync/posted_date_sync?sap-client=300

        List<Referral_Credits__c> listToUpdate = new List<Referral_Credits__c>();
		List<ERP_Integration_Log__c> apiloglist = new List<ERP_Integration_Log__c>();
        for (Referral_Credits__c rc : rcList) {
			ERP_Integration_Log__c api = new ERP_Integration_Log__c();
            // derive parameters
            String docNo = rc.SAP_Document_No__c;
            String fyYear = rc.Financial_Year__c;
            String compCode = rc.Reference_Booking__r.Project__r.RW_SAP_Company_Code__c;

            // build final dynamic URL
            String finalUrl = baseUrl +
                '&doc_no=' + EncodingUtil.urlEncode(docNo, 'UTF-8') +
                '&fy_year=' + EncodingUtil.urlEncode(fyYear, 'UTF-8') +
                '&comp_cd=' + EncodingUtil.urlEncode(compCode, 'UTF-8');

            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(finalUrl);
            req.setTimeout(120000);
            req.setMethod('GET');
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('Content-Type', 'application/json');

            HttpResponse res = http.send(req);
            System.debug('Request URL: ' + finalUrl);
            System.debug('Response: ' + res.getBody());

            if (res.getStatusCode() == 200 && res.getBody() != '[{"ERROR_LOG":"No data found!"}]') {
                SAPResp jsonBody = (SAPResp) JSON.deserialize(res.getBody(), SAPResp.class);
                String postingDate = String.valueOf(jsonBody.BUDAT);
                if(rc.SAP_Posting_Date__c == null && postingDate != null)
                	rc.SAP_Posting_Date__c =  Date.valueOf(postingDate);  
                //rc.Status__c = 'Posted';
                
                api.API_Name__c = 'Referral Credit Posting';
                //api.Request__c = res.getBody();
                api.Response__c = String.valueOf(res.getBody());
                system.debug('API Response : '+api.Response__c);
                api.Status__c = jsonBody.STATUS;  
                api.Referral_Credit__c = rc.id;
                apiloglist.add(api);
            } else {
                api.Status__c = 'Error';
                api.Response__c = res.getBody();
                 apiloglist.add(api);
            }

            listToUpdate.add(rc);
        }

        if (!listToUpdate.isEmpty()) {
            update listToUpdate;
        }
        
        if (!apiloglist.isEmpty()) {
            insert apiloglist;
        }
        
        system.debug('apiloglist -> '+apiloglist);
        system.debug('listToUpdate -> '+listToUpdate);
        
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('Referral Credit Posting Batch Completed Successfully');
    }

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new BatchforReferralCreditPosting(), 50);
    }

    global class SAPResp {
        public String BUDAT;//Posting date
        public String GJAHR;//Financial yr
        public String BUKRS;//Company code
        public String BELNR;//Document number
        public String STATUS;
    }
}