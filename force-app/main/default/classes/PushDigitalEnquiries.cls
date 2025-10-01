public class PushDigitalEnquiries implements Queueable, database.allowscallouts {
    public List < Task > enquiryList;
    public PushDigitalEnquiries(List < Task > tskList) {
        this.enquiryList = tskList;
    }
    public void execute(QueueableContext qc) {
        system.debug('inside execute Method enquiry List::' + enquiryList);
        List < Task > TList = [SELECT FullName__c, Mobile_Number_Webform__c FROM Task LIMIT 1];
        System.debug(' TList::' + TList);
        for (Task t: enquiryList) {
            String exceptionMsg = '';
            Boolean callOutError = false;

            if (t.FullName__c == null) t.FullName__c = '';
            if (t.Mobile_Number_Webform__c == null) t.Mobile_Number_Webform__c = '';

            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeNumberField('campaignId', 55);

            gen.writeFieldName('customerAndCallbackRecords');
            gen.writeStartArray();
            gen.writeStartObject();
            for (Task l: enquiryList) {

                gen.writeFieldName('customerRecord');
                gen.writeStartObject();
                gen.writeStringField('phone1', t.Mobile_Number_Webform__c);
                gen.writeStringField('name', t.FullName__c);
                gen.writeEndObject();
            }
            gen.writeEndObject();
            gen.writeEndArray();

            gen.writeNumberField('leadId', 117);
            gen.writeStringField('status', 'NOT_TRIED');

            gen.writeFieldName('properties');
            gen.writeStartObject();
            gen.writeBooleanField('update.customer', true);
            gen.writeBooleanField('migrate.customer', true);
            gen.writeEndObject();

            gen.writeNumberField('attempts', 0);
            gen.writeEndObject();
            
            String pretty = gen.getAsString();
            pretty = 'data='+pretty;
            System.debug('Formatted json Request::' + pretty);
            Http httpProtocol = new Http();
            HttpRequest request = new HttpRequest();
            request.setMethod('POST');
            request.setHeader('content-type', 'application/x-www-form-urlencoded');
            request.setHeader('hash-key', 'c450c5b2071cbabc9');
            request.setHeader('policy-name', 'token-based-authorization-policy');
            request.setHeader('requesting-host', 'runwal-cmapi');
            request.setEndPoint('http://202.149.220.187:8888/ameyowebaccess/command?command=uploadContactAndAddCallback');
            request.setBody(pretty);
            System.debug(' Request::' + request);
            ResponseLog resLog = new ResponseLog();

            try {
                if (!Test.isRunningTest()) {
                    HttpResponse response = httpProtocol.send(request);
                    System.debug('Response:' + response.getBody());
                    System.debug('Response:' + response);
                    //resLog = resLog.parse(response.getBody());
                }
                /*if (resLog != null && resLog.status != null && !resLog.status.equalsIgnorecase('OK')) {
                    callOutError = true;
                    exceptionMsg = resLog.message;
                }*/

            } catch (Exception ex) {
                System.debug('Exception:' + ex.getMessage());
                callOutError = true;
                exceptionMsg = ex.getMessage();
            }

        }

    }
    public static void checkPrerequisiteforCallout(Set < Id > enqIds) {
        system.debug('inside check prerequisite Method::' + enqIds);
        List < Task > anarockQualifiedLeads = new List < Task > ();
        if (!enqIds.isEmpty()) {
            anarockQualifiedLeads = [Select Id, whoId, WhatId, task_type__c, Status, FullName__c, emailAddress__c, country__c, dialingCode__c,
                Mobile_Number_Webform__c, Source_of_enquiry__c, Sub_source_of_enquiry__c, Budget_WebForm__c, Configuration__c,
                Project__c, Project__r.Send_Digital_data_to_Anarock__c, Project__r.Anarock_Campaign_Id__c, CreatedDate,
                UTM_Campaign__c, UTM_Display__c, UTM_Medium__c, description, UTM_Source__c, UTM_Term__c, Project__r.Name
                from Task where Id IN: enqIds
            ];

            system.debug('all anarock QualifiedLeadList::' + anarockQualifiedLeads);

            if (!anarockQualifiedLeads.isEmpty() && anarockQualifiedLeads.size() > 0) {
                system.debug('All anarock QualifiedLeadList size::' + anarockQualifiedLeads.size());
                // Calling out Anarock API for all qualified leads.
                System.enqueueJob(new PushDigitalEnquiries(anarockQualifiedLeads));
            } else {
                system.debug('No enquiries qualified for Anarock Callout');
            }
        }

    }

    public class ResponseLog {
        public String status;
        public String message;
        public Response response;
        public List < Errors > errors;

        public ResponseLog parse(String json) {
            return (ResponseLog) System.JSON.deserialize(json, ResponseLog.class);
        }
    }
    public class Response {
        public Integer lead_id;
        public Integer inquiries_count;
        public Integer last_inquiry_id;
    }
    public class Errors {
        public String message;
    }

}